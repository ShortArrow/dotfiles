BeforeAll {
    . $PSScriptRoot/MiseBinFarm.ps1
}

Describe 'Resolve-FarmEntry' {
    BeforeEach {
        $bin = Join-Path $TestDrive ([guid]::NewGuid())
        New-Item -ItemType Directory -Path $bin | Out-Null
    }

    It '実体が exe ならシムと同名のリンクにする' {
        $exe = Join-Path $bin 'rg.exe'; New-Item -ItemType File -Path $exe | Out-Null
        $entry = Resolve-FarmEntry -Name 'rg' -Target $exe
        $entry.File | Should -Be 'rg.exe'
        $entry.Kind | Should -Be 'Link'
        $entry.Target | Should -Be $exe
    }

    It '/ 混じりの実体パスは OS がリンク先に記録する形に正規化する' {
        New-Item -ItemType Directory -Path (Join-Path $bin 'sub') | Out-Null
        $exe = Join-Path $bin 'sub\cmake.exe'; New-Item -ItemType File -Path $exe | Out-Null
        (Resolve-FarmEntry -Name 'cmake' -Target "$bin/sub\cmake.exe").Target | Should -Be $exe
    }

    It '拡張子なしの npm スクリプトは隣の .cmd を呼ぶラッパーにする' {
        $script = Join-Path $bin 'gemini'
        New-Item -ItemType File -Path $script, "$script.cmd", "$script.ps1" | Out-Null
        $entry = Resolve-FarmEntry -Name 'gemini' -Target $script
        $entry.File | Should -Be 'gemini.cmd'
        $entry.Kind | Should -Be 'Wrapper'
        $entry.Target | Should -Be "$script.cmd"
    }

    It '.cmd が無く .bat だけあればそれを呼ぶ' {
        $script = Join-Path $bin 'gradle'
        New-Item -ItemType File -Path $script, "$script.bat" | Out-Null
        (Resolve-FarmEntry -Name 'gradle' -Target $script).Target | Should -Be "$script.bat"
    }

    It '実体そのものが .cmd ならそれを呼ぶ' {
        $cmd = Join-Path $bin 'tool.cmd'; New-Item -ItemType File -Path $cmd | Out-Null
        $entry = Resolve-FarmEntry -Name 'tool' -Target $cmd
        $entry.Kind | Should -Be 'Wrapper'
        $entry.Target | Should -Be $cmd
    }

    It 'cmd から起動できる実体が無ければ $null' {
        $script = Join-Path $bin 'shonly'; New-Item -ItemType File -Path $script | Out-Null
        Resolve-FarmEntry -Name 'shonly' -Target $script | Should -BeNullOrEmpty
    }
}

Describe 'Find-FarmTarget' {
    BeforeEach {
        $first = Join-Path $TestDrive ([guid]::NewGuid())
        $second = Join-Path $TestDrive ([guid]::NewGuid())
        New-Item -ItemType Directory -Path $first, $second | Out-Null
    }

    It '先に並ぶ bin パスにある実体を返す' {
        New-Item -ItemType File -Path (Join-Path $first 'runex.exe'), (Join-Path $second 'runex.exe') | Out-Null
        Find-FarmTarget -Name 'runex' -BinPath $first, $second | Should -Be (Join-Path $first 'runex.exe')
    }

    It '前の bin パスに無ければ後ろから探す' {
        New-Item -ItemType File -Path (Join-Path $second 'runex.exe') | Out-Null
        Find-FarmTarget -Name 'runex' -BinPath $first, $second | Should -Be (Join-Path $second 'runex.exe')
    }

    It '拡張子なしの npm スクリプトも実体として返す' {
        New-Item -ItemType File -Path (Join-Path $first 'gemini'), (Join-Path $first 'gemini.cmd') | Out-Null
        Find-FarmTarget -Name 'gemini' -BinPath $first | Should -Be (Join-Path $first 'gemini')
    }

    It 'どの bin パスにも無ければ $null' {
        Find-FarmTarget -Name 'none' -BinPath $first, (Join-Path $TestDrive 'missing') | Should -BeNullOrEmpty
    }
}

Describe 'New-FarmWrapperText と Get-FarmEntryTarget' {
    It 'ラッパーは実体を引数ごと呼ぶ 1 行で、その実体を読み戻せる' {
        $target = 'C:\mise\installs\npm-x\1.0.0\node_modules\.bin\x.cmd'
        $text = New-FarmWrapperText -Target $target
        $text | Should -Be "@`"$target`" %*"
        $file = Join-Path $TestDrive 'x.cmd'
        Set-Content -LiteralPath $file -Value $text
        Get-FarmEntryTarget (Get-Item -LiteralPath $file) | Should -Be $target
    }

    It 'ラッパーの形をしていないファイルは $null' {
        $file = Join-Path $TestDrive 'other.cmd'
        Set-Content -LiteralPath $file -Value '@echo hi'
        Get-FarmEntryTarget (Get-Item -LiteralPath $file) | Should -BeNullOrEmpty
    }
}
