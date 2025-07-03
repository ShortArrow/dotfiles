#!pwsh

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Set the target directory
$targetDirectory = "$env:APPDATA/Code/User"

# Make directory if it does not exist
if (-not (Test-Path -Path $targetDirectory)) {
  New-Item -ItemType Directory -Path $targetDirectory
}

$list = @("keybindings.json", "settings.json")
foreach ($item in $list) {
  Remove-Item "$targetDirectory/$item" -Force
  New-Item `
    -Type SymbolicLink `
    -Path "$targetDirectory" `
    -Name $item `
    -Value "$scriptDirectory/$item"
}

