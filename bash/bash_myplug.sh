# ls
alias l.='ls -d .* --color=tty'
alias ll='ls -l --color=tty'
alias ll.='ls -al --color=tty'
alias ls='ls --color=tty'
alias ls.='ls -a --color=tty'

# mosh
export LANG='en_US.UTF8'
export LC_CTYPE='en_US.UTF8'

# lua
alias luamake=$HOME/Documents/GitHub/lua-language-server/3rd/luamake/luamake
export PATH=$PATH:$HOME/Documents/GitHub/lua-language-server/bin

# rust
. "$HOME/.cargo/env"
export PATH=$PATH:$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer

# vimmer terminal
set -o vi
export VISUAL=vi
export EDITOR=vi
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
alias crontab='crontab -i'

# crontab
alias foresta='git-foresta | less -RSX'
