# my tmux config 

## Usage

1. Create `.tmux` folder in your home directory: `mkdir ~/.tmux`

2. To download, run the following command:

```bash
wget -O $HOME/.tmux/iceberg_minimal_with_win_index.tmux.conf \
https://raw.githubusercontent.com/ShortArrow/iceberg-dark/master/.tmux/iceberg_minimal_with_win_index.tmux.conf
```

3. Add `source-file ~/.tmux/iceberg_minimal_with_win_index.tmux.conf` to your `~/.tmux.conf`

```lua
set-option -sg escape-time 10
set-option -g focus-events on
set-option -g default-terminal 'screen-256color'
set-option -ga terminal-overrides ',xterm-256color:Tc'
source-file ~/.tmux/iceberg_minimal_with_win_index.tmux.conf
```

