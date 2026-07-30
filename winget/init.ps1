#!pwsh

<#
.SYNOPSIS
  Install the winget-managed packages for this machine.

.DESCRIPTION
  winget covers what mise cannot: GUI applications, OS integration,
  compilers and SDKs. Everything mise has a backend for is declared in
  mise/src/config.toml instead.

  public_usecase.txt holds the work and development environment.
  private_usecase.txt holds hobby and personal apps only. The two sets are
  disjoint, so a private machine imports both manifests rather than
  maintaining an overlapping list.

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
