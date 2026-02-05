# Learning Rate Optimizer (Iter 41)
param([string]$Topic, [int]$TimeSpent, [int]$Mastery, [switch]$Optimize)
if ($Optimize) {
    $rate = if ($TimeSpent -gt 0) { [math]::Round($Mastery / $TimeSpent, 2) } else { 0 }
    Write-Host "Learning Rate: $rate mastery/hour" -ForegroundColor Cyan
    if ($rate -lt 0.5) { Write-Host "  Recommendation: Change learning method" -ForegroundColor Yellow }
    elseif ($rate -lt 1.0) { Write-Host "  Recommendation: Increase practice frequency" -ForegroundColor Yellow }
    else { Write-Host "  Status: Optimal learning rate" -ForegroundColor Green }
}
