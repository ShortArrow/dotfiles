# for mac zsh
cd $HOME/Documents/Github
set-option -g default-shell "${SHELL}"
set -g default-command "${SHELL}"

# color theme
source-file ~/.tmux/iceberg_minimal.tmux.conf
source-file ~/.tmux/iceberg_minimal_with_win_index.tmux.conf
set-option -g default-terminal "screen-256color"
set-option -ga terminal-overrides ',xterm-256color:Tc'

# copymode
set-window-option -g mode-keys vi

set-option -sg escape-time 10
set-option -g focus-events on
