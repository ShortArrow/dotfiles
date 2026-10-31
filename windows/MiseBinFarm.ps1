#!pwsh

<#
.SYNOPSIS
  What goes in the mise bin farm for one tool, and what a farm entry points at.

.DESCRIPTION
  An exe gets a symlink. A tool whose real entry point is a batch file — an
  npm package's .cmd, gradle's .bat — gets a one-line .cmd wrapper instead:
  a symlink named .exe to a batch file is rejected by the loader, and
  leaving such a tool on its shim makes mise launch it under a PATH holding
  every install directory, which cmd.exe drops once past 8191 characters.
#>

$script:FarmWrapperPattern = '^@"(?<target>[^"]+)" %\*$'

function Find-FarmTarget {
    <#
    .SYNOPSIS
      The tool's executable in the first bin path that holds one, as `mise which` picks it.

    .DESCRIPTION
      Within one bin path an .exe comes first, then the extensionless script
      npm installs, then .cmd and .bat. $null when no bin path holds the tool.
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string[]]$BinPath
    )
    foreach ($dir in $BinPath) {
        foreach ($file in "$Name.exe", $Name, "$Name.cmd", "$Name.bat") {
            $path = Join-Path $dir $file
            if (Test-Path -LiteralPath $path -PathType Leaf) { return $path }
        }
    }
    $null
}

function Resolve-FarmEntry {
    <#
    .SYNOPSIS
      The farm entry for a tool: File (name in the farm), Kind (Link or Wrapper) and Target.

    .DESCRIPTION
      Target is what `mise which` reports. An .exe is linked under the shim's
      name. A .cmd or .bat is wrapped as is; an extensionless script is
      wrapped through its sibling .cmd, else .bat. $null when cmd.exe has
      nothing to run. Target is normalized the way Windows records a link
      target, so an unchanged entry compares equal on the next sync.
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Target
    )
    $Target = [IO.Path]::GetFullPath($Target)
    $extension = [IO.Path]::GetExtension($Target)
    if ($extension -eq '.exe') {
        return [pscustomobject]@{ File = "$Name.exe"; Kind = 'Link'; Target = $Target }
    }
    $runnable = if ($extension -in '.cmd', '.bat') { $Target }
        elseif (-not $extension) {
            "$Target.cmd", "$Target.bat" | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
        }
    if (-not $runnable) { return $null }
    [pscustomobject]@{ File = "$Name.cmd"; Kind = 'Wrapper'; Target = $runnable }
}

function New-FarmWrapperText {
    <# .SYNOPSIS The wrapper's single line: run Target with every argument. #>
    param([Parameter(Mandatory)][string]$Target)
    "@`"$Target`" %*"
}

function Get-FarmEntryTarget {
    <#
    .SYNOPSIS
      What a farm entry points at: a symlink's target, or the path a wrapper runs; $null for anything else.
    #>
    param([Parameter(Mandatory)][IO.FileSystemInfo]$Item)
    if ($Item.LinkType) { return @($Item.Target)[0] }
    $line = Get-Content -LiteralPath $Item.FullName -TotalCount 1 -ErrorAction SilentlyContinue
    if ($line -match $script:FarmWrapperPattern) { return $Matches.target }
    $null
}
