# This script creates symbolic links for zebar configuration files.
# It dynamically finds the location of the dotfiles repository.

$list = @("config.yaml", "script.js", "start.bat", "start.sh")

# The directory where zebar expects its config files
$zebarConfigDir = "$env:USERPROFILE/.glzr/zebar"

# Ensure the target directory exists
if (-not (Test-Path -Path $zebarConfigDir)) {
  Write-Host "Creating directory: $zebarConfigDir"
  New-Item -ItemType Directory -Path $zebarConfigDir -Force
}

foreach ($item in $list) {
  # Path for the symbolic link
  $linkPath = Join-Path -Path $zebarConfigDir -ChildPath $item
  
  # Path to the actual file in this repository
  # $PSScriptRoot is the directory where this script is located
  $targetPath = Join-Path -Path $PSScriptRoot -ChildPath $item

  # Remove existing link/file to avoid errors
  if (Test-Path -Path $linkPath -PathType Leaf) {
    Remove-Item $linkPath -Force
  }
  
  # Create the new symbolic link
  try {
    New-Item -ItemType SymbolicLink -Path $linkPath -Value $targetPath -ErrorAction Stop
    Write-Host "Successfully linked $item"
  }
  catch {
    Write-Error "Failed to link $item. Please make sure you are running this script with administrator privileges."
    # Exit the script if linking fails
    exit 1
  }
}

Write-Host "`nzebar setup complete."