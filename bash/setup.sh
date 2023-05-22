#!/bin/bash

# make symbolic link
rm -rf "$HOME/.bash_myplug"

# caution! Don't needs slash at last of directory name.
REPO="$HOME/Documents/GitHub/dotfiles/bash/src"
PLUG="$HOME/.bash_myplug"
ln -s "$REPO" "$PLUG"

# check link
file "$PLUG" # check link

# display guides after run this script
BACKQUOTE="\`"
echo "###########################################"
echo "Write this at the end of ${BACKQUOTE}~/.bashrc${BACKQUOTE}"
echo "${BACKQUOTE}source ~/.bash_myplug/bash_myplug.sh${BACKQUOTE}"
echo "###########################################"
