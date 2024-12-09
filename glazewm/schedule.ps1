#! pwsh

$taskName = "GlazeWM_Task"
$user = "$env:COMPUTERNAME\$env:USERNAME"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -StartWhenAvailable `
    -DontStopIfGoingOnBatteries `
    -StartIfNotIdle `
    -RestartOnIdle
$action = New-ScheduledTaskAction `
  -Execute "%userprofile%\Documents\GitHub\glazewm\target\release\glazewm.exe" `
  -Argument "start"

Register-ScheduledTask -TaskName $taskName -User $user -Trigger $trigger -Action $action -Settings $settings -Force

