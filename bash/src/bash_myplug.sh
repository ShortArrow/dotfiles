#!/bin/bash

# dot source for user permission
if [ -d "$HOME/.bashrc.d/" ]; then
  source "$HOME/.bashrc.d/bash_checkers.sh"
  source "$HOME/.bashrc.d/bash_mycompletion.sh"
fi

# dot source for lsp
if [ -d "/usr/local/bin/.bash_myplug/" ]; then
  source "/usr/local/bin/.bash_myplug/bash_checkers.sh"
  source "/usr/local/bin/.bash_myplug/bash_mycompletion.sh"
fi

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
export LESS="-r"

# nvim
if command_exists "nvim"; then
  alias nv="nvim"
  alias んヴぃｍ="nvim"
fi

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
export PATH="$PATH:$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer"
export PATH="$PATH:$HOME/.cargo/bin" # this is `source "$HOME/.cargo/env"`

# vimmer terminal
#set -o vi
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

# pnpm
export PNPM_HOME="/home/who/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# flutter
export PATH="$PATH:$HOME/Documents/GitHub/flutter/bin"
export CHROME_EXECUTABLE="/usr/bin/chromium"
export PATH="$PATH":"$HOME/.pub-cache/bin"

# crontab
alias crontab="crontab -i"

# git-graph
if command_exists "git-graph"; then
  alias gg="git-graph --style round --color always | less"
else
  alias gg="echo command git-graph is not found.\nPlease install \'git-graph\'"
fi

# lazydocker
if command_exists "lazydocker"; then
  alias lzd=lazydocker
else
  alias lzd="echo command lazydocker is not found.\nPlease install \'lazydocker\'"
fi

# lazygit
if command_exists "lazygit"; then
  alias lg=lazygit
else
  alias lg="echo command lazygit is not found.\nPlease install \'lazygit\'"
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

# dvm (deno version manager)
export DVM_DIR="/home/who/.dvm"
export PATH="$DVM_DIR/bin:$PATH"

# nim
export PATH="$HOME/.nimble/bin:$PATH"

# vivid
if command_exists "vivid"; then
  LS_COLORS="$(vivid generate molokai)"
  export LS_COLORS
else
  echo "please install vivid"
fi

# zellij
if command_exists "zellij"; then
  alias zj='zellij'
else
  echo "please install zellij"
fi

# zoxide
if command_exists "zoxide"; then
  eval "$(zoxide init bash)"
fi

# pyenv
if command_exists "pyenv"; then
  eval "$(pyenv init -)"
  # add pyenv shims to PATH
  # pyenvRoot="$(pyenv root)"
  # export PATH="$pyenvRoot/shims:$PATH"
fi

# poetry
export PATH="$PATH:$HOME/.local/bin"
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
