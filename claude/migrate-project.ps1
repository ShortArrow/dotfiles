<#
.SYNOPSIS
Move a project's directory while preserving `claude --resume` history (Windows counterpart of migrate-project.sh).

.DESCRIPTION
Claude Code stores per-project session logs under
  %USERPROFILE%\.claude\projects\<path-with-':'-and-'\'-as-'-'>\
and each session .jsonl records the JSON-escaped absolute cwd as "cwd":"<path>".
Moving a project to a new path orphans that history unless BOTH the directory
name and the in-file cwd are rewritten. This script rewrites both.

Dry-run by default; pass -Apply to make changes. The project directory is
backed up before any write.

Run this only while no Claude Code session for the old path is active —
a live session keeps appending to the old .jsonl and would split the history.

Verified against the on-disk layout of Claude Code 2.x (SupportedMajor guard).

.EXAMPLE
pwsh migrate-project.ps1 V:\ V:\marubot          # dry-run
pwsh migrate-project.ps1 -Apply V:\ V:\marubot   # apply
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$OldPath,
    [Parameter(Mandatory)][string]$NewPath,
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SupportedMajor = 2

function Assert-ClaudeSessionFormatVersion {
    $claude = Get-Command claude -ErrorAction SilentlyContinue
    if (-not $claude) { throw "ABORT: 'claude' not found on PATH - cannot verify the session format version." }
    $ver = (& $claude.Source --version 2>$null | Select-String -Pattern '\d+\.\d+\.\d+').Matches.Value | Select-Object -First 1
    if (-not $ver) { throw "ABORT: could not read a version from 'claude --version' - refusing to touch session files." }
    $major = [int]($ver.Split('.')[0])
    if ($major -ne $SupportedMajor) {
        throw "ABORT: claude major version is $major (v$ver) but this script was verified for $SupportedMajor. Re-verify the layout and bump `$SupportedMajor."
    }
}

function ConvertTo-ProjectDirName([string]$Path) {
    # Claude Code sanitizes every non-alphanumeric character, not only ':'
    # and '\': '_' and '.' also become '-' (V:\nasm_self_destruction ->
    # V--nasm-self-destruction, S3.kPGy -> S3-kPGy). Case is preserved.
    return $Path -replace '[^A-Za-z0-9]', '-'
}

function ConvertTo-JsonCwdLiteral([string]$Path) {
    return '"cwd":"' + $Path.Replace('\', '\\') + '"'
}

if (-not [System.IO.Path]::IsPathRooted($OldPath) -or -not [System.IO.Path]::IsPathRooted($NewPath)) {
    throw 'ABORT: both paths must be absolute.'
}

$projects = Join-Path $env:USERPROFILE '.claude\projects'
$oldDir = Join-Path $projects (ConvertTo-ProjectDirName $OldPath)
$newDir = Join-Path $projects (ConvertTo-ProjectDirName $NewPath)
$oldCwd = ConvertTo-JsonCwdLiteral $OldPath
$newCwd = ConvertTo-JsonCwdLiteral $NewPath

Assert-ClaudeSessionFormatVersion

if (-not (Test-Path $oldDir)) {
    Write-Output "No session history for $OldPath (looked for $oldDir) - nothing to migrate."
    exit 0
}
if (Test-Path $newDir) { throw "ABORT: destination project dir already exists: $newDir" }

$hitFiles = @(Get-ChildItem $oldDir -Recurse -File -Filter *.jsonl |
    Where-Object { Select-String -Path $_.FullName -Pattern ([regex]::Escape($oldCwd)) -Quiet })

Write-Output 'Project session migration'
Write-Output "  from : $OldPath"
Write-Output "  to   : $NewPath"
Write-Output "  dir  : $oldDir"
Write-Output "       -> $newDir"
Write-Output "  jsonl files containing old cwd: $($hitFiles.Count)"

if (-not $Apply) {
    Write-Output ''
    Write-Output 'DRY-RUN. Re-run with -Apply to perform the migration.'
    exit 0
}

$backup = Join-Path $projects (".backup-" + (ConvertTo-ProjectDirName $OldPath))
Write-Output "Backing up -> $backup"
if (Test-Path $backup) { Remove-Item $backup -Recurse -Force }
Copy-Item $oldDir $backup -Recurse

foreach ($f in $hitFiles) {
    [System.IO.File]::WriteAllText($f.FullName, [System.IO.File]::ReadAllText($f.FullName).Replace($oldCwd, $newCwd))
}
Move-Item $oldDir $newDir

$remaining = @(Get-ChildItem $newDir -Recurse -File -Filter *.jsonl |
    Where-Object { Select-String -Path $_.FullName -Pattern ([regex]::Escape($oldCwd)) -Quiet })
if ($remaining.Count -ne 0) {
    Write-Warning "$($remaining.Count) file(s) still reference the old cwd. Backup kept at $backup."
    exit 5
}

Write-Output "Done. Migrated $($hitFiles.Count) file(s). Backup kept at $backup (remove once verified)."
