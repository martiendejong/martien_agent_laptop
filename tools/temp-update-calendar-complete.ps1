$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$taskId = '869cc0j4z'

$comment = @{
    comment_text = "✅ AGENT COMPLETED

Agent ID: agent-013
PR: #90 - https://github.com/martiendejong/real-estate-agency-ai/pull/90
Files: 4 changed, 236 insertions

iCal calendar export MVP complete. OAuth integration deferred.

-- Claude Code Agent (agent-013)"
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
