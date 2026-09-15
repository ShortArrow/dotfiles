<#
.SYNOPSIS
Return PATH without the mise symlink farm directory.

.DESCRIPTION
The farm (%LocalAppData%\mise\bin) is a directory of symlinks to the real
executables. A process running under the Redirection Trust mitigation — every
child of sshd inherits it — refuses to follow a symlink owned by a non-elevated
user ("untrusted mount point"), so in such a session the farm must leave PATH
and the mise shims behind it, which are real executables, take resolution.

.PARAMETER Path
A PATH-style string (';'-separated).

.PARAMETER FarmDir
The farm directory. Compared case-insensitively, ignoring a trailing backslash.
#>
function Remove-MiseFarmFromPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Path,
        [Parameter(Mandatory)][string]$FarmDir
    )
    $farm = $FarmDir.TrimEnd('\')
    $kept = @(($Path -split ';') | Where-Object {
        -not $_.TrimEnd('\').Equals($farm, [StringComparison]::OrdinalIgnoreCase)
    })
    $kept -join ';'
}
