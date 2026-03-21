$config = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key; 'Content-Type' = 'application/json' }

$taskId = '869ccfmh3'
Write-Host "Moving 869ccfmh3 (Knowledge Sources) to testing..."
$body = '{"status":"testing"}'
$result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $body -ErrorAction Stop
Write-Host "  Status: $($result.status.status)"

$comment = '{"comment_text":"Feature already implemented and on develop (commits 7489ec0, cf6b891). KnowledgeSourcesPage.tsx fully functional with CRUD + crawl. Moving to TESTING."}'
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Post -Body $comment -ErrorAction Stop | Out-Null
Write-Host "  Comment added. Done."
