#!pwsh

<#
.SYNOPSIS
  Point Zebar's overline-zebar pack at another checkout, such as a development
  worktree, and restart Zebar so it loads it.

.DESCRIPTION
  dotfm links ~/.glzr/zebar/overline-zebar to this repository's submodule.
  While a feature is under development the host should run the worktree's
  build instead, without committing anything here. This replaces only that
  link and restarts Zebar, which reads widget packs at startup.

  Run without -Target to go back to the submodule. Creating a symbolic link
  needs Developer Mode or an elevated shell.

  The run is logged to Switch-ZebarPack.log under $env:TEMP, so the outcome
  can be read even when it was started through sudo in another window.

.PARAMETER Target
  The checkout to load. Defaults to the submodule next to this script.
#>
param(
  [string]$Target = (Join-Path $PSScriptRoot 'overline-zebar')
)

function Set-ZebarPackLink {
  <#
  .SYNOPSIS
    Replace the pack link with one to Target and return where it pointed
    before and after.

  .DESCRIPTION
    Only a symbolic link is replaced, so a pack copied in as a real directory
    is never deleted. A missing Target leaves the current link in place.
  #>
  param(
    [Parameter(Mandatory)][string]$Link,
    [Parameter(Mandatory)][string]$Target
  )
  $item = Get-Item -LiteralPath $Link -Force
  if ($item.LinkType -ne 'SymbolicLink') { throw "$Link is not a symbolic link" }
  if (-not (Test-Path -LiteralPath $Target -PathType Container)) { throw "$Target does not exist" }

  $before = @($item.Target)[0]
  $item.Delete()
  New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
  [pscustomobject]@{
    Before = $before
    After = @((Get-Item -LiteralPath $Link -Force).Target)[0]
  }
}

if ($MyInvocation.InvocationName -eq '.') { return }

$ErrorActionPreference = 'Stop'
Start-Transcript -Path (Join-Path $env:TEMP 'Switch-ZebarPack.log') -Force | Out-Null
try {
  $zebar = Get-Process zebar -ErrorAction SilentlyContinue
  $executable = $zebar | Select-Object -First 1 -ExpandProperty Path
  if (-not $executable) { $executable = Join-Path $env:ProgramFiles 'glzr.io/Zebar/zebar.exe' }

  $zebar | Stop-Process -Force
  $zebar | Wait-Process -Timeout 10 -ErrorAction SilentlyContinue

  $link = Join-Path $env:USERPROFILE '.glzr/zebar/overline-zebar'
  $result = Set-ZebarPackLink -Link $link -Target $Target
  "before: $($result.Before)"
  "after:  $($result.After)"

  Start-Process $executable
} finally {
  Stop-Transcript | Out-Null
}
