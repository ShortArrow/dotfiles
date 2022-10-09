# for mac zsh
set-option -g default-shell "${SHELL}"
set -g default-command "${SHELL}"

# color theme
source-file ~/.tmux/iceberg_minimal_with_win_index.tmux.conf
set-option -g default-terminal "tmux-256color"
set-option -ga terminal-overrides ',xterm-256color:Tc'

# copymode
set-window-option -g mode-keys vi

set-option -sg escape-time 10
set-option -g focus-events on

# key bind of window switching
bind -n M-h select-pane -L
bind -n M-j select-pane -D
bind -n M-k select-pane -U
bind -n M-l select-pane -R
