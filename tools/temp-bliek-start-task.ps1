# Start Bliek email notification task
$taskId = '869cc0j1p'
$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'

# Post working comment
$comment = @{
    comment_text = @"
AGENT WORKING

Agent ID: agent-007
Session Start: $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
Branch: feature/email-notifications-869cc0j1p

Implementation Plan:
1. SMTP email service integration (SendGrid)
2. Email templates for all event types
3. NotificationService with queue system
4. NotificationPreference entity
5. Background job for reminders
6. Settings UI for preferences

This task is now being actively worked on.
Other agents: Please do not pick up this task.

-- Claude Code Agent (agent-007)
"@
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" `
    -Method Post `
    -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
    -Body $comment | Out-Null

Write-Host "Comment posted" -ForegroundColor Green

# Update to busy and assign
$update = @{
    status = 'busy'
    assignees = @{
        add = @(74525428)
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" `
    -Method Put `
    -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
    -Body $update | Out-Null

Write-Host "Task moved to BUSY and assigned" -ForegroundColor Green
