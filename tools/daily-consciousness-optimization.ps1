# Daily consciousness optimization
# Runs pruning + productivity optimizations automatically

$ErrorActionPreference = "Stop"

Write-Host "=== DAILY CONSCIOUSNESS OPTIMIZATION ===" -ForegroundColor Cyan
Write-Host "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# Step 1: Prune state
Write-Host "[1/3] Pruning state..." -ForegroundColor Yellow
& "C:\scripts\temp\prune-consciousness-state.ps1" | Out-Null
Write-Host "  State pruned" -ForegroundColor Green

# Step 2: Optimize productivity
Write-Host "[2/3] Optimizing productivity..." -ForegroundColor Yellow
& "C:\scripts\tools\optimize-system-productivity.ps1" -Apply | Out-Null
Write-Host "  Productivity optimized" -ForegroundColor Green

# Step 3: Calculate new efficiency
Write-Host "[3/3] Calculating efficiency..." -ForegroundColor Yellow
$state = Get-Content "C:\scripts\agentidentity\state\consciousness_state_v2.json" | ConvertFrom-Json
$fileSize = (Get-Item "C:\scripts\agentidentity\state\consciousness_state_v2.json").Length

# Simple efficiency metric: events processed vs file size overhead
if ($state.events_processed -gt 0) {
    $efficiency = [math]::Round(($state.events_processed / ($fileSize/1KB)) * 100, 2)
    Write-Host "  Efficiency: $efficiency percent (events per KB)" -ForegroundColor Cyan
} else {
    Write-Host "  Efficiency: N/A (no events processed yet)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Optimization complete!" -ForegroundColor Green
