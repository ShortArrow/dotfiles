# make symbolic link
rm -rf ~/.bash_myplug
ln -s $HOME/Documents/GitHub/dotfiles/bash/bash_myplug.sh ~/.bash_myplug # caution! Don't needs slash at last.
file ~/.bash_myplug # check link

# display guides after run this script
BACKQUOTE="\`"
echo "###########################################"
echo "Write this at the end of ${BACKQUOTE}~/.bashrc${BACKQUOTE}"
echo "${BACKQUOTE}source ~/.bash_myplug${BACKQUOTE}"
echo "###########################################"
