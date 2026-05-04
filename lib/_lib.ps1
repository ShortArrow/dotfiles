# dotfiles common library (PowerShell).
#
# Sourced by every <tool>/setup.ps1 to share symlink/log/parser logic.
# Requires PowerShell 5.1+ (no class syntax, no PS7-only cmdlets).
#
# Public surface:
#   Write-DotfileInfo / Warn / Error
#   Test-WindowsSymlinkCapable
#   Expand-DotfileVars      [-Path] <string>
#   New-DotfileSymlink      [-Source] <string> [-Destination] <string>
#   Read-DotfileRegistry    [-Path] <string>
#   Set-DotfileLinks    [-ToolName] <string> [-DotfilesRoot] <string>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:DotfileLibVersion = '1'

function Write-DotfileInfo  { param([Parameter(Mandatory)][string]$Message) Write-Host "==> $Message" -ForegroundColor Cyan }
function Write-DotfileOk    { param([Parameter(Mandatory)][string]$Message) Write-Host "    $Message" -ForegroundColor Green }
function Write-DotfileWarn  { param([Parameter(Mandatory)][string]$Message) Write-Host "    $Message" -ForegroundColor Yellow }
function Write-DotfileError { param([Parameter(Mandatory)][string]$Message) Write-Host "!!! $Message" -ForegroundColor Red }

function Test-WindowsSymlinkCapable {
  $devModeKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
  $devModeOn = $false
  if (Test-Path $devModeKey) {
    $value = Get-ItemProperty -Path $devModeKey -Name 'AllowDevelopmentWithoutDevLicense' -ErrorAction SilentlyContinue
    if ($value -and $value.AllowDevelopmentWithoutDevLicense -eq 1) { $devModeOn = $true }
  }
  $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  if (-not $devModeOn -and -not $isAdmin) {
    Write-DotfileWarn 'Symlink creation may fail: Developer Mode off and not running as Administrator.'
    Write-DotfileWarn 'Enable: Settings > Privacy & security > For developers > Developer Mode'
    return $false
  }
  return $true
}

function Expand-DotfileVars {
  param([Parameter(Mandatory)][string]$Path)

  $homeDir = $env:USERPROFILE
  if (-not $homeDir) { $homeDir = $env:HOME }
  $xdg = $env:XDG_CONFIG_HOME
  if (-not $xdg) { $xdg = Join-Path $homeDir '.config' }

  $expanded = $Path
  $replacements = [ordered]@{
    '$HOME'            = $homeDir
    '$USERPROFILE'     = $env:USERPROFILE
    '$APPDATA'         = $env:APPDATA
    '$LOCALAPPDATA'    = $env:LOCALAPPDATA
    '$XDG_CONFIG_HOME' = $xdg
  }
  foreach ($kv in $replacements.GetEnumerator()) {
    if ($null -ne $kv.Value -and $kv.Value -ne '') {
      $expanded = $expanded.Replace($kv.Key, $kv.Value)
    }
  }

  if ($expanded.StartsWith('~/') -or $expanded.StartsWith('~\')) {
    $expanded = Join-Path $homeDir $expanded.Substring(2)
  } elseif ($expanded -eq '~') {
    $expanded = $homeDir
  }

  return $expanded
}

function New-DotfileSymlink {
  param(
    [Parameter(Mandatory)][string]$Source,
    [Parameter(Mandatory)][string]$Destination
  )

  if (-not (Test-Path -LiteralPath $Source)) {
    throw "source does not exist: $Source"
  }

  $parent = Split-Path -Parent $Destination
  if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  if (Test-Path -LiteralPath $Destination) {
    $item = Get-Item -LiteralPath $Destination -Force
    $isReparse = ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
    if ($isReparse) {
      $existingTarget = $null
      try { $existingTarget = $item.Target } catch {}
      if ($existingTarget) {
        $sourceFull = (Resolve-Path -LiteralPath $Source).Path
        $existingFull = $existingTarget
        try { $existingFull = (Resolve-Path -LiteralPath $existingTarget -ErrorAction Stop).Path } catch {}
        if ($existingFull -and ([IO.Path]::GetFullPath($existingFull) -ieq [IO.Path]::GetFullPath($sourceFull))) {
          Write-DotfileOk "noop  $Destination"
          return 'noop'
        }
      }
      Remove-Item -LiteralPath $Destination -Force -Recurse
      $action = 'replaced'
    } else {
      $bak = "$Destination.bak.$(Get-Date -Format yyyyMMddHHmmss)"
      Move-Item -LiteralPath $Destination -Destination $bak
      Write-DotfileWarn "backup $Destination -> $bak"
      $action = 'replaced'
    }
  } else {
    $action = 'created'
  }

  $sourceItem = Get-Item -LiteralPath $Source -Force
  if ($sourceItem.PSIsContainer) {
    New-Item -ItemType SymbolicLink -Path $Destination -Value $Source | Out-Null
  } else {
    New-Item -ItemType SymbolicLink -Path $Destination -Value $Source | Out-Null
  }
  Write-DotfileOk "$action $Destination -> $Source"
  return $action
}

function Read-DotfileRegistry {
  param([Parameter(Mandatory)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    throw "dotfm.toml not found: $Path"
  }

  $tools = @{}                          # name -> @{ platforms; links = @() }
  $currentTool = $null
  $currentLink = $null

  foreach ($rawLine in Get-Content -LiteralPath $Path -Encoding UTF8) {
    $line = $rawLine
    # strip comment
    if ($line -match '^\s*#') { continue }
    $line = $line -replace '\s+#.*$', ''
    $line = $line.Trim()
    if (-not $line) { continue }

    if ($line -match '^\[\[tools\.([^\.\]]+)\.links\]\]$') {
      $currentTool = $Matches[1]
      if (-not $tools.ContainsKey($currentTool)) {
        $tools[$currentTool] = @{ platforms = @(); links = @() }
      }
      $currentLink = @{ src = $null; src_kind = 'path'; src_dir = $null; include = @(); dst = @{} }
      $tools[$currentTool].links += ,$currentLink
      continue
    }
    if ($line -match '^\[tools\.([^\.\]]+)\]$') {
      $currentTool = $Matches[1]
      if (-not $tools.ContainsKey($currentTool)) {
        $tools[$currentTool] = @{ platforms = @(); links = @() }
      }
      $currentLink = $null
      continue
    }
    if ($line -match '^\[tools\.([^\.\]]+)\.(post_apply|script|doctor)') {
      # we ignore these sections for symlink replay
      $currentLink = $null
      continue
    }
    if ($line -match '^\[\[tools\.([^\.\]]+)\.post_apply\]\]$') {
      $currentLink = $null
      continue
    }

    if ($null -eq $currentTool) { continue }

    # platforms = ["windows", "linux"]
    if ($null -eq $currentLink -and $line -match '^platforms\s*=\s*\[(.*)\]$') {
      $vals = ($Matches[1] -split ',') | ForEach-Object { $_.Trim().Trim('"').Trim("'") } | Where-Object { $_ }
      $tools[$currentTool].platforms = @($vals)
      continue
    }

    if ($null -eq $currentLink) { continue }

    # src = "..."  (string form)
    if ($line -match '^src\s*=\s*"(.*)"$') {
      $currentLink.src = $Matches[1]
      $currentLink.src_kind = 'path'
      continue
    }
    # src = { dir = "...", include = [ "a", "b" ] }
    if ($line -match '^src\s*=\s*\{(.+)\}$') {
      $inner = $Matches[1]
      if ($inner -match 'dir\s*=\s*"([^"]+)"') {
        $currentLink.src_dir = $Matches[1]
      }
      if ($inner -match 'include\s*=\s*\[(.*)\]') {
        $items = ($Matches[1] -split ',') | ForEach-Object { $_.Trim().Trim('"').Trim("'") } | Where-Object { $_ }
        $currentLink.include = @($items)
      }
      $currentLink.src_kind = 'expand'
      continue
    }
    # dst.windows = "..."
    if ($line -match '^dst\.(windows|linux|macos)\s*=\s*"(.*)"$') {
      $currentLink.dst[$Matches[1]] = $Matches[2]
      continue
    }

    throw "dotfm.toml: cannot parse line for tool '$currentTool': $rawLine"
  }

  return $tools
}

function Set-DotfileLinks {
  param(
    [Parameter(Mandatory)][string]$ToolName,
    [string]$DotfilesRoot
  )

  if (-not $DotfilesRoot) {
    $DotfilesRoot = Split-Path -Parent $PSScriptRoot
  }
  $tomlPath = Join-Path $DotfilesRoot 'dotfm.toml'

  $tools = Read-DotfileRegistry -Path $tomlPath
  if (-not $tools.ContainsKey($ToolName)) {
    throw "tool '$ToolName' not found in $tomlPath"
  }

  $tool = $tools[$ToolName]
  if ($tool.platforms -and ($tool.platforms.Count -gt 0) -and ($tool.platforms -notcontains 'windows')) {
    Write-DotfileWarn "tool '$ToolName' is not for Windows (platforms: $($tool.platforms -join ', ')); skipping."
    return
  }

  if (-not (Test-WindowsSymlinkCapable)) {
    Write-DotfileWarn 'continuing without elevated privileges (may fail).'
  }

  Write-DotfileInfo "set $ToolName"

  foreach ($link in $tool.links) {
    $dstTemplate = $link.dst['windows']
    if (-not $dstTemplate) {
      # link is declared for another OS (e.g. dst.linux only); skip silently.
      continue
    }
    $dst = Expand-DotfileVars -Path $dstTemplate

    if ($link.src_kind -eq 'path') {
      $srcAbs = Join-Path $DotfilesRoot $link.src
      New-DotfileSymlink -Source $srcAbs -Destination $dst | Out-Null
    } elseif ($link.src_kind -eq 'expand') {
      $srcDirAbs = Join-Path $DotfilesRoot $link.src_dir
      foreach ($name in $link.include) {
        $srcAbs = Join-Path $srcDirAbs $name
        $dstChild = Join-Path $dst $name
        New-DotfileSymlink -Source $srcAbs -Destination $dstChild | Out-Null
      }
    }
  }
}
