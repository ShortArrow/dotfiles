#!/usr/bin/env bash
# Corpus for check-machine-guards.sh: each line is  verdict<TAB>command.
# "deny" expects a deny JSON on stdout; "allow" expects silence.
set -u

script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
guard="$script_dir/check-machine-guards.sh"

pass=0
fail=0

check() {
  local expected=$1 command=$2 out verdict
  out=$(jq -nc --arg c "$command" '{tool_input: {command: $c}}' | bash "$guard")
  if [ -n "$out" ]; then verdict=deny; else verdict=allow; fi
  if [ "$verdict" = "$expected" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL (%s, got %s): %s\n' "$expected" "$verdict" "$command" >&2
  fi
}

# GUI launches: the shapes an agent actually types.
check deny  'Start-Process "$env:LOCALAPPDATA\Programs\Bitwarden\Bitwarden.exe"'
check deny  'Start-Process zebar'
check deny  'start glazewm'
check deny  'Invoke-Item C:\tools\Bitwarden.exe'

check deny  'Start-Process code'
check deny  'start code .'
check deny  'Start-Process -FilePath code -ArgumentList .'
check deny  'Invoke-Item "C:\Users\who\AppData\Local\Programs\Microsoft VS Code\Code.exe"'

# Not launches: CLI subcommands, queries, kills, the sanctioned detached path.
check allow 'glazewm.exe command wm-exit'
check allow 'Get-Process Bitwarden -ErrorAction SilentlyContinue'
check allow 'taskkill /im zebar.exe'
check allow 'schtasks /run /tn "GlazeWM_Task"'
check allow 'git commit -m "feat(zebar): float the window"'
check allow 'systemctl restart zebar-sync.service'
check allow 'code .'
check allow 'Start-Process notepad C:\code\readme.txt'
check allow 'Start-Process decode.exe'
check allow 'git grep "start code"'
check allow 'taskkill /im Code.exe'

# Global signing-config writes: the "repair" this machine must refuse.
check deny  'git config --global gpg.format openpgp'
check deny  'git config --global commit.gpgsign false'
check deny  'git config --global --unset user.signingkey'
check deny  'git config --global gpg.program "C:\Program Files\GnuPG\bin\gpg.exe"'

# Reads and per-repo declarations stay open.
check allow 'git config --global --get gpg.format'
check allow 'git config --global --list'
check allow 'git config user.signingkey "key::ssh-ed25519 AAA x"'
check allow 'git config --global core.pager delta'

printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
