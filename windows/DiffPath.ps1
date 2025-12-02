#!pwsh
param(
  [ValidateSet("env", "resolve")]
  [string]$Mode = "env"
)

$PathRegistryLocation = "HKCU:\Environment"
$DesiredRaw = Get-Content -Path "$PSScriptRoot/PATH.txt"
$CurrentPathEntry = Get-ItemProperty -Path $PathRegistryLocation -Name Path
$CurrentRaw = $CurrentPathEntry.Path -split ";"

function Get-EnvMap {
  # Sort by value length so the longest match is picked first when normalizing.
  Get-ChildItem Env: |
    Where-Object { $_.Value } |
    Sort-Object { $_.Value.Length } -Descending
}

function Normalize-ToResolve {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
  $Expanded = [Environment]::ExpandEnvironmentVariables($Path.Trim())
  $Resolved = Resolve-Path -LiteralPath $Expanded -ErrorAction SilentlyContinue
  $Candidate = if ($Resolved) { $Resolved.ProviderPath } else { $Expanded }
  return $Candidate.TrimEnd('\', '/').ToLowerInvariant()
}

function Normalize-ToEnvPlaceholder {
  param(
    [string]$Path,
    [System.Collections.IEnumerable]$EnvMap
  )
  if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
  $Expanded = [Environment]::ExpandEnvironmentVariables($Path.Trim())
  foreach ($Item in $EnvMap) {
    $Value = $Item.Value
    if (-not $Value) { continue }
    if ($Expanded.StartsWith($Value, [System.StringComparison]::OrdinalIgnoreCase)) {
      $Suffix = $Expanded.Substring($Value.Length).TrimStart('\', '/')
      $Prefix = "%$($Item.Name)%"
      $Candidate = if ($Suffix) { "$Prefix\$Suffix" } else { $Prefix }
      return $Candidate.TrimEnd('\', '/').ToLowerInvariant()
    }
  }
  return $Expanded.TrimEnd('\', '/').ToLowerInvariant()
}

$EnvMap = Get-EnvMap

if ($Mode -eq "resolve") {
  $Desired = $DesiredRaw | ForEach-Object { Normalize-ToResolve $_ } | Where-Object { $_ }
  $Current = $CurrentRaw | ForEach-Object { Normalize-ToResolve $_ } | Where-Object { $_ }
} else {
  $Desired = $DesiredRaw | ForEach-Object { Normalize-ToEnvPlaceholder $_ $EnvMap } | Where-Object { $_ }
  $Current = $CurrentRaw | ForEach-Object { Normalize-ToEnvPlaceholder $_ $EnvMap } | Where-Object { $_ }
}

$Missing = $Desired | Where-Object { $_ -notin $Current }
$Extra = $Current | Where-Object { $_ -notin $Desired }

Write-Host -ForegroundColor Yellow "Mode: $Mode"
Write-Host -ForegroundColor Yellow "Desired entries: $($Desired.Count); Current entries: $($Current.Count)"

if ($Missing.Count -eq 0 -and $Extra.Count -eq 0) {
  Write-Host -ForegroundColor Green "PATH matches PATH.txt under '$Mode' normalization."
  exit 0
}

if ($Missing.Count -gt 0) {
  Write-Host -ForegroundColor Red "Missing (present in PATH.txt, absent in current PATH):"
  $Missing | ForEach-Object { Write-Host "  $_" }
}

if ($Extra.Count -gt 0) {
  Write-Host -ForegroundColor Cyan "Extra (present in current PATH, absent in PATH.txt):"
  $Extra | ForEach-Object { Write-Host "  $_" }
}
