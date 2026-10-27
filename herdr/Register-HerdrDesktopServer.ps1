#!pwsh

<#
.SYNOPSIS
  Register the logon takeover that keeps the herdr server in the desktop session.

.DESCRIPTION
  Two tasks, because the takeover needs both sides of UAC:
    herdr-desktop-server   at logon, unelevated: Start-HerdrDesktopServer.ps1
    herdr-stop-ssh-server  on demand, elevated:  Stop-HerdrSshServer.ps1
  The server must start unelevated, or the desktop client is refused; the one
  it replaces runs under sshd's elevated token and only an elevated process
  can stop it. Registering the elevated task needs an elevated shell.
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

function New-ScriptAction([string]$Script) {
    New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\conhost.exe" `
        -Argument "--headless `"$PSHOME\pwsh.exe`" -NoProfile -File `"$(Join-Path $PSScriptRoot $Script)`""
}

Write-DotfileInfo 'herdr: logon takeover of the SSH-started server'
$tasks = @(
    @{ TaskName = 'herdr-stop-ssh-server'; Action = New-ScriptAction 'Stop-HerdrSshServer.ps1'
       Principal = New-ScheduledTaskPrincipal @principal -RunLevel Highest }
    @{ TaskName = 'herdr-desktop-server'; Action = New-ScriptAction 'Start-HerdrDesktopServer.ps1'
       Principal = New-ScheduledTaskPrincipal @principal -RunLevel Limited
       Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME }
)
foreach ($task in $tasks) {
    Register-ScheduledTask @task -Settings $settings -Force | Out-Null
    Write-DotfileOk $task.TaskName
}
