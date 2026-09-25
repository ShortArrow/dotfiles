#!/usr/bin/env bash
# PreToolUse guard: a signed git operation whose passphrase is not cached.
#
# Reads the hook's tool_input JSON on stdin. Prints a deny verdict and exits 0
# when the guard fires; prints nothing otherwise. Silence is the allow verdict.
#
# Signing on this machine is GPG through gpg-agent, and the passphrase cache
# expires (gpg-agent.conf: max-cache-ttl). A tool call cannot open pinentry,
# so `git commit` then fails with "gpg failed to sign the data" and the
# session asks the user to unlock the key and report back — every day, in
# prose, after a failed attempt. The agent can be asked instead:
# `gpg-connect-agent 'keyinfo --list'` prints one line per key with a cached
# flag in the seventh field, so the state is known before the commit runs,
# and the deny reason carries the one command that fixes it.
#
# The gpg that git uses is the one in gpg.program, not the first `gpg` on
# PATH: in Git Bash on Windows both `gpg` and `gpg.exe` resolve to MSYS's
# /usr/bin/gpg, whose home and agent are different from the GnuPG that git
# calls, so an unlock typed as `gpg.exe --clearsign` caches nothing git can
# use. The unlock command below therefore names gpg.program, and
# gpg-connect-agent is taken from the same directory.
set -u

input="$(cat)"
command_line=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""')

deny() {
  jq -nc --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Only operations that create a signed object. Reads and pushes pass.
printf '%s' "$command_line" | grep -Eq '(^|[;&|] *)git +(commit|merge|tag|rebase|cherry-pick|revert|am)\b' || exit 0
printf '%s' "$command_line" | grep -Eq -- '--no-gpg-sign|--no-sign|gpgsign=false' && exit 0

[ -n "$cwd" ] && cd "$cwd" 2>/dev/null
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
[ "$(git config --get commit.gpgsign)" = "true" ] || exit 0
[ "$(git config --get gpg.format 2>/dev/null || echo openpgp)" = "openpgp" ] || exit 0
key=$(git config --get user.signingkey)
[ -n "$key" ] || exit 0          # the pre-commit hook explains that case

gpg=$(git config --get gpg.program)
[ -n "$gpg" ] || gpg=gpg
agent="$(dirname "$gpg")/gpg-connect-agent"
case "$gpg" in *.exe) agent="$agent.exe" ;; esac
command -v "$agent" >/dev/null 2>&1 || agent=gpg-connect-agent

# Keygrips of the primary key and of every subkey that can sign. Colon
# output: a sec/ssb record carries the capabilities in field 12, and the
# grp record that follows it carries the keygrip in field 10.
grips=$("$gpg" --batch --with-colons --with-keygrip -K "$key" 2>/dev/null | awk -F: '
  $1 == "sec" || $1 == "ssb" { signs = ($12 ~ /[sS]/) }
  $1 == "grp" && signs { print $10 }')
[ -n "$grips" ] || exit 0       # an unknown key is git's error to report, not this guard's

cached=0
keyinfo=$("$agent" 'keyinfo --list' /bye 2>/dev/null)
for g in $grips; do
  printf '%s\n' "$keyinfo" | grep -Eq "^S KEYINFO $g [^ ]+ [^ ]+ [^ ]+ 1 " && cached=1
done
[ "$cached" -eq 1 ] && exit 0

deny "The GPG passphrase for signing key $key is not cached in gpg-agent, so this signed operation would fail: a tool call cannot open pinentry. Ask the user to run this in the prompt (the leading ! runs it in the session, where pinentry can open, and the agent then caches the passphrase): ! echo test | \"\$(git config --get gpg.program)\" --clearsign > /dev/null   — then retry this command unchanged. Do not disable signing, and do not use gpg.exe or gpg from PATH: in Git Bash those are MSYS's copy, with a different agent from the one git uses."
