#!/bin/bash

source "$HOME/.bash_myplug/bash_checkers.sh"
source "$HOME/.bash_myplug/bash_mycompletion.sh"
source "$HOME/.bash_myplug/bash_mycolor.sh"

# ls
if command_exists "lsd"; then
	alias l.="lsd -d .* "
	alias ll="lsd -l "
	alias ll.="lsd -al "
	alias ls="lsd "
	alias ls.="lsd -a "
else
	alias l.="ls -d .* --color=tty"
	alias ll="ls -l --color=tty"
	alias ll.="ls -al --color=tty"
	alias ls="ls --color=tty"
	alias ls.="ls -a --color=tty"
fi

# ip
alias ip='ip -color=auto'

# less
export LESS='-R --use-color -Dd+r$Du+b'

# bat
if command_exists "bat"; then
	alias ncat="cat" # meaning normal cat
	alias cat="bat"
fi

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
export PATH="$PATH:$HOME/.cargo/bin"

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
export PATH="$PATH":"$HOME/.pub-cache/bin"

# crontab
alias crontab="crontab -i"

# git-foresta
alias foresta="git-foresta --all | less -RSX"

# git-graph
if command_exists "git-graph"; then
	alias gg="git-graph --style round --color always | less -RSX"
else
	alias gg="echo command git-graph is not found.\nPlease run \`cargo install git-graph\`"
fi

# lazydocker
if command_exists "lazydocker"; then
	alias lzd=lazydocker
else
	alias lzd="echo command lazydocker is not found.\nPlease install lazydocker\`"
fi

# lazygit
if command_exists "lazygit"; then
	alias lg=lazygit
else
	alias lg="echo command lazygit is not found.\nPlease run \`cargo install git-graph\` or \`go install github.com/jesseduffield/lazygit@latest\`, \`pkg install lazygit\`"
fi

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

# fnm (Fast Node.js version Manager)
export PATH="$HOME/.fnm:$PATH"
eval "$(fnm env)"

# dvm (deno version manager)
export DVM_DIR="/home/who/.dvm"
export PATH="$DVM_DIR/bin:$PATH"

# nim
export PATH="$HOME/.nimble/bin:$PATH"
