#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"
. "$PSScriptRoot/../lib/Merge-JsonSettings.ps1"

Set-DotfileLinks -ToolName 'codeinsiders'

# Same arrangement as code/setup.ps1, for the same reason: a linked
# settings.json turned every UI change into a repository diff, and carried
# values that hold on one machine only, such as an absolute path under the
# user's profile. The sample holds what every machine shares; the rest stays
# in the machine's own file.
$settingsPath = Join-Path $env:APPDATA 'Code - Insiders/User/settings.json'
$repoRoot = Split-Path -Parent $PSScriptRoot
$lastLinked = git -C $repoRoot log -1 --format=%H -- codeinsiders/settings.json 2>$null
$seed = if ($lastLinked) { (git -C $repoRoot show "${lastLinked}^:codeinsiders/settings.json" 2>$null) -join "`n" }
if (-not $seed) { $seed = '{}' }

if ((Convert-SettingsLinkToFile -Path $settingsPath -FallbackContent $seed) -eq 'converted') {
  Write-DotfileWarn "unlinked $settingsPath (now a regular file)"
}

Update-JsonSettingsFile `
  -SettingsPath $settingsPath `
  -SamplePath (Join-Path $PSScriptRoot 'settings.sample.json') | Out-Null
