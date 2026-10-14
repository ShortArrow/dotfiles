BeforeAll {
    . $PSScriptRoot/KanaLock.ps1
}

Describe 'Test-KeyToggled' {
    It '下位ビットが立っていればトグル中' {
        Test-KeyToggled -State 1 | Should -BeTrue
    }

    It '押下中を示す上位ビットだけならトグルではない' {
        Test-KeyToggled -State ([int16]-128) | Should -BeFalse
    }

    It '押下中かつトグル中' {
        Test-KeyToggled -State ([int16]-127) | Should -BeTrue
    }

    It '0 はトグルではない' {
        Test-KeyToggled -State 0 | Should -BeFalse
    }
}

Describe 'Get-KanaLockState' {
    # Each run is a fresh process: a loaded assembly cannot be unloaded, so a
    # second load in this session would not exercise the cache.
    BeforeAll {
        $script:probe = {
            param($source, $cacheDir)
            . $source
            Get-KanaLockState -CacheDir $cacheDir
        }
        $script:source = Join-Path $PSScriptRoot 'KanaLock.ps1'
        $script:invoke = {
            param($cacheDir)
            pwsh -NoProfile -NonInteractive -Command "& { $($script:probe) } '$($script:source)' '$cacheDir'"
        }
    }

    It '真偽値を返し、ネイティブ呼び出しを cache に置く' {
        $dir = Join-Path $TestDrive 'first'
        $out = & $script:invoke $dir
        $out | Should -BeIn @('True', 'False')
        Get-ChildItem -LiteralPath $dir -Filter '*.dll' | Should -HaveCount 1
    }

    It '二回目は置いた DLL を作り直さない' {
        $dir = Join-Path $TestDrive 'second'
        & $script:invoke $dir | Out-Null
        $dll = Get-ChildItem -LiteralPath $dir -Filter '*.dll'
        $before = $dll.LastWriteTimeUtc
        & $script:invoke $dir | Out-Null
        (Get-Item -LiteralPath $dll.FullName).LastWriteTimeUtc | Should -Be $before
    }
}
