param([string]$TaskId)
$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'

$task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId" -Headers @{ Authorization = $apiKey }
Write-Host "=== $($task.name) ==="
Write-Host "Priority: $($task.priority.priority)"
Write-Host "Status: $($task.status.status)"
Write-Host ""
Write-Host "Description:"
Write-Host $task.description
Write-Host ""

$comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId/comment" -Headers @{ Authorization = $apiKey }
Write-Host "=== Comments ($($comments.comments.Count)) ==="
foreach ($c in $comments.comments) {
    Write-Host "[$($c.date)] $($c.comment_text)"
    Write-Host "---"
}
