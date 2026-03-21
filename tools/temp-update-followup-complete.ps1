$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$taskId = '869cc0j5y'

$comment = @{
    comment_text = "✅ AGENT COMPLETED

Agent ID: agent-012
PR: #89 - https://github.com/martiendejong/real-estate-agency-ai/pull/89
Files: 14 changed, 2089 insertions

Automated follow-up system backend complete. Frontend dashboard pending.

-- Claude Code Agent (agent-012)"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" `
    -Method Post `
    -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
    -Body $comment | Out-Null

$update = @{ status = 'review' } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" `
    -Method Put `
    -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
    -Body $update | Out-Null

Write-Host "Task moved to REVIEW" -ForegroundColor Green
