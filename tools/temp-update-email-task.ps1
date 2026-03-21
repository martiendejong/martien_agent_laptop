$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$taskId = '869cc0j1p'

$comment = @{
    comment_text = "AGENT COMPLETED

Agent ID: agent-010
PR: #87 - https://github.com/martiendejong/real-estate-agency-ai/pull/87
Files: 11 changed, 1878 insertions

Infrastructure ready for review.

-- Claude Code Agent (agent-010)"
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
