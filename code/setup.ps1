#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"
. "$PSScriptRoot/../lib/Merge-JsonSettings.ps1"

Set-DotfileLinks -ToolName 'code'

# VS Code writes a setting into settings.json whenever one is changed in the
# UI or an extension prompt is dismissed, so a linked file turned every click
# into a repository diff. The sample holds what every machine shares; the
# rest stays in the machine's own file. A settings.json still linked to the
# repository becomes a regular file first, so the merge lands on the machine,
# not the sample. Once the linked file is gone, its last committed content
# seeds the conversion and the machine keeps the keys the sample left out.
$settingsPath = Join-Path $env:APPDATA 'Code/User/settings.json'
$repoRoot = Split-Path -Parent $PSScriptRoot
$lastLinked = git -C $repoRoot log -1 --format=%H -- code/settings.json 2>$null
$seed = if ($lastLinked) { (git -C $repoRoot show "${lastLinked}^:code/settings.json" 2>$null) -join "`n" }
if (-not $seed) { $seed = '{}' }

if ((Convert-SettingsLinkToFile -Path $settingsPath -FallbackContent $seed) -eq 'converted') {
  Write-DotfileWarn "unlinked $settingsPath (now a regular file)"
}

Update-JsonSettingsFile `
  -SettingsPath $settingsPath `
  -SamplePath (Join-Path $PSScriptRoot 'settings.sample.json') | Out-Null
