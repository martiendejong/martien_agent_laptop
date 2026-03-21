$config = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key; 'Content-Type' = 'application/json' }

# Task 869ccfy0t - Download button fix
$taskId = '869ccfy0t'
Write-Host "Moving $taskId (Download Button) to review..."
$body = '{"status":"review"}'
$result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $body -ErrorAction Stop
Write-Host "  Status: $($result.status.status)"

$comment = @{
    comment_text = "PR #68: https://github.com/martiendejong/seo-god/pull/68`n`nFixes:`n- Added /api/wordpress/plugin/download backend endpoint (ZipArchive)`n- Fixed frontend download link to use full API URL instead of relative path`n`nTESTING INSTRUCTIONS:`n1. Navigate to Dashboard`n2. Verify Download Plugin button is visible when plugin not detected`n3. Click Download Plugin - should download seo-god.zip`n4. Verify zip contains plugin files"
} | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Post -Body $comment -ErrorAction Stop | Out-Null
Write-Host "  Comment added."

# Task 869ccubck - FAQ from URL cards
$taskId = '869ccubck'
Write-Host "`nMoving $taskId (FAQ from URL Cards) to review..."
$result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $body -ErrorAction Stop
Write-Host "  Status: $($result.status.status)"

$comment = @{
    comment_text = "PR #68: https://github.com/martiendejong/seo-god/pull/68`n`nImplementation:`n- Added Actions column to URLsPage with FAQ navigation button per URL`n- FAQPage now accepts url_id query param for per-URL FAQ filtering`n- Back to URLs navigation link when viewing filtered FAQs`n`nTESTING INSTRUCTIONS:`n1. Navigate to URLs page`n2. Verify new Actions column with FAQ button per row`n3. Click FAQ button on any URL row`n4. Verify navigation to /faq?url_id=... with Back to URLs link`n5. Verify FAQs are filtered for that specific URL"
} | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Post -Body $comment -ErrorAction Stop | Out-Null
Write-Host "  Comment added."

Write-Host "`nDone! Both tasks moved to review."
