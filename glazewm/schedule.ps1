#! pwsh

param(
    [ValidateSet("Debug", "Release", "None")]
    [string]$Target = "None",
    [switch]$Pause,
    [string]$LocalRepository = "V:/glazewm"
)

function IsAdmin() {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    return $isAdmin
}

function RestartWithAdmin()
{
    $scriptPath = Resolve-Path $Script:MyInvocation.MyCommand.Path
    # if you want debug, add '-nol' option to $arguments
    $arguments = @("-nop", "-nol", "-ex", "RemoteSigned", "-c", "$scriptPath -Target $Target $($Pause ? "-Pause" : $null)")
    Start-Process pwsh -ArgumentList $arguments -Verb RunAs -Wait -PassThru
}

if (-not (IsAdmin)) {
    RestartWithAdmin
    exit
}

# check in no capital or lower case
if ($Target.ToLower() -eq "debug") {
    $glazewmPath = Resolve-Path `
        -Path "$LocalRepository/target/debug/glazewm.exe"
}
elseif ($Target.ToLower() -eq "release") {
    $glazewmPath = Resolve-Path `
        -Path "$LocalRepository/target/release/glazewm.exe"
}
else {
    # C:\Program Files\glzr.io\GlazeWM\cli\glazewm.exe
    $glazewmPath = "$env:ProgramFiles\glzr.io\GlazeWM\cli\glazewm.exe"
}

$taskName = "GlazeWM_Task"
$innerCommand = @(
    "`$PSStyle.OutputRendering='Ansi'",
    "Write-Host -ForegroundColor Green 'invoke success'",
    "`$host.UI.RawUI.WindowTitle = 'GlazewmLog'",
    "Start-Process -NoNewWindow '$glazewmPath' -ArgumentList 'start'",
    ($Pause ? "pause" : $null)
) -join ";"
Write-Host "Inner Command: $innerCommand"
$argument = "-nop -nol -c `"${innerCommand}`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -StartWhenAvailable `
    -DontStopIfGoingOnBatteries
$action = New-ScheduledTaskAction `
    -Execute "$PSHOME/pwsh.exe" `
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

