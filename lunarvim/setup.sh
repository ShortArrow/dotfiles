#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/_lib.sh
source "$script_dir/../lib/_lib.sh"

# Pin the LunarVim installer to a specific branch.
# Refresh SHA256 by:
#   curl -fsSL "$LV_INSTALLER_URL" | sha256sum
LV_BRANCH='release-1.2/neovim-0.8'
LV_INSTALLER_URL="https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh"
LV_INSTALLER_SHA256="${LV_INSTALLER_SHA256:-}"

if [[ -z "$LV_INSTALLER_SHA256" ]]; then
  dotfile_error 'LV_INSTALLER_SHA256 must be set to verify the installer.'
  dotfile_error "  Compute with: curl -fsSL '$LV_INSTALLER_URL' | sha256sum"
  dotfile_error '  Then re-run: LV_INSTALLER_SHA256=<hash> bash lunarvim/setup.sh'
  exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

dotfile_info "lunarvim: downloading installer"
curl -fsSL "$LV_INSTALLER_URL" -o "$tmp"
echo "$LV_INSTALLER_SHA256  $tmp" | sha256sum -c -
dotfile_ok 'lunarvim: installer sha256 verified'

LV_BRANCH="$LV_BRANCH" bash "$tmp"
