#!pwsh

<#
.SYNOPSIS
  Build ~/.glzr/glazewm/config.yaml from the tracked config plus the local
  ignore list, then reload the window manager.

.DESCRIPTION
  GlazeWM reads one file. It has no include directive — user_config.rs
  deserialises a single string — so composing a config from parts has to
  happen before the window manager sees it.

  config.yaml carries everything that is shared. ignore-local.txt names the
  processes this machine should leave unmanaged, and is untracked, so the
  published config does not enumerate the applications someone runs.

  The reload is issued from here rather than from the keybinding. GlazeWM's
  shell-exec returns as soon as the process starts, so a binding that ran the
  merge and then reloaded would race its own write.

.PARAMETER Destination
  Where GlazeWM reads its config. Defaults to ~/.glzr/glazewm/config.yaml.

.PARAMETER NoReload
  Write the file without asking a running window manager to reload it.
#>
param(
  [string]$Destination = (Join-Path $env:USERPROFILE '.glzr/glazewm/config.yaml'),
  [switch]$NoReload
)

$ErrorActionPreference = 'Stop'

# This script is linked next to the generated config so the reload keybinding
# can reach it by a stable path. $PSScriptRoot resolves to the link's own
# directory, which is where the *output* lives — reading the base from there
# would feed the generated file back in. Follow the link to the repository.
$self = Get-Item -LiteralPath $PSCommandPath
while ($self.LinkType -eq 'SymbolicLink' -and $self.Target)
{
  $self = Get-Item -LiteralPath (@($self.Target)[0])
}
$sourceDir = Split-Path -Parent $self.FullName

$base = Join-Path $sourceDir 'config.yaml'
$local = Join-Path $sourceDir 'ignore-local.txt'
$marker = '# LOCAL-IGNORES'

if (-not (Test-Path -LiteralPath $base))
{
  throw "Base config not found: $base"
}

$lines = [System.IO.File]::ReadAllLines($base)
$markerIndex = [array]::FindIndex($lines, [Predicate[string]] { $args[0].Trim() -eq $marker })
if ($markerIndex -lt 0)
{
  throw "Marker '$marker' is missing from $base. Nothing would be spliced, so refusing to write a config that silently drops the local ignores."
}

# Match the marker's own indentation so the generated entries stay in the
# sequence they are joining.
$indent = ($lines[$markerIndex] -replace '\S.*$', '')

$processes = @()
if (Test-Path -LiteralPath $local)
{
  $processes = Get-Content -LiteralPath $local |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') }
}

$generated = $processes | ForEach-Object { "$indent- window_process: { equals: '$_' }" }

$output = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $lines.Count; $i++)
{
  if ($i -eq $markerIndex)
  {
    $generated | ForEach-Object { $output.Add($_) }
  } else
  {
    $output.Add($lines[$i])
  }
}

$parent = Split-Path -Parent $Destination
if ($parent -and -not (Test-Path -LiteralPath $parent))
{
  New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

# The destination was a symlink into the repository before the config was
# split. Writing through it would put the generated result back into git.
$existing = Get-Item -LiteralPath $Destination -ErrorAction SilentlyContinue
if ($existing -and $existing.LinkType)
{
  Remove-Item -LiteralPath $Destination -Force
}

[System.IO.File]::WriteAllLines($Destination, $output)
Write-Host "wrote $Destination ($($processes.Count) local ignore$(if ($processes.Count -ne 1) { 's' }))"

if (-not $NoReload)
{
  if (Get-Command glazewm -ErrorAction SilentlyContinue)
  {
    # Fails when the window manager is not running, which is not an error here.
    try
    {
      glazewm command wm-reload-config 2>&1 | Out-Null
      Write-Host "reloaded"
    } catch
    {
      Write-Host "not reloaded (GlazeWM does not appear to be running)"
    }
  }
}
