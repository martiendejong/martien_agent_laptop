# Check Bliek on CORRECT ports
Write-Host "`n=== Bliek Status (Correct Ports) ===" -ForegroundColor Cyan

# Frontend: 3500
$frontend = Get-NetTCPConnection -LocalPort 3500 -ErrorAction SilentlyContinue
if ($frontend) {
    $process = Get-Process -Id $frontend.OwningProcess -ErrorAction SilentlyContinue
    Write-Host "[OK] Frontend: Running on port 3500" -ForegroundColor Green
    Write-Host "    Process: $($process.ProcessName) (PID: $($process.Id))" -ForegroundColor Gray
} else {
    Write-Host "[!!] Frontend: NOT running (port 3500)" -ForegroundColor Red
}

# Backend: 5028
$backend = Get-NetTCPConnection -LocalPort 5028 -ErrorAction SilentlyContinue
if ($backend) {
    $process = Get-Process -Id $backend.OwningProcess -ErrorAction SilentlyContinue
    Write-Host "[OK] Backend: Running on port 5028" -ForegroundColor Green
    Write-Host "    Process: $($process.ProcessName) (PID: $($process.Id))" -ForegroundColor Gray
} else {
    Write-Host "[!!] Backend: NOT running (port 5028)" -ForegroundColor Red
}

Write-Host ""
