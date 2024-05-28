#!/bin/bash

REPO="$HOME/Documents/GitHub/dotfiles/bash/src"
PLUG="$HOME/.bash_myplug"

# cleanup
rm -rf "$HOME/.bash_myplug"

# make symbolic link
ln -s "$REPO" "$PLUG"
# check link
file "$PLUG"

# display guides after run this script
echo "###########################################"
echo "Write this at the end of \`~/.bashrc\`"
echo "\`source ~/.bash_myplug/bash_myplug.sh\`"
echo "###########################################"
