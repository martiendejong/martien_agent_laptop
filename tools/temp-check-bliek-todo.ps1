$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $apiKey }
$url = 'https://api.clickup.com/api/v2/list/901216032110/task?archived=false&subtasks=false&statuses[]=todo'
$response = Invoke-RestMethod -Uri $url -Headers $headers
Write-Host "Bliek TODO tasks: $($response.tasks.Count)" -ForegroundColor Cyan
$response.tasks | ForEach-Object {
    Write-Host "  - $($_.name) ($($_.id))" -ForegroundColor Yellow
}
