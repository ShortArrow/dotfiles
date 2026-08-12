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

# Signing is Windows-only, so it lives here and not in [tools.git.post_apply]:
# the keys sit in the Bitwarden vault and reach git through the agent pipe
# \\.\pipe\openssh-ssh-agent, which only Windows OpenSSH's ssh-keygen can
# reach — Git for Windows' MSYS build looks for SSH_AUTH_SOCK and fails with
# "Couldn't get agent socket". WSL keeps its own git config untouched.
# gpg.program stays: gpg still decrypts and verifies pre-2026 GPG signatures.
# No global user.signingkey, deliberately — the identity is chosen per
# repository, exactly like user.email is here. A repository that has not
# declared one refuses to commit, which is the point: signing with the wrong
# identity should be impossible, not merely unlikely.
Write-DotfileInfo 'git: signing via the Bitwarden SSH agent (Windows-only)'
$signing = @(
  @{ key = 'commit.gpgsign';  value = 'true' }
  @{ key = 'gpg.format';      value = 'ssh' }
  @{ key = 'gpg.ssh.program'; value = 'C:/Windows/System32/OpenSSH/ssh-keygen.exe' }
)
foreach ($p in $signing) {
  & git config --global $p.key $p.value
  Write-DotfileOk "$($p.key) = $($p.value)"
}

# The allowed-signers list stays machine-local, outside this public checkout:
# it maps emails to keys, and a work identity mistakenly added to a tracked
# file would be published. Out here the same mistake has no publication path.
# Seeded with the personal identity only when absent; local edits are kept.
$signersFile = "$env:USERPROFILE/.config/git/allowed_signers" -replace '\\', '/'
if (-not (Test-Path -LiteralPath $signersFile)) {
  New-Item -ItemType Directory -Force (Split-Path $signersFile) | Out-Null
  Set-Content -LiteralPath $signersFile -Value 'bamboogeneral@shortarrow.jp namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8SSOadZbDH4NaCqNMmtnCSQtVtJK5KxfQBkADbOPN5 github-private'
}
& git config --global gpg.ssh.allowedSignersFile $signersFile
Write-DotfileOk "gpg.ssh.allowedSignersFile = $signersFile"
