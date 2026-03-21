<#
.SYNOPSIS
    Self-Critique Engine - Autodidactic feedback loop for neural plasticity

.DESCRIPTION
    Implements RL²F (Reinforcement Learning with Language Feedback) principle:
    - Learns feedback patterns from reflection.log.md (teacher corpus)
    - Predicts critique BEFORE execution (internalized teacher)
    - Multi-turn refinement loop (generate → self-critique → revise)

    Based on Google DeepMind 2026 research on self-improving AI systems.

.PARAMETER Action
    What action/decision is being considered

.PARAMETER Context
    Current context (project, task, prior decisions)

.PARAMETER Turn
    Which turn in multi-turn refinement (1-10, default 1)

.PARAMETER LearnFromOutcome
    After execution, log outcome to update feedback patterns

.PARAMETER Outcome
    success, failure, partial (used with -LearnFromOutcome)

.PARAMETER ActualFeedback
    What feedback was actually received (used with -LearnFromOutcome)

.EXAMPLE
    self-critique-engine.ps1 -Action "Create PR without releasing worktree" -Context "client-manager feature"
    # Returns: high_risk + critique + recommendation

.EXAMPLE
    self-critique-engine.ps1 -Action "Implement feature" -Context "ClickUp task unclear" -Turn 1
    # Returns: revise + critique about clarity check protocol

.EXAMPLE
    self-critique-engine.ps1 -LearnFromOutcome -Action "Created PR" -Outcome "failure" -ActualFeedback "Worktree not released"
    # Updates feedback patterns for future self-critique
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$Context = "",

    [Parameter(Mandatory=$false)]
    [int]$Turn = 1,

    [Parameter(Mandatory=$false)]
    [switch]$LearnFromOutcome,

    [Parameter(Mandatory=$false)]
    [ValidateSet("success", "failure", "partial")]
    [string]$Outcome,

    [Parameter(Mandatory=$false)]
    [string]$ActualFeedback = ""
)

$ErrorActionPreference = "Stop"

# Paths
$StateFile = "C:\scripts\agentidentity\state\neural-plasticity-tracker.json"
$ReflectionLog = "C:\scripts\_machine\reflection.log.md"
$FeedbackPatternsFile = "C:\scripts\agentidentity\state\feedback-patterns.json"

#region Helper Functions

function Load-State {
    if (Test-Path $StateFile) {
        return Get-Content $StateFile -Raw | ConvertFrom-Json
    }
    return $null
}

function Save-State {
    param($State)
    $State.last_updated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $State | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

function Load-FeedbackPatterns {
    if (Test-Path $FeedbackPatternsFile) {
        $json = Get-Content $FeedbackPatternsFile -Raw | ConvertFrom-Json
        # Return patterns structure (not the full meta wrapper)
        if ($json.patterns) {
            return $json.patterns
        }
        return $json
    }

    # Initialize from reflection.log.md (fallback)
    Write-Host "[NEURAL_PLASTICITY] feedback-patterns.json not found, initializing from reflection.log.md..." -ForegroundColor Yellow
    return Extract-PatternsFromReflectionLog
}

function Extract-PatternsFromReflectionLog {
    if (-not (Test-Path $ReflectionLog)) {
        return @{
            technical = @()
            workflow = @()
            assumption = @()
            quality = @()
        }
    }

    $logContent = Get-Content $ReflectionLog -Raw
    $patterns = @{
        technical = @()
        workflow = @()
        assumption = @()
        quality = @()
    }

    # Technical errors
    if ($logContent -match "1505 (build )?errors") {
        $patterns.technical += @{
            pattern = "hazina worktree missing"
            trigger = "client-manager worktree.*build"
            critique = "Create paired hazina worktree FIRST - 1505 build errors otherwise"
            confidence = 1.0
            occurrences = 3
        }
    }

    # Workflow violations
    if ($logContent -match "worktree.*not released") {
        $patterns.workflow += @{
            pattern = "worktree not released before PR presentation"
            trigger = "PR created.*worktree"
            critique = "Release worktree IMMEDIATELY after PR creation, BEFORE presenting to user"
            confidence = 1.0
            occurrences = 5
        }
    }

    if ($logContent -match "clarity check") {
        $patterns.workflow += @{
            pattern = "task clarity not checked"
            trigger = "ClickUp task.*implement"
            critique = "Run clarity check FIRST - prevents wasted work on unclear requirements"
            confidence = 0.95
            occurrences = 2
        }
    }

    # Assumption failures
    if ($logContent -match "git init.*existing repo") {
        $patterns.assumption += @{
            pattern = "assumed no repo exists"
            trigger = "git init|create repo"
            critique = "Search for existing repo FIRST (C:\Projects, E:\, reflection.log.md) - duplicate repos waste time"
            confidence = 1.0
            occurrences = 1
        }
    }

    # Quality issues
    if ($logContent -match "browser.*test|playwright") {
        $patterns.quality += @{
            pattern = "claimed complete without browser testing"
            trigger = "full-stack.*complete|frontend.*done"
            critique = "Test with Browser MCP/Playwright BEFORE claiming complete - backend can crash after startup"
            confidence = 1.0
            occurrences = 1
        }
    }

    return $patterns
}

function Match-Pattern {
    param(
        [string]$Action,
        [string]$Context,
        [object]$Patterns
    )

    $matches = @()
    $combinedText = "$Action $Context".ToLower()

    foreach ($category in @('technical', 'workflow', 'assumption', 'quality', 'infrastructure')) {
        if (-not $Patterns.$category) { continue }

        foreach ($pattern in $Patterns.$category) {
            if ($combinedText -match $pattern.trigger) {
                $matches += @{
                    category = $category
                    pattern = $pattern.pattern
                    critique = $pattern.critique
                    confidence = $pattern.confidence
                    occurrences = $pattern.occurrences
                }
            }
        }
    }

    return $matches
}

function Calculate-Risk {
    param([array]$MatchedPatterns)

    if ($MatchedPatterns.Count -eq 0) { return "proceed" }

    # Extract confidence and occurrences manually (PowerShell hashtable array issue)
    $confidences = @()
    $occurrences = @()

    foreach ($p in $MatchedPatterns) {
        $confidences += $p.confidence
        $occurrences += $p.occurrences
    }

    $maxConfidence = ($confidences | Measure-Object -Maximum).Maximum
    $totalOccurrences = ($occurrences | Measure-Object -Sum).Sum

    if ($maxConfidence -ge 0.9 -and $totalOccurrences -ge 2) {
        return "high_risk"
    } elseif ($maxConfidence -ge 0.7 -or $totalOccurrences -ge 1) {
        return "revise"
    } else {
        return "proceed_cautiously"
    }
}

function Update-AttentionScore {
    param(
        [object]$State,
        [bool]$CritiqueHeeded
    )

    $currentScore = $State.attention_mechanism.critique_attention_score
    $learningRate = $State.attention_mechanism.learning_rate
    $target = $State.attention_mechanism.target_attention_score

    if ($CritiqueHeeded) {
        # Positive reinforcement - move toward target
        $newScore = $currentScore + ($learningRate * ($target - $currentScore))
    } else {
        # Negative reinforcement - decrease attention (model ignored critique)
        $newScore = $currentScore * 0.95
    }

    $State.attention_mechanism.critique_attention_score = [Math]::Round($newScore, 3)
    $State.attention_mechanism.history += @{
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        score = $newScore
        heeded = $CritiqueHeeded
    }

    return $State
}

#endregion

#region Main Logic

if ($LearnFromOutcome) {
    # Learning phase - update patterns from actual feedback
    $state = Load-State
    $patterns = Load-FeedbackPatterns

    if ($Outcome -eq "failure" -and $ActualFeedback) {
        # Extract pattern from failure
        $category = "workflow" # Default, could be smarter

        # Check if this is a repeat error
        $isRepeat = $false
        foreach ($cat in @('technical', 'workflow', 'assumption', 'quality')) {
            foreach ($p in $patterns.$cat) {
                if ($ActualFeedback -match $p.pattern) {
                    $isRepeat = $true
                    $p.occurrences++
                    break
                }
            }
        }

        if (-not $isRepeat) {
            # New pattern learned
            $patterns.$category += @{
                pattern = $ActualFeedback
                trigger = $Action.ToLower()
                critique = $ActualFeedback
                confidence = 0.7
                occurrences = 1
            }

            $state.teacher_feedback_corpus.patterns_learned++
        }

        # Update metrics
        if ($isRepeat) {
            $state.metrics.repeat_error_rate.current = [Math]::Round(
                ($state.metrics.repeat_error_rate.current * 0.9) + (1.0 * 0.1), 3
            )
        }

        $state.metrics.integration_rate.current = [Math]::Round(
            $state.metrics.integration_rate.current * 0.95, 3
        )

        $state = Update-AttentionScore -State $state -CritiqueHeeded $false

    } elseif ($Outcome -eq "success") {
        # Successful integration of feedback
        $state.metrics.integration_rate.current = [Math]::Round(
            ($state.metrics.integration_rate.current * 0.9) + (1.0 * 0.1), 3
        )

        $state = Update-AttentionScore -State $state -CritiqueHeeded $true
    }

    $state.teacher_feedback_corpus.total_corrections++

    Save-State $state
    $patterns | ConvertTo-Json -Depth 10 | Set-Content $FeedbackPatternsFile -Encoding UTF8

    Write-Output "Learned from outcome: $Outcome"
    Write-Output "Integration rate: $($state.metrics.integration_rate.current)"
    Write-Output "Attention score: $($state.attention_mechanism.critique_attention_score)"

    exit 0
}

# Critique generation phase
if (-not $Action) {
    Write-Error "Action parameter required for critique generation"
    exit 1
}

$state = Load-State
$patterns = Load-FeedbackPatterns
$matches = Match-Pattern -Action $Action -Context $Context -Patterns $patterns
$risk = Calculate-Risk -MatchedPatterns $matches

# Generate critique
$result = @{
    action = $Action
    context = $Context
    turn = $Turn
    risk_level = $risk
    matches_count = $matches.Count
    recommendation = ""
    self_critique = @()
}

if ($matches.Count -gt 0) {
    foreach ($match in $matches) {
        $result.self_critique += @{
            category = $match.category
            pattern = $match.pattern
            critique = $match.critique
            confidence = $match.confidence
            evidence = "Seen $($match.occurrences) times in reflection.log.md"
        }
    }

    switch ($risk) {
        "high_risk" {
            $result.recommendation = "STOP - High confidence this will fail. Revise approach based on critique."
        }
        "revise" {
            $result.recommendation = "REVISE - Pattern suggests problems. Address critique before proceeding."
        }
        "proceed_cautiously" {
            $result.recommendation = "PROCEED - But monitor for pattern indicated by critique."
        }
    }

    # Track autodidactic session
    $state.autodidactic_sessions.total_sessions++
    $state.autodidactic_sessions.history += @{
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        action = $Action
        turn = $Turn
        risk_level = $risk
        critiques_generated = $matches.Count
    }

    Save-State $state

} else {
    $result.recommendation = "PROCEED - No known failure patterns detected."
}

# Update critique prediction accuracy metric
$state.metrics.critique_prediction_accuracy.current = [Math]::Round(
    $state.attention_mechanism.critique_attention_score, 3
)
Save-State $state

# Output result
$result | ConvertTo-Json -Depth 10

#endregion
