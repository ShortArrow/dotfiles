#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"

# Owned by [tools.git-signing-gpg] in dotfm.toml: the GPG alternative to
# signing.ps1. The two set the same keys — gpg.format above all — so they are
# mutually exclusive by construction: whichever is applied last owns signing
# on this machine. Pick this one where the Bitwarden vault is absent or the
# target requires OpenPGP (pacman repository signing, keyservers).
# Idempotent: git config --global is set every run; same value -> no-op.

# gpg.format is set explicitly because signing.ps1 may have left 'ssh' here.
# No global user.signingkey, for the same reason as the SSH side: the
# identity is declared per repository, and an undeclared repository refuses
# to commit instead of signing with the wrong key.
Write-DotfileInfo 'git: signing via GPG (OpenPGP)'
$signing = @(
  @{ key = 'commit.gpgsign'; value = 'true' }
  @{ key = 'merge.gpgsign';  value = 'true' }
  @{ key = 'tag.gpgSign';    value = 'true' }
  @{ key = 'gpg.format';     value = 'openpgp' }
  @{ key = 'gpg.program';    value = 'C:/Program Files (x86)/GnuPG/bin/gpg.exe' }
)
foreach ($p in $signing) {
  & git config --global $p.key $p.value
  Write-DotfileOk "$($p.key) = $($p.value)"
}
