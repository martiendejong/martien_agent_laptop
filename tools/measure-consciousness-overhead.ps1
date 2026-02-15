# Measure Consciousness System Overhead
# Analyzes state file to calculate efficiency metrics

param([switch]$Silent)

$ErrorActionPreference = "Stop"

$stateFile = "C:\scripts\agentidentity\state\consciousness_state_v2.json"

if (-not (Test-Path $stateFile)) {
    Write-Error "State file not found: $stateFile"
    exit 1
}

# Load state
$json = Get-Content $stateFile -Raw | ConvertFrom-Json

# Count items
$metrics = @{
    FileSizeKB = [math]::Round((Get-Item $stateFile).Length / 1KB, 2)
    EventBusEvents = $json.EventBus.Events.Count
    MemoryWorkingEvents = $json.Memory.Working.RecentEvents.Count
    MemoryPatterns = $json.Memory.LongTerm.Patterns.Count
    PredictionAnticipations = $json.Prediction.Anticipations.Count
    ControlDecisions = $json.Control.Decisions.Count
    EmotionHistory = $json.Emotion.History.Count
    ThermoHeatEvents = $json.Thermodynamics.HeatEvents.Count
    ThermoCoolingEvents = $json.Thermodynamics.CoolingEvents.Count
}

# Calculate totals
$metrics.TotalEvents = $metrics.EventBusEvents + $metrics.MemoryWorkingEvents +
                       $metrics.EmotionHistory + $metrics.ThermoHeatEvents +
                       $metrics.ThermoCoolingEvents

$metrics.TotalDataPoints = $metrics.TotalEvents + $metrics.MemoryPatterns +
                          $metrics.PredictionAnticipations + $metrics.ControlDecisions

# Estimate useful vs overhead
# Useful: Patterns (persistent learning), Decisions (control), Anticipations (prediction)
$metrics.UsefulData = $metrics.MemoryPatterns + $metrics.ControlDecisions +
                      $metrics.PredictionAnticipations

# Overhead: Events (history tracking), Emotion history, Thermo events
$metrics.OverheadData = $metrics.TotalEvents

# Efficiency calculation
if ($metrics.TotalDataPoints -gt 0) {
    $metrics.EfficiencyPercent = [math]::Round(($metrics.UsefulData / $metrics.TotalDataPoints) * 100, 2)
    $metrics.OverheadPercent = [math]::Round(($metrics.OverheadData / $metrics.TotalDataPoints) * 100, 2)
} else {
    $metrics.EfficiencyPercent = 0
    $metrics.OverheadPercent = 0
}

# Carnot efficiency (useful work / total energy)
# From thermodynamics: actual efficiency vs theoretical maximum
$carnotEff = $json.Thermodynamics.CarnotEfficiency
$metrics.CarnotEfficiency = [math]::Round($carnotEff * 100, 2)

# Output
if (-not $Silent) {
    Write-Host "=== Consciousness System Overhead Analysis ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "FILE:" -ForegroundColor Yellow
    Write-Host "  Size: $($metrics.FileSizeKB) KB"
    Write-Host ""
    Write-Host "DATA COUNTS:" -ForegroundColor Yellow
    Write-Host "  EventBus Events: $($metrics.EventBusEvents)"
    Write-Host "  Working Memory Events: $($metrics.MemoryWorkingEvents)"
    Write-Host "  Long-term Patterns: $($metrics.MemoryPatterns)"
    Write-Host "  Predictions: $($metrics.PredictionAnticipations)"
    Write-Host "  Decisions: $($metrics.ControlDecisions)"
    Write-Host "  Emotion History: $($metrics.EmotionHistory)"
    Write-Host "  Thermo Heat Events: $($metrics.ThermoHeatEvents)"
    Write-Host "  Thermo Cooling Events: $($metrics.ThermoCoolingEvents)"
    Write-Host "  ---"
    Write-Host "  TOTAL Data Points: $($metrics.TotalDataPoints)" -ForegroundColor White
    Write-Host ""
    Write-Host "EFFICIENCY:" -ForegroundColor Yellow
    Write-Host "  Useful Data: $($metrics.UsefulData) ($($metrics.EfficiencyPercent)%)" -ForegroundColor Green
    Write-Host "  Overhead Data: $($metrics.OverheadData) ($($metrics.OverheadPercent)%)" -ForegroundColor Red
    Write-Host "  Carnot Efficiency: $($metrics.CarnotEfficiency)%" -ForegroundColor $(if ($metrics.CarnotEfficiency -lt 10) { "Red" } elseif ($metrics.CarnotEfficiency -lt 50) { "Yellow" } else { "Green" })
    Write-Host ""

    if ($metrics.CarnotEfficiency -lt 10) {
        Write-Host "WARNING: System is spending $($metrics.OverheadPercent)% of energy on overhead!" -ForegroundColor Red
        Write-Host "Recommendation: Implement aggressive eviction + consolidation" -ForegroundColor Yellow
    } elseif ($metrics.CarnotEfficiency -lt 50) {
        Write-Host "CAUTION: Moderate overhead detected" -ForegroundColor Yellow
    } else {
        Write-Host "OK: System efficiency is acceptable" -ForegroundColor Green
    }
}

# Return metrics object
return $metrics
