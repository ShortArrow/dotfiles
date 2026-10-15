BeforeAll {
    . $PSScriptRoot/Switch-ZebarPack.ps1
}

Describe 'Set-ZebarPackLink' {
    BeforeEach {
        $root = Join-Path $TestDrive ([guid]::NewGuid())
        $released = New-Item -ItemType Directory (Join-Path $root 'released')
        $worktree = New-Item -ItemType Directory (Join-Path $root 'worktree')
        $link = Join-Path $root 'overline-zebar'
    }

    It 'リンクを指定先に張り替え、前後の向き先を返す' {
        New-Item -ItemType SymbolicLink -Path $link -Target $released.FullName | Out-Null

        $result = Set-ZebarPackLink -Link $link -Target $worktree.FullName

        (Get-Item $link -Force).Target | Should -Be $worktree.FullName
        $result.Before | Should -Be $released.FullName
        $result.After | Should -Be $worktree.FullName
    }

    It '張り替えても元の向き先の中身は消さない' {
        New-Item -ItemType File (Join-Path $released 'zpack.json') | Out-Null
        New-Item -ItemType SymbolicLink -Path $link -Target $released.FullName | Out-Null

        Set-ZebarPackLink -Link $link -Target $worktree.FullName | Out-Null

        Join-Path $released 'zpack.json' | Should -Exist
    }

    It 'リンクでない実ディレクトリは置き換えずに止まる' {
        New-Item -ItemType Directory $link | Out-Null
        New-Item -ItemType File (Join-Path $link 'zpack.json') | Out-Null

        { Set-ZebarPackLink -Link $link -Target $worktree.FullName } | Should -Throw '*not a symbolic link*'
        Join-Path $link 'zpack.json' | Should -Exist
    }

    It '存在しない指定先には張り替えず元のリンクを残す' {
        New-Item -ItemType SymbolicLink -Path $link -Target $released.FullName | Out-Null

        { Set-ZebarPackLink -Link $link -Target (Join-Path $root 'missing') } | Should -Throw '*does not exist*'
        (Get-Item $link -Force).Target | Should -Be $released.FullName
    }
}
