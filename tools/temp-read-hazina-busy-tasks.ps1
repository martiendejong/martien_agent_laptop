$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $apiKey }

$taskIds = @('869c6y96p', '869c5wk6z')

foreach ($taskId in $taskIds) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    $url = "https://api.clickup.com/api/v2/task/$taskId"
    $task = Invoke-RestMethod -Uri $url -Headers $headers

    Write-Host "TASK: $($task.name)" -ForegroundColor Yellow
    Write-Host "ID: $taskId"
    Write-Host "Status: $($task.status.status)"
    Write-Host "Priority: $($task.priority.priority)"
    Write-Host "`nDESCRIPTION:" -ForegroundColor Green
    Write-Host $task.description

    # Get comments
    $commentsUrl = "https://api.clickup.com/api/v2/task/$taskId/comment"
    $comments = Invoke-RestMethod -Uri $commentsUrl -Headers $headers

    if ($comments.comments.Count -gt 0) {
        Write-Host "`nCOMMENTS ($($comments.comments.Count)):" -ForegroundColor Magenta
        foreach ($comment in $comments.comments) {
            Write-Host "`n---"
            Write-Host "Date: $($comment.date)"
            Write-Host "User: $($comment.user.username)"
            Write-Host "Text: $($comment.comment_text)"
        }
    } else {
        Write-Host "`nNo comments" -ForegroundColor Gray
    }
    Write-Host "========================================`n"
}
