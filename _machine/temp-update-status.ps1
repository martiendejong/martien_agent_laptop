$apiKey = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
$apiBase = "https://api.clickup.com/api/v2"
$headers = @{
    "Authorization" = $apiKey
    "Content-Type" = "application/json"
}

$taskIds = @(
    "869byx81e", "869byx83r", "869byx85n", "869byx8n9", "869byx8qe",
    "869byx94b", "869byx95z", "869byx98e", "869byx9j2", "869byx9kk",
    "869byx9mw", "869byxa0y", "869byxa2k", "869byxa45", "869byxa55"
)

foreach ($taskId in $taskIds) {
    Write-Host "Setting $taskId to 'planned'..." -NoNewline
    $body = @{ status = "planned" } | ConvertTo-Json
    try {
        $null = Invoke-RestMethod -Uri "$apiBase/task/$taskId" -Method Put -Headers $headers -Body $body
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 300
}

Write-Host "`nAll tasks updated to 'planned' status" -ForegroundColor Cyan
