#!pwsh

# Target is "~/.config/starship.toml"

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Set the target directory
$targetDirectory = "$env:USERPROFILE/.config/"

$list = @("starship.toml")
foreach ($item in $list) {
  Remove-Item "$targetDirectory/$item" -Force
  New-Item `
    -Type SymbolicLink `
    -Path "$targetDirectory" `
    -Name $item `
    -Value "$scriptDirectory/$item"
}
