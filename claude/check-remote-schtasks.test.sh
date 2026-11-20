#!/usr/bin/env bash
# Corpus for check-remote-schtasks.sh: each check is  verdict, command.
# "deny" expects a deny JSON on stdout; "allow" expects silence.
set -u

script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
guard="$script_dir/check-remote-schtasks.sh"

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

# A task registered, changed or deleted on the ssh command line, in the shapes an agent uses.
check deny  "ssh tempPC 'schtasks /create /tn Rollback /tr C:\\tmp\\rollback.cmd /sc once /st 12:00 /ru SYSTEM'"
check deny  'ssh tempPC schtasks /create /tn X /tr notepad /sc onlogon'
check deny  'ssh -o HostName=192.168.123.140 -o HostKeyAlias=192.168.29.140 tempPC "schtasks.exe /delete /tn X /f"'
check deny  "ssh tempPC 'C:\\Windows\\System32\\schtasks.exe /change /tn X /disable'"
check deny  'ssh tempPC SCHTASKS /Create /TN X /TR notepad /SC ONLOGON'
check deny  'ssh tempPC pwsh -c "Set-ScheduledTask -TaskName X -Trigger $t"'
check deny  'ssh tempPC pwsh -c "Unregister-ScheduledTask -TaskName X -Confirm:$false"'
check deny  'ssh tempPC pwsh -NoProfile -Command "Register-ScheduledTask -TaskName X -Action $a -Trigger $t"'
check deny  "ssh.exe tempPC 'powershell -c \"register-scheduledtask -TaskName X -Xml (Get-Content x.xml -Raw)\"'"
check deny  '& ssh tempPC "Register-ScheduledTask -TaskName X -InputObject $task"'
check deny  'scp a.txt tempPC:C:/tmp/ && ssh tempPC schtasks /create /tn X /tr notepad /sc onstart'
check deny  "ssh tempPC pwsh -NoProfile -Command - <<'EOF'
\$a = New-ScheduledTaskAction -Execute pwsh
Register-ScheduledTask -TaskName X -Action \$a
EOF"
check deny  '"C:\Windows\System32\OpenSSH\ssh.exe" tempPC schtasks /create /tn X /tr notepad /sc onstart'

# The sanctioned way, and the task commands that register nothing: query, run, end.
check allow 'scp register-task.ps1 tempPC:C:/tmp/ && ssh tempPC pwsh -NoProfile -File C:/tmp/register-task.ps1'
check allow 'ssh tempPC pwsh -NoProfile -File C:/tmp/register-schtasks.ps1'
check allow 'ssh tempPC pwsh -NoProfile -File C:/tmp/Register-ScheduledTask.ps1'
check allow 'ssh tempPC Get-ScheduledTask'
check allow 'ssh tempPC schtasks /query /tn X /v /fo list'
check allow "ssh tempPC 'C:\Windows\System32\schtasks.exe /run /tn X'"
check allow 'ssh tempPC pwsh -c "Start-ScheduledTask -TaskName X"'
check allow 'ssh tempPC schtasks /end /tn X'

# No ssh in command position: local task commands, searches, prose.
check allow 'schtasks /create /tn X /tr notepad /sc onlogon'
check allow 'Register-ScheduledTask -TaskName X -Action $a'
check allow "grep -n 'ssh.*schtasks' notes.md"
check allow 'git commit -m "docs: ssh では schtasks を直接打たない"'
check allow 'Get-Service sshd; schtasks /query /tn X'
check allow 'ssh-keygen -t ed25519 -f key; schtasks /query /tn X'

printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
