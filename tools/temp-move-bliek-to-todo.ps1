$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $apiKey; 'Content-Type' = 'application/json' }

$taskIds = @('869cc94k3', '869cc0j5y', '869cc0j4z', '869cc0j1p')

Write-Host "=== Moving Bliek Tasks from BUSY to TODO ===" -ForegroundColor Cyan
foreach ($taskId in $taskIds) {
    $body = @{ status = 'todo' } | ConvertTo-Json
    $url = "https://api.clickup.com/api/v2/task/$taskId"
    Write-Host "Moving task $taskId to todo..."
    try {
        $response = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body
        Write-Host "  [OK] Moved to: $($response.status.status)" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] Failed: $_" -ForegroundColor Red
    }
}
