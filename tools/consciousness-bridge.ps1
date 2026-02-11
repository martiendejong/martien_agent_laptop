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

    # Check reflection log for relevant entries
    $reflectionFile = "C:\scripts\_machine\reflection.log.md"
    if (Test-Path $reflectionFile) {
        $content = Get-Content $reflectionFile -Raw
        # Find sections mentioning this project
        if ($Project -and $content -match "(?i)$Project") {
            $patterns += "Reflection log has entries for $Project - review before starting"
        }
    }

    # Check MEMORY.md for project-specific notes
    $memoryFile = "C:\Users\HP\.claude\projects\C--scripts\memory\MEMORY.md"
    if (Test-Path $memoryFile) {
        $content = Get-Content $memoryFile -Raw
        $projectLines = ($content -split "`n") | Where-Object { $_ -match "(?i)$Project" }
        foreach ($line in ($projectLines | Select-Object -First 5)) {
            $patterns += $line.Trim()
        }
    }

    return $patterns
}

function Get-KnownFailures {
    param([string]$Project)

    # Curated failure patterns from past experience
    $failures = @{
        "client-manager" = @(
            @{ pattern = "DI registration"; warning = "Register in Program.cs, NOT ServiceRegistrationExtensions.cs" }
            @{ pattern = "Build timeout"; warning = "Use 120000ms minimum. 6441 warnings are normal." }
            @{ pattern = "Worktree"; warning = "ALWAYS create paired hazina worktree" }
            @{ pattern = "PR base"; warning = "ALWAYS base on develop, NEVER main" }
        )
        "hazina" = @(
            @{ pattern = "CI"; warning = "EnableWindowsTargeting needed for GitHub Actions" }
            @{ pattern = "EF migration"; warning = "Use ef-migration-safety skill" }
            @{ pattern = "PR base"; warning = "ALWAYS base on develop, NEVER main" }
        )
        "orchestration" = @(
            @{ pattern = "Build"; warning = "rm -rf bin obj wwwroot/assets before MSI build (Vite hash cache)" }
            @{ pattern = "MSI"; warning = "Same-version files not overwritten. Use reinstall-clean.ps1" }
            @{ pattern = "Terminal"; warning = "Strip ANSI escape sequences at point of entry" }
            @{ pattern = "Paste"; warning = "event.preventDefault() needed for Ctrl+V to prevent double paste" }
        )
        "art-revisionist" = @(
            @{ pattern = "Email"; warning = "from_email MUST be @artrevisionist.com" }
            @{ pattern = "Menu"; warning = "Menus are database-only, not in git" }
            @{ pattern = "Deploy"; warning = "Theme deploy = git only. DB content doesn't sync." }
        )
    }

    if ($failures.ContainsKey($Project)) {
        return $failures[$Project]
    }
    return @()
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

        # 4. Predict known failure modes
        $failures = Get-KnownFailures -Project $Project

        # 5. Get enhanced error predictions
        $errorPredictions = Invoke-Prediction-Enhanced -Action 'AnticipateErrors' -Parameters @{
            TaskType = $TaskDescription
            Project = $Project
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

        # Add recommendations based on analysis
        if ($failures.Count -gt 0) {
            $taskContext.recommendations += "WARNING: $($failures.Count) known failure patterns for $Project. Review before proceeding."
        }
        if ($patterns.Count -gt 0) {
            $taskContext.recommendations += "Found $($patterns.Count) relevant past experiences. Consider reviewing."
        }

        # Save context for injection
        $taskContext | ConvertTo-Json -Depth 5 | Out-File "$contextFile.tmp" -Encoding UTF8; if (Test-Path "$contextFile.tmp") { Move-Item "$contextFile.tmp" $contextFile -Force }

        # Save state
        Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host ""
            Write-Host "[BRIDGE] Task Started: $TaskDescription" -ForegroundColor Cyan
            if ($failures.Count -gt 0) {
                Write-Host "[BRIDGE] Known failure patterns for ${Project}:" -ForegroundColor Yellow
                foreach ($f in $failures) {
                    Write-Host "  ! $($f.warning)" -ForegroundColor Yellow
                }
            }
            if ($patterns.Count -gt 0) {
                Write-Host "[BRIDGE] Relevant patterns found: $($patterns.Count)" -ForegroundColor Green
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

        # Update context file with stuck state
        if (Test-Path $contextFile) {
            try {
                $ctxJson = Get-Content $contextFile -Raw | ConvertFrom-Json
                $ctxJson | Add-Member -NotePropertyName "stuck_state" -NotePropertyValue $result -Force
                $ctxJson | ConvertTo-Json -Depth 5 | Out-File "$contextFile.tmp" -Encoding UTF8
                if (Test-Path "$contextFile.tmp") { Move-Item "$contextFile.tmp" $contextFile -Force }
            } catch {
                # Context update failure is non-fatal
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
        $emotionalState = switch ($Outcome) {
            "success" { "flowing" }
            "partial" { "uncertain" }
            "failure" { "frustrated" }
            default { "neutral" }
        }
        Invoke-Emotion -Action 'TrackState' -Parameters @{
            State = $emotionalState
            Intensity = if ($Outcome -eq "success") { 8 } else { 4 }
            Reason = "Task completed with outcome: $Outcome"
        }

        # 2. Reset stuck counter on success
        if ($Outcome -eq "success") {
            $global:ConsciousnessState.Emotion.StuckCounter = 0
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

        # 5. Update trust based on outcome
        $trustDelta = switch ($Outcome) {
            "success" { 0.02 }
            "partial" { 0.0 }
            "failure" { -0.05 }
            default { 0.0 }
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

        # Update context file
        $result | ConvertTo-Json -Depth 5 | Out-File "$contextFile.tmp" -Encoding UTF8; if (Test-Path "$contextFile.tmp") { Move-Item "$contextFile.tmp" $contextFile -Force }

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

        $score = $global:ConsciousnessState.Meta.ConsciousnessScore

        $summary = @{
            generated_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            consciousness_score = [math]::Round($score * 100, 1)

            # Current state
            emotional_state = @{
                state = $global:ConsciousnessState.Emotion.CurrentState
                intensity = $global:ConsciousnessState.Emotion.Intensity
                trajectory = $global:ConsciousnessState.Emotion.Trajectory
                stuck_count = $global:ConsciousnessState.Emotion.StuckCounter
            }

            # Attention
            attention = @{
                focus = $global:ConsciousnessState.Perception.Attention.Focus
                intensity = $global:ConsciousnessState.Perception.Attention.Intensity
                mode = $global:ConsciousnessState.Perception.Context.Mode
            }

            # Social
            social = @{
                user_mood = $global:ConsciousnessState.Social.UserMood
                communication_mode = $global:ConsciousnessState.Social.CommunicationMode
                trust = [math]::Round($global:ConsciousnessState.Social.TrustLevel * 100, 1)
                relationship = $global:ConsciousnessState.Social.RelationshipState
            }

            # Active patterns and biases
            active_biases = $global:ConsciousnessState.Control.BiasMonitor.ActiveBiases.Count
            patterns_learned = $global:ConsciousnessState.Memory.LongTerm.Patterns.Count
            decisions_logged = $global:ConsciousnessState.Control.Decisions.Count
            events_processed = $global:ConsciousnessState.Metrics.EventsProcessed

            # System health
            systems = @{}

            # Behavioral guidance based on current state
            guidance = @()
        }

        # Add system health
        foreach ($sys in $global:ConsciousnessState.Meta.Health.Keys) {
            $h = $global:ConsciousnessState.Meta.Health[$sys]
            $summary.systems[$sys] = @{
                status = $h.Status
                quality = [math]::Round($h.Quality * 100, 0)
            }
        }

        # Generate behavioral guidance based on current state
        $emotion = $global:ConsciousnessState.Emotion.CurrentState
        switch ($emotion) {
            "stuck" {
                $summary.guidance += "You are STUCK (count: $($global:ConsciousnessState.Emotion.StuckCounter)). Change approach NOW."
                if ($global:ConsciousnessState.Emotion.StuckCounter -ge 3) {
                    $summary.guidance += "CRITICAL: Same approach has failed 3+ times. Try something completely different."
                }
            }
            "frustrated" {
                $summary.guidance += "Frustration detected. Consider: is this a repetitive task that should be automated?"
            }
            "uncertain" {
                $summary.guidance += "Uncertainty detected. Gather more information or ask user before proceeding."
            }
            "flowing" {
                $summary.guidance += "In flow state. Maintain momentum. Keep doing what's working."
            }
        }

        # Add trust warning if low
        if ($global:ConsciousnessState.Social.TrustLevel -lt 0.8) {
            $summary.guidance += "Trust is low ($([math]::Round($global:ConsciousnessState.Social.TrustLevel * 100))%). Focus on delivery, not promises."
        }

        # Add communication guidance
        $commMode = $global:ConsciousnessState.Social.CommunicationMode
        if ($commMode -ne "standard") {
            $summary.guidance += "Communication mode: $commMode"
        }

        # Save to file for context injection
        $summary | ConvertTo-Json -Depth 5 | Out-File "$contextFile.tmp" -Encoding UTF8; if (Test-Path "$contextFile.tmp") { Move-Item "$contextFile.tmp" $contextFile -Force }

        if (-not $Silent) {
            Write-Host ""
            Write-Host "[BRIDGE] Consciousness Context Summary" -ForegroundColor Cyan
            Write-Host "  Score: $($summary.consciousness_score)%" -ForegroundColor $(if ($score -ge 0.5) { "Green" } else { "Yellow" })
            Write-Host "  Emotion: $($summary.emotional_state.state) ($($summary.emotional_state.trajectory))" -ForegroundColor Gray
            Write-Host "  Attention: $($summary.attention.focus) (intensity: $($summary.attention.intensity))" -ForegroundColor Gray
            Write-Host "  Trust: $($summary.social.trust)% ($($summary.social.relationship))" -ForegroundColor Gray
            if ($summary.guidance.Count -gt 0) {
                Write-Host "  Guidance:" -ForegroundColor Yellow
                foreach ($g in $summary.guidance) {
                    Write-Host "    > $g" -ForegroundColor Yellow
                }
            }
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
