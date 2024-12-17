#! pwsh

function IsAdmin() {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    return $isAdmin
}

function RestartWithAdmin()
{
    $scriptPath = Resolve-Path $Script:MyInvocation.MyCommand.Path
    # if you want debug, add '-noe' option to $arguments
    $arguments = @("-nop", "-nol", "-ex", "RemoteSigned", "-f", "$scriptPath")
    Start-Process pwsh -ArgumentList $arguments -Verb RunAs -Wait -PassThru
    exit
}

if (-not (IsAdmin)) {
    RestartWithAdmin
}

$taskName = "GlazeWM_Task"
$glazewmPath = Resolve-Path `
    -Path "$env:USERPROFILE/Documents/GitHub/glazewm/target/release/glazewm.exe"
$argument = @(
        "-c `"`$PSStyle.OutputRendering='Ansi'",
        "`$host.UI.RawUI.WindowTitle = 'GlazewmLog'",
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
    -RunLevel Highest `
    -Force

exit

