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

  A tool whose entry point is a batch file — an npm package's .cmd,
  gradle's .bat — gets a one-line .cmd wrapper instead of a link (see
  MiseBinFarm.ps1): through its shim mise would run it under a PATH holding
  every install directory, past what cmd.exe accepts.

  Interpreters that locate their standard library relative to the exe are
  excluded — through a symlink they would look in the farm and find
  nothing. The rust family is excluded because ~/.cargo/bin is already on
  the persistent PATH.

  ~/.cargo/bin, which mise lists as rust's bin path, is searched last: a
  `cargo install` left there would otherwise shadow the mise-managed tool
  of the same name, while a tool only cargo installed is still linked.
#>
param(
  [string]$Farm = (Join-Path $env:LOCALAPPDATA 'mise\bin')
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/MiseBinFarm.ps1"

$exclude = @('python*', 'pip*', 'cargo*', 'rustc*', 'rustup', 'rust-*', 'rustfmt', 'clippy*', 'rls', 'rustdoc')

$cargoBin = Join-Path ($env:CARGO_HOME ?? (Join-Path $HOME '.cargo')) 'bin'
$binPaths = @(& mise bin-paths 2>$null | Sort-Object -Stable { $_ -eq $cargoBin })

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

  $target = Find-FarmTarget -Name $name -BinPath $binPaths
  if (-not $target) { continue }

  $entry = Resolve-FarmEntry -Name $name -Target $target
  if ($entry) { $wanted[$entry.File] = $entry }
}

$created = 0; $updated = 0; $pruned = 0
foreach ($entry in $wanted.Values)
{
  $path = Join-Path $Farm $entry.File
  $existing = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
  if ($existing -and (Get-FarmEntryTarget $existing) -eq $entry.Target) { continue }
  if ($existing) { Remove-Item -LiteralPath $path -Force; $updated++ } else { $created++ }
  if ($entry.Kind -eq 'Link')
  {
    New-Item -ItemType SymbolicLink -Path $path -Target $entry.Target | Out-Null
  } else
  {
    Set-Content -LiteralPath $path -Value (New-FarmWrapperText -Target $entry.Target) -Encoding ascii
  }
}

foreach ($item in Get-ChildItem -LiteralPath $Farm -File)
{
  $target = Get-FarmEntryTarget $item
  $stale = -not $wanted.ContainsKey($item.Name)
  $broken = $target -and -not (Test-Path -LiteralPath $target)
  if ($stale -or $broken)
  {
    Remove-Item -LiteralPath $item.FullName -Force
    $pruned++
  }
}

Write-Host ("farm: {0} entries ({1} created, {2} updated, {3} pruned)" -f $wanted.Count, $created, $updated, $pruned)
