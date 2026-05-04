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
