#! pwsh

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

$list = @("keybindings.json", "settings.json")
foreach ($item in $list) {
  Remove-Item "$env:APPDATA/Code - Insiders/User/$item" -Force
  New-Item `
    -Type SymbolicLink `
    -Path "$env:APPDATA/Code - Insiders/User" `
    -Name $item `
    -Value "$scriptDirectory/$item"
}
