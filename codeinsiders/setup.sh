#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
config_dir="$HOME/.config/Code - Insiders/User"

rm -f "$config_dir/keybindings.json"
rm -f "$config_dir/settings.json"

ln -s "$script_dir/keybindings.json" "$config_dir/keybindings.json"
ln -s "$script_dir/settings.json" "$config_dir/settings.json"

file "$config_dir/keybindings.json"
file "$config_dir/settings.json"
