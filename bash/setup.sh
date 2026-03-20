#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)
src_dir="$script_dir/src"

# Ensure ~/.bash_profile sources ~/.bashrc (for login shells like Git Bash)
if ! grep -qF ".bashrc" "$HOME/.bash_profile" 2>/dev/null; then
  echo '[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"' >> "$HOME/.bash_profile"
  echo "Added .bashrc sourcing to ~/.bash_profile"
fi

# Add source line to ~/.bashrc if not already present
entry="source \"$src_dir/bash_myplug.sh\""
if ! grep -qF "bash_myplug.sh" "$HOME/.bashrc" 2>/dev/null; then
  echo "$entry" >> "$HOME/.bashrc"
  echo "Added to ~/.bashrc:"
  echo "  $entry"
else
  echo "~/.bashrc already contains bash_myplug.sh entry"
fi
