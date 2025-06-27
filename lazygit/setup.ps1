#!pwsh

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

$targetDirectory = "$env:LOCALAPPDATA"

# $env:LOCALAPPDATA\lazygit\config.yml

$item = "lazygit"

if (Test-Path "$targetDirectory/$item") {
    Remove-Item "$targetDirectory/$item" -Force -Recurse
}

New-Item `
  -Type SymbolicLink `
  -Path "$targetDirectory" `
  -Name "$item" `
  -Value (Resolve-Path "$scriptDirectory")

