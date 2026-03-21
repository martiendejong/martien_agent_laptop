# Start Windows UI Automation Bridge if not running
# Usage: start-windows-ui-bridge.ps1 [-Force]

param(
    [switch]$Force
)

$port = 27184
$exePath = "C:\Projects\WindowsUIBridge\WindowsUIBridge\publish\WindowsUIBridge.exe"

# Check if already running
try {
    $health = Invoke-RestMethod "http://localhost:$port/health" -TimeoutSec 2 -ErrorAction Stop
    if ($health.status -eq "ok") {
        if ($Force) {
            Write-Host "[UI-BRIDGE] Already running, restarting due to -Force..." -ForegroundColor Yellow
            Get-Process -Name "WindowsUIBridge" -ErrorAction SilentlyContinue | Stop-Process -Force
            Start-Sleep -Seconds 1
        } else {
            Write-Host "[UI-BRIDGE] Already running (port $port)" -ForegroundColor Green
            return
        }
    }
} catch {
    # Not running, will start below
}

# Check if executable exists
if (-not (Test-Path $exePath)) {
    Write-Host "[UI-BRIDGE] ERROR: Executable not found at $exePath" -ForegroundColor Red
    Write-Host "[UI-BRIDGE] Build it first: cd C:\Projects\WindowsUIBridge\WindowsUIBridge && dotnet publish" -ForegroundColor Yellow
    exit 1
}

# Start the service
Write-Host "[UI-BRIDGE] Starting Windows UI Automation Bridge..." -ForegroundColor Cyan
Start-Process -FilePath $exePath -WindowStyle Minimized

# Wait for startup
$maxWait = 10
$waited = 0
while ($waited -lt $maxWait) {
    Start-Sleep -Seconds 1
    $waited++

    try {
        $health = Invoke-RestMethod "http://localhost:$port/health" -TimeoutSec 1 -ErrorAction Stop
        if ($health.status -eq "ok") {
            Write-Host "[UI-BRIDGE] Started successfully on port $port" -ForegroundColor Green
            return
        }
    } catch {
        # Keep waiting
    }
}

Write-Host "[UI-BRIDGE] WARNING: Started but health check failed after ${maxWait}s" -ForegroundColor Yellow
Write-Host "[UI-BRIDGE] Service may still be starting up..." -ForegroundColor Gray
