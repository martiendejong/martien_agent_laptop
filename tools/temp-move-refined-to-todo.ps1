$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $apiKey; 'Content-Type' = 'application/json' }

# SEO God tasks
$seoGodTasks = @('869ccvyjd', '869ccvyh3')
Write-Host "=== Moving SEO God Tasks to TODO ===" -ForegroundColor Cyan
foreach ($taskId in $seoGodTasks) {
    $body = @{ status = 'todo' } | ConvertTo-Json
    $url = "https://api.clickup.com/api/v2/task/$taskId"
    Write-Host "Moving task $taskId to todo..."
    try {
        Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body | Out-Null
        Write-Host "  [OK] Moved to todo" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] Failed: $_" -ForegroundColor Red
    }
}

# Bliek tasks
$bliekTasks = @('869cc94k3', '869cc0j5y', '869cc0j4z', '869cc0j1p')
Write-Host "`n=== Moving Bliek Tasks to TODO ===" -ForegroundColor Cyan
foreach ($taskId in $bliekTasks) {
    $body = @{ status = 'todo' } | ConvertTo-Json
    $url = "https://api.clickup.com/api/v2/task/$taskId"
    Write-Host "Moving task $taskId to todo..."
    try {
        Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body | Out-Null
        Write-Host "  [OK] Moved to todo" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] Failed: $_" -ForegroundColor Red
    }
}

Write-Host "`n=== All tasks moved to todo status! ===" -ForegroundColor Green
