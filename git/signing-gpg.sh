#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/_lib.sh
source "$script_dir/../lib/_lib.sh"

# Owned by [tools.git-signing-gpg] in dotfm.toml, apart from [tools.git]:
# key wiring and general git config change for different reasons.
# gpg.format is set explicitly so a machine that once signed over SSH comes
# back to OpenPGP. gpg comes from PATH; no gpg.program needed here.
# No global user.signingkey: the identity is declared per repository, and an
# undeclared repository refuses to commit instead of signing wrongly.
# Idempotent: git config --global is set every run.

dotfile_info 'git: signing via GPG (OpenPGP)'

git config --global commit.gpgsign true    ; dotfile_ok 'commit.gpgsign = true'
git config --global merge.gpgsign  true    ; dotfile_ok 'merge.gpgsign = true'
git config --global tag.gpgSign    true    ; dotfile_ok 'tag.gpgSign = true'
git config --global gpg.format     openpgp ; dotfile_ok 'gpg.format = openpgp'
