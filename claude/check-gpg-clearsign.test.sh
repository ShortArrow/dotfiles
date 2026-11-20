#!/usr/bin/env bash
# Corpus for check-gpg-clearsign.pl: each check is  verdict, command.
# "deny" expects a deny decision on stdout; "allow" expects silence.
set -u

script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
guard="$script_dir/check-gpg-clearsign.pl"

pass=0
fail=0

check() {
  local expected=$1 command=$2 out verdict
  out=$(jq -nc --arg c "$command" '{tool_input: {command: $c}}' | perl "$guard")
  case "$out" in
    *'"permissionDecision":"deny"'*) verdict=deny ;;
    '') verdict=allow ;;
    *) verdict="unexpected output: $out" ;;
  esac
  if [ "$verdict" = "$expected" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL (%s, got %s): %s\n' "$expected" "$verdict" "$command" >&2
  fi
}

# gpg called with --clearsign, in the shapes an agent types or hands over.
check deny  'echo test | "$(git config --get gpg.program)" -u 7B66415DC7B803DD --clearsign > /dev/null'
check deny  'gpg --clearsign notes.txt'
check deny  'gpg.exe --local-user 7B66415DC7B803DD --clearsign'
check deny  'printf unlock | "C:\Program Files\GnuPG\bin\gpg.exe" --clearsign >/dev/null'
check deny  '& "C:\Program Files\GnuPG\bin\gpg.exe" --clear-sign notes.txt'
check deny  'gpg2 --batch --clearsign notes.txt'
check deny  'echo x | "$gpg" --local-user "$key" --clearsign >/dev/null'
check deny  'cmd /c gpg --clearsign notes.txt'
check deny  '"$(git config gpg.program)" --clearsign < /dev/null'

# git unlock is the sanctioned way: its body uses --clearsign, the line does not.
check allow 'git unlock'
check allow 'bash git/unlock.sh'
check allow 'cd /v/github.com/ShortArrow/dotfiles && git unlock'

# Other gpg calls, and the words only mentioned.
check allow 'gpg --list-secret-keys --keyid-format long'
check allow 'gpg --verify notes.txt.asc'
check allow 'gpgconf --reload gpg-agent'
check allow 'git log --show-signature -1'
check allow 'git commit -m "fix: the passphrase is cached by git unlock, not gpg --clearsign"'
check allow "grep -n -- '--clearsign' git/unlock.sh"
check allow 'rg clearsign claude/'
check allow 'echo "type ! git unlock; never gpg --clearsign"'

# The deny reason reads as written: the user types ! git unlock.
reason=$(jq -nc '{tool_input: {command: "gpg --clearsign x"}}' | perl "$guard" |
  jq -r '.hookSpecificOutput.permissionDecisionReason')
case "$reason" in
  '署名のパスフレーズは ! git unlock でユーザーに入れてもらう。エージェントは打たない。'*) pass=$((pass + 1)) ;;
  *) fail=$((fail + 1)); printf 'FAIL (reason): %s\n' "$reason" >&2 ;;
esac

printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
