#!pwsh

<#
.SYNOPSIS
  Install the listed Windows applications on a fresh machine.

.DESCRIPTION
  These files are a list to reinstall from, not a description of the
  machine. `winget import` installs what they name and removes nothing, so
  a package installed by hand stays installed and stays off the list.
  Running this on an established machine is a no-op for everything already
  present.

  public_usecase.txt holds the work and development environment.
  private_usecase.txt holds hobby and personal apps only. The two sets are
  disjoint, so a work machine runs this without -IncludePrivate and gets
  none of the second file.

.PARAMETER IncludePrivate
  Also import private_usecase.txt.
#>
param([switch]$IncludePrivate)

$ErrorActionPreference = 'Stop'

$manifests = @("$PSScriptRoot/public_usecase.txt")
if ($IncludePrivate) { $manifests += "$PSScriptRoot/private_usecase.txt" }

foreach ($manifest in $manifests) {
  Write-Host -ForegroundColor Cyan "Importing $(Split-Path -Leaf $manifest)"
  winget import --import-file $manifest `
    --accept-package-agreements --accept-source-agreements --ignore-unavailable
}
