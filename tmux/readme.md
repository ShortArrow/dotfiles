# my tmux config 

## Usage

1. Create `.tmux` folder in your home directory: `mkdir ~/.tmux`

2. Make symbolic link.

```bash
rm -rf ~/.tmux_myplug
ln -s $HOME/Documents/GitHub/dotfiles/tmux/tmux_myplug.sh ~/.tmux_myplug # caution! Don't needs slash at last.
file ~/.tmux_myplug # check link
```

3. Install iceberg-dark

To download, run the following command:

```bash
wget -O $HOME/.tmux/iceberg_minimal_with_win_index.tmux.conf \
https://raw.githubusercontent.com/ShortArrow/iceberg-dark/master/.tmux/iceberg_minimal_with_win_index.tmux.conf
```

