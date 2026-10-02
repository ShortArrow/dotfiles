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
# Gpg4win 4 installs 32-bit under Program Files (x86), Gpg4win 5 64-bit under
# Program Files. Git Bash's own gpg on PATH reads ~/.gnupg, not this keyring.
$gpg = @(
  'C:/Program Files/GnuPG/bin/gpg.exe'
  'C:/Program Files (x86)/GnuPG/bin/gpg.exe'
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $gpg) {
  Write-DotfileWarn 'gpg.exe not found; install Gpg4win (winget GnuPG.Gpg4win)'
  return
}
$signing = @(
  @{ key = 'commit.gpgsign'; value = 'true' }
  @{ key = 'merge.gpgsign';  value = 'true' }
  @{ key = 'tag.gpgSign';    value = 'true' }
  @{ key = 'gpg.format';     value = 'openpgp' }
  @{ key = 'gpg.program';    value = $gpg }
)
foreach ($p in $signing) {
  & git config --global $p.key $p.value
  Write-DotfileOk "$($p.key) = $($p.value)"
}
