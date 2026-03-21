# Check running Bliek processes
Write-Host "`n=== Running Processes ===" -ForegroundColor Cyan
Get-Process -Name dotnet,node -ErrorAction SilentlyContinue |
    Select-Object ProcessName, Id, @{Name='CPU(s)';Expression={[math]::Round($_.CPU,2)}}, @{Name='Memory(MB)';Expression={[math]::Round($_.WorkingSet64/1MB,2)}} |
    Format-Table -AutoSize

# Check Bliek project location
$bliekPath = "E:\projects\bliek"
if (Test-Path $bliekPath) {
    Write-Host "`n=== Bliek Project Status ===" -ForegroundColor Cyan
    Write-Host "Path: $bliekPath" -ForegroundColor Green

    # Check if backend is running (port 5100)
    $backendPort = Get-NetTCPConnection -LocalPort 5100 -ErrorAction SilentlyContinue
    if ($backendPort) {
        Write-Host "Backend: Running on port 5100" -ForegroundColor Green
    } else {
        Write-Host "Backend: NOT running" -ForegroundColor Red
    }

    # Check if frontend is running (port 5015)
    $frontendPort = Get-NetTCPConnection -LocalPort 5015 -ErrorAction SilentlyContinue
    if ($frontendPort) {
        Write-Host "Frontend: Running on port 5015" -ForegroundColor Green
    } else {
        Write-Host "Frontend: NOT running" -ForegroundColor Red
    }
} else {
    Write-Host "Bliek project not found at: $bliekPath" -ForegroundColor Red
}

# Check for crash indicators
Write-Host "`n=== Recent Git Commits ===" -ForegroundColor Cyan
git log --oneline -5
