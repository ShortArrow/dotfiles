#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"

# Mirrors [tools.git.post_apply] in dotfm.toml.
# Idempotent: git config --global is set every run; same value -> no-op effectively.

Write-DotfileInfo 'git: applying global config'
$pairs = @(
  @{ key = 'init.defaultBranch';      value = 'main' }
  @{ key = 'core.pager';              value = 'delta' }
  @{ key = 'interactive.diffFilter';  value = 'delta --color-only' }
  @{ key = 'delta.navigate';          value = 'true' }
  @{ key = 'merge.conflictStyle';     value = 'zdiff3' }
)

foreach ($p in $pairs) {
  & git config --global $p.key $p.value
  Write-DotfileOk "$($p.key) = $($p.value)"
}

# Global, so the guard covers every repository on the machine rather than the
# one it happens to be installed in. This replaces .git/hooks; the hooks call
# a repository's own version at the end, so nothing is lost by it.
# Forward slashes: git reads the value as a path and does not unescape it.
$hooksDir = (Resolve-Path "$PSScriptRoot/hooks").Path -replace '\\', '/'
& git config --global core.hooksPath $hooksDir
Write-DotfileOk "core.hooksPath = $hooksDir"

# Key wiring lives in signing.ps1, owned by [tools.git-signing]: a machine
# without the Bitwarden vault still wants everything above.
