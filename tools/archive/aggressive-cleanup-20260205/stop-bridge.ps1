#Requires -Version 5.1
<#
.SYNOPSIS
    Stop the Claude Bridge Server

.DESCRIPTION
    Finds and stops the running claude-bridge-server.py process

.EXAMPLE
    .\stop-bridge.ps1
#>

Write-Host "Stopping Claude Bridge Server..." -ForegroundColor Cyan

# Find Python processes running the bridge server
$bridgeProcesses = Get-Process python -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*claude-bridge-server.py*"
}

if (-not $bridgeProcesses) {
    # Try alternative method - find by window title or port
    $bridgeProcesses = Get-Process python -ErrorAction SilentlyContinue | Where-Object {
        $processId = $_.Id
        try {
            $connections = netstat -ano | Select-String ":9999.*LISTENING"
            $connections -match "\s+$processId\s*$"
        } catch {
            $false
        }
    }
}

if ($bridgeProcesses) {
    $count = ($bridgeProcesses | Measure-Object).Count
    Write-Host "Found $count bridge server process(es)" -ForegroundColor Yellow

    foreach ($process in $bridgeProcesses) {
        Write-Host "Stopping process ID: $($process.Id)" -ForegroundColor Gray
        Stop-Process -Id $process.Id -Force
    }

    Start-Sleep -Seconds 1

    # Verify it stopped
    $stillRunning = Get-Process python -ErrorAction SilentlyContinue | Where-Object {
        $processId = $_.Id
        try {
            $connections = netstat -ano | Select-String ":9999.*LISTENING"
            $connections -match "\s+$processId\s*$"
        } catch {
            $false
        }
    }

    if (-not $stillRunning) {
        Write-Host "[SUCCESS] Bridge server stopped" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Server may still be running" -ForegroundColor Yellow
    }
} else {
    Write-Host "[INFO] Bridge server is not running" -ForegroundColor Gray
}

# Also check if port 9999 is still in use
$portInUse = netstat -ano | Select-String ":9999.*LISTENING"
if ($portInUse) {
    Write-Host ""
    Write-Host "[WARNING] Port 9999 is still in use:" -ForegroundColor Yellow
    Write-Host $portInUse -ForegroundColor Gray
    Write-Host ""
    Write-Host "To forcefully kill the process:" -ForegroundColor Yellow

    $portInUse -match "\s+(\d+)\s*$" | Out-Null
    $pid = $matches[1]

    if ($pid) {
        Write-Host "taskkill /F /PID $pid" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "[SUCCESS] Port 9999 is now free" -ForegroundColor Green
}
