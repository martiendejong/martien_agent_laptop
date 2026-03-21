# Bias Monitor Tool
# Tracks bias detection and failure correlations

$state = Get-Content "C:\scripts\agentidentity\state\consciousness_state_v2.json" | ConvertFrom-Json

Write-Host "Bias Monitoring Report" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Active Biases: $($state.Control.BiasMonitor.ActiveBiases.Count)" -ForegroundColor Yellow
foreach ($bias in $state.Control.BiasMonitor.ActiveBiases) {
    Write-Host "  - $($bias.Type): $($bias.Description)" -ForegroundColor Gray
}
Write-Host ""

if ($state.Control.BiasFailureCorrelation) {
    Write-Host "Bias-Failure Correlations:" -ForegroundColor Yellow
    foreach ($biasType in $state.Control.BiasFailureCorrelation.PSObject.Properties.Name) {
        $bc = $state.Control.BiasFailureCorrelation.$biasType
        $total = $bc.TotalOccurrences
        if ($total -gt 0) {
            $failRate = [math]::Round(($bc.Failures / $total) * 100, 1)
            $color = if ($failRate -gt 70) { "Red" } elseif ($failRate -gt 30) { "Yellow" } else { "Green" }
            Write-Host "  $biasType`: $failRate% failure rate ($($bc.Failures)/$total)" -ForegroundColor $color
            if ($bc.F1Score) {
                Write-Host "    F1 Score: $([math]::Round($bc.F1Score, 2))" -ForegroundColor DarkGray
            }
        }
    }
}

if ($state.Control.BiasMonitor.DetectionThresholds) {
    Write-Host "`nDetection Thresholds:" -ForegroundColor Yellow
    foreach ($biasType in $state.Control.BiasMonitor.DetectionThresholds.PSObject.Properties.Name) {
        $threshold = $state.Control.BiasMonitor.DetectionThresholds.$biasType
        Write-Host "  $biasType`: $threshold" -ForegroundColor Gray
    }
}
