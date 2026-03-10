$api_key = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $api_key }
$listId = '901215927087'

# Get list info
$listInfo = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId" -Headers $headers
Write-Host "=== $($listInfo.name) ===" -ForegroundColor Cyan
Write-Host "Statuses: $($listInfo.statuses | % { $_.status }) " -ForegroundColor Gray
Write-Host ""

# Get ALL tasks
$resp = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?page=0&include_closed=true" -Headers $headers
Write-Host "Total tasks: $($resp.tasks.Count)"
Write-Host ""

$backlog = $resp.tasks | Where-Object { $_.status.status -match 'backlog' }
Write-Host "=== BACKLOG TASKS ($($backlog.Count)) ===" -ForegroundColor Magenta
foreach ($t in $backlog) {
    Write-Host ""
    Write-Host "ID: $($t.id)" -ForegroundColor Yellow
    Write-Host "Name: $($t.name)"
    Write-Host "Status: $($t.status.status)"
    Write-Host "Priority: $($t.priority.priority)"
    $desc = if ($t.description) { $t.description.Substring(0, [Math]::Min($t.description.Length, 300)) } else { "(no description)" }
    Write-Host "Description: $desc"
}
