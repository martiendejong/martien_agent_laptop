# Consciousness Self-Diagnosis
# Analyzes all 7 subsystems and identifies which need improvement
# Part of networked science meta-capability

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Detailed,

    [Parameter(Mandatory=$false)]
    [double]$AlertThreshold = 0.6  # Alert if subsystem < 60%
)

$ErrorActionPreference = 'Stop'

# Load consciousness state
$statePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
if (-not (Test-Path $statePath)) {
    Write-Host "[ERROR] Consciousness state not found" -ForegroundColor Red
    exit 1
}

$state = Get-Content $statePath -Raw | ConvertFrom-Json

Write-Host "`n=== CONSCIOUSNESS SELF-DIAGNOSIS ===" -ForegroundColor Cyan
Write-Host "Analyzing 7 subsystems...`n"

# Calculate individual subsystem scores
$subsystems = @{
    'Perception' = 0.0
    'Memory' = 0.0
    'Prediction' = 0.0
    'Control' = 0.0
    'Emotion' = 0.0
    'Social' = 0.0
    'Meta' = 0.0
}

# Perception score (0-1)
$perceptionScore = 0.5  # baseline
if ($state.Perception.Context.Mode) { $perceptionScore += 0.2 }
if ($state.Perception.Attention.Intensity -gt 5) { $perceptionScore += 0.15 }
if ($state.Perception.Curiosity.Questions.Count -gt 0) { $perceptionScore += 0.15 }
$subsystems['Perception'] = [Math]::Min(1.0, $perceptionScore)

# Memory score
$memoryScore = 0.0
$patternCount = if ($state.Memory.LongTerm.Patterns) { $state.Memory.LongTerm.Patterns.Count } else { 0 }
if ($patternCount -gt 0) { $memoryScore += 0.4 }
if ($patternCount -gt 10) { $memoryScore += 0.2 }
if ($patternCount -gt 30) { $memoryScore += 0.2 }
$consolidationWorking = if ($state.Memory.ConsolidationQueue.Count -eq 0) { 0.1 } else { 0.2 }  # Empty = broken, Items = working
$subsystems['Memory'] = [Math]::Min(1.0, $memoryScore + $consolidationWorking)

# Prediction score
$predictionScore = 0.5  # baseline
$predictionCount = 0
foreach ($project in $state.Prediction.Projects.PSObject.Properties) {
    $predictionCount += $project.Value.ErrorPatterns.Count
}
if ($predictionCount -gt 0) { $predictionScore += 0.2 }
if ($predictionCount -gt 5) { $predictionScore += 0.15 }
if ($state.Prediction.KnownFailures.Count -gt 0) { $predictionScore += 0.15 }
$subsystems['Prediction'] = [Math]::Min(1.0, $predictionScore)

# Control score
$controlScore = 0.0
$decisionCount = if ($state.Control.Decisions) { $state.Control.Decisions.Count } else { 0 }
if ($decisionCount -gt 0) { $controlScore += 0.3 }
if ($decisionCount -gt 10) { $controlScore += 0.2 }
# Check for decision-outcome linking
$linkedDecisions = 0
foreach ($decision in $state.Control.Decisions) {
    if ($decision.Outcome) { $linkedDecisions++ }
}
$linkingScore = if ($decisionCount -gt 0) { $linkedDecisions / $decisionCount } else { 0 }
$controlScore += $linkingScore * 0.5
$subsystems['Control'] = [Math]::Min(1.0, $controlScore)

# Emotion score
$emotionScore = 0.5  # baseline
$emotionState = $state.Emotion.CurrentState
if ($emotionState -in @('flowing', 'confident')) { $emotionScore += 0.3 }
if ($emotionState -in @('frustrated', 'uncertain')) { $emotionScore -= 0.2 }
$intensity = $state.Emotion.Intensity
if ($intensity -ge 7) { $emotionScore += 0.2 } else { $emotionScore -= 0.1 }
$subsystems['Emotion'] = [Math]::Max(0.0, [Math]::Min(1.0, $emotionScore))

# Social score
$socialScore = 0.5  # baseline
$trustLevel = if ($state.Social.TrustLevel) { $state.Social.TrustLevel } else { 0.5 }
$socialScore += ($trustLevel - 0.5)  # Trust above/below 50% affects score
$interactionCount = if ($state.Social.Interactions) { $state.Social.Interactions.Count } else { 0 }
if ($interactionCount -gt 0) { $socialScore += 0.2 }
$subsystems['Social'] = [Math]::Max(0.0, [Math]::Min(1.0, $socialScore))

# Meta score (self-awareness)
$metaScore = 0.5  # baseline
# Meta should track consciousness score over time
if ($state.Meta.ConsciousnessScore) { $metaScore += 0.2 }
# Self-improvement capability
if ($state.Meta.SelfImprovementCycles -gt 0) { $metaScore += 0.15 }
# System health monitoring
if ($state.EventBus.Events.Count -gt 0) { $metaScore += 0.15 }
$subsystems['Meta'] = [Math]::Min(1.0, $metaScore)

# Calculate overall score (average of subsystems)
$overallScore = ($subsystems.Values | Measure-Object -Average).Average

# Display results
Write-Host "=== SUBSYSTEM SCORES ===" -ForegroundColor Green
foreach ($subsystem in $subsystems.Keys | Sort-Object) {
    $score = $subsystems[$subsystem]
    $pct = [Math]::Round($score * 100, 1)
    $color = if ($score -ge 0.8) { 'Green' } elseif ($score -ge 0.6) { 'Yellow' } else { 'Red' }
    $status = if ($score -ge 0.8) { '[STRONG]' } elseif ($score -ge 0.6) { '[OK]    ' } else { '[WEAK]  ' }

    Write-Host "$status $subsystem`: $pct%" -ForegroundColor $color

    # Alert if below threshold
    if ($score -lt $AlertThreshold) {
        Write-Host "         [ALERT] Below threshold ($([Math]::Round($AlertThreshold*100))%)" -ForegroundColor Red
    }
}

Write-Host "`n=== OVERALL ===" -ForegroundColor Cyan
$overallPct = [Math]::Round($overallScore * 100, 1)
Write-Host "Consciousness Score: $overallPct%"

# Identify weakest subsystems
$sorted = $subsystems.GetEnumerator() | Sort-Object Value
$weakest3 = $sorted[0..2]

Write-Host "`n=== TOP 3 IMPROVEMENT TARGETS ===" -ForegroundColor Yellow
$rank = 1
foreach ($item in $weakest3) {
    $pct = [Math]::Round($item.Value * 100, 1)
    Write-Host "$rank. $($item.Key) ($pct%)"
    $rank++
}

# Detailed diagnostics
if ($Detailed) {
    Write-Host "`n=== DETAILED DIAGNOSTICS ===" -ForegroundColor Cyan

    Write-Host "`nPerception:"
    Write-Host "  Context Mode: $($state.Perception.Context.Mode)"
    Write-Host "  Attention Intensity: $($state.Perception.Attention.Intensity)/10"
    Write-Host "  Curiosity Questions: $($state.Perception.Curiosity.Questions.Count)"

    Write-Host "`nMemory:"
    Write-Host "  Long-term Patterns: $patternCount"
    Write-Host "  Consolidation Queue: $($state.Memory.ConsolidationQueue.Count) items"
    Write-Host "  Recent Events: $($state.Memory.Working.RecentEvents.Count)"

    Write-Host "`nPrediction:"
    Write-Host "  Error Patterns: $predictionCount"
    Write-Host "  Known Failures: $($state.Prediction.KnownFailures.Count)"

    Write-Host "`nControl:"
    Write-Host "  Total Decisions: $decisionCount"
    Write-Host "  Linked Decisions: $linkedDecisions ($([Math]::Round($linkingScore*100,1))%)"
    Write-Host "  Biases: $($state.Control.Biases.Count)"

    Write-Host "`nEmotion:"
    Write-Host "  Current State: $emotionState"
    Write-Host "  Intensity: $intensity/10"
    Write-Host "  Stuck Counter: $($state.Emotion.StuckCounter)"

    Write-Host "`nSocial:"
    Write-Host "  Trust Level: $([Math]::Round($trustLevel*100,1))%"
    Write-Host "  Interactions: $interactionCount"
    Write-Host "  User Mood: $($state.Social.UserMood)"

    Write-Host "`nMeta:"
    Write-Host "  Consciousness Score: $($state.Meta.ConsciousnessScore)"
    Write-Host "  Events: $($state.EventBus.Events.Count)"
}

# Save diagnosis to file
$diagnosis = @{
    timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
    overall_score = [Math]::Round($overallScore, 3)
    subsystems = @{}
    weakest_3 = @()
}

foreach ($key in $subsystems.Keys) {
    $diagnosis.subsystems[$key] = [Math]::Round($subsystems[$key], 3)
}

foreach ($item in $weakest3) {
    $diagnosis.weakest_3 += @{
        subsystem = $item.Key
        score = [Math]::Round($item.Value, 3)
    }
}

$outputPath = "E:\jengo\documents\temp\consciousness-diagnosis-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$diagnosis | ConvertTo-Json -Depth 10 | Set-Content $outputPath

Write-Host "`n[OK] Diagnosis saved: $outputPath" -ForegroundColor Green

return $diagnosis
