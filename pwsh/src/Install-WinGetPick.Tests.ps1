BeforeAll {
    . $PSScriptRoot/Install-WinGetPick.ps1
}

Describe 'ConvertTo-WinGetPickLine' {
    It 'Id をタブで区切り、名前と版を後ろに並べる' {
        $package = [pscustomobject]@{ Id = 'OpenAI.Codex'; Name = 'Codex'; Version = '1.2.3' }
        ConvertTo-WinGetPickLine $package | Should -Be "OpenAI.Codex`tCodex [1.2.3]"
    }
}

Describe 'ConvertFrom-WinGetPickLine' {
    It '選択行のタブより前を Id として返す' {
        ConvertFrom-WinGetPickLine "OpenAI.Codex`tCodex [1.2.3]" | Should -Be 'OpenAI.Codex'
    }

    It '空行(fzf キャンセル)は $null を返す' {
        ConvertFrom-WinGetPickLine '' | Should -BeNullOrEmpty
    }
}

Describe 'Show-WinGetPreview' {
    BeforeEach {
        $cache = Join-Path $TestDrive ([guid]::NewGuid())
        New-Item -ItemType Directory -Path $cache | Out-Null
        $script:fetched = @()
        $fetch = {
            param($Id, $Path)
            $script:fetched += $Id
            Set-Content -LiteralPath $Path -Value "shown $Id"
        }
    }

    It 'キャッシュが無ければ取得して表示し、キャッシュに残す' {
        Show-WinGetPreview -Id 'Git.Git' -CacheDir $cache -DelayMs 0 -Fetch $fetch |
            Should -Be 'shown Git.Git'
        $script:fetched | Should -Be @('Git.Git')
        Test-Path (Join-Path $cache 'Git.Git.txt') | Should -BeTrue
    }

    It '一度表示した項目は取得し直さずキャッシュから表示する' {
        Show-WinGetPreview -Id 'Git.Git' -CacheDir $cache -DelayMs 0 -Fetch $fetch | Out-Null
        Show-WinGetPreview -Id 'Git.Git' -CacheDir $cache -DelayMs 0 -Fetch $fetch |
            Should -Be 'shown Git.Git'
        $script:fetched | Should -Be @('Git.Git')
    }

    It 'Id に使えない文字を含む Id は取得せず空を返す' -TestCases @(
        @{ Id = 'Evil&calc.Pkg' }
        @{ Id = '..\..\outside' }
        @{ Id = 'A.%PATH%' }
        @{ Id = 'A."quote' }
    ) {
        Show-WinGetPreview -Id $Id -CacheDir $cache -DelayMs 0 -Fetch $fetch |
            Should -BeNullOrEmpty
        $script:fetched | Should -BeNullOrEmpty
    }

    It '取得が何も書かなければ空を返し、キャッシュも作らない' {
        $empty = { param($Id, $Path) }
        Show-WinGetPreview -Id 'Gone.Pkg' -CacheDir $cache -DelayMs 0 -Fetch $empty |
            Should -BeNullOrEmpty
        Test-Path (Join-Path $cache 'Gone.Pkg.txt') | Should -BeFalse
    }
}
