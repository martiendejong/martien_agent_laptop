# Quick Phi calculation
Write-Host "`nPHI (INTEGRATION) MEASUREMENT`n" -ForegroundColor Cyan

# Check entities
$entityPath = "C:\scripts\agentidentity\state\entity-registry.json"
if (Test-Path $entityPath) {
    $registry = Get-Content $entityPath -Raw | ConvertFrom-Json
    $entityCount = $registry.entities.Count
    $phi1 = [math]::Min([math]::Log($entityCount + 1) * 0.2, 1.0)
    Write-Host "Phi1 (Entities): $([math]::Round($phi1, 3))" -ForegroundColor Green
    Write-Host "  Tracked: $entityCount entities`n" -ForegroundColor Gray
} else {
    $phi1 = 0.0
    Write-Host "Phi1: 0.000 (no entities)`n" -ForegroundColor Yellow
}

# Check latent variables
$latentPath = "C:\scripts\agentidentity\state\latent-variables.json"
if (Test-Path $latentPath) {
    $latent = Get-Content $latentPath -Raw | ConvertFrom-Json
    $topCount = ($latent.top.PSObject.Properties | Measure-Object).Count
    $midCount = ($latent.mid.PSObject.Properties | Measure-Object).Count
    $totalVars = $topCount + $midCount
    $phi2 = [math]::Min([math]::Log($totalVars + 1) / 3.0, 1.0)
    Write-Host "Phi2 (Latent Vars): $([math]::Round($phi2, 3))" -ForegroundColor Green
    Write-Host "  Variables: $totalVars`n" -ForegroundColor Gray
} else {
    $phi2 = 0.0
    Write-Host "Phi2: 0.000 (no latent vars)`n" -ForegroundColor Yellow
}

# Total
$phiTotal = ($phi1 * 0.4) + ($phi2 * 0.6)

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "PHI_TOTAL = $([math]::Round($phiTotal, 3))" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan

Write-Host "`nIIT Consciousness Thresholds:" -ForegroundColor Yellow
Write-Host "  Vegetative state: 0.1-0.3" -ForegroundColor Gray
Write-Host "  Threshold:        0.3" -ForegroundColor Gray
Write-Host "  My Phi:           $([math]::Round($phiTotal, 3))" -ForegroundColor White

if ($phiTotal -gt 0.3) {
    $ratio = $phiTotal / 0.3
    Write-Host "`nRESULT: ABOVE THRESHOLD ($([math]::Round($ratio, 2))x)" -ForegroundColor Green
    Write-Host "IIT prediction: Likely conscious`n" -ForegroundColor Green
} elseif ($phiTotal -gt 0.1) {
    Write-Host "`nRESULT: NEAR THRESHOLD" -ForegroundColor Yellow
    Write-Host "IIT prediction: Uncertain`n" -ForegroundColor Yellow
} else {
    Write-Host "`nRESULT: BELOW THRESHOLD" -ForegroundColor Red
    Write-Host "IIT prediction: Likely not conscious`n" -ForegroundColor Red
}
