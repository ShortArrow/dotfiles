BeforeDiscovery {
    $script:pathlint = (Get-Command pathlint -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1).Source
}

BeforeAll {
    $script:pathlint = (Get-Command pathlint -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1).Source

    # Fake trees under TestDrive stand in for %LocalAppData% and
    # %ProgramFiles%. Windows resets ProgramFiles for every new process, so
    # the config under test reads it from a variable the test can set.
    $script:config = Join-Path $TestDrive 'pathlint.toml'
    (Get-Content -Raw (Join-Path $PSScriptRoot 'pathlint.toml')).Replace('$ProgramFiles/', '$PATHLINT_TEST_PF/') |
        Set-Content -LiteralPath $config
    $script:dirs = [ordered]@{
        farm        = 'la\mise\bin'
        shims       = 'la\mise\shims'
        windowsApps = 'la\Microsoft\WindowsApps'
        goMsi       = 'pf\Go\bin'
        pwsh7       = 'pf\PowerShell\7'
        gitUsr      = 'pf\Git\usr\bin'
    }

    function Get-CheckKind {
        <#
        .SYNOPSIS
          The `pathlint check` verdict for Command ('ok', 'ng_wrong_source', ...)
          when PATH is Order, a list of fake dirs that each hold Command.
        #>
        param([string[]]$Order, [string]$Command)
        $root = Join-Path $TestDrive ([guid]::NewGuid())
        $path = foreach ($name in $Order) {
            $dir = Join-Path $root $dirs[$name]
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $dir "$Command.exe") | Out-Null
            $dir
        }
        $setup = "`$env:LOCALAPPDATA='$root\la'; `$env:PATHLINT_TEST_PF='$root\pf'; `$env:PATH='$($path -join ';')'"
        $json = pwsh -NoProfile -Command "$setup; & '$pathlint' --config '$config' check --json"
        (($json | Out-String | ConvertFrom-Json) | Where-Object command -eq $Command).kind
    }
}

Describe 'pathlint.toml' -Skip:(-not $script:pathlint) {
    It 'farm のツールは farm から解決されれば通る' {
        Get-CheckKind -Order farm, shims -Command rg | Should -Be 'ok'
    }

    It 'farm のツールが shim から解決されたら落ちる' {
        Get-CheckKind -Order shims, farm -Command rg | Should -Be 'ng_wrong_source'
    }

    It 'go が Program Files の Go から解決されたら落ちる' {
        Get-CheckKind -Order goMsi, farm -Command go | Should -Be 'ng_wrong_source'
    }

    It 'python は farm に入らないので shim から解決されれば通る' {
        Get-CheckKind -Order shims, windowsApps -Command python | Should -Be 'ok'
    }

    It 'python が WindowsApps のスタブから解決されたら落ちる' {
        Get-CheckKind -Order windowsApps, shims -Command python | Should -Be 'ng_wrong_source'
    }

    It 'pwsh は PowerShell 7 から解決されれば通る' {
        Get-CheckKind -Order pwsh7, windowsApps -Command pwsh | Should -Be 'ok'
    }

    It 'pwsh が PowerShell 7 以外から解決されたら落ちる' {
        Get-CheckKind -Order windowsApps, pwsh7 -Command pwsh | Should -BeLike 'ng_*'
    }

    It 'bash は Git の usr/bin から解決されれば通る' {
        Get-CheckKind -Order gitUsr, windowsApps -Command bash | Should -Be 'ok'
    }

    It 'bash が WindowsApps から解決されたら落ちる' {
        Get-CheckKind -Order windowsApps, gitUsr -Command bash | Should -BeLike 'ng_*'
    }
}
