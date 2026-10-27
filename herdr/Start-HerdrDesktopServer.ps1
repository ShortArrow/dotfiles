#!pwsh

<#
.SYNOPSIS
  At logon, make the herdr server run in the desktop session, unelevated.

.DESCRIPTION
  Runs unelevated from the logon task that Register-HerdrDesktopServer.ps1
  registers. Until a server answers `herdr status server` here, it has the
  elevated stop task end the session 0 herdr that an SSH reconnect started,
  ends any server of this session that does not answer, and starts one.
  A saved machine can reconnect in the gap and start another under sshd —
  then this server fails to bind and the loop goes round again.

  A server already answering ends the script at once, so a logon without
  any SSH server is left as it was.
#>
param(
    [int]$MaxAttempts = 10,
    [int]$WaitSeconds = 30,
    [string]$StopTask = 'herdr-stop-ssh-server',
    [string]$Log = (Join-Path $env:LOCALAPPDATA 'herdr\desktop-server.log')
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/HerdrServer.ps1"

$session = (Get-Process -Id $PID).SessionId
$herdr = (Get-Command herdr.exe -CommandType Application | Select-Object -First 1).Source

function Write-TakeoverLog([string]$Message) {
    Add-Content -LiteralPath $Log -Value ('{0:s} start {1}' -f (Get-Date), $Message)
}

function Test-DesktopServer {
    Test-HerdrServerRunning -StatusJson (& $herdr status server --json 2>&1 | Out-String)
}

function Wait-Until([scriptblock]$Condition) {
    $deadline = (Get-Date).AddSeconds($WaitSeconds)
    while (-not (& $Condition) -and (Get-Date) -lt $deadline) { Start-Sleep -Seconds 1 }
}

function Stop-SessionZeroHerdr {
    & schtasks.exe /run /tn $StopTask | Out-Null
    Wait-Until { -not (Get-Process herdr -ErrorAction SilentlyContinue | Where-Object SessionId -eq 0) }
}

function Stop-SilentDesktopServer {
    $processes = @(Get-CimInstance Win32_Process -Filter "Name='herdr.exe'")
    Select-HerdrServer -Process $processes -SessionId $session | ForEach-Object { & taskkill.exe /pid $_.ProcessId /t /f 2>&1 | Out-Null }
}

for ($attempt = 1; ; $attempt++) {
    $step = Get-HerdrTakeoverStep -DesktopServerRunning (Test-DesktopServer) -Attempt $attempt -MaxAttempts $MaxAttempts
    if ($step -ne 'Takeover') {
        Write-TakeoverLog "$step after $($attempt - 1) takeover(s) in session $session"
        exit ($step -eq 'Done' ? 0 : 1)
    }
    Stop-SessionZeroHerdr
    Stop-SilentDesktopServer
    Start-Process -FilePath $herdr -ArgumentList 'server' -WindowStyle Hidden
    Wait-Until { Test-DesktopServer }
}
