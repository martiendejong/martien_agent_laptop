$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$taskId = '869cc0j4z'

$task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" `
    -Method Get `
    -Headers @{Authorization=$apiKey}

Write-Host "=== TASK: $($task.name) ===" -ForegroundColor Cyan
Write-Host "Status: $($task.status.status)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Description:" -ForegroundColor Green
Write-Host $task.description
Write-Host ""
Write-Host "Comments:" -ForegroundColor Green
if ($task.comments) {
    foreach ($comment in $task.comments) {
        Write-Host "---"
        Write-Host "From: $($comment.user.username)"
        Write-Host "Date: $($comment.date)"
        Write-Host $comment.comment_text
    }
} else {
    Write-Host "(No comments)"
}
