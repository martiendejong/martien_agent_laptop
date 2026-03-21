$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $apiKey }

$taskIds = @('869cc94k3', '869cc0j5y', '869cc0j4z', '869cc0j1p')

Write-Host "=== Checking Bliek Task Statuses ===" -ForegroundColor Cyan
foreach ($taskId in $taskIds) {
    $url = "https://api.clickup.com/api/v2/task/$taskId"
    $task = Invoke-RestMethod -Uri $url -Headers $headers
    Write-Host "Task: $($task.name)" -ForegroundColor Yellow
    Write-Host "  Status: $($task.status.status)" -ForegroundColor Green
    Write-Host "  ID: $taskId"
    Write-Host ""
}
