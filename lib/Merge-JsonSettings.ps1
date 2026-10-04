#!pwsh

<#
.SYNOPSIS
Overlay a repository's sample JSON onto a machine's settings file.

.DESCRIPTION
For applications whose settings file mixes what this repository shares with
what one machine accumulates on its own — Claude Code's permission entries,
Windows Terminal's generated profiles — the file is not a symlink. Only the
keys the sample declares travel, and they travel by being merged in rather
than by replacing the file.

A key the sample declares wins — that is what makes the sample the source of
truth. A key it says nothing about is left alone. A protected key is refused
even when the sample carries one, for a key whose shared value would hand
every machine the state of whichever machine wrote it last.

The merge reaches one level below the top. Where both sides hold an object
under a key, each child key the sample declares replaces its counterpart and
the rest are kept, so a sample can own `profiles.defaults` without touching
`profiles.list`. Below that, values replace wholesale rather than merging
element by element: a hook the repository has retired should disappear on the
next apply, and a half-merged array would be neither the old behaviour nor the
new one.
#>

Set-StrictMode -Version Latest

function ConvertTo-HashtableDeep
{
  param([Parameter(Mandatory)][AllowNull()]$InputObject)

  if ($null -eq $InputObject) { return $null }

  if ($InputObject -is [System.Collections.IDictionary])
  {
    $copy = @{}
    foreach ($key in $InputObject.Keys)
    {
      $copy[$key] = ConvertTo-HashtableDeep -InputObject $InputObject[$key]
    }
    return $copy
  }

  if ($InputObject -is [System.Management.Automation.PSCustomObject])
  {
    $copy = @{}
    foreach ($prop in $InputObject.PSObject.Properties)
    {
      $copy[$prop.Name] = ConvertTo-HashtableDeep -InputObject $prop.Value
    }
    return $copy
  }

  if ($InputObject -is [string]) { return $InputObject }

  if ($InputObject -is [System.Collections.IEnumerable])
  {
    # `return @(...)` would unwrap a one-element array back into its element,
    # turning a single-entry hooks list into the hook itself. Build the array
    # and hand it back through the pipeline-free comma operator instead.
    $items = [System.Collections.ArrayList]::new()
    foreach ($item in $InputObject)
    {
      [void]$items.Add((ConvertTo-HashtableDeep -InputObject $item))
    }
    return ,$items.ToArray()
  }

  return $InputObject
}

function ConvertTo-CanonicalJson
{
  <#
  .SYNOPSIS
  Render settings as JSON with object keys sorted, so two structurally equal
  settings compare equal as text.

  .DESCRIPTION
  Hashtables hand their keys back in whatever order the runtime chose, so a
  merge that changed nothing still serialises differently from the file it
  came from. Sorting the keys makes "did this apply change anything?" a string
  comparison. Array order is preserved — a hooks list is a sequence, and
  reordering it changes which hook runs first.
  #>
  param([Parameter(Mandatory)][AllowNull()]$InputObject)

  $canonical = ConvertTo-SortedKeys -InputObject (ConvertTo-HashtableDeep -InputObject $InputObject)
  return ($canonical | ConvertTo-Json -Depth 20 -Compress)
}

function ConvertTo-SortedKeys
{
  param([Parameter(Mandatory)][AllowNull()]$InputObject)

  if ($InputObject -is [System.Collections.IDictionary])
  {
    $sorted = [ordered]@{}
    foreach ($key in ($InputObject.Keys | Sort-Object))
    {
      $sorted[$key] = ConvertTo-SortedKeys -InputObject $InputObject[$key]
    }
    return $sorted
  }

  if (($InputObject -isnot [string]) -and ($InputObject -is [System.Collections.IEnumerable]))
  {
    $items = [System.Collections.ArrayList]::new()
    foreach ($item in $InputObject)
    {
      [void]$items.Add((ConvertTo-SortedKeys -InputObject $item))
    }
    return ,$items.ToArray()
  }

  return $InputObject
}

function Merge-JsonSettings
{
  param(
    [Parameter(Mandatory)][AllowNull()]$Current,
    [Parameter(Mandatory)][AllowNull()]$Sample,
    [string[]]$ProtectedKeys = @()
  )

  $merged = ConvertTo-HashtableDeep -InputObject $Current
  if ($null -eq $merged) { $merged = @{} }

  $incoming = ConvertTo-HashtableDeep -InputObject $Sample
  if ($null -eq $incoming) { return $merged }

  foreach ($key in $incoming.Keys)
  {
    if ($ProtectedKeys -contains $key) { continue }

    $value = $incoming[$key]
    $existing = if ($merged.ContainsKey($key)) { $merged[$key] } else { $null }

    $bothAreMaps = ($value -is [System.Collections.IDictionary]) -and
                   ($existing -is [System.Collections.IDictionary])

    if ($bothAreMaps)
    {
      foreach ($childKey in $value.Keys)
      {
        $existing[$childKey] = $value[$childKey]
      }
    }
    else
    {
      $merged[$key] = $value
    }
  }

  return $merged
}

function Convert-SettingsLinkToFile
{
  <#
  .SYNOPSIS
  Replace a settings symlink with a regular file holding the same content.

  .DESCRIPTION
  For a tool that moves from linking its settings file to merging into it.
  Merged into through the link, the repository's file would receive the
  machine's state. The link's target is left in place. A link whose target
  no longer exists — the repository stopped carrying the linked file — is
  replaced by FallbackContent. A regular file and a missing path are left
  alone.

  .OUTPUTS
  'converted' or 'noop'.
  #>
  param(
    [Parameter(Mandatory)][string]$Path,
    [Parameter(Mandatory)][AllowEmptyString()][string]$FallbackContent
  )

  $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
  if ($null -eq $item -or -not $item.LinkType) { return 'noop' }

  $target = @($item.Target)[0]
  if (-not [IO.Path]::IsPathRooted($target)) { $target = Join-Path (Split-Path -Parent $Path) $target }
  $content = if (Test-Path -LiteralPath $target -PathType Leaf) {
    Get-Content -LiteralPath $target -Raw
  } else {
    $FallbackContent
  }

  Remove-Item -LiteralPath $Path -Force
  Set-Content -LiteralPath $Path -Value $content -NoNewline -Encoding UTF8
  return 'converted'
}

function Update-JsonSettingsFile
{
  <#
  .SYNOPSIS
  Merge a sample JSON file into a settings file, writing only when it changes.

  .DESCRIPTION
  A settings file that the merge leaves structurally equal is not rewritten,
  so re-running a setup is a no-op. Before a rewrite the previous file is
  copied to <path>.bak.<timestamp>; the backup is never deleted. A missing
  settings file and its directory are created. The caller must have
  dot-sourced lib/_lib.ps1 for the Write-Dotfile* messages.

  .OUTPUTS
  'noop' or 'merged'.
  #>
  param(
    [Parameter(Mandatory)][string]$SettingsPath,
    [Parameter(Mandatory)][string]$SamplePath,
    [string[]]$ProtectedKeys = @()
  )

  $sample = Get-Content -LiteralPath $SamplePath -Raw | ConvertFrom-Json
  $current = if (Test-Path -LiteralPath $SettingsPath) {
    Get-Content -LiteralPath $SettingsPath -Raw | ConvertFrom-Json
  } else {
    $null
  }

  $merged = Merge-JsonSettings -Current $current -Sample $sample -ProtectedKeys $ProtectedKeys

  $unchanged = ($null -ne $current) -and
               ((ConvertTo-CanonicalJson -InputObject $current) -eq
                (ConvertTo-CanonicalJson -InputObject $merged))
  if ($unchanged) {
    Write-DotfileOk "noop  $SettingsPath"
    return 'noop'
  }

  if (Test-Path -LiteralPath $SettingsPath) {
    $bak = "$SettingsPath.bak.$(Get-Date -Format yyyyMMddHHmmss)"
    Copy-Item -LiteralPath $SettingsPath -Destination $bak
    Write-DotfileWarn "backup $SettingsPath -> $bak"
  }
  $parent = Split-Path -Parent $SettingsPath
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  Set-Content -LiteralPath $SettingsPath -Value ($merged | ConvertTo-Json -Depth 20) -Encoding UTF8
  Write-DotfileOk "merged $SettingsPath"
  return 'merged'
}
