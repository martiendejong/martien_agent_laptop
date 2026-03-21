$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $apiKey }

# Check the 2 SEO God tasks from earlier
$seoTasks = @('869ccvyjd', '869ccvyh3')
Write-Host 'SEO God Previous Tasks:' -ForegroundColor Cyan
foreach ($id in $seoTasks) {
    try {
        $task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id" -Headers $headers
        Write-Host "  $id: $($task.status.status) - $($task.name.Substring(0, [Math]::Min(60, $task.name.Length)))" -ForegroundColor Yellow
    } catch {
        Write-Host "  $id: ERROR - $_" -ForegroundColor Red
    }
}

# Check the 4 Bliek tasks from earlier
$bliekTasks = @('869cc94k3', '869cc0j5y', '869cc0j4z', '869cc0j1p')
Write-Host "`nBliek Previous Tasks:" -ForegroundColor Cyan
foreach ($id in $bliekTasks) {
    try {
        $task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id" -Headers $headers
        Write-Host "  $id: $($task.status.status) - $($task.name.Substring(0, [Math]::Min(60, $task.name.Length)))" -ForegroundColor Yellow
    } catch {
        Write-Host "  $id: ERROR - $_" -ForegroundColor Red
    }
}
