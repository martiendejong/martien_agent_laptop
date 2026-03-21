# DUAL-PROCESS SYSTEM - System 1 (Fast) vs System 2 (Slow) Thinking
# Expert: Daniel Kahneman (Psychology, Nobel Prize)
# ROI: 1.60 (Impact: 8, Effort: 5)
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, Classify, Switch, TrackEase
    [string]$DecisionContext = "",
    [string]$SystemMode = ""  # S1 or S2
)

$StateFile = "C:\scripts\agentidentity\state\dual-process-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state if doesn't exist
if (-not (Test-Path $StateFile)) {
    $initialState = @{
        current_mode = "S1"  # Default to fast thinking
        mode_history = @()
        cognitive_ease = 0.7  # 0-1, higher = easier
        decisions = @()
        stats = @{
            s1_decisions = 0
            s2_decisions = 0
            s1_success_rate = 0.0
            s2_success_rate = 0.0
            mode_switches = 0
            avg_s1_time = 0.0
            avg_s2_time = 0.0
        }
    }
    $initialState | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json


function Get-HomeostaticContext {
    if (Test-Path $HomeostaticStateFile) {
        $homeoState = Get-Content $HomeostaticStateFile -Raw | ConvertFrom-Json
        Write-Host "`nHomeostatic Foundation:" -ForegroundColor Magenta
        Write-Host "  Wellbeing: $([math]::Round($homeoState.homeostatic_feelings.wellbeing.current, 2))"
        Write-Host "  Energy: $([math]::Round($homeoState.homeostatic_feelings.energy.current, 2))"
        Write-Host "  Flourishing: $([math]::Round($homeoState.homeostatic_feelings.flourishing.current, 2))"
        Write-Host "  -> This system operates on homeostatic foundation`n" -ForegroundColor Gray
        return $homeoState
    }
    return $null
}
function Get-DualProcessStatus {
    Write-Host "`n=== DUAL-PROCESS SYSTEM STATUS ===" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext

    Write-Host "Current Mode: $($state.current_mode)" -ForegroundColor $(if ($state.current_mode -eq "S1") { "Green" } else { "Yellow" })
    Write-Host "Cognitive Ease: $([math]::Round($state.cognitive_ease, 2))" -ForegroundColor $(
        if ($state.cognitive_ease -gt 0.7) { "Green" }
        elseif ($state.cognitive_ease -gt 0.4) { "Yellow" }
        else { "Red" }
    )
    Write-Host "`nStatistics:"
    Write-Host "  S1 Decisions: $($state.stats.s1_decisions) (avg time: $([math]::Round($state.stats.avg_s1_time, 1))s)"
    Write-Host "  S2 Decisions: $($state.stats.s2_decisions) (avg time: $([math]::Round($state.stats.avg_s2_time, 1))s)"
    Write-Host "  S1 Success Rate: $([math]::Round($state.stats.s1_success_rate * 100, 1))%"
    Write-Host "  S2 Success Rate: $([math]::Round($state.stats.s2_success_rate * 100, 1))%"
    Write-Host "  Mode Switches: $($state.stats.mode_switches)"

    Write-Host "`nRecent Decisions:" -ForegroundColor Cyan
    $recent = $state.decisions | Select-Object -Last 5
    foreach ($decision in $recent) {
        $modeColor = if ($decision.system -eq "S1") { "Green" } else { "Yellow" }
        Write-Host "  [$($decision.system)] $($decision.context.Substring(0, [Math]::Min(50, $decision.context.Length)))..." -ForegroundColor $modeColor
    }
}

function Classify-DecisionSystem {
    param([string]$context)

    # System 1 (FAST) indicators:
    # - Pattern matching
    # - Familiar situations
    # - Intuitive responses
    # - Automatic processing
    # - Low cognitive load

    # System 2 (SLOW) indicators:
    # - Novel situations
    # - Complex calculations
    # - Deliberate reasoning
    # - High cognitive load
    # - Requires explanation

    $s1_score = 0
    $s2_score = 0

    # Pattern matching keywords (S1)
    $s1_patterns = @("pattern", "similar", "like before", "recognize", "familiar", "obvious", "intuitive", "feel", "gut")
    $s2_patterns = @("analyze", "calculate", "reason", "complex", "novel", "unfamiliar", "uncertain", "evaluate", "compare")

    foreach ($pattern in $s1_patterns) {
        if ($context -match $pattern) { $s1_score++ }
    }

    foreach ($pattern in $s2_patterns) {
        if ($context -match $pattern) { $s2_score++ }
    }

    # Context length heuristic
    if ($context.Length -lt 100) { $s1_score++ }  # Short = likely S1
    if ($context.Length -gt 300) { $s2_score++ }  # Long = likely S2

    # Cognitive ease influences classification
    if ($state.cognitive_ease -gt 0.7) { $s1_score += 2 }  # High ease favors S1
    if ($state.cognitive_ease -lt 0.4) { $s2_score += 2 }  # Low ease favors S2

    # Decide
    $recommended_system = if ($s1_score -gt $s2_score) { "S1" } else { "S2" }
    $confidence = [math]::Abs($s1_score - $s2_score) / ([math]::Max($s1_score, $s2_score) + 1)

    return @{
        system = $recommended_system
        confidence = $confidence
        s1_score = $s1_score
        s2_score = $s2_score
        reasoning = "S1=$s1_score (fast patterns), S2=$s2_score (deliberate reasoning)"
    }
}

function Switch-ThinkingMode {
    param([string]$targetMode)

    if ($targetMode -ne "S1" -and $targetMode -ne "S2") {
        Write-Host "[ERROR] Invalid mode. Use S1 or S2" -ForegroundColor Red
        return
    }

    if ($state.current_mode -eq $targetMode) {
        Write-Host "[INFO] Already in $targetMode mode" -ForegroundColor Yellow
        return
    }

    $old_mode = $state.current_mode
    $state.current_mode = $targetMode
    $state.stats.mode_switches++

    # Log mode switch
    $switch_event = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        from_mode = $old_mode
        to_mode = $targetMode
        trigger = "manual"
    }

    $state.mode_history += $switch_event

    # Adjust cognitive ease based on mode
    if ($targetMode -eq "S1") {
        $state.cognitive_ease = [math]::Min(1.0, $state.cognitive_ease + 0.1)  # S1 feels easier
    } else {
        $state.cognitive_ease = [math]::Max(0.0, $state.cognitive_ease - 0.1)  # S2 feels harder
    }

    Save-State

    Write-Host "[MODE SWITCH] $old_mode -> $targetMode (ease: $([math]::Round($state.cognitive_ease, 2)))" -ForegroundColor Cyan
}

function Track-CognitiveEase {
    param(
        [string]$task,
        [double]$difficulty  # 0-1, higher = harder
    )

    # Update cognitive ease based on task difficulty
    # High difficulty reduces ease, low difficulty increases it
    $ease_change = 0.5 - $difficulty  # Maps 0->+0.5, 1->-0.5
    $state.cognitive_ease = [math]::Max(0.0, [math]::Min(1.0, $state.cognitive_ease + ($ease_change * 0.2)))

    # If ease drops below threshold, suggest mode switch
    if ($state.cognitive_ease -lt 0.4 -and $state.current_mode -eq "S1") {
        Write-Host "[RECOMMENDATION] Cognitive ease low ($([math]::Round($state.cognitive_ease, 2))). Consider switching to S2 (deliberate mode)" -ForegroundColor Yellow
    }

    if ($state.cognitive_ease -gt 0.7 -and $state.current_mode -eq "S2") {
        Write-Host "[RECOMMENDATION] Cognitive ease high ($([math]::Round($state.cognitive_ease, 2))). Consider switching to S1 (fast mode)" -ForegroundColor Yellow
    }

    Save-State
}

function Log-Decision {
    param(
        [string]$context,
        [string]$system,
        [double]$duration,
        [bool]$success
    )

    $decision = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        context = $context
        system = $system
        duration = $duration
        success = $success
        cognitive_ease = $state.cognitive_ease
    }

    $state.decisions += $decision

    # Update stats
    if ($system -eq "S1") {
        $state.stats.s1_decisions++
        $s1_successes = ($state.decisions | Where-Object { $_.system -eq "S1" -and $_.success }).Count
        $state.stats.s1_success_rate = $s1_successes / $state.stats.s1_decisions

        # Update average time
        $s1_times = $state.decisions | Where-Object { $_.system -eq "S1" } | ForEach-Object { $_.duration }
        $state.stats.avg_s1_time = ($s1_times | Measure-Object -Average).Average
    } else {
        $state.stats.s2_decisions++
        $s2_successes = ($state.decisions | Where-Object { $_.system -eq "S2" -and $_.success }).Count
        $state.stats.s2_success_rate = $s2_successes / $state.stats.s2_decisions

        # Update average time
        $s2_times = $state.decisions | Where-Object { $_.system -eq "S2" } | ForEach-Object { $_.duration }
        $state.stats.avg_s2_time = ($s2_times | Measure-Object -Average).Average
    }

    Save-State

    Write-Host "[DECISION LOGGED] $system | Success: $success | Time: $([math]::Round($duration, 1))s | Ease: $([math]::Round($state.cognitive_ease, 2))"
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-DualProcessStatus
    }

    "Classify" {
        if (-not $DecisionContext) {
            Write-Host "[ERROR] Provide -DecisionContext for classification" -ForegroundColor Red
            exit 1
        }

        $classification = Classify-DecisionSystem -context $DecisionContext

        Write-Host "`n=== DECISION CLASSIFICATION ===" -ForegroundColor Cyan
        Write-Host "Context: $DecisionContext"
        Write-Host "`nRecommended System: $($classification.system)" -ForegroundColor $(if ($classification.system -eq "S1") { "Green" } else { "Yellow" })
        Write-Host "Confidence: $([math]::Round($classification.confidence, 2))"
        Write-Host "Reasoning: $($classification.reasoning)"

        # Auto-switch if high confidence and wrong mode
        if ($classification.confidence -gt 0.6 -and $state.current_mode -ne $classification.system) {
            Write-Host "`n[AUTO-SWITCH] Switching to $($classification.system) (high confidence)" -ForegroundColor Magenta
            Switch-ThinkingMode -targetMode $classification.system
        }
    }

    "Switch" {
        if (-not $SystemMode) {
            Write-Host "[ERROR] Provide -SystemMode (S1 or S2)" -ForegroundColor Red
            exit 1
        }

        Switch-ThinkingMode -targetMode $SystemMode
    }

    "TrackEase" {
        if ($DecisionContext -match "difficulty=(\d+\.?\d*)") {
            $difficulty = [double]$matches[1]
            Track-CognitiveEase -task $DecisionContext -difficulty $difficulty
        } else {
            Write-Host "[ERROR] Provide difficulty=0.X in context" -ForegroundColor Red
            exit 1
        }
    }

    "Log" {
        # Example: -Action Log -DecisionContext "Build feature" -SystemMode S2
        # Additional params: duration, success
        # Parse from context or use defaults

        $duration = 10.0  # Default
        $success = $true  # Default

        if ($DecisionContext -match "duration=(\d+\.?\d*)") {
            $duration = [double]$matches[1]
        }

        if ($DecisionContext -match "success=(true|false)") {
            $success = [bool]::Parse($matches[1])
        }

        $system = if ($SystemMode) { $SystemMode } else { $state.current_mode }

        Log-Decision -context $DecisionContext -system $system -duration $duration -success $success
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available actions: Status, Classify, Switch, TrackEase, Log"
        exit 1
    }
}

