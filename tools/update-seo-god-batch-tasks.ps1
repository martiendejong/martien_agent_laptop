$h = @{ Authorization = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'; 'Content-Type' = 'application/json' }

$tasks = @('869cdpzmt', '869cdpy7n', '869cdpxh6', '869cdpxgc', '869cdpwz7', '869cdpwyf')

foreach ($id in $tasks) {
    # Move to review
    $body = @{ status = 'review'; assignees = @(@{ id = '74525428' }) } | ConvertTo-Json -Depth 3
    Invoke-RestMethod -Method Put -Uri "https://api.clickup.com/api/v2/task/$id" -Headers $h -Body $body | Out-Null
    Write-Host "Moved $id to review"

    # Comment
    $comment = @{ comment_text = "AGENT COMPLETED`n`nPR #141: https://github.com/martiendejong/seo-god/pull/141`nBranch: feature/task-seo-god-batch-backlog`n`nAll 6 tasks implemented in single PR. Ready for review.`n`n-- Claude Code Agent (agent-001)" } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "https://api.clickup.com/api/v2/task/$id/comment" -Headers $h -Body $comment | Out-Null
    Write-Host "Commented on $id"
}
Write-Host "All 6 tasks moved to review."
