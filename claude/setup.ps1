#!pwsh

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Set the target directory
$targetDirectory = "$env:USERPROFILE\.claude"

# Link targets
$linkNames = @(
  "notify.ps1",
  "CLAUDE.md",
  "statusline.sh"
)

# --- Functions ---

function New-Symlink
{
  param (
    [string]$TargetDirectory,
    [string]$LinkName,
    [string]$ScriptDirectory
  )
  $linkPath = Join-Path $TargetDirectory $LinkName
  if (Test-Path $linkPath)
  {
    Remove-Item $linkPath -Force
  }
  New-Item -Type SymbolicLink -Path $TargetDirectory -Name $LinkName -Value "$ScriptDirectory\$LinkName"
  Write-Host "✓ Created symlink: $linkPath -> $ScriptDirectory\$LinkName" -ForegroundColor Green
}

function Test-EnvFile
{
  param (
    [string]$TargetDirectory,
    [string]$ScriptDirectory
  )
  $envPath = "$TargetDirectory\.env"
  if (-not (Test-Path $envPath))
  {
    Write-Host ""
    Write-Host "⚠ .env file not found at $envPath" -ForegroundColor Yellow
    Write-Host "  Copy the sample and edit it:" -ForegroundColor Yellow
    Write-Host "    cp $ScriptDirectory\env.sample $envPath" -ForegroundColor Cyan
    Write-Host "  Then set your TEAMS_WEBHOOK_URL" -ForegroundColor Yellow
  }
}

# --- Main ---

# Make directory if it does not exist
if (-not (Test-Path -Path $targetDirectory))
{
  New-Item -ItemType Directory -Path $targetDirectory
}

foreach ($linkName in $linkNames)
{
  New-Symlink -TargetDirectory $targetDirectory -LinkName $linkName -ScriptDirectory $scriptDirectory
}

Test-EnvFile -TargetDirectory $targetDirectory -ScriptDirectory $scriptDirectory
