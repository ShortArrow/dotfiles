#!pwsh

# Generate runex's clink integration script into clink's state directory.
# Requires `runex` to be on PATH.

$clinkDir = "$env:LOCALAPPDATA/clink"
if (-not (Test-Path -Path $clinkDir)) {
  New-Item -ItemType Directory -Path $clinkDir | Out-Null
}

$target = "$clinkDir/runex.lua"

if (-not (Get-Command runex -ErrorAction SilentlyContinue)) {
  Write-Warning "runex not found on PATH. Skipping clink integration."
  return
}

runex export clink | Set-Content -Path $target -Encoding utf8
Write-Host "Wrote $target"
