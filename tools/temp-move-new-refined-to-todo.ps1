$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $apiKey; 'Content-Type' = 'application/json' }

Write-Host "=== Moving Newly Refined Tasks to TODO ===" -ForegroundColor Cyan

# SEO God task
Write-Host "`nSEO God: Sidebar menu ordering" -ForegroundColor Yellow
$body1 = @{ status = 'todo' } | ConvertTo-Json
$url1 = "https://api.clickup.com/api/v2/task/869ccw0bb"
try {
    $response1 = Invoke-RestMethod -Uri $url1 -Method Put -Headers $headers -Body $body1
    Write-Host "  [OK] Moved to: $($response1.status.status)" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Failed: $_" -ForegroundColor Red
}

# Bliek task
Write-Host "`nBliek: Rename project to RealEstateAgencyAPI" -ForegroundColor Yellow
$body2 = @{ status = 'todo' } | ConvertTo-Json
$url2 = "https://api.clickup.com/api/v2/task/869ccvzgh"
try {
    $response2 = Invoke-RestMethod -Uri $url2 -Method Put -Headers $headers -Body $body2
    Write-Host "  [OK] Moved to: $($response2.status.status)" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Failed: $_" -ForegroundColor Red
}

Write-Host "`n=== All tasks moved to TODO ===" -ForegroundColor Green
