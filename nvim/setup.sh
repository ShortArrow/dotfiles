#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
dst_dir="$HOME/.config/nvim"
src_dir="${script_dir}/src"

rm -rf "$HOME/.config/nvim"
ln -s "$src_dir" "$dst_dir"
ls -la "$HOME/.config/nvim" # check link

