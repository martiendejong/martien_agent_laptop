$config = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key; 'Content-Type' = 'application/json' }

# 869ccun2h - URLs API 500 error - FIXED (was pending migrations)
$taskId = '869ccun2h'
Write-Host "Moving $taskId to testing..."
$body = '{"status":"testing"}'
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $body -ErrorAction Stop | Out-Null
$comment = @{ comment_text = "ROOT CAUSE: 4 pending EF migrations not applied (AddBlogPostIdToFAQ, AddFaqEnabledField, AddDocumentsStatusToWorkflow, AddKnowledgeSources). Backend auto-migrates on startup but the running instance predated these migrations.`n`nFIX: Restarted backend. All 4 migrations now applied. URLs API returns 200 OK.`n`nNo code changes needed - this was a deployment issue. Moving to TESTING." } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Post -Body $comment -ErrorAction Stop | Out-Null
Write-Host "  Done"

# 869c7mt8c - Page Advisor blocked (same root cause)
$taskId = '869c7mt8c'
Write-Host "Moving $taskId to testing..."
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $body -ErrorAction Stop | Out-Null
$comment = @{ comment_text = "The /urls API 500 error was caused by 4 pending EF migrations (FaqEnabled column missing). Backend restarted, migrations applied. URLs API now returns 200 OK. Page Advisor depends on working URLs API - should now be functional. Moving to TESTING." } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Post -Body $comment -ErrorAction Stop | Out-Null
Write-Host "  Done"

# 869ccubck - FAQ from URL cards - back in todo with vite error
$taskId = '869ccubck'
Write-Host "`nReading latest comment on $taskId..."
$comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Get -ErrorAction Stop
$latest = $comments.comments[0]
Write-Host "Latest comment: $($latest.comment_text.Substring(0, [Math]::Min(300, $latest.comment_text.Length)))..."

Write-Host "`nDone."
