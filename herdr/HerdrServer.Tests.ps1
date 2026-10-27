BeforeAll {
    . $PSScriptRoot/HerdrServer.ps1

    function New-Proc([int]$ProcessId, [int]$SessionId, [string]$CommandLine, [string]$Name = 'herdr.exe') {
        [pscustomobject]@{ ProcessId = $ProcessId; SessionId = $SessionId; Name = $Name; CommandLine = $CommandLine }
    }
    $exe = '"C:\Users\u\.herdr\packages\standalone\releases\0.9.3-x86_64-pc-windows-msvc\herdr.exe"'
}

Describe 'Select-HerdrServer' {
    BeforeAll {
        $processes = @(
            New-Proc 10 1 "$exe"
            New-Proc 11 1 "$exe server"
            New-Proc 20 0 "$exe server"
            New-Proc 21 0 "$exe remote-client-bridge "
            New-Proc 30 1 'pwsh.exe -c herdr server' 'pwsh.exe'
        )
    }

    It '指定セッションの herdr.exe server だけを返す' {
        (Select-HerdrServer -Process $processes -SessionId 0).ProcessId | Should -Be 20
        (Select-HerdrServer -Process $processes -SessionId 1).ProcessId | Should -Be 11
    }

    It 'クライアントとリモートブリッジはサーバーとみなさない' {
        Select-HerdrServer -Process (New-Proc 1 0 "$exe remote-client-bridge ") -SessionId 0 | Should -BeNullOrEmpty
        Select-HerdrServer -Process (New-Proc 2 1 "$exe") -SessionId 1 | Should -BeNullOrEmpty
    }

    It 'コマンドラインが読めないプロセスはサーバーとみなさない' {
        Select-HerdrServer -Process (New-Proc 3 0 $null) -SessionId 0 | Should -BeNullOrEmpty
    }
}

Describe 'Test-HerdrServerRunning' {
    It 'status の JSON が running なら $true' {
        Test-HerdrServerRunning -StatusJson '{"status":"running","running":true,"version":"0.9.3"}' | Should -BeTrue
    }

    It 'サーバーがいなければ $false' {
        Test-HerdrServerRunning -StatusJson '{"status":"not running","running":false}' | Should -BeFalse
    }

    It '接続を拒まれたときのような JSON でない出力は $false' {
        Test-HerdrServerRunning -StatusJson 'Access is denied. (os error 5)' | Should -BeFalse
    }

    It '出力が空なら $false' {
        Test-HerdrServerRunning -StatusJson '' | Should -BeFalse
    }
}

Describe 'Get-HerdrTakeoverStep' {
    It 'デスクトップ側のサーバーが動いていれば Done' {
        Get-HerdrTakeoverStep -DesktopServerRunning $true -Attempt 1 -MaxAttempts 5 | Should -Be 'Done'
    }

    It '動いておらず試行が残っていれば Takeover' {
        Get-HerdrTakeoverStep -DesktopServerRunning $false -Attempt 5 -MaxAttempts 5 | Should -Be 'Takeover'
    }

    It '試行を使い切ったら GiveUp' {
        Get-HerdrTakeoverStep -DesktopServerRunning $false -Attempt 6 -MaxAttempts 5 | Should -Be 'GiveUp'
    }
}
