#!pwsh

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Set the target directory
$targetDirectory = "$env:USERPROFILE\.claude"

# Make directory if it does not exist
if (-not (Test-Path -Path $targetDirectory)) {
    New-Item -ItemType Directory -Path $targetDirectory
}

# Create symbolic link for notify.ps1
$linkName = "notify.ps1"
$linkPath = "$targetDirectory\$linkName"

if (Test-Path $linkPath) {
    Remove-Item $linkPath -Force
}

New-Item `
    -Type SymbolicLink `
    -Path $targetDirectory `
    -Name $linkName `
    -Value "$scriptDirectory\$linkName"

Write-Host "✓ Created symlink: $linkPath -> $scriptDirectory\$linkName" -ForegroundColor Green

# Check if .env exists, if not, prompt user
$envPath = "$targetDirectory\.env"
if (-not (Test-Path $envPath)) {
    Write-Host ""
    Write-Host "⚠ .env file not found at $envPath" -ForegroundColor Yellow
    Write-Host "  Copy the sample and edit it:" -ForegroundColor Yellow
    Write-Host "    cp $scriptDirectory\env.sample $envPath" -ForegroundColor Cyan
    Write-Host "  Then set your TEAMS_WEBHOOK_URL" -ForegroundColor Yellow
}
