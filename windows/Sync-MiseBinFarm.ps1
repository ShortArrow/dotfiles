#!pwsh

<#
.SYNOPSIS
  Rebuild %LocalAppData%\mise\bin — symlinks to the real executables of
  mise-managed tools.

.DESCRIPTION
  A mise shim launches mise, which resolves the tool and launches it: three
  processes for one command. Under a managed AV that taxes every process
  creation ~150 ms, a 15 ms tool costs 170 ms through its shim — and the
  extra console middleman can also swallow pager exits, leaving bat unable
  to return to the prompt.

  A symlink launches the real executable directly. One process, 15 ms, and
  one 44-character PATH entry instead of twenty install directories, which
  is what keeps cmd.exe's 8191-character expansion under budget where
  `mise activate` would not.

  The cost is freshness: an upgrade moves the versioned install directory
  and strands the link. Run this after `mise install`/`mise up`; the doctor
  reports stranded links.

  Interpreters that locate their standard library relative to the exe are
  excluded — through a symlink they would look in the farm and find
  nothing. The rust family is excluded because ~/.cargo/bin is already on
  the persistent PATH.
#>
param(
  [string]$Farm = (Join-Path $env:LOCALAPPDATA 'mise\bin')
)

$ErrorActionPreference = 'Stop'

$exclude = @('python*', 'pip*', 'cargo*', 'rustc*', 'rustup', 'rust-*', 'rustfmt', 'clippy*', 'rls', 'rustdoc')

$shims = Join-Path $env:LOCALAPPDATA 'mise\shims'
if (-not (Test-Path -LiteralPath $shims))
{
  throw "mise shims directory not found: $shims"
}

New-Item -ItemType Directory -Path $Farm -Force | Out-Null

$wanted = @{}
foreach ($shim in Get-ChildItem -LiteralPath $shims -Filter '*.exe')
{
  $name = $shim.BaseName
  if ($exclude | Where-Object { $name -like $_ }) { continue }

  $target = & mise which $name 2>$null
  if (-not $target -or -not (Test-Path -LiteralPath $target)) { continue }

  # The link carries the shim's .exe name. A target that is not itself a PE
  # (npm.cmd, a bare script) would produce an npm.exe that the loader
  # rejects — those tools stay on their shims.
  if ([IO.Path]::GetExtension($target) -ne '.exe') { continue }

  $wanted[$shim.Name] = $target
}

$created = 0; $updated = 0; $pruned = 0
foreach ($entry in $wanted.GetEnumerator())
{
  $link = Join-Path $Farm $entry.Key
  $existing = Get-Item -LiteralPath $link -ErrorAction SilentlyContinue
  if ($existing -and @($existing.Target)[0] -eq $entry.Value) { continue }
  if ($existing) { Remove-Item -LiteralPath $link -Force; $updated++ } else { $created++ }
  New-Item -ItemType SymbolicLink -Path $link -Target $entry.Value | Out-Null
}

foreach ($link in Get-ChildItem -LiteralPath $Farm -File)
{
  $stale = -not $wanted.ContainsKey($link.Name)
  $broken = $link.LinkType -and -not (Test-Path -LiteralPath (@($link.Target)[0]))
  if ($stale -or $broken)
  {
    Remove-Item -LiteralPath $link.FullName -Force
    $pruned++
  }
}

Write-Host ("farm: {0} links ({1} created, {2} updated, {3} pruned)" -f $wanted.Count, $created, $updated, $pruned)
