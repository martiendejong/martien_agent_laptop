$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$taskId = '869cc0j5y'

$comment = @{
    comment_text = "🤖 AGENT WORKING

Agent ID: agent-012
Session Start: $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
Branch: feature/automated-followups-869cc0j5y
Worktree: E:/projects/worker-agents/agent-012/bliek

Implementing automated follow-up and reminder system.

-- Claude Code Agent (agent-012)"
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
