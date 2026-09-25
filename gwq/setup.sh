#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/_lib.sh
source "$script_dir/../lib/_lib.sh"

# Owned by [tools.gwq] in dotfm.toml: the Linux/macOS side of setup.ps1.
# The base directory is <ghq root>/worktrees, derived at apply time because
# the root differs per machine and gwq's config expands only `~`.
# Idempotent: the same value is written every run.

if ! command -v gwq >/dev/null 2>&1; then
  dotfile_warn 'gwq is not on PATH; it is installed through mise (mise/src/config.toml)'
  exit 0
fi
ghq_root="$(git config --global --get ghq.root || true)"
if [ -z "$ghq_root" ]; then
  dotfile_warn 'ghq.root is not set; leaving gwq at its default (~/worktrees). Apply the ghq tool first.'
  exit 0
fi
basedir="${ghq_root%/}/worktrees"
dotfile_info "gwq: worktree.basedir $basedir"
gwq config set worktree.basedir "$basedir" >/dev/null
dotfile_ok "worktree.basedir = $(gwq config get worktree.basedir)"
