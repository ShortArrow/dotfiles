BeforeAll {
    . $PSScriptRoot/Get-GitHubReleaseDownloads.ps1 -Repository 'dummy/dummy'

    $script:releases = @(
        [pscustomobject]@{
            tag_name = 'v1.0.0'
            assets   = @(
                [pscustomobject]@{ name = 'app-windows.zip'; download_count = 10 }
                [pscustomobject]@{ name = 'app-linux.tar.gz'; download_count = 5 }
            )
        }
        [pscustomobject]@{
            tag_name = 'v0.9.0'
            assets   = @(
                [pscustomobject]@{ name = 'app-windows.zip'; download_count = 3 }
            )
        }
        [pscustomobject]@{
            tag_name = 'v0.8.0'
            assets   = @()
        }
    )
}

Describe 'ConvertTo-DownloadReport' {
    It 'リリース毎に asset の行と小計行を出力する' {
        $report = ConvertTo-DownloadReport -Releases $script:releases

        $v1 = $report | Where-Object Release -EQ 'v1.0.0'
        $v1.Count | Should -Be 3
        ($v1 | Where-Object Asset -EQ 'app-windows.zip').Downloads | Should -Be 10
        ($v1 | Where-Object Asset -EQ '(release total)').Downloads | Should -Be 15
    }

    It 'asset の無いリリースは小計 0 の行のみになる' {
        $report = ConvertTo-DownloadReport -Releases $script:releases

        $v08 = @($report | Where-Object Release -EQ 'v0.8.0')
        $v08.Count | Should -Be 1
        $v08[0].Asset | Should -Be '(release total)'
        $v08[0].Downloads | Should -Be 0
    }
}

Describe 'Measure-TotalDownloads' {
    It '全リリースの合計を返す' {
        Measure-TotalDownloads -Releases $script:releases | Should -Be 18
    }

    It '空のリリース一覧では 0 を返す' {
        Measure-TotalDownloads -Releases @() | Should -Be 0
    }
}
