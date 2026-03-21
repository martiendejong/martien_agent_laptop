# stop-opencode-orchestration.ps1
# Gracefully stops all OpenCode ACP servers

param(
    [switch]$Force,
    [int[]]$PIDs
)

$ErrorActionPreference = "Stop"

Write-Host "=== OpenCode Orchestration Shutdown ===" -ForegroundColor Cyan
Write-Host ""

# Read PIDs from file if not provided
$pidFile = "$env:TEMP\opencode-orchestration-pids.txt"

if ($PIDs.Count -eq 0) {
    if (Test-Path $pidFile) {
        Write-Host "[*] Loading PIDs from: $pidFile" -ForegroundColor Gray

        $savedData = Get-Content $pidFile
        $PIDs = $savedData | ForEach-Object {
            $parts = $_ -split '\|'
            if ($parts.Count -eq 3) {
                [int]$parts[2]
            }
        }

        Write-Host "[OK] Found $($PIDs.Count) saved PIDs" -ForegroundColor Green
    } else {
        Write-Host "[!] No PID file found, searching for OpenCode processes..." -ForegroundColor Yellow
    }
}

# Find running OpenCode processes if no PIDs provided
if ($PIDs.Count -eq 0) {
    $processes = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -like "*opencode*acp*"
    }

    if ($processes) {
        $PIDs = $processes | ForEach-Object { $_.Id }
        Write-Host "[OK] Found $($PIDs.Count) OpenCode processes" -ForegroundColor Green
    } else {
        Write-Host "[OK] No OpenCode processes running" -ForegroundColor Green

        # Clean up PID file
        if (Test-Path $pidFile) {
            Remove-Item $pidFile -Force
            Write-Host "[OK] Cleaned up PID file" -ForegroundColor Green
        }

        exit 0
    }
}

# Stop each process
Write-Host ""
Write-Host "[*] Stopping $($PIDs.Count) processes..." -ForegroundColor Gray

$stopped = 0
$failed = 0

foreach ($pid in $PIDs) {
    try {
        $process = Get-Process -Id $pid -ErrorAction Stop

        if ($Force) {
            $process | Stop-Process -Force
            Write-Host "[OK] Force killed PID $pid" -ForegroundColor Yellow
        } else {
            $process | Stop-Process
            Write-Host "[OK] Stopped PID $pid" -ForegroundColor Green
        }

        $stopped++
    } catch {
        Write-Host "[SKIP] PID $pid not found (already stopped)" -ForegroundColor DarkGray
        $failed++
    }
}

# Clean up PID file
if (Test-Path $pidFile) {
    Remove-Item $pidFile -Force
    Write-Host ""
    Write-Host "[OK] Cleaned up PID file" -ForegroundColor Green
}

# Summary
Write-Host ""
Write-Host "=== Shutdown Summary ===" -ForegroundColor Cyan
Write-Host "Stopped: $stopped" -ForegroundColor Green
Write-Host "Already stopped: $failed" -ForegroundColor DarkGray
Write-Host ""
