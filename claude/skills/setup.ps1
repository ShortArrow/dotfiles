#!pwsh

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Set the target directory
$targetDirectory = "$env:USERPROFILE\.claude\skills"

# Make directory if it does not exist
if (-not (Test-Path -Path $targetDirectory))
{
  New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
  Write-Host "✓ Created directory: $targetDirectory" -ForegroundColor Green
}

# Get all skill directories (directories containing SKILL.md)
$skillDirs = Get-ChildItem -Path $scriptDirectory -Directory | Where-Object {
  Test-Path (Join-Path $_.FullName "SKILL.md")
}

if ($skillDirs.Count -eq 0)
{
  Write-Host "⚠ No skills found in $scriptDirectory" -ForegroundColor Yellow
  exit 0
}

# Create symbolic links for each skill
foreach ($skill in $skillDirs)
{
  $linkPath = Join-Path $targetDirectory $skill.Name

  if (Test-Path $linkPath)
  {
    Remove-Item $linkPath -Force -Recurse
  }

  New-Item `
    -Type SymbolicLink `
    -Path $targetDirectory `
    -Name $skill.Name `
    -Value $skill.FullName | Out-Null

  Write-Host "✓ Created symlink: $linkPath -> $skill.FullName" -ForegroundColor Green
}

Write-Host ""
Write-Host "Skills installed: $($skillDirs.Count)" -ForegroundColor Cyan
