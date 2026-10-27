#!pwsh

<#
.SYNOPSIS
  Register the logon takeover that keeps the herdr server in the desktop session.

.DESCRIPTION
  Two tasks, because the takeover needs both sides of UAC:
    herdr-desktop-server   at logon, unelevated: Start-HerdrDesktopServer.ps1
    herdr-stop-ssh-server  on demand, elevated:  taskkill every herdr.exe in
                           session 0 with its process tree
  The server must start unelevated, or the desktop client is refused; the one
  it replaces runs under sshd's elevated token and only an elevated process
  can stop it. The SSH bridges in session 0 go too and reconnect by themselves.

  The elevated task runs System32's taskkill with its arguments held in the
  task definition, which only an administrator can change: a script or PATH
  lookup there would let any unelevated process run code elevated by editing
  the file and starting the task. Registering it needs an elevated shell.
  Remove with `schtasks /delete /tn <name> /f`.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../lib/_lib.ps1"

$principal = @{ UserId = $env:USERNAME; LogonType = 'Interactive' }
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10)

$stop = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\taskkill.exe" `
    -Argument '/f /t /fi "SESSION eq 0" /fi "IMAGENAME eq herdr.exe"'
$start = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\conhost.exe" `
    -Argument "--headless `"$PSHOME\pwsh.exe`" -NoProfile -File `"$(Join-Path $PSScriptRoot 'Start-HerdrDesktopServer.ps1')`""

Write-DotfileInfo 'herdr: logon takeover of the SSH-started server'
$tasks = @(
    @{ TaskName = 'herdr-stop-ssh-server'; Action = $stop
       Principal = New-ScheduledTaskPrincipal @principal -RunLevel Highest }
    @{ TaskName = 'herdr-desktop-server'; Action = $start
       Principal = New-ScheduledTaskPrincipal @principal -RunLevel Limited
       Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME }
)
foreach ($task in $tasks) {
    Register-ScheduledTask @task -Settings $settings -Force | Out-Null
    Write-DotfileOk $task.TaskName
}
