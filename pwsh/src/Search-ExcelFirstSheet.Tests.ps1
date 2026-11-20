BeforeAll {
    . $PSScriptRoot/Search-ExcelFirstSheet.ps1

    $script:root = Join-Path $TestDrive 'books'
    New-Item -ItemType Directory -Path (Join-Path $script:root 'sub') -Force | Out-Null

    $hit = Join-Path $script:root 'sub/見積_A.xlsx'
    [pscustomobject]@{ A = 'x'; B = $null; C = "two`r`nlines" } |
        Export-Excel -Path $hit -WorksheetName 'first' -NoHeader
    [pscustomobject]@{ A = 'second sheet' } |
        Export-Excel -Path $hit -WorksheetName 'second' -NoHeader

    [pscustomobject]@{ A = 'other' } |
        Export-Excel -Path (Join-Path $script:root 'other.xlsx') -NoHeader
}

Describe 'Search-ExcelFirstSheet' {
    It '名前にキーワードを含むブックの先頭シートを、パス・行番号・セルの順にタブで並べる' {
        $lines = @(Search-ExcelFirstSheet $script:root '見積')
        $lines.Count | Should -Be 1
        $path, $row, $text = $lines[0] -split "`t"
        $path | Should -BeLike '*sub*見積_A.xlsx'
        $row | Should -Be '1'
        $text | Should -Be 'x | two lines'
    }

    It '名前にキーワードを含まないブックは読まない' {
        Search-ExcelFirstSheet $script:root '該当なし' | Should -BeNullOrEmpty
    }
}
