#!pwsh

<#
.SYNOPSIS
  Capture the interactive desktop from a session that does not have one.

.DESCRIPTION
  An SSH session on Windows, and an RDP session that is currently
  disconnected, run without a window station. GDI screen capture there
  returns a black image and reports no error, so the failure is silent.

  This registers a one-shot scheduled task that runs as the interactive
  user, starts it, waits for the PNG to appear, and removes the task
  again. The capture therefore happens inside the desktop session while
  the caller stays in the headless one.

  Requires the target user to be logged on with a live desktop. A fully
  signed-out machine has nothing to capture.

.PARAMETER Path
  Destination PNG. Defaults to a timestamped file under
  <MyPictures>\Screenshots. Passed through to Save-Screenshot.ps1.

.PARAMETER TimeoutSeconds
  How long to wait for the file. The original waited a fixed 3 seconds
  and then deleted the task, which could remove it mid-capture on a slow
  or high-resolution desktop.

.EXAMPLE
  ./Invoke-ScreenshotViaTask.ps1 -Path C:/temp/remote.png
#>
param(
  [string]$Path,
  [int]$TimeoutSeconds = 30
)

$ErrorActionPreference = 'Stop'

$taskName = "TakeScreenshotOnce-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
$capture = Join-Path $PSScriptRoot 'Save-Screenshot.ps1'

if (-not $Path)
{
  $saveDir = Join-Path ([Environment]::GetFolderPath('MyPictures')) 'Screenshots'
  $Path = Join-Path $saveDir "screenshot-$(Get-Date -Format 'yyyyMMdd-HHmmss').png"
}
if (Test-Path -LiteralPath $Path) { Remove-Item -LiteralPath $Path -Force }

$action = New-ScheduledTaskAction `
  -Execute 'powershell.exe' `
  -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$capture`" -Path `"$Path`""

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)

$principal = New-ScheduledTaskPrincipal `
  -UserId "$env:COMPUTERNAME\$env:USERNAME" `
  -LogonType Interactive `
  -RunLevel Limited

Register-ScheduledTask `
  -TaskName $taskName `
  -Action $action `
  -Trigger $trigger `
  -Principal $principal `
  -Force | Out-Null

try
{
  Start-ScheduledTask -TaskName $taskName

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline -and -not (Test-Path -LiteralPath $Path))
  {
    Start-Sleep -Milliseconds 250
  }
} finally
{
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

if (-not (Test-Path -LiteralPath $Path))
{
  throw "Screenshot did not appear within ${TimeoutSeconds}s. Is $env:USERNAME logged on with a live desktop?"
}

Write-Output $Path
