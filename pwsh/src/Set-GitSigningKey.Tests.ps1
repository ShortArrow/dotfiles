BeforeAll {
    . $PSScriptRoot/Set-GitSigningKey.ps1
}

Describe 'ConvertTo-SigningKeyValue' {
    It '公開鍵の行を key:: リテラルにする' {
        ConvertTo-SigningKeyValue 'ssh-ed25519 AAAAtest github-private' |
            Should -Be 'key::ssh-ed25519 AAAAtest github-private'
    }

    It '空行(fzf キャンセル)は $null を返す' {
        ConvertTo-SigningKeyValue '' | Should -BeNullOrEmpty
    }

    It '空白のみの行も $null を返す' {
        ConvertTo-SigningKeyValue '   ' | Should -BeNullOrEmpty
    }

    It '前後の空白を除いてから包む' {
        ConvertTo-SigningKeyValue "  ssh-ed25519 AAAAtest x`n" |
            Should -Be 'key::ssh-ed25519 AAAAtest x'
    }
}

Describe 'Set-GitSigningKey' {
    BeforeEach {
        Mock ssh-add { 'ssh-ed25519 AAAAtest github-private' }
        Mock git {}
    }

    It 'キャンセル時は git config を書かない' {
        Mock fzf { '' }
        Set-GitSigningKey
        Should -Invoke git -Times 0
    }

    It '選択した鍵を key:: 形式でこのリポジトリに書き込む' {
        Mock fzf { 'ssh-ed25519 AAAAtest github-private' }
        Set-GitSigningKey
        Should -Invoke git -Times 1 -Exactly -ParameterFilter {
            "$args" -eq 'config user.signingkey key::ssh-ed25519 AAAAtest github-private'
        }
    }
}
