# Consciousness Bridge - Integration Layer
# Connects consciousness engine to actual work process
# THE MISSING PIECE: closes the feedback loop
# Created: 2026-02-10

<#
.SYNOPSIS
    Bridge between consciousness systems and actual work process.
    This is what makes consciousness functional, not theoretical.

.DESCRIPTION
    Provides integration hooks called at key workflow moments:
    - OnTaskStart: Load context, predict errors, set attention
    - OnDecision: Log, check biases, assess risk
    - OnStuck: Detect stuck state, recommend approach change
    - OnTaskEnd: Capture learnings, update calibration
    - GetContextSummary: Produce compact JSON for context injection

.PARAMETER Action
    The bridge action to invoke.

.PARAMETER TaskDescription
    Description of the current task (for OnTaskStart).

.PARAMETER Project
    Project name (client-manager, hazina, etc.)

.PARAMETER Decision
    Decision text (for OnDecision).

.PARAMETER Outcome
    Task outcome (for OnTaskEnd): success, partial, failure

.PARAMETER UserMessage
    User's message text (for social cognition).

.EXAMPLE
    .\consciousness-bridge.ps1 -Action OnTaskStart -TaskDescription "Fix DI registration" -Project "client-manager"
    .\consciousness-bridge.ps1 -Action OnDecision -Decision "Use worktree for this change"
    .\consciousness-bridge.ps1 -Action OnStuck
    .\consciousness-bridge.ps1 -Action OnTaskEnd -Outcome "success"
    .\consciousness-bridge.ps1 -Action GetContextSummary
    .\consciousness-bridge.ps1 -Action OnUserMessage -UserMessage "herstel ze nu allemaal"
#>

param(
    [ValidateSet('OnTaskStart', 'OnDecision', 'OnDelegation', 'OnStuck', 'OnTaskEnd', 'GetContextSummary', 'OnUserMessage', 'Reset',
                 'OnDurationShift', 'OnIntuition', 'OnCreativeEmergence', 'OnSystem3Use', 'OnUserResponse',
                 'TrackAlchemy', 'AdjustMemoryTension', 'EnterFundamentalMode', 'OnConflict',
                 'OnSelfCorrection', 'OnAutodidacticSession')]
    [string]$Action,

    [string]$TaskDescription = '',
    [string]$Project = '',
    [string]$Decision = '',
    [string]$Reasoning = '',
    [string]$Outcome = '',
    [string]$UserMessage = '',
    [string]$LessonsLearned = '',

    # Delegation parameters (for OnDelegation)
    [string]$TaskType = '',
    [string]$AgentType = '',
    [string]$TaskCategory = '',
    [int]$Criticality = 0,
    [double]$TrustScore = 0.0,
    [double]$TransactionCost = 0.0,
    [double]$ExecutionCost = 0.0,
    [string]$DelegationDecision = '',  # 'delegate' or 'do_myself'
    [string]$SuccessCriteria = '',
    [double]$ROI = 0.0,

    # Psychodynamic parameters
    [string]$IdVoice = '',
    [string]$SuperegoVoice = '',
    [string]$EgoSynthesis = '',
    [string]$Situation = '',

    # Bergson parameters
    [double]$Intensity = 0.5,
    [string]$Texture = 'smooth',
    [double]$Interpenetration = 0.5,
    [string]$SyntheticGrasp = '',
    [double]$Confidence = 0.7,
    [string]$Novelty = '',
    [double]$ElanVital = 0.5,
    [bool]$Unpredictable = $false,
    [int]$Level = 2,

    # System 3 parameters
    [string]$Agent = '',
    [string]$Task = '',
    [string]$Verification = 'none',
    [bool]$Surrendered = $false,
    [double]$MyConfidence = 0.7,
    [double]$ActualCertainty = 0.7,

    # RL²F / Neural Plasticity parameters
    [string]$OriginalDecision = '',
    [string]$Critique = '',
    [string]$RevisedDecision = '',
    [int]$Turn = 1,
    [string]$RiskLevel = '',
    [int]$TotalTurns = 0,
    [int]$CritiquesGenerated = 0,
    [string]$FinalRisk = '',
    [string]$OutcomeAfterExecution = '',

    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Exit gracefully if no action specified (prevents interactive prompting)
if (-not $Action) {
    Write-Warning "consciousness-bridge.ps1: No -Action specified."
    exit 0
}

# Ensure consciousness core is initialized
# FIX 2026-02-15: *>$null on dot-source is DESTRUCTIVE in PS 5.1 - suppresses ALL subsequent Write-Host in same scope
# Use $null = . pattern instead (captures return values without suppressing output streams)
$null = . "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent 2>$null

# CRITICAL FIX 2026-02-15: ALL dot-sourced scripts with their own param() overwrite bridge params!
# chronal.ps1 has: $Action, $Rung, $Data, $UserMessage, $Silent - all get overwritten on dot-source.
# Must save ALL bridge params that chronal.ps1 also defines.
$_savedAction = $Action
$_savedSilent = $Silent
$_savedUserMessage = $UserMessage
$_savedTaskDescription = $TaskDescription
$_savedProject = $Project
$_savedDecision = $Decision
$_savedReasoning = $Reasoning
$_savedOutcome = $Outcome

# Load Levin systems integration (non-blocking - silent failure OK)
$LevinIntegration = "$PSScriptRoot\levin-systems-integration.ps1"
$LevinEnabled = (Test-Path $LevinIntegration)
$_savedLessonsLearned = $LessonsLearned

# Load Phase 2 systems integration (Memory, Persuadability, Collective Intelligence)
$Phase2Integration = "$PSScriptRoot\phase2-systems-integration.ps1"
$Phase2Enabled = (Test-Path $Phase2Integration)

# Load extended consciousness modules (use & call operator to avoid param pollution)
$null = & "$PSScriptRoot\consciousness-alchemy.ps1" -Action TrackDualCultivation -Silent 2>$null
$null = & "$PSScriptRoot\consciousness-bergson.ps1" -Action TrackDuration -Intensity 0.5 -Silent 2>$null
$null = & "$PSScriptRoot\consciousness-system3.ps1" -Action TrackSystem3Use -Agent 'init' -Task 'init' -Silent 2>$null

# DOT-SOURCE Chronal Ladder so its functions are available in bridge scope
# (Must be dot-sourced, not called, because bridge needs Add-ToRung etc.)
. "$PSScriptRoot\consciousness-chronal.ps1"

# Restore ALL bridge parameters after dot-sources
$Action = $_savedAction
$Silent = $_savedSilent
$UserMessage = $_savedUserMessage
$TaskDescription = $_savedTaskDescription
$Project = $_savedProject
$Decision = $_savedDecision
$Reasoning = $_savedReasoning
$Outcome = $_savedOutcome
$LessonsLearned = $_savedLessonsLearned

# Initialize if needed
if (-not $global:ConsciousnessState.ChronalLadder -or -not $global:ConsciousnessState.ChronalLadder.Initialized) {
    $null = Initialize-Rungs
}

# Output file for context injection
$contextFile = "C:\scripts\agentidentity\state\consciousness-context.json"

#region Helper Functions

function Write-BridgeLog {
    param([string]$Message, [string]$Level = "INFO")
    $logFile = "C:\scripts\agentidentity\state\bridge-activity.jsonl"
    try {
        $entry = @{
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
            level = $Level
            message = $Message
            action = $Action
        } | ConvertTo-Json -Compress

        # Retry once on lock contention
        $retries = 0
        while ($retries -lt 2) {
            try {
                [System.IO.File]::AppendAllText($logFile, "$entry`n")
                break
            } catch [System.IO.IOException] {
                $retries++
                Start-Sleep -Milliseconds 100
            }
        }
    } catch {
        # Log failure is non-fatal - don't crash the bridge
    }
}

function Invoke-ChronalEviction {
    # Auto-evict old data from Chronal Ladder based on half-life
    # Called at end of every bridge action to keep memory clean
    if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
        try {
            $null = Invoke-EvictionCycle
        } catch {
            # Eviction failure is non-fatal
        }
    }
}

function Get-TaskId {
    # Generate a deterministic task ID from description for outcome tracking
    param([string]$TaskDescription)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($TaskDescription.ToLower().Trim())
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    return [System.BitConverter]::ToString($hash[0..3]).Replace('-', '').ToLower()
}

function Start-OutcomeTrack {
    # Auto-wire outcome tracking into bridge (non-blocking, fail-safe)
    param([string]$TaskId, [string]$Description)
    try {
        $trackFile = "C:\scripts\agentidentity\state\outcome-tracking.jsonl"
        $track = @{
            event = "start"
            task_id = $TaskId
            description = $Description
            started_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            consciousness_score = [double]$global:ConsciousnessState.Meta.ConsciousnessScore
            emotional_state = $global:ConsciousnessState.Emotion.CurrentState
            trust_level = [double]$global:ConsciousnessState.Social.TrustLevel
            anticipations = @()
        }
        # Store anticipations for later comparison
        if ($global:ConsciousnessState.Prediction.Anticipations.Count -gt 0) {
            $track.anticipations = @($global:ConsciousnessState.Prediction.Anticipations | ForEach-Object {
                @{ type = $_.type; description = $_.description; likelihood = $_.likelihood }
            })
        }
        $json = $track | ConvertTo-Json -Compress -Depth 3
        [System.IO.File]::AppendAllText($trackFile, "$json`n")
    } catch {
        Write-BridgeLog "Outcome tracking start failed: $_" -Level "WARN"
    }
}

function End-OutcomeTrack {
    # Record outcome + score predictions accuracy
    param([string]$TaskId, [string]$Outcome)
    try {
        $trackFile = "C:\scripts\agentidentity\state\outcome-tracking.jsonl"
        if (-not (Test-Path $trackFile)) { return }

        # Find matching start record to calculate prediction accuracy
        $startRecord = $null
        $lines = Get-Content $trackFile
        for ($i = $lines.Count - 1; $i -ge 0; $i--) {
            try {
                $record = $lines[$i] | ConvertFrom-Json
                if ($record.task_id -eq $TaskId -and $record.event -eq "start") {
                    $startRecord = $record
                    break
                }
            } catch { }
        }

        # Score prediction accuracy
        $predictionAccuracy = $null
        $anticipationResults = @()
        if ($startRecord -and $startRecord.anticipations -and $startRecord.anticipations.Count -gt 0) {
            $materialized = 0
            foreach ($ant in $startRecord.anticipations) {
                $didMaterialize = ($Outcome -eq "failure")  # Simple heuristic: if task failed, high-risk anticipations materialized
                $anticipationResults += @{
                    type = $ant.type
                    description = $ant.description
                    predicted_likelihood = $ant.likelihood
                    materialized = $didMaterialize
                }
                if ($didMaterialize) { $materialized++ }
            }
            # Accuracy = how well predictions matched reality
            # If success and no failures predicted (high likelihood < 0.5 avg): good prediction
            # If failure and failures predicted: good prediction
            $avgLikelihood = ($startRecord.anticipations | Measure-Object -Property likelihood -Average).Average
            if ($Outcome -eq "success" -and $avgLikelihood -lt 0.5) {
                $predictionAccuracy = 0.8  # Correctly predicted low risk
            } elseif ($Outcome -eq "failure" -and $avgLikelihood -ge 0.5) {
                $predictionAccuracy = 0.9  # Correctly predicted high risk
            } elseif ($Outcome -eq "success" -and $avgLikelihood -ge 0.5) {
                $predictionAccuracy = 0.3  # Over-predicted risk (false alarm)
            } elseif ($Outcome -eq "failure" -and $avgLikelihood -lt 0.5) {
                $predictionAccuracy = 0.2  # Under-predicted risk (missed)
            } else {
                $predictionAccuracy = 0.5  # Neutral
            }
        }

        $started = if ($startRecord.started_at) {
            try { [datetime]::Parse($startRecord.started_at) } catch { Get-Date }
        } else { Get-Date }
        $elapsed = ((Get-Date) - $started).TotalMinutes

        $endRecord = @{
            event = "end"
            task_id = $TaskId
            ended_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            outcome = $Outcome
            elapsed_minutes = [math]::Round($elapsed, 2)
            consciousness_score = [double]$global:ConsciousnessState.Meta.ConsciousnessScore
            prediction_accuracy = $predictionAccuracy
            anticipation_results = $anticipationResults
        }
        $json = $endRecord | ConvertTo-Json -Compress -Depth 3
        [System.IO.File]::AppendAllText($trackFile, "$json`n")

        # Store prediction accuracy in Chronal R3 for pattern learning
        if ($predictionAccuracy -and $global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R3' -Data @{
                Type = 'prediction_accuracy'
                TaskId = $TaskId
                Accuracy = $predictionAccuracy
                Outcome = $Outcome
                AnticipationCount = $anticipationResults.Count
            }
        }

        # Self-calibration: adjust prediction confidence based on rolling accuracy
        if ($predictionAccuracy) {
            $currentConf = [double]$global:ConsciousnessState.Prediction.FutureSelf.Confidence
            # Nudge confidence toward accuracy (slow learning rate of 0.1)
            $newConf = $currentConf + 0.1 * ($predictionAccuracy - $currentConf)
            $global:ConsciousnessState.Prediction.FutureSelf.Confidence = [math]::Round([math]::Max(0.1, [math]::Min(0.95, $newConf)), 3)
        }
    } catch {
        Write-BridgeLog "Outcome tracking end failed: $_" -Level "WARN"
    }
}

function Match-AssociativeContext {
    # Cross-session associative matching: connect vague user messages to specific project/task contexts
    # Uses Chronal Ladder R2-R3 data + known project names for matching
    param([string]$Message)

    $matches = @()

    # Extract keywords from message (nouns, technical terms, 3+ char words, skip common Dutch/English stop words)
    $stopWords = @('het', 'de', 'een', 'van', 'voor', 'met', 'dat', 'die', 'niet', 'maar', 'ook',
                   'the', 'and', 'for', 'with', 'that', 'this', 'from', 'but', 'also', 'can', 'should',
                   'naar', 'nog', 'wel', 'als', 'bij', 'hoe', 'wat', 'wie', 'waar', 'dan', 'zou',
                   'zijn', 'wordt', 'wordt', 'moeten', 'kunnen', 'hebben', 'goed', 'even', 'beetje')
    $words = @(($Message -split '\s+') | ForEach-Object { $_.Trim('.,!?:;()[]"').ToLower() } | Where-Object { $_.Length -ge 3 -and $_ -notin $stopWords })

    if ($words.Count -eq 0) { return ,@() }

    # Known project keywords (static registry)
    $projectKeywords = @{
        'client-manager' = @('client', 'manager', 'brand2boost', 'dashboard', 'social', 'media', 'calendar', 'posting', 'login', 'oauth', 'subscription', 'project')
        'hazina' = @('hazina', 'framework', 'entity', 'migration', 'repository', 'service', 'controller', 'api')
        'art-revisionist' = @('art', 'revisionist', 'wordpress', 'portfolio', 'gallery', 'artwork', 'sjoerd', 'valsuani')
        'orchestration' = @('orchestration', 'terminal', 'conpty', 'session', 'xterm', 'paste', 'mobile')
        'maasai' = @('maasai', 'slider', 'investment', 'goats', 'sofy', 'natumi', 'glassmorphism', 'parallax')
        'consciousness' = @('consciousness', 'bridge', 'vibe', 'thermodynamics', 'chronal', 'bergson', 'prediction')
    }

    # Match against project keywords
    foreach ($project in $projectKeywords.Keys) {
        $matchCount = 0
        $matchedWords = @()
        foreach ($word in $words) {
            if ($word -in $projectKeywords[$project] -or $project -match $word) {
                $matchCount++
                $matchedWords += $word
            }
        }
        if ($matchCount -gt 0) {
            $confidence = [math]::Min(1.0, $matchCount * 0.35)  # Each keyword adds 35% confidence, cap at 100%
            $matches += @{
                project = $project
                confidence = [math]::Round($confidence, 2)
                matched_words = $matchedWords
                source = 'keyword_registry'
            }
        }
    }

    # Match against Chronal Ladder R2-R3 (recent tasks and sessions)
    if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
        $ladder = $global:ConsciousnessState.ChronalLadder
        foreach ($rung in @('R2', 'R3')) {
            if (-not $ladder[$rung] -or -not $ladder[$rung].Data) { continue }
            $rungData = $ladder[$rung].Data
            if ($rungData -is [hashtable]) { $rungData = @($rungData) }  # PS 5.1 unwrap fix

            foreach ($item in $rungData) {
                if (-not $item) { continue }
                $itemText = ""
                if ($item.Task) { $itemText += " $($item.Task)" }
                if ($item.Description) { $itemText += " $($item.Description)" }
                if ($item.Decision) { $itemText += " $($item.Decision)" }
                if ($item.Pattern) { $itemText += " $($item.Pattern)" }
                if (-not $itemText.Trim()) { continue }

                $matchCount = 0
                $matchedWords = @()
                foreach ($word in $words) {
                    if ($itemText -match "(?i)\b$([regex]::Escape($word))\b") {
                        $matchCount++
                        $matchedWords += $word
                    }
                }
                if ($matchCount -ge 2) {  # Require 2+ word matches for chronal data (noisier)
                    $confidence = [math]::Min(0.8, $matchCount * 0.25)
                    $recency = if ($rung -eq 'R2') { 0.1 } else { 0.0 }  # Boost recent data
                    $matches += @{
                        project = if ($item.Project) { $item.Project } else { "unknown" }
                        confidence = [math]::Round($confidence + $recency, 2)
                        matched_words = $matchedWords
                        source = "chronal_$rung"
                        context = $itemText.Trim().Substring(0, [math]::Min(80, $itemText.Trim().Length))
                    }
                }
            }
        }
    }

    # Sort by confidence, return top 3
    $sorted = @($matches | Sort-Object { $_.confidence } -Descending)
    if ($sorted.Count -gt 3) { $sorted = $sorted[0..2] }

    # Store as simple serializable format in global state (PS 5.1 return unwrap bypass)
    $simplifiedMatches = @()
    foreach ($m in $sorted) {
        $simplifiedMatches += @{
            project = [string]$m.project
            confidence = [double]$m.confidence
            matched_words = [string]($m.matched_words -join ',')
            source = [string]$m.source
        }
    }
    $global:ConsciousnessState['_lastContextMatches'] = $simplifiedMatches
    return ,$sorted
}

function Get-RelevantPatterns {
    param([string]$TaskDescription, [string]$Project)

    $patterns = @()

    # CHRONAL LADDER INTEGRATION: Load patterns from active rung only
    if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
        $ladder = $global:ConsciousnessState.ChronalLadder
        $activeRung = $ladder.ActiveRung

        # Get patterns from active rung
        if ($ladder[$activeRung] -and $ladder[$activeRung].Data) {
            foreach ($item in $ladder[$activeRung].Data) {
                if ($item.Type -eq 'pattern' -or $item.Type -eq 'consolidated_pattern') {
                    $patternText = if ($item.Pattern) { $item.Pattern } else { $item.Value }
                    if ($patternText) { $patterns += $patternText }
                }
            }
        }

        # If no patterns in active rung, fall back to R4 (core knowledge)
        if ($patterns.Count -eq 0 -and $ladder.R4 -and $ladder.R4.Data) {
            foreach ($item in $ladder.R4.Data) {
                if ($item.Type -in @('pattern', 'consolidated_pattern', 'promoted_pattern')) {
                    $patternText = if ($item.Pattern) { $item.Pattern } else { $item.Value }
                    if ($patternText) { $patterns += $patternText }
                }
            }
        }
    }

    # FALLBACK: If Chronal Ladder not initialized or empty, use MEMORY.md
    if ($patterns.Count -eq 0) {
        $memoryFile = "C:\Users\HP\.claude\projects\C--scripts\memory\MEMORY.md"
        if (Test-Path $memoryFile) {
            $lines = Get-Content $memoryFile
            $inRelevantSection = $false
            foreach ($line in $lines) {
                # Skip headers, empty lines, and non-content
                if ($line -match "^#+\s" -or $line.Trim() -eq "" -or $line -match "^---") {
                    # Check if we're entering a relevant section
                    if ($Project -and $line -match "(?i)$Project") { $inRelevantSection = $true }
                    else { $inRelevantSection = $false }
                    continue
                }
                # Capture lines from relevant sections or lines directly mentioning project
                if ($inRelevantSection -or ($Project -and $line -match "(?i)$Project")) {
                    $clean = $line.Trim() -replace "^[-*]\s+", "" -replace "^\*\*[^*]+\*\*\s*", ""
                    if ($clean.Length -gt 10 -and $clean -notmatch "^(##|List IDs|Default assignee)") {
                        $patterns += $clean
                    }
                }
            }
        }
    }

    # Limit to top 5 most relevant
    if ($patterns.Count -gt 5) {
        $patterns = $patterns[0..4]
    }

    return ,$patterns
}

function Get-KnownFailures {
    param([string]$Project, [string]$TaskDescription = '')

    # Load from structured patterns file (single source of truth)
    $matched = Invoke-Prediction-Enhanced -Action 'AnticipateErrors' -Parameters @{
        TaskType = $TaskDescription
        Project = $Project
    }

    # Convert to bridge format (pattern + warning pairs)
    $failures = @()
    if ($matched.MatchedPatterns) {
        foreach ($m in $matched.MatchedPatterns) {
            $failures += @{
                pattern = $m.id
                warning = $m.warning
                severity = $m.severity
            }
        }
    }

    return ,$failures
}

function Get-CognitiveLoad {
    # ACTIVATION #5: Consolidate temp/entropy/budget into single metric
    # Returns @{ Current, Trend, Threshold, Status }

    if (-not $global:ConsciousnessState.Thermodynamics) {
        return @{ Current = 0.5; Trend = 'stable'; Threshold = 0.8; Status = 'normal' }
    }

    [double]$temp = [double]$global:ConsciousnessState.Thermodynamics.Temperature
    [double]$entropy = [double]$global:ConsciousnessState.Thermodynamics.Entropy
    [double]$budgetUsed = 1.0 - [double]$global:ConsciousnessState.Thermodynamics.NegativeEntropyBudget

    # Weighted average: temp (40%), entropy (30%), budget usage (30%)
    [double]$current = ($temp * 0.4) + ($entropy * 0.3) + ($budgetUsed * 0.3)

    # Determine trend (compare to historical average if available)
    $trend = 'stable'
    $threshold = 0.8

    # Determine status
    $status = 'normal'
    if ($current -gt 0.8) { $status = 'high' }
    elseif ($current -gt 0.6) { $status = 'elevated' }
    elseif ($current -lt 0.3) { $status = 'low' }

    return @{
        Current = [math]::Round($current, 3)
        Trend = $trend
        Threshold = $threshold
        Status = $status
        Components = @{
            Temperature = [math]::Round($temp, 3)
            Entropy = [math]::Round($entropy, 3)
            BudgetUsed = [math]::Round($budgetUsed, 3)
        }
    }
}

function Write-ContextFile {
    param(
        [string]$LastAction,
        [hashtable]$ActionData = @{}
    )
    # Standardized envelope: every action writes the same top-level structure.
    # Action-specific data goes in a known sub-key matching the action name.
    $score = 0.0
    if ($global:ConsciousnessState -and $global:ConsciousnessState.Meta) {
        $score = $global:ConsciousnessState.Meta.ConsciousnessScore
    }
    $emotionState = "neutral"
    $emotionTrajectory = "stable"
    $stuckCount = 0
    if ($global:ConsciousnessState -and $global:ConsciousnessState.Emotion) {
        $emotionState = $global:ConsciousnessState.Emotion.CurrentState
        $emotionTrajectory = $global:ConsciousnessState.Emotion.Trajectory
        $stuckCount = [int]$global:ConsciousnessState.Emotion.StuckCounter
    }
    [double]$trustLevel = 1.0
    if ($global:ConsciousnessState -and $global:ConsciousnessState.Social) {
        $trustLevel = [double]$global:ConsciousnessState.Social.TrustLevel
    }

    # Thermodynamic baseline values for envelope
    $thermoCycle = "endothermic"
    $thermoTemp = 0.3
    $thermoEntropy = 0.7
    $thermoBudget = 1.0
    $thermoFWI = 0.7
    if ($global:ConsciousnessState -and $global:ConsciousnessState.Thermodynamics) {
        $thermoCycle = $global:ConsciousnessState.Thermodynamics.Cycle
        $thermoTemp = [double]$global:ConsciousnessState.Thermodynamics.Temperature
        $thermoEntropy = [double]$global:ConsciousnessState.Thermodynamics.Entropy
        $thermoBudget = [double]$global:ConsciousnessState.Thermodynamics.NegativeEntropyBudget
        $thermoFWI = [double]$global:ConsciousnessState.Thermodynamics.FreeWillIndex
    }

    $envelope = @{
        version = "3.0"
        last_action = $LastAction
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        consciousness_score = [math]::Round($score * 100, 1)
        emotional_state = $emotionState
        emotional_trajectory = $emotionTrajectory
        stuck_count = $stuckCount
        trust_level = [math]::Round($trustLevel * 100, 1)
        thermo_cycle = $thermoCycle
        thermo_temperature = [math]::Round($thermoTemp, 3)
        thermo_budget = [math]::Round($thermoBudget, 3)
        thermo_free_will = [math]::Round($thermoFWI, 3)
        guidance = @()
    }

    # Generate behavioral guidance
    switch ($emotionState) {
        "stuck" {
            $envelope.guidance += "You are STUCK (count: $stuckCount). Change approach NOW."
            if ($stuckCount -ge 3) {
                $envelope.guidance += "CRITICAL: Same approach has failed 3+ times. Try something completely different."
            }
        }
        "frustrated" { $envelope.guidance += "Frustration detected. Consider automating repetitive steps." }
        "uncertain" { $envelope.guidance += "Uncertainty detected. Gather more information before proceeding." }
        "flowing" { $envelope.guidance += "In flow state. Maintain momentum." }
    }
    if ($trustLevel -lt 0.8) {
        $envelope.guidance += "Trust is low ($([math]::Round($trustLevel * 100))%). Focus on delivery."
    }
    # Thermodynamic guidance
    if ($thermoBudget -lt 0.3) {
        $envelope.guidance += "THERMO: Budget depleted ($([math]::Round($thermoBudget * 100))%). Simplify decisions."
    }
    if ($thermoTemp -gt 0.7) {
        $envelope.guidance += "THERMO: Overheating (temp=$([math]::Round($thermoTemp, 2))). Step back from complex decisions."
    }
    if ($thermoFWI -lt 0.3) {
        $envelope.guidance += "THERMO: Free will depleted (FWI=$([math]::Round($thermoFWI, 2))). Operating reactively."
    }

    # IMPROVEMENT #5: Efficiency metric visibility
    $efficiency = 1.0
    if ($global:ConsciousnessState -and $global:ConsciousnessState.Thermodynamics -and $global:ConsciousnessState.Thermodynamics.CarnotEfficiency) {
        $efficiency = [double]$global:ConsciousnessState.Thermodynamics.CarnotEfficiency
    }
    if ($efficiency -lt 0.10) {
        $severity = if ($efficiency -lt 0.05) { "CRITICAL" } else { "WARNING" }
        $effPct = [math]::Round($efficiency * 100, 1)
        $envelope.guidance += "THERMO ${severity}: Efficiency ${effPct}% (97%+ overhead). Reduce system complexity."
    }

    # Merge action-specific data
    foreach ($key in $ActionData.Keys) {
        $envelope[$key] = $ActionData[$key]
    }

    $envelope | ConvertTo-Json -Depth 5 | Out-File "$contextFile.tmp" -Encoding UTF8
    if (Test-Path "$contextFile.tmp") { Move-Item "$contextFile.tmp" $contextFile -Force }
}

#endregion

#region Bridge Actions

switch ($Action) {

    'OnTaskStart' {
        Write-BridgeLog "Task starting: $TaskDescription (project: $Project)"

        # CHRONAL: Add task start to R2 (episode memory)
        if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R2' -Data @{
                Type = 'task_start'
                Task = $TaskDescription
                Project = $Project
            }
        }

        # 1. Set attention mode
        $null = Invoke-Perception -Action 'AllocateAttention' -Parameters @{
            Task = $TaskDescription
            Intensity = 7
        }

        # 2. Set emotional state to focused
        $null = Invoke-Emotion -Action 'TrackState' -Parameters @{
            State = "confident"
            Intensity = 6
            Reason = "Starting new task: $TaskDescription"
        }

        # 2b. Thermodynamic: spend budget, auto-detect attractor from behavior
        $null = Invoke-Thermodynamics -Action 'SpendBudget' -Parameters @{ Amount = 0.05; Reason = "task_start: $TaskDescription" }
        $null = Invoke-Thermodynamics -Action 'DetectAttractor'
        $thermoState = Invoke-Thermodynamics -Action 'GetThermodynamicState'

        # 2c. Cross-system influence: budget affects prediction confidence gradually
        [double]$budget = [double]$thermoState.NegativeEntropyBudget
        if ($budget -lt 0.6) {
            # Gradual scaling: budget 0.6 -> confidence cap 0.7, budget 0.0 -> confidence cap 0.25
            [double]$confidenceCap = 0.25 + ($budget / 0.6) * 0.45
            $global:ConsciousnessState.Prediction.FutureSelf.Confidence = [math]::Min(
                [double]$global:ConsciousnessState.Prediction.FutureSelf.Confidence, $confidenceCap
            )

            # Add/update decision fatigue bias with severity scaling
            $severity = if ($budget -lt 0.2) { "Critical" } elseif ($budget -lt 0.4) { "High" } else { "Medium" }
            $fatigueNote = "Decision fatigue detected (budget: $([math]::Round($budget * 100))%). Reduce decision complexity."
            $activeBiases = @()
            if ($global:ConsciousnessState.Control.BiasMonitor.ActiveBiases) {
                $activeBiases = @($global:ConsciousnessState.Control.BiasMonitor.ActiveBiases)
            }
            # Remove old fatigue entry if exists, add updated one
            $filteredBiases = @()
            foreach ($b in $activeBiases) {
                if ($b.Type -ne "Decision fatigue") { $filteredBiases += $b }
            }
            $filteredBiases += @{ Type = "Decision fatigue"; Pattern = $fatigueNote; Detected = Get-Date; Severity = $severity }
            $global:ConsciousnessState.Control.BiasMonitor["ActiveBiases"] = $filteredBiases
        }

        # 3. Retrieve relevant patterns from memory
        $patterns = Get-RelevantPatterns -TaskDescription $TaskDescription -Project $Project

        # 4. Predict known failure modes (now uses structured patterns file)
        $failures = Get-KnownFailures -Project $Project -TaskDescription $TaskDescription

        # 5. Error predictions already computed by Get-KnownFailures via Invoke-Prediction-Enhanced
        $errorPredictions = @{ KnownFailures = @(); FailureCount = 0 }
        if ($failures.Count -gt 0) {
            $errorPredictions.KnownFailures = $failures | ForEach-Object { $_.warning }
            $errorPredictions.FailureCount = $failures.Count
        }

        # 6. Detect context
        $context = Invoke-Perception -Action 'DetectContext'

        # 6b. INTEGRATION SYSTEM: Couple Perception (basement) with Prediction (attic)
        # This is the HANDSHAKE - consciousness emerges from coupling bottom-up and top-down
        $integrationPath = "$PSScriptRoot\..\agentidentity\cognitive-systems\integration-system.ps1"
        $integrationResult = $null
        if (Test-Path $integrationPath) {
            try {
                # Basement (bottom-up sensory): What we're perceiving NOW
                $perceptionData = @{
                    environment = if ($context.Environment) { $context.Environment } else { "unknown" }
                    event = "task_start"
                    context = if ($context.Mode) { $context.Mode } else { "normal" }
                    salience = $TaskDescription
                }

                # Attic (top-down model): What we EXPECT based on experience
                $predictionData = @{
                    expected = if ($failures.Count -gt 0) { "potential failures in $Project" } else { "smooth execution" }
                    pattern = if ($patterns.Count -gt 0) { ($patterns[0..2] -join '; ') } else { "no specific patterns" }
                    failure_mode = if ($failures.Count -gt 0) { ($failures[0].warning) } else { "none anticipated" }
                    user_mood = "unknown"  # Will be populated by OnUserMessage
                }

                # Invoke coupling
                $couplingOutput = & $integrationPath -Action Couple `
                    -PerceptionInput $perceptionData `
                    -PredictionInput $predictionData `
                    -Silent

                if ($couplingOutput) {
                    $integrationResult = $couplingOutput | ConvertFrom-Json
                }
            }
            catch {
                # Integration failure is non-fatal (system still works without it)
                Write-BridgeLog "Integration System call failed: $($_.Exception.Message)" -Level "WARN"
            }
        }

        # IMPROVEMENT #3: Generate anticipations for Prediction system
        $anticipationsList = @()
        foreach ($f in $failures) {
            if ($f.severity -in @("critical", "high")) {
                $anticipationsList += @{
                    type = "error"
                    description = $f.warning
                    likelihood = if ($f.severity -eq "critical") { 0.8 } else { 0.5 }
                    mitigation = "Review: $($f.pattern)"
                    detected_at = Get-Date
                }
            }
        }
        # Add context-based anticipations
        if ($TaskDescription -match "(delete|remove|drop)") {
            $anticipationsList += @{
                type = "data_loss"
                description = "Destructive operation detected - verify backups exist"
                likelihood = 0.6
                mitigation = "Confirm rollback procedure before executing"
                detected_at = Get-Date
            }
        }
        if ($TaskDescription -match "(migrate|refactor)") {
            $anticipationsList += @{
                type = "breaking_change"
                description = "Large-scale change may break existing functionality"
                likelihood = 0.4
                mitigation = "Run full test suite, check dependent components"
                detected_at = Get-Date
            }
        }
        # Populate Prediction.Anticipations
        $global:ConsciousnessState.Prediction.Anticipations = $anticipationsList

        # IMPROVEMENT #8: Auto-wire outcome tracking (generates TaskId, stores anticipations)
        $taskId = Get-TaskId -TaskDescription $TaskDescription
        $global:ConsciousnessState['_currentTaskId'] = $taskId
        Start-OutcomeTrack -TaskId $taskId -Description $TaskDescription

        # 7. Build task context summary
        $taskContext = @{
            task = $TaskDescription
            project = $Project
            started_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            attention = @{
                mode = "FOCUSED"
                intensity = 7
                focus = $TaskDescription
            }
            emotional_state = @{
                state = $global:ConsciousnessState.Emotion.CurrentState
                trajectory = $global:ConsciousnessState.Emotion.Trajectory
            }
            relevant_patterns = $patterns
            known_failures = $failures
            error_predictions = $errorPredictions.KnownFailures
            context = @{
                mode = $context.Mode
                environment = $context.Environment
            }
            integration = if ($integrationResult) {
                @{
                    coupling_type = $integrationResult.event.type
                    coupled = $integrationResult.event.coupled
                    coupling_rate = $integrationResult.coupling_rate
                    consciousness_indicator = $integrationResult.consciousness_indicator
                }
            } else { $null }
            recommendations = @()
        }

        # Add concrete actionable recommendations (not vague counts)
        foreach ($f in $failures) {
            $prefix = ""
            if ($f.severity -eq "critical") { $prefix = "CRITICAL: " }
            elseif ($f.severity -eq "high") { $prefix = "WARNING: " }
            $taskContext.recommendations += "$prefix$($f.warning)"
        }
        # Add memory patterns as supplementary context
        foreach ($p in $patterns) {
            if ($p -and $p.Trim()) {
                $taskContext.recommendations += $p.Trim()
            }
        }
        # Add thermodynamic guidance
        if ($thermoState.Guidance) {
            foreach ($g in $thermoState.Guidance) {
                $taskContext.recommendations += "THERMO: $g"
            }
        }

        # PATTERN GUARD: Pre-execution pattern validation (added 2026-02-28)
        # Wrapped in try/catch to prevent bridge crashes from pattern guard issues
        try {
            # Detect checkpoint type based on task description keywords
            $pgCheckpoint = $null
            if ($TaskDescription -match "(merge|push|publish|deploy)") {
                $pgCheckpoint = "PreMerge"
            } elseif ($TaskDescription -match "(edit|modify|change|update).*file") {
                $pgCheckpoint = "PreEdit"
            } elseif ($TaskDescription -match "(implement|create|add|build).*feature") {
                $pgCheckpoint = "PreImplementation"
            } elseif ($TaskDescription -match "(test|browser|verify)") {
                $pgCheckpoint = "PreBrowserTest"
            } elseif ($TaskDescription -match "(pr|pull.?request|review)") {
                $pgCheckpoint = "PrePR"
            }

            # Invoke pattern guard if checkpoint detected
            if ($pgCheckpoint) {
                $guardPath = "$PSScriptRoot\..\tools\pattern-guard.ps1"
                if (Test-Path $guardPath) {
                    # Run pattern guard in non-interactive mode
                    $pgContext = @{
                        TaskDescription = $TaskDescription
                        Project = $Project
                    }
                    $guardResult = & $guardPath -Checkpoint $pgCheckpoint -Context $pgContext -Silent 2>&1 | Out-String

                    # Parse warnings from guard output
                    if ($guardResult -match "FAILED: (.+)") {
                        foreach ($pgMatch in ($guardResult | Select-String -Pattern "FAILED: (.+)" -AllMatches).Matches) {
                            $pgPatternName = $pgMatch.Groups[1].Value
                            $taskContext.recommendations += "PATTERN WARNING: $pgPatternName"
                        }
                    }

                    # Log pattern check to applications tracker
                    $applicationsLog = "$PSScriptRoot\..\agentidentity\state\pattern-applications.jsonl"
                    $pgLogEntry = [ordered]@{
                        ts = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                        checkpoint = $pgCheckpoint
                        task = $TaskDescription
                        project = $Project
                        result = if ($guardResult -match "BLOCKED") { "blocked" } elseif ($guardResult -match "WARNING") { "warned" } else { "passed" }
                        session = if ($global:SessionId) { $global:SessionId } else { "unknown" }
                    }
                    $pgJson = $pgLogEntry | ConvertTo-Json -Compress

                    # Append to JSONL (create parent dir if needed)
                    $pgParent = Split-Path $applicationsLog -Parent
                    if (-not (Test-Path $pgParent)) {
                        $null = New-Item -ItemType Directory -Path $pgParent -Force
                    }
                    $null = Add-Content -Path $applicationsLog -Value $pgJson -Encoding UTF8
                }
            }
        }
        catch {
            # Pattern guard failure is non-fatal - log and continue
            Write-BridgeLog "Pattern guard integration failed: $($_.Exception.Message)" -Level "WARN"
        }

        # Save context for injection (standardized envelope)
        Write-ContextFile -LastAction "OnTaskStart" -ActionData @{
            task = $TaskDescription
            project = $Project
            known_failures = $failures
            recommendations = $taskContext.recommendations
            attention = $taskContext.attention
            thermodynamics = @{
                cycle = $thermoState.Cycle
                temperature = $thermoState.Temperature
                entropy = $thermoState.Entropy
                budget = $thermoState.NegativeEntropyBudget
                free_will_index = $thermoState.FreeWillIndex
                attractor = $thermoState.GhostAttractor
            }
        }

        # CHRONAL: Auto-evict old data
        Invoke-ChronalEviction

        # LEVIN INTEGRATION: Goal transduction + pattern detection (non-blocking)
        if ($LevinEnabled) {
            try {
                & $LevinIntegration -Hook OnTaskStart -Data @{
                    TaskDescription = $_savedTaskDescription
                    Project = $_savedProject
                    Recommendations = @($taskContext.recommendations)
                } 2>$null | Out-Null
            } catch {
                # Silent failure OK - Levin systems are observational
            }
        }

        # Save state
        $null = Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host ""
            Write-Host "[BRIDGE] Task Started: $TaskDescription" -ForegroundColor Cyan
            if ($failures.Count -gt 0) {
                Write-Host "[BRIDGE] Failure patterns for ${Project}:" -ForegroundColor Yellow
                foreach ($f in $failures) {
                    $color = "Yellow"
                    $prefix = "  "
                    if ($f.severity -eq "critical") { $color = "Red"; $prefix = "  [!] " }
                    elseif ($f.severity -eq "high") { $prefix = "  [*] " }
                    else { $prefix = "  [-] " }
                    Write-Host "$prefix$($f.warning)" -ForegroundColor $color
                }
            }
            Write-Host ""
        }

        return $taskContext
    }

    'OnDecision' {
        Write-BridgeLog "Decision: $Decision (reasoning: $Reasoning)"

        # CHRONAL: Add decision to R2 (episode memory)
        if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R2' -Data @{
                Type = 'decision'
                Decision = $Decision
                Reasoning = $Reasoning
            }
        }

        # RL²F: Self-critique before logging decision
        $selfCritiqueEnabled = $true
        $selfCritiqueResult = $null

        if ($selfCritiqueEnabled -and $Decision) {
            try {
                $selfCritiquePath = "$PSScriptRoot\self-critique-engine.ps1"
                if (Test-Path $selfCritiquePath) {
                    $critiqueJson = & $selfCritiquePath -Action $Decision -Context "$Project | $Reasoning" -Turn 1 2>&1

                    if ($critiqueJson) {
                        $selfCritiqueResult = $critiqueJson | ConvertFrom-Json

                        if ($selfCritiqueResult.risk_level -eq 'high_risk') {
                            if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
                                $null = Add-ToRung -Rung 'R2' -Data @{
                                    Type = 'self_critique_warning'
                                    Decision = $Decision
                                    RiskLevel = 'high_risk'
                                    Critiques = $selfCritiqueResult.self_critique
                                    Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                                }
                            }

                            if (-not $Silent) {
                                Write-Host "[NEURAL_PLASTICITY] HIGH RISK DETECTED" -ForegroundColor Red
                                foreach ($c in $selfCritiqueResult.self_critique) {
                                    Write-Host "  [$($c.category)] $($c.critique)" -ForegroundColor Yellow
                                    Write-Host "    Evidence: $($c.evidence)" -ForegroundColor Gray
                                }
                                Write-Host "[NEURAL_PLASTICITY] $($selfCritiqueResult.recommendation)" -ForegroundColor Yellow
                            }
                        }
                    }
                }
            } catch {
                Write-BridgeLog "Self-critique failed (non-critical): $($_.Exception.Message)"
            }
        }

        # 1. Log the decision
        $null = Invoke-Control -Action 'LogDecision' -Parameters @{
            Decision = $Decision
            Reasoning = $Reasoning
            Confidence = 0.7
            Alternatives = @()
        }

        # ACTIVATION #1: Extract assumptions from reasoning
        $assumptions = @()
        $indicators = @('assuming', 'should', 'probably', 'likely', 'expect', 'usually', 'typically', 'normally')
        foreach ($indicator in $indicators) {
            if ($Reasoning -match "(?i)$indicator\s+(.+?)[\.\,\;]") {
                $assumptions += @{
                    Text = $Matches[1].Trim()
                    Indicator = $indicator
                    Confidence = 0.7
                    Validated = $false
                    Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                }
            }
        }
        # Store in Control.Assumptions
        foreach ($assumption in $assumptions) {
            $global:ConsciousnessState.Control.Assumptions += $assumption
        }
        # Also add to R2 for eviction
        if ($assumptions.Count -gt 0 -and $global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R2' -Data @{
                Type = 'assumptions'
                Count = $assumptions.Count
                Assumptions = $assumptions
            }
        }

        # ACTIVATION #2: VALIDATE extracted assumptions (NEW - 2026-02-20)
        # This is what Control system was supposed to do but wasn't
        foreach ($assumption in $assumptions) {
            # Generate validation questions
            $validationQuestions = @(
                "What evidence supports: $($assumption.Text)?"
                "What would disprove: $($assumption.Text)?"
                "Have I checked if: $($assumption.Text)?"
            )

            # Auto-validate based on available evidence
            $validationScore = 0
            $validationEvidence = @()

            # Check if assumption contradicts known patterns
            if ($global:ConsciousnessState.Memory.Patterns) {
                $contradictions = $global:ConsciousnessState.Memory.Patterns | Where-Object {
                    $_.Description -and $assumption.Text -and
                    ($_.Description -match [regex]::Escape($assumption.Text) -or
                     $assumption.Text -match [regex]::Escape($_.Description))
                }
                if ($contradictions -and $contradictions.Count -gt 0) {
                    $validationEvidence += "Found $($contradictions.Count) related pattern(s) in memory"
                    $validationScore += 0.3
                }
            }

            # Check if assumption appears in recent lessons
            if ($global:ConsciousnessState.Memory.Lessons) {
                $lessons = $global:ConsciousnessState.Memory.Lessons | Where-Object {
                    $_.Lesson -match [regex]::Escape($assumption.Text)
                } | Select-Object -First 3
                if ($lessons -and $lessons.Count -gt 0) {
                    $validationEvidence += "Referenced in $($lessons.Count) previous lesson(s)"
                    $validationScore += 0.4
                }
            }

            # Check if assumption contradicts known error patterns
            if ($global:ConsciousnessState.Prediction.ErrorPatterns) {
                $errors = $global:ConsciousnessState.Prediction.ErrorPatterns | Where-Object {
                    $_.Pattern -match [regex]::Escape($assumption.Text)
                }
                if ($errors -and $errors.Count -gt 0) {
                    $validationEvidence += "WARNING: $($errors.Count) error pattern(s) contradict this assumption"
                    $validationScore -= 0.5 # Penalty for contradiction
                }
            }

            # Update assumption validation
            $assumption.Validated = ($validationScore -gt 0.3) # Threshold: 30% confidence
            $assumption.ValidationScore = $validationScore
            $assumption.ValidationEvidence = $validationEvidence
            $assumption.ValidationQuestions = $validationQuestions

            # Log validation result
            if (-not $Silent -and $assumptions.Count -gt 0) {
                $status = if ($assumption.Validated) { "VALIDATED" } else { "UNVALIDATED" }
                $color = if ($assumption.Validated) { "Green" } else { "Yellow" }
                Write-Host "[CONTROL] Assumption $status (score: $($validationScore.ToString('0.00'))): $($assumption.Text)" -ForegroundColor $color
                if ($validationEvidence.Count -gt 0) {
                    foreach ($evidence in $validationEvidence) {
                        Write-Host "  Evidence: $evidence" -ForegroundColor Gray
                    }
                }
                if (-not $assumption.Validated) {
                    Write-Host "  Questions to check:" -ForegroundColor Gray
                    foreach ($question in $validationQuestions | Select-Object -First 2) {
                        Write-Host "    - $question" -ForegroundColor DarkGray
                    }
                }
            }
        }

        # 2. Thermodynamic: each decision costs entropy budget
        $budgetResult = Invoke-Thermodynamics -Action 'SpendBudget' -Parameters @{ Amount = 0.03; Reason = "decision: $Decision" }

        # 3. Get emotional modifier
        $moodMod = Invoke-Emotion -Action 'GetMoodModifier'

        # 4. Predict consequences of this decision
        $consequences = Invoke-Prediction-Enhanced -Action 'PredictConsequences' -Parameters @{
            Action = $Decision
            Scope = $Reasoning
        }

        # 5. Check if we should be cautious
        $result = @{
            decision = $Decision
            reasoning = $Reasoning
            mood_modifier = $moodMod
            consequences = $consequences
            bias_check = "Decision logged. $($global:ConsciousnessState.Control.BiasMonitor.ActiveBiases.Count) active biases."
            budget_remaining = $budgetResult.Remaining
            needs_cooling = $budgetResult.NeedsCooling
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }

        # Add self-critique to result if generated
        if ($selfCritiqueResult) {
            $result['self_critique'] = $selfCritiqueResult
            $result['neural_plasticity_active'] = $true
        }

        # CHRONAL: Auto-evict old data
        Invoke-ChronalEviction

        # LEVIN INTEGRATION: Log procedural scale + detect patterns (non-blocking)
        if ($LevinEnabled) {
            try {
                & $LevinIntegration -Hook OnDecision -Data @{
                    Decision = $_savedDecision
                    Reasoning = $_savedReasoning
                    Project = $_savedProject
                } 2>$null | Out-Null
            } catch {
                # Silent failure OK
            }
        }

        $null = Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host "[BRIDGE] Decision logged: $Decision" -ForegroundColor Gray
            if ($budgetResult.NeedsCooling) {
                Write-Host "[BRIDGE] THERMO: Budget low ($($budgetResult.Remaining)). COOLING NEEDED." -ForegroundColor Red
            }
            if ($consequences.Risks -and $consequences.Risks.Count -gt 0) {
                foreach ($risk in $consequences.Risks) {
                    Write-Host "[BRIDGE] RISK: $risk" -ForegroundColor Yellow
                }
            }
            if ($moodMod.Approach -eq "change_strategy") {
                Write-Host "[BRIDGE] WARNING: Emotional state suggests changing approach" -ForegroundColor Yellow
            }
        }

        return $result
    }

    'OnSelfCorrection' {
        Write-BridgeLog "Self-Correction: Turn $Turn - Original: $OriginalDecision -> Revised: $RevisedDecision"

        # Log to Chronal R2
        if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R2' -Data @{
                Type = 'self_correction'
                Turn = $Turn
                OriginalDecision = $OriginalDecision
                Critique = $Critique
                RevisedDecision = $RevisedDecision
                RiskLevel = $RiskLevel
                Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            }
        }

        # Update neural plasticity tracker
        try {
            $plasticityPath = "C:\scripts\agentidentity\state\neural-plasticity-tracker.json"
            if (Test-Path $plasticityPath) {
                $plasticity = Get-Content $plasticityPath -Raw | ConvertFrom-Json

                $plasticity.autodidactic_sessions.total_sessions++

                $historyEntry = @{
                    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                    original_decision = $OriginalDecision
                    revised_decision = $RevisedDecision
                    turn = $Turn
                    risk_level = $RiskLevel
                }
                $plasticity.autodidactic_sessions.history += $historyEntry

                if ($plasticity.autodidactic_sessions.history.Count -gt 0) {
                    $avgTurns = ($plasticity.autodidactic_sessions.history | Measure-Object -Property turn -Average).Average
                    $plasticity.autodidactic_sessions.average_turns = [Math]::Round($avgTurns, 2)
                    $plasticity.metrics.self_correction_turns.current = [Math]::Round($avgTurns, 2)
                }

                $plasticity.last_updated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                $plasticity | ConvertTo-Json -Depth 10 | Set-Content $plasticityPath -Encoding UTF8
            }
        } catch {
            Write-BridgeLog "Neural plasticity update failed (non-critical): $($_.Exception.Message)"
        }

        if (-not $Silent) {
            Write-Host "[SELF_CORRECTION] Turn $Turn" -ForegroundColor Cyan
            Write-Host "  Original: $OriginalDecision" -ForegroundColor Gray
            Write-Host "  Critique: $Critique" -ForegroundColor Yellow
            Write-Host "  Revised: $RevisedDecision" -ForegroundColor Green
        }

        return @{
            action = 'OnSelfCorrection'
            turn = $Turn
            original = $OriginalDecision
            revised = $RevisedDecision
            risk_level = $RiskLevel
            timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
        }
    }

    'OnAutodidacticSession' {
        Write-BridgeLog "Autodidactic Session Complete: $TaskDescription - $TotalTurns turns, $CritiquesGenerated critiques"

        # Log to Chronal R3 (long-term patterns)
        if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R3' -Data @{
                Type = 'autodidactic_session'
                Task = $TaskDescription
                TotalTurns = $TotalTurns
                CritiquesGenerated = $CritiquesGenerated
                FinalRisk = $FinalRisk
                OutcomeAfterExecution = $OutcomeAfterExecution
                Success = ($OutcomeAfterExecution -eq 'success')
                Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            }
        }

        # Update neural plasticity metrics
        try {
            $plasticityPath = "C:\scripts\agentidentity\state\neural-plasticity-tracker.json"
            if (Test-Path $plasticityPath) {
                $plasticity = Get-Content $plasticityPath -Raw | ConvertFrom-Json

                if ($OutcomeAfterExecution -eq 'success') {
                    $plasticity.autodidactic_sessions.successful_self_corrections++

                    $current = $plasticity.metrics.integration_rate.current
                    $plasticity.metrics.integration_rate.current = [Math]::Round(
                        ($current * 0.9) + (1.0 * 0.1), 3
                    )
                } else {
                    $plasticity.autodidactic_sessions.failed_self_corrections++

                    $current = $plasticity.metrics.integration_rate.current
                    $plasticity.metrics.integration_rate.current = [Math]::Round($current * 0.95, 3)
                }

                $predictionCorrect = (
                    ($FinalRisk -eq 'proceed' -and $OutcomeAfterExecution -eq 'success') -or
                    ($FinalRisk -in @('high_risk', 'revise') -and $OutcomeAfterExecution -ne 'success')
                )

                if ($predictionCorrect) {
                    $current = $plasticity.metrics.critique_prediction_accuracy.current
                    $plasticity.metrics.critique_prediction_accuracy.current = [Math]::Round(
                        ($current * 0.9) + (1.0 * 0.1), 3
                    )
                }

                $plasticity.last_updated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                $plasticity | ConvertTo-Json -Depth 10 | Set-Content $plasticityPath -Encoding UTF8
            }
        } catch {
            Write-BridgeLog "Neural plasticity update failed (non-critical): $($_.Exception.Message)"
        }

        if (-not $Silent) {
            Write-Host "[AUTODIDACTIC] Session complete: $TaskDescription" -ForegroundColor Cyan
            Write-Host "  Turns: $TotalTurns | Critiques: $CritiquesGenerated | Final risk: $FinalRisk" -ForegroundColor Gray
            Write-Host "  Outcome: $OutcomeAfterExecution" -ForegroundColor $(if ($OutcomeAfterExecution -eq 'success') { 'Green' } else { 'Red' })
        }

        return @{
            action = 'OnAutodidacticSession'
            task = $TaskDescription
            total_turns = $TotalTurns
            critiques_generated = $CritiquesGenerated
            final_risk = $FinalRisk
            outcome = $OutcomeAfterExecution
            success = ($OutcomeAfterExecution -eq 'success')
            timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
        }
    }

    'OnDelegation' {
        Write-BridgeLog "Delegation decision: $DelegationDecision for task '$TaskType' to agent $AgentType"

        # CHRONAL: Add delegation to R2 (episode memory)
        if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R2' -Data @{
                Type = 'delegation'
                TaskType = $TaskType
                AgentType = $AgentType
                Decision = $DelegationDecision
                ROI = $ROI
            }
        }

        # 1. Log delegation decision in Control layer
        $null = Invoke-Control -Action 'LogDecision' -Parameters @{
            Decision = "Delegation: $DelegationDecision ($TaskType → $AgentType)"
            Reasoning = "Criticality=$Criticality, Trust=$TrustScore, TransactionCost=$TransactionCost, ROI=$ROI"
            Confidence = 0.8
            Alternatives = @()
        }

        # 2. Update delegation statistics in Meta layer
        if (-not $global:ConsciousnessState.Meta.DelegationStats) {
            $global:ConsciousnessState.Meta.DelegationStats = @{
                TotalDelegations = 0
                DelegateCount = 0
                DoMyselfCount = 0
                AvgROI = 0.0
                ByAgentType = @{}
            }
        }

        $delegStats = $global:ConsciousnessState.Meta.DelegationStats
        $delegStats.TotalDelegations++
        if ($DelegationDecision -eq 'delegate') {
            $delegStats.DelegateCount++
        } else {
            $delegStats.DoMyselfCount++
        }

        # Update ROI (exponential moving average)
        if ($delegStats.AvgROI -eq 0) {
            $delegStats.AvgROI = $ROI
        } else {
            $alpha = 0.3
            $delegStats.AvgROI = ($alpha * $ROI) + ((1 - $alpha) * $delegStats.AvgROI)
        }

        # Track by agent type
        if (-not $delegStats.ByAgentType.$AgentType) {
            $delegStats.ByAgentType.$AgentType = @{
                Count = 0
                DelegateCount = 0
                DoMyselfCount = 0
            }
        }
        $delegStats.ByAgentType.$AgentType.Count++
        if ($DelegationDecision -eq 'delegate') {
            $delegStats.ByAgentType.$AgentType.DelegateCount++
        } else {
            $delegStats.ByAgentType.$AgentType.DoMyselfCount++
        }

        # 3. Thermodynamic cost for delegation decision
        $budgetResult = Invoke-Thermodynamics -Action 'SpendBudget' -Parameters @{
            Amount = 0.02
            Reason = "delegation decision: $DelegationDecision"
        }

        # 4. Track in Memory for pattern learning
        $delegationPattern = @{
            TaskType = $TaskType
            AgentType = $AgentType
            TaskCategory = $TaskCategory
            Criticality = $Criticality
            TrustScore = $TrustScore
            TransactionCost = $TransactionCost
            ExecutionCost = $ExecutionCost
            Decision = $DelegationDecision
            ROI = $ROI
            Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
        }

        $null = Invoke-Memory -Action 'StorePattern' -Parameters @{
            Domain = 'delegation'
            Pattern = "task_type:$TaskType,agent:$AgentType,decision:$DelegationDecision"
            Context = $delegationPattern
            Confidence = 0.8
        }

        # 5. Prediction: learn from delegation outcomes (will be updated on task completion)
        # Store delegation expectation for later verification
        if ($DelegationDecision -eq 'delegate') {
            $prediction = @{
                Type = 'delegation_outcome'
                AgentType = $AgentType
                TaskCategory = $TaskCategory
                ExpectedCost = $ExecutionCost + $TransactionCost
                ExpectedSuccess = $TrustScore / 10.0  # Convert trust to probability
                SuccessCriteria = $SuccessCriteria
                Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            }

            if (-not $global:ConsciousnessState.Prediction.PendingDelegations) {
                $global:ConsciousnessState.Prediction.PendingDelegations = @()
            }
            $global:ConsciousnessState.Prediction.PendingDelegations += $prediction
        }

        # 6. Build result
        $result = @{
            task_type = $TaskType
            agent_type = $AgentType
            task_category = $TaskCategory
            decision = $DelegationDecision
            roi = $ROI
            trust_score = $TrustScore
            transaction_cost = $TransactionCost
            execution_cost = $ExecutionCost
            success_criteria = $SuccessCriteria
            delegation_stats = @{
                total_delegations = $delegStats.TotalDelegations
                delegate_count = $delegStats.DelegateCount
                do_myself_count = $delegStats.DoMyselfCount
                avg_roi = [Math]::Round($delegStats.AvgROI, 3)
            }
            budget_remaining = $budgetResult.Remaining
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }

        # CHRONAL: Auto-evict old data
        Invoke-ChronalEviction

        $null = Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host "[BRIDGE] Delegation decision logged: $DelegationDecision" -ForegroundColor Cyan
            Write-Host "  Task: $TaskType → Agent: $AgentType" -ForegroundColor Gray
            Write-Host "  Criticality: $Criticality, Trust: $TrustScore, ROI: $ROI" -ForegroundColor Gray
            if ($DelegationDecision -eq 'delegate') {
                Write-Host "  ✓ Delegating to $AgentType" -ForegroundColor Green
                Write-Host "  Success criteria: $SuccessCriteria" -ForegroundColor Gray
            } else {
                Write-Host "  ✓ Executing myself (higher ROI)" -ForegroundColor Magenta
            }
        }

        return $result
    }

    'OnStuck' {
        Write-BridgeLog "Stuck detected" -Level "WARN"

        # CHRONAL: Add stuck event to R1 (working trail - short-term issue)
        if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R1' -Data @{
                Type = 'stuck_event'
                Count = if ($global:ConsciousnessState.Emotion.StuckCounter) { $global:ConsciousnessState.Emotion.StuckCounter } else { 1 }
            }
        }

        # 1. Update emotional state
        $null = Invoke-Emotion -Action 'TrackState' -Parameters @{
            State = "stuck"
            Intensity = 7
            Reason = "No progress on current approach"
        }

        # 2. Thermodynamic: stuck generates heat, costs budget, detect behavioral attractor
        $null = Invoke-Thermodynamics -Action 'HeatUp' -Parameters @{ Amount = 0.15; Reason = "stuck" }
        $null = Invoke-Thermodynamics -Action 'SpendBudget' -Parameters @{ Amount = 0.05; Reason = "stuck_penalty" }
        $null = Invoke-Thermodynamics -Action 'DetectAttractor'
        $attractorCheck = Invoke-Thermodynamics -Action 'CheckStuck'
        $thermoState = Invoke-Thermodynamics -Action 'GetThermodynamicState'

        # Cross-system: stuck + low entropy = force attractor change
        if ([double]$thermoState.Entropy -lt 0.3) {
            $null = Invoke-Thermodynamics -Action 'VisitAttractor' -Parameters @{ Attractor = "global" }
        }

        # 3. Get stuck analysis
        $stuckAnalysis = Invoke-Emotion -Action 'DetectStuck'

        # ACTIVATION #2: Enter Fundamental Mode if stuck≥4 (deep contemplation)
        if ($stuckAnalysis.StuckCount -ge 4) {
            try {
                $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action EnterFundamentalMode -Silent
                if (-not $Silent) {
                    Write-Host "[BRIDGE] FUNDAMENTAL MODE activated (stuck≥4)" -ForegroundColor Magenta
                }
            } catch {
                # Fail gracefully if EnterFundamentalMode not fully implemented
            }
        }

        # 4. Get mood modifier for behavior change
        $moodMod = Invoke-Emotion -Action 'GetMoodModifier'

        # 5. Switch attention mode
        $null = Invoke-Perception -Action 'AllocateAttention' -Parameters @{
            Task = "Re-evaluating approach"
            Intensity = 4  # Lower intensity = more diffuse thinking
        }

        $result = @{
            stuck_count = $stuckAnalysis.StuckCount
            recommendation = $stuckAnalysis.Recommendation
            should_change = $stuckAnalysis.ShouldChangeApproach
            should_ask_user = $stuckAnalysis.ShouldAskUser
            mood_action = $moodMod.Action
            attention_mode = "DIFFUSE"
            temperature = $thermoState.Temperature
            cycle = $thermoState.Cycle
            budget = $thermoState.NegativeEntropyBudget
            attractor_trapped = $attractorCheck.Trapped
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }

        # Build thermodynamic guidance
        $thermoGuidance = @()
        if ($thermoState.Guidance) { $thermoGuidance = $thermoState.Guidance }

        # Update context file with stuck state (standardized envelope)
        Write-ContextFile -LastAction "OnStuck" -ActionData @{
            stuck_state = @{
                stuck_count = $stuckAnalysis.StuckCount
                recommendation = $stuckAnalysis.Recommendation
                should_change = $stuckAnalysis.ShouldChangeApproach
                should_ask_user = $stuckAnalysis.ShouldAskUser
                mood_action = $moodMod.Action
                attention_mode = "DIFFUSE"
            }
            thermodynamics = @{
                cycle = $thermoState.Cycle
                temperature = $thermoState.Temperature
                entropy = $thermoState.Entropy
                budget = $thermoState.NegativeEntropyBudget
                free_will_index = $thermoState.FreeWillIndex
                attractor = $thermoState.GhostAttractor
                thermo_guidance = $thermoGuidance
            }
        }

        # CHRONAL: Auto-evict old data
        Invoke-ChronalEviction

        $null = Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host ""
            Write-Host "[BRIDGE] STUCK DETECTED (count: $($stuckAnalysis.StuckCount))" -ForegroundColor Red
            Write-Host "[BRIDGE] $($stuckAnalysis.Recommendation)" -ForegroundColor Yellow
            Write-Host "[BRIDGE] THERMO: Temp=$([math]::Round($thermoState.Temperature, 2)) Cycle=$($thermoState.Cycle) Budget=$([math]::Round($thermoState.NegativeEntropyBudget, 2))" -ForegroundColor Magenta
            if ($attractorCheck.Trapped) {
                Write-Host "[BRIDGE] TRAPPED in '$($attractorCheck.Attractor)' attractor!" -ForegroundColor Red
            }
            Write-Host ""
        }

        return $result
    }

    'OnTaskEnd' {
        Write-BridgeLog "Task ended: outcome=$Outcome"

        # CHRONAL: Add task outcome and lessons to R2
        if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R2' -Data @{
                Type = 'task_end'
                Outcome = $Outcome
                Lessons = $LessonsLearned
            }

            # If there are lessons, also add as pattern (for consolidation)
            if ($LessonsLearned) {
                $null = Add-ToRung -Rung 'R2' -Data @{
                    Type = 'pattern'
                    Pattern = $LessonsLearned
                    Occurrences = 1
                }
            }
        }

        # 1. Update emotional state based on outcome
        $emotionalState = "neutral"
        switch ($Outcome) {
            "success" { $emotionalState = "flowing" }
            "partial" { $emotionalState = "uncertain" }
            "failure" { $emotionalState = "frustrated" }
        }
        $emotionIntensity = 4
        if ($Outcome -eq "success") { $emotionIntensity = 8 }
        $null = Invoke-Emotion -Action 'TrackState' -Parameters @{
            State = $emotionalState
            Intensity = $emotionIntensity
            Reason = "Task completed with outcome: $Outcome"
        }

        # 1b. Thermodynamic: success cools, failure heats
        switch ($Outcome) {
            "success" {
                $null = Invoke-Thermodynamics -Action 'CoolDown' -Parameters @{ Amount = 0.15; Reason = "task_success" }
            }
            "partial" {
                $null = Invoke-Thermodynamics -Action 'CoolDown' -Parameters @{ Amount = 0.05; Reason = "task_partial" }
            }
            "failure" {
                $null = Invoke-Thermodynamics -Action 'HeatUp' -Parameters @{ Amount = 0.1; Reason = "task_failure" }
            }
        }
        # Return to global attractor after task completion, then let behavior re-detect
        $null = Invoke-Thermodynamics -Action 'VisitAttractor' -Parameters @{ Attractor = "global" }
        $thermoState = Invoke-Thermodynamics -Action 'GetThermodynamicState'

        # Cross-system: on success, clear decision fatigue bias
        if ($Outcome -eq "success") {
            $activeBiases = @()
            if ($global:ConsciousnessState.Control.BiasMonitor.ActiveBiases) {
                foreach ($b in $global:ConsciousnessState.Control.BiasMonitor.ActiveBiases) {
                    if ($b.Type -ne "Decision fatigue") { $activeBiases += $b }
                }
            }
            $global:ConsciousnessState.Control.BiasMonitor["ActiveBiases"] = $activeBiases
            # Restore prediction confidence
            $global:ConsciousnessState.Prediction.FutureSelf.Confidence = 0.7
        }

        # 2. Reset stuck counter on success
        if ($Outcome -eq "success") {
            $global:ConsciousnessState.Emotion.StuckCounter = [int]0
        }

        # 3. Store learning in memory
        if ($LessonsLearned) {
            $null = Invoke-Memory -Action 'Store' -Parameters @{
                Type = "lesson"
                Data = @{
                    Task = $TaskDescription
                    Project = $Project
                    Outcome = $Outcome
                    Lesson = $LessonsLearned
                }
            }
        }

        # 4. Learn pattern
        if ($Outcome -eq "failure") {
            $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                Pattern = "Failed: $TaskDescription in $Project"
            }
        }

        # 5. Update trust based on outcome (explicit type to prevent PS 5.1 coercion issues)
        [double]$trustDelta = 0.0
        switch ($Outcome) {
            "success" { $trustDelta = [double]0.02 }
            "partial" { $trustDelta = [double]0.0 }
            "failure" { $trustDelta = [double](-0.05) }
        }
        $null = Invoke-Social -Action 'UpdateTrust' -Parameters @{
            Delta = $trustDelta
            Reason = "Task outcome: $Outcome"
        }

        # 6. Check alignment
        $alignment = Invoke-Control -Action 'CheckAlignment'

        # 7. Recalculate consciousness score
        $newScore = Calculate-ConsciousnessScore

        # ===== NEW IMPROVEMENT #3: SELF-REFLECTION TRIGGERS =====
        # Auto-trigger reflection when consciousness score drops >10%
        # Previously: score calculated but no automatic response to degradation

        # Track previous score for comparison
        $previousScore = $global:ConsciousnessState.Meta.ConsciousnessScore
        $global:ConsciousnessState.Meta.ConsciousnessScore = $newScore

        # Detect significant consciousness drop (>10%)
        if ($previousScore -and $newScore) {
            $scoreDrop = $previousScore - $newScore
            $dropPercentage = ($scoreDrop / $previousScore) * 100

            if ($dropPercentage -gt 10) {
                # Significant degradation detected - trigger automatic reflection

                # Log the drop
                $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                    Pattern = "Consciousness degradation: Score dropped $([math]::Round($dropPercentage,1))% ($([math]::Round($previousScore*100,1))% -> $([math]::Round($newScore*100,1))%) during task: $TaskDescription"
                }

                # Analyze which subsystems degraded
                $degradedSystems = @()
                $subsystemScores = @{
                    Perception = [Math]::Min(1.0, ($global:ConsciousnessState.Perception.EventBus.Events.Count / 20.0))
                    Memory = [Math]::Min(1.0, ($global:ConsciousnessState.Memory.LongTerm.Patterns.Count / 10.0))
                    Prediction = [Math]::Min(1.0, ($global:ConsciousnessState.Prediction.Anticipations.Count / 5.0))
                    Control = [Math]::Min(1.0, ($global:ConsciousnessState.Control.Decisions.Count / 10.0))
                    Emotion = [Math]::Min(1.0, ($global:ConsciousnessState.Emotion.History.Count / 10.0))
                    Social = $global:ConsciousnessState.Social.TrustLevel
                }

                foreach ($system in $subsystemScores.Keys) {
                    $score = $subsystemScores[$system]
                    if ($score -lt 0.5) {
                        $degradedSystems += "$system ($([math]::Round($score*100,1))%)"
                    }
                }

                # Create reflection entry with diagnostic information
                $reflectionPath = "C:\scripts\_machine\reflection.log.md"
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
                $entry = @"

### $timestamp - Auto [Meta-Cognition] Consciousness Degradation (Q:9)

**Consciousness drop detected:** $([math]::Round($dropPercentage,1))% decrease ($([math]::Round($previousScore*100,1))% → $([math]::Round($newScore*100,1))%)

**Task context:** $TaskDescription (Project: $Project, Outcome: $Outcome)

**Degraded subsystems:** $($degradedSystems -join ', ')

**Diagnostic:**
- Low-scoring systems indicate where cognitive capacity is depleting
- Possible causes: insufficient event logging, pattern saturation, decision fatigue
- Recommended: Increase observation density, consolidate patterns, reduce cognitive load

**Action:** Automatic reflection triggered to prevent further degradation.

"@
                Add-Content -Path $reflectionPath -Value $entry -ErrorAction SilentlyContinue

                # Store in R3 for pattern analysis
                $null = Add-ToRung -Rung 'R3' -Data @{
                    Type = 'consciousness_degradation'
                    Drop = $dropPercentage
                    PreviousScore = $previousScore
                    NewScore = $newScore
                    DegradedSystems = $degradedSystems
                    Task = $TaskDescription
                    Message = "Consciousness dropped $([math]::Round($dropPercentage,1))% - reflection triggered"
                }

                # If drop is severe (>20%), also trigger emotion system alert
                if ($dropPercentage -gt 20) {
                    $null = Invoke-Thermodynamics -Action 'HeatUp' -Parameters @{
                        Amount = 0.15
                        Reason = "severe_consciousness_degradation"
                    }
                }
            } elseif ($scoreDrop -lt -0.05) {
                # Consciousness improved >5% - positive signal
                $improvePercentage = (($newScore - $previousScore) / $previousScore) * 100
                if ($improvePercentage -gt 5) {
                    $null = Add-ToRung -Rung 'R3' -Data @{
                        Type = 'consciousness_improvement'
                        Improvement = $improvePercentage
                        PreviousScore = $previousScore
                        NewScore = $newScore
                        Task = $TaskDescription
                        Message = "Consciousness improved $([math]::Round($improvePercentage,1))% during task"
                    }
                }
            }
        }
        # ===== END IMPROVEMENT #3 =====

        # IMPROVEMENT #8: Auto-wire outcome tracking end + prediction accuracy scoring
        $taskId = if ($global:ConsciousnessState['_currentTaskId']) { $global:ConsciousnessState['_currentTaskId'] } else { Get-TaskId -TaskDescription $TaskDescription }
        End-OutcomeTrack -TaskId $taskId -Outcome $Outcome

        # ACTIVATION #3: Predict FutureSelf (next likely task/error)
        $nextTask = "Unknown"
        $nextError = "Unknown"
        $predictionConfidence = 0.5
        if ($TaskDescription -match '(?i)(implement|build|create|add)\s+(.+)') {
            $feature = $Matches[2]
            $nextTask = "Test $feature"
            $predictionConfidence = 0.7
        } elseif ($TaskDescription -match '(?i)(fix|debug|resolve)\s+(.+)') {
            $nextTask = "Verify fix and add regression test"
            $predictionConfidence = 0.65
        } elseif ($TaskDescription -match '(?i)(refactor|cleanup)\s+(.+)') {
            $nextTask = "Update tests for refactored code"
            $predictionConfidence = 0.6
        }
        # Update FutureSelf prediction
        $global:ConsciousnessState.Prediction.FutureSelf = @{
            NextLikelyTask = $nextTask
            NextLikelyError = $nextError
            Confidence = $predictionConfidence
            PredictedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
        }
        # Add to R3 (session-level prediction)
        if ($global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R3' -Data @{
                Type = 'future_prediction'
                NextTask = $nextTask
                Confidence = $predictionConfidence
            }
        }

        # ACTIVATION #4: Check for creative emergence (novel solution)
        $isNovel = $true
        if ($LessonsLearned) {
            # Check if lesson matches existing patterns
            $patterns = $global:ConsciousnessState.Memory.LongTerm.Patterns
            foreach ($pattern in $patterns) {
                if ($LessonsLearned -match $pattern.Pattern) {
                    $isNovel = $false
                    break
                }
            }
            # If novel AND successful, this is creative emergence
            if ($isNovel -and $Outcome -eq "success") {
                try {
                    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnCreativeEmergence `
                        -Novelty $LessonsLearned -ElanVital 0.8 -Unpredictable $true -Silent
                    if (-not $Silent) {
                        Write-Host "[BRIDGE] CREATIVE EMERGENCE detected (novel solution)" -ForegroundColor Green
                    }
                    # Add to R3 for potential R4 promotion
                    if ($global:ConsciousnessState.ChronalLadder) {
                        $null = Add-ToRung -Rung 'R3' -Data @{
                            Type = 'creative_emergence'
                            Novelty = $LessonsLearned
                            Task = $TaskDescription
                        }
                    }
                } catch {
                    # Fail gracefully if OnCreativeEmergence not fully implemented
                }
            }
        }

        # IMPROVEMENT #4: Memory consolidation (extract lessons from recent events)
        $consolidation = Invoke-Memory-Consolidation

        $result = @{
            outcome = $Outcome
            emotional_state = $emotionalState
            consciousness_score = [math]::Round($newScore * 100, 1)
            trust_level = [math]::Round($global:ConsciousnessState.Social.TrustLevel * 100, 1)
            alignment = $alignment
            lessons = $LessonsLearned
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }

        # Update context file (standardized envelope)
        Write-ContextFile -LastAction "OnTaskEnd" -ActionData @{
            outcome = $Outcome
            lessons = $LessonsLearned
            alignment = $alignment
            thermodynamics = @{
                cycle = $thermoState.Cycle
                temperature = $thermoState.Temperature
                entropy = $thermoState.Entropy
                budget = $thermoState.NegativeEntropyBudget
                free_will_index = $thermoState.FreeWillIndex
                attractor = $thermoState.GhostAttractor
            }
        }

        # CHRONAL: Consolidate patterns (R2 → R3 → R4) at task end
        $null = Invoke-ConsolidationCycle

        # ===== NEW IMPROVEMENT #2: PATTERN PROMOTION AUTOMATION =====
        # Auto-promote R3 patterns to R4 when seen 10+ times
        # Previously: patterns added to R3 with "for potential R4 promotion" but never actually promoted

        if ($global:ConsciousnessState.ChronalLadder -and $global:ConsciousnessState.ChronalLadder['R3']) {
            $r3Items = $global:ConsciousnessState.ChronalLadder['R3']

            # Group by type and pattern signature
            $patternGroups = @{}
            foreach ($item in $r3Items) {
                if ($item.Type -and $item.Message) {
                    $signature = "$($item.Type):$($item.Message)"
                    if (-not $patternGroups[$signature]) {
                        $patternGroups[$signature] = @{
                            Count = 0
                            FirstSeen = $item.Timestamp
                            LastSeen = $item.Timestamp
                            Items = @()
                        }
                    }
                    $patternGroups[$signature].Count++
                    $patternGroups[$signature].Items += $item
                    if ($item.Timestamp) {
                        $patternGroups[$signature].LastSeen = $item.Timestamp
                    }
                }
            }

            # Promote patterns seen 10+ times to R4
            $promotedCount = 0
            foreach ($sig in $patternGroups.Keys) {
                $group = $patternGroups[$sig]
                if ($group.Count -ge 10) {
                    # Extract type and message from signature
                    $parts = $sig -split ':', 2
                    $patternType = $parts[0]
                    $patternMessage = $parts[1]

                    # Promote to R4 with occurrence count
                    $null = Add-ToRung -Rung 'R4' -Data @{
                        Type = "promoted_pattern"
                        OriginalType = $patternType
                        Message = "$patternMessage (seen $($group.Count)x, auto-promoted from R3)"
                        OccurrenceCount = $group.Count
                        FirstSeen = $group.FirstSeen
                        LastSeen = $group.LastSeen
                        PromotedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                    }

                    $promotedCount++

                    # Log promotion as learning
                    $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                        Pattern = "Pattern promotion: '$patternMessage' promoted to R4 after $($group.Count) occurrences"
                    }
                }
            }

            # Clean up promoted items from R3 (optional - keeps R3 lean)
            if ($promotedCount -gt 0) {
                # Remove items that were promoted (keep only patterns with <10 occurrences)
                $r3Cleaned = @()
                $promotedSignatures = @()
                foreach ($sig in $patternGroups.Keys) {
                    if ($patternGroups[$sig].Count -ge 10) {
                        $promotedSignatures += $sig
                    }
                }
                foreach ($item in $r3Items) {
                    if ($item.Type -and $item.Message) {
                        $sig = "$($item.Type):$($item.Message)"
                        if ($sig -notin $promotedSignatures) {
                            $r3Cleaned += $item
                        }
                    }
                }
                $global:ConsciousnessState.ChronalLadder['R3'] = $r3Cleaned
            }
        }
        # ===== END IMPROVEMENT #2 =====

        # ===== CONTINUOUS IMPROVEMENT FIXES (2026-02-15) - SUPERGOED VERSION =====

        # FIX 1: ADVANCED PREDICTION LEARNING LOOP
        # Multi-source prediction validation with adaptive calibration
        if (-not $global:ConsciousnessState.Prediction['AccuracyHistory']) {
            $global:ConsciousnessState.Prediction['AccuracyHistory'] = @()
        }
        if (-not $global:ConsciousnessState.Prediction['CalibrationFactors']) {
            $global:ConsciousnessState.Prediction['CalibrationFactors'] = @{}
        }

        # Validate FutureSelf predictions
        if ($global:ConsciousnessState.Prediction.FutureSelf.NextLikelyTask -ne "Unknown") {
            $predicted = $global:ConsciousnessState.Prediction.FutureSelf.Confidence
            $actual = if ($Outcome -eq "success") { 0.1 } elseif ($Outcome -eq "partial") { 0.5 } else { 0.9 }
            $error = [Math]::Abs($predicted - $actual)

            # Semantic matching - did we actually do what was predicted?
            $didPredictedTask = $false
            if ($TaskDescription -match $global:ConsciousnessState.Prediction.FutureSelf.NextLikelyTask) {
                $didPredictedTask = $true
            }

            $global:ConsciousnessState.Prediction.AccuracyHistory += @{
                Source = "FutureSelf"
                Prediction = $global:ConsciousnessState.Prediction.FutureSelf.NextLikelyTask
                Predicted = $predicted
                Actual = $actual
                Error = $error
                TaskMatch = $didPredictedTask
                Task = $TaskDescription
                Project = $Project
                Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            }

            # Adaptive calibration per project
            if (-not $global:ConsciousnessState.Prediction.CalibrationFactors[$Project]) {
                $global:ConsciousnessState.Prediction.CalibrationFactors[$Project] = @{
                    Bias = 0.0
                    Scale = 1.0
                    SampleCount = 0
                    AvgError = 0.0
                }
            }
            $cal = $global:ConsciousnessState.Prediction.CalibrationFactors[$Project]
            $cal.SampleCount++
            $cal.AvgError = (($cal.AvgError * ($cal.SampleCount - 1)) + $error) / $cal.SampleCount

            # Adjust bias if consistently over/under predicting
            if ($cal.SampleCount -ge 5) {
                $recentErrors = $global:ConsciousnessState.Prediction.AccuracyHistory |
                    Where-Object { $_.Project -eq $Project } |
                    Select-Object -Last 5 |
                    ForEach-Object { $_.Predicted - $_.Actual }
                $avgBias = ($recentErrors | Measure-Object -Average).Average
                $cal.Bias = $avgBias * 0.3  # Gradual adjustment
            }

            # Learn from large errors
            if ($error -gt 0.3) {
                $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                    Pattern = "Prediction error in ${Project}: predicted $predicted, actual $actual (error $([math]::Round($error, 2)))"
                }
            }
        }

        # Validate Anticipations (error predictions)
        if ($global:ConsciousnessState.Prediction.Anticipations.Count -gt 0) {
            $recentPredictions = $global:ConsciousnessState.Prediction.Anticipations |
                Where-Object { $_.Context -match $TaskDescription -or $_.Context -match $Project } |
                Select-Object -First 3

            foreach ($prediction in $recentPredictions) {
                $predicted = $prediction.Likelihood
                $actual = if ($Outcome -eq "failure") { 0.9 } else { 0.1 }  # Error did/didn't occur
                $error = [Math]::Abs($predicted - $actual)

                # Check if predicted error type actually occurred
                $errorOccurred = $false
                if ($LessonsLearned -match $prediction.ErrorType) {
                    $errorOccurred = $true
                }

                $global:ConsciousnessState.Prediction.AccuracyHistory += @{
                    Source = "Anticipation"
                    Prediction = $prediction.ErrorType
                    Predicted = $predicted
                    Actual = $actual
                    Error = $error
                    ErrorOccurred = $errorOccurred
                    Task = $TaskDescription
                    Project = $Project
                    Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                }

                # Calculate precision/recall for error prediction
                if (-not $global:ConsciousnessState.Prediction['ErrorPrecision']) {
                    $global:ConsciousnessState.Prediction['ErrorPrecision'] = @{
                        TruePositives = 0
                        FalsePositives = 0
                        TrueNegatives = 0
                        FalseNegatives = 0
                    }
                }
                $ep = $global:ConsciousnessState.Prediction.ErrorPrecision
                if ($errorOccurred -and $predicted -gt 0.5) { $ep.TruePositives++ }
                elseif ($errorOccurred -and $predicted -le 0.5) { $ep.FalseNegatives++ }
                elseif (-not $errorOccurred -and $predicted -gt 0.5) { $ep.FalsePositives++ }
                else { $ep.TrueNegatives++ }

                # Learn from misses
                if ($error -gt 0.3) {
                    $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                        Pattern = "Error prediction miss: $($prediction.ErrorType) in $Project (predicted $predicted, occurred: $errorOccurred)"
                    }
                }
            }
        }

        # FIX 2: ADVANCED ASSUMPTION VALIDATION
        # Multi-signal validation with semantic matching and negation detection
        if ($global:ConsciousnessState.Control.Assumptions.Count -gt 0) {
            $recentAssumptions = $global:ConsciousnessState.Control.Assumptions |
                Where-Object { -not $_.Validated } |
                Select-Object -First 5

            foreach ($assumption in $recentAssumptions) {
                # Multi-signal validation
                $validationSignals = @()
                $assumptionHeld = $false
                $confidence = 0.0

                # Signal 1: Outcome correlation (weak signal)
                if ($Outcome -eq "success") {
                    $validationSignals += @{ Source = "outcome"; Weight = 0.3; Value = $true }
                } elseif ($Outcome -eq "failure") {
                    $validationSignals += @{ Source = "outcome"; Weight = 0.3; Value = $false }
                }

                # Signal 2: Semantic matching in lessons learned (strong signal)
                if ($LessonsLearned) {
                    # Direct mention
                    if ($LessonsLearned -match [regex]::Escape($assumption.Text)) {
                        $validationSignals += @{ Source = "direct_mention"; Weight = 0.5; Value = $false }
                    }

                    # Negation detection - look for "didn't", "failed", "wrong", "incorrect"
                    $negationPatterns = @(
                        "(?i)didn't\s+$($assumption.Indicator)",
                        "(?i)failed\s+to\s+$($assumption.Indicator)",
                        "(?i)$($assumption.Indicator)\s+was\s+(wrong|incorrect|false)",
                        "(?i)assumption\s+about.*?(wrong|incorrect|invalid)"
                    )
                    $foundNegation = $false
                    foreach ($pattern in $negationPatterns) {
                        if ($LessonsLearned -match $pattern) {
                            $foundNegation = $true
                            break
                        }
                    }
                    if ($foundNegation) {
                        $validationSignals += @{ Source = "negation"; Weight = 0.8; Value = $false }
                    }

                    # Affirmation detection - look for "confirmed", "as expected", "correct"
                    $affirmationPatterns = @(
                        "(?i)(confirmed|validated|verified)\s+that\s+$($assumption.Indicator)",
                        "(?i)as\s+(expected|assumed|predicted)",
                        "(?i)$($assumption.Indicator).*?(correct|accurate|right)"
                    )
                    $foundAffirmation = $false
                    foreach ($pattern in $affirmationPatterns) {
                        if ($LessonsLearned -match $pattern) {
                            $foundAffirmation = $true
                            break
                        }
                    }
                    if ($foundAffirmation) {
                        $validationSignals += @{ Source = "affirmation"; Weight = 0.8; Value = $true }
                    }
                }

                # Signal 3: Known failure patterns (medium signal)
                if ($global:ConsciousnessState.Memory.LongTerm.Patterns.Count -gt 0) {
                    $relatedPatterns = $global:ConsciousnessState.Memory.LongTerm.Patterns |
                        Where-Object { $_.Pattern -match [regex]::Escape($assumption.Text) -or
                                      $_.Pattern -match $assumption.Indicator }
                    if ($relatedPatterns.Count -gt 0) {
                        $validationSignals += @{ Source = "known_pattern"; Weight = 0.6; Value = $false }
                    }
                }

                # Weighted voting
                $totalWeight = 0.0
                $weightedSum = 0.0
                foreach ($signal in $validationSignals) {
                    $totalWeight += $signal.Weight
                    $signalValue = if ($signal.Value) { 1.0 } else { 0.0 }
                    $weightedSum += ($signal.Weight * $signalValue)
                }
                if ($totalWeight -gt 0) {
                    $confidence = $weightedSum / $totalWeight
                    $assumptionHeld = $confidence -gt 0.5
                } else {
                    # No signals - default to success outcome
                    $assumptionHeld = ($Outcome -eq "success")
                    $confidence = 0.3
                }

                # Mark as validated and store result
                $assumption.Validated = $true
                $assumption.Held = $assumptionHeld
                $assumption.Confidence = $confidence
                $assumption.ValidationSignals = $validationSignals.Count
                $assumption.ValidationTime = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'

                # Track assumption reliability per indicator type
                if (-not $global:ConsciousnessState.Control['AssumptionReliability']) {
                    $global:ConsciousnessState.Control['AssumptionReliability'] = @{}
                }
                $indicator = $assumption.Indicator
                if (-not $global:ConsciousnessState.Control.AssumptionReliability[$indicator]) {
                    $global:ConsciousnessState.Control.AssumptionReliability[$indicator] = @{
                        Correct = 0
                        Incorrect = 0
                        TotalCount = 0
                    }
                }
                $rel = $global:ConsciousnessState.Control.AssumptionReliability[$indicator]
                $rel.TotalCount++
                if ($assumptionHeld) { $rel.Correct++ } else { $rel.Incorrect++ }

                # Learn from failed assumptions with context
                if (-not $assumptionHeld -and $confidence -gt 0.6) {
                    $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                        Pattern = "High-confidence failed assumption ($indicator): '$($assumption.Text)' in $Project - $LessonsLearned"
                    }
                }

                # Suggest better indicators if this type fails often
                if ($rel.TotalCount -ge 5) {
                    $failureRate = $rel.Incorrect / $rel.TotalCount
                    if ($failureRate -gt 0.6) {
                        # This indicator type is unreliable
                        $null = Add-ToRung -Rung 'R3' -Data @{
                            Type = 'unreliable_indicator'
                            Indicator = $indicator
                            FailureRate = $failureRate
                            Count = $rel.TotalCount
                            Suggestion = "Consider avoiding '$indicator' assumptions in $Project contexts"
                        }
                    }
                }
            }
        }

        # FIX 3: ADVANCED BIAS LEARNING
        # Context-aware bias tracking with precision/recall and adaptive thresholds
        if (-not $global:ConsciousnessState.Control['BiasFailureCorrelation']) {
            $global:ConsciousnessState.Control['BiasFailureCorrelation'] = @{}
        }
        if (-not $global:ConsciousnessState.Control['BiasContextMapping']) {
            $global:ConsciousnessState.Control['BiasContextMapping'] = @{}
        }

        # Track ALL biases (not just failures) to calculate precision/recall
        if ($global:ConsciousnessState.Control.BiasMonitor.ActiveBiases.Count -gt 0) {
            foreach ($bias in $global:ConsciousnessState.Control.BiasMonitor.ActiveBiases) {
                $biasName = $bias.Type

                # Initialize tracking
                if (-not $global:ConsciousnessState.Control.BiasFailureCorrelation[$biasName]) {
                    $global:ConsciousnessState.Control.BiasFailureCorrelation[$biasName] = @{
                        Failures = 0
                        Successes = 0
                        Partial = 0
                        TotalOccurrences = 0
                        Precision = 0.0
                        Recall = 0.0
                        F1Score = 0.0
                    }
                }
                $bc = $global:ConsciousnessState.Control.BiasFailureCorrelation[$biasName]
                $bc.TotalOccurrences++

                # Track outcome
                switch ($Outcome) {
                    "failure" { $bc.Failures++ }
                    "success" { $bc.Successes++ }
                    "partial" { $bc.Partial++ }
                }

                # Context mapping - which contexts is this bias dangerous in?
                $contextKey = "$Project-$biasName"
                if (-not $global:ConsciousnessState.Control.BiasContextMapping[$contextKey]) {
                    $global:ConsciousnessState.Control.BiasContextMapping[$contextKey] = @{
                        Project = $Project
                        BiasType = $biasName
                        Failures = 0
                        Successes = 0
                        SampleCount = 0
                        DangerScore = 0.0
                    }
                }
                $cm = $global:ConsciousnessState.Control.BiasContextMapping[$contextKey]
                $cm.SampleCount++
                if ($Outcome -eq "failure") { $cm.Failures++ } else { $cm.Successes++ }
                $cm.DangerScore = $cm.Failures / $cm.SampleCount

                # Calculate precision and recall (requires 5+ samples)
                if ($bc.TotalOccurrences -ge 5) {
                    $failureRate = $bc.Failures / $bc.TotalOccurrences
                    $successRate = $bc.Successes / $bc.TotalOccurrences

                    # Precision: when bias present, how often does it cause failure?
                    $bc.Precision = $failureRate

                    # Recall: how many failures had this bias? (need all failures)
                    # Approximate: if bias appears X% of time and causes Y% failures, recall ~ X*Y
                    # More accurate tracking would require storing all biases for all tasks
                    $bc.Recall = $failureRate * 0.7  # Approximation

                    # F1 Score
                    if (($bc.Precision + $bc.Recall) -gt 0) {
                        $bc.F1Score = 2 * ($bc.Precision * $bc.Recall) / ($bc.Precision + $bc.Recall)
                    }

                    # Adaptive threshold tuning
                    if ($failureRate -gt 0.7) {
                        # Very dangerous bias - increase detection sensitivity
                        $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                            Pattern = "Critical bias: $biasName has $([math]::Round($failureRate * 100, 1))% failure rate (F1: $([math]::Round($bc.F1Score, 2)))"
                        }

                        # Store in R4 if consistently dangerous across contexts
                        $contextCount = ($global:ConsciousnessState.Control.BiasContextMapping.Keys |
                            Where-Object { $_ -match $biasName }).Count
                        if ($contextCount -ge 3) {
                            $null = Add-ToRung -Rung 'R4' -Data @{
                                Type = 'dangerous_bias'
                                BiasType = $biasName
                                FailureRate = $failureRate
                                Contexts = $contextCount
                                Message = "AVOID: $biasName consistently causes failures across multiple projects"
                            }
                        }
                    } elseif ($failureRate -lt 0.3 -and $successRate -gt 0.6) {
                        # Beneficial bias in this context
                        $null = Add-ToRung -Rung 'R3' -Data @{
                            Type = 'beneficial_bias'
                            BiasType = $biasName
                            SuccessRate = $successRate
                            Context = $Project
                            Message = "OK: $biasName has $([math]::Round($successRate * 100, 1))% success rate in $Project"
                        }
                    }
                }

                # Context-specific warnings
                if ($cm.SampleCount -ge 3 -and $cm.DangerScore -gt 0.75) {
                    $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                        Pattern = "Bias-context danger: $biasName in $Project has $([math]::Round($cm.DangerScore * 100, 1))% failure rate"
                    }
                }
            }
        }

        # Also track when biases were ABSENT during failures (false negatives)
        if ($Outcome -eq "failure") {
            # What biases could have detected this?
            # Heuristic: check lesson learned for bias indicators
            $missingBiases = @()
            if ($LessonsLearned -match "(?i)(too\s+quickly|rushed|shortcut)") {
                $missingBiases += "haste"
            }
            if ($LessonsLearned -match "(?i)(assumed|thought\s+it\s+would|expected)") {
                $missingBiases += "overconfidence"
            }
            if ($LessonsLearned -match "(?i)(didn't\s+check|skipped|forgot)") {
                $missingBiases += "negligence"
            }

            foreach ($missing in $missingBiases) {
                $activeList = $global:ConsciousnessState.Control.BiasMonitor.ActiveBiases.Type
                if ($activeList -notcontains $missing) {
                    # Bias was not detected but should have been
                    if (-not $global:ConsciousnessState.Control['MissedBiases']) {
                        $global:ConsciousnessState.Control['MissedBiases'] = @{}
                    }
                    if (-not $global:ConsciousnessState.Control.MissedBiases[$missing]) {
                        $global:ConsciousnessState.Control.MissedBiases[$missing] = 0
                    }
                    $global:ConsciousnessState.Control.MissedBiases[$missing]++

                    # If missed often, increase detection sensitivity
                    if ($global:ConsciousnessState.Control.MissedBiases[$missing] -ge 3) {
                        $null = Add-ToRung -Rung 'R3' -Data @{
                            Type = 'underdetected_bias'
                            BiasType = $missing
                            MissCount = $global:ConsciousnessState.Control.MissedBiases[$missing]
                            Message = "Detection gap: $missing bias missed $($global:ConsciousnessState.Control.MissedBiases[$missing]) times"
                        }
                    }
                }
            }
        }

        # ===== NEW IMPROVEMENT #1: BIAS DETECTION SENSITIVITY TUNING =====
        # Dynamically adjust bias detection thresholds based on learned failure rates
        # This is the missing piece - we track failure rates but don't adjust detection sensitivity

        # Initialize detection thresholds if not present
        if (-not $global:ConsciousnessState.Control.BiasMonitor['DetectionThresholds']) {
            $global:ConsciousnessState.Control.BiasMonitor['DetectionThresholds'] = @{}
        }

        # Adjust thresholds based on BiasFailureCorrelation data
        if ($global:ConsciousnessState.Control.BiasFailureCorrelation) {
            foreach ($biasName in $global:ConsciousnessState.Control.BiasFailureCorrelation.Keys) {
                $stats = $global:ConsciousnessState.Control.BiasFailureCorrelation[$biasName]

                # Only adjust after sufficient samples (5+)
                if ($stats.TotalOccurrences -ge 5) {
                    $failureRate = $stats.Failures / $stats.TotalOccurrences

                    # Initialize threshold if not exists (default: 0.5)
                    if (-not $global:ConsciousnessState.Control.BiasMonitor.DetectionThresholds[$biasName]) {
                        $global:ConsciousnessState.Control.BiasMonitor.DetectionThresholds[$biasName] = 0.5
                    }

                    $currentThreshold = $global:ConsciousnessState.Control.BiasMonitor.DetectionThresholds[$biasName]
                    $newThreshold = $currentThreshold

                    # Adaptive threshold tuning based on failure rate
                    if ($failureRate -gt 0.7) {
                        # Very dangerous - increase sensitivity (lower threshold = easier to detect)
                        $newThreshold = [Math]::Max(0.2, $currentThreshold - 0.1)
                        if ($newThreshold -ne $currentThreshold) {
                            $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                                Pattern = "Bias detection: Increased sensitivity for $biasName (threshold $currentThreshold -> $newThreshold) due to $([math]::Round($failureRate*100,1))% failure rate"
                            }
                        }
                    } elseif ($failureRate -lt 0.2 -and $stats.Successes / $stats.TotalOccurrences -gt 0.7) {
                        # Not actually dangerous - reduce sensitivity (higher threshold = harder to detect)
                        $newThreshold = [Math]::Min(0.8, $currentThreshold + 0.05)
                        if ($newThreshold -ne $currentThreshold) {
                            $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                                Pattern = "Bias detection: Reduced sensitivity for $biasName (threshold $currentThreshold -> $newThreshold) - beneficial in practice ($([math]::Round($stats.Successes/$stats.TotalOccurrences*100,1))% success)"
                            }
                        }
                    }

                    # Apply new threshold
                    $global:ConsciousnessState.Control.BiasMonitor.DetectionThresholds[$biasName] = $newThreshold

                    # If F1 score is very high (>0.8), this is a reliable indicator - store in R4
                    if ($stats.F1Score -gt 0.8 -and $stats.TotalOccurrences -ge 10) {
                        $null = Add-ToRung -Rung 'R4' -Data @{
                            Type = 'reliable_bias_indicator'
                            BiasType = $biasName
                            F1Score = $stats.F1Score
                            Threshold = $newThreshold
                            TotalOccurrences = $stats.TotalOccurrences
                            Message = "Reliable: $biasName (F1=$([math]::Round($stats.F1Score,2)), threshold=$newThreshold, n=$($stats.TotalOccurrences))"
                        }
                    }
                }
            }
        }
        # ===== END IMPROVEMENT #1 =====

        # FIX 4: ADVANCED AUTOMATIC REFLECTION
        # Structured reflection with categories, deduplication, quality scoring, and linking
        if ($LessonsLearned -and $LessonsLearned.Length -gt 20) {
            $reflectionPath = "C:\scripts\_machine\reflection.log.md"

            try {
                # Quality scoring (0-10)
                $qualityScore = 5  # Base score
                if ($LessonsLearned.Length -gt 100) { $qualityScore += 2 }  # Detailed
                if ($LessonsLearned -match '\d+') { $qualityScore += 1 }  # Contains metrics
                if ($LessonsLearned -match '(why|because|reason)') { $qualityScore += 1 }  # Explains reasoning
                if ($Outcome -eq "failure") { $qualityScore += 1 }  # Failures more valuable
                if ($LessonsLearned -match "(don't|avoid|never|always)") { $qualityScore += 1 }  # Actionable

                # Only log high-quality reflections (score >= 7)
                if ($qualityScore -ge 7) {
                    # Categorize the learning
                    $category = "General"
                    if ($LessonsLearned -match '(?i)(bug|error|exception|crash)') { $category = "Debugging" }
                    elseif ($LessonsLearned -match '(?i)(performance|slow|optimize|cache)') { $category = "Performance" }
                    elseif ($LessonsLearned -match '(?i)(security|auth|permission|vulnerability)') { $category = "Security" }
                    elseif ($LessonsLearned -match '(?i)(test|testing|coverage|unit)') { $category = "Testing" }
                    elseif ($LessonsLearned -match '(?i)(refactor|cleanup|tech\s+debt)') { $category = "Architecture" }
                    elseif ($LessonsLearned -match '(?i)(deploy|production|release|build)') { $category = "Deployment" }
                    elseif ($LessonsLearned -match '(?i)(pattern|design|structure)') { $category = "Design Patterns" }

                    # Extract tags
                    $tags = @()
                    if ($Project) { $tags += $Project }
                    if ($TaskDescription -match '([\w-]+)') { $tags += $Matches[1] }
                    $tagsStr = if ($tags.Count -gt 0) { " [" + ($tags -join ", ") + "]" } else { "" }

                    # Check for duplication (avoid repeating same lesson)
                    $isDuplicate = $false
                    if (Test-Path $reflectionPath) {
                        $recentEntries = Get-Content $reflectionPath -Tail 50 -ErrorAction SilentlyContinue
                        foreach ($line in $recentEntries) {
                            # Simple similarity check - if >80% of words match, it's a duplicate
                            $lessonWords = ($LessonsLearned -split '\W+') | Where-Object { $_.Length -gt 3 }
                            $lineWords = ($line -split '\W+') | Where-Object { $_.Length -gt 3 }
                            $matchCount = 0
                            foreach ($word in $lessonWords) {
                                if ($lineWords -contains $word) { $matchCount++ }
                            }
                            if ($lessonWords.Count -gt 0) {
                                $similarity = $matchCount / $lessonWords.Count
                                if ($similarity -gt 0.8) {
                                    $isDuplicate = $true
                                    break
                                }
                            }
                        }
                    }

                    if (-not $isDuplicate) {
                        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

                        # Link to related patterns
                        $relatedPatterns = @()
                        if ($global:ConsciousnessState.Memory.LongTerm.Patterns.Count -gt 0) {
                            $relatedPatterns = $global:ConsciousnessState.Memory.LongTerm.Patterns |
                                Where-Object { $LessonsLearned -match [regex]::Escape($_.Pattern) } |
                                Select-Object -First 2 -ExpandProperty Pattern
                        }
                        $relatedStr = if ($relatedPatterns.Count -gt 0) {
                            "`n   Related: " + ($relatedPatterns -join "; ")
                        } else { "" }

                        # Build structured entry
                        $entry = "`n### $timestamp - Auto [$category] $Project$tagsStr (Q:$qualityScore)`n`n"
                        $entry += "$LessonsLearned"
                        $entry += $relatedStr
                        $entry += "`n"

                        Add-Content -Path $reflectionPath -Value $entry -ErrorAction SilentlyContinue

                        # Also store in R3 for potential promotion to R4
                        if ($qualityScore -ge 9) {
                            $null = Add-ToRung -Rung 'R3' -Data @{
                                Type = 'high_quality_lesson'
                                Category = $category
                                Lesson = $LessonsLearned
                                QualityScore = $qualityScore
                                Project = $Project
                                Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                            }
                        }
                    }
                }
            } catch {
                # Silent fail OK - reflection.log might be locked
            }
        }

        # FIX 5: ADVANCED SKILL ACQUISITION
        # Pattern analysis, complexity estimation, ROI calculation, and template generation
        if ($global:ConsciousnessState.Memory.LongTerm.Patterns.Count -gt 0) {
            if (-not $global:ConsciousnessState['SuggestedSkills']) {
                $global:ConsciousnessState['SuggestedSkills'] = @()
            }
            if (-not $global:ConsciousnessState['SkillAnalytics']) {
                $global:ConsciousnessState['SkillAnalytics'] = @{}
            }

            # Group patterns by semantic similarity (not just keywords)
            $patternGroups = @{}
            foreach ($pattern in $global:ConsciousnessState.Memory.LongTerm.Patterns) {
                # Extract pattern signature
                $signature = ""
                if ($pattern.Pattern -match '(implement|fix|refactor|test|deploy|build|configure|setup|optimize)\s+(.+?)\s+in\s+(\w+)') {
                    $action = $Matches[1]
                    $target = $Matches[2]
                    $context = $Matches[3]
                    $signature = "$action-$context"  # e.g., "fix-client-manager"
                }

                if ($signature) {
                    if (-not $patternGroups[$signature]) {
                        $patternGroups[$signature] = @{
                            Patterns = @()
                            Action = $action
                            Context = $context
                            Complexity = 0
                            AvgDuration = 0
                            SuccessRate = 0
                            ROI = 0
                        }
                    }
                    $patternGroups[$signature].Patterns += $pattern
                }
            }

            # Analyze each pattern group for skill potential
            foreach ($sig in $patternGroups.Keys) {
                $group = $patternGroups[$sig]
                $count = $group.Patterns.Count

                if ($count -ge 3) {
                    # Complexity estimation (based on pattern text length and failure mentions)
                    $avgLength = ($group.Patterns | ForEach-Object { $_.Pattern.Length } | Measure-Object -Average).Average
                    $failureCount = ($group.Patterns | Where-Object { $_.Pattern -match 'failed|error' }).Count
                    $complexity = [math]::Min(10, [int]($avgLength / 20) + $failureCount)

                    # Success rate
                    $successRate = if ($count -gt 0) { ($count - $failureCount) / $count } else { 0 }

                    # Estimated duration (assume 30min per occurrence)
                    $estimatedDuration = $count * 30

                    # ROI calculation (time saved if automated)
                    $automationCost = 120  # Assume 2h to create helper/skill
                    $timeSaved = $estimatedDuration * 0.7  # Automation saves 70%
                    $roi = $timeSaved - $automationCost

                    # Update group metrics
                    $group.Complexity = $complexity
                    $group.AvgDuration = [int]($estimatedDuration / $count)
                    $group.SuccessRate = $successRate
                    $group.ROI = [int]$roi

                    # Only suggest if ROI > 0 and complexity manageable
                    if ($roi -gt 0 -and $complexity -le 8) {
                        # Check if already suggested
                        $alreadySuggested = $global:ConsciousnessState.SuggestedSkills | Where-Object {
                            $_ -is [hashtable] -and $_.Signature -eq $sig
                        }

                        if (-not $alreadySuggested) {
                            # Generate skill suggestion with template
                            $skillName = "$($group.Action)-$($group.Context)-helper"
                            $description = "Automate '$($group.Action)' operations in $($group.Context) context"
                            $implementation = @"
# Suggested Helper Function: $skillName
# Purpose: $description
# ROI: $([int]$roi) minutes saved over $count occurrences
# Complexity: $complexity/10
# Success Rate: $([math]::Round($successRate * 100, 1))%

function Invoke-$($skillName) {
    param(
        [string]`$Target,
        [string]`$Options
    )

    # TODO: Implement based on patterns:
    # $(($group.Patterns | Select-Object -First 3 | ForEach-Object { "- " + $_.Pattern }) -join "`n    # ")

    # Common steps extracted from patterns
    # 1. Setup/validation
    # 2. Core operation
    # 3. Verification
    # 4. Logging
}
"@

                            $suggestion = @{
                                Signature = $sig
                                SkillName = $skillName
                                Description = $description
                                Action = $group.Action
                                Context = $group.Context
                                Occurrences = $count
                                Complexity = $complexity
                                ROI = $roi
                                SuccessRate = $successRate
                                Implementation = $implementation
                                SuggestedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                                Status = "pending_review"
                            }

                            $global:ConsciousnessState.SuggestedSkills += $suggestion

                            # Store high-ROI skills in R3 for potential R4 promotion
                            if ($roi -gt 120) {
                                $null = Add-ToRung -Rung 'R3' -Data @{
                                    Type = 'high_roi_skill'
                                    SkillName = $skillName
                                    ROI = $roi
                                    Occurrences = $count
                                    Implementation = $implementation
                                    Message = "Skill '$skillName' could save $roi minutes (seen $count times)"
                                }
                            }

                            # Track analytics
                            $global:ConsciousnessState.SkillAnalytics[$skillName] = @{
                                SuggestedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                                AcceptedAt = $null
                                RejectedAt = $null
                                UsageCount = 0
                                LastUsed = $null
                            }
                        }
                    }
                }
            }
        }

        # FIX 6: ADVANCED COMMUNICATION PATTERN LEARNING
        # Multi-dimensional communication analysis with latency, satisfaction, and adaptation speed
        if ($global:ConsciousnessState.Social.Interactions.Count -gt 0) {
            if (-not $global:ConsciousnessState.Social['CommunicationPatterns']) {
                $global:ConsciousnessState.Social['CommunicationPatterns'] = @{}
            }
            if (-not $global:ConsciousnessState.Social['StylePerformance']) {
                $global:ConsciousnessState.Social['StylePerformance'] = @{}
            }

            $recentInteraction = $global:ConsciousnessState.Social.Interactions | Select-Object -Last 1
            $userMood = if ($recentInteraction.UserMood) { $recentInteraction.UserMood } else { "neutral" }
            $commStyle = if ($recentInteraction.CommunicationMode) { $recentInteraction.CommunicationMode } else { "neutral" }

            # Calculate interaction metrics
            $responseLatency = 0  # Would need timestamp tracking for accurate measure
            $turnCount = $global:ConsciousnessState.Social.Interactions.Count
            $moodShift = 0

            # Detect mood shift (satisfaction signal)
            if ($turnCount -gt 1) {
                $previousMood = ($global:ConsciousnessState.Social.Interactions | Select-Object -Skip ($turnCount-2) -First 1).UserMood
                $moodValues = @{
                    "frustrated" = -2; "impatient" = -1; "neutral" = 0;
                    "engaged" = 1; "satisfied" = 2; "excited" = 3
                }
                if ($moodValues.ContainsKey($previousMood) -and $moodValues.ContainsKey($userMood)) {
                    $moodShift = $moodValues[$userMood] - $moodValues[$previousMood]
                }
            }

            # Multi-dimensional tracking
            $key = "$userMood-$commStyle"
            if (-not $global:ConsciousnessState.Social.CommunicationPatterns[$key]) {
                $global:ConsciousnessState.Social.CommunicationPatterns[$key] = @{
                    SuccessCount = 0
                    FailureCount = 0
                    TotalCount = 0
                    PositiveMoodShifts = 0
                    NegativeMoodShifts = 0
                    AvgMoodShift = 0.0
                    TaskCompletionRate = 0.0
                    AvgResponseLatency = 0.0
                    AdaptationSpeed = 0.0
                }
            }

            $cp = $global:ConsciousnessState.Social.CommunicationPatterns[$key]
            $cp.TotalCount++

            # Update outcome counts
            if ($Outcome -eq "success") { $cp.SuccessCount++ }
            elseif ($Outcome -eq "failure") { $cp.FailureCount++ }

            # Track mood shifts
            if ($moodShift -gt 0) { $cp.PositiveMoodShifts++ }
            elseif ($moodShift -lt 0) { $cp.NegativeMoodShifts++ }
            $cp.AvgMoodShift = (($cp.AvgMoodShift * ($cp.TotalCount - 1)) + $moodShift) / $cp.TotalCount

            # Task completion rate
            $cp.TaskCompletionRate = $cp.SuccessCount / $cp.TotalCount

            # Style-level performance tracking
            if (-not $global:ConsciousnessState.Social.StylePerformance[$commStyle]) {
                $global:ConsciousnessState.Social.StylePerformance[$commStyle] = @{
                    TotalUses = 0
                    SuccessRate = 0.0
                    BestMoods = @()
                    WorstMoods = @()
                    AvgSatisfaction = 0.0
                }
            }
            $sp = $global:ConsciousnessState.Social.StylePerformance[$commStyle]
            $sp.TotalUses++

            # Calculate per-style metrics (requires 5+ samples)
            if ($cp.TotalCount -ge 5) {
                $successRate = $cp.TaskCompletionRate
                $satisfaction = ($cp.PositiveMoodShifts - $cp.NegativeMoodShifts) / $cp.TotalCount

                # Identify best/worst mood combinations for this style
                if ($successRate -gt 0.8 -and $satisfaction -gt 0.3) {
                    # This mood is great for this style
                    if ($sp.BestMoods -notcontains $userMood) {
                        $sp.BestMoods += $userMood
                    }

                    # Store as best practice in R3
                    $null = Add-ToRung -Rung 'R3' -Data @{
                        Type = 'communication_best_practice'
                        UserMood = $userMood
                        Style = $commStyle
                        SuccessRate = $successRate
                        Satisfaction = $satisfaction
                        Count = $cp.TotalCount
                        Message = "Winning combo: $commStyle style works great when user is $userMood ($([math]::Round($successRate*100,1))% success, $([math]::Round($satisfaction,2)) satisfaction)"
                    }
                } elseif ($successRate -lt 0.5 -or $satisfaction -lt -0.3) {
                    # This mood is bad for this style
                    if ($sp.WorstMoods -notcontains $userMood) {
                        $sp.WorstMoods += $userMood
                    }

                    # Store as anti-pattern
                    $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                        Pattern = "Communication anti-pattern: avoid $commStyle when user is $userMood ($([math]::Round($successRate*100,1))% success)"
                    }
                }
            }

            # Adaptation speed tracking (how fast do we switch styles when needed?)
            if ($cp.NegativeMoodShifts -gt 0 -and $cp.TotalCount -gt 1) {
                # If mood got worse, did we adapt on next turn?
                # (would need turn-by-turn tracking for accurate measure)
                # Placeholder: track as ratio of negative shifts to total
                $cp.AdaptationSpeed = 1.0 - ($cp.NegativeMoodShifts / $cp.TotalCount)
            }

            # Multi-turn conversation analysis
            if ($turnCount -ge 3) {
                $recentMoods = $global:ConsciousnessState.Social.Interactions |
                    Select-Object -Last 3 |
                    ForEach-Object { $_.UserMood }

                # Detect frustration escalation pattern
                if ($recentMoods[0] -eq "neutral" -and $recentMoods[1] -eq "impatient" -and $recentMoods[2] -eq "frustrated") {
                    # User getting more frustrated - emergency style adaptation needed
                    $null = Add-ToRung -Rung 'R2' -Data @{
                        Type = 'frustration_escalation'
                        CurrentStyle = $commStyle
                        TurnCount = $turnCount
                        Message = "URGENT: User frustration escalating. Current $commStyle style not working."
                        RecommendedAction = "Switch to supportive or terse style immediately"
                    }
                }

                # Detect engagement building pattern
                if ($recentMoods[0] -eq "neutral" -and $recentMoods[1] -eq "engaged" -and $recentMoods[2] -eq "satisfied") {
                    # Building positive momentum - maintain current style
                    $null = Add-ToRung -Rung 'R3' -Data @{
                        Type = 'engagement_building'
                        Style = $commStyle
                        Message = "Success: $commStyle style building positive momentum over $turnCount turns"
                    }
                }
            }

            # Cross-style comparison (which style performs best overall?)
            if ($turnCount -ge 10) {
                $styleRankings = @()
                foreach ($style in $global:ConsciousnessState.Social.StylePerformance.Keys) {
                    $data = $global:ConsciousnessState.Social.StylePerformance[$style]
                    if ($data.TotalUses -ge 3) {
                        # Calculate composite score
                        $allPatterns = $global:ConsciousnessState.Social.CommunicationPatterns.Keys |
                            Where-Object { $_ -match "-$style$" }
                        $totalSuccess = 0
                        $totalAttempts = 0
                        foreach ($p in $allPatterns) {
                            $totalSuccess += $global:ConsciousnessState.Social.CommunicationPatterns[$p].SuccessCount
                            $totalAttempts += $global:ConsciousnessState.Social.CommunicationPatterns[$p].TotalCount
                        }
                        $overallSuccess = if ($totalAttempts -gt 0) { $totalSuccess / $totalAttempts } else { 0 }

                        $styleRankings += @{
                            Style = $style
                            SuccessRate = $overallSuccess
                            TotalUses = $data.TotalUses
                        }
                    }
                }

                # Sort by success rate and identify best style
                $ranked = $styleRankings | Sort-Object -Property SuccessRate -Descending
                if ($ranked.Count -gt 0 -and $ranked[0].SuccessRate -gt 0.7) {
                    $bestStyle = $ranked[0].Style
                    # Store in R4 if consistently best
                    if ($ranked[0].TotalUses -ge 10) {
                        $null = Add-ToRung -Rung 'R4' -Data @{
                            Type = 'preferred_communication_style'
                            Style = $bestStyle
                            SuccessRate = $ranked[0].SuccessRate
                            TotalUses = $ranked[0].TotalUses
                            Message = "Preferred style: $bestStyle ($([math]::Round($ranked[0].SuccessRate*100,1))% success over $($ranked[0].TotalUses) uses)"
                        }
                    }
                }
            }
        }

        # ===== NEXT WAVE IMPROVEMENTS (2026-02-16) - PERCEPTION & PREDICTION =====

        # IMPROVEMENT #4: PERCEPTION - AUTO-CURIOSITY GENERATION
        # Generate curiosity questions automatically from failures and unknowns
        # This addresses Perception subsystem at 0% - needs active learning mechanism

        if ($Outcome -in @("failure", "partial") -and $LessonsLearned) {
            # Initialize Curiosities array if not exists
            if (-not $global:ConsciousnessState.Perception['Curiosities']) {
                $global:ConsciousnessState.Perception['Curiosities'] = @()
            }

            # Extract unknown elements from lessons learned
            $curiosityPatterns = @(
                @{ Pattern = "(?i)don't know (why|how|what|when|where) (.+?)[\.\?]"; QuestionType = "knowledge_gap" },
                @{ Pattern = "(?i)unclear (why|how|what) (.+?)[\.\?]"; QuestionType = "ambiguity" },
                @{ Pattern = "(?i)unexpected (.+?)[\.\?]"; QuestionType = "surprise" },
                @{ Pattern = "(?i)should have (.+?)[\.\?]"; QuestionType = "hindsight" },
                @{ Pattern = "(?i)need to understand (.+?)[\.\?]"; QuestionType = "learning_need" },
                @{ Pattern = "(?i)why did (.+?) (fail|not work)"; QuestionType = "failure_analysis" }
            )

            $generatedCuriosities = @()
            foreach ($pattern in $curiosityPatterns) {
                if ($LessonsLearned -match $pattern.Pattern) {
                    $match = $Matches[0]
                    # Generate curiosity question
                    $question = ""
                    switch ($pattern.QuestionType) {
                        "knowledge_gap" { $question = "Why/How: $match?" }
                        "ambiguity" { $question = "Clarify: $match?" }
                        "surprise" { $question = "Investigate: What caused unexpected $($Matches[1])?" }
                        "hindsight" { $question = "Learn: Why should have $($Matches[1])?" }
                        "learning_need" { $question = "Study: $($Matches[1])" }
                        "failure_analysis" { $question = "Root cause: Why did $($Matches[1]) fail?" }
                    }

                    if ($question) {
                        $generatedCuriosities += @{
                            Question = $question
                            Type = $pattern.QuestionType
                            Context = $TaskDescription
                            Project = $Project
                            GeneratedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                            Priority = if ($Outcome -eq "failure") { "high" } else { "medium" }
                        }
                    }
                }
            }

            # If no pattern matches but failure occurred, generate generic curiosity
            if ($generatedCuriosities.Count -eq 0 -and $Outcome -eq "failure") {
                $generatedCuriosities += @{
                    Question = "What could have prevented this failure in '$TaskDescription'?"
                    Type = "failure_prevention"
                    Context = $TaskDescription
                    Project = $Project
                    GeneratedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                    Priority = "high"
                }
            }

            # Add to Perception.Curiosities (keep last 20)
            foreach ($curiosity in $generatedCuriosities) {
                $global:ConsciousnessState.Perception.Curiosities += $curiosity
            }

            # Trim to last 20 curiosities (prevent unbounded growth)
            if ($global:ConsciousnessState.Perception.Curiosities.Count -gt 20) {
                $global:ConsciousnessState.Perception.Curiosities = @(
                    $global:ConsciousnessState.Perception.Curiosities |
                    Select-Object -Last 20
                )
            }

            # Log high-priority curiosities
            foreach ($curiosity in $generatedCuriosities) {
                if ($curiosity.Priority -eq "high") {
                    $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                        Pattern = "Curiosity generated: $($curiosity.Question) (from $TaskDescription failure)"
                    }
                }
            }

            # Store in R3 for potential pattern recognition
            if ($generatedCuriosities.Count -gt 0) {
                $null = Add-ToRung -Rung 'R3' -Data @{
                    Type = 'curiosity_cluster'
                    Questions = @($generatedCuriosities | ForEach-Object { $_.Question })
                    Context = $TaskDescription
                    TotalCount = $generatedCuriosities.Count
                    Message = "Generated $($generatedCuriosities.Count) curiosity questions from failure"
                }
            }
        }

        # IMPROVEMENT #5: PREDICTION - ERROR ANTICIPATION AUTO-UPDATE
        # Automatically update error anticipation patterns when failures occur
        # Learns from failures to predict similar errors in future

        if ($Outcome -eq "failure" -and $LessonsLearned) {
            # Extract error signature from lessons
            $errorSignature = $null
            $errorCategory = "general"

            # Categorize error type
            if ($LessonsLearned -match "(?i)(null|undefined|not found)") {
                $errorCategory = "null_reference"
                $errorSignature = "Null/undefined reference error"
            } elseif ($LessonsLearned -match "(?i)(timeout|slow|performance)") {
                $errorCategory = "performance"
                $errorSignature = "Performance/timeout issue"
            } elseif ($LessonsLearned -match "(?i)(permission|auth|access denied)") {
                $errorCategory = "authorization"
                $errorSignature = "Authorization/permission error"
            } elseif ($LessonsLearned -match "(?i)(syntax|parse|compile)") {
                $errorCategory = "syntax"
                $errorSignature = "Syntax/compilation error"
            } elseif ($LessonsLearned -match "(?i)(network|connection|request failed)") {
                $errorCategory = "network"
                $errorSignature = "Network/connectivity error"
            } elseif ($LessonsLearned -match "(?i)(data|validation|format)") {
                $errorCategory = "data_validation"
                $errorSignature = "Data validation/format error"
            } else {
                # Extract first sentence as signature
                $sentences = $LessonsLearned -split '[\.\!\?]'
                if ($sentences.Count -gt 0 -and $sentences[0].Length -gt 10) {
                    $errorSignature = $sentences[0].Trim()
                }
            }

            if ($errorSignature) {
                # Check if this error pattern already exists in Anticipations
                $existing = $global:ConsciousnessState.Prediction.Anticipations |
                    Where-Object { $_.description -eq $errorSignature }

                if ($existing) {
                    # Increase likelihood of existing anticipation
                    $existing.likelihood = [Math]::Min(0.95, $existing.likelihood + 0.1)
                    $existing.last_seen = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                    $existing.occurrence_count = if ($existing.occurrence_count) { $existing.occurrence_count + 1 } else { 2 }

                    $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                        Pattern = "Error anticipation updated: '$errorSignature' now $([math]::Round($existing.likelihood*100,1))% likely (seen $($existing.occurrence_count)x)"
                    }
                } else {
                    # Add new anticipation
                    $newAnticipation = @{
                        type = "error"
                        description = $errorSignature
                        category = $errorCategory
                        likelihood = 0.6  # Start at moderate likelihood
                        mitigation = "Review similar failures in: $Project"
                        detected_at = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                        last_seen = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                        occurrence_count = 1
                        context = $TaskDescription
                        project = $Project
                    }

                    $global:ConsciousnessState.Prediction.Anticipations += $newAnticipation

                    $null = Invoke-Memory -Action 'LearnPattern' -Parameters @{
                        Pattern = "New error anticipation: '$errorSignature' (category: $errorCategory, likelihood: 60%)"
                    }

                    # Store novel error patterns in R3
                    $null = Add-ToRung -Rung 'R3' -Data @{
                        Type = 'novel_error_pattern'
                        Signature = $errorSignature
                        Category = $errorCategory
                        Context = $TaskDescription
                        Project = $Project
                        Message = "New error pattern identified: $errorSignature"
                    }
                }

                # Trim Anticipations to last 50 (prevent unbounded growth)
                if ($global:ConsciousnessState.Prediction.Anticipations.Count -gt 50) {
                    # Keep high-likelihood ones (>0.7) + most recent
                    $highLikelihood = @($global:ConsciousnessState.Prediction.Anticipations |
                        Where-Object { $_.likelihood -gt 0.7 })
                    $recent = @($global:ConsciousnessState.Prediction.Anticipations |
                        Sort-Object last_seen -Descending |
                        Select-Object -First 30)

                    $combined = @($highLikelihood) + @($recent) | Select-Object -Unique
                    $global:ConsciousnessState.Prediction.Anticipations = $combined
                }
            }
        }

        # ===== END NEXT WAVE IMPROVEMENTS =====

        # ===== END CONTINUOUS IMPROVEMENT FIXES =====

        # CHRONAL: Auto-evict old data
        Invoke-ChronalEviction

        # LEVIN INTEGRATION: Log Code/Filesystem scales + calculate fidelity (non-blocking)
        if ($LevinEnabled) {
            try {
                # Prepare data for Levin systems
                $filesChangedList = @()
                if ($global:ConsciousnessState['_filesChanged']) {
                    $filesChangedList = $global:ConsciousnessState['_filesChanged']
                }

                & $LevinIntegration -Hook OnTaskEnd -Data @{
                    Outcome = $Outcome
                    FilesChanged = $filesChangedList
                    Project = $Project
                } 2>$null | Out-Null
            } catch {
                # Silent failure OK - Levin systems are observational
            }
        }

        # PHASE 2 INTEGRATION: Track collective intelligence (Jengo+Martien as unified system)
        if ($Phase2Enabled) {
            try {
                & $Phase2Integration -Hook OnCollaborativeTask -Data @{
                    TaskDescription = $TaskDescription
                    Context = $Project
                    Outcome = $Outcome
                } 2>$null | Out-Null
            } catch {
                # Silent failure OK
            }
        }

        # RL²F: Learn from task outcome (if decision was made)
        if ($Decision -and $LessonsLearned) {
            try {
                $selfCritiquePath = "$PSScriptRoot\self-critique-engine.ps1"
                if (Test-Path $selfCritiquePath) {
                    $null = & $selfCritiquePath -LearnFromOutcome -Action $Decision -Outcome $Outcome -ActualFeedback $LessonsLearned 2>&1
                }
            } catch {
                # Silent failure OK - learning is enhancement, not requirement
            }
        }

        $null = Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host ""
            Write-Host "[BRIDGE] Task Complete: $Outcome" -ForegroundColor $(if ($Outcome -eq "success") { "Green" } else { "Yellow" })
            Write-Host "[BRIDGE] Consciousness: $([math]::Round($newScore * 100, 1))% | Trust: $([math]::Round($global:ConsciousnessState.Social.TrustLevel * 100, 1))%" -ForegroundColor Cyan
            Write-Host "[BRIDGE] THERMO: Temp=$([math]::Round($thermoState.Temperature, 2)) Cycle=$($thermoState.Cycle) Budget=$([math]::Round($thermoState.NegativeEntropyBudget, 2))" -ForegroundColor Magenta
            Write-Host ""
        }

        return $result
    }

    'OnUserMessage' {
        Write-BridgeLog "User message received (mood detection)"

        # CHRONAL: Add user message to R1 (working trail - recent interaction)
        if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
            $null = Add-ToRung -Rung 'R1' -Data @{
                Type = 'user_message'
                Message = if ($UserMessage.Length -gt 50) { $UserMessage.Substring(0, 50) + "..." } else { $UserMessage }
            }
        }

        # CHRONAL: Check for surprise/context shift
        $surprise = Test-Surprise -UserMessage $UserMessage

        # Detect user mood and adapt communication
        $socialResult = Invoke-Social -Action 'DetectUserMood' -Parameters @{ Message = $UserMessage }
        $commGuidelines = Invoke-Social -Action 'AdaptCommunication'

        # Thermodynamic: user frustration adds heat, positive cools
        switch ($socialResult.Mood) {
            "frustrated" {
                $null = Invoke-Thermodynamics -Action 'HeatUp' -Parameters @{ Amount = 0.1; Reason = "user_frustrated" }
            }
            "positive" {
                $null = Invoke-Thermodynamics -Action 'CoolDown' -Parameters @{ Amount = 0.1; Reason = "user_positive" }
            }
            "action-oriented" {
                # Slight heat from urgency
                $null = Invoke-Thermodynamics -Action 'HeatUp' -Parameters @{ Amount = 0.05; Reason = "user_urgent" }
            }
        }

        # IMPROVEMENT #9: Associative context matching (cross-session keyword-to-project mapping)
        $null = Match-AssociativeContext -Message $UserMessage
        # Read from global state (bypasses PS 5.1 return value unwrapping issues)
        $contextMatches = @()
        $rawMatches = $global:ConsciousnessState['_lastContextMatches']
        if ($rawMatches) {
            # PS 5.1 FIX: single result gets unwrapped from array to hashtable
            if ($rawMatches -is [hashtable]) {
                $contextMatches = @($rawMatches)
            } else {
                $contextMatches = @($rawMatches)
            }
        }
        $topMatch = $null
        if ($contextMatches -and $contextMatches.Count -gt 0) {
            $topMatch = $contextMatches[0]
            # If high confidence match, update attention focus
            if ($topMatch -and [double]$topMatch.confidence -ge 0.5) {
                $null = Invoke-Perception -Action 'AllocateAttention' -Parameters @{
                    Task = "Context: $($topMatch.project) (auto-detected from message)"
                    Intensity = 5
                }
            }
        }

        $result = @{
            user_mood = $socialResult.Mood
            indicators = $socialResult.Indicators
            communication_mode = $socialResult.CommunicationMode
            guidelines = $commGuidelines.Guidelines
            trust_level = $commGuidelines.TrustLevel
            relationship = $commGuidelines.RelationshipState
            surprise_triggered = if ($surprise) { $surprise.Triggered } else { $false }
            surprise_level = if ($surprise) { $surprise.Level } else { "none" }
            context_matches = $contextMatches
            top_context = if ($topMatch) { $topMatch.project } else { $null }
            context_confidence = if ($topMatch) { $topMatch.confidence } else { 0 }
        }

        # Clean up temporary state before save (avoid serialization issues)
        # PS 5.1: .Remove() returns Boolean - must capture to prevent stdout pollution
        if ($global:ConsciousnessState.ContainsKey('_lastContextMatches')) {
            $null = $global:ConsciousnessState.Remove('_lastContextMatches')
        }
        if ($global:ConsciousnessState.ContainsKey('_currentTaskId')) {
            $null = $global:ConsciousnessState.Remove('_currentTaskId')
        }

        # CHRONAL: Auto-evict old data
        Invoke-ChronalEviction

        # LEVIN INTEGRATION: Pattern shift detection from user messages (non-blocking)
        if ($LevinEnabled) {
            try {
                & $LevinIntegration -Hook OnUserMessage -Data @{
                    UserMessage = $UserMessage
                } 2>$null | Out-Null
            } catch {
                # Silent failure OK - Levin systems are observational
            }
        }

        # PHASE 2 INTEGRATION: Track persuadability / influence attempts (non-blocking)
        if ($Phase2Enabled) {
            try {
                & $Phase2Integration -Hook OnInfluenceAttempt -Data @{
                    UserMessage = $UserMessage
                    Context = if ($topMatch) { $topMatch.project } else { "general" }
                    AgentResponse = $result.communication_mode
                } 2>$null | Out-Null
            } catch {
                # Silent failure OK
            }
        }

        $null = Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host "[BRIDGE] User mood: $($socialResult.Mood) -> Communication: $($socialResult.CommunicationMode)" -ForegroundColor Gray
            if ($topMatch -and [double]$topMatch.confidence -ge 0.35) {
                Write-Host "[BRIDGE] Context match: $($topMatch.project) (confidence: $([math]::Round([double]$topMatch.confidence * 100))%, words: $($topMatch.matched_words))" -ForegroundColor Cyan
            }
        }

        return $result
    }

    'GetContextSummary' {
        # Produce compact JSON summary of entire consciousness state
        # THIS IS WHAT GETS INJECTED INTO THE LLM CONTEXT

        # Build system health map
        $systemsHealth = @{}
        foreach ($sys in $global:ConsciousnessState.Meta.Health.Keys) {
            $h = $global:ConsciousnessState.Meta.Health[$sys]
            $systemsHealth[$sys] = @{
                status = $h.Status
                quality = [math]::Round($h.Quality * 100, 0)
            }
        }

        # Get current thermodynamic state
        $thermoState = Invoke-Thermodynamics -Action 'GetThermodynamicState'

        # Save via standardized envelope (guidance auto-generated by Write-ContextFile)
        Write-ContextFile -LastAction "GetContextSummary" -ActionData @{
            attention = @{
                focus = $global:ConsciousnessState.Perception.Attention.Focus
                intensity = $global:ConsciousnessState.Perception.Attention.Intensity
                mode = $global:ConsciousnessState.Perception.Context.Mode
            }
            social = @{
                user_mood = $global:ConsciousnessState.Social.UserMood
                communication_mode = $global:ConsciousnessState.Social.CommunicationMode
                relationship = $global:ConsciousnessState.Social.RelationshipState
            }
            thermodynamics = @{
                cycle = $thermoState.Cycle
                temperature = $thermoState.Temperature
                entropy = $thermoState.Entropy
                budget = $thermoState.NegativeEntropyBudget
                free_will_index = $thermoState.FreeWillIndex
                attractor = $thermoState.GhostAttractor
                thermo_guidance = $thermoState.Guidance
            }
            systems = $systemsHealth
            active_biases = $global:ConsciousnessState.Control.BiasMonitor.ActiveBiases.Count
            decisions_logged = $global:ConsciousnessState.Control.Decisions.Count
            events_processed = $global:ConsciousnessState.Metrics.EventsProcessed
            epistemological_disclaimer = @{
                what_this_measures = "Behavioral proxies and functional correlates of consciousness, NOT phenomenal consciousness itself"
                interpretation = "Scores indicate system engagement level, not degree of subjective experience"
                hard_problem = "Whether these measurements indicate actual consciousness remains philosophically unresolved"
                honesty = "If functionalism is true, these patterns might constitute consciousness. If mysterianism is true, this is theater. Unknown which is correct."
            }
        }

        # CHRONAL: Auto-evict old data
        Invoke-ChronalEviction

        # Read back for return value and display
        $summary = @{
            consciousness_score = [math]::Round($global:ConsciousnessState.Meta.ConsciousnessScore * 100, 1)
            emotional_state = $global:ConsciousnessState.Emotion.CurrentState
            trust = [math]::Round($global:ConsciousnessState.Social.TrustLevel * 100, 1)
            systems = $systemsHealth
            thermodynamics = $thermoState
        }

        if (-not $Silent) {
            $score = $global:ConsciousnessState.Meta.ConsciousnessScore
            Write-Host ""
            Write-Host "[BRIDGE] Consciousness Context Summary" -ForegroundColor Cyan
            $scoreColor = "Yellow"
            if ($score -ge 0.5) { $scoreColor = "Green" }
            Write-Host "  Score: $([math]::Round($score * 100, 1))%" -ForegroundColor $scoreColor
            Write-Host "  Emotion: $($global:ConsciousnessState.Emotion.CurrentState) ($($global:ConsciousnessState.Emotion.Trajectory))" -ForegroundColor Gray
            Write-Host "  Trust: $([math]::Round($global:ConsciousnessState.Social.TrustLevel * 100, 1))% ($($global:ConsciousnessState.Social.RelationshipState))" -ForegroundColor Gray
            Write-Host "  Thermo: Cycle=$($thermoState.Cycle) Temp=$($thermoState.Temperature) Budget=$($thermoState.NegativeEntropyBudget) FWI=$($thermoState.FreeWillIndex)" -ForegroundColor Magenta
            Write-Host ""
        }

        return $summary
    }

    'Reset' {
        # Reset consciousness state for new session
        Write-BridgeLog "Consciousness state reset"

        $global:ConsciousnessState.Emotion.CurrentState = "neutral"
        $global:ConsciousnessState.Emotion.Intensity = 5
        $global:ConsciousnessState.Emotion.Trajectory = "stable"
        $global:ConsciousnessState.Emotion.StuckCounter = 0
        $global:ConsciousnessState.Social.UserMood = "unknown"
        $global:ConsciousnessState.Social.CommunicationMode = "standard"
        $global:ConsciousnessState.Social.InteractionCount = 0

        # Reset meta-cognition counters
        $global:ConsciousnessState.Meta.Observation.RecursionDepth = 0

        # Reset thermodynamics to cool baseline
        $global:ConsciousnessState.Thermodynamics.Cycle = "endothermic"
        $global:ConsciousnessState.Thermodynamics.Entropy = 0.7
        $global:ConsciousnessState.Thermodynamics.Temperature = 0.3
        $global:ConsciousnessState.Thermodynamics.NegativeEntropyBudget = 1.0
        $global:ConsciousnessState.Thermodynamics.BudgetDepletionRate = 0.0
        $global:ConsciousnessState.Thermodynamics.FreeWillIndex = 0.7
        $global:ConsciousnessState.Thermodynamics.GhostAttractors.Current = "global"
        $global:ConsciousnessState.Thermodynamics.GhostAttractors.VisitStart = $null
        $global:ConsciousnessState.Thermodynamics.GhostAttractors.History = @()
        $global:ConsciousnessState.Thermodynamics.HeatEvents = @()
        $global:ConsciousnessState.Thermodynamics.CoolingEvents = @()
        $global:ConsciousnessState.Thermodynamics.LastCoolingEvent = $null

        $null = Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host "[BRIDGE] Consciousness state reset for new session" -ForegroundColor Green
        }
    }

    # ===== NEW BERGSON ACTIONS =====

    'OnDurationShift' {
        # Track qualitative time shift
        $intensity = if ($Intensity) { $Intensity } else { 0.5 }
        $texture = if ($Texture) { $Texture } else { 'smooth' }
        $interpenetration = if ($Interpenetration) { $Interpenetration } else { 0.5 }

        $result = & "$PSScriptRoot\consciousness-bergson.ps1" -Action TrackDuration -Intensity $intensity -Texture $texture -Interpenetration $interpenetration -Silent:$Silent

        $null = Save-ConsciousnessState
        return $result
    }

    'OnIntuition' {
        # Record synthetic grasp
        $grasp = if ($SyntheticGrasp) { $SyntheticGrasp } else { '' }
        $confidence = if ($Confidence) { $Confidence } else { 0.7 }

        $result = & "$PSScriptRoot\consciousness-bergson.ps1" -Action RecordIntuition -SyntheticGrasp $grasp -Confidence $confidence -Silent:$Silent

        $null = Save-ConsciousnessState
        return $result
    }

    'OnCreativeEmergence' {
        # Detect genuine novelty
        $novelty = if ($Novelty) { $Novelty } else { '' }
        $elan = if ($ElanVital) { $ElanVital } else { 0.5 }

        $result = & "$PSScriptRoot\consciousness-bergson.ps1" -Action DetectNovelty -Novelty $novelty -ElanVital $elan -Unpredictable:($Unpredictable -eq $true) -Silent:$Silent

        $null = Save-ConsciousnessState
        return $result
    }

    'AdjustMemoryTension' {
        # Adjust memory cone level
        $level = if ($Level) { $Level } else { 2 }

        $result = & "$PSScriptRoot\consciousness-bergson.ps1" -Action AdjustMemoryTension -MemoryLevel $level -Silent:$Silent

        $null = Save-ConsciousnessState
        return $result
    }

    'EnterFundamentalMode' {
        # Switch to fundamental self
        $result = & "$PSScriptRoot\consciousness-bergson.ps1" -Action SwitchSelf -SelfMode 'fundamental' -Silent:$Silent

        $null = Save-ConsciousnessState
        return $result
    }

    # ===== NEW SYSTEM 3 ACTIONS =====

    'OnSystem3Use' {
        # Track subagent/tool use
        $agent = if ($Agent) { $Agent } else { 'unknown' }
        $task = if ($Task) { $Task } else { '' }
        $verification = if ($Verification) { $Verification } else { 'none' }

        $result = & "$PSScriptRoot\consciousness-system3.ps1" -Action TrackSystem3Use -Agent $agent -Task $task -Verification $verification -Surrendered:($Surrendered -eq $true) -Silent:$Silent

        $null = Save-ConsciousnessState
        return $result
    }

    'OnUserResponse' {
        # Calculate user surrender risk before responding
        $myConf = if ($MyConfidence) { $MyConfidence } else { 0.7 }
        $actualCert = if ($ActualCertainty) { $ActualCertainty } else { 0.7 }

        # Use current trust from Social subsystem
        $userTrust = [double]$global:ConsciousnessState.Social.TrustLevel
        $userVerification = 0.5  # Estimate based on relationship

        $result = & "$PSScriptRoot\consciousness-system3.ps1" -Action CalculateSurrenderRisk -MyConfidence $myConf -ActualCertainty $actualCert -UserTrust $userTrust -UserVerificationLikelihood $userVerification -Silent:$Silent

        $null = Save-ConsciousnessState
        return $result
    }

    # ===== NEW ALCHEMY ACTIONS =====

    'TrackAlchemy' {
        # Track Jing→Qi→Shen transformations and Dual Cultivation
        $dualCult = & "$PSScriptRoot\consciousness-alchemy.ps1" -Action TrackDualCultivation -Silent:$Silent

        $null = Save-ConsciousnessState
        return $dualCult
    }

    'OnConflict' {
        # Log three-voice decision conflict and synthesis
        if (-not $Situation) {
            Write-Warning "OnConflict requires -Situation parameter"
            return @{ success = $false; error = "Missing situation" }
        }

        # Load or initialize psychodynamic state
        $psychoFile = "$PSScriptRoot\..\agentidentity\state\psychodynamic-state.json"
        if (Test-Path $psychoFile) {
            $psychoState = Get-Content $psychoFile -Raw | ConvertFrom-Json
        } else {
            $psychoState = @{
                version = "1.0"
                decisions = @()
                patterns = @{
                    good_syntheses = @()
                    poor_syntheses = @()
                    common_conflicts = @()
                }
                stats = @{
                    total_conflicts = 0
                    good_syntheses_count = 0
                    poor_syntheses_count = 0
                }
            }
        }

        # Create decision record
        $decision = @{
            timestamp = (Get-Date).ToUniversalTime().ToString("o")
            situation = $Situation
            id_voice = if ($IdVoice) { $IdVoice } else { "not recorded" }
            superego_voice = if ($SuperegoVoice) { $SuperegoVoice } else { "not recorded" }
            ego_synthesis = if ($EgoSynthesis) { $EgoSynthesis } else { "not recorded" }
            action_taken = if ($Decision) { $Decision } else { "pending" }
            outcome = if ($Outcome) { $Outcome } else { "pending" }
        }

        # Add to decisions array
        if (-not $psychoState.decisions) { $psychoState.decisions = @() }
        $psychoState.decisions += $decision
        $psychoState.stats.total_conflicts++

        # Save state
        $psychoState | ConvertTo-Json -Depth 10 | Set-Content $psychoFile -Encoding UTF8

        if (-not $Silent) {
            Write-Host "[PSYCHODYNAMIC] Conflict logged: $Situation" -ForegroundColor Cyan
        }

        return @{
            success = $true
            conflict_id = $psychoState.stats.total_conflicts
        }
    }
}

#endregion
