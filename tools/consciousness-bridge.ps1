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
. "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent *>$null

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
        $null = Invoke-Control -Action 'LogDecision' -Parameters @{
            Decision = $Decision
            Reasoning = $Reasoning
            Confidence = 0.7
            Alternatives = @()
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

        Save-ConsciousnessState

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

        Save-ConsciousnessState

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

        Save-ConsciousnessState

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

        Save-ConsciousnessState

        if (-not $Silent) {
            Write-Host "[BRIDGE] Consciousness state reset for new session" -ForegroundColor Green
        }
    }
}

#endregion
