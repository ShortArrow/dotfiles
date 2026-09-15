#!pwsh
<#
.SYNOPSIS
Point ghq at the repository root and make sure the root exists.

.DESCRIPTION
Owned by [tools.ghq] in dotfm.toml, so a machine set up through dotfm gets
ghq.root without anyone remembering it. `ghq get` then clones into
<root>\github.com\<owner>\<repo>, the layout every repository on this
machine already follows. Idempotent: the same value is written every run.

.PARAMETER Root
The ghq root. V:\ is the Dev Drive that holds every checkout here.
#>
param([string]$Root = 'V:\')
. "$PSScriptRoot/../lib/_lib.ps1"

Write-DotfileInfo "ghq: root $Root"
if (-not (Test-Path -LiteralPath $Root)) {
  New-Item -ItemType Directory -Force -Path $Root | Out-Null
  Write-DotfileOk "created $Root"
}
& git config --global ghq.root $Root
Write-DotfileOk "ghq.root = $Root"

if (Get-Command ghq -ErrorAction SilentlyContinue) {
  Write-DotfileOk "ghq on PATH: $((Get-Command ghq).Source)"
} else {
  Write-DotfileWarn 'ghq is not on PATH; it is installed through mise (mise/src/config.toml)'
}
