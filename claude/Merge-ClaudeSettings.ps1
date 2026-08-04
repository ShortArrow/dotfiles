#!pwsh

<#
.SYNOPSIS
Overlay the shared Claude Code settings onto a machine's settings.json.

.DESCRIPTION
settings.json is not a symlink: it accumulates permission entries that belong
to one machine and nowhere else. Only the keys this repository declares travel,
and they travel by being merged in rather than by replacing the file.

A key the sample declares wins — that is what makes the sample the source of
truth for attribution and hooks. A key it says nothing about is left alone, so
`permissions` and any local `model` survive the merge. `permissions` is refused
outright even when the sample carries one, because a shared allowlist would
hand every machine the rules of whichever machine wrote it last.

The merge is one level deep. Nested values (a hooks event, an attribution
field) replace wholesale rather than merging element by element: a hook the
repository has retired should disappear on the next apply, and a half-merged
hook array would be neither the old behaviour nor the new one.
#>

Set-StrictMode -Version Latest

$script:ProtectedKeys = @('permissions')

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

function Merge-ClaudeSettings
{
  param(
    [Parameter(Mandatory)][AllowNull()]$Current,
    [Parameter(Mandatory)][AllowNull()]$Sample
  )

  $merged = ConvertTo-HashtableDeep -InputObject $Current
  if ($null -eq $merged) { $merged = @{} }

  $incoming = ConvertTo-HashtableDeep -InputObject $Sample
  if ($null -eq $incoming) { return $merged }

  foreach ($key in $incoming.Keys)
  {
    if ($script:ProtectedKeys -contains $key) { continue }

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
