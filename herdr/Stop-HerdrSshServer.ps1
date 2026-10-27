#!pwsh

<#
.SYNOPSIS
  Stop the herdr server that an SSH reconnect started in session 0.

.DESCRIPTION
  Runs elevated from the on-demand task that Register-HerdrDesktopServer.ps1
  registers: that server runs under sshd's elevated token, so the desktop
  user cannot stop it. `herdr server stop` lets it save its session first;
  only while no desktop server runs, since the socket then belongs to the
  session 0 one. Whatever is left is ended with its process tree, so no pane
  outlives it in session 0.
#>
param(
    [string]$Log = (Join-Path $env:LOCALAPPDATA 'herdr\desktop-server.log')
)

. "$PSScriptRoot/HerdrServer.ps1"

function Get-HerdrProcess { @(Get-CimInstance Win32_Process -Filter "Name='herdr.exe'") }

$desktop = (Get-Process -Id $PID).SessionId
$ssh = @(Select-HerdrServer -Process (Get-HerdrProcess) -SessionId 0)
if (-not $ssh) { exit 0 }

if (-not (Select-HerdrServer -Process (Get-HerdrProcess) -SessionId $desktop)) {
    $herdr = (Get-Command herdr.exe -CommandType Application | Select-Object -First 1).Source
    & $herdr server stop 2>&1 | Out-Null
}
foreach ($server in Select-HerdrServer -Process (Get-HerdrProcess) -SessionId 0) {
    & taskkill.exe /pid $server.ProcessId /t /f 2>&1 | Out-Null
}
Add-Content -LiteralPath $Log -Value ('{0:s} stop  session 0 server(s) {1}' -f (Get-Date), ($ssh.ProcessId -join ','))
