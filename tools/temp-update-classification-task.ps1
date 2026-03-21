$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$taskId = '869cc94k3'

$comment = @{
    comment_text = "✅ AGENT COMPLETED

Agent ID: agent-011
PR: #88 - https://github.com/martiendejong/real-estate-agency-ai/pull/88
Files: 9 changed, 1458 insertions

AI message classification MVP ready for review.

-- Claude Code Agent (agent-011)"
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
