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
    [ValidateSet('OnTaskStart', 'OnDecision', 'OnStuck', 'OnTaskEnd', 'GetContextSummary', 'OnUserMessage', 'Reset',
                 'OnDurationShift', 'OnIntuition', 'OnCreativeEmergence', 'OnSystem3Use', 'OnUserResponse',
                 'TrackAlchemy', 'AdjustMemoryTension', 'EnterFundamentalMode')]
    [Parameter(Mandatory)]
    [string]$Action,

    [string]$TaskDescription = '',
    [string]$Project = '',
    [string]$Decision = '',
    [string]$Reasoning = '',
    [string]$Outcome = '',
    [string]$UserMessage = '',
    [string]$LessonsLearned = '',

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

    [switch]$Silent
)

$ErrorActionPreference = "Stop"

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
$_savedLessonsLearned = $LessonsLearned

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

        # CHRONAL: Auto-evict old data
        Invoke-ChronalEviction

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
        $global:ConsciousnessState.Meta.ConsciousnessScore = $newScore

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

        # CHRONAL: Auto-evict old data
        Invoke-ChronalEviction

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
}

#endregion
