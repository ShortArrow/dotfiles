#!/usr/bin/env bash
# PreToolUse guard: refuse commands that break this machine's standing
# arrangements — mistakes made once and now fenced off.
#
# Reads the hook's tool_input JSON on stdin. Prints a deny verdict and exits 0
# when a guard fires; prints nothing otherwise. Silence is the allow verdict.
#
# Guard 1 — GUI launches. A GUI app started from a session inherits its
# console handles, and its log stream floods the chat until the process
# dies (zebar 2026-06, Bitwarden 2026-08). Only launch verbs are refused:
# the apps' own CLI subcommands (glazewm command wm-exit), queries, kills
# and the sanctioned detached path (schtasks /run) must keep working. The
# launch-verb list covers the shapes an agent actually types; a bare exe
# invocation slips through, which is the price of not matching commit
# messages that merely mention an app.
#
# Guard 2 — global signing-config writes. Signing on this machine is SSH
# via the Bitwarden agent, declared per repository; the global gpg.* and
# signing keys are owned by git/setup.ps1. An agent that meets the
# undeclared-key refusal and reaches for `git config --global` is
# "repairing" a design decision. Reads (--get, --list) stay open, and so
# do per-repository declarations.
set -u

command_line=$(jq -r '.tool_input.command // ""')

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

apps='(bitwarden|zebar|glazewm)'
if printf '%s' "$command_line" | grep -Eiq "(start-process|invoke-item)[^;|&]*$apps" ||
   printf '%s' "$command_line" | grep -Eiq "(^|[;&|] *)start +[^;|&]*$apps"; then
  deny 'GUI apps must not be launched from a session: the process inherits the console handles and its logs flood the chat. Ask the user to start it (tray, Start menu), or use schtasks /run for a detached launch.'
fi

if printf '%s' "$command_line" | grep -Eiq 'git +config' &&
   printf '%s' "$command_line" | grep -q -- '--global' &&
   printf '%s' "$command_line" | grep -Eiq '(gpg\.|commit\.gpgsign|user\.signingkey)' &&
   ! printf '%s' "$command_line" | grep -Eq -- '--(get|list)'; then
  deny 'Global signing config is owned by git/setup.ps1 (SSH signing via the Bitwarden agent, keys declared per repository — see the pre-commit hook message). Do not rewrite it. Declare a per-repo key with Set-GitSigningKey, or ask the user.'
fi

exit 0
