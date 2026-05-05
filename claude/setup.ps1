#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"
Set-DotfileLinks -ToolName 'claude'

# Helpful nudge: Teams notifier needs $USERPROFILE/.claude/.env
$envPath = Join-Path $env:USERPROFILE '.claude/.env'
if (-not (Test-Path -LiteralPath $envPath)) {
  Write-DotfileWarn ".env not found at $envPath"
  Write-DotfileWarn "  copy from $PSScriptRoot/env.sample and set TEAMS_WEBHOOK_URL"
}
