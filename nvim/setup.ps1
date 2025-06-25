#! pwsh
 
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$targetDirectory = "$env:LOCALAPPDATA"

$item = "nvim"

Remove-Item "$targetDirectory/$item" -Force
New-Item `
  -Type SymbolicLink `
  -Path "$targetDirectory" `
  -Name "$item" `
  -Value "$scriptDirectory"

Get-ChildItem -Path $env:LOCALAPPDATA -Force -ErrorAction 'silentlycontinue' |

Where-Object { $_.Attributes -match "ReparsePoint" -and $_.Name -match "$item"}


