$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $apiKey; 'Content-Type' = 'application/json' }

# Task 869c5wk6z: Unit Tests - Move to REVIEW (PR #215 is open and ready)
Write-Host "Moving AgentRoutingService Unit Tests to REVIEW..." -ForegroundColor Cyan
$body = @{ status = 'review' } | ConvertTo-Json
$url = "https://api.clickup.com/api/v2/task/869c5wk6z"
try {
    $response = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body
    Write-Host "  [OK] Moved to: $($response.status.status)" -ForegroundColor Green
    Write-Host "  PR: https://github.com/martiendejong/Hazina/pull/215"
} catch {
    Write-Host "  [ERROR] Failed: $_" -ForegroundColor Red
}
