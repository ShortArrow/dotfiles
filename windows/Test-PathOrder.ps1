# Verify that the process PATH satisfies the partial-order rules declared
# in path-order.toml. Each rule is "<before> must come earlier than every
# entry matching <after>" (substring, case-insensitive).
#
# Designed to be sourced from windows/doctor.ps1, but can also be run
# stand-alone:
#
#     pwsh -NoProfile -File windows/Test-PathOrder.ps1
#     pwsh -NoProfile -File windows/Test-PathOrder.ps1 -RulesPath ./other.toml
#     pwsh -NoProfile -File windows/Test-PathOrder.ps1 -PathSource User
#
# Exit code: 0 if all rules pass (or no rules defined), 1 otherwise.

[CmdletBinding()]
param(
  [string]$RulesPath = "$PSScriptRoot/path-order.toml",
  [ValidateSet("Process", "User", "Machine")]
  [string]$PathSource = "Process"
)

# ---- Tiny TOML reader -------------------------------------------------------
# Parses only the subset we actually use:
#   - top-level table arrays:  [[rule]]
#   - inside each: string assignments and one-line string-array assignments.
# No nested tables, no inline tables, no multiline strings.

function Read-PathOrderRules {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "rules file not found: $Path"
  }
  $rules = @()
  $current = $null
  $sectionFor = $null

  foreach ($raw in Get-Content -LiteralPath $Path) {
    $line = $raw.Trim()
    if (-not $line -or $line.StartsWith('#')) { continue }

    if ($line -match '^\[\[(.+)\]\]$') {
      if ($current) { $rules += [pscustomobject]$current }
      $sectionFor = $matches[1].Trim()
      $current = [ordered]@{}
      continue
    }
    if ($line -match '^\[(.+)\]$') {
      # Plain section header — we don't use these but skip cleanly.
      if ($current) { $rules += [pscustomobject]$current; $current = $null }
      $sectionFor = $null
      continue
    }
    if ($null -eq $current) { continue }   # outside any [[rule]] header

    if ($line -match '^([A-Za-z0-9_-]+)\s*=\s*(.+)$') {
      $key = $matches[1]
      $val = $matches[2].Trim()
      if ($val.StartsWith('"') -and $val.EndsWith('"')) {
        $current[$key] = $val.Trim('"').Replace('\\', '\')
      }
      elseif ($val.StartsWith('[') -and $val.EndsWith(']')) {
        $items = @()
        foreach ($piece in $val.Trim('[', ']').Split(',')) {
          $piece = $piece.Trim()
          if ($piece) { $items += $piece.Trim('"').Replace('\\', '\') }
        }
        $current[$key] = $items
      }
      else {
        $current[$key] = $val
      }
    }
  }
  if ($current) { $rules += [pscustomobject]$current }
  # Drop entries that didn't get a name (defensive; shouldn't happen with
  # well-formed input, but keeps Test-PathOrderRule from blowing up).
  $filtered = @()
  foreach ($r in $rules) {
    if ($r.PSObject.Properties.Match('name').Count -gt 0) { $filtered += $r }
  }
  return ,$filtered
}

# ---- PATH source ------------------------------------------------------------

function Get-PathEntries {
  param([string]$Source)
  switch ($Source) {
    'User'    { $raw = [Environment]::GetEnvironmentVariable('Path', 'User') }
    'Machine' { $raw = [Environment]::GetEnvironmentVariable('Path', 'Machine') }
    default   { $raw = $env:PATH }
  }
  if (-not $raw) { return @() }
  $expanded = [Environment]::ExpandEnvironmentVariables($raw)
  return ($expanded -split ';') | Where-Object { $_ -and $_.Trim() }
}

# ---- Rule evaluation --------------------------------------------------------

function Find-FirstIndex {
  param([string[]]$Entries, [string]$Needle)
  for ($i = 0; $i -lt $Entries.Count; $i++) {
    if ($Entries[$i] -and $Entries[$i].IndexOf(
          $Needle, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
      return $i
    }
  }
  return -1
}

function Find-AllIndices {
  param([string[]]$Entries, [string]$Needle)
  $result = @()
  for ($i = 0; $i -lt $Entries.Count; $i++) {
    if ($Entries[$i] -and $Entries[$i].IndexOf(
          $Needle, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
      $result += $i
    }
  }
  return ,$result
}

function Test-PathOrderRule {
  param(
    [string[]]$Entries,
    [pscustomobject]$Rule
  )
  $beforeIdx = Find-FirstIndex -Entries $Entries -Needle $Rule.before
  $afterMatches = @{}
  $hasAfter = $false
  foreach ($needle in @($Rule.after)) {
    $idx = Find-FirstIndex -Entries $Entries -Needle $needle
    $afterMatches[$needle] = $idx
    if ($idx -ge 0) { $hasAfter = $true }
  }

  $status = 'ok'
  $reason = $null
  if ($beforeIdx -lt 0 -and -not $hasAfter) {
    $status = 'na'
    $reason = "neither '$($Rule.before)' nor any of [$($Rule.after -join ', ')] are present"
  }
  elseif ($beforeIdx -lt 0) {
    $status = 'fail'
    $reason = "'$($Rule.before)' is missing while one of its successors is present"
  }
  else {
    $offenders = @()
    foreach ($needle in @($Rule.after)) {
      $idx = $afterMatches[$needle]
      if ($idx -ge 0 -and $idx -lt $beforeIdx) {
        $offenders += "'$needle' at #$idx precedes '$($Rule.before)' at #$beforeIdx"
      }
    }
    if ($offenders.Count -gt 0) {
      $status = 'fail'
      $reason = $offenders -join '; '
    }
  }

  return [pscustomobject]@{
    Name      = $Rule.name
    Before    = $Rule.before
    After     = @($Rule.after)
    BeforeIdx = $beforeIdx
    Status    = $status
    Reason    = $reason
  }
}

# ---- Main -------------------------------------------------------------------

$rules = Read-PathOrderRules -Path $RulesPath
$entries = @(Get-PathEntries -Source $PathSource)

Write-Host "PATH order check ($PathSource, $($entries.Count) entries, $($rules.Count) rules)" -ForegroundColor Cyan

$failed = 0
foreach ($r in $rules) {
  $result = Test-PathOrderRule -Entries $entries -Rule $r
  switch ($result.Status) {
    'ok'   { Write-Host "- [" -NoNewline; Write-Host "OK" -ForegroundColor Green -NoNewline; Write-Host "]: $($result.Name)" }
    'na'   { Write-Host "- [" -NoNewline; Write-Host "skip" -ForegroundColor DarkGray -NoNewline; Write-Host "]: $($result.Name) ($($result.Reason))" }
    'fail' {
      Write-Host "- [" -NoNewline; Write-Host "NG" -ForegroundColor Red -NoNewline; Write-Host "]: $($result.Name)"
      Write-Host "    $($result.Reason)" -ForegroundColor Yellow
      $failed++
    }
  }
}

if ($MyInvocation.InvocationName -ne '.') {
  exit ($failed -gt 0 ? 1 : 0)
}
