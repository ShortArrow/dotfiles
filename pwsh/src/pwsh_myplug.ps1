# Skip profile for non-interactive sessions (e.g. pwsh -c)
if (-not [Environment]::UserInteractive -or [Console]::IsInputRedirected) { return }

# Profile load time measurement
$profileLoadStart = Get-Date

# Initialize command check cache and need install list
$script:commandExistCache = @{}
$script:needInstallList = @()

# Helper functions
function Test-CommandExist([string]$cmd) {
  if ($script:commandExistCache.ContainsKey($cmd)) {
    return $script:commandExistCache[$cmd]
  }

  $foundCommand = Get-Command $cmd -ErrorAction SilentlyContinue
  $exists = $null -ne $foundCommand -and $foundCommand.Count -gt 0
  
  $script:commandExistCache[$cmd] = $exists
  return $exists
}

function Set-CommandAlias([string]$aliasName, [string]$commandName, [string]$fallback = "") {
  if (Test-CommandExist($commandName)) {
    New-Alias -Name $aliasName -Value $commandName -Force -Scope Global -ErrorAction Stop
  }
  else {
    $msg = "Please install $commandName"
    $fallbackFunctionName = "Invoke_$($aliasName)_Fallback"
    # Dynamically create a function for the fallback
    Set-Item -Path "Function:Global:$fallbackFunctionName" -Value {
      param([string]$message = $msg) # Capture $msg in the closure
      Write-Host $message
    }.GetNewClosure()
    New-Alias -Name $aliasName -Value $fallbackFunctionName -Force -Scope Global -ErrorAction Stop
    $script:needInstallList += $commandName
  }
}

# Environment variable management
function Reload-EnvironmentVariables {
  $reloadStart = [DateTime]::Now

  function Get-EnvVar([string]$name, [string]$scope) {
    [System.Environment]::GetEnvironmentVariable($name, $scope)
  }

  # Merge Machine + User PATH while preserving process-specific entries (e.g. mise shims)
  # and removing case-insensitive duplicates. Order: process-only -> Machine -> User.
  $machinePath = (Get-EnvVar 'Path' 'Machine') -split ';' | Where-Object { $_ }
  $userPath = (Get-EnvVar 'Path' 'User')    -split ';' | Where-Object { $_ }
  $currentPath = $env:Path -split ';' | Where-Object { $_ }

  $machineSet = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]($machinePath | ForEach-Object { $_.TrimEnd('\') }),
    [System.StringComparer]::OrdinalIgnoreCase)
  $userSet = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]($userPath | ForEach-Object { $_.TrimEnd('\') }),
    [System.StringComparer]::OrdinalIgnoreCase)

  $processOnly = $currentPath | Where-Object {
    $n = $_.TrimEnd('\')
    -not $machineSet.Contains($n) -and -not $userSet.Contains($n)
  }

  $merged = @($processOnly) + @($machinePath) + @($userPath)
  $seen = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase)
  $deduped = foreach ($p in $merged) {
    if ($seen.Add($p.TrimEnd('\'))) { $p }
  }
  $newPath = ($deduped -join ';')

  $envVars = @{
    Path   = @{
      Current = $env:Path
      New     = $newPath
    }
    EDITOR = @{
      Current = $env:EDITOR
      New     = (Get-EnvVar 'EDITOR' 'Machine') ?? (Get-EnvVar 'EDITOR' 'User')
    }
    VISUAL = @{
      Current = $env:VISUAL
      New     = (Get-EnvVar 'VISUAL' 'Machine') ?? (Get-EnvVar 'VISUAL' 'User')
    }
  }

  $changed = $false
  foreach ($var in $envVars.GetEnumerator()) {
    if ($var.Value.Current -ne $var.Value.New) {
      Set-Item "env:$($var.Key)" $var.Value.New
      $changed = $true
    }
  }
  
  # Only broadcast if changes were made
  if ($changed) {
    # Only load assembly if needed
    if (-not ([System.Management.Automation.PSTypeName]'NativeMethodsForEnvReload').Type) {
      Add-Type @"
      using System;
      using System.Runtime.InteropServices;

      public class NativeMethodsForEnvReload {
          [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
          [return: MarshalAs(UnmanagedType.Bool)]
          public static extern bool SendNotifyMessage(IntPtr hWnd, uint Msg, IntPtr wParam, string lParam);
      }
"@
    }
    
    # Broadcast environment changes
    $HWND_BROADCAST = [System.IntPtr]0xffff
    $WM_SETTINGCHANGE = 0x1a
    [NativeMethodsForEnvReload]::SendNotifyMessage($HWND_BROADCAST, $WM_SETTINGCHANGE, [System.IntPtr]::Zero, "Environment") | Out-Null
    Write-Debug "Environment variables updated and broadcasted."
  }

  $reloadDuration = (Get-Date) - $reloadStart
  Write-Debug "Environment reload took: $($reloadDuration.TotalMilliseconds) ms"
}
## Reload this profile
function Read-Profile() {
  . $PROFILE
  Write-Host "Reloaded profile. 😀" -ForeGroundColor Green
}
New-Alias -Name reload -Value Read-Profile -Force

# New-Item -Type File -Path $PROFILE -Force

# PSReadLine requires a console host with virtual terminal support. Skip setup in
# non-interactive / redirected sessions to avoid initialization errors.
if ((Get-Module PSReadLine -ListAvailable) -and [Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
  Import-Module PSReadLine -ErrorAction SilentlyContinue
  try {
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
    Set-PSReadlineOption -HistoryNoDuplicates
    Set-PSReadlineOption -BellStyle None
    Set-PSReadlineOption -EditMode "Vi"
    Set-PSReadLineKeyHandler -Chord "Ctrl+n" -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord "Ctrl+p" -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Chord "Ctrl+delete" -Function BackwardKillWord

    # Skip history entries matching: literal SKIPHISTORY, single alphabetic chars, or exit.
    Set-PSReadlineOption -AddToHistoryHandler {
      param ($command)
      if ([string]::IsNullOrEmpty($command)) { return $false }
      try {
        switch -regex ($command) {
          "SKIPHISTORY|^[a-z]$|exit" { return $false }
          default { return $true }
        }
      } catch {
        return $true
      }
    }

    # Word delimiters on cursor navigation by ctrl + arrows
    Set-PSReadLineOption -WordDelimiters ";:,.[]{}()/\|^&*-=+'`" !?@#$%&_<>「」（）『』『』［］、，。：；／"
  } catch {
    Write-Debug "PSReadLine setup failed: $($_.Exception.Message)"
  }
}

# prompt setting
# choco install starship
# Initialize starship - needed for prompt functionality
if (Test-CommandExist('starship')) {
  Invoke-Expression (&starship init powershell)

  # OSC escape sequence for terminal title (tab title)
  function Set-TerminalTitle {
    $folder = Split-Path -Leaf (Get-Location)
    if (-not $folder) {
      $folder = (Get-Location).Path  # Drive root
    }
    # HOME -> ~
    if ((Get-Location).Path -eq $HOME) {
      $folder = "~"
    }
    # OSC 1 (icon title / tab title)
    Write-Host -NoNewline "`e]1;$folder`a"
    # OSC 7 (CWD notification for wezterm)
    $uri = "file://$env:COMPUTERNAME/" + ((Get-Location).Path -replace '\\', '/')
    Write-Host -NoNewline "`e]7;$uri`a"
  }

  # Wrap starship prompt to set terminal title
  $script:originalPrompt = $function:prompt
  function prompt {
    Set-TerminalTitle
    & $script:originalPrompt
  }
}
else {
  Write-Warning "Starship is not installed. Prompt customization will be disabled."
}

# Reload PROFILE
Set-PSReadLineKeyHandler -Key "Alt+R" -BriefDescription "reloadPROFILE" -LongDescription "reloadPROFILE" -ScriptBlock {
  Write-Output "Reloading profile..."
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('<#SKIPHISTORY#> . $PROFILE')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# PSFzf
$env:FZF_DEFAULT_OPTS = @'
--style=minimal
--bind ctrl-u:unix-line-discard
--gutter '󰌪' --color gutter:green
--color gutter:green
'@

# Preview file content using bat (https://github.com/sharkdp/bat)
# $env:FZF_CTRL_T_OPTS=@'
#   --walker-skip .git,node_modules,target
#   --preview 'bat -n --color=always {}'
#   --bind 'ctrl-/:change-preview-window(down|hidden|)'
# '@

# CTRL-Y to copy the command into clipboard using pbcopy
$env:FZF_CTRL_R_OPTS=@'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'
'@

# Print tree structure in the preview window
# $env:FZF_ALT_C_OPTS=@'
#   --walker-skip .git,node_modules,target
#   --preview 'tree -C {}'
# '@

# gsudo
# choco install gsudo
$gsudoModulePath = 'C:\tools\gsudo\Current\gsudoModule.psd1'

# Create a proxy function for gsudo that loads the module on first use
function Initialize-Gsudo {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
  
  if (Test-Path $gsudoModulePath) {
    Import-Module $gsudoModulePath
    # Remove this function after module is loaded
    Remove-Item Function:\Initialize-Gsudo
    # Load completion
    (Get-Module gsudoModule).ExportedCommands.Values |
    Where-Object { $_.CommandType -eq 'Cmdlet' -or $_.CommandType -eq 'Function' } |
    ForEach-Object { . (Get-Command -Name $_.Name -CommandType Function).ScriptBlock }
  }
  else {
    Write-Warning "gsudo module not found at $gsudoModulePath"
  }
}
# Register the proxy function
Set-Item -Path Function:\gsudo -Value ${function:Initialize-Gsudo}

# go path (appended only if not already present)
if (Test-CommandExist('go')) {
  $goBin = "$env:USERPROFILE\go\bin"
  $hasGoBin = ($env:Path -split ';') |
    Where-Object { $_.TrimEnd('\').Equals($goBin.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase) }
  if (-not $hasGoBin) { $env:Path = "$env:Path;$goBin" }
}

# mise: resolved via %LocalAppData%\mise\shims on the persistent PATH (windows/PATH.txt).
# `mise activate` is intentionally not used — it prepends ~20 per-tool install dirs and
# pushes the process PATH past cmd.exe's 8191-char limit, breaking npm run-scripts.
# node-gyp must resolve python without going through a mise shim: a shimmed `python`
# runs `mise x`, which blocks on the lock held by a parent `mise install`/`mise up`.
if (Test-CommandExist('mise') -and -not $env:NODE_GYP_FORCE_PYTHON) {
  $misePython = mise which python 2>$null
  if ($misePython -and (Test-Path $misePython)) { $env:NODE_GYP_FORCE_PYTHON = $misePython }
}

# lunarvim setup
$lunarvimPath = "$env:USERPROFILE\.local\bin\lvim.ps1"
Set-CommandAlias 'lvim' $lunarvimPath -fallback 'lunarvim'

# lsd: ls, ll, l., ll. are handled by runex

if (Test-CommandExist('zoxide')) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
else {
  # Define Show-NeedInstall if not already defined
  if (-not (Get-Command Show-NeedInstall -ErrorAction SilentlyContinue)) {
    function Show-NeedInstall {
      Write-Host "Required command not found. Please install it."
    }
  }
  # Define Add-NeedInstall if not already defined
  if (-not (Get-Command Add-NeedInstall -ErrorAction SilentlyContinue)) {
    function Add-NeedInstall([string]$command) {
      $script:needInstallList += $command
      Write-Host "$command added to the list of commands to install."
    }
  }
  New-Alias -Name z -Value Show-NeedInstall -Force
  Add-NeedInstall 'zoxide'
}

## password generator
function New-Password($length = 32) {
  $currentTime = Get-Date

  # Generate a hash from the current time
  $hash = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
  $byteArray = [System.Text.Encoding]::UTF8.GetBytes($currentTime.ToString())
  $hashedBytes = $hash.ComputeHash($byteArray)
  $hashString = -join $hashedBytes.ForEach({ $_.ToString("x2") })

  # Set current time as random seed
  $seed = [int]($currentTime.Ticks % [int]::MaxValue)
  $random = New-Object System.Random($seed)

  # Pick random characters from the hash string
  $password = for ($i = 0; $i -lt $length; $i++) {
    $position = $random.Next(0, $hashString.Length)
    $hashString[$position]
  }
  -join $password
}

## escape sequence color checker
function Test-TrueColor {
  $testStringForeground =
  " `e[48;2;255;255;255m`e[38;2;255;0;0m 赤 `e[0m" +
  " `e[48;2;255;255;255m`e[38;2;0;255;0m 緑 `e[0m" +
  " `e[48;2;255;255;255m`e[38;2;0;0;255m 青 `e[0m"
  $testStringBackground =
  " `e[48;2;255;0;0m`e[38;2;255;255;255m 赤 `e[0m" +
  " `e[48;2;0;255;0m`e[38;2;255;255;255m 緑 `e[0m" +
  " `e[48;2;0;0;255m`e[38;2;255;255;255m 青 `e[0m"

  Write-Host -NoNewline "`r`n"
  Write-Host -NoNewline $testStringForeground
  Write-Host -NoNewline "`r`n`r`n"
  Write-Host -NoNewline $testStringBackground
  Write-Host -NoNewline "`r`n`r`n"
  Write-Host "if the text above is displayed in RGB, TrueColor is supported."
}

## reboot
function Start-Reboot() {
  Restart-Computer -Force
}
New-Alias -Name reboot -Value Start-Reboot -Force

## poweroff
function Start-Poweroff() {
  Stop-Computer -Force
}
New-Alias -Name poweroff -Value Start-Poweroff -Force

## CFA (Controlled Folder Access)
function GetCfaEvent() {
  Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational"
  | Where-Object { $_.Id -eq "1123" }
  | fzf --reverse
}
New-Alias -Name cfa -Value GetCfaEvent -Force

function LoginGhcrIo() {
  gh auth refresh --scopes read:packages
  $username = Read-Host "Enter your username"
  gh auth token | docker login ghcr.io --username $username --password-stdin
}

# Install check for applications with direct paths
$appPaths = @{
  'chromedev' = @{
    Path    = "C:\Program Files\Google\Chrome Dev\Application\chrome.exe"
    Message = 'Please install Chrome Dev.'
  }
  'thorium'   = @{
    Path    = "$env:LOCALAPPDATA/Thorium/Application/thorium.exe"
    Message = 'Please install Thorium.'
  }
  'tshark'    = @{
    Path    = "C:\Program Files\Wireshark\tshark.exe"
    Message = 'Please install Wireshark.'
  }
}

foreach ($app in $appPaths.GetEnumerator()) {
  $name = $app.Key
  $path = $app.Value.Path
  $message = $app.Value.Message
  
  # Create a function with the app name
  Set-Item -Path "Function:Global:$name" -Value {
    param($name = $name, $path = $path, $message = $message)
    if (Test-Path $path) {
      & $path @args
    } else {
      Write-Host $message
    }
  }.GetNewClosure()
}

# ConvertFrom-Json for ShiftJIS
Function ConvertFrom-JsonShiftJIS {
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$json
  )
  $jsonBytes = [System.Text.Encoding]::GetEncoding("shift_jis").GetBytes($json)
  $jsonString = [System.Text.Encoding]::UTF8.GetString($jsonBytes)
  ConvertFrom-Json -InputObject $jsonString
}

# glazewm dev
$glazewmPath = "$env:USERPROFILE/Documents/GitHub/glazewm/target/release/glazewm.exe"
$glazewmCliPath = "$env:USERPROFILE/Documents/GitHub/glazewm/target/release/glazewm-cli.exe"
function GetGlazewmWindows() {
  $(& "$glazewmCliPath" query windows | ConvertFrom-JsonShiftJIS ).data.windows
  | % { $index = 0 } {
    [PSCustomObject]@{
      Index       = $index
      Title       = $_.title
      ProcessName = $_.processname
      ClassName   = $_.classname
    }; $index++; }
  | ft -AutoSize
}
if (Test-Path $glazewmPath) {
  New-Alias -Force -Name glazewmdev -Value $glazewmPath
  New-Alias -Force -Name glazewm-cli -Value $glazewmCliPath
  New-Alias -Force -Name Get-GlazewmWindows -Value GetGlazewmWindows
}
else {
  New-Alias -Force -Name glazewmdev -Value "Write-Host 'Please build glazewm Dev.'"
}

# default Apps
function SetDefaultApp() {
  # https://learn.microsoft.com/en-us/windows/uwp/launch-resume/launch-settings-app
  Start-Process ms-settings:defaultapps
}
New-Alias -Name Set-DefaultApp -Value SetDefaultApp -Force

#For PowerShell v3
Function gig {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$list
  )
  $params = ($list | ForEach-Object { [uri]::EscapeDataString($_) }) -join ","
  $DebugPreference = 'SilentlyContinue'
  Invoke-RestMethod -Uri "https://www.toptal.com/developers/gitignore/api/$params"
}


# Windows wmic
function Get-LogicalDisks {
  wmic logicaldisk get name, volumename
}

# RecycleBin
function Get-RecycleBin {
  $recycleBin = Get-ChildItem -Path "C:\$Recycle.Bin" -Force
  $recycleBin | Where-Object { $_.PSIsContainer } | ForEach-Object {
    Write-Host "Drive: $($_.Name)"
    Get-ChildItem -Path $_.FullName -Force | Select-Object Name, Length, LastWriteTime
  }
}

function Show-RecycleBin {
  explorer.exe shell:RecycleBinFolder
}

# path
function Edit-Env {
  param(
    [string]$ScopeName,
    [string]$VariableName,
    [string]$EditorName
  )
  # Check if Vim is available
  if (-not (Get-Command $EditorName -ErrorAction SilentlyContinue)) {
    Write-Error "${EditorName}is not installed or not in PATH."
    return
  }

  # Get current user PATH
  $currentPath = [Environment]::GetEnvironmentVariable($VariableName, $ScopeName)

  # Create a temporary file with the current PATH (each directory on a separate line for better editing)
  $tempFile = [System.IO.Path]::GetTempFileName()
  $currentPath -split ";" | Where-Object { $_ } | ForEach-Object { $_ } | Out-File -FilePath $tempFile -Encoding utf8

  # Open Vim to edit the PATH
  Start-Process -FilePath $EditorName -ArgumentList $tempFile -Wait -NoNewWindow

  # Read the edited content
  $newPathItems = Get-Content -Path $tempFile | Where-Object { $_ -ne "" }

  # Join the items with semicolons
  $newPath = $newPathItems -join ";"

  # Set the environment variable
  [Environment]::SetEnvironmentVariable($VariableName, $newPath, $ScopeName)

  # Clean up
  Remove-Item -Path $tempFile -Force

  Write-Host "PATH has been updated." -ForegroundColor Green
  Write-Host "Please restart your shell or run 'refreshenv'."
}
function Edit-PathForUser {
  Edit-Env -ScopeName "User" -VariableName "Path" -EditorName "vim"
}
function Edit-PathForMachine {
  Edit-Env -ScopeName "Machine" -VariableName "Path" -EditorName "vim"
}

[Environment]::SetEnvironmentVariable(
    "YAZI_FILE_ONE",
    (Join-Path $env:ProgramFiles "\Git\usr\bin\file.exe"),
    "User"
)

# Enable debug output
$DebugPreference = 'Continue'

# Initialize only essential environment variables
Reload-EnvironmentVariables

# runex abbreviation engine
if (Test-CommandExist('runex')) {
  (& runex export pwsh) | Out-String | Invoke-Expression
}

# Clear command existence cache after initial load and alias setup
$script:commandExistCache.Clear()

# Final PATH deduplication (case-insensitive, trailing-backslash normalized).
# Late-stage additions (go, mise, runex) may reintroduce duplicates; clean them up here.
$__seenPath = [System.Collections.Generic.HashSet[string]]::new(
  [System.StringComparer]::OrdinalIgnoreCase)
$env:Path = (($env:Path -split ';' | Where-Object { $_ -and $__seenPath.Add($_.TrimEnd('\')) }) -join ';')
Remove-Variable __seenPath -ErrorAction SilentlyContinue

$profileLoadDuration = (Get-Date) - $profileLoadStart
Write-Debug ("Profile loaded in {0:N0} ms" -f $profileLoadDuration.TotalMilliseconds)
