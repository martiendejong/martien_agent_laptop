#Requires -Version 5.1
<#
.SYNOPSIS
    Manage Claude Bridge Server (start, stop, restart, status)

.EXAMPLE
    .\bridge-manager.ps1 -Action start
    .\bridge-manager.ps1 -Action stop
    .\bridge-manager.ps1 -Action restart
    .\bridge-manager.ps1 -Action status
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("start", "stop", "restart", "status")]
    [string]$Action
)

$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$serverScript = Join-Path $scriptPath "claude-bridge-server.py"

function Get-BridgeProcess {
    # Find Python process on port 9999
    $portInUse = netstat -ano | Select-String ":9999.*LISTENING"
    if ($portInUse) {
        $portInUse -match "\s+(\d+)\s*$" | Out-Null
        $processId = $matches[1]
        if ($processId) {
            return Get-Process -Id $processId -ErrorAction SilentlyContinue
        }
    }
    return $null
}

function Test-BridgeHealth {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:9999/health" -Method GET -TimeoutSec 2
        return $response.status -eq "healthy"
    } catch {
        return $false
    }
}

function Stop-Bridge {
    Write-Host "[STOP] Stopping bridge server..." -ForegroundColor Yellow

    $process = Get-BridgeProcess
    if ($process) {
        Write-Host "Found process (PID: $($process.Id))" -ForegroundColor Gray
        Stop-Process -Id $process.Id -Force
        Start-Sleep -Seconds 1

        $stillRunning = Get-BridgeProcess
        if (-not $stillRunning) {
            Write-Host "[SUCCESS] Bridge server stopped" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[ERROR] Failed to stop server" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "[INFO] Bridge server is not running" -ForegroundColor Gray
        return $true
    }
}

function Start-Bridge {
    Write-Host "[START] Starting bridge server..." -ForegroundColor Cyan

    # Check if already running
    if (Test-BridgeHealth) {
        Write-Host "[INFO] Bridge server is already running" -ForegroundColor Yellow
        return $true
    }

    # Start server
    $process = Start-Process python -ArgumentList $serverScript -WindowStyle Hidden -PassThru

    # Wait for startup
    Write-Host "Waiting for server to start..." -ForegroundColor Gray
    $maxAttempts = 10
    $attempt = 0

    while ($attempt -lt $maxAttempts) {
        Start-Sleep -Seconds 1
        if (Test-BridgeHealth) {
            Write-Host "[SUCCESS] Bridge server started (PID: $($process.Id))" -ForegroundColor Green
            Write-Host "Server running on http://localhost:9999" -ForegroundColor White
            return $true
        }
        $attempt++
    }

    Write-Host "[ERROR] Server failed to start" -ForegroundColor Red
    return $false
}

function Show-Status {
    Write-Host "[STATUS] Bridge Server Status" -ForegroundColor Cyan
    Write-Host ""

    $process = Get-BridgeProcess
    $healthy = Test-BridgeHealth

    if ($process) {
        Write-Host "Process:  RUNNING (PID: $($process.Id))" -ForegroundColor Green
    } else {
        Write-Host "Process:  NOT RUNNING" -ForegroundColor Red
    }

    if ($healthy) {
        Write-Host "Health:   HEALTHY" -ForegroundColor Green

        try {
            $response = Invoke-RestMethod -Uri "http://localhost:9999/health" -Method GET
            Write-Host "Messages: $($response.messageCount) total, $($response.unreadCount) unread" -ForegroundColor White
        } catch {
            Write-Host "Messages: Unable to fetch" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Health:   NOT RESPONDING" -ForegroundColor Red
    }

    Write-Host "Port:     9999" -ForegroundColor White
    Write-Host "URL:      http://localhost:9999" -ForegroundColor White
}

# Execute action
switch ($Action) {
    "start" {
        Start-Bridge
    }

    "stop" {
        Stop-Bridge
    }

    "restart" {
        Write-Host "[RESTART] Restarting bridge server..." -ForegroundColor Cyan
        Write-Host ""
        Stop-Bridge
        Write-Host ""
        Start-Sleep -Seconds 1
        Start-Bridge
    }

    "status" {
        Show-Status
    }
}
