param(
    [string]$Message,
    [string]$EnvFile = "$env:USERPROFILE\.claude\.env"
)

# Load Hooks input from stdin
$hookInput = $null
if ([Console]::IsInputRedirected) {
    $stdinContent = [Console]::In.ReadToEnd()
    if ($stdinContent) {
        try {
            $hookInput = $stdinContent | ConvertFrom-Json
        } catch {
            # Ignore failed json parse
        }
    }
}

# Message is not Specified, generate from Hooks input
if (-not $Message) {
    if ($hookInput -and $hookInput.hook_event_name) {
        switch ($hookInput.hook_event_name) {
            "Stop" {
                $Message = "✅ Claude Code: Complete"
            }
            "Notification" {
                # notification_typeで分岐
                $emoji = switch ($hookInput.notification_type) {
                    "permission_prompt"   { "🔐" }
                    "idle_prompt"         { "💤" }
                    "auth_success"        { "🔓" }
                    "elicitation_dialog"  { "✋" }
                    default               { "🔔" }
                }
                $Message = "$emoji $($hookInput.message)"
            }
            "UserPromptSubmit" {
                # Include User Prompt
                $prompt = $hookInput.prompt
                if ($prompt.Length -gt 100) {
                    $prompt = $prompt.Substring(0, 100) + "..."
                }
                $Message = "📝 User: $prompt"
            }
            "SessionStart" {
                $sessionId = $hookInput.session_id
                $Message = "🟢 Claude Code: Session Start (id: $sessionId)"
            }
            "SessionEnd" {
                $sessionId = $hookInput.session_id
                $Message = "🛑 Claude Code: Session Ended (id: $sessionId)"
            }
            default {
                $Message = "Claude Code: $($hookInput.hook_event_name)"
            }
        }
    } else {
        $Message = "Notification from Claude Code"
    }
}

# Load .env
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim() -replace '^["'']|["'']$', ''
            Set-Item -Path "Env:$name" -Value $value
        }
    }
}

$webhookUrl = $env:TEAMS_WEBHOOK_URL

if (-not $webhookUrl) {
    Write-Error "TEAMS_WEBHOOK_URL not found in $EnvFile"
    exit 1
}

$body = @{ text = $Message } | ConvertTo-Json -Compress

try {
    Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json; charset=utf-8" -Body $body | Out-Null
    Write-Host "✓ Teams notification sent" -ForegroundColor Green
} catch {
    Write-Error "Failed to send Teams notification: $_"
    exit 1
}
