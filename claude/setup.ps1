#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"
. "$PSScriptRoot/../lib/Merge-JsonSettings.ps1"

Set-DotfileLinks -ToolName 'claude'

# Helpful nudge: Teams notifier needs $USERPROFILE/.claude/.env
$envPath = Join-Path $env:USERPROFILE '.claude/.env'
if (-not (Test-Path -LiteralPath $envPath)) {
  Write-DotfileWarn ".env not found at $envPath"
  Write-DotfileWarn "  copy from $PSScriptRoot/env.sample and set TEAMS_WEBHOOK_URL"
}

# settings.json stays machine-local because it carries this machine's
# permission rules, so the shared keys are merged in rather than linked.
# A shared allowlist would hand every machine the rules of whichever machine
# wrote it last, so `permissions` never travels.
Update-JsonSettingsFile `
  -SettingsPath (Join-Path $env:USERPROFILE '.claude/settings.json') `
  -SamplePath (Join-Path $PSScriptRoot 'settings.sample.json') `
  -ProtectedKeys @('permissions') | Out-Null
