#!/usr/bin/env bash
# PreToolUse guard: a scheduled task on an ssh host is registered by a script
# sent with scp, never by schtasks or Register-ScheduledTask typed on the ssh
# command line. ssh then runs one line, the one that starts that script.
#
# Reads the hook's tool_input JSON on stdin. Prints a deny verdict and exits 0
# when the command line runs ssh and, from there on, names schtasks or
# Register-ScheduledTask as a command; prints nothing otherwise. Silence is
# the allow verdict.
#
# ssh counts only in command position (line start, after ; & | ( or a
# newline, optionally quoted or with a path), so prose, commit messages and
# searches that mention it pass, and so do ssh-keygen and sshd. The task
# command counts only as a whole word, so a script named
# register-schtasks.ps1 or Register-ScheduledTask.ps1 passes.
set -u

command_line=$(jq -r '.tool_input.command // ""' | tr '\n' ';')

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

ssh_onward=$(printf '%s' "$command_line" |
  grep -Eio '(^|[;&|(]) *"?([^ ;&|"]*[\\/])?ssh(\.exe)?"? .*' | head -n 1)
[ -n "$ssh_onward" ] || exit 0

if printf '%s' "$ssh_onward" |
   grep -Eiq '(^|[^a-z0-9_-])(schtasks(\.exe)?|register-scheduledtask)([^a-z0-9_.-]|$)'; then
  deny 'Do not put schtasks or Register-ScheduledTask on an ssh command line. Write the task registration into a script, send it with scp, and run only that script over ssh, in one line: scp register-task.ps1 <host>:C:/tmp/ && ssh <host> pwsh -NoProfile -File C:/tmp/register-task.ps1'
fi

exit 0
