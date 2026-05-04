#!pwsh
. "$PSScriptRoot/../../lib/_lib.ps1"

# Auto-discover skill directories (anything that contains a SKILL.md)
# and symlink them under ~/.claude/skills/.

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$targetDirectory = Join-Path $env:USERPROFILE '.claude/skills'

if (-not (Test-Path -LiteralPath $targetDirectory)) {
  New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
  Write-DotfileOk "created $targetDirectory"
}

$skillDirs = Get-ChildItem -LiteralPath $scriptDirectory -Directory |
  Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') }

if (-not $skillDirs -or $skillDirs.Count -eq 0) {
  Write-DotfileWarn "no skills (directories with SKILL.md) found in $scriptDirectory"
  exit 0
}

foreach ($skill in $skillDirs) {
  $linkPath = Join-Path $targetDirectory $skill.Name
  New-DotfileSymlink -Source $skill.FullName -Destination $linkPath | Out-Null
}

Write-DotfileInfo "skills installed: $($skillDirs.Count)"
