$apiKey = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
$apiBase = "https://api.clickup.com/api/v2"
$headers = @{
    "Authorization" = $apiKey
    "Content-Type" = "application/json"
}

$taskData = Get-Content "C:\scripts\_machine\temp-cm-refinements.json" -Raw | ConvertFrom-Json
$total = $taskData.Count
Write-Host "Updating $total client-manager tasks" -ForegroundColor Cyan

for ($i = 0; $i -lt $total; $i++) {
    $task = $taskData[$i]
    Write-Host "[$($i+1)/$total] $($task.id)..." -NoNewline

    $body = @{
        name = $task.title
        description = $task.description
    } | ConvertTo-Json -Depth 5

    try {
        $response = Invoke-RestMethod -Uri "$apiBase/task/$($task.id)" -Method Put -Headers $headers -Body $body
        Write-Host " OK - $($response.name.Substring(0, [Math]::Min(55, $response.name.Length)))..." -ForegroundColor Green
    } catch {
        Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 500
}

Write-Host "`nDone!" -ForegroundColor Cyan
