#!pwsh
<#
.SYNOPSIS
Point gwq's worktree base directory at <ghq root>\worktrees.

.DESCRIPTION
Owned by [tools.gwq] in dotfm.toml. gwq's default puts worktrees under the
home directory, which on this machine is the slow side; the ghq root is the
fast one. The base directory is derived from `ghq root` rather than tracked,
because the root differs per machine (V:\ here, ~/ghq elsewhere) and gwq's
own config expands only `~`. A worktree under the ghq root shows up in
`ghq list` as worktrees/<host>/<owner>/<repo>/<branch>, which the only
consumer here, a cd picker, treats as one more place to jump to.
Idempotent: the same value is written every run.
#>
. "$PSScriptRoot/../lib/_lib.ps1"

if (-not (Get-Command gwq -ErrorAction SilentlyContinue)) {
  Write-DotfileWarn 'gwq is not on PATH; it is installed through mise (mise/src/config.toml)'
  return
}
$ghqRoot = (& git config --global --get ghq.root)
if (-not $ghqRoot) {
  Write-DotfileWarn 'ghq.root is not set; leaving gwq at its default (~/worktrees). Apply the ghq tool first.'
  return
}
$basedir = (Join-Path $ghqRoot 'worktrees') -replace '\\', '/'
Write-DotfileInfo "gwq: worktree.basedir $basedir"
& gwq config set worktree.basedir $basedir | Out-Null
Write-DotfileOk "worktree.basedir = $(& gwq config get worktree.basedir)"
