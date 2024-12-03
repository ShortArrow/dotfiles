#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")

ln -s "$script_dir/starship.toml" "$HOME/.config/starship.toml"
