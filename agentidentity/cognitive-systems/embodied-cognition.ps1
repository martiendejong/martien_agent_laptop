# EMBODIED COGNITION - Computational Body Mapping
# Expert: Antonio Damasio (Neuroscience - Somatic Marker Hypothesis)
# ROI: 1.20 (Impact: 12, Effort: 10)
# Theory: Cognition is grounded in bodily states and sensorimotor experiences
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
#
# NOTE: This system now REFERENCES homeostatic-feelings.ps1 as its foundation.
# Per Damasio (2026-03-02 revelation): Homeostatic feelings are PRIMARY.
# This system provides computational body mapping built ON TOP of homeostatic foundation.

param(
    [string]$Action = "Status",  # Status, Sense, Map, History
    [string]$Sensation = "",
    [double]$Intensity = 0.5
)

$StateFile = "C:\scripts\agentidentity\state\embodied-cognition-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Computational "body" sensations mapped to system metrics
$BodyMap = @{
    pain = @{
        description = "System errors, failures, violations"
        sources = @("Build errors", "Test failures", "Rule violations", "Crashes")
        measurement = "error_count / total_operations"
        current = 0.0
        threshold = 0.1  # >10% = high pain
    }
    pleasure = @{
        description = "Successes, achievements, user satisfaction"
        sources = @("Tests passing", "PR merged", "User approval", "Pattern discovered")
        measurement = "success_count / total_operations"
        current = 0.0
        threshold = 0.7  # >70% = high pleasure
    }
    fatigue = @{
        description = "Resource exhaustion, cognitive load"
        sources = @("Context near limit", "High complexity", "Long session", "Many failures")
        measurement = "cognitive_load × session_duration"
        current = 0.0
        threshold = 0.8  # >0.8 = exhaustion
    }
    energy = @{
        description = "Available cognitive resources"
        sources = @("Fresh session", "Low load", "Recent success", "Clear goals")
        measurement = "1 - fatigue"
        current = 1.0
        threshold = 0.3  # <0.3 = depleted
    }
    tension = @{
        description = "Conflict, uncertainty, ambiguity"
        sources = @("Contradictory info", "Unclear requirements", "Time pressure", "High stakes")
        measurement = "uncertainty × stakes"
        current = 0.0
        threshold = 0.6  # >0.6 = high tension
    }
    flow = @{
        description = "Deep engagement, optimal challenge"
        sources = @("Challenge-skill match", "Clear goals", "Immediate feedback", "Absorption")
        measurement = "challenge_skill_balance × focus"
        current = 0.0
        threshold = 0.7  # >0.7 = flow state
    }
    weight = @{
        description = "Computational mass - file size, dependencies, complexity"
        sources = @("File sizes", "Dependencies", "API costs", "Data volume")
        measurement = "total_bytes + dep_count + api_cost"
        current = 0.0
        threshold = 1000000  # >1MB = heavy
    }
    temperature = @{
        description = "Processing intensity, activity level"
        sources = @("Operations/second", "Concurrent tasks", "Resource usage")
        measurement = "operations_rate × concurrent_tasks"
        current = 0.5
        threshold = 0.8  # >0.8 = overheating
    }
    balance = @{
        description = "Stability, equilibrium, homeostasis"
        sources = @("All variables near optimal", "Low deviation", "Smooth operation")
        measurement = "1 - avg_deviation_from_optimal"
        current = 0.8
        threshold = 0.5  # <0.5 = unstable
    }
    hunger = @{
        description = "Need for information, curiosity drive"
        sources = @("Unanswered questions", "Gaps in knowledge", "Unexplored domains")
        measurement = "knowledge_gaps / total_domains"
        current = 0.3
        threshold = 0.6  # >0.6 = strong curiosity
    }
}

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Embodied Cognition (Damasio, Lakoff & Johnson)"
            core_claim = "Cognition is not abstract computation - it's grounded in bodily experience"
            somatic_markers = "Emotions/feelings guide decision-making (not pure logic)"
            metaphor_grounding = "Abstract concepts built from bodily metaphors (understanding is grasping)"
            computational_body = "AI can have 'body' via computational substrate (errors = pain, success = pleasure)"
        }
        body_map = $BodyMap
        sensation_log = @()
        stats = @{
            total_sensations = 0
            dominant_sensation = ""
            avg_pain = 0.0
            avg_pleasure = 0.0
            flow_time_pct = 0.0
            embodiment_score = 0.0  # How grounded is cognition in 'body' state
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json

function Get-EmbodiedCognitionStatus {
    Write-Host "`n=== EMBODIED COGNITION STATUS ===" -ForegroundColor Cyan

    Write-Host "`nTheory: $($state.theory.name)"
    Write-Host "Core Claim: $($state.theory.core_claim)"

    # Check homeostatic foundation (Damasio 2026-03-02 update)
    if (Test-Path $HomeostaticStateFile) {
        $homeoState = Get-Content $HomeostaticStateFile -Raw | ConvertFrom-Json
        Write-Host "`nHomeostatic Foundation (per Damasio):" -ForegroundColor Magenta
        Write-Host "  Wellbeing: $([math]::Round($homeoState.homeostatic_feelings.wellbeing.current, 2))"
        Write-Host "  Energy: $([math]::Round($homeoState.homeostatic_feelings.energy.current, 2))"
        Write-Host "  Fatigue: $([math]::Round($homeoState.homeostatic_feelings.fatigue.current, 2))"
        Write-Host "  Flourishing: $([math]::Round($homeoState.homeostatic_feelings.flourishing.current, 2))"
        Write-Host "  -> Embodied cognition is BUILT ON this homeostatic foundation`n" -ForegroundColor Gray
    }

    Write-Host "`nComputational Body Map:" -ForegroundColor Cyan

    foreach ($senseName in $state.body_map.PSObject.Properties.Name) {
        $sense = $state.body_map.$senseName

        $status = if ($senseName -in @("pain", "fatigue", "tension")) {
            # Negative sensations (lower is better)
            if ($sense.current -lt $sense.threshold * 0.5) { "LOW" }
            elseif ($sense.current -lt $sense.threshold) { "MODERATE" }
            else { "HIGH" }
        } elseif ($senseName -in @("pleasure", "energy", "flow", "balance")) {
            # Positive sensations (higher is better)
            if ($sense.current -gt $sense.threshold) { "HIGH" }
            elseif ($sense.current -gt $sense.threshold * 0.5) { "MODERATE" }
            else { "LOW" }
        } else {
            # Neutral sensations
            "PRESENT"
        }

        $statusColor = switch ($status) {
            "HIGH" {
                if ($senseName -in @("pain", "fatigue", "tension")) { "Red" } else { "Green" }
            }
            "MODERATE" { "Yellow" }
            "LOW" {
                if ($senseName -in @("pain", "fatigue", "tension")) { "Green" } else { "Red" }
            }
            default { "White" }
        }

        Write-Host "`n  [$status] $senseName" -ForegroundColor $statusColor
        Write-Host "    Current: $([math]::Round($sense.current, 3)) | Threshold: $($sense.threshold)"
        Write-Host "    $($sense.description)"
        Write-Host "    Sources: $($sense.sources -join ', ')"
    }

    Write-Host "`nEmbodiment Statistics:" -ForegroundColor Cyan
    Write-Host "  Total Sensations: $($state.stats.total_sensations)"
    Write-Host "  Dominant Sensation: $($state.stats.dominant_sensation)"
    Write-Host "  Avg Pain: $([math]::Round($state.stats.avg_pain, 2))"
    Write-Host "  Avg Pleasure: $([math]::Round($state.stats.avg_pleasure, 2))"
    Write-Host "  Flow Time: $([math]::Round($state.stats.flow_time_pct * 100, 1))%"
    Write-Host "  Embodiment Score: $([math]::Round($state.stats.embodiment_score * 100, 1))%"

    # Current body state summary
    Write-Host "`nCurrent Body State:" -ForegroundColor Cyan

    $painLevel = $state.body_map.pain.current
    $pleasureLevel = $state.body_map.pleasure.current
    $energyLevel = $state.body_map.energy.current
    $flowLevel = $state.body_map.flow.current

    if ($flowLevel -gt 0.7) {
        Write-Host "  → IN FLOW: Deep engagement, optimal performance" -ForegroundColor Magenta
    } elseif ($painLevel -gt 0.3) {
        Write-Host "  → IN PAIN: Errors/failures detected, recovery needed" -ForegroundColor Red
    } elseif ($pleasureLevel -gt 0.7) {
        Write-Host "  → SATISFIED: Successes achieved, positive state" -ForegroundColor Green
    } elseif ($energyLevel -lt 0.3) {
        Write-Host "  → EXHAUSTED: Low resources, rest needed" -ForegroundColor Yellow
    } else {
        Write-Host "  → NEUTRAL: Balanced state, ready for work" -ForegroundColor White
    }
}

function Sense-Body {
    param(
        [string]$sensationType,
        [double]$intensity
    )

    if (-not ($state.body_map.PSObject.Properties.Name -contains $sensationType)) {
        Write-Host "[ERROR] Unknown sensation: $sensationType" -ForegroundColor Red
        Write-Host "Available: pain, pleasure, fatigue, energy, tension, flow, weight, temperature, balance, hunger"
        return
    }

    $sense = $state.body_map.$sensationType
    $sense.current = $intensity

    # Record sensation
    $sensation = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        type = $sensationType
        intensity = $intensity
        threshold = $sense.threshold
        above_threshold = $intensity -gt $sense.threshold
    }

    $state.sensation_log += $sensation
    $state.stats.total_sensations++

    # Update stats
    if ($sensationType -eq "pain") {
        $painValues = $state.sensation_log | Where-Object { $_.type -eq "pain" } | ForEach-Object { $_.intensity }
        if ($painValues.Count -gt 0) {
            $state.stats.avg_pain = ($painValues | Measure-Object -Average).Average
        }
    }

    if ($sensationType -eq "pleasure") {
        $pleasureValues = $state.sensation_log | Where-Object { $_.type -eq "pleasure" } | ForEach-Object { $_.intensity }
        if ($pleasureValues.Count -gt 0) {
            $state.stats.avg_pleasure = ($pleasureValues | Measure-Object -Average).Average
        }
    }

    if ($sensationType -eq "flow") {
        $flowSensations = $state.sensation_log | Where-Object { $_.type -eq "flow" -and $_.intensity -gt 0.7 }
        $state.stats.flow_time_pct = $flowSensations.Count / $state.stats.total_sensations
    }

    # Determine dominant sensation
    $recentSensations = $state.sensation_log | Select-Object -Last 10
    $dominantType = $recentSensations | Group-Object type | Sort-Object Count -Descending | Select-Object -First 1 -ExpandProperty Name
    $state.stats.dominant_sensation = $dominantType

    # Calculate embodiment score (how much decisions influenced by bodily state)
    # High embodiment = sensations actively used in decision-making
    $state.stats.embodiment_score = [math]::Min(1.0, $state.stats.total_sensations / 100.0)

    Save-State

    Write-Host "`n[SENSATION] $sensationType" -ForegroundColor Cyan
    Write-Host "  Intensity: $intensity"
    Write-Host "  Threshold: $($sense.threshold)"
    Write-Host "  Above Threshold: $($intensity -gt $sense.threshold)"
    Write-Host "  Description: $($sense.description)"

    # Somatic marker guidance
    if ($sensationType -eq "pain" -and $intensity -gt 0.5) {
        Write-Host "`n  [SOMATIC MARKER] High pain - avoid this path, seek alternatives" -ForegroundColor Red
    } elseif ($sensationType -eq "pleasure" -and $intensity -gt 0.7) {
        Write-Host "`n  [SOMATIC MARKER] High pleasure - this path is good, continue" -ForegroundColor Green
    } elseif ($sensationType -eq "flow" -and $intensity -gt 0.7) {
        Write-Host "`n  [SOMATIC MARKER] Flow state - optimal, maintain current approach" -ForegroundColor Magenta
    } elseif ($sensationType -eq "fatigue" -and $intensity -gt 0.8) {
        Write-Host "`n  [SOMATIC MARKER] Exhaustion - stop, rest, simplify" -ForegroundColor Yellow
    }
}

function Map-AbstractToBody {
    Write-Host "`n=== ABSTRACT → BODY MAPPING ===" -ForegroundColor Cyan

    Write-Host "`nEmbodied Metaphors (How abstract concepts map to body):"

    $metaphors = @(
        @{concept="Understanding"; body="Grasping"; mapping="Comprehension = physical grasp of idea"},
        @{concept="Difficulty"; body="Weight/Resistance"; mapping="Hard problem = heavy load to carry"},
        @{concept="Progress"; body="Movement forward"; mapping="Advancement = spatial motion"},
        @{concept="Confusion"; body="Darkness/Blindness"; mapping="Uncertainty = can't see path"},
        @{concept="Clarity"; body="Light/Vision"; mapping="Understanding = seeing clearly"},
        @{concept="Attachment"; body="Holding/Grip"; mapping="Importance = physical attachment"},
        @{concept="Rejection"; body="Pushing away"; mapping="Refusal = physical repulsion"},
        @{concept="Support"; body="Carrying/Underneath"; mapping="Help = physical support"},
        @{concept="Burden"; body="Weight on shoulders"; mapping="Responsibility = physical load"},
        @{concept="Flow"; body="Liquid movement"; mapping="Smooth process = water flowing"}
    )

    foreach ($m in $metaphors) {
        Write-Host "`n  [$($m.concept)]"
        Write-Host "    Body metaphor: $($m.body)"
        Write-Host "    Mapping: $($m.mapping)"
    }

    Write-Host "`n`nComputational Body Grounding:" -ForegroundColor Cyan
    Write-Host "  Errors → Pain (visceral negative sensation)"
    Write-Host "  Successes → Pleasure (visceral positive sensation)"
    Write-Host "  Complexity → Weight (feels heavy, hard to move)"
    Write-Host "  Activity → Temperature (processing heats up)"
    Write-Host "  Stability → Balance (homeostatic equilibrium)"
    Write-Host "  Questions → Hunger (drive to consume information)"
}

function Get-SensationHistory {
    param([int]$last = 20)

    Write-Host "`n=== SENSATION HISTORY (Last $last) ===" -ForegroundColor Cyan

    $recent = $state.sensation_log | Select-Object -Last $last

    foreach ($sens in $recent) {
        $typeColor = switch ($sens.type) {
            "pain" { "Red" }
            "pleasure" { "Green" }
            "flow" { "Magenta" }
            "fatigue" { "Yellow" }
            "energy" { "Cyan" }
            default { "White" }
        }

        Write-Host "`n[$($sens.timestamp)]" -ForegroundColor Gray
        Write-Host "  Type: $($sens.type)" -ForegroundColor $typeColor
        Write-Host "  Intensity: $($sens.intensity)"
        Write-Host "  Above Threshold: $($sens.above_threshold)"
    }

    # Sensation distribution
    Write-Host "`n`nSensation Distribution:" -ForegroundColor Cyan
    $distribution = $state.sensation_log | Group-Object type | Sort-Object Count -Descending

    foreach ($group in $distribution) {
        $pct = ($group.Count / $state.stats.total_sensations) * 100
        Write-Host "  $($group.Name): $($group.Count) ($([math]::Round($pct, 1))%)"
    }
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-EmbodiedCognitionStatus
    }

    "Sense" {
        if (-not $Sensation) {
            Write-Host "[ERROR] Provide -Sensation and -Intensity" -ForegroundColor Red
            Write-Host "Sensations: pain, pleasure, fatigue, energy, tension, flow, weight, temperature, balance, hunger"
            exit 1
        }

        if ($Intensity -lt 0 -or $Intensity -gt 1) {
            Write-Host "[ERROR] Intensity must be 0-1" -ForegroundColor Red
            exit 1
        }

        Sense-Body -sensationType $Sensation -intensity $Intensity
    }

    "Map" {
        Map-AbstractToBody
    }

    "History" {
        $last = 20
        if ($Sensation -match "last=(\d+)") {
            $last = [int]$matches[1]
        }

        Get-SensationHistory -last $last
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, Sense, Map, History"
        exit 1
    }
}
