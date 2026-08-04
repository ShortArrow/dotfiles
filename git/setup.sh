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

# Global, so the guard covers every repository on the machine rather than the
# one it happens to be installed in. This replaces .git/hooks; the hooks call
# a repository's own version at the end, so nothing is lost by it.
hooks_dir="$(cd -P "$script_dir/hooks" && pwd)"
chmod +x "$hooks_dir/commit-msg" "$hooks_dir/pre-push"
git config --global core.hooksPath "$hooks_dir"           ; dotfile_ok "core.hooksPath = $hooks_dir"
