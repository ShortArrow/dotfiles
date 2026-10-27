#!pwsh

<#
.SYNOPSIS
  At logon, make the herdr server run in the desktop session, unelevated.

.DESCRIPTION
  Runs unelevated from the logon task that Register-HerdrDesktopServer.ps1
  registers. While no server runs in this session, it has the elevated stop
  task end the session 0 herdr that an SSH reconnect started, then starts
  one here. A saved machine can reconnect in the gap and start another under
  sshd — then this server fails to bind and the loop goes round again.

  A server already running here ends the script at once, so a logon without
  any SSH server is left as it was.
#>
param(
    [int]$MaxAttempts = 10,
    [int]$SettleSeconds = 5,
    [string]$StopTask = 'herdr-stop-ssh-server',
    [string]$Log = (Join-Path $env:LOCALAPPDATA 'herdr\desktop-server.log')
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/HerdrServer.ps1"

function Write-TakeoverLog([string]$Message) {
    Add-Content -LiteralPath $Log -Value ('{0:s} start {1}' -f (Get-Date), $Message)
}

function Test-DesktopServer([int]$SessionId) {
    $processes = @(Get-CimInstance Win32_Process -Filter "Name='herdr.exe'")
    [bool](Select-HerdrServer -Process $processes -SessionId $SessionId)
}

function Invoke-StopTask {
    & schtasks.exe /run /tn $StopTask | Out-Null
    Start-Sleep -Seconds 2
}

$session = (Get-Process -Id $PID).SessionId
$herdr = (Get-Command herdr.exe -CommandType Application | Select-Object -First 1).Source

for ($attempt = 1; ; $attempt++) {
    $step = Get-HerdrTakeoverStep -DesktopServerRunning (Test-DesktopServer $session) -Attempt $attempt -MaxAttempts $MaxAttempts
    if ($step -ne 'Takeover') {
        Write-TakeoverLog "$step after $($attempt - 1) takeover(s) in session $session"
        exit ($step -eq 'Done' ? 0 : 1)
    }
    Invoke-StopTask
    Start-Process -FilePath $herdr -ArgumentList 'server' -WindowStyle Hidden
    Start-Sleep -Seconds $SettleSeconds
}
