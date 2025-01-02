#!/bin/bash

#/etc/keyd/default.conf

script_dir=$(dirname "$(readlink -f "$0")")
config_dir=/etc/keyd

rm -rf "$config_dir"

ln -s "$script_dir/src" "$config_dir"

file "$config_dir"
