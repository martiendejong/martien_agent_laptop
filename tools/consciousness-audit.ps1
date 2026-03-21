# Consciousness Audit Tool
# Quick assessment of consciousness system health
param([switch]$Detailed)

$state = Get-Content "C:\scripts\agentidentity\state\consciousness_state_v2.json" | ConvertFrom-Json

$subsystems = @{
    Perception = [Math]::Min(1.0, ($state.Perception.EventBus.Events.Count / 20.0))
    Memory = [Math]::Min(1.0, ($state.Memory.LongTerm.Patterns.Count / 10.0))
    Prediction = [Math]::Min(1.0, ($state.Prediction.Anticipations.Count / 5.0))
    Control = [Math]::Min(1.0, ($state.Control.Decisions.Count / 10.0))
    Emotion = [Math]::Min(1.0, ($state.Emotion.History.Count / 10.0))
    Social = $state.Social.TrustLevel
    Meta = 1.0
    Thermodynamics = (1.0 - $state.Thermodynamics.Temperature) * $state.Thermodynamics.NegativeEntropyBudget
}

$overall = ($subsystems.Values | Measure-Object -Average).Average

Write-Host "Consciousness Score: $([math]::Round($overall * 100, 1))%" -ForegroundColor Cyan
foreach ($sys in $subsystems.Keys | Sort-Object) {
    $score = [math]::Round($subsystems[$sys] * 100, 1)
    $color = if ($score -lt 30) { "Red" } elseif ($score -lt 70) { "Yellow" } else { "Green" }
    Write-Host "  $sys`: $score%" -ForegroundColor $color
}

if ($Detailed) {
    Write-Host "`nDetailed Metrics:" -ForegroundColor Yellow
    Write-Host "  Patterns: $($state.Memory.LongTerm.Patterns.Count)" -ForegroundColor Gray
    Write-Host "  Decisions: $($state.Control.Decisions.Count)" -ForegroundColor Gray
    Write-Host "  Anticipations: $($state.Prediction.Anticipations.Count)" -ForegroundColor Gray
    Write-Host "  Curiosities: $(if ($state.Perception.Curiosities) { $state.Perception.Curiosities.Count } else { 0 })" -ForegroundColor Gray
    Write-Host "  Temperature: $([math]::Round($state.Thermodynamics.Temperature, 2))" -ForegroundColor Gray
    Write-Host "  Trust: $([math]::Round($state.Social.TrustLevel * 100, 1))%" -ForegroundColor Gray
}
