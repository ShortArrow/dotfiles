#!pwsh

<#
.SYNOPSIS
  Which herdr server runs where, and what the logon takeover does next.

.DESCRIPTION
  A saved herdr machine reconnects over SSH as soon as sshd is up, which on a
  rebooted Windows host is before anyone logs on. With no server running, the
  reconnect starts one under sshd: elevated and in session 0. That server
  cannot follow the user's unelevated symlinks (Redirection Trust), refuses the
  desktop client (Access denied), and its panes have no desktop for GUI
  prompts. The takeover replaces it with a server in the desktop session.
#>

function Select-HerdrServer {
    <#
    .SYNOPSIS
      The `herdr.exe server` processes in one Windows session.

    .DESCRIPTION
      Process carries Name, CommandLine and SessionId, as Win32_Process does.
      A process whose command line is unreadable — another elevation's, seen
      unelevated — is not counted.
    #>
    param(
        [AllowEmptyCollection()][object[]]$Process,
        [Parameter(Mandatory)][int]$SessionId
    )
    $Process | Where-Object {
        $_.Name -eq 'herdr.exe' -and $_.SessionId -eq $SessionId -and $_.CommandLine -match '\sserver\s*$'
    }
}

function Get-HerdrTakeoverStep {
    <#
    .SYNOPSIS
      Done once the desktop server runs; Takeover while attempts remain; GiveUp after.
    #>
    param(
        [Parameter(Mandatory)][bool]$DesktopServerRunning,
        [Parameter(Mandatory)][int]$Attempt,
        [Parameter(Mandatory)][int]$MaxAttempts
    )
    if ($DesktopServerRunning) { return 'Done' }
    if ($Attempt -le $MaxAttempts) { return 'Takeover' }
    'GiveUp'
}
