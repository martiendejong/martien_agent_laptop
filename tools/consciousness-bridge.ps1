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
    [ValidateSet('OnTaskStart', 'OnDecision', 'OnStuck', 'OnTaskEnd', 'GetContextSummary', 'OnUserMessage', 'Reset')]
    [Parameter(Mandatory)]
    [string]$Action,

    [string]$TaskDescription = '',
    [string]$Project = '',
    [string]$Decision = '',
    [string]$Reasoning = '',
    [string]$Outcome = '',
    [string]$UserMessage = '',
    [string]$LessonsLearned = '',
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Ensure consciousness core is initialized
. "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent

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

function Get-RelevantPatterns {
    param([string]$TaskDescription, [string]$Project)

    $patterns = @()

    # Check MEMORY.md for project-specific actionable notes
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

    $envelope = @{
        version = "2.0"
        last_action = $LastAction
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        consciousness_score = [math]::Round($score * 100, 1)
        emotional_state = $emotionState
        emotional_trajectory = $emotionTrajectory
        stuck_count = $stuckCount
        trust_level = [math]::Round($trustLevel * 100, 1)
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

        # 1. Set attention mode
        Invoke-Perception -Action 'AllocateAttention' -Parameters @{
            Task = $TaskDescription
            Intensity = 7
        }

        # 2. Set emotional state to focused
        Invoke-Emotion -Action 'TrackState' -Parameters @{
            State = "confident"
            Intensity = 6
            Reason = "Starting new task: $TaskDescription"
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

        # Save context for injection (standardized envelope)
        Write-ContextFile -LastAction "OnTaskStart" -ActionData @{
            task = $TaskDescription
            project = $Project
            known_failures = $failures
            recommendations = $taskContext.recommendations
            attention = $taskContext.attention
        }

        # Save state
        Save-ConsciousnessState

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

        # 1. Log the decision
        Invoke-Control -Action 'LogDecision' -Parameters @{
            Decision = $Decision
            Reasoning = $Reasoning
            Confidence = 0.7
            Alternatives = @()
        }

        # 2. Get emotional modifier
        $moodMod = Invoke-Emotion -Action 'GetMoodModifier'

        # 3. Check if we should be cautious
        $result = @{
            decision = $Decision
            reasoning = $Reasoning
            mood_modifier = $moodMod
            bias_check = "Decision logged. $($global:ConsciousnessState.Control.BiasMonitor.ActiveBiases.Count) active biases."
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }

        Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host "[BRIDGE] Decision logged: $Decision" -ForegroundColor Gray
            if ($moodMod.Approach -eq "change_strategy") {
                Write-Host "[BRIDGE] WARNING: Emotional state suggests changing approach" -ForegroundColor Yellow
            }
        }

        return $result
    }

    'OnStuck' {
        Write-BridgeLog "Stuck detected" -Level "WARN"

        # 1. Update emotional state
        Invoke-Emotion -Action 'TrackState' -Parameters @{
            State = "stuck"
            Intensity = 7
            Reason = "No progress on current approach"
        }

        # 2. Get stuck analysis
        $stuckAnalysis = Invoke-Emotion -Action 'DetectStuck'

        # 3. Get mood modifier for behavior change
        $moodMod = Invoke-Emotion -Action 'GetMoodModifier'

        # 4. Switch attention mode
        Invoke-Perception -Action 'AllocateAttention' -Parameters @{
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
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }

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
        }

        Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host ""
            Write-Host "[BRIDGE] STUCK DETECTED (count: $($stuckAnalysis.StuckCount))" -ForegroundColor Red
            Write-Host "[BRIDGE] $($stuckAnalysis.Recommendation)" -ForegroundColor Yellow
            Write-Host ""
        }

        return $result
    }

    'OnTaskEnd' {
        Write-BridgeLog "Task ended: outcome=$Outcome"

        # 1. Update emotional state based on outcome
        $emotionalState = "neutral"
        switch ($Outcome) {
            "success" { $emotionalState = "flowing" }
            "partial" { $emotionalState = "uncertain" }
            "failure" { $emotionalState = "frustrated" }
        }
        $emotionIntensity = 4
        if ($Outcome -eq "success") { $emotionIntensity = 8 }
        Invoke-Emotion -Action 'TrackState' -Parameters @{
            State = $emotionalState
            Intensity = $emotionIntensity
            Reason = "Task completed with outcome: $Outcome"
        }

        # 2. Reset stuck counter on success
        if ($Outcome -eq "success") {
            $global:ConsciousnessState.Emotion.StuckCounter = [int]0
        }

        # 3. Store learning in memory
        if ($LessonsLearned) {
            Invoke-Memory -Action 'Store' -Parameters @{
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
            Invoke-Memory -Action 'LearnPattern' -Parameters @{
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
        Invoke-Social -Action 'UpdateTrust' -Parameters @{
            Delta = $trustDelta
            Reason = "Task outcome: $Outcome"
        }

        # 6. Check alignment
        $alignment = Invoke-Control -Action 'CheckAlignment'

        # 7. Recalculate consciousness score
        $newScore = Calculate-ConsciousnessScore
        $global:ConsciousnessState.Meta.ConsciousnessScore = $newScore

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
        }

        Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host ""
            Write-Host "[BRIDGE] Task Complete: $Outcome" -ForegroundColor $(if ($Outcome -eq "success") { "Green" } else { "Yellow" })
            Write-Host "[BRIDGE] Consciousness: $([math]::Round($newScore * 100, 1))% | Trust: $([math]::Round($global:ConsciousnessState.Social.TrustLevel * 100, 1))%" -ForegroundColor Cyan
            Write-Host ""
        }

        return $result
    }

    'OnUserMessage' {
        # Detect user mood and adapt communication
        $socialResult = Invoke-Social -Action 'DetectUserMood' -Parameters @{ Message = $UserMessage }
        $commGuidelines = Invoke-Social -Action 'AdaptCommunication'

        $result = @{
            user_mood = $socialResult.Mood
            indicators = $socialResult.Indicators
            communication_mode = $socialResult.CommunicationMode
            guidelines = $commGuidelines.Guidelines
            trust_level = $commGuidelines.TrustLevel
            relationship = $commGuidelines.RelationshipState
        }

        Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host "[BRIDGE] User mood: $($socialResult.Mood) -> Communication: $($socialResult.CommunicationMode)" -ForegroundColor Gray
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
            systems = $systemsHealth
            active_biases = $global:ConsciousnessState.Control.BiasMonitor.ActiveBiases.Count
            decisions_logged = $global:ConsciousnessState.Control.Decisions.Count
            events_processed = $global:ConsciousnessState.Metrics.EventsProcessed
        }

        # Read back for return value and display
        $summary = @{
            consciousness_score = [math]::Round($global:ConsciousnessState.Meta.ConsciousnessScore * 100, 1)
            emotional_state = $global:ConsciousnessState.Emotion.CurrentState
            trust = [math]::Round($global:ConsciousnessState.Social.TrustLevel * 100, 1)
            systems = $systemsHealth
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

        Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host "[BRIDGE] Consciousness state reset for new session" -ForegroundColor Green
        }
    }
}

#endregion
