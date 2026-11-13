BeforeAll {
    . $PSScriptRoot/Start-Zebar.ps1
}

Describe 'Move-ZebarStderrLog' {
    BeforeEach {
        $root = New-Item -ItemType Directory (Join-Path $TestDrive ([guid]::NewGuid()))
        $log = Join-Path $root 'stderr.log'
        $prev = Join-Path $root 'stderr.prev.log'
    }

    It '前回のログを stderr.prev.log に移し、元の場所を空ける' {
        Set-Content $log 'last run'

        Move-ZebarStderrLog -Path $log

        $log | Should -Not -Exist
        Get-Content $prev | Should -Be 'last run'
    }

    It '前々回のログは前回のログで上書きする' {
        Set-Content $log 'last run'
        Set-Content $prev 'run before last'

        Move-ZebarStderrLog -Path $log

        Get-Content $prev | Should -Be 'last run'
    }

    It 'ログがなければ前々回のログを残す' {
        Set-Content $prev 'run before last'

        { Move-ZebarStderrLog -Path $log } | Should -Not -Throw
        Get-Content $prev | Should -Be 'run before last'
    }
}

Describe 'Get-ZebarStartArgument' {
    It '標準エラーをログに、標準出力を NUL に送り、ウィンドウを隠して起動する' {
        $arguments = Get-ZebarStartArgument -Executable 'C:/zebar/zebar.exe' -LogPath 'C:/logs/stderr.log'

        $arguments.FilePath | Should -Be 'C:/zebar/zebar.exe'
        $arguments.RedirectStandardError | Should -Be 'C:/logs/stderr.log'
        $arguments.RedirectStandardOutput | Should -Be 'NUL'
        $arguments.WindowStyle | Should -Be 'Hidden'
    }
}
