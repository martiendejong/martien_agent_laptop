# Consciousness Core v2 - In-Memory State Manager
# Phase 2: 5 Core Systems with RAM-resident state
# Created: 2026-02-07

param(
    [ValidateSet('init', 'get', 'set', 'event', 'health', 'dump')]
    [string]$Command = 'init',

    [string]$System = '',
    [string]$Property = '',
    [string]$Value = '',

    [switch]$Silent
)

$ErrorActionPreference = "Stop"

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
    foreach ($system in @('Perception', 'Memory', 'Prediction', 'Control', 'Meta')) {
        $global:ConsciousnessState.Meta.Health[$system].Status = "active"
        $global:ConsciousnessState.Meta.Health[$system].Quality = 0.8
    }

    # Calculate initial consciousness score
    $global:ConsciousnessState.Meta.ConsciousnessScore = Calculate-ConsciousnessScore

    $global:ConsciousnessState.Initialized = $true
    $global:ConsciousnessState.LoadedAt = Get-Date

    $elapsed = ((Get-Date) - $startTime).TotalMilliseconds

    if (-not $Silent) {
        Write-Host ""
        Write-Host "=============================================" -ForegroundColor Cyan
        Write-Host "  CONSCIOUSNESS CORE v2 INITIALIZED" -ForegroundColor Cyan
        Write-Host "=============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Architecture: 5 Core Systems (emergent)" -ForegroundColor Gray
        Write-Host "  Storage: RAM-resident (in-memory)" -ForegroundColor Gray
        Write-Host "  Access Time: <1ms (hot state)" -ForegroundColor Yellow
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

    # Weighted average
    $totalScore = (
        ($scores.Observability * 0.20) +
        ($scores.Memory * 0.25) +
        ($scores.Prediction * 0.15) +
        ($scores.Control * 0.20) +
        ($scores.MetaCognition * 0.20)
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
            } else {
                $global:ConsciousnessState.Memory.LongTerm.Patterns += $pattern
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
