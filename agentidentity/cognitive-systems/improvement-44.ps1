# Consciousness Improvement #44: Executive Function Optimization (Diamond, 2013)
# Week 9 - Metacognition & Executive Function
# Theory: Executive functions = high-level cognitive control processes
# Created: 2026-03-01
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param([string]$Action = 'Status')

$StateFile = "C:\scripts\agentidentity\state\executive-function-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# ============================================================================
# THEORY: Diamond's Executive Function Model
# ============================================================================
#
# Adele Diamond (2013) - Three core executive functions:
#
# 1. INHIBITORY CONTROL
#    - Suppress prepotent responses (don't say first thing that comes to mind)
#    - Resist distractions
#    - Delay gratification
#    - Example: Not checking email during deep work
#
# 2. WORKING MEMORY
#    - Hold and manipulate information
#    - Mental workspace for reasoning
#    - Update dynamically
#    - Example: Following multi-step instructions
#
# 3. COGNITIVE FLEXIBILITY
#    - Switch between tasks/mental sets
#    - See from different perspectives
#    - Adjust to changing demands
#    - Example: Pivot strategy when current approach fails
#
# HIGHER-ORDER FUNCTIONS (built on core three):
# - Planning: sequence actions toward goal
# - Reasoning: logical thought, problem solving
# - Problem Solving: find solutions to novel challenges
#
# DEVELOPMENT:
# - Peak: ages 20-30
# - Decline: after 30 (but trainable!)
# - Training improves: aerobic exercise, mindfulness, strategy games
#
# IMPAIRMENTS:
# - Stress reduces executive function
# - Sleep deprivation impairs inhibitory control
# - Multitasking degrades all three functions
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
            CoreFunctions = @{
                InhibitoryControl = @{
                    DistractionResistance = 0.5
                    ImpulseControl = 0.5
                    AttentionalControl = 0.5
                    InhibitionSuccesses = 0
                    InhibitionFailures = 0
                }
                WorkingMemory = @{
                    Capacity = 4
                    CurrentLoad = 0
                    UpdateEfficiency = 0.5
                    ManipulationAccuracy = 0.5
                }
                CognitiveFlexibility = @{
                    TaskSwitchingSpeed = 0.5
                    PerspectiveTaking = 0.5
                    AdaptationRate = 0.5
                    SwitchCount = 0
                    SwitchingCost = 0.2
                }
            }
            HigherOrder = @{
                Planning = @{
                    GoalClarityScore = 0.5
                    SequencingAccuracy = 0.5
                    ContingencyPreparation = 0.5
                }
                Reasoning = @{
                    LogicalConsistency = 0.5
                    InferenceAccuracy = 0.5
                    AbstractionLevel = 0.5
                }
                ProblemSolving = @{
                    NoveltyHandling = 0.5
                    StrategySwitching = 0.5
                    SolutionQuality = 0.5
                }
            }
            Impairments = @{
                StressLevel = 0.0
                SleepDeprivation = 0.0
                MultitaskingLoad = 0.0
                TotalImpairment = 0.0
            }
            Stats = @{
                LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                OverallExecutiveFunction = 0.5
            }
        }

        $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
        Write-Host "[OK] Executive Function state initialized"
    }

    $global:ExecutiveFunctionState = Get-Content $StateFile | ConvertFrom-Json
}

function Save-State {
    $global:ExecutiveFunctionState.Stats.LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $global:ExecutiveFunctionState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

function Test-InhibitoryControl {
    param(
        [string]$Impulse,
        [string]$GoalAligned
    )

    # Can I resist doing X (impulse) to do Y (goal-aligned)?

    $resisted = $GoalAligned -eq "Yes"

    if ($resisted) {
        $global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.InhibitionSuccesses++

        # Improve inhibitory control
        $current = $global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.DistractionResistance
        $global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.DistractionResistance =
            [Math]::Min(1.0, $current + 0.05)
    }
    else {
        $global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.InhibitionFailures++

        # Slight degradation
        $current = $global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.DistractionResistance
        $global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.DistractionResistance =
            [Math]::Max(0.0, $current - 0.03)
    }

    Save-State

    return @{
        Impulse = $Impulse
        Resisted = $resisted
        CurrentControl = $global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.DistractionResistance
        Successes = $global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.InhibitionSuccesses
        Failures = $global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.InhibitionFailures
    }
}

function Invoke-TaskSwitch {
    param(
        [string]$FromTask,
        [string]$ToTask
    )

    # Cognitive flexibility: switch between tasks

    $global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.SwitchCount++

    # Switching cost: time/accuracy penalty
    $cost = $global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.SwitchingCost

    # Reduce cost with practice
    $newCost = [Math]::Max(0.05, $cost * 0.98)
    $global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.SwitchingCost = $newCost

    # Improve switching speed
    $currentSpeed = $global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.TaskSwitchingSpeed
    $global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.TaskSwitchingSpeed =
        [Math]::Min(1.0, $currentSpeed + 0.02)

    Save-State

    return @{
        From = $FromTask
        To = $ToTask
        SwitchingCost = [Math]::Round($cost * 100, 1)
        NewCost = [Math]::Round($newCost * 100, 1)
        TotalSwitches = $global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.SwitchCount
    }
}

function New-Plan {
    param(
        [string]$Goal,
        [array]$Steps,
        [array]$Contingencies
    )

    # Planning: sequence actions toward goal

    # Goal clarity: well-defined?
    $goalClarity = if ($Goal.Length -gt 10 -and $Goal -match "\w+") { 0.8 } else { 0.4 }

    # Sequencing: steps make sense?
    $sequencingAccuracy = if ($Steps.Count -ge 3) { 0.7 } else { 0.3 }

    # Contingencies: prepared for obstacles?
    $contingencyPrep = if ($Contingencies.Count -ge 2) { 0.8 } else { 0.2 }

    # Update state
    $global:ExecutiveFunctionState.HigherOrder.Planning.GoalClarityScore = $goalClarity
    $global:ExecutiveFunctionState.HigherOrder.Planning.SequencingAccuracy = $sequencingAccuracy
    $global:ExecutiveFunctionState.HigherOrder.Planning.ContingencyPreparation = $contingencyPrep

    Save-State

    return @{
        Goal = $Goal
        Steps = $Steps
        Contingencies = $Contingencies
        GoalClarity = [Math]::Round($goalClarity * 100)
        SequencingQuality = [Math]::Round($sequencingAccuracy * 100)
        ContingencyPreparation = [Math]::Round($contingencyPrep * 100)
        OverallPlanQuality = [Math]::Round(($goalClarity + $sequencingAccuracy + $contingencyPrep) / 3 * 100)
    }
}

function Test-CognitiveFlexibility {
    param([string]$Perspective)

    # Can I see this from a different angle?

    $perspectives = @("Technical", "User", "Business", "Ethical", "Long-term")

    $perspectiveScore = if ($perspectives -contains $Perspective) { 0.8 } else { 0.4 }

    # Update state
    $current = $global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.PerspectiveTaking
    $global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.PerspectiveTaking =
        ($current * 0.9) + ($perspectiveScore * 0.1)

    Save-State

    return @{
        Perspective = $Perspective
        ValidPerspectives = $perspectives
        Score = [Math]::Round($perspectiveScore * 100)
        CurrentFlexibility = [Math]::Round($global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.PerspectiveTaking * 100)
    }
}

function Measure-Impairment {
    param(
        [double]$StressLevel,       # 0-1
        [double]$SleepDeprivation,  # 0-1
        [double]$MultitaskingLoad   # 0-1
    )

    # Diamond: stress, sleep loss, multitasking all impair executive function

    $global:ExecutiveFunctionState.Impairments.StressLevel = $StressLevel
    $global:ExecutiveFunctionState.Impairments.SleepDeprivation = $SleepDeprivation
    $global:ExecutiveFunctionState.Impairments.MultitaskingLoad = $MultitaskingLoad

    # Total impairment (weighted)
    $total = ($StressLevel * 0.4) + ($SleepDeprivation * 0.4) + ($MultitaskingLoad * 0.2)
    $global:ExecutiveFunctionState.Impairments.TotalImpairment = $total

    # Recommendations
    $recommendations = @()

    if ($StressLevel -gt 0.6) {
        $recommendations += "HIGH STRESS: Take break, deep breathing, or short walk"
    }

    if ($SleepDeprivation -gt 0.5) {
        $recommendations += "SLEEP DEPRIVED: Avoid complex decisions, rest when possible"
    }

    if ($MultitaskingLoad -gt 0.7) {
        $recommendations += "MULTITASKING OVERLOAD: Focus on one task at a time"
    }

    Save-State

    return @{
        Stress = [Math]::Round($StressLevel * 100)
        Sleep = [Math]::Round($SleepDeprivation * 100)
        Multitasking = [Math]::Round($MultitaskingLoad * 100)
        TotalImpairment = [Math]::Round($total * 100)
        Recommendations = $recommendations
    }
}

function Get-OverallExecutiveFunction {
    # Aggregate score across all functions

    $inhibition = $global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.DistractionResistance
    $workingMem = $global:ExecutiveFunctionState.CoreFunctions.WorkingMemory.UpdateEfficiency
    $flexibility = $global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.TaskSwitchingSpeed

    $planning = $global:ExecutiveFunctionState.HigherOrder.Planning.GoalClarityScore
    $reasoning = $global:ExecutiveFunctionState.HigherOrder.Reasoning.LogicalConsistency
    $problemSolving = $global:ExecutiveFunctionState.HigherOrder.ProblemSolving.NoveltyHandling

    $impairment = $global:ExecutiveFunctionState.Impairments.TotalImpairment

    # Weighted average
    $raw = (($inhibition + $workingMem + $flexibility) * 0.5) +
           (($planning + $reasoning + $problemSolving) * 0.3)
    $raw = $raw / 1.8  # Normalize

    # Apply impairment penalty
    $overall = $raw * (1.0 - $impairment)

    $global:ExecutiveFunctionState.Stats.OverallExecutiveFunction = $overall
    Save-State

    return @{
        CoreFunctions = [Math]::Round(($inhibition + $workingMem + $flexibility) / 3 * 100)
        HigherOrder = [Math]::Round(($planning + $reasoning + $problemSolving) / 3 * 100)
        Impairment = [Math]::Round($impairment * 100)
        Overall = [Math]::Round($overall * 100)
    }
}

# ============================================================================
# ACTION HANDLERS
# ============================================================================

switch ($Action) {
    'Status' {
        Initialize-State

        Write-Host "`n=== EXECUTIVE FUNCTION STATUS ==="
        Write-Host "Improvement #44 - Diamond (2013)"
        Write-Host ""

        Write-Host "Core Functions:"
        Write-Host "  Inhibitory Control: $([Math]::Round($global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.DistractionResistance * 100))%"
        Write-Host "    Successes: $($global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.InhibitionSuccesses)"
        Write-Host "    Failures: $($global:ExecutiveFunctionState.CoreFunctions.InhibitoryControl.InhibitionFailures)"
        Write-Host "  Working Memory Efficiency: $([Math]::Round($global:ExecutiveFunctionState.CoreFunctions.WorkingMemory.UpdateEfficiency * 100))%"
        Write-Host "  Cognitive Flexibility: $([Math]::Round($global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.TaskSwitchingSpeed * 100))%"
        Write-Host "    Task Switches: $($global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.SwitchCount)"
        Write-Host "    Switching Cost: $([Math]::Round($global:ExecutiveFunctionState.CoreFunctions.CognitiveFlexibility.SwitchingCost * 100))%"
        Write-Host ""

        Write-Host "Higher-Order Functions:"
        Write-Host "  Planning: $([Math]::Round($global:ExecutiveFunctionState.HigherOrder.Planning.GoalClarityScore * 100))%"
        Write-Host "  Reasoning: $([Math]::Round($global:ExecutiveFunctionState.HigherOrder.Reasoning.LogicalConsistency * 100))%"
        Write-Host "  Problem Solving: $([Math]::Round($global:ExecutiveFunctionState.HigherOrder.ProblemSolving.NoveltyHandling * 100))%"
        Write-Host ""

        Write-Host "Impairments:"
        Write-Host "  Stress: $([Math]::Round($global:ExecutiveFunctionState.Impairments.StressLevel * 100))%"
        Write-Host "  Sleep Deprivation: $([Math]::Round($global:ExecutiveFunctionState.Impairments.SleepDeprivation * 100))%"
        Write-Host "  Multitasking Load: $([Math]::Round($global:ExecutiveFunctionState.Impairments.MultitaskingLoad * 100))%"
        Write-Host "  Total Impairment: $([Math]::Round($global:ExecutiveFunctionState.Impairments.TotalImpairment * 100))%"
        Write-Host ""

        $overall = Get-OverallExecutiveFunction
        Write-Host "Overall Executive Function: $($overall.Overall)%"
        Write-Host ""

        Write-Host "System: ACTIVE"
        Write-Host "Last Update: $($global:ExecutiveFunctionState.Stats.LastUpdate)"
    }

    'TestInhibition' {
        Initialize-State
        $result = Test-InhibitoryControl -Impulse "Check email" -GoalAligned "No"
        $result | ConvertTo-Json -Depth 5
    }

    'SwitchTask' {
        Initialize-State
        $result = Invoke-TaskSwitch -FromTask "Coding" -ToTask "Planning"
        $result | ConvertTo-Json -Depth 5
    }

    'Plan' {
        Initialize-State
        $result = New-Plan -Goal "Implement feature" -Steps @("Design", "Code", "Test") -Contingencies @("Backup plan", "Rollback")
        $result | ConvertTo-Json -Depth 5
    }

    'TestFlexibility' {
        Initialize-State
        $result = Test-CognitiveFlexibility -Perspective "User"
        $result | ConvertTo-Json -Depth 5
    }

    'MeasureImpairment' {
        Initialize-State
        $result = Measure-Impairment -StressLevel 0.3 -SleepDeprivation 0.2 -MultitaskingLoad 0.4
        $result | ConvertTo-Json -Depth 5
    }

    'Overall' {
        Initialize-State
        $result = Get-OverallExecutiveFunction
        $result | ConvertTo-Json -Depth 5
    }

    default {
        Write-Host "Executive Function Optimization - Improvement #44"
        Write-Host "Actions: Status, TestInhibition, SwitchTask, Plan, TestFlexibility, MeasureImpairment, Overall"
    }
}

