#!/bin/bash
mkdir -p "$HOME/.config/alacritty/"
rm -f "$HOME/.config/alacritty/alacritty.yml"
ln -s "$HOME/Documents/GitHub/dotfiles/alacritty/alacritty.yml" "$HOME/.config/alacritty/"
