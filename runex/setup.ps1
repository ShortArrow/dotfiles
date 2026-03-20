#!pwsh

# Target is "$APPDATA/runex/config.toml" (Windows) or "~/.config/runex/config.toml" (others)

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Set the target directory
$targetDirectory = "$env:APPDATA/runex"

# Make directory if it does not exist
if (-not (Test-Path -Path $targetDirectory)) {
  New-Item -ItemType Directory -Path $targetDirectory
}

$list = @("config.toml")
foreach ($item in $list) {
  Remove-Item "$targetDirectory/$item" -Force -ErrorAction SilentlyContinue
  New-Item `
    -Type SymbolicLink `
    -Path "$targetDirectory" `
    -Name $item `
    -Value "$scriptDirectory/$item"
}
