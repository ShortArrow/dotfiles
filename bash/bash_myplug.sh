#!/bin/bash

# ls
alias l.="ls -d .* --color=tty"
alias ll="ls -l --color=tty"
alias ll.="ls -al --color=tty"
alias ls="ls --color=tty"
alias ls.="ls -a --color=tty"

# sudo refresher
alias sudo="sudo -v; sudo"

# ignore case on completion
bind "set completion-ignore-case on"

# mosh
export LANG="en_US.UTF8"
export LC_CTYPE="en_US.UTF8"

# go
export PATH="$PATH:$HOME/go/bin"

# rust
. "$HOME/.cargo/env"
export PATH="$PATH:$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer"

# vimmer terminal
set -o vi
export VISUAL=vim
export EDITOR=vim
unset LESSEDIT

# starship
eval "$(starship init bash)"

# npm, node, yarn
# export PATH=~/.npm-global/bin:$PATH
export PATH="$PATH:$HOME/.yarn/bin"
export PATH="$PATH:$HOME/.npm-global/bin"
# `npm doctor` `npm root -g` `npm bin -g`

# flutter
export PATH="$PATH:$HOME/Documents/GitHub/flutter/bin"
export CHROME_EXECUTABLE="/usr/bin/chromium"

# crontab
alias crontab="crontab -i"

# git-foresta
alias foresta="git-foresta --all | less -RSX"

# git-graph
alias gg="git-graph --color always | less -RSX"

# lazydocker
alias lzd=lazydocker

# lazygit
alias lg=lazygit

# japanese
export GTK_IM_MODULE=ibus
export T_IM_MODULE=ibus
export MODIFIERS=@im=ibus

# color check
checkcolor() {
	curl -s "https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh" | bash
}
echo "If you want to check color support, run \`checkcolor\`"

# tmux color
alias tmux="tmux -2"

# sshrc
# https://github.com/rcmdnk/sshrc
# alias ssh="sshrc"

# arduino-cli
# https://github.com/cli/cli
alias acli='${HOME}/bin/arduino-cli'

# fnm
export PATH="$HOME/.fnm:$PATH"
eval "$(fnm env)"

# dvm
export DVM_DIR="/home/who/.dvm"
export PATH="$DVM_DIR/bin:$PATH"
export DVM_DIR="/home/who/.dvm"
export PATH="$DVM_DIR/bin:$PATH"

