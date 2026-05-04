#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"

# Generates runex's clink integration into clink's state directory.
# Requires `runex` on PATH; gracefully exits otherwise.

$clinkDir = Join-Path $env:LOCALAPPDATA 'clink'
if (-not (Test-Path -LiteralPath $clinkDir)) {
  New-Item -ItemType Directory -Path $clinkDir -Force | Out-Null
}

$target = Join-Path $clinkDir 'runex.lua'

if (-not (Get-Command runex -ErrorAction SilentlyContinue)) {
  Write-DotfileWarn 'runex not on PATH; skipping clink integration.'
  return
}

runex export clink | Set-Content -LiteralPath $target -Encoding utf8
Write-DotfileOk "wrote $target"
