#!/bin/bash

configName=".wezterm.lua"

script_dir=$(dirname "$(readlink -f "$0")")

ln -s "$script_dir/$configName" "$HOME/$configName"

file "$HOME/$configName"
