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

# Fish風のオートサジェスト機能を有効に
Set-PSReadLineOption -PredictionSource History
Set-PSReadlineOption -HistoryNoDuplicates
Set-PSReadlineOption -BellStyle None
Set-PSReadlineOption -EditMode "Vi"
# -PredictionViewStyle パラメーターで表示形式を指定
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
# (optional) Ctrl+f 入力で前方1単語進む : 補完の確定に使う用
Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardWord

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

# gsudo
# choco install gsudo
Import-Module 'C:\tools\gsudo\Current\gsudoModule.psd1'

# lazygit
# choco install lazygit
New-Alias -Name lg -Value lazygit

## lunarvim
New-Alias -Name lvim -Value "$env:USERPROFILE\.local\bin\lvim.ps1"
