BeforeAll {
    . $PSScriptRoot/Compare-DeclaredPath.ps1
}

Describe 'Compare-DeclaredPath' {
    It '宣言と実際が一致すれば欠落も未宣言も空' {
        $r = Compare-DeclaredPath -Declared 'C:\a', 'C:\b' -Actual 'C:\a;C:\b'
        $r.Missing | Should -BeNullOrEmpty
        $r.Undeclared | Should -BeNullOrEmpty
    }

    It 'インストーラーが PATH を1件に置き換えたとき、宣言の全件が欠落し、置いた1件が未宣言になる' {
        $r = Compare-DeclaredPath -Declared 'C:\a', 'C:\b' -Actual 'C:\arm\bin'
        $r.Missing | Should -Be @('C:\a', 'C:\b')
        $r.Undeclared | Should -Be @('C:\arm\bin')
    }

    It '欠落は宣言の綴りのまま、未宣言は実際の綴りのまま返す' {
        $env:DOTFILES_TEST_ROOT = 'C:\root'
        try {
            $r = Compare-DeclaredPath -Declared '%DOTFILES_TEST_ROOT%\gone' -Actual '%DOTFILES_TEST_ROOT%\extra'
            $r.Missing | Should -Be @('%DOTFILES_TEST_ROOT%\gone')
            $r.Undeclared | Should -Be @('%DOTFILES_TEST_ROOT%\extra')
        } finally {
            Remove-Item Env:DOTFILES_TEST_ROOT
        }
    }

    It '環境変数を展開してから比べる' {
        $env:DOTFILES_TEST_ROOT = 'C:\root'
        try {
            $r = Compare-DeclaredPath -Declared '%DOTFILES_TEST_ROOT%\bin' -Actual 'C:\root\bin'
            $r.Missing | Should -BeNullOrEmpty
            $r.Undeclared | Should -BeNullOrEmpty
        } finally {
            Remove-Item Env:DOTFILES_TEST_ROOT
        }
    }

    It '大文字小文字と末尾の \ の違いを同一視する' {
        $r = Compare-DeclaredPath -Declared 'C:\Tools\Bin' -Actual 'c:\tools\bin\'
        $r.Missing | Should -BeNullOrEmpty
        $r.Undeclared | Should -BeNullOrEmpty
    }

    It '空の項目と空白だけの行は無視する' {
        $r = Compare-DeclaredPath -Declared 'C:\a', '', '  ' -Actual ';C:\a;;'
        $r.Missing | Should -BeNullOrEmpty
        $r.Undeclared | Should -BeNullOrEmpty
    }

    It '順序の違いは差分にしない' {
        $r = Compare-DeclaredPath -Declared 'C:\a', 'C:\b' -Actual 'C:\b;C:\a'
        $r.Missing | Should -BeNullOrEmpty
        $r.Undeclared | Should -BeNullOrEmpty
    }

    It '実際の PATH が空なら宣言の全件が欠落する' {
        $r = Compare-DeclaredPath -Declared 'C:\a' -Actual ''
        $r.Missing | Should -Be @('C:\a')
        $r.Undeclared | Should -BeNullOrEmpty
    }
}
