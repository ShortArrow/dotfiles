#!pwsh

$script:WinGetPickScript = $PSCommandPath

function ConvertTo-WinGetPickLine {
    <#
    .SYNOPSIS
      Turn a Find-WinGetPackage result into one fzf line: "<Id>`t<Name> [<Version>]".

    .DESCRIPTION
      The Id comes first and alone before the tab, so fzf's {1} and
      ConvertFrom-WinGetPickLine both read it without parsing the name.
    #>
    param([Parameter(Mandatory)]$Package)
    "$($Package.Id)`t$($Package.Name) [$($Package.Version)]"
}

function ConvertFrom-WinGetPickLine {
    <#
    .SYNOPSIS
      Take the package Id off a picked line; $null for the empty line fzf returns on cancel.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$PickedLine)
    if ([string]::IsNullOrWhiteSpace($PickedLine)) { return $null }
    ($PickedLine -split "`t")[0].Trim()
}

function Test-WinGetPackageId {
    <#
    .SYNOPSIS
      True when Id is dot-separated runs of word characters, '+' and '-'.

    .DESCRIPTION
      An Id is spliced into a cmd command line and a cache file name, so
      anything else — quotes, '&', '%', path separators, '..' — is refused
      rather than escaped. Every Id winget's own sources serve fits.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Id)
    $Id -match '^[\w+-]+(\.[\w+-]+)*$'
}

function Show-WinGetPreview {
    <#
    .SYNOPSIS
      Print `winget show` for a package, from CacheDir when it has been shown before.

    .DESCRIPTION
      fzf kills the preview process each time the cursor moves. On a cache
      miss this waits DelayMs first, so a cursor passing over an item is
      killed before any winget starts. The default Fetch runs winget
      detached, writing straight to the cache file: a fetch whose preview
      was killed still finishes and fills the cache, and holds no handle to
      fzf's preview pipe. Fetch receives the Id and the cache file path and
      may leave the file absent when there is nothing to show. An Id that
      fails Test-WinGetPackageId shows nothing.
    #>
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$CacheDir,
        [int]$DelayMs = 250,
        [scriptblock]$Fetch = {
            param($Id, $Path)
            $command = "winget show --id `"$Id`" --exact > `"$Path.tmp`" && move /y `"$Path.tmp`" `"$Path`" >nul"
            Start-Process cmd -ArgumentList '/c', $command -WindowStyle Hidden -Wait
        }
    )
    if (-not (Test-WinGetPackageId $Id)) { return }
    $path = Join-Path $CacheDir "$Id.txt"
    if (-not (Test-Path -LiteralPath $path)) {
        Start-Sleep -Milliseconds $DelayMs
        & $Fetch $Id $path
    }
    if (Test-Path -LiteralPath $path) { Get-Content -LiteralPath $path }
}

function Install-WinGetPick {
    <#
    .SYNOPSIS
      Search winget for Query, pick a package with fzf (previewing `winget show`), and install it.

    .DESCRIPTION
      Previews are cached for this one search and removed afterwards.
      Cancelling the pick installs nothing.
    #>
    param([Parameter(Mandatory)][string]$Query)
    $cache = Join-Path ([IO.Path]::GetTempPath()) "winget-pick-$PID"
    New-Item -ItemType Directory -Path $cache -Force | Out-Null
    try {
        $preview = ". '$script:WinGetPickScript'; Show-WinGetPreview -Id {1} -CacheDir '$cache'"
        $line = Find-WinGetPackage $Query |
            ForEach-Object { ConvertTo-WinGetPickLine $_ } |
            fzf --delimiter "`t" --with-shell 'pwsh -NoProfile -NonInteractive -Command' `
                --preview $preview --preview-window=right:60%:wrap
        $id = ConvertFrom-WinGetPickLine "$line"
        if ($id) { Install-WinGetPackage -Id $id }
    } finally {
        Remove-Item -LiteralPath $cache -Recurse -Force -ErrorAction SilentlyContinue
    }
}
