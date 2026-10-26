#!/usr/bin/env bash
# git unlock: have gpg-agent cache the passphrase of this repository's
# signing key, so the signed commits that follow do not stop at pinentry.
#
# The key is the repository's user.signingkey and the program gpg.program, so
# neither has to be typed, and Git Bash's own gpg on PATH is not the one used.
#
# A kana lock left on is cleared first, as pre-commit does, since the
# passphrase typed into pinentry would otherwise arrive as half-width kana.
set -u

script_dir=$(cd -P "$(dirname "$0")" && pwd)
# shellcheck source=hooks/kana_lock.sh
. "$script_dir/hooks/kana_lock.sh"

if ! key=$(git config user.signingkey); then
  printf '%s\n' "unlock: no user.signingkey for this repository" >&2
  exit 1
fi
gpg=$(git config gpg.program || printf gpg)

clear_kana_lock unlock
if ! printf unlock | "$gpg" --local-user "$key" --clearsign >/dev/null; then
  printf '%s\n' "unlock: gpg could not sign with $key" >&2
  exit 1
fi
