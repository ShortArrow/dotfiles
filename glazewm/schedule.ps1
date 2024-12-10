#! pwsh

$taskName = "GlazeWM_Task"
$glazewmPath = Resolve-Path `
    -Path "$env:USERPROFILE/Documents/GitHub/glazewm/target/release/glazewm.exe"
$argument = @(
        "-c `"`$PSStyle.OutputRendering='Ansi'",
        "Start-Process -NoNewWindow '$glazewmPath' -ArgumentList 'start'",
        "pause",
        "`""
    ) -join ";"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -StartWhenAvailable `
    -DontStopIfGoingOnBatteries
$action = New-ScheduledTaskAction `
    -Execute "pwsh.exe" `
    -Argument $argument

Register-ScheduledTask `
    -TaskName $taskName `
    -User $env:USERNAME `
    -Trigger $trigger `
    -Action $action `
    -Settings $settings `
    -Force

