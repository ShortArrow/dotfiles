#!pwsh

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

$targetDirectory = "$env:APPDATA"

$item = "lazygit"

if (Test-Path "$targetDirectory/$item") {
    Remove-Item "$targetDirectory/$item" -Force
}

New-Item `
  -Type SymbolicLink `
  -Path "$targetDirectory" `
  -Name "$item" `
  -Value (Resolve-Path "$scriptDirectory")

