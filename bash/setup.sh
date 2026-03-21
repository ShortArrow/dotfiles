#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)
src_dir="$script_dir/src"

# Ensure ~/.bash_profile sources ~/.bashrc (for login shells like Git Bash)
if ! grep -qF ".bashrc" "$HOME/.bash_profile" 2>/dev/null; then
  echo '[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"' >> "$HOME/.bash_profile"
  echo "Added .bashrc sourcing to ~/.bash_profile"
fi

# Ensure ~/.bashrc sources bash_myplug.sh with the correct path
entry="source \"$src_dir/bash_myplug.sh\""
if grep -qF "bash_myplug.sh" "$HOME/.bashrc" 2>/dev/null; then
  sed -i '\|bash_myplug.sh|d' "$HOME/.bashrc"
  echo "Removed old bash_myplug.sh entry from ~/.bashrc"
fi
echo "$entry" >> "$HOME/.bashrc"
echo "Added to ~/.bashrc:"
echo "  $entry"
