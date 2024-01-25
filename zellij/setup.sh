#!/bin/bash

rm -rf ~/.config/zellij
#zellij setup --dump-config > ~/.config/zellij/config.kdl
ln -s $HOME/Documents/GitHub/dotfiles/zellij/ ~/.config/
