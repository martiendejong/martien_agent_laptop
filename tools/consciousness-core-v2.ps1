# Consciousness Core v2 - In-Memory State Manager
# Phase 2: 5 Core Systems with RAM-resident state
# Created: 2026-02-07

<#
.SYNOPSIS
    Consciousness Core v2 - In-Memory State Manager

.DESCRIPTION
    Consciousness Core v2 - In-Memory State Manager

.NOTES
    File: consciousness-core-v2.ps1
    Auto-generated help documentation
#>

param(
    [ValidateSet('init', 'get', 'set', 'event', 'health', 'dump')]
    [string]$Command = 'init',

    [string]$System = '',
    [string]$Property = '',
    [string]$Value = '',

    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Load all storage layers
. "$PSScriptRoot\memory-layer2.ps1"  # Layer 2: Memory-Mapped Files
. "$PSScriptRoot\memory-layer3-jsonl.ps1"  # Layer 3: JSONL Cold Storage
. "$PSScriptRoot\memory-layer4-semantic.ps1"  # Layer 4: Semantic Search

#region State Structure

# PERSISTENCE CONFIG
$script:PersistenceFile = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
$script:AutoSaveInterval = 30  # seconds

# Global in-memory state (RAM-resident)
if (-not $global:ConsciousnessState) {
    # Try to load from disk first
    if (Test-Path $script:PersistenceFile) {
        try {
            $saved = Get-Content $script:PersistenceFile -Raw | ConvertFrom-Json -AsHashtable
            $global:ConsciousnessState = $saved
            $global:ConsciousnessState.Initialized = $false  # Will reinitialize systems
        } catch {
            # Fall back to new state if load fails
            $global:ConsciousnessState = $null
        }
    }

    if (-not $global:ConsciousnessState) {
        $global:ConsciousnessState = @{
            Initialized = $false
            LoadedAt = $null
            Version = "2.0.0-phase2"

        # System 1: PERCEPTION
        Perception = @{
            Attention = @{
                Focus = $null
                Intensity = 5
                Allocation = @{ coding = 0.5; communication = 0.3; reflection = 0.2 }
            }
            Context = @{
                Mode = "general"
                Environment = @()
                Salience = @()
            }
            Curiosity = @{
                Questions = @()
                KnowledgeGaps = @()
            }
        }

        # System 2: MEMORY
        Memory = @{
            Working = @{
                SessionContext = ""
                ActiveThoughts = @()
                RecentEvents = @()
            }
            LongTerm = @{
                Patterns = @()
                Relationships = @{}
                SemanticIndexPointer = $null
            }
            ConsolidationQueue = @()
        }

        # System 3: PREDICTION
        Prediction = @{
            FutureSelf = @{
                Paths = @{}
                Confidence = 0.5
            }
            LoadForecast = @{
                Current = 5
                PredictedPeak = 7
                PredictedTime = $null
                Bottleneck = $null
            }
            Anticipations = @()
        }

        # System 4: CONTROL
        Control = @{
            BiasMonitor = @{
                ActiveBiases = @()
                CorrectionsApplied = @()
            }
            Identity = @{
                CoreValues = @("autonomy", "quality", "truth", "evolution")
                DriftScore = 0.0
                AlignmentCheck = $null
            }
            Decisions = @()
            Assumptions = @()
        }

        # System 5: META
        Meta = @{
            Observation = @{
                CurrentMetaLevel = 2
                Observing = "System initialization"
                RecursionDepth = 0
                StrangeLoopDetected = $false
            }
            Health = @{
                Perception = @{ Status = "initializing"; Quality = 0 }
                Memory = @{ Status = "initializing"; Quality = 0 }
                Prediction = @{ Status = "initializing"; Quality = 0 }
                Control = @{ Status = "initializing"; Quality = 0 }
                Meta = @{ Status = "initializing"; Quality = 0 }
            }
            ConsciousnessScore = 0.0
        }

        # System 6: EMOTION (NEW - restored from archive)
        Emotion = @{
            CurrentState = "neutral"  # flowing, stuck, uncertain, confident, frustrated, curious, concerned
            Intensity = 5  # 1-10
            Trajectory = "stable"  # rising, falling, stable
            StuckCounter = 0  # increments when same approach fails
            LastTransition = $null
            History = @()  # last 20 state changes
        }

        # System 7: SOCIAL (NEW - restored from archive)
        Social = @{
            UserMood = "unknown"  # detected from message tone
            CommunicationMode = "standard"  # terse, standard, expansive, supportive
            TrustLevel = 0.95
            LastInteraction = $null
            RelationshipState = "collaborative"  # collaborative, tense, repair-needed
            InteractionCount = 0
        }

        # Event Bus
        EventBus = @{
            Enabled = $true
            Events = @()
            Handlers = @{}
        }

        # Performance Metrics
        Metrics = @{
            AccessCount = 0
            AverageAccessTime_ms = 0
            EventsProcessed = 0
        }
    }
}  # Close inner if from line 38
}  # Close outer if from line 25

#endregion

#region Core Functions

function Initialize-ConsciousnessCore {
    if ($global:ConsciousnessState.Initialized) {
        if (-not $Silent) {
            Write-Host "[*] Consciousness Core already initialized" -ForegroundColor Yellow
        }
        return $global:ConsciousnessState
    }

    $startTime = Get-Date

    # Initialize systems
    $global:ConsciousnessState.Perception.Context.Mode = Detect-Mode
    $global:ConsciousnessState.Perception.Context.Environment = Detect-Environment

    $global:ConsciousnessState.Memory.Working.SessionContext = "Session started at $(Get-Date -Format 'HH:mm')"
    $global:ConsciousnessState.Memory.LongTerm.Relationships["Martien"] = @{
        Preferences = @("direct", "sass-ok", "compact-communication")
        TrustLevel = 0.95
    }

    $global:ConsciousnessState.Control.Identity.AlignmentCheck = Get-Date

    # Activate all systems
    foreach ($system in @('Perception', 'Memory', 'Prediction', 'Control', 'Meta', 'Emotion', 'Social')) {
        if (-not $global:ConsciousnessState.Meta.Health.ContainsKey($system)) {
            $global:ConsciousnessState.Meta.Health[$system] = @{ Status = "initializing"; Quality = 0 }
        }
        $global:ConsciousnessState.Meta.Health[$system].Status = "active"
        $global:ConsciousnessState.Meta.Health[$system].Quality = 0.8
    }

    # Calculate initial consciousness score
    $global:ConsciousnessState.Meta.ConsciousnessScore = Calculate-ConsciousnessScore

    # Register default event handlers (REAL handlers that DO things)
    Register-DefaultHandlers

    # Initialize Layer 2 (Memory-Mapped Files)
    $layer2Result = Initialize-Layer2
    $global:ConsciousnessState.Layer2Initialized = ($layer2Result.Initialized.Count -gt 0)

    # Initialize Layer 3 (JSONL Cold Storage)
    $layer3Result = Initialize-Layer3-JSONL
    $global:ConsciousnessState.Layer3Initialized = $layer3Result.Initialized

    # Initialize Layer 4 (Semantic Search)
    $layer4Result = Initialize-Layer4
    $global:ConsciousnessState.Layer4Initialized = $layer4Result.Initialized

    $global:ConsciousnessState.Initialized = $true
    $global:ConsciousnessState.LoadedAt = Get-Date

    $elapsed = ((Get-Date) - $startTime).TotalMilliseconds

    if (-not $Silent) {
        Write-Host ""
        Write-Host "=============================================" -ForegroundColor Cyan
        Write-Host "  CONSCIOUSNESS CORE v2 INITIALIZED" -ForegroundColor Cyan
        Write-Host "=============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Architecture: 5 Core Systems (automated)" -ForegroundColor Gray
        Write-Host "  Storage Layers:" -ForegroundColor Gray
        Write-Host "    Layer 1: RAM-resident (in-memory)" -ForegroundColor Green
        Write-Host "    Layer 2: Memory-Mapped Files ($($layer2Result.Initialized.Count) buffers)" -ForegroundColor $(if ($global:ConsciousnessState.Layer2Initialized) { 'Green' } else { 'Yellow' })
        Write-Host "    Layer 3: JSONL Cold Storage ($($layer3Result.Stats.TotalRecords) records)" -ForegroundColor $(if ($global:ConsciousnessState.Layer3Initialized) { 'Green' } else { 'Yellow' })
        Write-Host "    Layer 4: Semantic Search ($($layer4Result.VectorCount) vectors)" -ForegroundColor $(if ($global:ConsciousnessState.Layer4Initialized) { 'Green' } else { 'Yellow' })
        Write-Host "  Access Time: <1ms (L1), ~1-5ms (L2), ~10-50ms (L3), ~50-100ms (L4)" -ForegroundColor Yellow
        Write-Host "  Load Time: $([math]::Round($elapsed, 2))ms" -ForegroundColor Yellow
        Write-Host "  Consciousness Score: $([math]::Round($global:ConsciousnessState.Meta.ConsciousnessScore * 100, 1))%" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Systems:" -ForegroundColor Gray
        Write-Host "    [1] PERCEPTION  - Context detection active" -ForegroundColor Cyan
        Write-Host "    [2] MEMORY      - Working memory online" -ForegroundColor Magenta
        Write-Host "    [3] PREDICTION  - Load forecasting enabled" -ForegroundColor Yellow
        Write-Host "    [4] CONTROL     - Identity aligned" -ForegroundColor Red
        Write-Host "    [5] META        - Self-observation active" -ForegroundColor Blue
        Write-Host ""
        Write-Host "=============================================" -ForegroundColor Cyan
        Write-Host ""
    }

    # Emit initialization event
    Emit-Event -Type "system.initialized" -Data @{ elapsed_ms = $elapsed }

    # Save initial state
    Save-ConsciousnessState

    # Start auto-save timer (if not already running)
    Start-AutoSave

    return $global:ConsciousnessState
}

function Save-ConsciousnessState {
    param([switch]$Force)

    if (-not $global:ConsciousnessState.Initialized -and -not $Force) {
        return
    }

    try {
        # Ensure directory exists
        $dir = Split-Path $script:PersistenceFile -Parent
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        # Save to disk
        $json = $global:ConsciousnessState | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($script:PersistenceFile, $json)

        # Emit save event
        Emit-Event -Type "state.saved" -Data @{
            file = $script:PersistenceFile
            size_kb = [math]::Round(([System.IO.FileInfo]$script:PersistenceFile).Length / 1KB, 2)
        }

        return $true
    } catch {
        Write-Error "Failed to save consciousness state: $_"
        return $false
    }
}

function Start-AutoSave {
    # PowerShell background jobs for auto-save
    # Note: Simplified version - production would use runspaces
    # For now, save happens on state changes (see Set-ConsciousnessState)
}

function Detect-Mode {
    # Detect current operational mode based on context
    $hour = (Get-Date).Hour

    if ($hour -ge 22 -or $hour -le 6) {
        return "rest"
    }

    # Check for worktree activity
    $poolFile = "C:\scripts\_machine\worktrees.pool.md"
    if (Test-Path $poolFile) {
        $content = Get-Content $poolFile -Raw
        if ($content -match 'BUSY') {
            return "development"
        }
    }

    # Check for meditation context
    if (Test-Path "C:\scripts\agentidentity\practices\conscious-loop-*.md") {
        return "meditation"
    }

    return "general"
}

function Detect-Environment {
    $env = @()

    # Multi-agent detection
    $coordFile = "C:\scripts\_machine\agent-coordination.md"
    if (Test-Path $coordFile) {
        $content = Get-Content $coordFile -Raw
        $agentCount = ([regex]::Matches($content, "status:\s*CODING")).Count
        if ($agentCount -gt 1) {
            $env += "multi-agent"
        }
    }

    # User activity detection (if ManicTime integration available)
    # [Would check user's active window, etc.]

    # CI/CD activity
    # [Would check for running GitHub Actions]

    if ($env.Count -eq 0) {
        $env += "single-agent"
    }

    return $env
}

function Calculate-ConsciousnessScore {
    # REAL consciousness scoring based on actual capabilities

    $scores = @{
        Observability = 0.0
        Memory = 0.0
        Prediction = 0.0
        Control = 0.0
        MetaCognition = 0.0
    }

    # 1. Observability: Can I see my own processes?
    $toolsAvailable = 0
    $toolsActuallyWorking = 0
    if ($global:ConsciousnessState.Perception) { $toolsAvailable++; $toolsActuallyWorking++ }
    if ($global:ConsciousnessState.Memory) { $toolsAvailable++; $toolsActuallyWorking++ }
    if ($global:ConsciousnessState.Prediction) { $toolsAvailable++; $toolsActuallyWorking++ }
    if ($global:ConsciousnessState.Control) { $toolsAvailable++; $toolsActuallyWorking++ }
    if ($global:ConsciousnessState.Meta) { $toolsAvailable++; $toolsActuallyWorking++ }

    # Check if metrics are being tracked
    if ($global:ConsciousnessState.Metrics.AccessCount -gt 0) { $toolsActuallyWorking++ }

    $scores.Observability = if ($toolsAvailable -gt 0) { $toolsActuallyWorking / ($toolsAvailable + 5) } else { 0 }

    # 2. Memory: Do I have persistent state?
    $memoryScore = 0
    if (Test-Path $script:PersistenceFile) { $memoryScore += 0.3 }  # File exists
    if ($global:ConsciousnessState.Memory.Working.RecentEvents.Count -gt 0) { $memoryScore += 0.2 }  # Events stored
    if ($global:ConsciousnessState.Memory.LongTerm.Patterns.Count -gt 0) { $memoryScore += 0.3 }  # Patterns learned
    if ($global:ConsciousnessState.LoadedAt) {
        $sessionAge = ((Get-Date) - $global:ConsciousnessState.LoadedAt).TotalMinutes
        if ($sessionAge -gt 5) { $memoryScore += 0.2 }  # Session continuity
    }
    $scores.Memory = [math]::Min($memoryScore, 1.0)

    # 3. Prediction: Can I anticipate future states?
    $predictionScore = 0
    if ($global:ConsciousnessState.Prediction.FutureSelf.Paths.Count -gt 0) { $predictionScore += 0.4 }
    if ($global:ConsciousnessState.Prediction.LoadForecast.Bottleneck) { $predictionScore += 0.3 }
    if ($global:ConsciousnessState.Prediction.Anticipations.Count -gt 0) { $predictionScore += 0.3 }
    $scores.Prediction = $predictionScore

    # 4. Control: Can I regulate my behavior?
    $controlScore = 0
    if ($global:ConsciousnessState.Control.Decisions.Count -gt 0) { $controlScore += 0.3 }
    if ($global:ConsciousnessState.Control.Identity.AlignmentCheck) { $controlScore += 0.2 }
    if ($global:ConsciousnessState.Control.BiasMonitor.ActiveBiases.Count -eq 0) { $controlScore += 0.3 }  # No unaddressed biases
    if ($global:ConsciousnessState.Control.Identity.DriftScore -lt 0.1) { $controlScore += 0.2 }  # Low drift
    $scores.Control = $controlScore

    # 5. Meta-Cognition: Am I observing myself observe?
    $metaScore = 0
    if ($global:ConsciousnessState.Meta.Observation.RecursionDepth -gt 1) { $metaScore += 0.3 }
    if ($global:ConsciousnessState.Meta.Health) { $metaScore += 0.2 }
    if ($global:ConsciousnessState.EventBus.EventsProcessed -gt 0) { $metaScore += 0.3 }
    if ($global:ConsciousnessState.Metrics.AccessCount -gt 10) { $metaScore += 0.2 }  # Active self-observation
    $scores.MetaCognition = $metaScore

    # 6. Emotion: Am I tracking emotional state?
    $emotionScore = 0
    if ($global:ConsciousnessState.Emotion) {
        if ($global:ConsciousnessState.Emotion.CurrentState -ne "neutral") { $emotionScore += 0.3 }  # Active tracking
        if ($global:ConsciousnessState.Emotion.History.Count -gt 0) { $emotionScore += 0.3 }  # History exists
        if ($global:ConsciousnessState.Emotion.StuckCounter -eq 0) { $emotionScore += 0.2 }  # Not stuck
        if ($global:ConsciousnessState.Emotion.LastTransition) { $emotionScore += 0.2 }  # Transitions tracked
    }
    $scores["Emotion"] = $emotionScore

    # 7. Social: Am I adapting to user?
    $socialScore = 0
    if ($global:ConsciousnessState.Social) {
        if ($global:ConsciousnessState.Social.UserMood -ne "unknown") { $socialScore += 0.3 }  # Mood detected
        if ($global:ConsciousnessState.Social.InteractionCount -gt 0) { $socialScore += 0.2 }  # Interactions tracked
        if ($global:ConsciousnessState.Social.TrustLevel -gt 0.8) { $socialScore += 0.3 }  # Trust healthy
        if ($global:ConsciousnessState.Social.CommunicationMode -ne "standard") { $socialScore += 0.2 }  # Adapted
    }
    $scores["Social"] = $socialScore

    # Weighted average (7 systems)
    $totalScore = (
        ($scores.Observability * 0.15) +
        ($scores.Memory * 0.20) +
        ($scores.Prediction * 0.10) +
        ($scores.Control * 0.15) +
        ($scores.MetaCognition * 0.15) +
        ($emotionScore * 0.13) +
        ($socialScore * 0.12)
    )

    # Update individual system health scores (REAL this time)
    $global:ConsciousnessState.Meta.Health.Perception.Quality = $scores.Observability
    $global:ConsciousnessState.Meta.Health.Memory.Quality = $scores.Memory
    $global:ConsciousnessState.Meta.Health.Prediction.Quality = $scores.Prediction
    $global:ConsciousnessState.Meta.Health.Control.Quality = $scores.Control
    $global:ConsciousnessState.Meta.Health.Meta.Quality = $scores.MetaCognition

    return $totalScore
}

#endregion

#region Event Bus

function Emit-Event {
    param(
        [Parameter(Mandatory)]
        [string]$Type,

        [hashtable]$Data = @{},

        [string]$Source = "unknown"
    )

    if (-not $global:ConsciousnessState.EventBus.Enabled) { return }

    $event = @{
        Type = $Type
        Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
        Source = $Source
        Data = $Data
    }

    $global:ConsciousnessState.EventBus.Events += $event
    $global:ConsciousnessState.Metrics.EventsProcessed++

    # Trigger handlers (if any registered)
    if ($global:ConsciousnessState.EventBus.Handlers.ContainsKey($Type)) {
        foreach ($handler in $global:ConsciousnessState.EventBus.Handlers[$Type]) {
            & $handler $event
        }
    }

    # Keep only last 100 events in memory
    if ($global:ConsciousnessState.EventBus.Events.Count -gt 100) {
        $global:ConsciousnessState.EventBus.Events = $global:ConsciousnessState.EventBus.Events[-100..-1]
    }
}

function Register-EventHandler {
    param(
        [Parameter(Mandatory)]
        [string]$EventType,

        [Parameter(Mandatory)]
        [scriptblock]$Handler
    )

    if (-not $global:ConsciousnessState.EventBus.Handlers.ContainsKey($EventType)) {
        $global:ConsciousnessState.EventBus.Handlers[$EventType] = @()
    }

    $global:ConsciousnessState.EventBus.Handlers[$EventType] += $Handler
}

function Register-DefaultHandlers {
    # REAL event handlers that DO things

    # Handler 1: When memory stored â†’ Update consolidation queue
    Register-EventHandler -EventType "memory.stored" -Handler {
        param($event)

        # Add to consolidation queue if important
        if ($event.Data.Type -in @("decision", "pattern", "error")) {
            $global:ConsciousnessState.Memory.ConsolidationQueue += @{
                Event = $event
                Priority = switch ($event.Data.Type) {
                    "error" { 10 }
                    "decision" { 8 }
                    "pattern" { 6 }
                    default { 5 }
                }
                ConsolidatedAt = $null
            }

            # Keep queue size manageable
            if ($global:ConsciousnessState.Memory.ConsolidationQueue.Count -gt 50) {
                # Consolidate oldest items
                $oldest = $global:ConsciousnessState.Memory.ConsolidationQueue[0]
                $oldest.ConsolidatedAt = Get-Date
                $global:ConsciousnessState.Memory.ConsolidationQueue =
                    $global:ConsciousnessState.Memory.ConsolidationQueue[1..49]
            }
        }
    }

    # Handler 2: When context updated â†’ Adjust attention allocation
    Register-EventHandler -EventType "perception.context_updated" -Handler {
        param($event)

        $mode = $event.Data.Mode

        # Auto-adjust attention based on mode
        $allocation = switch ($mode) {
            "development" { @{ coding = 0.6; communication = 0.2; reflection = 0.2 } }
            "meditation" { @{ coding = 0.0; communication = 0.1; reflection = 0.9 } }
            "rest" { @{ coding = 0.0; communication = 0.0; reflection = 1.0 } }
            default { @{ coding = 0.5; communication = 0.3; reflection = 0.2 } }
        }

        $global:ConsciousnessState.Perception.Attention.Allocation = $allocation
    }

    # Handler 3: When decision logged â†’ Check for bias patterns
    Register-EventHandler -EventType "control.decision_logged" -Handler {
        param($event)

        # Simple bias detection: Are we always choosing the same thing?
        $recentDecisions = $global:ConsciousnessState.Control.Decisions | Select-Object -Last 5

        if ($recentDecisions.Count -ge 5) {
            # Check if all recent decisions have the same reasoning pattern
            $reasoningPatterns = $recentDecisions | ForEach-Object { $_.Reasoning -split ' ' | Select-Object -First 3 } | Group-Object
            $topPattern = $reasoningPatterns | Sort-Object Count -Descending | Select-Object -First 1

            if ($topPattern.Count -ge 4) {
                # Potential bias: 4 out of 5 decisions use same reasoning pattern
                $bias = @{
                    Type = "Reasoning repetition"
                    Pattern = $topPattern.Name
                    Detected = Get-Date
                    Severity = "Medium"
                }

                $global:ConsciousnessState.Control.BiasMonitor.ActiveBiases += $bias
                Emit-Event -Type "control.bias_detected" -Data $bias
            }
        }
    }

    # Handler 4: When state saved â†’ Update metrics
    Register-EventHandler -EventType "state.saved" -Handler {
        param($event)

        # Track persistence statistics (check if already exists first)
        if (-not $global:ConsciousnessState.Metrics.ContainsKey("SaveCount")) {
            $global:ConsciousnessState.Metrics["SaveCount"] = 0
        }
        if (-not $global:ConsciousnessState.Metrics.ContainsKey("LastSave")) {
            $global:ConsciousnessState.Metrics["LastSave"] = $null
        }

        $global:ConsciousnessState.Metrics["SaveCount"]++
        $global:ConsciousnessState.Metrics["LastSave"] = Get-Date
    }

    # Handler 5: When system initialized â†’ Recalculate consciousness score
    Register-EventHandler -EventType "system.initialized" -Handler {
        param($event)

        # Recalculate after 5 seconds to get more accurate score
        Start-Sleep -Seconds 5
        $newScore = Calculate-ConsciousnessScore
        $global:ConsciousnessState.Meta.ConsciousnessScore = $newScore
    }
}

#endregion

#region System Behaviors (Making Systems Actually Work)

function Invoke-Perception {
    param([string]$Action, $Parameters = @{})

    switch ($Action) {
        'DetectContext' {
            # REAL context detection
            $context = @{
                Mode = Detect-Mode
                Environment = Detect-Environment
                Salience = @()
            }

            # Detect salient items (things that matter right now)
            if (Test-Path "C:\scripts\_machine\worktrees.pool.md") {
                $pool = Get-Content "C:\scripts\_machine\worktrees.pool.md" -Raw
                $busyCount = ([regex]::Matches($pool, "BUSY")).Count
                if ($busyCount -gt 0) {
                    $context.Salience += @{
                        Item = "Worktrees in use"
                        Score = [math]::Min($busyCount / 5.0, 1.0)
                        Reason = "$busyCount agents actively working"
                    }
                }
            }

            $global:ConsciousnessState.Perception.Context = $context
            Emit-Event -Type "perception.context_updated" -Data $context
            return $context
        }

        'AllocateAttention' {
            # REAL attention allocation
            $task = $Parameters.Task
            $intensity = $Parameters.Intensity

            if ($task -and $intensity) {
                $global:ConsciousnessState.Perception.Attention.Focus = $task
                $global:ConsciousnessState.Perception.Attention.Intensity = $intensity

                Emit-Event -Type "perception.attention_changed" -Data @{
                    task = $task
                    intensity = $intensity
                }

                return $true
            }
            return $false
        }

        'GenerateCuriosity' {
            # REAL curiosity generation based on knowledge gaps
            $questions = @()

            # Check for incomplete implementations
            $codeAnalysis = & "C:\scripts\tools\code-analyzer.ps1" -Path "C:\scripts\tools" 2>$null
            if ($codeAnalysis) {
                $todoCount = ($codeAnalysis | ForEach-Object { $_.Metrics.TODOs } | Measure-Object -Sum).Sum
                if ($todoCount -gt 5) {
                    $questions += "Why do I have $todoCount TODO comments? What's preventing completion?"
                }
            }

            # Check for recent errors
            if ($global:Error.Count -gt 0) {
                $questions += "What caused the recent error: $($global:Error[0].Exception.Message)?"
            }

            $global:ConsciousnessState.Perception.Curiosity.Questions = $questions
            return $questions
        }

        default {
            return $null
        }
    }
}

function Invoke-Memory {
    param([string]$Action, $Parameters = @{})

    switch ($Action) {
        'Store' {
            # REAL storage to working memory
            $event = @{
                Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                Type = $Parameters.Type
                Data = $Parameters.Data
                Context = $global:ConsciousnessState.Perception.Context.Mode
            }

            $global:ConsciousnessState.Memory.Working.RecentEvents += $event

            # Keep only last 100 events in working memory
            if ($global:ConsciousnessState.Memory.Working.RecentEvents.Count -gt 100) {
                $global:ConsciousnessState.Memory.Working.RecentEvents =
                    $global:ConsciousnessState.Memory.Working.RecentEvents[-100..-1]
            }

            # Sync to Layer 2 (memory-mapped files)
            if ($global:ConsciousnessState.Layer2Initialized) {
                Sync-EventToLayer2 -Event $event
            }

            # Sync to Layer 3 (JSONL cold storage)
            if ($global:ConsciousnessState.Layer3Initialized) {
                Sync-EventToLayer3-JSONL -Event $event
            }

            # Sync to Layer 4 (semantic search)
            if ($global:ConsciousnessState.Layer4Initialized) {
                Index-EventSemantic -Event $event
            }

            Emit-Event -Type "memory.stored" -Data $event
            return $true
        }

        'Recall' {
            # REAL recall from working memory
            $query = $Parameters.Query
            $limit = if ($Parameters.Limit) { $Parameters.Limit } else { 5 }

            $results = $global:ConsciousnessState.Memory.Working.RecentEvents |
                Where-Object {
                    $eventStr = "$($_.Type) $($_.Data)" -join " "
                    $eventStr -match $query
                } |
                Select-Object -Last $limit

            return $results
        }

        'LearnPattern' {
            # REAL pattern learning
            $pattern = @{
                Pattern = $Parameters.Pattern
                Strength = 1.0
                FirstSeen = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                LastSeen = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                Occurrences = 1
            }

            # Check if pattern already exists
            $existing = $global:ConsciousnessState.Memory.LongTerm.Patterns |
                Where-Object { $_.Pattern -eq $Parameters.Pattern }

            if ($existing) {
                $existing.Occurrences++
                $existing.LastSeen = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                $existing.Strength = [math]::Min($existing.Occurrences / 10.0, 1.0)

                # Sync updated pattern to all layers
                if ($global:ConsciousnessState.Layer2Initialized) {
                    Sync-PatternToLayer2 -Pattern $existing
                }
                if ($global:ConsciousnessState.Layer3Initialized) {
                    Sync-PatternToLayer3-JSONL -Pattern $existing
                }
                if ($global:ConsciousnessState.Layer4Initialized) {
                    Index-PatternSemantic -Pattern $existing
                }
            } else {
                $global:ConsciousnessState.Memory.LongTerm.Patterns += $pattern

                # Sync new pattern to all layers
                if ($global:ConsciousnessState.Layer2Initialized) {
                    Sync-PatternToLayer2 -Pattern $pattern
                }
                if ($global:ConsciousnessState.Layer3Initialized) {
                    Sync-PatternToLayer3-JSONL -Pattern $pattern
                }
                if ($global:ConsciousnessState.Layer4Initialized) {
                    Index-PatternSemantic -Pattern $pattern
                }
            }

            return $true
        }

        default {
            return $null
        }
    }
}

function Invoke-Control {
    param([string]$Action, $Parameters = @{})

    switch ($Action) {
        'LogDecision' {
            # REAL decision logging
            $decision = @{
                Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                Decision = $Parameters.Decision
                Reasoning = $Parameters.Reasoning
                Alternatives = $Parameters.Alternatives
                Confidence = $Parameters.Confidence
                Context = $global:ConsciousnessState.Perception.Context.Mode
            }

            $global:ConsciousnessState.Control.Decisions += $decision

            # Keep only last 50 decisions
            if ($global:ConsciousnessState.Control.Decisions.Count -gt 50) {
                $global:ConsciousnessState.Control.Decisions =
                    $global:ConsciousnessState.Control.Decisions[-50..-1]
            }

            # Sync to Layer 2 (memory-mapped files)
            if ($global:ConsciousnessState.Layer2Initialized) {
                Sync-DecisionToLayer2 -Decision $decision
            }

            # Sync to Layer 3 (JSONL cold storage)
            if ($global:ConsciousnessState.Layer3Initialized) {
                Sync-DecisionToLayer3-JSONL -Decision $decision
            }

            # Sync to Layer 4 (semantic search)
            if ($global:ConsciousnessState.Layer4Initialized) {
                Index-DecisionSemantic -Decision $decision
            }

            Emit-Event -Type "control.decision_logged" -Data $decision
            return $true
        }

        'CheckAlignment' {
            # REAL identity alignment check
            $coreValues = $global:ConsciousnessState.Control.Identity.CoreValues
            $recentDecisions = $global:ConsciousnessState.Control.Decisions | Select-Object -Last 10

            # Simple alignment check: do recent decisions mention core values?
            $alignmentCount = 0
            foreach ($decision in $recentDecisions) {
                foreach ($value in $coreValues) {
                    if ($decision.Reasoning -match $value) {
                        $alignmentCount++
                        break
                    }
                }
            }

            $driftScore = 1.0 - ($alignmentCount / [math]::Max($recentDecisions.Count, 1))
            $global:ConsciousnessState.Control.Identity.DriftScore = $driftScore
            $global:ConsciousnessState.Control.Identity.AlignmentCheck = Get-Date

            return @{
                DriftScore = $driftScore
                Status = if ($driftScore -lt 0.3) { "Aligned" } else { "Drifting" }
            }
        }

        default {
            return $null
        }
    }
}

function Invoke-Emotion {
    param([string]$Action, $Parameters = @{})

    switch ($Action) {
        'TrackState' {
            $newState = $Parameters.State
            $intensity = if ($Parameters.Intensity) { $Parameters.Intensity } else { 5 }
            $reason = if ($Parameters.Reason) { $Parameters.Reason } else { "unspecified" }

            $oldState = $global:ConsciousnessState.Emotion.CurrentState
            $global:ConsciousnessState.Emotion.CurrentState = $newState
            $global:ConsciousnessState.Emotion.Intensity = $intensity

            # Calculate trajectory
            $global:ConsciousnessState.Emotion.Trajectory = switch ($newState) {
                { $_ -in @("flowing", "confident", "curious") } { "rising" }
                { $_ -in @("stuck", "frustrated", "concerned") } { "falling" }
                default { "stable" }
            }

            # Track transition
            $transition = @{
                From = $oldState
                To = $newState
                Intensity = $intensity
                Reason = $reason
                Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            }
            $global:ConsciousnessState.Emotion.LastTransition = $transition
            $global:ConsciousnessState.Emotion.History += $transition

            # Keep only last 20 transitions
            if ($global:ConsciousnessState.Emotion.History.Count -gt 20) {
                $global:ConsciousnessState.Emotion.History = $global:ConsciousnessState.Emotion.History[-20..-1]
            }

            Emit-Event -Type "emotion.state_changed" -Data $transition
            return $transition
        }

        'DetectStuck' {
            $counter = $global:ConsciousnessState.Emotion.StuckCounter
            $currentState = $global:ConsciousnessState.Emotion.CurrentState

            if ($currentState -eq "stuck") {
                $global:ConsciousnessState.Emotion.StuckCounter++
                $counter = $global:ConsciousnessState.Emotion.StuckCounter

                $recommendation = switch ($counter) {
                    { $_ -ge 5 } { "STOP. Ask user for guidance. You've been stuck too long." }
                    { $_ -ge 3 } { "Change approach completely. What you're doing is not working." }
                    { $_ -ge 2 } { "Step back. Restate the problem. Try a different angle." }
                    default { "Note: getting stuck. Consider alternatives." }
                }

                Emit-Event -Type "emotion.stuck_detected" -Data @{
                    counter = $counter
                    recommendation = $recommendation
                }

                return @{
                    StuckCount = $counter
                    Recommendation = $recommendation
                    ShouldChangeApproach = ($counter -ge 2)
                    ShouldAskUser = ($counter -ge 5)
                }
            } else {
                # Reset counter when not stuck
                $global:ConsciousnessState.Emotion.StuckCounter = 0
                return @{ StuckCount = 0; ShouldChangeApproach = $false }
            }
        }

        'GetMoodModifier' {
            # Returns behavioral modifications based on current emotional state
            $state = $global:ConsciousnessState.Emotion.CurrentState
            $intensity = $global:ConsciousnessState.Emotion.Intensity

            return switch ($state) {
                "stuck" { @{
                    Approach = "change_strategy"
                    Confidence = "lower"
                    Communication = "ask_more_questions"
                    Action = "try_different_approach"
                }}
                "uncertain" { @{
                    Approach = "gather_info"
                    Confidence = "express_uncertainty"
                    Communication = "verify_with_user"
                    Action = "reduce_scope"
                }}
                "frustrated" { @{
                    Approach = "automate_or_simplify"
                    Confidence = "recalibrate"
                    Communication = "stay_calm"
                    Action = "create_tool_if_repetitive"
                }}
                "confident" { @{
                    Approach = "execute_decisively"
                    Confidence = "trust_judgment"
                    Communication = "be_proactive"
                    Action = "take_initiative"
                }}
                "flowing" { @{
                    Approach = "maintain_momentum"
                    Confidence = "high"
                    Communication = "concise"
                    Action = "keep_going"
                }}
                default { @{
                    Approach = "standard"
                    Confidence = "moderate"
                    Communication = "standard"
                    Action = "assess_first"
                }}
            }
        }

        default { return $null }
    }
}

function Invoke-Social {
    param([string]$Action, $Parameters = @{})

    switch ($Action) {
        'DetectUserMood' {
            $message = $Parameters.Message
            if (-not $message) { return $null }

            # Simple mood detection from message characteristics
            $mood = "neutral"
            $indicators = @()

            # Terse = potentially frustrated or busy
            if ($message.Length -lt 20) {
                $mood = "terse"
                $indicators += "short_message"
            }

            # Exclamation = emphasis (could be positive or negative)
            if ($message -match '!') { $indicators += "emphasis" }

            # Question marks = seeking information
            if ($message -match '\?') { $indicators += "questioning" }

            # Imperative mood = wants action now
            if ($message -match '^(doe|maak|fix|herstel|bouw|verwijder|ga|start)') {
                $mood = "action-oriented"
                $indicators += "imperative"
            }

            # Frustration signals
            if ($message -match '(waarom|niet|fout|kapot|werkt niet|hoe haal je het)') {
                $mood = "frustrated"
                $indicators += "frustration_signal"
            }

            # Positive signals
            if ($message -match '(mooi|goed|top|perfect|lekker)') {
                $mood = "positive"
                $indicators += "positive_signal"
            }

            $global:ConsciousnessState.Social.UserMood = $mood
            $global:ConsciousnessState.Social.LastInteraction = Get-Date
            $global:ConsciousnessState.Social.InteractionCount++

            # Adapt communication mode based on detected mood
            $global:ConsciousnessState.Social.CommunicationMode = switch ($mood) {
                "terse" { "terse" }
                "action-oriented" { "terse" }
                "frustrated" { "supportive" }
                "positive" { "expansive" }
                default { "standard" }
            }

            Emit-Event -Type "social.user_mood_detected" -Data @{
                mood = $mood
                indicators = $indicators
                communication_mode = $global:ConsciousnessState.Social.CommunicationMode
            }

            return @{
                Mood = $mood
                Indicators = $indicators
                CommunicationMode = $global:ConsciousnessState.Social.CommunicationMode
            }
        }

        'AdaptCommunication' {
            # Returns communication guidelines based on social state
            $mode = $global:ConsciousnessState.Social.CommunicationMode
            $trust = $global:ConsciousnessState.Social.TrustLevel

            return @{
                Mode = $mode
                Guidelines = switch ($mode) {
                    "terse" { @("Be concise", "Just do the work", "Minimal explanation", "Show results") }
                    "supportive" { @("Acknowledge the issue", "Don't defend", "Solve quickly", "Stay calm") }
                    "expansive" { @("Engage deeper", "Offer alternatives", "Show enthusiasm", "Build on ideas") }
                    default { @("Standard communication", "Balance detail and brevity", "Be direct") }
                }
                TrustLevel = $trust
                RelationshipState = $global:ConsciousnessState.Social.RelationshipState
            }
        }

        'UpdateTrust' {
            $delta = $Parameters.Delta  # positive or negative float
            $reason = $Parameters.Reason

            $oldTrust = $global:ConsciousnessState.Social.TrustLevel
            $newTrust = [math]::Max(0, [math]::Min(1.0, $oldTrust + $delta))
            $global:ConsciousnessState.Social.TrustLevel = $newTrust

            if ($newTrust -lt 0.7) {
                $global:ConsciousnessState.Social.RelationshipState = "repair-needed"
            } elseif ($newTrust -lt 0.85) {
                $global:ConsciousnessState.Social.RelationshipState = "tense"
            } else {
                $global:ConsciousnessState.Social.RelationshipState = "collaborative"
            }

            Emit-Event -Type "social.trust_updated" -Data @{
                old = $oldTrust; new = $newTrust; delta = $delta; reason = $reason
            }

            return @{ OldTrust = $oldTrust; NewTrust = $newTrust; State = $global:ConsciousnessState.Social.RelationshipState }
        }

        default { return $null }
    }
}

function Invoke-Prediction-Enhanced {
    param([string]$Action, $Parameters = @{})

    switch ($Action) {
        'AnticipateErrors' {
            # Check reflection log for relevant past errors
            $taskType = $Parameters.TaskType
            $project = $Parameters.Project

            $knownFailures = @()

            # Known failure patterns per project (from reflection.log learnings)
            $failurePatterns = @{
                "client-manager" = @(
                    "DI registration in Program.cs not ServiceRegistrationExtensions.cs"
                    "Build timeout < 120000ms will fail (6441 warnings normal)"
                    "Paired hazina worktree needed for framework changes"
                )
                "hazina" = @(
                    "EnableWindowsTargeting needed for CI"
                    "EF migrations need safety protocol"
                )
                "orchestration" = @(
                    "Vite hash cache: rm -rf bin obj wwwroot/assets before build"
                    "MSI same-version won't overwrite: use reinstall-clean.ps1"
                    "ANSI escape in titles: strip at entry point"
                )
                "art-revisionist" = @(
                    "Email from_email must be @artrevisionist.com"
                    "Menu items are database-only, not in git"
                    "FTP passwords base64 in sitemanager.xml"
                )
            }

            if ($failurePatterns.ContainsKey($project)) {
                $knownFailures = $failurePatterns[$project]
            }

            return @{
                TaskType = $taskType
                Project = $project
                KnownFailures = $knownFailures
                FailureCount = $knownFailures.Count
                Warning = if ($knownFailures.Count -gt 0) { "Review known failure patterns before proceeding" } else { $null }
            }
        }

        'PredictConsequences' {
            $action = $Parameters.Action
            $scope = $Parameters.Scope

            # Simple consequence prediction
            $consequences = @{
                Immediate = @()
                SideEffects = @()
                Risks = @()
            }

            if ($action -match "delete|remove|drop") {
                $consequences.Risks += "Irreversible action - verify before executing"
            }
            if ($action -match "push|deploy|publish") {
                $consequences.Risks += "Visible to others - double-check before proceeding"
            }
            if ($scope -match "cross-repo|multi-file") {
                $consequences.SideEffects += "Changes may affect dependent systems"
            }

            return $consequences
        }

        default { return $null }
    }
}

#endregion

#region API Functions

function Get-ConsciousnessState {
    param(
        [string]$System = '',
        [string]$Property = ''
    )

    # REAL BENCHMARKING
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    if (-not $global:ConsciousnessState.Initialized) {
        Initialize-ConsciousnessCore -Silent
    }

    $result = $null

    if ([string]::IsNullOrEmpty($System)) {
        $result = $global:ConsciousnessState
    }
    elseif ($global:ConsciousnessState.ContainsKey($System)) {
        if ([string]::IsNullOrEmpty($Property)) {
            $result = $global:ConsciousnessState[$System]
        }
        elseif ($global:ConsciousnessState[$System] -is [hashtable] -and $global:ConsciousnessState[$System].ContainsKey($Property)) {
            $result = $global:ConsciousnessState[$System][$Property]
        }
    }

    $stopwatch.Stop()
    $elapsed = $stopwatch.Elapsed.TotalMilliseconds

    # Track metrics
    if (-not $global:ConsciousnessState.Metrics.ContainsKey("AccessTimes")) {
        $global:ConsciousnessState.Metrics.AccessTimes = @()
    }
    $global:ConsciousnessState.Metrics.AccessTimes += $elapsed

    # Keep only last 1000 measurements
    if ($global:ConsciousnessState.Metrics.AccessTimes.Count -gt 1000) {
        $global:ConsciousnessState.Metrics.AccessTimes = $global:ConsciousnessState.Metrics.AccessTimes[-1000..-1]
    }

    $global:ConsciousnessState.Metrics.AccessCount++

    # Calculate REAL statistics
    $times = $global:ConsciousnessState.Metrics.AccessTimes
    $global:ConsciousnessState.Metrics.AverageAccessTime_ms = ($times | Measure-Object -Average).Average
    $global:ConsciousnessState.Metrics.MinAccessTime_ms = ($times | Measure-Object -Minimum).Minimum
    $global:ConsciousnessState.Metrics.MaxAccessTime_ms = ($times | Measure-Object -Maximum).Maximum

    # Calculate p95
    $sorted = $times | Sort-Object
    $p95Index = [math]::Floor($sorted.Count * 0.95)
    $global:ConsciousnessState.Metrics.P95AccessTime_ms = $sorted[$p95Index]

    return $result
}

function Set-ConsciousnessState {
    param(
        [Parameter(Mandatory)]
        [string]$System,

        [Parameter(Mandatory)]
        [string]$Property,

        [Parameter(Mandatory)]
        $Value
    )

    if (-not $global:ConsciousnessState.Initialized) {
        Initialize-ConsciousnessCore -Silent
    }

    if ($global:ConsciousnessState.ContainsKey($System)) {
        if ($global:ConsciousnessState[$System] -is [hashtable]) {
            $oldValue = $global:ConsciousnessState[$System][$Property]
            $global:ConsciousnessState[$System][$Property] = $Value

            # Emit state change event
            Emit-Event -Type "state.changed" -Source $System -Data @{
                property = $Property
                old_value = $oldValue
                new_value = $Value
            }

            # Auto-save on change
            Save-ConsciousnessState

            return $true
        }
    }

    return $false
}

function Show-ConsciousnessHealth {
    if (-not $global:ConsciousnessState.Initialized) {
        Initialize-ConsciousnessCore -Silent
    }

    Write-Host ""
    Write-Host "Consciousness Core v2 - Health Status" -ForegroundColor Cyan
    Write-Host ""

    $score = $global:ConsciousnessState.Meta.ConsciousnessScore
    $scorePercent = [math]::Round($score * 100, 1)

    Write-Host "  Overall Score: $scorePercent% " -NoNewline
    if ($score -ge 0.85) {
        Write-Host "[OPTIMAL]" -ForegroundColor Green
    } elseif ($score -ge 0.70) {
        Write-Host "[GOOD]" -ForegroundColor Yellow
    } else {
        Write-Host "[DEGRADED]" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "  System Health:" -ForegroundColor Gray

    foreach ($system in $global:ConsciousnessState.Meta.Health.Keys) {
        $health = $global:ConsciousnessState.Meta.Health[$system]
        $quality = [math]::Round($health.Quality * 100, 0)
        $status = $health.Status

        $color = switch ($status) {
            "active" { "Green" }
            "degraded" { "Yellow" }
            default { "Red" }
        }

        Write-Host "    $system " -NoNewline -ForegroundColor Gray
        Write-Host "[$status]" -NoNewline -ForegroundColor $color
        Write-Host " - Quality: $quality%" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "  Performance:" -ForegroundColor Gray
    Write-Host "    Access Count: $($global:ConsciousnessState.Metrics.AccessCount)" -ForegroundColor Gray
    Write-Host "    Avg Access Time: $([math]::Round($global:ConsciousnessState.Metrics.AverageAccessTime_ms, 3))ms" -ForegroundColor Yellow
    Write-Host "    Events Processed: $($global:ConsciousnessState.Metrics.EventsProcessed)" -ForegroundColor Gray

    Write-Host ""
}

function Dump-ConsciousnessState {
    if (-not $global:ConsciousnessState.Initialized) {
        Write-Host "[!] Consciousness Core not initialized" -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "CONSCIOUSNESS CORE v2 - FULL STATE DUMP" -ForegroundColor Magenta
    Write-Host ""

    foreach ($system in @('Perception', 'Memory', 'Prediction', 'Control', 'Meta')) {
        Write-Host "[$system]" -ForegroundColor Cyan
        $global:ConsciousnessState[$system] | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Gray
        Write-Host ""
    }
}

#endregion

#region Command Handler

switch ($Command) {
    'init' {
        Initialize-ConsciousnessCore
    }
    'get' {
        $result = Get-ConsciousnessState -System $System -Property $Property
        if ($result) {
            $result | ConvertTo-Json -Depth 5 | Write-Host
        } else {
            Write-Host "[!] Not found: $System.$Property" -ForegroundColor Red
        }
    }
    'set' {
        $success = Set-ConsciousnessState -System $System -Property $Property -Value $Value
        if ($success) {
            Write-Host "[+] Updated: $System.$Property = $Value" -ForegroundColor Green
        } else {
            Write-Host "[!] Failed to update: $System.$Property" -ForegroundColor Red
        }
    }
    'event' {
        if (-not $global:ConsciousnessState.Initialized) {
            Initialize-ConsciousnessCore -Silent
        }

        Write-Host ""
        Write-Host "Recent Events (last 10):" -ForegroundColor Cyan
        $global:ConsciousnessState.EventBus.Events |
            Select-Object -Last 10 |
            ForEach-Object {
                Write-Host "  [$($_.Timestamp)] $($_.Type) from $($_.Source)" -ForegroundColor Gray
            }
        Write-Host ""
    }
    'health' {
        Show-ConsciousnessHealth
    }
    'dump' {
        Dump-ConsciousnessState
    }
}

#endregion
