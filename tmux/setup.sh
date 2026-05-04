#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/_lib.sh
source "$script_dir/../lib/_lib.sh"

# Pinned upstream resource. Update both URL and SHA256 together.
# To refresh the SHA256 manually:
#   curl -fsSL "$THEME_URL" | sha256sum
THEME_URL='https://raw.githubusercontent.com/ShortArrow/iceberg-dark/master/.tmux/iceberg_minimal_with_win_index.tmux.conf'
THEME_SHA256="${TMUX_THEME_SHA256:-}"

mkdir -p "$HOME/.tmux"

theme_path="$HOME/.tmux/iceberg_minimal_with_win_index.tmux.conf"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

dotfile_info "tmux: downloading theme"
curl -fsSL "$THEME_URL" -o "$tmp"

if [[ -n "$THEME_SHA256" ]]; then
  echo "$THEME_SHA256  $tmp" | sha256sum -c -
  dotfile_ok 'tmux: theme sha256 verified'
else
  dotfile_warn 'tmux: TMUX_THEME_SHA256 not set; skipping integrity check'
  dotfile_warn '       set it to a known-good hash to harden this step.'
fi

mv "$tmp" "$theme_path"
trap - EXIT

new_dotfile_symlink "$script_dir/tmux_myplug.sh" "$HOME/.tmux_myplug" >/dev/null

dotfile_info 'tmux: append the following to ~/.tmux.conf if not present:'
dotfile_info '  source ~/.tmux_myplug'
