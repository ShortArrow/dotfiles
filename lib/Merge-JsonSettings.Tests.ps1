BeforeAll {
    . $PSScriptRoot/Merge-JsonSettings.ps1
}

Describe 'Merge-JsonSettings' {
    Context '共有キーを持ち込む' {
        It 'settings 側に無いキーを sample から追加する' {
            $current = @{}
            $sample = @{ attribution = @{ commit = ''; sessionUrl = $false } }

            $merged = Merge-JsonSettings -Current $current -Sample $sample

            $merged.attribution.commit | Should -Be ''
            $merged.attribution.sessionUrl | Should -BeFalse
        }

        It 'sample の値で settings 側の古い値を上書きする' {
            $current = @{ attribution = @{ sessionUrl = $true } }
            $sample = @{ attribution = @{ sessionUrl = $false } }

            $merged = Merge-JsonSettings -Current $current -Sample $sample

            $merged.attribution.sessionUrl | Should -BeFalse
        }

        It 'sample が知らない兄弟キーは settings 側を残す' {
            $current = @{ attribution = @{ pr = 'keep me' } }
            $sample = @{ attribution = @{ commit = '' } }

            $merged = Merge-JsonSettings -Current $current -Sample $sample

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

            $merged = Merge-JsonSettings -Current $current -Sample $sample

            $merged.permissions.allow | Should -HaveCount 2
            $merged.model | Should -Be 'opus'
        }

        It '保護キーは sample が持っていても上書きしない' {
            $current = @{ permissions = @{ allow = @('Bash(git:*)') } }
            $sample = @{ permissions = @{ allow = @('Bash(rm:*)') } }

            $merged = Merge-JsonSettings -Current $current -Sample $sample -ProtectedKeys @('permissions')

            $merged.permissions.allow | Should -Be @('Bash(git:*)')
        }
    }

    Context 'Windows Terminal の形' {
        It 'profiles.defaults を持ち込み、UUID 付きの profiles.list と defaultProfile は残す' {
            $current = @{
                defaultProfile = '{574e775e-4f2a-5b96-ac1e-a2962a402336}'
                profiles       = @{
                    defaults = @{}
                    list     = @(@{ guid = '{574e775e-4f2a-5b96-ac1e-a2962a402336}'; name = 'PowerShell' })
                }
            }
            $sample = @{ profiles = @{ defaults = @{ font = @{ face = 'JetBrainsMonoNL Nerd Font' } } } }

            $merged = Merge-JsonSettings -Current $current -Sample $sample

            $merged.profiles.defaults.font.face | Should -Be 'JetBrainsMonoNL Nerd Font'
            $merged.profiles.list | Should -HaveCount 1
            $merged.profiles.list[0].name | Should -Be 'PowerShell'
            $merged.defaultProfile | Should -Be '{574e775e-4f2a-5b96-ac1e-a2962a402336}'
        }
    }

    Context '配列を持つキー' {
        It 'hooks は sample の定義でまるごと置き換える' {
            $current = @{ hooks = @{ PreToolUse = @(@{ matcher = 'Bash'; hooks = @(@{ type = 'command'; command = 'old' }) }) } }
            $sample = @{ hooks = @{ PreToolUse = @(@{ matcher = 'Bash'; hooks = @(@{ type = 'command'; command = 'new' }) }) } }

            $merged = Merge-JsonSettings -Current $current -Sample $sample

            $merged.hooks.PreToolUse[0].hooks[0].command | Should -Be 'new'
        }

        It 'settings が hooks を持たなくても sample から作る' {
            $current = @{ model = 'opus' }
            $sample = @{ hooks = @{ PreToolUse = @(@{ matcher = 'Bash' }) } }

            $merged = Merge-JsonSettings -Current $current -Sample $sample

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

            $once = Merge-JsonSettings -Current $current -Sample $sample
            $twice = Merge-JsonSettings -Current $once -Sample $sample

            ConvertTo-CanonicalJson -InputObject $once |
                Should -Be (ConvertTo-CanonicalJson -InputObject $twice)
        }
    }

    Context '入力を壊さない' {
        It '渡された Current を書き換えない' {
            $current = @{ attribution = @{ sessionUrl = $true } }
            $sample = @{ attribution = @{ sessionUrl = $false } }

            Merge-JsonSettings -Current $current -Sample $sample | Out-Null

            $current.attribution.sessionUrl | Should -BeTrue
        }
    }
}

Describe 'Convert-SettingsLinkToFile' {
    BeforeEach {
        $dir = Join-Path $TestDrive ([guid]::NewGuid())
        New-Item -ItemType Directory -Path $dir | Out-Null
        $target = Join-Path $dir 'repo-settings.json'
        $settings = Join-Path $dir 'settings.json'
    }

    It 'リンクを、リンク先と同じ内容の普通のファイルに置き換え、リンク先は残す' {
        Set-Content -LiteralPath $target -Value '{"a":1}' -NoNewline
        New-Item -ItemType SymbolicLink -Path $settings -Target $target | Out-Null

        Convert-SettingsLinkToFile -Path $settings -FallbackContent '{"fallback":true}' | Should -Be 'converted'

        (Get-Item -LiteralPath $settings).LinkType | Should -BeNullOrEmpty
        Get-Content -LiteralPath $settings -Raw | Should -Be '{"a":1}'
        Get-Content -LiteralPath $target -Raw | Should -Be '{"a":1}'
    }

    It 'リンク先が無いときは FallbackContent で普通のファイルを作る' {
        Set-Content -LiteralPath $target -Value '{}' -NoNewline
        New-Item -ItemType SymbolicLink -Path $settings -Target $target | Out-Null
        Remove-Item -LiteralPath $target

        Convert-SettingsLinkToFile -Path $settings -FallbackContent '{"fallback":true}' | Should -Be 'converted'

        (Get-Item -LiteralPath $settings).LinkType | Should -BeNullOrEmpty
        Get-Content -LiteralPath $settings -Raw | Should -Be '{"fallback":true}'
        Test-Path -LiteralPath $target | Should -BeFalse
    }

    It '普通のファイルには触れない' {
        Set-Content -LiteralPath $settings -Value '{"mine":1}' -NoNewline

        Convert-SettingsLinkToFile -Path $settings -FallbackContent '{"fallback":true}' | Should -Be 'noop'

        Get-Content -LiteralPath $settings -Raw | Should -Be '{"mine":1}'
    }

    It 'ファイルが無ければ何も作らない' {
        Convert-SettingsLinkToFile -Path $settings -FallbackContent '{"fallback":true}' | Should -Be 'noop'

        Test-Path -LiteralPath $settings | Should -BeFalse
    }
}
