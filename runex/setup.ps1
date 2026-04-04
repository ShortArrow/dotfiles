#!pwsh

# Target is "~/.config/runex/config.toml" on all platforms (XDG_CONFIG_HOME or ~/.config)

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Set the target directory
$xdgConfigHome = $env:XDG_CONFIG_HOME
if (-not $xdgConfigHome) {
  $xdgConfigHome = "$env:USERPROFILE/.config"
}
$targetDirectory = "$xdgConfigHome/runex"

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
