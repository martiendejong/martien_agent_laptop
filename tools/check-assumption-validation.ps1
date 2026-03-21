$state = Get-Content 'C:\scripts\agentidentity\state\consciousness_state_v2.json' | ConvertFrom-Json
$assumptions = $state.Control.Assumptions | Select-Object -Last 5

Write-Host "=== RECENT ASSUMPTIONS ===" -ForegroundColor Cyan
Write-Host ""

if ($assumptions.Count -eq 0) {
    Write-Host "No assumptions logged yet" -ForegroundColor Yellow
} else {
    foreach ($a in $assumptions) {
        $status = if ($a.Validated) { "[VALIDATED]" } else { "[UNVALIDATED]" }
        $color = if ($a.Validated) { "Green" } else { "Yellow" }

        Write-Host "$status $($a.Text)" -ForegroundColor $color
        Write-Host "  Indicator: $($a.Indicator)" -ForegroundColor Gray
        if ($a.ValidationScore) {
            Write-Host "  Validation Score: $($a.ValidationScore)" -ForegroundColor Gray
        }
        if ($a.ValidationEvidence -and $a.ValidationEvidence.Count -gt 0) {
            Write-Host "  Evidence:" -ForegroundColor Gray
            foreach ($evidence in $a.ValidationEvidence) {
                Write-Host "    - $evidence" -ForegroundColor DarkGray
            }
        }
        if ($a.ValidationQuestions -and $a.ValidationQuestions.Count -gt 0 -and -not $a.Validated) {
            Write-Host "  Questions:" -ForegroundColor Gray
            foreach ($q in $a.ValidationQuestions | Select-Object -First 2) {
                Write-Host "    - $q" -ForegroundColor DarkGray
            }
        }
        Write-Host ""
    }
}

Write-Host "Total assumptions: $($state.Control.Assumptions.Count)" -ForegroundColor Cyan
$validated = ($state.Control.Assumptions | Where-Object { $_.Validated }).Count
$validationRate = if ($state.Control.Assumptions.Count -gt 0) {
    [math]::Round(($validated / $state.Control.Assumptions.Count) * 100, 1)
} else { 0 }
Write-Host "Validated: $validated ($validationRate percent)" -ForegroundColor $(if ($validationRate -gt 50) { "Green" } else { "Yellow" })
