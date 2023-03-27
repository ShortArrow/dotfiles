function ExistsCommand
{
  param (
    [string]$targetCommand
  )
  if (Get-Command $targetCommand -ea SilentlyContinue)
  {
    Write-Output 'Success!'
  } else
  {
    Write-Error 'Error!'
  }
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

# git-graph
# cargo install git-graph
New-Alias -Name gg -Value git-graph

# lazygit
# choco install lazygit
New-Alias -Name lg -Value lazygit

## lunarvim
New-Alias -Name lvim -Value "$env:USERPROFILE\.local\bin\lvim.ps1"
