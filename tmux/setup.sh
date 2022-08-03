# make directory of tmux configrations
mkdir -p ~/.tmux

# download color theme icebarg theme fork
wget -O $HOME/.tmux/iceberg_minimal_with_win_index.tmux.conf \
https://raw.githubusercontent.com/ShortArrow/iceberg-dark/master/.tmux/iceberg_minimal_with_win_index.tmux.conf

# make symbolic link
rm -rf ~/.tmux_myplug
ln -s $HOME/Documents/GitHub/dotfiles/tmux/tmux_myplug.sh ~/.tmux_myplug # caution! Don't needs slash at last.
file ~/.tmux_myplug # check link

# display guides after run this script
BACKQUOTE="\`"
echo "###########################################"
echo "Write this at the end of ${BACKQUOTE}~/.tmux.conf${BACKQUOTE}"
echo "${BACKQUOTE}source ~/.tmux_myplug${BACKQUOTE}"
echo "###########################################"
