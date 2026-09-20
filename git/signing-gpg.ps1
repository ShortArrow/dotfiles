#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"

# Owned by [tools.git-signing-gpg] in dotfm.toml, apart from [tools.git]:
# key wiring and general git config change for different reasons.
# Idempotent: git config --global is set every run; same value -> no-op.

# gpg.format is set explicitly so a machine that once signed over SSH comes
# back to OpenPGP. No global user.signingkey: the keyring holds more than
# one identity, so the key is declared per repository, and an undeclared
# repository refuses to commit instead of signing with the wrong one.
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
