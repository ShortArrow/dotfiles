#!pwsh

function Search-ExcelFirstSheet {
    <#
    .SYNOPSIS
      Print the first sheet of every .xlsx/.xlsm under a directory whose file name contains a keyword.

    .DESCRIPTION
      One line per non-empty row: "<full path>`t<row number>`t<cells joined by ' | '>".
      Blank cells are dropped and line breaks inside a cell become spaces, so each
      row stays on one line for grep or fzf. Requires the ImportExcel module.

    .EXAMPLE
      Search-ExcelFirstSheet \\server\share 見積
    #>
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$TargetDir,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Keyword
    )

    $Files = Get-ChildItem -Path $TargetDir -Recurse -File -Include *.xlsx, *.xlsm |
        Where-Object { $_.Name -like "*$Keyword*" }

    foreach ($File in $Files) {
        $Rows = Import-Excel -Path $File.FullName -NoHeader

        $RowNum = 1
        foreach ($Row in $Rows) {
            $CellValues = $Row.PSObject.Properties.Value | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

            if ($CellValues.Count -gt 0) {
                $CleanValues = $CellValues | ForEach-Object { ($_ -replace "`r?`n", " ").Trim() }
                $LineText = $CleanValues -join " | "

                "$($File.FullName)`t$RowNum`t$LineText"
            }
            $RowNum++
        }
    }
}
