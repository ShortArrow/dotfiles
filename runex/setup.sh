#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")

mkdir -p "$HOME/.config/runex"
ln -sf "$script_dir/config.toml" "$HOME/.config/runex/config.toml"
