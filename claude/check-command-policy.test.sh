#!/usr/bin/env bash
# Corpus for check-command-policy.pl: each check is  verdict, command.
#   deny  expects a deny decision,
#   ask   expects an ask decision,
#   log   expects silence and one new line in the log,
#   allow expects silence and no new log line.
set -u

script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
guard="$script_dir/check-command-policy.pl"
log=$(mktemp)
export CLAUDE_COMMAND_POLICY_LOG="$log"

pass=0
fail=0

check() {
  local expected=$1 command=$2 out verdict before after
  before=$(wc -l < "$log")
  out=$(jq -nc --arg c "$command" '{tool_input: {command: $c}}' | perl "$guard")
  after=$(wc -l < "$log")
  case "$out" in
    *'"permissionDecision":"deny"'*) verdict=deny ;;
    *'"permissionDecision":"ask"'*) verdict=ask ;;
    '') if [ "$after" -gt "$before" ]; then verdict=log; else verdict=allow; fi ;;
    *) verdict="unexpected output: $out" ;;
  esac
  if [ "$verdict" = "$expected" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL (%s, got %s): %s\n' "$expected" "$verdict" "$command" >&2
  fi
}

# ERROR: a scheduled task registered, changed or deleted on this machine.
check deny  'schtasks /create /tn X /tr notepad /sc onlogon'
check deny  'SCHTASKS.EXE /Delete /TN X /F'
check deny  '& "C:\Windows\System32\schtasks.exe" /change /tn X /disable'
check deny  'cmd /c schtasks -create /tn X /tr notepad /sc once /st 12:00'
check deny  'Get-Date; schtasks /create /tn X /tr notepad /sc onlogon'
check deny  "Start-Process schtasks -ArgumentList '/create /tn X /tr notepad /sc onlogon'"
check deny  'Register-ScheduledTask -TaskName X -Action $a -Trigger $t'
check deny  '$task = Register-ScheduledTask -TaskName X -Xml (Get-Content x.xml -Raw)'
check deny  'New-ScheduledTask -Action $a | Register-ScheduledTask -TaskName X'
check deny  "pwsh -NoProfile -Command - <<'EOF'
\$a = New-ScheduledTaskAction -Execute notepad
Register-ScheduledTask -TaskName X -Action \$a
EOF"

# ERROR: an encoded script.
check deny  'powershell -NoProfile -EncodedCommand SQBFAFgA'
check deny  'pwsh -enc SQBFAFgA'
check deny  'pwsh.exe -ec SQBFAFgA'
check deny  'powershell.exe -e SQBFAFgA'

# ERROR: a Windows service created.
check deny  'sc create MySvc binPath= C:\x.exe'
check deny  'sc.exe \\pc1 create MySvc binPath= C:\x.exe'
check deny  'New-Service -Name MySvc -BinaryPathName C:\x.exe'

# ERROR: a process started through WMI.
check deny  'wmic process call create "notepad.exe"'
check deny  'wmic /node:pc1 process call create "cmd /c x"'
check deny  'Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine="notepad"}'
check deny  'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList notepad'

# WARN: the script policy turned off.
check ask   'powershell -ExecutionPolicy Bypass -File x.ps1'
check ask   'pwsh -ep bypass -File x.ps1'
check ask   'Set-ExecutionPolicy Bypass -Scope Process'

# WARN: remoting, PsExec, elevation.
check ask   'Invoke-Command -ComputerName pc1 -ScriptBlock { hostname }'
check ask   '$r = Invoke-Command -ComputerName pc1 { hostname }'
check ask   'Enter-PSSession pc1'
check ask   '$s = New-PSSession -ComputerName pc1'
check ask   'psexec \\pc1 -s cmd'
check ask   'PsExec64.exe -s -i cmd'
check ask   'Start-Process pwsh -Verb RunAs -ArgumentList "-File x.ps1"'

# WARN: a program set to start at every logon.
check ask   'reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v X /d C:\x.exe'
check ask   "Set-ItemProperty 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run' -Name X -Value C:\\x.exe"
check ask   'New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Name X -Value y'
check ask   'Copy-Item x.lnk "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\"'
check ask   'New-Item -ItemType SymbolicLink -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\x.lnk" -Target C:\x.exe'

# INFO: a command run over ssh is logged and let through.
check log   'ssh host powershell -NoProfile -ExecutionPolicy RemoteSigned -File check.ps1'
check log   'scp t.ps1 host: && ssh host pwsh -NoProfile -File t.ps1'
check log   'ssh host schtasks /query /tn X'
check log   'ssh host wmic os get caption'
check log   "ssh host 'sc create X binPath= C:\\x.exe'"
check log   'ssh host powershell -EncodedCommand SQBFAFgA'

# Reads, and the words only mentioned: quotes, commit messages, searches, echo.
check allow 'schtasks /query /tn X /v /fo list'
check allow 'schtasks /run /tn X'
check allow 'Get-ScheduledTask -TaskName X'
check allow 'reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run'
check allow "Get-ItemProperty 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run'"
check allow 'Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"'
check allow 'misc create foo'
check allow 'Start-Process notepad'
check allow 'powershell -NoProfile -ExecutionPolicy RemoteSigned -File x.ps1'
check allow 'git commit -m "feat: refuse schtasks /create; ask for Invoke-Command and psexec"'
check allow "git commit -F - <<'EOF'
feat: refuse sc create and wmic process call create
Register-ScheduledTask and -EncodedCommand are refused too.
EOF"
check allow "grep -rn 'schtasks.*create' claude/"
check allow 'rg -i "Invoke-Command|psexec|ExecutionPolicy Bypass" .'
check allow 'echo "run pwsh -enc AAA or sc create X"'
check allow 'Write-Host "Register-ScheduledTask | New-Service"'
check allow 'Select-String -Pattern "Enter-PSSession" -Path *.ps1'
check allow 'Get-Service sshd; ssh-keygen -l -f key.pub'

# A logged command with Japanese in it is written as UTF-8, with nothing on stderr.
err=$(jq -nc '{tool_input: {command: "ssh host powershell -Command \"echo 日本語\""}}' |
  perl "$guard" 2>&1 >/dev/null)
if [ -z "$err" ] && tail -n 1 "$log" | grep -q '日本語'; then
  pass=$((pass + 1))
else
  fail=$((fail + 1))
  printf 'FAIL (utf-8 log): stderr=%s last=%s\n' "$err" "$(tail -n 1 "$log")" >&2
fi

rm -f "$log"
printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
