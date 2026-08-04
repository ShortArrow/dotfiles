#!pwsh
. "$PSScriptRoot/../lib/_lib.ps1"
. "$PSScriptRoot/Merge-ClaudeSettings.ps1"

Set-DotfileLinks -ToolName 'claude'

# Helpful nudge: Teams notifier needs $USERPROFILE/.claude/.env
$envPath = Join-Path $env:USERPROFILE '.claude/.env'
if (-not (Test-Path -LiteralPath $envPath)) {
  Write-DotfileWarn ".env not found at $envPath"
  Write-DotfileWarn "  copy from $PSScriptRoot/env.sample and set TEAMS_WEBHOOK_URL"
}

# settings.json stays machine-local because it carries this machine's
# permission rules, so the shared keys are merged in rather than linked.
$settingsPath = Join-Path $env:USERPROFILE '.claude/settings.json'
$samplePath = Join-Path $PSScriptRoot 'settings.sample.json'

$sample = Get-Content -LiteralPath $samplePath -Raw | ConvertFrom-Json
$current = if (Test-Path -LiteralPath $settingsPath) {
  Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
} else {
  $null
}

$merged = Merge-ClaudeSettings -Current $current -Sample $sample
$rendered = $merged | ConvertTo-Json -Depth 20

$unchanged = ($null -ne $current) -and
             ((ConvertTo-CanonicalJson -InputObject $current) -eq
              (ConvertTo-CanonicalJson -InputObject $merged))

if ($unchanged) {
  Write-DotfileOk "noop  $settingsPath"
} else {
  if (Test-Path -LiteralPath $settingsPath) {
    $bak = "$settingsPath.bak.$(Get-Date -Format yyyyMMddHHmmss)"
    Copy-Item -LiteralPath $settingsPath -Destination $bak
    Write-DotfileWarn "backup $settingsPath -> $bak"
  }
  $parent = Split-Path -Parent $settingsPath
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  Set-Content -LiteralPath $settingsPath -Value $rendered -Encoding UTF8
  Write-DotfileOk "merged $settingsPath"
}
