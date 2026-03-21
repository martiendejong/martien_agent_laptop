$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$listId = '901216032110'

$tasks = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task" `
    -Method Get `
    -Headers @{Authorization=$apiKey}

Write-Host "=== TASKS IN REVIEW ===" -ForegroundColor Cyan
$reviewTasks = $tasks.tasks | Where-Object { $_.status.status -eq 'review' }

if ($reviewTasks.Count -eq 0) {
    Write-Host "No tasks in review status" -ForegroundColor Yellow
} else {
    foreach ($task in $reviewTasks) {
        Write-Host ""
        Write-Host "ID: $($task.id)" -ForegroundColor Green
        Write-Host "Name: $($task.name)" -ForegroundColor White
        Write-Host "Status: $($task.status.status)" -ForegroundColor Yellow
    }
}
