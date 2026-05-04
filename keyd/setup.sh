#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/_lib.sh
source "$script_dir/../lib/_lib.sh"

# keyd installs to /etc/keyd, which is owned by root.
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  dotfile_error 'keyd setup must run as root (try: sudo bash keyd/setup.sh)'
  exit 1
fi

new_dotfile_symlink "$script_dir/src" /etc/keyd
