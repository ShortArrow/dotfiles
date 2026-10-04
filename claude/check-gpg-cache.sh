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
# prose, after a failed attempt. The hook signs a throwaway text first, with
# the repository's key and --pinentry-mode error, so the attempt fails
# instead of prompting; the state is known before the commit runs, and the
# deny reason carries the one command that fixes it. The agent's per-keygrip
# cached flag (`keyinfo --list`) is not consulted: GnuPG 2.5 was seen to sign
# without prompting while the flag reported the signing keygrip uncached.
#
# The gpg that git uses is the one in gpg.program, not the first `gpg` on
# PATH: in Git Bash on Windows both `gpg` and `gpg.exe` resolve to MSYS's
# /usr/bin/gpg, whose home and agent are different from the GnuPG that git
# calls, so an unlock typed as `gpg.exe --clearsign` caches nothing git can
# use. The unlock command below therefore names gpg.program, and names the
# key: without -u, gpg unlocks its default key, which need not be the one
# this repository signs with.
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

"$gpg" --batch --with-colons -K "$key" >/dev/null 2>&1 || exit 0   # an unknown key is git's error to report, not this guard's

echo test | "$gpg" --batch --pinentry-mode error --local-user "$key" --clearsign >/dev/null 2>&1 && exit 0

deny "The GPG passphrase for signing key $key is not cached in gpg-agent, so this signed operation would fail: a tool call cannot open pinentry. Ask the user to run this in the prompt (the leading ! runs it in the session, where pinentry can open, and the agent then caches the passphrase): ! echo test | \"\$(git config --get gpg.program)\" -u $key --clearsign > /dev/null   — then retry this command unchanged. Do not disable signing, and do not use gpg.exe or gpg from PATH: in Git Bash those are MSYS's copy, with a different agent from the one git uses."
