#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"
Set-DotfileLinks -ToolName 'claude'

# Helpful nudge: Teams notifier needs $USERPROFILE/.claude/.env
$envPath = Join-Path $env:USERPROFILE '.claude/.env'
if (-not (Test-Path -LiteralPath $envPath)) {
  Write-DotfileWarn ".env not found at $envPath"
  Write-DotfileWarn "  copy from $PSScriptRoot/env.sample and set TEAMS_WEBHOOK_URL"
}

# Helpful nudge: settings.json stays machine-local because it carries this
# machine's permission rules, so the shared keys are merged by hand.
$settingsPath = Join-Path $env:USERPROFILE '.claude/settings.json'
$settings = if (Test-Path -LiteralPath $settingsPath) {
  Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
}
if (-not $settings.env.CLAUDE_CODE_USE_POWERSHELL_TOOL) {
  Write-DotfileWarn "CLAUDE_CODE_USE_POWERSHELL_TOOL not set in $settingsPath"
  Write-DotfileWarn "  merge the env block from $PSScriptRoot/settings.sample.json"
}
