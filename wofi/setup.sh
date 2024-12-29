#!/bin/bash

configName="wofi"

script_dir=$(dirname "$(readlink -f "$0")")

ln -s "$script_dir/src" "$HOME/.config/$configName"

file "$HOME/.config/$configName"
