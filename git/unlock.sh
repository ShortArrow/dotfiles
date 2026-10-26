#!/usr/bin/env bash
# git unlock: have gpg-agent cache the passphrase of this repository's
# signing key, so the signed commits that follow do not stop at pinentry.
#
# The key is the repository's user.signingkey and the program gpg.program, so
# neither has to be typed, and Git Bash's own gpg on PATH is not the one used.
#
# When signing fails, say whether kana lock is on: it turns the passphrase
# typed into pinentry into half-width kana, and gpg's own message does not
# say so. pwsh is started only on that failure path.
set -u

if ! key=$(git config user.signingkey); then
  printf '%s\n' "unlock: no user.signingkey for this repository" >&2
  exit 1
fi
gpg=$(git config gpg.program || printf gpg)

if printf unlock | "$gpg" --local-user "$key" --clearsign >/dev/null; then
  exit 0
fi

printf '%s\n' "unlock: gpg could not sign with $key" >&2
case ${OSTYPE:-} in
  msys* | cygwin*)
    kana=$(pwsh -NoProfile -NonInteractive -Command \
      'if ((Get-Command Get-KanaLock -ErrorAction Ignore) -and (Get-KanaLock)) { "on" }' 2>/dev/null)
    if [ "$kana" = on ]; then
      printf '%s\n' "unlock: kana lock is on, so the passphrase reached pinentry as half-width kana." >&2
      printf '%s\n' "        Run Disable-KanaLock and try again." >&2
    fi
    ;;
esac
exit 1
