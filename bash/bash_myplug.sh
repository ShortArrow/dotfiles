# mosh
export LANG='en_US.UTF8'
export LC_CTYPE='en_US.UTF8'

# lua
alias luamake=/home/verde/Documents/GitHub/lua-language-server/3rd/luamake/luamake

# rust
. "$HOME/.cargo/env"
export PATH=$PATH:$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer

# vimmer terminal
set -o vi
export VISUAL=nvim
export EDITOR=nvim
unset LESSEDIT

# starship
eval "$(starship init bash)"

# npm, node
# export PATH=~/.npm-global/bin:$PATH
