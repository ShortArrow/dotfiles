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
if command_exists "starship"; then
  eval "$(starship init bash)"
else
  echo "please install starship"
fi

# npm, node, yarn
# export PATH=~/.npm-global/bin:$PATH
export PATH="$PATH:$HOME/.yarn/bin"
export PATH="$PATH:$HOME/.npm-global/bin"
# `npm doctor` `npm root -g` `npm bin -g`

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
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

# lazydocker
if command_exists "lazydocker"; then
  alias lzd=lazydocker
else
  alias lzd="Please install 'lazydocker'"
fi

# lazygit
if command_exists "lazygit"; then
  alias lg=lazygit
else
  alias lg="Please install 'lazygit'"
fi

# japanese
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export MODIFIERS=@im=fcitx

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
if command_exists "arduino-cli"; then
  alias acli='${HOME}/bin/arduino-cli'
else
  alias acli="Please install 'arduino-cli'"
fi

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
else
  echo "please install zoxide"
fi

# pyenv
if command_exists "pyenv"; then
  eval "$(pyenv init -)"
  # add pyenv shims to PATH
  # pyenvRoot="$(pyenv root)"
  # export PATH="$pyenvRoot/shims:$PATH"
fi

# zed
if command_exists "zeditor"; then
  alias zed='zeditor'
fi

# poetry
export PATH="$PATH:$HOME/.local/bin"
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# SUDO_ASKPASS - GUI password prompt for sudo
if command_exists "zenity"; then
  export SUDO_ASKPASS="zenity --password --title='sudo password required'"
elif command_exists "kdialog"; then
  export SUDO_ASKPASS="kdialog --password 'sudo password required'"
elif command_exists "ssh-askpass"; then
  export SUDO_ASKPASS="ssh-askpass"
fi

# WSL2

alias explorer="explorer.exe ."

# for reloading this script

alias reload="source \$HOME/.bashrc"

# GPG
#
# enable passphrase prompt for gpg
# GPG_TTY=$(tty)
# export GPG_TTY
#
# sudo ln -s /mnt/c/Program\ Files\ \(x86\)/GnuPG/bin/gpg.exe /usr/local/bin/gpg
# sudo ln -s gpg /usr/local/bin/gpg2

# fzf
if command_exists "fzf"; then
  export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --color header:italic
    --preview 'bat -n --color=always {}'"
  export FZF_COMPLETION_TRIGGER='**'
  export FZF_COMPLETION_OPTS="
    --walker-skip .git,node_modules,target
    --info=inline"
  export FZF_COMPLETION_PATH_OPTS="--walker file,follow,hidden"
  export FZF_COMPLETION_DIR_OPTS="--walker dir,follow"
  export FZF_TMUX=1
  eval "$(fzf --bash)"
else
  echo "please install fzf"
fi

# mcfly
if command_exists "mcfly"; then
  eval "$(mcfly init bash)"
else
  echo "please install mcfly"
fi

# WSL
if command_exists "wsl.exe";then
  alias wsl="wsl.exe"
else
  alias wsl="echo 'wsl.exe is not found, are you in Windows?'"
fi

# waybar
if command_exists "waybar"; then
  alias waybar-reload="pkill waybar && hyprctl dispatch exec waybar"
else
  alias waybar-reload="echo 'waybar is not found'"
fi

# gitignore
function gig() {
  curl -sL "https://gitignore.io/api/${*}"
}
