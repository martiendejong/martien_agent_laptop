$config = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key; 'Content-Type' = 'application/json' }

$listId = '901215927087'

# Get ALL tasks to find backlogs
$result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?include_closed=false&subtasks=true" -Headers $headers -Method Get -ErrorAction Stop

Write-Host "=== ALL SEO GOD TASKS ==="
Write-Host ""

foreach ($task in $result.tasks) {
    $status = $task.status.status
    Write-Host "[$status] $($task.id) - $($task.name)"

    # Get last comment for each task
    try {
        $comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" -Headers $headers -Method Get -ErrorAction Stop
        if ($comments.comments.Count -gt 0) {
            $lastComment = $comments.comments[0].comment_text
            if ($lastComment.Length -gt 150) { $lastComment = $lastComment.Substring(0, 150) + "..." }
            Write-Host "  Last comment: $lastComment"
        }
    } catch {}
    Write-Host ""
}

Write-Host "=== BACKLOG ONLY ==="
$backlogTasks = $result.tasks | Where-Object { $_.status.status -eq 'backlog' }
Write-Host "Found $($backlogTasks.Count) backlog tasks:"
foreach ($task in $backlogTasks) {
    Write-Host "  $($task.id) - $($task.name)"
    Write-Host "  Description: $($task.description)"
    Write-Host ""
}
