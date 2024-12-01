#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")

ln -s "$script_dir/.vimrc" "$HOME/.vimrc"

file "$HOME/.vimrc"
