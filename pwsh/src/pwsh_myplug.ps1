# Profile load time measurement
$profileLoadStart = Get-Date

# Initialize command check cache and need install list
$script:commandExistCache = @{}
$script:needInstallList = @()

# Helper functions
function Test-CommandExist([string]$cmd) {
  $script:commandExistCache[$cmd] = $script:commandExistCache[$cmd] ?? (Get-Command $cmd -ea SilentlyContinue).Count -gt 0
  return $script:commandExistCache[$cmd]
}

function Set-CommandAlias([string]$name, [string]$command, [string]$fallback = "") {
  if (Test-CommandExist($command)) {
    New-Alias -Name $name -Value $command -Force
  }
  else {
    New-Alias -Name $name -Value { Write-Host "Please install $command" } -Force
    $script:needInstallList += $command
  }
}

# Environment variable management
function Reload-EnvironmentVariables {
  $reloadStart = [DateTime]::Now

  function Get-EnvVar([string]$name, [string]$scope) {
    [System.Environment]::GetEnvironmentVariable($name, $scope)
  }

  $envVars = @{
    Path   = @{
      Current = $env:Path
      New     = "$(Get-EnvVar 'Path' 'Machine');$(Get-EnvVar 'Path' 'User')"
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
    Write-Host "Environment variables updated and broadcasted." -ForegroundColor Cyan
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

Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
Set-PSReadlineOption -HistoryNoDuplicates
Set-PSReadlineOption -BellStyle None
Set-PSReadlineOption -EditMode "Vi"
Set-PSReadLineKeyHandler -Chord "Ctrl+n" -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord "Ctrl+p" -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord "Ctrl+delete" -Function BackwardKillWord

# criteria of when leave history, contains word "SKIPHISTORY", or only one charactor of alphabet, or finish terminal command.

Set-PSReadlineOption -AddToHistoryHandler {
  param ($command)
  switch -regex ($command) {
    "SKIPHISTORY|^[a-z]$|exit" { return $false }
    default { return $true }
  }
}

# Word delimiters on cursor navigation by ctrl + arrows
Set-PSReadLineOption -WordDelimiters ";:,.[]{}()/\|^&*-=+'`" !?@#$%&_<>「」（）『』『』［］、，。：；／"

# prompt setting
# choco install starship
# Initialize starship - needed for prompt functionality
if (Test-CommandExist('starship')) {
  Invoke-Expression (&starship init powershell)
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
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
$env:FZF_DEFAULT_OPTS = '--bind ctrl-u:unix-line-discard'

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

# go path
if (Test-CommandExist('go')) {
  $env:Path = "$env:Path;$env:USERPROFILE\go\bin;"
}

# Set up common command aliases
$commonAliases = @{
  'gg'  = 'git-graph'
  'lg'  = 'lazygit'
  'lzd' = 'lazydocker'
}

foreach ($alias in $commonAliases.GetEnumerator()) {
  Set-CommandAlias $alias.Key $alias.Value
}

# pnpm setup
if (Test-CommandExist('pnpm')) {
  $env:Path = "$env:Path$(pnpm bin);"
}

# lunarvim setup
$lunarvimPath = "$env:USERPROFILE\.local\bin\lvim.ps1"
Set-CommandAlias 'lvim' $lunarvimPath -fallback 'lunarvim'

# lsd setup
function Get-FilteredChildItem {
  & Get-ChildItem -Force @args | Where-Object { -not $_.Name.StartsWith(".") }
}
function Get-AllChildItem { 
  & Get-ChildItem -Force @args
}
function llong {
  & lsd -l @args 
}
function lldot {
  & lsd -la @args 
}
function ldot {
  & lsd -a @args 
}
if (Test-CommandExist('lsd')) {
  New-Alias -Name 'ls' -Value lsd -Force
  New-Alias -Name 'l.' -Value ldot -Force
  New-Alias -Name 'll' -Value llong -Force
  New-Alias -Name 'll.' -Value lldot -Force
}
else {
  New-Alias -Name 'll' -Value Get-FilteredChildItem -Force
  New-Alias -Name 'll.' -Value Get-AllChildItem -Force
}

if (Test-CommandExist('zoxide')) {
  # Lazy load zoxide
  $env:ZOXIDE_INITIALIZED = $false
  function Initialize-Zoxide {
    if (-not $env:ZOXIDE_INITIALIZED) {
      Invoke-Expression (& { (zoxide init powershell | Out-String) })
      $env:ZOXIDE_INITIALIZED = $true
    }
  }
  # Initialize on first use
  $ExecutionContext.SessionState.InvokeCommand.PreCommandLookupAction = {
    param($commandName)
    if ($commandName -eq 'z' -and -not $env:ZOXIDE_INITIALIZED) {
      Initialize-Zoxide
    }
  }
}
else {
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
  Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$params" | select -ExpandProperty content | Out-File -FilePath $(Join-Path -path $pwd -ChildPath ".gitignore") -Encoding ascii
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

# Enable debug output
$DebugPreference = 'Continue'

# Initialize only essential environment variables
Reload-EnvironmentVariables

# Clear command existence cache after initial load
$script:commandExistCache.Clear()