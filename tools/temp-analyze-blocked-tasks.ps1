$config = Get-Content 'C:/scripts/_machine/clickup-config.json' | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key }

$blockedTasks = @(
    '869ccfvqa',  # Email/WhatsApp buttons
    '869cc94k3',  # AI message classification
    '869cc94k0',  # Message-to-property linking
    '869cc94jx',  # Background IMAP sync
    '869cc0j5y',  # Automated follow-ups
    '869cc0j1p'   # Email notifications
)

foreach ($taskId in $blockedTasks) {
    $task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Task: $($task.name)" -ForegroundColor Yellow
    Write-Host "ID: $taskId" -ForegroundColor Gray
    Write-Host "Status: $($task.status.status)" -ForegroundColor Magenta
    Write-Host "`nDescription:" -ForegroundColor Green
    Write-Host $task.description

    # Get latest comment
    if ($task.comments -and $task.comments.Count -gt 0) {
        $latestComment = $task.comments | Sort-Object -Property date -Descending | Select-Object -First 1
        Write-Host "`nLatest Comment:" -ForegroundColor Cyan
        Write-Host $latestComment.comment_text
    }
}
