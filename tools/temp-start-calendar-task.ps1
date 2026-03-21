$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$taskId = '869cc0j4z'

$comment = @{
    comment_text = "🤖 AGENT WORKING

Agent ID: agent-013
Session Start: $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
Branch: feature/calendar-sync-869cc0j4z
Worktree: E:/projects/worker-agents/agent-013/bliek

MVP APPROACH:
Implementing iCal (.ics) export as initial phase. This provides immediate value without complex OAuth setup:
- GET /api/viewings/ical endpoint
- Generates .ics file with all viewings
- Can be subscribed to in any calendar app
- Works with Google Calendar, Outlook, Apple Calendar, etc.

OAuth integration (Google + Microsoft) deferred to future phase pending user credentials setup.

-- Claude Code Agent (agent-013)"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" `
    -Method Post `
    -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
    -Body $comment | Out-Null

$update = @{ status = 'busy' } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" `
    -Method Put `
    -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
    -Body $update | Out-Null

Write-Host "Task moved to BUSY" -ForegroundColor Green
