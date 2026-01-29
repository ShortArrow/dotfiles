#!pwsh

# Target is "~/.config/mise/config.toml"

# Directory containing this script (absolute path, works from any cwd)
$scriptDirectory = Split-Path -Parent (Convert-Path $MyInvocation.MyCommand.Definition)

# Target directory
$targetDirectory = "$env:USERPROFILE/.config/mise"

# Ensure target directory exists
if (-not (Test-Path -LiteralPath $targetDirectory)) {
  New-Item -ItemType Directory -Path $targetDirectory | Out-Null
}

# Remove existing file/link then create symlink
$targetFile = Join-Path $targetDirectory "config.toml"
if (Test-Path -LiteralPath $targetFile) {
  Remove-Item -LiteralPath $targetFile -Force
}

New-Item `
  -ItemType SymbolicLink `
  -Path $targetDirectory `
  -Name "config.toml" `
  -Value (Join-Path $scriptDirectory "src/config.toml") | Out-Null

Get-ItemProperty $targetFile
