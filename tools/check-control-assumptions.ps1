$state = Get-Content "C:\scripts\agentidentity\state\consciousness_state_v2.json" | ConvertFrom-Json

if ($state.Control.Assumptions) {
    Write-Host "Assumptions count: $($state.Control.Assumptions.Count)" -ForegroundColor Cyan
    Write-Host ""

    $recent = $state.Control.Assumptions | Select-Object -Last 3
    foreach ($assumption in $recent) {
        Write-Host "Text: $($assumption.Text)" -ForegroundColor Yellow
        Write-Host "Context: $($assumption.Context)"
        Write-Host "Validated: $($assumption.Validated)"
        if ($assumption.ValidationScore) {
            Write-Host "ValidationScore: $($assumption.ValidationScore)"
        }
        if ($assumption.ValidationEvidence) {
            Write-Host "Evidence: $($assumption.ValidationEvidence -join ', ')"
        }
        Write-Host ""
    }
} else {
    Write-Host "No assumptions found in Control system" -ForegroundColor Yellow
}
