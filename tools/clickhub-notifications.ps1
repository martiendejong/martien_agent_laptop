# ClickHub Notifications System
# Version: 1.0.0
# Created: 2026-02-28

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("TaskBlocked", "FailurePattern", "SuccessRateDrop", "DailyDigest", "AgentTimeout", "TaskCompleted")]
    [string]$EventType,

    [Parameter(Mandatory=$false)]
    [hashtable]$Data,

    [Parameter(Mandatory=$false)]
    [switch]$Test
)

$configFile = "C:\scripts\_machine\clickhub-notifications-config.json"

# Load config
$config = Get-Content $configFile | ConvertFrom-Json

if (-not $config.enabled) {
    if ($Test) { Write-Host "Notifications disabled" -ForegroundColor Yellow }
    return
}

# Send Slack notification
function Send-SlackNotification {
    param($channel, $message, $color = "good")

    if (-not $config.channels.slack.enabled) { return }

    $webhook = $config.channels.slack.webhook_url
    if (-not $webhook) {
        Write-Host "Slack webhook not configured" -ForegroundColor Yellow
        return
    }

    $payload = @{
        channel = $channel
        attachments = @(
            @{
                color = $color
                text = $message
                mrkdwn = $true
            }
        )
    } | ConvertTo-Json -Depth 10

    try {
        Invoke-RestMethod -Uri $webhook -Method Post -Body $payload -ContentType "application/json" | Out-Null
        Write-Host "[SLACK] Notification sent to $channel" -ForegroundColor Green
    } catch {
        Write-Host "[SLACK] Failed to send: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Send email notification
function Send-EmailNotification {
    param($recipients, $subject, $body)

    if (-not $config.channels.email.enabled) { return }

    $smtp = $config.channels.email.smtp_server
    $port = $config.channels.email.smtp_port
    $from = $config.channels.email.from_address

    if (-not $from) {
        Write-Host "Email from_address not configured" -ForegroundColor Yellow
        return
    }

    # TODO: Implement SMTP send (requires credentials)
    # For now, log to file
    $emailLog = "C:\scripts\_machine\email-notifications.log"
    $logEntry = @"
[$(Get-Date -Format 'o')]
To: $($recipients -join ', ')
Subject: $subject
Body: $body
---
"@
    Add-Content -Path $emailLog -Value $logEntry

    Write-Host "[EMAIL] Notification logged (SMTP not configured)" -ForegroundColor Yellow
}

# Generate notification based on event type
switch ($EventType) {
    "TaskBlocked" {
        $rule = $config.notification_rules.on_task_blocked
        if (-not $rule.enabled) { return }

        $message = @"
🚨 *TASK BLOCKED*

Task: $($Data.task_id) - $($Data.task_name)
Project: $($Data.project)
Reason: $($Data.reason)
Duration: $($Data.hours_blocked) hours

Action Required: Review and unblock
Task URL: https://app.clickup.com/t/$($Data.task_id)
"@

        foreach ($channel in $rule.channels) {
            if ($channel -match "slack\.(.+)") {
                $slackChannel = $config.channels.slack.channels.$($matches[1])
                Send-SlackNotification -channel $slackChannel -message $message -color "danger"
            }
            elseif ($channel -match "email\.(.+)") {
                $recipients = $config.channels.email.recipients.$($matches[1])
                Send-EmailNotification -recipients $recipients -subject "ClickHub: Task Blocked" -body $message
            }
        }
    }

    "FailurePattern" {
        $rule = $config.notification_rules.on_failure_pattern
        if (-not $rule.enabled) { return }

        $message = @"
⚠️ *FAILURE PATTERN DETECTED*

Pattern: $($Data.pattern)
Occurrences: $($Data.count)
Solution: $($Data.solution)
Projects Affected: $($Data.projects -join ', ')

This pattern has occurred $($Data.count) times. Consider systematic fix.
"@

        foreach ($channel in $rule.channels) {
            if ($channel -match "slack\.(.+)") {
                $slackChannel = $config.channels.slack.channels.$($matches[1])
                Send-SlackNotification -channel $slackChannel -message $message -color "warning"
            }
        }
    }

    "SuccessRateDrop" {
        $rule = $config.notification_rules.on_success_rate_drop
        if (-not $rule.enabled) { return }

        $message = @"
📉 *SUCCESS RATE DROPPED*

Current Success Rate: $($Data.current_rate)%
Previous Success Rate: $($Data.previous_rate)%
Drop: $($Data.drop_percentage)%

Top Failures:
$($Data.top_failures | ForEach-Object { "- $($_.pattern) (x$($_.count))" } -join "`n")

Action Required: Investigate recent failures
"@

        foreach ($channel in $rule.channels) {
            if ($channel -match "slack\.(.+)") {
                $slackChannel = $config.channels.slack.channels.$($matches[1])
                Send-SlackNotification -channel $slackChannel -message $message -color "danger"
            }
        }
    }

    "DailyDigest" {
        $rule = $config.notification_rules.daily_digest
        if (-not $rule.enabled) { return }

        $message = @"
📊 *CLICKHUB DAILY DIGEST* - $(Get-Date -Format 'yyyy-MM-dd')

*Tasks Today:* $($Data.tasks_processed)
*Success Rate:* $($Data.success_rate)%
*Avg Completion:* $($Data.avg_completion) min
*Cost Today:* EUR $($Data.cost)

*Top Failures:*
$($Data.top_failures | ForEach-Object { "- $($_.pattern) (x$($_.count))" } -join "`n")

*Agent Performance:*
$($Data.agents | ForEach-Object { "- $($_.id): $($_.tasks) tasks, $($_.success_rate)% success" } -join "`n")
"@

        foreach ($channel in $rule.channels) {
            if ($channel -match "slack\.(.+)") {
                $slackChannel = $config.channels.slack.channels.$($matches[1])
                Send-SlackNotification -channel $slackChannel -message $message -color "good"
            }
            elseif ($channel -match "email\.(.+)") {
                $recipients = $config.channels.email.recipients.$($matches[1])
                Send-EmailNotification -recipients $recipients -subject "ClickHub Daily Digest" -body $message
            }
        }
    }

    "TaskCompleted" {
        # Success notification (optional, low priority)
        $message = @"
✅ *TASK COMPLETED*

Task: $($Data.task_id) - $($Data.task_name)
Project: $($Data.project)
Agent: $($Data.agent_id)
Duration: $($Data.completion_minutes) minutes
PR: $($Data.pr_url)
"@

        if ($config.channels.slack.enabled) {
            Send-SlackNotification -channel "#dev-updates" -message $message -color "good"
        }
    }
}

if ($Test) {
    Write-Host "`n=== NOTIFICATION TEST ===" -ForegroundColor Cyan
    Write-Host "Event Type: $EventType" -ForegroundColor White
    Write-Host "Config loaded: $($config.enabled)" -ForegroundColor White
    Write-Host "Slack enabled: $($config.channels.slack.enabled)" -ForegroundColor White
    Write-Host "Email enabled: $($config.channels.email.enabled)" -ForegroundColor White
}
