#!/bin/bash

set -euo pipefail

# Resolve script directory (works even if called via absolute/relative path)
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

target_dir="${HOME}/.config/mise"
mkdir -p "$target_dir"

# Symlink config.toml from repo to user config
ln -sf "${script_dir}/src/config.toml" "${target_dir}/config.toml"
