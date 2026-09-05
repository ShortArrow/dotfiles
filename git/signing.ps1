#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"

# Owned by [tools.git-signing] in dotfm.toml, apart from [tools.git]: key
# wiring and general git config change for different reasons, and a machine
# without the Bitwarden vault still wants the general half.
# Idempotent: git config --global is set every run; same value -> no-op.

# Signing is Windows-only: the keys sit in the Bitwarden vault and reach git
# through the agent pipe \\.\pipe\openssh-ssh-agent, which only Windows
# OpenSSH's ssh-keygen can reach — Git for Windows' MSYS build looks for
# SSH_AUTH_SOCK and fails with "Couldn't get agent socket". WSL keeps its own
# git config untouched.
# gpg.program stays: gpg still decrypts and verifies pre-2026 GPG signatures.
# No global user.signingkey, deliberately — the identity is chosen per
# repository, exactly like user.email is here. A repository that has not
# declared one refuses to commit, which is the point: signing with the wrong
# identity should be impossible, not merely unlikely.
Write-DotfileInfo 'git: signing via the Bitwarden SSH agent (Windows-only)'
# Each of the three has its own switch and none implies the others, so a tag or
# a merge commit goes out unsigned while every ordinary commit is signed. That
# gap is invisible in `git log`: `git tag -v` on an unsigned tag prints the
# tagger and stops, which reads like success.
$signing = @(
  @{ key = 'commit.gpgsign';  value = 'true' }
  @{ key = 'merge.gpgsign';   value = 'true' }
  @{ key = 'tag.gpgSign';     value = 'true' }
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
