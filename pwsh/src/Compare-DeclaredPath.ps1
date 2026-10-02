<#
.SYNOPSIS
Compare a declared PATH (windows/PATH.txt, SYSTEM_PATH.txt) with an actual one.

.DESCRIPTION
Installers rewrite the registry PATH on their own; some replace it outright
with their single entry. Missing lists declared entries absent from the
actual PATH, in their declared spelling; Undeclared lists actual entries the
declaration does not name, in their actual spelling. Entries are equal when
they match after environment-variable expansion, ignoring case and a trailing
backslash. Order and blank entries are not compared.

.PARAMETER Declared
One entry per element, as read from the declaration file.

.PARAMETER Actual
A PATH-style string (';'-separated), unexpanded as stored in the registry.
#>
function Compare-DeclaredPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][AllowEmptyCollection()][string[]]$Declared,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Actual
    )
    $key = { param($entry) [Environment]::ExpandEnvironmentVariables($entry.Trim()).TrimEnd('\').ToLowerInvariant() }
    $declaredEntries = @($Declared | Where-Object { $_ -and $_.Trim() })
    $actualEntries = @(($Actual -split ';') | Where-Object { $_ -and $_.Trim() })
    $declaredKeys = [Collections.Generic.HashSet[string]]::new([string[]]@($declaredEntries | ForEach-Object { & $key $_ }))
    $actualKeys = [Collections.Generic.HashSet[string]]::new([string[]]@($actualEntries | ForEach-Object { & $key $_ }))
    [pscustomobject]@{
        Missing    = @($declaredEntries | Where-Object { -not $actualKeys.Contains((& $key $_)) })
        Undeclared = @($actualEntries | Where-Object { -not $declaredKeys.Contains((& $key $_)) })
    }
}
