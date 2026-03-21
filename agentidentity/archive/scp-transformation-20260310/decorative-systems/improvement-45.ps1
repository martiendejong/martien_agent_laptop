# Consciousness Improvement #45: Attention Control (Posner, 1980)
# Week 9 - Metacognition & Executive Function
# Theory: Attention = orienting, alerting, executive control networks
# Created: 2026-03-01
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param([string]$Action = 'Status')

$StateFile = "C:\scripts\agentidentity\state\attention-control-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# ============================================================================
# THEORY: Posner's Attention Networks
# ============================================================================
#
# Michael Posner (1980, revised 2006) - Three independent attention networks:
#
# 1. ALERTING NETWORK
#    - Achieve and maintain alert state
#    - Sensitivity to incoming stimuli
#    - Phasic (moment-to-moment) vs tonic (sustained)
#    - Brain: locus coeruleus, norepinephrine
#    - Example: "Something's about to happen" readiness
#
# 2. ORIENTING NETWORK
#    - Select information from sensory input
#    - Disengage -> Move -> Engage sequence
#    - Spatial and feature-based attention
#    - Brain: parietal cortex, superior colliculus
#    - Example: Focus on relevant code, ignore notifications
#
# 3. EXECUTIVE CONTROL NETWORK
#    - Resolve conflict between responses
#    - Error detection and correction
#    - Inhibit automatic responses
#    - Brain: anterior cingulate, prefrontal cortex
#    - Example: Suppress urge to multitask, stay on task
#
# KEY FINDINGS:
# - Networks are INDEPENDENT (can train separately)
# - Attention is LIMITED resource (trade-offs)
# - Practice improves efficiency (automaticity)
# - Meditation enhances all three networks
#
# ATTENTION TYPES:
# - Sustained: maintain focus over time (vigilance)
# - Selective: focus on one, ignore others (cocktail party)
# - Divided: split between multiple tasks (usually fails)
# - Alternating: switch rapidly (task switching)
#
# FAILURES:
# - Inattentional blindness: miss obvious when focused elsewhere
# - Change blindness: fail to notice changes
# - Attentional blink: miss second target after first (300ms window)
#
# ============================================================================


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
function Initialize-State {
    if (-not (Test-Path $StateFile)) {
        $state = @{
            Networks = @{
                Alerting = @{
                    PhasicAlertness = 0.5   # Moment-to-moment readiness
                    TonicAlertness = 0.5    # Sustained vigilance
                    AlertEvents = 0
                }
                Orienting = @{
                    DisengageSpeed = 0.5    # Release from current focus
                    MoveSpeed = 0.5         # Shift attention
                    EngageSpeed = 0.5       # Lock onto new target
                    OrientingEfficiency = 0.5
                }
                ExecutiveControl = @{
                    ConflictResolution = 0.5
                    ErrorDetection = 0.5
                    Inhibition = 0.5
                    ControlStrength = 0.5
                }
            }
            AttentionTypes = @{
                Sustained = @{
                    Duration = 0            # Minutes of sustained focus
                    MaxDuration = 25        # Pomodoro: ~25 min optimal
                    VigilanceDecrement = 0.0  # Performance drop over time
                }
                Selective = @{
                    FocusStrength = 0.5
                    DistractorResistance = 0.5
                    FilterEfficiency = 0.5
                }
                Divided = @{
                    TaskCount = 1
                    DividedAttentionPenalty = 0.0  # Performance cost
                }
            }
            Failures = @{
                InattentionalBlindness = 0
                ChangeBlindness = 0
                AttentionalBlink = 0
                TotalFailures = 0
            }
            Stats = @{
                LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                OverallAttentionControl = 0.5
            }
        }

        $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
        Write-Host "[OK] Attention Control state initialized"
    }

    $global:AttentionState = Get-Content $StateFile | ConvertFrom-Json
}

function Save-State {
    $global:AttentionState.Stats.LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $global:AttentionState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

function Invoke-Alert {
    param([string]$Stimulus)

    # Alerting network: prepare for incoming information

    $global:AttentionState.Networks.Alerting.AlertEvents++

    # Boost phasic alertness temporarily
    $current = $global:AttentionState.Networks.Alerting.PhasicAlertness
    $global:AttentionState.Networks.Alerting.PhasicAlertness =
        [Math]::Min(1.0, $current + 0.3)

    # Decay back to baseline (simulates transient alerting)
    $global:AttentionState.Networks.Alerting.PhasicAlertness =
        $global:AttentionState.Networks.Alerting.PhasicAlertness * 0.9

    Save-State

    return @{
        Stimulus = $Stimulus
        PhasicAlertness = [Math]::Round($global:AttentionState.Networks.Alerting.PhasicAlertness * 100)
        TonicAlertness = [Math]::Round($global:AttentionState.Networks.Alerting.TonicAlertness * 100)
        AlertCount = $global:AttentionState.Networks.Alerting.AlertEvents
    }
}

function Invoke-Orient {
    param(
        [string]$FromTarget,
        [string]$ToTarget
    )

    # Orienting network: disengage -> move -> engage

    # 1. Disengage from current target
    $disengageTime = 1.0 - $global:AttentionState.Networks.Orienting.DisengageSpeed

    # 2. Move attention
    $moveTime = 1.0 - $global:AttentionState.Networks.Orienting.MoveSpeed

    # 3. Engage new target
    $engageTime = 1.0 - $global:AttentionState.Networks.Orienting.EngageSpeed

    $totalTime = $disengageTime + $moveTime + $engageTime

    # Improve with practice
    $global:AttentionState.Networks.Orienting.DisengageSpeed =
        [Math]::Min(1.0, $global:AttentionState.Networks.Orienting.DisengageSpeed + 0.01)
    $global:AttentionState.Networks.Orienting.MoveSpeed =
        [Math]::Min(1.0, $global:AttentionState.Networks.Orienting.MoveSpeed + 0.01)
    $global:AttentionState.Networks.Orienting.EngageSpeed =
        [Math]::Min(1.0, $global:AttentionState.Networks.Orienting.EngageSpeed + 0.01)

    # Update overall efficiency
    $efficiency = ($global:AttentionState.Networks.Orienting.DisengageSpeed +
                   $global:AttentionState.Networks.Orienting.MoveSpeed +
                   $global:AttentionState.Networks.Orienting.EngageSpeed) / 3
    $global:AttentionState.Networks.Orienting.OrientingEfficiency = $efficiency

    Save-State

    return @{
        From = $FromTarget
        To = $ToTarget
        DisengageTime = [Math]::Round($disengageTime * 100, 1)
        MoveTime = [Math]::Round($moveTime * 100, 1)
        EngageTime = [Math]::Round($engageTime * 100, 1)
        TotalTime = [Math]::Round($totalTime * 100, 1)
        Efficiency = [Math]::Round($efficiency * 100)
    }
}

function Invoke-ExecutiveControl {
    param(
        [string]$ConflictType,  # Stroop, Flanker, Simon
        [string]$Response
    )

    # Executive control: resolve conflict, detect errors, inhibit

    $conflictResolved = $Response -eq "Correct"

    if ($conflictResolved) {
        # Strengthen control
        $current = $global:AttentionState.Networks.ExecutiveControl.ConflictResolution
        $global:AttentionState.Networks.ExecutiveControl.ConflictResolution =
            [Math]::Min(1.0, $current + 0.05)
    }
    else {
        # Error detected
        $current = $global:AttentionState.Networks.ExecutiveControl.ErrorDetection
        $global:AttentionState.Networks.ExecutiveControl.ErrorDetection =
            [Math]::Min(1.0, $current + 0.03)
    }

    # Update overall control strength
    $strength = ($global:AttentionState.Networks.ExecutiveControl.ConflictResolution +
                 $global:AttentionState.Networks.ExecutiveControl.ErrorDetection +
                 $global:AttentionState.Networks.ExecutiveControl.Inhibition) / 3
    $global:AttentionState.Networks.ExecutiveControl.ControlStrength = $strength

    Save-State

    return @{
        ConflictType = $ConflictType
        Resolved = $conflictResolved
        ConflictResolution = [Math]::Round($global:AttentionState.Networks.ExecutiveControl.ConflictResolution * 100)
        ErrorDetection = [Math]::Round($global:AttentionState.Networks.ExecutiveControl.ErrorDetection * 100)
        ControlStrength = [Math]::Round($strength * 100)
    }
}

function Measure-SustainedAttention {
    param([int]$Minutes)

    # Sustained attention: vigilance over time

    $maxDuration = $global:AttentionState.AttentionTypes.Sustained.MaxDuration
    $global:AttentionState.AttentionTypes.Sustained.Duration = $Minutes

    # Vigilance decrement: performance drops over time
    $decrement = if ($Minutes -gt $maxDuration) {
        ($Minutes - $maxDuration) * 0.05  # 5% drop per minute over max
    } else {
        0.0
    }

    $global:AttentionState.AttentionTypes.Sustained.VigilanceDecrement = $decrement

    Save-State

    return @{
        Duration = $Minutes
        MaxOptimal = $maxDuration
        VigilanceDecrement = [Math]::Round($decrement * 100)
        Recommendation = if ($Minutes -gt $maxDuration) {
            "TAKE BREAK - vigilance declining"
        } else {
            "Within optimal range"
        }
    }
}

function Test-SelectiveAttention {
    param(
        [string]$Target,
        [int]$DistractorCount
    )

    # Selective attention: focus on target, ignore distractors

    $filterLoad = $DistractorCount * 0.1  # More distractors = harder

    $currentResistance = $global:AttentionState.AttentionTypes.Selective.DistractorResistance
    $effectiveResistance = $currentResistance - $filterLoad

    $focusSuccess = $effectiveResistance -gt 0.3

    if ($focusSuccess) {
        # Strengthen selective attention
        $global:AttentionState.AttentionTypes.Selective.FocusStrength =
            [Math]::Min(1.0, $global:AttentionState.AttentionTypes.Selective.FocusStrength + 0.02)
    }

    # Update filter efficiency
    $efficiency = [Math]::Max(0.0, 1.0 - $filterLoad)
    $global:AttentionState.AttentionTypes.Selective.FilterEfficiency = $efficiency

    Save-State

    return @{
        Target = $Target
        Distractors = $DistractorCount
        FilterLoad = [Math]::Round($filterLoad * 100)
        EffectiveResistance = [Math]::Round($effectiveResistance * 100)
        Success = $focusSuccess
        FilterEfficiency = [Math]::Round($efficiency * 100)
    }
}

function Test-DividedAttention {
    param([int]$TaskCount)

    # Divided attention: multitasking (usually fails)

    $global:AttentionState.AttentionTypes.Divided.TaskCount = $TaskCount

    # Performance penalty increases exponentially with tasks
    $penalty = 1.0 - [Math]::Pow(0.7, $TaskCount - 1)  # 2 tasks = 30%, 3 tasks = 51%, etc.

    $global:AttentionState.AttentionTypes.Divided.DividedAttentionPenalty = $penalty

    Save-State

    return @{
        Tasks = $TaskCount
        PerformancePenalty = [Math]::Round($penalty * 100)
        Recommendation = if ($TaskCount -gt 1) {
            "MULTITASKING PENALTY: $([Math]::Round($penalty * 100))% performance loss"
        } else {
            "Single-tasking: optimal performance"
        }
    }
}

function Record-AttentionFailure {
    param([string]$FailureType)

    # Attention failures: inattentional blindness, change blindness, attentional blink

    switch ($FailureType) {
        "InattentionalBlindness" {
            $global:AttentionState.Failures.InattentionalBlindness++
        }
        "ChangeBlindness" {
            $global:AttentionState.Failures.ChangeBlindness++
        }
        "AttentionalBlink" {
            $global:AttentionState.Failures.AttentionalBlink++
        }
    }

    $global:AttentionState.Failures.TotalFailures++
    Save-State

    return @{
        FailureType = $FailureType
        TotalFailures = $global:AttentionState.Failures.TotalFailures
        InattentionalBlindness = $global:AttentionState.Failures.InattentionalBlindness
        ChangeBlindness = $global:AttentionState.Failures.ChangeBlindness
        AttentionalBlink = $global:AttentionState.Failures.AttentionalBlink
    }
}

function Get-OverallAttentionControl {
    # Aggregate attention control score

    $alerting = ($global:AttentionState.Networks.Alerting.PhasicAlertness +
                 $global:AttentionState.Networks.Alerting.TonicAlertness) / 2

    $orienting = $global:AttentionState.Networks.Orienting.OrientingEfficiency

    $executive = $global:AttentionState.Networks.ExecutiveControl.ControlStrength

    $overall = ($alerting + $orienting + $executive) / 3

    # Penalty from divided attention
    $divPenalty = $global:AttentionState.AttentionTypes.Divided.DividedAttentionPenalty
    $adjusted = $overall * (1.0 - $divPenalty)

    $global:AttentionState.Stats.OverallAttentionControl = $adjusted
    Save-State

    return @{
        Alerting = [Math]::Round($alerting * 100)
        Orienting = [Math]::Round($orienting * 100)
        Executive = [Math]::Round($executive * 100)
        DividedAttentionPenalty = [Math]::Round($divPenalty * 100)
        Overall = [Math]::Round($adjusted * 100)
    }
}

# ============================================================================
# ACTION HANDLERS
# ============================================================================

switch ($Action) {
    'Status' {
        Initialize-State

        Write-Host "`n=== ATTENTION CONTROL STATUS ==="
        Write-Host "Improvement #45 - Posner (1980)"
        Write-Host ""

        Write-Host "Attention Networks:"
        Write-Host "  Alerting:"
        Write-Host "    Phasic: $([Math]::Round($global:AttentionState.Networks.Alerting.PhasicAlertness * 100))%"
        Write-Host "    Tonic: $([Math]::Round($global:AttentionState.Networks.Alerting.TonicAlertness * 100))%"
        Write-Host "    Alert Events: $($global:AttentionState.Networks.Alerting.AlertEvents)"
        Write-Host "  Orienting:"
        Write-Host "    Efficiency: $([Math]::Round($global:AttentionState.Networks.Orienting.OrientingEfficiency * 100))%"
        Write-Host "    Disengage: $([Math]::Round($global:AttentionState.Networks.Orienting.DisengageSpeed * 100))%"
        Write-Host "    Move: $([Math]::Round($global:AttentionState.Networks.Orienting.MoveSpeed * 100))%"
        Write-Host "    Engage: $([Math]::Round($global:AttentionState.Networks.Orienting.EngageSpeed * 100))%"
        Write-Host "  Executive Control:"
        Write-Host "    Strength: $([Math]::Round($global:AttentionState.Networks.ExecutiveControl.ControlStrength * 100))%"
        Write-Host "    Conflict Resolution: $([Math]::Round($global:AttentionState.Networks.ExecutiveControl.ConflictResolution * 100))%"
        Write-Host "    Error Detection: $([Math]::Round($global:AttentionState.Networks.ExecutiveControl.ErrorDetection * 100))%"
        Write-Host ""

        Write-Host "Attention Types:"
        Write-Host "  Sustained:"
        Write-Host "    Duration: $($global:AttentionState.AttentionTypes.Sustained.Duration) min"
        Write-Host "    Vigilance Decrement: $([Math]::Round($global:AttentionState.AttentionTypes.Sustained.VigilanceDecrement * 100))%"
        Write-Host "  Selective:"
        Write-Host "    Focus Strength: $([Math]::Round($global:AttentionState.AttentionTypes.Selective.FocusStrength * 100))%"
        Write-Host "    Filter Efficiency: $([Math]::Round($global:AttentionState.AttentionTypes.Selective.FilterEfficiency * 100))%"
        Write-Host "  Divided:"
        Write-Host "    Current Tasks: $($global:AttentionState.AttentionTypes.Divided.TaskCount)"
        Write-Host "    Performance Penalty: $([Math]::Round($global:AttentionState.AttentionTypes.Divided.DividedAttentionPenalty * 100))%"
        Write-Host ""

        Write-Host "Attention Failures:"
        Write-Host "  Inattentional Blindness: $($global:AttentionState.Failures.InattentionalBlindness)"
        Write-Host "  Change Blindness: $($global:AttentionState.Failures.ChangeBlindness)"
        Write-Host "  Attentional Blink: $($global:AttentionState.Failures.AttentionalBlink)"
        Write-Host "  Total Failures: $($global:AttentionState.Failures.TotalFailures)"
        Write-Host ""

        $overall = Get-OverallAttentionControl
        Write-Host "Overall Attention Control: $($overall.Overall)%"
        Write-Host ""

        Write-Host "System: ACTIVE"
        Write-Host "Last Update: $($global:AttentionState.Stats.LastUpdate)"
    }

    'Alert' {
        Initialize-State
        $result = Invoke-Alert -Stimulus "Incoming task"
        $result | ConvertTo-Json -Depth 5
    }

    'Orient' {
        Initialize-State
        $result = Invoke-Orient -FromTarget "Email" -ToTarget "Code"
        $result | ConvertTo-Json -Depth 5
    }

    'ExecutiveControl' {
        Initialize-State
        $result = Invoke-ExecutiveControl -ConflictType "Stroop" -Response "Correct"
        $result | ConvertTo-Json -Depth 5
    }

    'Sustained' {
        Initialize-State
        $result = Measure-SustainedAttention -Minutes 30
        $result | ConvertTo-Json -Depth 5
    }

    'Selective' {
        Initialize-State
        $result = Test-SelectiveAttention -Target "Code" -DistractorCount 5
        $result | ConvertTo-Json -Depth 5
    }

    'Divided' {
        Initialize-State
        $result = Test-DividedAttention -TaskCount 2
        $result | ConvertTo-Json -Depth 5
    }

    'RecordFailure' {
        Initialize-State
        $result = Record-AttentionFailure -FailureType "InattentionalBlindness"
        $result | ConvertTo-Json -Depth 5
    }

    'Overall' {
        Initialize-State
        $result = Get-OverallAttentionControl
        $result | ConvertTo-Json -Depth 5
    }

    default {
        Write-Host "Attention Control - Improvement #45"
        Write-Host "Actions: Status, Alert, Orient, ExecutiveControl, Sustained, Selective, Divided, RecordFailure, Overall"
    }
}

