#!pwsh

<#
.SYNOPSIS
  Start Zebar with its stderr written to a file, so a panic leaves its message
  and backtrace behind.

.DESCRIPTION
  A release build of Zebar has no console and installs no panic hook, so a
  panic message goes to stderr and is lost. This starts it with
  RUST_BACKTRACE=1, stderr redirected to ~/.glzr/zebar/stderr.log, and
  stdout discarded, since stdout carries the full tracing log.

  The previous run's log is kept as stderr.prev.log, so a restart after a
  freeze does not overwrite the evidence.

  glazewm runs this through shell-exec at startup. Switch-ZebarPack starts
  zebar.exe directly through explorer.exe, so a Zebar it starts keeps no
  stderr log. Zebar inherits the elevation of whoever starts this script.

.PARAMETER Executable
  zebar.exe to start. Defaults to the installed one.
#>
param(
  [string]$Executable = (Join-Path $env:ProgramFiles 'glzr.io/Zebar/zebar.exe')
)

function Move-ZebarStderrLog {
  <#
  .SYNOPSIS
    Move the log at Path to stderr.prev.log in the same directory, replacing
    the one before it. Does nothing when Path does not exist.
  #>
  param(
    [Parameter(Mandatory)][string]$Path
  )
  if (-not (Test-Path -LiteralPath $Path)) { return }
  $previous = Join-Path (Split-Path -Parent $Path) 'stderr.prev.log'
  Move-Item -LiteralPath $Path -Destination $previous -Force
}

function Get-ZebarStartArgument {
  <#
  .SYNOPSIS
    Start-Process parameters that run Executable hidden, with stderr written
    to LogPath and stdout discarded.
  #>
  param(
    [Parameter(Mandatory)][string]$Executable,
    [Parameter(Mandatory)][string]$LogPath
  )
  @{
    FilePath = $Executable
    RedirectStandardError = $LogPath
    RedirectStandardOutput = 'NUL'
    WindowStyle = 'Hidden'
  }
}

if ($MyInvocation.InvocationName -eq '.') { return }

$ErrorActionPreference = 'Stop'
$log = Join-Path $env:USERPROFILE '.glzr/zebar/stderr.log'
Move-ZebarStderrLog -Path $log
$env:RUST_BACKTRACE = '1'
$arguments = Get-ZebarStartArgument -Executable $Executable -LogPath $log
Start-Process @arguments
