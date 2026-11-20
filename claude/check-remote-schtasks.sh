#!/usr/bin/env bash
# PreToolUse guard: a scheduled task on an ssh host is registered by a script
# sent with scp, never by schtasks or Register-ScheduledTask typed on the ssh
# command line. ssh then runs one line, the one that starts that script.
#
# Reads the hook's tool_input JSON on stdin. Prints a deny verdict and exits 0
# when the command line runs ssh and, from there on, registers, changes or
# deletes a task: schtasks /create, /change or /delete, or Register-,
# Set- or Unregister-ScheduledTask. Prints nothing otherwise. Silence is
# the allow verdict. Reading and starting a task — schtasks /query, /run,
# /end, Get- and Start-ScheduledTask — stay open over ssh.
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

word_start='(^|[^a-z0-9_-])'
schtasks_write="${word_start}schtasks(\\.exe)?[^;&|]* [\"']?/(create|change|delete)([^a-z]|\$)"
cmdlet_write="${word_start}(register|set|unregister)-scheduledtask([^a-z0-9_.-]|\$)"
if printf '%s' "$ssh_onward" | grep -Eiq "$schtasks_write|$cmdlet_write"; then
  deny 'Do not register, change or delete a scheduled task on an ssh command line (schtasks /create, /change, /delete, Register-, Set- or Unregister-ScheduledTask). Write the task registration into a script, send it with scp, and run only that script over ssh, in one line: scp register-task.ps1 <host>:C:/tmp/ && ssh <host> pwsh -NoProfile -File C:/tmp/register-task.ps1'
fi

exit 0
