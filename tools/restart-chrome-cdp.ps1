#Requires -Version 5.1
# Restart Chrome with CDP

Write-Host "Stopping all Chrome processes..." -ForegroundColor Yellow
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 5

$remaining = Get-Process chrome -ErrorAction SilentlyContinue
if ($remaining) {
    Write-Host "WARNING: Some Chrome processes still running" -ForegroundColor Red
    exit 1
}

Write-Host "All Chrome stopped. Starting with CDP..." -ForegroundColor Green
Start-Process "C:\Program Files\Google\Chrome\Application\chrome.exe" -ArgumentList "--remote-debugging-port=9222"
Start-Sleep -Seconds 8

Write-Host "Testing CDP connection..." -ForegroundColor Cyan
try {
    $version = Invoke-RestMethod -Uri "http://localhost:9222/json/version" -Method Get -TimeoutSec 3
    Write-Host "SUCCESS: CDP is active!" -ForegroundColor Green
    Write-Host "Browser: $($version.Browser)" -ForegroundColor Gray
    Write-Host "Protocol: $($version.'Protocol-Version')" -ForegroundColor Gray
    exit 0
}
catch {
    Write-Host "FAILED: CDP not active" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
