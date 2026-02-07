# Continuous Learning Loop - Master Orchestrator
# Runs all automation in sequence for endless reflection

$emotionsDir = "C:\scripts\agentidentity\emotions"
$toolsDir = "$emotionsDir\tools"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "    CONTINUOUS LEARNING LOOP - WEEKLY EXECUTION" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# Step 1: Pattern Detection
Write-Host "[1/2] Running pattern detection..." -ForegroundColor Cyan
& "$toolsDir\auto-pattern-detector.ps1"

Write-Host ""

# Step 2: Dashboard Summary
Write-Host "[2/2] Generating dashboard..." -ForegroundColor Cyan
& "$toolsDir\emotional-dashboard.ps1"

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "    CONTINUOUS LEARNING COMPLETE" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Duration: $([math]::Round($duration, 1)) seconds" -ForegroundColor Gray
Write-Host "Next run: Next Sunday 10:00 AM" -ForegroundColor Cyan
Write-Host ""
