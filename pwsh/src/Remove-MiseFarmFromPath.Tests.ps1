BeforeAll {
    . $PSScriptRoot/Remove-MiseFarmFromPath.ps1
}

Describe 'Remove-MiseFarmFromPath' {
    It 'farm ディレクトリの項目を PATH から除く' {
        Remove-MiseFarmFromPath -Path 'C:\a;C:\Users\who\AppData\Local\mise\bin;C:\b' -FarmDir 'C:\Users\who\AppData\Local\mise\bin' |
            Should -Be 'C:\a;C:\b'
    }

    It '末尾の \ と大文字小文字の違いを同一視する' {
        Remove-MiseFarmFromPath -Path 'C:\a;c:\users\WHO\appdata\local\MISE\bin\;C:\b' -FarmDir 'C:\Users\who\AppData\Local\mise\bin' |
            Should -Be 'C:\a;C:\b'
    }

    It '他の項目は順序を変えずに残す' {
        Remove-MiseFarmFromPath -Path 'C:\z;C:\y;C:\x' -FarmDir 'C:\farm' |
            Should -Be 'C:\z;C:\y;C:\x'
    }

    It 'farm と名前が前方一致するだけの項目は残す' {
        Remove-MiseFarmFromPath -Path 'C:\farm\shims;C:\farm' -FarmDir 'C:\farm' |
            Should -Be 'C:\farm\shims'
    }
}
