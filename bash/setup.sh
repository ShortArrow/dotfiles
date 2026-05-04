#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/_lib.sh
source "$script_dir/../lib/_lib.sh"

src_dir="$script_dir/src"

dotfile_info 'bash: ensure ~/.bash_profile sources ~/.bashrc'
append_unique_line "$HOME/.bash_profile" '[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"'

dotfile_info 'bash: ensure ~/.bashrc sources bash_myplug.sh'
entry="source \"$src_dir/bash_myplug.sh\""

# Remove any prior bash_myplug entry pointing at a different path
if [[ -f "$HOME/.bashrc" ]] && grep -qF 'bash_myplug.sh' "$HOME/.bashrc"; then
  if ! grep -qF "$entry" "$HOME/.bashrc"; then
    sed -i.bak.dotfm '\|bash_myplug\.sh|d' "$HOME/.bashrc"
    dotfile_warn "removed stale bash_myplug entry from ~/.bashrc (backup: ~/.bashrc.bak.dotfm)"
  fi
fi

append_unique_line "$HOME/.bashrc" "$entry"
dotfile_ok "$entry"
