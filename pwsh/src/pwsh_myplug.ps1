function Test-CommandExist
{
  param (
    [string]$targetCommand
  )
  if (Get-Command $targetCommand -ea SilentlyContinue)
  {
    return $true
  } else
  {
    return $false
  }
}

$needInstallList = @()

function Show-NeedInstall
{
  # print list of need install
  Write-Host "Need install: $script:needInstallList"
}

function Add-NeedInstall
{
  param (
    [string]$targetCommand
  )
  $script:needInstallList += $targetCommand
}

# Reload Env
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

## Reload this profile
function Read-Profile()
{
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

# criteria of when leave history, contains word "SKIPHISTORY", or only one charactor of alphabet, or finish terminal command.

Set-PSReadlineOption -AddToHistoryHandler {
  param ($command)
  switch -regex ($command)
  {
    "SKIPHISTORY"
    {return $false
    }
    "^[a-z]$"
    {return $false
    }
    "exit"
    {return $false
    }
  }
  return $true
}

# Word delimiters on cursor navigation by ctrl + arrows
Set-PSReadLineOption -WordDelimiters ";:,.[]{}()/\|^&*-=+'`" !?@#$%&_<>「」（）『』『』［］、，。：；／"

# prompt setting
# choco install starship
Invoke-Expression (&starship init powershell)

# Reload PROFILE
Set-PSReadLineKeyHandler -Key "alt+r" -BriefDescription "reloadPROFILE" -LongDescription "reloadPROFILE" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('<#SKIPHISTORY#> . $PROFILE')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# gsudo
# choco install gsudo
Import-Module 'C:\tools\gsudo\Current\gsudoModule.psd1'

# go path
if (Test-CommandExist('go'))
{
  $env:Path = "$env:Path;$env:USERPROFILE\go\bin;"
}

# git-graph
# cargo install git-graph
if (Test-CommandExist('git-graph'))
{
  New-Alias -Name gg -Value git-graph -Force
} else
{
  New-Alias -Name gg -Value Show-NeedInstall -Force
  Add-NeedInstall 'pnpm'
}

# pnpm
# volta install pnpm
if (Test-CommandExist('pnpm'))
{
  $env:Path = "$env:Path$(pnpm bin);"
} else
{
  New-Alias -Name pnpm -Value Show-NeedInstall -Force
  Add-NeedInstall 'pnpm'
}

# lazygit
# choco install lazygit
if (Test-CommandExist('lazygit'))
{
  New-Alias -Name lg -Value lazygit -Force
} else
{
  New-Alias -Name lg -Value Show-NeedInstall -Force
  Add-NeedInstall 'lazygit'
}

# lazydocker
if (Test-CommandExist('lazydocker'))
{
  New-Alias -Name lzd -Value lazydocker -Force
} else
{
  New-Alias -Name lzd -Value Show-NeedInstall -Force
  Add-NeedInstall 'lzd'
}

## lunarvim
$lunarvimPath = "$env:USERPROFILE\.local\bin\lvim.ps1"
if(Test-Path($lunarvimPath))
{
  New-Alias -Name lvim -Value $lunarvimPath -Force
} else
{
  New-Alias -Name lvim -Value Show-NeedInstall -Force
  Add-NeedInstall 'lunarvim'
}

## lsd
function Get-FilteredChildItem
{
  Get-ChildItem -Force | Where-Object { -not $_.Name.StartsWith(".") }
}
function Get-AllChildItem
{
  Get-ChildItem -Force 
}
function llong
{
  lsd -l extension
}
function lldot
{
  lsd -la extension
}
if(Test-CommandExist('lsd'))
{
  New-Alias -Name 'll' -Value llong -Force
  New-Alias -Name 'll.' -Value lldot -Force
} else
{
  New-Alias -Name 'll' -Value Get-FilteredChildItem -Force
  New-Alias -Name 'll.' -Value Get-AllChildItem -Force
}

if(Test-CommandExist('zoxide'))
{
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
} else
{
  New-Alias -Name z -Value Show-NeedInstall -Force
  Add-NeedInstall 'zoxide'
}

## password generator
function New-Password($length = 32)
{
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
  $password = for ($i = 0; $i -lt $length; $i++)
  {
    $position = $random.Next(0, $hashString.Length)
    $hashString[$position]
  }
  -join $password
}

## escape sequence color checker
function Test-TrueColor
{
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
function Start-Reboot()
{
  Restart-Computer -Force
}
New-Alias -Name reboot -Value Start-Reboot -Force

## poweroff
function Start-Poweroff()
{
  Stop-Computer -Force
}
New-Alias -Name poweroff -Value Start-Poweroff -Force

## CFA (Controlled Folder Access)
function GetCfaEvent()
{
  Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational"
    | Where-Object {$_.Id -eq "1123" }
    | fzf --reverse
}
New-Alias -Name cfa -Value GetCfaEvent -Force

function LoginGhcrIo()
{
  gh auth refresh --scopes read:packages
  $username = Read-Host "Enter your username"
  gh auth token | docker login ghcr.io --username $username --password-stdin
}

# chrome dev
$chromeDevPath = "C:\Program Files\Google\Chrome Dev\Application\chrome.exe"
if(Test-Path $chromeDevPath)
{
  New-Alias -Force -Name chromedev -Value $chromeDevPath
} else {
  New-Alias -Force -Name chromedev -Value "Write-Host 'Please install Chrome Dev.'"
}
# glazewm dev
$glazewmPath= "$env:USERPROFILE/Documents/GitHub/glazewm/target/release/glazewm.exe"
function GetGlazewmWindows(){
  $(glazewmdev query windows | ConvertFrom-Json ).data.windows
    | %{$index=0}{
      [PSCustomObject]@{
        Index = $index
        Title = $_.title
        ProcessName = $_.processname
        ClassName = $_.classname
      };$index++;}
    | ft -AutoSize
}
if(Test-Path $glazewmPath)
{
  New-Alias -Force -Name glazewmdev -Value $glazewmPath
  New-Alias -Force -Name Get-GlazewmWindows -Value GetGlazewmWindows
} else {
  New-Alias -Force -Name glazewmdev -Value "Write-Host 'Please build glazewm Dev.'"
}

# default Apps
function SetDefaultApp()
{
  # https://learn.microsoft.com/en-us/windows/uwp/launch-resume/launch-settings-app
  Start-Process ms-settings:defaultapps
}
New-Alias -Name Set-DefaultApp -Value SetDefaultApp -Force

#For PowerShell v3
Function gig {
  param(
    [Parameter(Mandatory=$true)]
    [string[]]$list
  )
  $params = ($list | ForEach-Object { [uri]::EscapeDataString($_) }) -join ","
  Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$params" | select -ExpandProperty content | Out-File -FilePath $(Join-Path -path $pwd -ChildPath ".gitignore") -Encoding ascii
}

# Thorium
$thoriumPath = "$env:LOCALAPPDATA/Thorium/Application/thorium.exe"
if(Test-Path $thoriumPath)
{
  New-Alias -Force -Name thorium -Value $thoriumPath
} else {
  New-Alias -Force -Name thorium -Value "Write-Host 'Please install Thorium.'"
}

# Tshark

$tsharkPath = "C:\Program Files\Wireshark\tshark.exe"
if(Test-Path $tsharkPath)
{
  New-Alias -Force -Name tshark -Value $tsharkPath
} else {
  New-Alias -Force -Name tshark -Value "Write-Host 'Please install Wireshark.'"
}

