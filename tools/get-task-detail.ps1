param([string]$TaskId)
$apiKey = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
$task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId" `
    -Headers @{ Authorization = $apiKey }
Write-Host "=== $($task.name) ==="
Write-Host $task.text_content
Write-Host "=== COMMENTS ==="
$comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId/comment" `
    -Headers @{ Authorization = $apiKey }
foreach ($c in $comments.comments) {
    Write-Host "[$($c.date)] $($c.comment_text)"
}
