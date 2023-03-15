#!/bin/bash

# make symbolic link
rm -rf ~/.bash_myplug
rm -rf ~/.bash_mycompletion.sh

# caution! Don't needs slash at last of directory name.
REPO="$HOME/Documents/GitHub/dotfiles/bash"
ln -s "$REPO/bash_myplug.sh" ~/.bash_myplug
ln -s "$REPO/bash_mycompletion.sh" ~/.bash_mycompletion.sh

# check link
file ~/.bash_myplug          # check link
file ~/.bash_mycompletion.sh # check link

# display guides after run this script
BACKQUOTE="\`"
echo "###########################################"
echo "Write this at the end of ${BACKQUOTE}~/.bashrc${BACKQUOTE}"
echo "${BACKQUOTE}source ~/.bash_myplug${BACKQUOTE}"
echo "###########################################"
