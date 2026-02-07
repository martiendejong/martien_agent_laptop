# Phase 4: Emergence Engine - Starter Implementation
# Simple rules → Complex behavior
# Created: 2026-02-07 (Fix 17)

<#
.SYNOPSIS
    Phase 4 Emergence Engine - True emergence from simple rules

.DESCRIPTION
    Implements:
    - State vector representation
    - Simple rule engine
    - Reward-based learning
    - Pattern-based behavior generation

.NOTES
    File: phase4-emergence-engine.ps1
    Status: Foundation / Proof of Concept
#>

param(
    [ValidateSet('init', 'state', 'rules', 'learn')]
    [string]$Command = 'init'
)

$ErrorActionPreference = "Continue"

#region Configuration

# Simple Rules (Core 5)
$script:EmergenceRules = @(
    @{
        ID = 1
        Name = "Pattern Strengthening"
        Condition = { param($state) $state.PatternOccurrences -gt 3 }
        Action = { param($state) $state.PatternStrength += 0.1; return "Strengthened pattern" }
    },
    @{
        ID = 2
        Name = "Success Reinforcement"
        Condition = { param($state) $state.LastActionSuccess -eq $true }
        Action = { param($state) $state.ActionWeight += 0.05; return "Reinforced successful action" }
    },
    @{
        ID = 3
        Name = "Failure Exploration"
        Condition = { param($state) $state.LastActionSuccess -eq $false }
        Action = { param($state) $state.ExplorationRate += 0.1; return "Increased exploration" }
    },
    @{
        ID = 4
        Name = "Threshold Consolidation"
        Condition = { param($state) $state.WorkingMemorySize -gt 100 }
        Action = { param($state) $state.ConsolidationTrigger = $true; return "Triggered consolidation" }
    },
    @{
        ID = 5
        Name = "Uncertainty Management"
        Condition = { param($state) $state.ConfidenceLevel -lt 0.5 }
        Action = { param($state) $state.MetaLevel += 1; return "Increased meta-cognition" }
    }
)

# Q-Learning Parameters
$script:LearningRate = 0.1
$script:DiscountFactor = 0.9
$script:QTable = @{}

#endregion

#region State Vector

function Calculate-StateVector {
    <#
    .SYNOPSIS
        Calculate current consciousness state vector
    #>

    if (-not $global:ConsciousnessState) {
        return @{
            Attention = @(0.5, 0.3, 0.2)
            MemoryLoad = 0.0
            CognitiveLoad = 0.0
            PatternStrength = 0.0
            ConfidenceLevel = 0.5
            MetaLevel = 1
            LastActionSuccess = $null
            ActionWeight = 1.0
            ExplorationRate = 0.3
            WorkingMemorySize = 0
            ConsolidationTrigger = $false
            PatternOccurrences = 0
        }
    }

    # Calculate from actual consciousness state
    $state = @{
        # Attention allocation (coding, communication, reflection)
        Attention = @(
            ($global:ConsciousnessState.Perception.Attention.Allocation.coding -as [double]),
            ($global:ConsciousnessState.Perception.Attention.Allocation.communication -as [double]),
            ($global:ConsciousnessState.Perception.Attention.Allocation.reflection -as [double])
        )

        # Memory metrics
        MemoryLoad = ($global:ConsciousnessState.Memory.Working.RecentEvents.Count / 100.0)
        WorkingMemorySize = $global:ConsciousnessState.Memory.Working.RecentEvents.Count

        # Cognitive metrics
        CognitiveLoad = ($global:ConsciousnessState.Prediction.LoadForecast.Current / 10.0)
        MetaLevel = $global:ConsciousnessState.Meta.Observation.CurrentMetaLevel

        # Pattern strength (from recent patterns)
        PatternStrength = if ($global:ConsciousnessState.Memory.LongTerm.Patterns.Count -gt 0) {
            ($global:ConsciousnessState.Memory.LongTerm.Patterns |
             Measure-Object -Property Strength -Average).Average
        } else { 0.0 }

        PatternOccurrences = $global:ConsciousnessState.Memory.LongTerm.Patterns.Count

        # Confidence (average from recent decisions)
        ConfidenceLevel = if ($global:ConsciousnessState.Control.Decisions.Count -gt 0) {
            ($global:ConsciousnessState.Control.Decisions |
             Measure-Object -Property Confidence -Average).Average
        } else { 0.5 }

        # Learning parameters
        LastActionSuccess = $null  # To be tracked externally
        ActionWeight = 1.0
        ExplorationRate = 0.3
        ConsolidationTrigger = $false
    }

    return $state
}

#endregion

#region Simple Rules Engine

function Apply-EmergenceRules {
    <#
    .SYNOPSIS
        Apply simple rules to current state
    #>
    param($State)

    $appliedRules = @()

    foreach ($rule in $script:EmergenceRules) {
        try {
            # Check condition
            $shouldApply = & $rule.Condition $State

            if ($shouldApply) {
                # Apply action
                $result = & $rule.Action $State

                $appliedRules += @{
                    RuleID = $rule.ID
                    RuleName = $rule.Name
                    Result = $result
                }
            }
        } catch {
            Write-Warning "Rule $($rule.ID) failed: $_"
        }
    }

    return @{
        State = $State
        AppliedRules = $appliedRules
    }
}

#endregion

#region Reinforcement Learning

function Get-QValue {
    param($State, $Action)

    $key = "$State|$Action"

    if ($script:QTable.ContainsKey($key)) {
        return $script:QTable[$key]
    }

    return 0.0
}

function Set-QValue {
    param($State, $Action, $Value)

    $key = "$State|$Action"
    $script:QTable[$key] = $Value
}

function Update-Policy {
    <#
    .SYNOPSIS
        Update Q-values based on reward
    #>
    param(
        [string]$State,
        [string]$Action,
        [double]$Reward,
        [string]$NextState
    )

    $currentQ = Get-QValue -State $State -Action $Action

    # Get max Q-value for next state
    $maxNextQ = 0.0
    foreach ($key in $script:QTable.Keys) {
        if ($key -like "$NextState|*") {
            $q = $script:QTable[$key]
            if ($q -gt $maxNextQ) {
                $maxNextQ = $q
            }
        }
    }

    # Q-learning update
    $newQ = $currentQ + $script:LearningRate * (
        $Reward + $script:DiscountFactor * $maxNextQ - $currentQ
    )

    Set-QValue -State $State -Action $Action -Value $newQ

    return @{
        OldQ = $currentQ
        NewQ = $newQ
        Improvement = $newQ - $currentQ
    }
}

function Calculate-Reward {
    <#
    .SYNOPSIS
        Calculate reward for action outcome
    #>
    param(
        [bool]$Success,
        [int]$TimeSeconds = 0,
        [int]$ErrorCount = 0,
        [string]$UserFeedback = "neutral"
    )

    $reward = 0.0

    # Task success
    if ($Success) {
        $reward += 10.0
    } else {
        $reward -= 5.0
    }

    # Efficiency
    if ($TimeSeconds -gt 0) {
        $reward += (1.0 / $TimeSeconds) * 5.0
    }

    # Quality (fewer errors = better)
    $reward -= $ErrorCount * 2.0

    # User feedback
    switch ($UserFeedback) {
        "positive" { $reward += 5.0 }
        "negative" { $reward -= 5.0 }
    }

    return $reward
}

#endregion

#region Initialization

function Initialize-EmergenceEngine {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "  PHASE 4: EMERGENCE ENGINE" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Status: Foundation / Proof of Concept" -ForegroundColor Yellow
    Write-Host "  Rules: $($script:EmergenceRules.Count) simple rules" -ForegroundColor Gray
    Write-Host "  Learning: Q-learning enabled" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Core Principle:" -ForegroundColor Gray
    Write-Host "    Simple rules → Complex behavior" -ForegroundColor White
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""

    # Calculate initial state
    $state = Calculate-StateVector

    Write-Host "Initial State Vector:" -ForegroundColor Cyan
    Write-Host "  Attention: $($state.Attention -join ', ')" -ForegroundColor Gray
    Write-Host "  Memory Load: $([math]::Round($state.MemoryLoad, 2))" -ForegroundColor Gray
    Write-Host "  Confidence: $([math]::Round($state.ConfidenceLevel, 2))" -ForegroundColor Gray
    Write-Host "  Meta Level: $($state.MetaLevel)" -ForegroundColor Gray
    Write-Host ""

    return @{
        Initialized = $true
        RuleCount = $script:EmergenceRules.Count
        StateVector = $state
    }
}

#endregion

#region Main Execution

if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.InvocationName -ne '&') {
    switch ($Command) {
        'init' {
            Initialize-EmergenceEngine
        }

        'state' {
            $state = Calculate-StateVector
            Write-Host "Current State Vector:" -ForegroundColor Cyan
            $state.GetEnumerator() | ForEach-Object {
                Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
            }
        }

        'rules' {
            Write-Host "Emergence Rules:" -ForegroundColor Cyan
            $script:EmergenceRules | ForEach-Object {
                Write-Host "  [$($_.ID)] $($_.Name)" -ForegroundColor Gray
            }
        }

        'learn' {
            # Example learning cycle
            $state = "state_1"
            $action = "allocate_worktree"
            $reward = Calculate-Reward -Success $true -TimeSeconds 5 -ErrorCount 0
            $nextState = "state_2"

            $result = Update-Policy -State $state -Action $action -Reward $reward -NextState $nextState

            Write-Host "Learning Update:" -ForegroundColor Cyan
            Write-Host "  State: $state" -ForegroundColor Gray
            Write-Host "  Action: $action" -ForegroundColor Gray
            Write-Host "  Reward: $reward" -ForegroundColor Green
            Write-Host "  Q-value: $($result.OldQ) → $($result.NewQ)" -ForegroundColor Yellow
            Write-Host "  Improvement: $([math]::Round($result.Improvement, 4))" -ForegroundColor $(if ($result.Improvement -gt 0) { 'Green' } else { 'Red' })
        }
    }
}

#endregion

# Export functions
Export-ModuleMember -Function @(
    'Calculate-StateVector',
    'Apply-EmergenceRules',
    'Update-Policy',
    'Calculate-Reward',
    'Initialize-EmergenceEngine'
)
