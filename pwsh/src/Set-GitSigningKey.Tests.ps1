BeforeAll {
    . $PSScriptRoot/Set-GitSigningKey.ps1
}

Describe 'ConvertFrom-GpgSecretKeyListing' {
    It 'sec 行の鍵 ID と直後の uid を 1 行にまとめる' {
        $listing = @(
            'sec:u:255:22:7B66415DC7B803DD:1728723173:::u:::scESC:::+::ed25519:::0:'
            'uid:u::::1728863291::FPR1::ShortArrow (hi!) <bamboogeneral@shortarrow.jp>::::::::::0:'
            'sec:u:255:22:D8096CB4AD0FB34D:1728860204:::u:::scESC:::+::ed25519:::0:'
            'uid:u::::1728860204::FPR2::Take (hey) <take_shoutarou@fukaden.co.jp>::::::::::0:'
        )
        ConvertFrom-GpgSecretKeyListing $listing | Should -Be @(
            '7B66415DC7B803DD  ShortArrow (hi!) <bamboogeneral@shortarrow.jp>'
            'D8096CB4AD0FB34D  Take (hey) <take_shoutarou@fukaden.co.jp>'
        )
    }

    It '鍵が無ければ空を返す' {
        ConvertFrom-GpgSecretKeyListing @() | Should -BeNullOrEmpty
    }
}

Describe 'ConvertTo-SigningKeyValue' {
    It '選択行の先頭トークンを鍵 ID として返す' {
        ConvertTo-SigningKeyValue '7B66415DC7B803DD  ShortArrow (hi!) <x@y>' |
            Should -Be '7B66415DC7B803DD'
    }

    It '空行(fzf キャンセル)は $null を返す' {
        ConvertTo-SigningKeyValue '' | Should -BeNullOrEmpty
    }

    It '空白のみの行も $null を返す' {
        ConvertTo-SigningKeyValue '   ' | Should -BeNullOrEmpty
    }

    It '前後の空白を除いてから取り出す' {
        ConvertTo-SigningKeyValue "  D8096CB4AD0FB34D  Take <x@y>`n" |
            Should -Be 'D8096CB4AD0FB34D'
    }
}

Describe 'Set-GitSigningKey' {
    BeforeEach {
        Mock gpg { 'sec:u:255:22:7B66415DC7B803DD:1::::::::+::ed25519:::0:'; 'uid:u::::1::F::ShortArrow <x@y>::::::::::0:' }
        Mock git {}
    }

    It 'キャンセル時は git config を書かない' {
        Mock fzf { '' }
        Set-GitSigningKey
        Should -Invoke git -Times 0
    }

    It '選択した鍵の ID をこのリポジトリに書き込む' {
        Mock fzf { '7B66415DC7B803DD  ShortArrow <x@y>' }
        Set-GitSigningKey
        Should -Invoke git -Times 1 -Exactly -ParameterFilter {
            "$args" -eq 'config user.signingkey 7B66415DC7B803DD'
        }
    }
}
