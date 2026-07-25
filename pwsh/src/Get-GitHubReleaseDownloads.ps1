#!pwsh
<#
.SYNOPSIS
GitHub リポジトリのリリース資産のダウンロード数を集計する。

.DESCRIPTION
リリース毎・バイナリ(asset)毎のダウンロード数を PSCustomObject で出力する。
$env:GITHUB_TOKEN が設定されていれば認証付きで API を呼び、レート制限を緩和する。

.PARAMETER Repository
"owner/repo" 形式のリポジトリ指定。

.PARAMETER Release
特定リリースのタグ名 (例: v1.2.3)。省略時は全リリースを対象とする。

.PARAMETER Total
指定時は資産の内訳を出さず、対象リリース全体の合計ダウンロード数のみを出力する。

.EXAMPLE
./Get-GitHubReleaseDownloads.ps1 -Repository sharkdp/bat

.EXAMPLE
./Get-GitHubReleaseDownloads.ps1 -Repository sharkdp/bat -Release v0.24.0

.EXAMPLE
./Get-GitHubReleaseDownloads.ps1 -Repository sharkdp/bat -Total
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[\w.-]+/[\w.-]+$')]
    [string]$Repository,

    [string]$Release,

    [switch]$Total
)

function Get-GitHubReleases {
    param(
        [Parameter(Mandatory)][string]$Repository,
        [string]$Tag
    )
    $headers = @{ Accept = 'application/vnd.github+json' }
    if ($env:GITHUB_TOKEN) { $headers.Authorization = "Bearer $($env:GITHUB_TOKEN)" }

    if ($Tag) {
        return @(Invoke-RestMethod -Uri "https://api.github.com/repos/$Repository/releases/tags/$Tag" -Headers $headers)
    }

    $releases = @()
    $page = 1
    do {
        $batch = @(Invoke-RestMethod -Uri "https://api.github.com/repos/$Repository/releases?per_page=100&page=$page" -Headers $headers)
        $releases += $batch
        $page++
    } while ($batch.Count -eq 100)
    return $releases
}

function ConvertTo-DownloadReport {
    param([object[]]$Releases)
    foreach ($release in $Releases) {
        foreach ($asset in $release.assets) {
            [pscustomobject]@{
                Release   = $release.tag_name
                Asset     = $asset.name
                Downloads = $asset.download_count
            }
        }
        [pscustomobject]@{
            Release   = $release.tag_name
            Asset     = '(release total)'
            Downloads = [int](($release.assets | Measure-Object download_count -Sum).Sum ?? 0)
        }
    }
}

function Measure-TotalDownloads {
    param([object[]]$Releases)
    [int](($Releases.assets | Measure-Object download_count -Sum).Sum ?? 0)
}

if ($MyInvocation.InvocationName -ne '.') {
    try {
        $releases = Get-GitHubReleases -Repository $Repository -Tag $Release
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            throw "Not found: repository '$Repository'$(if ($Release) { " or release '$Release'" })"
        }
        throw
    }

    if ($Total) {
        [pscustomobject]@{
            Repository     = $Repository
            Releases       = $releases.Count
            TotalDownloads = Measure-TotalDownloads $releases
        }
    }
    else {
        ConvertTo-DownloadReport $releases
    }
}
