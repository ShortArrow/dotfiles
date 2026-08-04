BeforeAll {
    . $PSScriptRoot/Merge-ClaudeSettings.ps1
}

Describe 'Merge-ClaudeSettings' {
    Context '共有キーを持ち込む' {
        It 'settings 側に無いキーを sample から追加する' {
            $current = @{}
            $sample = @{ attribution = @{ commit = ''; sessionUrl = $false } }

            $merged = Merge-ClaudeSettings -Current $current -Sample $sample

            $merged.attribution.commit | Should -Be ''
            $merged.attribution.sessionUrl | Should -BeFalse
        }

        It 'sample の値で settings 側の古い値を上書きする' {
            $current = @{ attribution = @{ sessionUrl = $true } }
            $sample = @{ attribution = @{ sessionUrl = $false } }

            $merged = Merge-ClaudeSettings -Current $current -Sample $sample

            $merged.attribution.sessionUrl | Should -BeFalse
        }

        It 'sample が知らない兄弟キーは settings 側を残す' {
            $current = @{ attribution = @{ pr = 'keep me' } }
            $sample = @{ attribution = @{ commit = '' } }

            $merged = Merge-ClaudeSettings -Current $current -Sample $sample

            $merged.attribution.pr | Should -Be 'keep me'
            $merged.attribution.commit | Should -Be ''
        }
    }

    Context 'マシン固有の設定を守る' {
        It 'sample に無いトップレベルキーへは触れない' {
            $current = @{
                permissions = @{ allow = @('Bash(git:*)', 'WebSearch') }
                model       = 'opus'
            }
            $sample = @{ attribution = @{ commit = '' } }

            $merged = Merge-ClaudeSettings -Current $current -Sample $sample

            $merged.permissions.allow | Should -HaveCount 2
            $merged.model | Should -Be 'opus'
        }

        It 'permissions は sample が持っていても上書きしない' {
            $current = @{ permissions = @{ allow = @('Bash(git:*)') } }
            $sample = @{ permissions = @{ allow = @('Bash(rm:*)') } }

            $merged = Merge-ClaudeSettings -Current $current -Sample $sample

            $merged.permissions.allow | Should -Be @('Bash(git:*)')
        }
    }

    Context '配列を持つキー' {
        It 'hooks は sample の定義でまるごと置き換える' {
            $current = @{ hooks = @{ PreToolUse = @(@{ matcher = 'Bash'; hooks = @(@{ type = 'command'; command = 'old' }) }) } }
            $sample = @{ hooks = @{ PreToolUse = @(@{ matcher = 'Bash'; hooks = @(@{ type = 'command'; command = 'new' }) }) } }

            $merged = Merge-ClaudeSettings -Current $current -Sample $sample

            $merged.hooks.PreToolUse[0].hooks[0].command | Should -Be 'new'
        }

        It 'settings が hooks を持たなくても sample から作る' {
            $current = @{ model = 'opus' }
            $sample = @{ hooks = @{ PreToolUse = @(@{ matcher = 'Bash' }) } }

            $merged = Merge-ClaudeSettings -Current $current -Sample $sample

            $merged.hooks.PreToolUse[0].matcher | Should -Be 'Bash'
            $merged.model | Should -Be 'opus'
        }
    }

    Context '変化の有無を判定できる' {
        It 'キーの並びが違うだけの二つを同じとみなす' {
            $a = @{ attribution = @{ commit = ''; pr = '' }; model = 'opus' }
            $b = @{ model = 'opus'; attribution = @{ pr = ''; commit = '' } }

            ConvertTo-CanonicalJson -InputObject $a |
                Should -Be (ConvertTo-CanonicalJson -InputObject $b)
        }

        It '値が違えば別物とみなす' {
            $a = @{ attribution = @{ sessionUrl = $false } }
            $b = @{ attribution = @{ sessionUrl = $true } }

            ConvertTo-CanonicalJson -InputObject $a |
                Should -Not -Be (ConvertTo-CanonicalJson -InputObject $b)
        }

        It '配列の順序は意味を持つので区別する' {
            $a = @{ hooks = @('first', 'second') }
            $b = @{ hooks = @('second', 'first') }

            ConvertTo-CanonicalJson -InputObject $a |
                Should -Not -Be (ConvertTo-CanonicalJson -InputObject $b)
        }

        It 'マージを二度かけても結果が変わらない' {
            $current = @{ permissions = @{ allow = @('Bash(git:*)') }; model = 'opus' }
            $sample = @{ attribution = @{ sessionUrl = $false } }

            $once = Merge-ClaudeSettings -Current $current -Sample $sample
            $twice = Merge-ClaudeSettings -Current $once -Sample $sample

            ConvertTo-CanonicalJson -InputObject $once |
                Should -Be (ConvertTo-CanonicalJson -InputObject $twice)
        }
    }

    Context '入力を壊さない' {
        It '渡された Current を書き換えない' {
            $current = @{ attribution = @{ sessionUrl = $true } }
            $sample = @{ attribution = @{ sessionUrl = $false } }

            Merge-ClaudeSettings -Current $current -Sample $sample | Out-Null

            $current.attribution.sessionUrl | Should -BeTrue
        }
    }
}
