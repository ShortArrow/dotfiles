#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/_lib.sh
source "$script_dir/../lib/_lib.sh"

# Mirrors [tools.git.post_apply] in dotfm.toml.
# Idempotent: git config --global is set every run.

dotfile_info 'git: applying global config'

git config --global init.defaultBranch     main                      ; dotfile_ok 'init.defaultBranch = main'
git config --global core.pager             delta                     ; dotfile_ok 'core.pager = delta'
git config --global interactive.diffFilter 'delta --color-only'      ; dotfile_ok "interactive.diffFilter = 'delta --color-only'"
git config --global delta.navigate         true                      ; dotfile_ok 'delta.navigate = true'
git config --global merge.conflictStyle    zdiff3                    ; dotfile_ok 'merge.conflictStyle = zdiff3'
