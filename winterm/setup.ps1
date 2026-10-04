#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"
. "$PSScriptRoot/../lib/Merge-JsonSettings.ps1"

# Windows Terminal writes a profile with a generated GUID for every shell it
# discovers, so profiles.list and defaultProfile differ per machine and the
# file is merged rather than linked. The sample owns profiles.defaults, which
# applies to every profile without naming one.
$settingsPath = Join-Path $env:LOCALAPPDATA 'Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json'
if (-not (Test-Path -LiteralPath $settingsPath)) {
  Write-DotfileWarn "Windows Terminal settings not found at $settingsPath; start Windows Terminal once, then re-run"
  return
}

Update-JsonSettingsFile `
  -SettingsPath $settingsPath `
  -SamplePath (Join-Path $PSScriptRoot 'settings.sample.json') `
  -ProtectedKeys @('defaultProfile') | Out-Null
