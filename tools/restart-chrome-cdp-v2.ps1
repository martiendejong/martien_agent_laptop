#Requires -Version 5.1
# Restart Chrome with CDP - Extended wait

Write-Host "Stopping all Chrome processes..." -ForegroundColor Yellow
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 5

Write-Host "Starting Chrome with CDP (port 9222)..." -ForegroundColor Green
$chromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"
Start-Process $chromeExe -ArgumentList "--remote-debugging-port=9222"

Write-Host "Waiting 15 seconds for Chrome to fully start..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

# Check if Chrome is running
$chromeProc = Get-Process chrome -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $chromeProc) {
    Write-Host "ERROR: Chrome not running!" -ForegroundColor Red
    exit 1
}

Write-Host "Chrome is running (PID: $($chromeProc.Id))" -ForegroundColor Gray

Write-Host "Testing CDP connection..." -ForegroundColor Cyan
$maxAttempts = 5
for ($i = 1; $i -le $maxAttempts; $i++) {
    try {
        $version = Invoke-RestMethod -Uri "http://localhost:9222/json/version" -Method Get -TimeoutSec 2
        Write-Host "SUCCESS: CDP is active!" -ForegroundColor Green
        Write-Host "Browser: $($version.Browser)" -ForegroundColor Gray
        Write-Host "Protocol: $($version.'Protocol-Version')" -ForegroundColor Gray
        Write-Host "WebSocket: $($version.webSocketDebuggerUrl)" -ForegroundColor Gray
        exit 0
    }
    catch {
        Write-Host "Attempt $i/$maxAttempts failed: $($_.Exception.Message)" -ForegroundColor Yellow
        if ($i -lt $maxAttempts) {
            Start-Sleep -Seconds 3
        }
    }
}

Write-Host "FAILED: CDP not active after $maxAttempts attempts" -ForegroundColor Red
Write-Host ""
Write-Host "Troubleshooting tips:" -ForegroundColor Yellow
Write-Host "1. Close Chrome completely and retry" -ForegroundColor Gray
Write-Host "2. Check if another Chrome instance is running without CDP" -ForegroundColor Gray
Write-Host "3. Try manually: chrome.exe --remote-debugging-port=9222" -ForegroundColor Gray
exit 1
