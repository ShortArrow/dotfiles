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

# New-Item -Type File -Path $PROFILE -Force

Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
Set-PSReadlineOption -HistoryNoDuplicates
Set-PSReadlineOption -BellStyle None
Set-PSReadlineOption -EditMode "Vi"
Set-PSReadLineKeyHandler -Chord "Ctrl+j" -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord "Ctrl+k" -Function HistorySearchBackward

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
  New-Alias -Name gg -Value git-graph
} else
{
  New-Alias -Name gg -Value Show-NeedInstall
  Add-NeedInstall 'pnpm'
}

# pnpm
# volta install pnpm
if (Test-CommandExist('pnpm'))
{
  $env:Path = "$env:Path$(pnpm bin);"
} else
{
  New-Alias -Name pnpm -Value Show-NeedInstall
  Add-NeedInstall 'pnpm'
}

# lazygit
# choco install lazygit
if (Test-CommandExist('lazygit'))
{
  New-Alias -Name lg -Value lazygit
} else
{
  New-Alias -Name lg -Value Show-NeedInstall
  Add-NeedInstall 'lazygit'
}

# lazydocker
if (Test-CommandExist('lazydocker'))
{
  New-Alias -Name lzd -Value lazydocker
} else
{
  New-Alias -Name lzd -Value Show-NeedInstall
  Add-NeedInstall 'lzd'
}

## lunarvim
$lunarvimPath = "$env:USERPROFILE\.local\bin\lvim.ps1"
if(Test-Path($lunarvimPath))
{
  New-Alias -Name lvim -Value $lunarvimPath
} else
{
  New-Alias -Name lvim -Value Show-NeedInstall
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
  lsd -l --sort extension
}
function lldot
{
  lsd -al --sort extension
}
if(Test-CommandExist('lsd'))
{
  New-Alias -Name 'll' -Value llong
  New-Alias -Name 'll.' -Value lldot
} else
{
  New-Alias -Name 'll' -Value Get-FilteredChildItem
  New-Alias -Name 'll.' -Value Get-AllChildItem
}

if(Test-CommandExist('zoxide'))
{
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
} else
{
  New-Alias -Name z -Value Show-NeedInstall
  Add-NeedInstall 'zoxide'
}

## password generator
function Get-NewPassword($length = 32)
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

## reboot
function Go-Reboot()
{
  Restart-Computer -Force
}
New-Alias -Name reboot -Value Go-Reboot

## poweroff
function Go-Poweroff()
{
  Poweroff-Computer -Force
}
New-Alias -Name poweroff -Value Go-Poweroff
