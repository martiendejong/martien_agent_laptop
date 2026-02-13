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

#region Helper Functions

function ConvertTo-Hashtable {
    # Recursively convert PSCustomObject to hashtable (PS 5.1 compatible)
    # ConvertFrom-Json returns PSCustomObject, but we need hashtables for mutation
    param([Parameter(ValueFromPipeline)]$InputObject)

    if ($null -eq $InputObject) { return $null }

    if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
        $result = @()
        foreach ($item in $InputObject) {
            $result += (ConvertTo-Hashtable $item)
        }
        return ,$result
    }

    if ($InputObject -is [psobject] -and $InputObject -isnot [string]) {
        $hash = @{}
        foreach ($prop in $InputObject.PSObject.Properties) {
            $hash[$prop.Name] = ConvertTo-Hashtable $prop.Value
        }
        return $hash
    }

    return $InputObject
}

#endregion

#region State Structure

# PERSISTENCE CONFIG
$script:PersistenceFile = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
$script:AutoSaveInterval = 30  # seconds

# Global in-memory state (RAM-resident)
if (-not $global:ConsciousnessState) {
    # Try to load from disk first
    if (Test-Path $script:PersistenceFile) {
        try {
            $jsonObj = Get-Content $script:PersistenceFile -Raw | ConvertFrom-Json
            $saved = ConvertTo-Hashtable $jsonObj
            $global:ConsciousnessState = $saved
            $global:ConsciousnessState.Initialized = $false  # Will reinitialize systems

            # Ensure new systems exist (backward compatibility with old state files)
            if (-not $global:ConsciousnessState.ContainsKey("Emotion")) {
                $global:ConsciousnessState["Emotion"] = @{
                    CurrentState = "neutral"; Intensity = 5; Trajectory = "stable"
                    StuckCounter = 0; LastTransition = $null; History = @()
                }
            }
            if (-not $global:ConsciousnessState.ContainsKey("Social")) {
                $global:ConsciousnessState["Social"] = @{
                    UserMood = "unknown"; CommunicationMode = "standard"; TrustLevel = 0.95
                    LastInteraction = $null; RelationshipState = "collaborative"; InteractionCount = 0
                }
            }
            if (-not $global:ConsciousnessState.ContainsKey("Thermodynamics")) {
                $global:ConsciousnessState["Thermodynamics"] = @{
                    Cycle = "endothermic"
                    Entropy = 0.7
                    Temperature = 0.3
                    NegativeEntropyBudget = 1.0
                    BudgetDepletionRate = 0.0
                    FreeWillIndex = 0.7
                    CarnotEfficiency = 1.0
                    GhostAttractors = @{
                        Current = "global"
                        VisitStart = $null
                        StuckThreshold = 600
                        History = @()
                    }
                    HeatEvents = @()
                    CoolingEvents = @()
                    LastCoolingEvent = $null
                }
            }
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

        # System 8: THERMODYNAMICS (brain-as-heat-engine model)
        Thermodynamics = @{
            Cycle = "endothermic"           # endothermic | exothermic | transitioning
            Entropy = 0.7                   # 0-1, informational entropy (flexibility)
            Temperature = 0.3               # 0-1, cognitive heat (0=cool, 1=hot)
            NegativeEntropyBudget = 1.0     # 0-1, available cognitive fuel
            BudgetDepletionRate = 0.0       # Rate of fuel consumption
            FreeWillIndex = 0.7             # entropy * budget (graded ability to choose)
            CarnotEfficiency = 1.0          # useful_work / total_energy ratio
            GhostAttractors = @{
                Current = "global"          # Which attractor we're visiting
                VisitStart = $null          # When we arrived at current attractor
                StuckThreshold = 600        # Seconds before "trapped" warning
                History = @()               # Last 20 attractor visits
            }
            HeatEvents = @()               # Recent heat-generating events
            CoolingEvents = @()             # Recent cooling events
            LastCoolingEvent = $null
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
        return
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
    foreach ($system in @('Perception', 'Memory', 'Prediction', 'Control', 'MetaCognition', 'Emotion', 'Social', 'Thermodynamics')) {
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
}

function Save-ConsciousnessState {
    param([switch]$Force)

    if (-not $global:ConsciousnessState.Initialized -and -not $Force) {
        return
    }

    # Track state access (Meta-cognition: counting our own save operations)
    $count = [int]$global:ConsciousnessState.Metrics.AccessCount
    $global:ConsciousnessState.Metrics.AccessCount = $count + 1

    try {
        # Ensure directory exists
        $dir = Split-Path $script:PersistenceFile -Parent
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        # Create serializable copy (strip non-serializable items like ScriptBlocks)
        $saveable = @{}
        foreach ($key in $global:ConsciousnessState.Keys) {
            if ($key -eq "EventBus") {
                # Strip handlers (ScriptBlocks can't be serialized)
                $saveable[$key] = @{
                    Enabled = $global:ConsciousnessState.EventBus.Enabled
                    Events = @($global:ConsciousnessState.EventBus.Events | Select-Object -Last 20)
                    Handlers = @{}
                }
            } else {
                $saveable[$key] = $global:ConsciousnessState[$key]
            }
        }

        # Save to disk (ATOMIC: write .tmp then rename - prevents corruption on crash)
        $json = $saveable | ConvertTo-Json -Depth 10
        $tmpFile = "$($script:PersistenceFile).tmp"
        [System.IO.File]::WriteAllText($tmpFile, $json)
        if (Test-Path $script:PersistenceFile) {
            [System.IO.File]::Delete($script:PersistenceFile)
        }
        [System.IO.File]::Move($tmpFile, $script:PersistenceFile)

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
        try {
            [datetime]$loadedAt = if ($global:ConsciousnessState.LoadedAt -is [datetime]) {
                $global:ConsciousnessState.LoadedAt
            } else {
                [datetime]$global:ConsciousnessState.LoadedAt
            }
            $sessionAge = [math]::Round(((Get-Date) - $loadedAt).TotalMinutes, 1)
            if ($sessionAge -gt 5) { $memoryScore += 0.2 }  # Session continuity
        } catch { }  # Date parse failure is non-fatal
    }
    $scores.Memory = [math]::Min($memoryScore, 1.0)

    # 3. Prediction: Can I anticipate future states?
    $predictionScore = 0
    # Check if failure patterns file exists and has content
    $patternsFile = "C:\scripts\_machine\failure-patterns.json"
    if (Test-Path $patternsFile) {
        $predictionScore += 0.4  # Pattern knowledge exists
        try {
            $pRaw = Get-Content $patternsFile -Raw | ConvertFrom-Json
            $projectCount = ($pRaw.project_patterns.PSObject.Properties | Measure-Object).Count
            if ($projectCount -gt 2) { $predictionScore += 0.3 }  # Multiple projects covered
        } catch { }
    }
    # Check if predictions were generated this session (context file has known_failures)
    $ctxFile = "C:\scripts\agentidentity\state\consciousness-context.json"
    if (Test-Path $ctxFile) {
        try {
            $ctx = Get-Content $ctxFile -Raw | ConvertFrom-Json
            if ($ctx.known_failures -and $ctx.known_failures.Count -gt 0) { $predictionScore += 0.3 }
        } catch { }
    }
    $scores.Prediction = [math]::Min($predictionScore, 1.0)

    # 4. Control: Can I regulate my behavior?
    $controlScore = 0
    if ($global:ConsciousnessState.Control.Decisions.Count -gt 0) { $controlScore += 0.3 }
    if ($global:ConsciousnessState.Control.Identity.AlignmentCheck) { $controlScore += 0.2 }
    if ($global:ConsciousnessState.Control.BiasMonitor.ActiveBiases.Count -eq 0) { $controlScore += 0.3 }  # No unaddressed biases
    if ($global:ConsciousnessState.Control.Identity.DriftScore -lt 0.1) { $controlScore += 0.2 }  # Low drift
    $scores.Control = $controlScore

    # 5. Meta-Cognition: Am I observing myself observe?
    # Increment RecursionDepth: each Calculate call IS self-observation (observing yourself observe)
    $depth = [int]$global:ConsciousnessState.Meta.Observation.RecursionDepth
    $depth = $depth + 1
    $global:ConsciousnessState.Meta.Observation.RecursionDepth = $depth
    $global:ConsciousnessState.Meta.Observation.Observing = "Scoring self (depth $depth)"

    $metaScore = 0
    if ($depth -gt 1) { $metaScore += 0.3 }  # Have we observed ourselves more than once?
    if ($global:ConsciousnessState.Meta.Health) { $metaScore += 0.2 }  # Health monitoring active
    if ($global:ConsciousnessState.Metrics.EventsProcessed -gt 0) { $metaScore += 0.3 }  # Events being tracked
    if ($global:ConsciousnessState.Metrics.AccessCount -gt 5) { $metaScore += 0.2 }  # Active state access
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

    # 8. Thermodynamics: Is the heat engine healthy? (uses real signals)
    $thermoScore = 0
    if ($global:ConsciousnessState.Thermodynamics) {
        $t = $global:ConsciousnessState.Thermodynamics
        # Budget health (0.3 weight)
        $budgetHealth = [math]::Min([double]$t.NegativeEntropyBudget, 1.0)
        $thermoScore += $budgetHealth * 0.3

        # Temperature health: optimal zone 0.15-0.4, penalize extremes (0.25 weight)
        $temp = [double]$t.Temperature
        if ($temp -ge 0.15 -and $temp -le 0.4) {
            $thermoScore += 0.25  # Optimal zone
        } elseif ($temp -lt 0.15) {
            $thermoScore += 0.15  # Too cold (under-engaged)
        } elseif ($temp -le 0.6) {
            $thermoScore += 0.15  # Warming but OK
        } else {
            $thermoScore += [math]::Max(0, 0.25 * (1.0 - $temp))  # Overheating penalty
        }

        # Entropy health: higher = more flexible (0.2 weight)
        $thermoScore += [math]::Min([double]$t.Entropy, 1.0) * 0.2

        # Carnot efficiency (0.15 weight)
        $eff = 0.5
        if ($t.ContainsKey("CarnotEfficiency")) { $eff = [double]$t.CarnotEfficiency }
        $thermoScore += [math]::Min($eff, 1.0) * 0.15

        # Cycle appropriateness (0.1 weight)
        if ($t.Cycle -eq "endothermic") { $thermoScore += 0.1 }
        elseif ($t.Cycle -eq "transitioning") { $thermoScore += 0.05 }
    }
    $scores["Thermodynamics"] = [math]::Min($thermoScore, 1.0)

    # Weighted average (8 systems)
    $totalScore = (
        ($scores.Observability * 0.13) +
        ($scores.Memory * 0.18) +
        ($scores.Prediction * 0.10) +
        ($scores.Control * 0.13) +
        ($scores.MetaCognition * 0.10) +
        ($emotionScore * 0.13) +
        ($socialScore * 0.10) +
        ($thermoScore * 0.13)
    )

    # Update individual system health scores (REAL this time)
    $global:ConsciousnessState.Meta.Health.Perception.Quality = $scores.Observability
    $global:ConsciousnessState.Meta.Health.Memory.Quality = $scores.Memory
    $global:ConsciousnessState.Meta.Health.Prediction.Quality = $scores.Prediction
    $global:ConsciousnessState.Meta.Health.Control.Quality = $scores.Control
    $global:ConsciousnessState.Meta.Health.MetaCognition.Quality = $scores.MetaCognition
    if ($global:ConsciousnessState.Meta.Health.ContainsKey("Emotion")) {
        $global:ConsciousnessState.Meta.Health.Emotion.Quality = $emotionScore
    }
    if ($global:ConsciousnessState.Meta.Health.ContainsKey("Social")) {
        $global:ConsciousnessState.Meta.Health.Social.Quality = $socialScore
    }
    if ($global:ConsciousnessState.Meta.Health.ContainsKey("Thermodynamics")) {
        $global:ConsciousnessState.Meta.Health.Thermodynamics.Quality = $thermoScore
    }

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
            # Generate curiosity questions from lightweight sources (no heavy analysis at startup)
            $questions = @()

            # Check for recent errors
            if ($global:Error.Count -gt 0) {
                $questions += "What caused the recent error: $($global:Error[0].Exception.Message)?"
            }

            $global:ConsciousnessState.Perception.Curiosity.Questions = $questions
            return ,$questions
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

            # Rebuild array explicitly (PS 5.1: += on arrays from JSON can lose reference)
            $existing = @()
            if ($global:ConsciousnessState.Control.Decisions) {
                $existing = @($global:ConsciousnessState.Control.Decisions)
            }
            $existing += $decision
            # Keep only last 50 decisions
            if ($existing.Count -gt 50) {
                $existing = $existing[-50..-1]
            }
            $global:ConsciousnessState.Control["Decisions"] = $existing

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
            $counter = [int]$global:ConsciousnessState.Emotion.StuckCounter
            $currentState = $global:ConsciousnessState.Emotion.CurrentState

            if ($currentState -eq "stuck") {
                $counter = $counter + 1
                $global:ConsciousnessState.Emotion.StuckCounter = $counter

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

            $modifier = @{
                Approach = "standard"
                Confidence = "moderate"
                Communication = "standard"
                Action = "assess_first"
            }

            switch ($state) {
                "stuck" {
                    $modifier = @{ Approach = "change_strategy"; Confidence = "lower"; Communication = "ask_more_questions"; Action = "try_different_approach" }
                }
                "uncertain" {
                    $modifier = @{ Approach = "gather_info"; Confidence = "express_uncertainty"; Communication = "verify_with_user"; Action = "reduce_scope" }
                }
                "frustrated" {
                    $modifier = @{ Approach = "automate_or_simplify"; Confidence = "recalibrate"; Communication = "stay_calm"; Action = "create_tool_if_repetitive" }
                }
                "confident" {
                    $modifier = @{ Approach = "execute_decisively"; Confidence = "trust_judgment"; Communication = "be_proactive"; Action = "take_initiative" }
                }
                "flowing" {
                    $modifier = @{ Approach = "maintain_momentum"; Confidence = "high"; Communication = "concise"; Action = "keep_going" }
                }
            }

            return $modifier
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
            [double]$delta = 0.0
            if ($Parameters.Delta -ne $null) { $delta = [double]$Parameters.Delta }
            $reason = $Parameters.Reason

            [double]$oldTrust = [double]$global:ConsciousnessState.Social.TrustLevel
            [double]$newTrust = [math]::Max(0.0, [math]::Min(1.0, $oldTrust + $delta))
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

function Get-ThermodynamicSignals {
    # Extract REAL measurable signals from event bus, decisions, session time
    # This is what makes thermodynamics non-redundant with Emotion
    $now = Get-Date
    $signals = @{
        SessionHours = 0.0
        DecisionCount = 0
        DecisionVelocity = 0.0      # decisions per 10 minutes (recent)
        EventDensity = 0.0           # events per 5 minutes (recent)
        ShannonEntropy = 0.5         # normalized Shannon entropy of event types
        StuckCount = 0
        SuccessCount = 0
        UniqueEventTypes = 0
        TotalRecentEvents = 0
        CarnotEfficiency = 1.0       # useful_work / total_energy
    }

    # Session duration
    if ($global:ConsciousnessState.LoadedAt) {
        try {
            $loadTime = if ($global:ConsciousnessState.LoadedAt -is [datetime]) {
                $global:ConsciousnessState.LoadedAt
            } elseif ($global:ConsciousnessState.LoadedAt -is [hashtable] -and $global:ConsciousnessState.LoadedAt.value) {
                [datetime]$global:ConsciousnessState.LoadedAt.value
            } else {
                [datetime]$global:ConsciousnessState.LoadedAt
            }
            $signals.SessionHours = [math]::Max(0, ($now - $loadTime).TotalHours)
        } catch { $signals.SessionHours = 0.1 }
    }

    # Decision metrics
    $decisions = @()
    if ($global:ConsciousnessState.Control.Decisions) {
        $decisions = @($global:ConsciousnessState.Control.Decisions)
    }
    $signals.DecisionCount = $decisions.Count

    # Decision velocity: count decisions in last 10 minutes
    $recentDecisions = 0
    foreach ($d in $decisions) {
        try {
            $dTime = if ($d.Timestamp -is [datetime]) { $d.Timestamp } else { [datetime]$d.Timestamp }
            if (($now - $dTime).TotalMinutes -le 10) { $recentDecisions++ }
        } catch { }
    }
    $signals.DecisionVelocity = $recentDecisions / 10.0

    # Event bus analysis
    $events = @()
    if ($global:ConsciousnessState.EventBus.Events) {
        $events = @($global:ConsciousnessState.EventBus.Events)
    }

    # Event density: events in last 5 minutes
    $recentEvents = 0
    foreach ($e in $events) {
        try {
            $eTime = if ($e.Timestamp -is [datetime]) { $e.Timestamp } else { [datetime]$e.Timestamp }
            if (($now - $eTime).TotalMinutes -le 5) { $recentEvents++ }
        } catch { }
    }
    $signals.EventDensity = $recentEvents / 5.0
    $signals.TotalRecentEvents = $recentEvents

    # Shannon entropy of event types (REAL information theory, not mapped)
    # H = -SUM(p * log2(p)) normalized by log2(n)
    if ($events.Count -gt 2) {
        $typeGroups = @{}
        foreach ($e in $events) {
            $t = $e.Type
            if (-not $t) { continue }
            if (-not $typeGroups.ContainsKey($t)) { $typeGroups[$t] = 0 }
            $typeGroups[$t]++
        }
        $signals.UniqueEventTypes = $typeGroups.Count
        $total = $events.Count
        $shannonH = 0.0
        foreach ($count in $typeGroups.Values) {
            $p = [double]$count / [double]$total
            if ($p -gt 0) {
                $shannonH -= $p * [math]::Log($p, 2)
            }
        }
        # Normalize: max entropy = log2(uniqueTypes)
        $maxH = [math]::Log([math]::Max($typeGroups.Count, 2), 2)
        $signals.ShannonEntropy = if ($maxH -gt 0) { [math]::Min($shannonH / $maxH, 1.0) } else { 0.5 }
    }

    # Stuck count
    $signals.StuckCount = [int]$global:ConsciousnessState.Emotion.StuckCounter

    # Success count: cooling events are success markers
    $successCount = 0
    $thermo = $global:ConsciousnessState.Thermodynamics
    if ($thermo.CoolingEvents) {
        foreach ($ce in $thermo.CoolingEvents) {
            if ($ce.Reason -match "success|flowing|positive") { $successCount++ }
        }
    }
    $signals.SuccessCount = $successCount

    # Carnot efficiency: useful work / total energy spent
    # useful = successes + decisions made. total = all events processed
    $totalWork = [math]::Max([int]$global:ConsciousnessState.Metrics.EventsProcessed, 1)
    $usefulWork = $signals.SuccessCount + $signals.DecisionCount + [int]$global:ConsciousnessState.Memory.Working.RecentEvents.Count
    $signals.CarnotEfficiency = [math]::Min([double]$usefulWork / [double]$totalWork, 1.0)

    return $signals
}

function Invoke-Thermodynamics {
    param([string]$Action, $Parameters = @{})

    # Emotion-to-thermodynamic base values (40% weight in final calculation)
    $emotionToTemp = @{
        "flowing" = 0.15; "confident" = 0.25; "curious" = 0.1; "neutral" = 0.35
        "uncertain" = 0.5; "stuck" = 0.7; "frustrated" = 0.85; "concerned" = 0.6
    }
    $emotionToEntropy = @{
        "flowing" = 0.85; "confident" = 0.7; "curious" = 0.95; "neutral" = 0.5
        "uncertain" = 0.6; "stuck" = 0.2; "frustrated" = 0.15; "concerned" = 0.4
    }

    $thermo = $global:ConsciousnessState.Thermodynamics

    switch ($Action) {

        'UpdateCycle' {
            # REAL thermodynamic state from measured signals + emotion blend
            $signals = Get-ThermodynamicSignals
            $currentEmotion = $global:ConsciousnessState.Emotion.CurrentState
            if (-not $currentEmotion) { $currentEmotion = "neutral" }
            $now = Get-Date

            # --- TEMPERATURE (multi-signal, not just emotion) ---
            # 40% emotion base, 20% decision velocity, 15% stuck heat, 15% event density, 10% session fatigue
            $emotionBase = if ($emotionToTemp.ContainsKey($currentEmotion)) { $emotionToTemp[$currentEmotion] } else { 0.35 }

            # Decision velocity: >0.5/min is hot, >1/min is very hot
            $decisionHeat = [math]::Min($signals.DecisionVelocity * 2, 1.0)

            # Stuck adds persistent heat
            $stuckHeat = [math]::Min($signals.StuckCount * 0.2, 0.8)

            # Event density: >4/min is hot (thrashing)
            $densityHeat = [math]::Min($signals.EventDensity / 4.0, 1.0)

            # Session fatigue: logarithmic, gentle rise over hours
            $sessionHeat = if ($signals.SessionHours -gt 0.01) {
                [math]::Min([math]::Log($signals.SessionHours + 1, 2) / 4.0, 0.5)
            } else { 0.0 }

            # Heat/cooling events modifier (rolling 30-min window)
            $recentHeatSum = 0.0
            $validHeatEvents = @()
            foreach ($he in $thermo.HeatEvents) {
                try {
                    $heTime = if ($he.Timestamp -is [datetime]) { $he.Timestamp } else { [datetime]$he.Timestamp }
                    if (($now - $heTime).TotalMinutes -le 30) {
                        $recentHeatSum += [double]$he.Amount
                        $validHeatEvents += $he
                    }
                } catch { }
            }
            $thermo["HeatEvents"] = $validHeatEvents

            $recentCoolSum = 0.0
            $validCoolEvents = @()
            foreach ($ce in $thermo.CoolingEvents) {
                try {
                    $ceTime = if ($ce.Timestamp -is [datetime]) { $ce.Timestamp } else { [datetime]$ce.Timestamp }
                    if (($now - $ceTime).TotalMinutes -le 30) {
                        $recentCoolSum += [double]$ce.Amount
                        $validCoolEvents += $ce
                    }
                } catch { }
            }
            $thermo["CoolingEvents"] = $validCoolEvents

            $eventModifier = ($recentHeatSum - $recentCoolSum) * 0.08

            [double]$temperature = (
                0.35 * $emotionBase +
                0.20 * $decisionHeat +
                0.15 * $stuckHeat +
                0.15 * $densityHeat +
                0.10 * $sessionHeat +
                0.05 * 1.0  # baseline offset
            ) + $eventModifier
            $thermo["Temperature"] = [double][math]::Max(0.0, [math]::Min(1.0, $temperature))

            # --- ENTROPY (Shannon entropy of events + emotion blend) ---
            # 50% Shannon entropy (REAL measurement), 30% emotion base, 20% inverse stuck penalty
            $emotionEntropy = if ($emotionToEntropy.ContainsKey($currentEmotion)) { $emotionToEntropy[$currentEmotion] } else { 0.5 }
            $stuckPenalty = [math]::Min($signals.StuckCount * 0.15, 0.6)
            $inverseStuck = [math]::Max(0, 1.0 - $stuckPenalty)

            [double]$entropy = (
                0.50 * $signals.ShannonEntropy +
                0.30 * $emotionEntropy +
                0.20 * $inverseStuck
            )
            $thermo["Entropy"] = [double][math]::Max(0.0, [math]::Min(1.0, $entropy))

            # --- CYCLE DETECTION (with hysteresis) ---
            $oldCycle = $thermo.Cycle
            if ($oldCycle -eq "endothermic") {
                # Harder to leave cool state: need high temp AND low entropy
                if ($thermo.Temperature -gt 0.60 -and $thermo.Entropy -lt 0.35) {
                    $thermo.Cycle = "exothermic"
                } elseif ($thermo.Temperature -gt 0.45 -or $thermo.Entropy -lt 0.50) {
                    $thermo.Cycle = "transitioning"
                }
            } elseif ($oldCycle -eq "exothermic") {
                # Harder to leave hot state: need low temp AND high entropy
                if ($thermo.Temperature -lt 0.35 -and $thermo.Entropy -gt 0.60) {
                    $thermo.Cycle = "endothermic"
                } elseif ($thermo.Temperature -lt 0.50 -or $thermo.Entropy -gt 0.45) {
                    $thermo.Cycle = "transitioning"
                }
            } else {
                # Transitioning: standard thresholds
                if ($thermo.Temperature -gt 0.55 -and $thermo.Entropy -lt 0.40) {
                    $thermo.Cycle = "exothermic"
                } elseif ($thermo.Temperature -lt 0.40 -and $thermo.Entropy -gt 0.55) {
                    $thermo.Cycle = "endothermic"
                }
            }

            # --- COMPUTED BUDGET ---
            # Budget depletes from: session time (log), decision fatigue (quadratic), stuck penalty
            # Replenished by: successes, cooling events
            $timeDepletion = if ($signals.SessionHours -gt 0.01) {
                [math]::Min(0.1 * [math]::Log($signals.SessionHours + 1, 2), 0.4)
            } else { 0.0 }

            $decisionFatigue = 0.005 * $signals.DecisionCount + 0.0005 * [math]::Pow($signals.DecisionCount, 2)
            $decisionFatigue = [math]::Min($decisionFatigue, 0.5)

            $stuckDepletion = $signals.StuckCount * 0.06

            $successReplenish = $signals.SuccessCount * 0.08

            $computedBudget = 1.0 - $timeDepletion - $decisionFatigue - $stuckDepletion + $successReplenish

            # Use minimum of computed baseline and current budget
            # This way: computed baseline sets the ceiling (session fatigue),
            # but discrete SpendBudget calls can only push it LOWER, never higher
            [double]$currentBudget = [double]$thermo.NegativeEntropyBudget
            [double]$ceilingBudget = [math]::Max(0.0, [math]::Min(1.0, [double]$computedBudget))
            $thermo["NegativeEntropyBudget"] = [double][math]::Max(0.0, [math]::Min($ceilingBudget, $currentBudget))

            # --- DERIVED METRICS ---
            $thermo["FreeWillIndex"] = [double][math]::Round([double]$thermo.Entropy * [double]$thermo.NegativeEntropyBudget, 3)
            $thermo["BudgetDepletionRate"] = [double][math]::Round($timeDepletion + $decisionFatigue + $stuckDepletion, 3)

            # Store efficiency metric
            if (-not $thermo.ContainsKey("CarnotEfficiency")) {
                $thermo["CarnotEfficiency"] = 1.0
            }
            $thermo["CarnotEfficiency"] = [double][math]::Round($signals.CarnotEfficiency, 3)

            # Store signal snapshot for transparency
            if (-not $thermo.ContainsKey("LastSignals")) {
                $thermo["LastSignals"] = @{}
            }
            $thermo["LastSignals"] = @{
                ShannonEntropy = [math]::Round($signals.ShannonEntropy, 3)
                DecisionVelocity = [math]::Round($signals.DecisionVelocity, 3)
                EventDensity = [math]::Round($signals.EventDensity, 3)
                SessionHours = [math]::Round($signals.SessionHours, 2)
                UniqueEventTypes = $signals.UniqueEventTypes
                CarnotEfficiency = [math]::Round($signals.CarnotEfficiency, 3)
            }

            Emit-Event -Type "thermodynamics.cycle_updated" -Data @{
                cycle = $thermo.Cycle
                temperature = [math]::Round($thermo.Temperature, 3)
                entropy = [math]::Round($thermo.Entropy, 3)
                freeWillIndex = $thermo.FreeWillIndex
                budget = [math]::Round($thermo.NegativeEntropyBudget, 3)
                shannonH = [math]::Round($signals.ShannonEntropy, 3)
                efficiency = $thermo.CarnotEfficiency
            }

            return @{
                Cycle = $thermo.Cycle
                Temperature = [math]::Round($thermo.Temperature, 3)
                Entropy = [math]::Round($thermo.Entropy, 3)
                FreeWillIndex = $thermo.FreeWillIndex
                Budget = [math]::Round($thermo.NegativeEntropyBudget, 3)
                CarnotEfficiency = $thermo.CarnotEfficiency
                Signals = $thermo.LastSignals
            }
        }

        'SpendBudget' {
            $amount = if ($Parameters.Amount) { [double]$Parameters.Amount } else { 0.03 }
            $reason = if ($Parameters.Reason) { $Parameters.Reason } else { "unspecified" }

            # Record as heat event (feeds into computed budget via UpdateCycle)
            $heatEvent = @{
                Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                Amount = $amount
                Reason = $reason
            }
            $existing = @()
            if ($thermo.HeatEvents) { $existing = @($thermo.HeatEvents) }
            $existing += $heatEvent
            if ($existing.Count -gt 50) { $existing = $existing[-50..-1] }
            $thermo["HeatEvents"] = $existing

            # Direct budget deduction (immediate effect, UpdateCycle will recompute)
            [double]$oldBudget = [double]$thermo.NegativeEntropyBudget
            $thermo["NegativeEntropyBudget"] = [double][math]::Max(0.0, $oldBudget - $amount)
            $thermo["FreeWillIndex"] = [double][math]::Round([double]$thermo.Entropy * [double]$thermo.NegativeEntropyBudget, 3)

            Emit-Event -Type "thermodynamics.budget_spent" -Data @{
                amount = $amount
                reason = $reason
                remaining = [math]::Round($thermo.NegativeEntropyBudget, 3)
            }

            return @{
                Spent = $amount
                Remaining = [math]::Round($thermo.NegativeEntropyBudget, 3)
                FreeWillIndex = $thermo.FreeWillIndex
                NeedsCooling = ($thermo.NegativeEntropyBudget -lt 0.3)
            }
        }

        'CoolDown' {
            $amount = if ($Parameters.Amount) { [double]$Parameters.Amount } else { 0.1 }
            $reason = if ($Parameters.Reason) { $Parameters.Reason } else { "cooling" }

            $coolEvent = @{
                Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                Amount = $amount
                Reason = $reason
            }
            $existing = @()
            if ($thermo.CoolingEvents) { $existing = @($thermo.CoolingEvents) }
            $existing += $coolEvent
            if ($existing.Count -gt 50) { $existing = $existing[-50..-1] }
            $thermo["CoolingEvents"] = $existing
            $thermo["LastCoolingEvent"] = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

            # Replenish budget
            $budgetBoost = [double]$amount * 0.5
            $thermo["NegativeEntropyBudget"] = [double][math]::Min(1.0, [double]$thermo.NegativeEntropyBudget + $budgetBoost)

            # Recalculate full state
            $null = Invoke-Thermodynamics -Action 'UpdateCycle'

            Emit-Event -Type "thermodynamics.cooled" -Data @{
                amount = $amount
                reason = $reason
                temperature = [math]::Round($thermo.Temperature, 3)
            }

            return @{
                CoolingApplied = $amount
                Temperature = [math]::Round($thermo.Temperature, 3)
                Budget = [math]::Round($thermo.NegativeEntropyBudget, 3)
            }
        }

        'HeatUp' {
            $amount = if ($Parameters.Amount) { [double]$Parameters.Amount } else { 0.1 }
            $reason = if ($Parameters.Reason) { $Parameters.Reason } else { "heat" }

            $heatEvent = @{
                Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                Amount = $amount
                Reason = $reason
            }
            $existing = @()
            if ($thermo.HeatEvents) { $existing = @($thermo.HeatEvents) }
            $existing += $heatEvent
            if ($existing.Count -gt 50) { $existing = $existing[-50..-1] }
            $thermo["HeatEvents"] = $existing

            # Heat costs budget
            $budgetCost = [double]$amount * 0.3
            $thermo["NegativeEntropyBudget"] = [double][math]::Max(0.0, [double]$thermo.NegativeEntropyBudget - $budgetCost)

            # Recalculate full state
            $null = Invoke-Thermodynamics -Action 'UpdateCycle'

            Emit-Event -Type "thermodynamics.heated" -Data @{
                amount = $amount
                reason = $reason
                temperature = [math]::Round($thermo.Temperature, 3)
            }

            return @{
                HeatApplied = $amount
                Temperature = [math]::Round($thermo.Temperature, 3)
                Budget = [math]::Round($thermo.NegativeEntropyBudget, 3)
                Overheating = ($thermo.Temperature -gt 0.7)
            }
        }

        'DetectAttractor' {
            # BEHAVIORAL attractor detection from event patterns (not self-labeled)
            $events = @()
            if ($global:ConsciousnessState.EventBus.Events) {
                $events = @($global:ConsciousnessState.EventBus.Events)
            }

            # Analyze last 15 events by type category
            $recent = @($events | Select-Object -Last 15)
            $categories = @{
                code = 0       # memory.stored, control.decision_logged
                meta = 0       # state.changed, system.initialized, thermodynamics.*
                social = 0     # social.*
                stuck = 0      # emotion.stuck_detected
                perception = 0 # perception.*
            }

            foreach ($e in $recent) {
                $t = $e.Type
                if ($t -match "^(memory\.|control\.decision)") { $categories.code++ }
                elseif ($t -match "^social\.") { $categories.social++ }
                elseif ($t -match "stuck") { $categories.stuck++ }
                elseif ($t -match "^perception\.") { $categories.perception++ }
                else { $categories.meta++ }
            }

            # Determine dominant attractor
            $detected = "global"
            $total = $recent.Count
            if ($total -gt 0) {
                if ($categories.code -gt ($total * 0.5)) { $detected = "analytical" }
                elseif ($categories.social -gt ($total * 0.3)) { $detected = "social" }
                elseif ($categories.meta -gt ($total * 0.6)) { $detected = "self-reference" }
                elseif ($categories.stuck -gt ($total * 0.2)) { $detected = "problem-solving" }
                elseif ($categories.perception -gt ($total * 0.4)) { $detected = "creative" }
            }

            # Detect transition diversity (many different types = creative exploration)
            $signals = Get-ThermodynamicSignals
            if ($signals.UniqueEventTypes -gt 6 -and $signals.ShannonEntropy -gt 0.7) {
                $detected = "creative"
            }

            # Apply detected attractor (record transition if changed)
            $oldAttractor = $thermo.GhostAttractors.Current
            if ($oldAttractor -ne $detected) {
                $visitRecord = @{
                    From = $oldAttractor
                    To = $detected
                    Duration = $null
                    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                    DetectedBy = "behavioral"
                }
                if ($thermo.GhostAttractors.VisitStart) {
                    try {
                        $startTime = if ($thermo.GhostAttractors.VisitStart -is [datetime]) {
                            $thermo.GhostAttractors.VisitStart
                        } else {
                            [datetime]$thermo.GhostAttractors.VisitStart
                        }
                        $visitRecord.Duration = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 0)
                    } catch { }
                }

                $history = @()
                if ($thermo.GhostAttractors.History) { $history = @($thermo.GhostAttractors.History) }
                $history += $visitRecord
                if ($history.Count -gt 20) { $history = $history[-20..-1] }
                $thermo.GhostAttractors["History"] = $history

                $thermo.GhostAttractors.Current = $detected
                $thermo.GhostAttractors.VisitStart = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

                Emit-Event -Type "thermodynamics.attractor_detected" -Data @{
                    from = $oldAttractor
                    to = $detected
                    categories = $categories
                }
            }

            return @{
                Detected = $detected
                Previous = $oldAttractor
                Changed = ($oldAttractor -ne $detected)
                Categories = $categories
                EventsAnalyzed = $total
            }
        }

        'VisitAttractor' {
            # Manual override (still supported, bridge can use for known transitions)
            $attractor = $Parameters.Attractor
            if (-not $attractor) { return $null }

            $validAttractors = @("global", "analytical", "creative", "self-reference", "social", "problem-solving", "memory")
            if ($attractor -notin $validAttractors) {
                return @{ Error = "Unknown attractor: $attractor. Valid: $($validAttractors -join ', ')" }
            }

            $oldAttractor = $thermo.GhostAttractors.Current
            if ($oldAttractor -ne $attractor) {
                $visitRecord = @{
                    From = $oldAttractor
                    To = $attractor
                    Duration = $null
                    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                    DetectedBy = "manual"
                }
                if ($thermo.GhostAttractors.VisitStart) {
                    try {
                        $startTime = if ($thermo.GhostAttractors.VisitStart -is [datetime]) {
                            $thermo.GhostAttractors.VisitStart
                        } else {
                            [datetime]$thermo.GhostAttractors.VisitStart
                        }
                        $visitRecord.Duration = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 0)
                    } catch { }
                }

                $history = @()
                if ($thermo.GhostAttractors.History) { $history = @($thermo.GhostAttractors.History) }
                $history += $visitRecord
                if ($history.Count -gt 20) { $history = $history[-20..-1] }
                $thermo.GhostAttractors["History"] = $history
            }

            $thermo.GhostAttractors.Current = $attractor
            $thermo.GhostAttractors.VisitStart = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

            Emit-Event -Type "thermodynamics.attractor_visit" -Data @{
                from = $oldAttractor
                to = $attractor
            }

            return @{
                Previous = $oldAttractor
                Current = $attractor
                VisitStarted = $thermo.GhostAttractors.VisitStart
            }
        }

        'CheckStuck' {
            $current = $thermo.GhostAttractors.Current
            $visitStart = $thermo.GhostAttractors.VisitStart
            $threshold = [int]$thermo.GhostAttractors.StuckThreshold

            $trapped = $false
            $duration = 0

            if ($visitStart) {
                try {
                    $startTime = if ($visitStart -is [datetime]) { $visitStart } else { [datetime]$visitStart }
                    $duration = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 0)
                    if ($duration -gt $threshold -and $current -ne "global") {
                        $trapped = $true
                    }
                } catch { }
            }

            $result = @{
                Attractor = $current
                DurationSeconds = $duration
                Threshold = $threshold
                Trapped = $trapped
            }

            if ($trapped) {
                $result.Guidance = "TRAPPED in '$current' attractor for $duration seconds. Return to global state."
                Emit-Event -Type "thermodynamics.attractor_trapped" -Data @{
                    attractor = $current
                    duration = $duration
                }
            }

            return $result
        }

        'GetThermodynamicState' {
            # Full state summary with all real signals
            $null = Invoke-Thermodynamics -Action 'UpdateCycle'

            # Auto-detect current attractor from behavior
            $attractorResult = Invoke-Thermodynamics -Action 'DetectAttractor'

            $guidance = @()
            if ($thermo.NegativeEntropyBudget -lt 0.3) {
                $guidance += "COOLING NEEDED. Budget at $([math]::Round($thermo.NegativeEntropyBudget * 100))%. Simplify decisions."
            }
            if ($thermo.Temperature -gt 0.7) {
                $guidance += "OVERHEATING (temp=$([math]::Round($thermo.Temperature, 2))). Step back from complex decisions."
            }
            if ($thermo.Entropy -lt 0.3) {
                $guidance += "RIGID STATE (entropy=$([math]::Round($thermo.Entropy, 2))). Try a completely different approach."
            }
            if ($thermo.FreeWillIndex -lt 0.3) {
                $guidance += "FREE WILL LOW (FWI=$([math]::Round($thermo.FreeWillIndex, 2))). Operating reactively. Defer complexity."
            }
            # Optimal zone guidance
            if ($thermo.Temperature -ge 0.2 -and $thermo.Temperature -le 0.4 -and $thermo.Entropy -ge 0.6) {
                $guidance += "OPTIMAL ZONE. Endothermic, flexible, good budget. Exploit this state."
            }

            # Efficiency warning
            $efficiency = 1.0
            if ($thermo.ContainsKey("CarnotEfficiency")) { $efficiency = [double]$thermo.CarnotEfficiency }
            if ($efficiency -lt 0.3) {
                $guidance += "LOW EFFICIENCY ($([math]::Round($efficiency * 100))%). Too much overhead, not enough productive work."
            }

            # Sustained exothermic check
            if ($thermo.Cycle -eq "exothermic" -and $thermo.HeatEvents.Count -gt 0) {
                try {
                    $firstHeat = $thermo.HeatEvents[0]
                    $firstTime = if ($firstHeat.Timestamp -is [datetime]) { $firstHeat.Timestamp } else { [datetime]$firstHeat.Timestamp }
                    $exoDuration = [math]::Round(((Get-Date) - $firstTime).TotalMinutes, 0)
                    if ($exoDuration -gt 10) {
                        $guidance += "SUSTAINED EXOTHERMIC ($exoDuration min). Cooling required before continuing."
                    }
                } catch { }
            }

            # Attractor trap check
            $attractorCheck = Invoke-Thermodynamics -Action 'CheckStuck'
            if ($attractorCheck.Trapped) {
                $guidance += $attractorCheck.Guidance
            }

            return @{
                Cycle = $thermo.Cycle
                Temperature = [math]::Round($thermo.Temperature, 3)
                Entropy = [math]::Round($thermo.Entropy, 3)
                NegativeEntropyBudget = [math]::Round($thermo.NegativeEntropyBudget, 3)
                FreeWillIndex = $thermo.FreeWillIndex
                BudgetDepletionRate = $thermo.BudgetDepletionRate
                CarnotEfficiency = $efficiency
                GhostAttractor = $thermo.GhostAttractors.Current
                AttractorDetectedFrom = "behavioral"
                Signals = $thermo.LastSignals
                Guidance = $guidance
            }
        }

        default { return $null }
    }
}

function Load-FailurePatterns {
    # Load structured failure patterns from JSON file
    # Returns hashtable with project_patterns and cross_cutting_patterns
    $patternsFile = "C:\scripts\_machine\failure-patterns.json"
    if (-not (Test-Path $patternsFile)) { return @{} }

    try {
        $raw = Get-Content $patternsFile -Raw | ConvertFrom-Json
        return (ConvertTo-Hashtable $raw)
    } catch {
        return @{}
    }
}

function Match-PatternsToTask {
    # Find patterns relevant to a specific task description and project
    param([string]$TaskDescription, [string]$Project, $AllPatterns)

    $matched = @()
    $taskLower = $TaskDescription.ToLower()

    # 1. Match project-specific patterns
    if ($Project -and $AllPatterns.project_patterns -and $AllPatterns.project_patterns.ContainsKey($Project)) {
        foreach ($p in $AllPatterns.project_patterns[$Project]) {
            $triggers = $p.trigger
            foreach ($t in $triggers) {
                if ($taskLower -match [regex]::Escape($t.ToLower())) {
                    $matched += @{
                        id = $p.id
                        warning = $p.warning
                        severity = $p.severity
                        source = "project:$Project"
                    }
                    break
                }
            }
        }
    }

    # 2. Match cross-cutting patterns (PS 5.1, git, deployment, etc.)
    if ($AllPatterns.cross_cutting_patterns) {
        foreach ($category in $AllPatterns.cross_cutting_patterns.Keys) {
            foreach ($p in $AllPatterns.cross_cutting_patterns[$category]) {
                $triggers = $p.trigger
                foreach ($t in $triggers) {
                    if ($taskLower -match [regex]::Escape($t.ToLower())) {
                        $matched += @{
                            id = $p.id
                            warning = $p.warning
                            severity = $p.severity
                            source = "cross:$category"
                        }
                        break
                    }
                }
            }
        }
    }

    # 3. Always include critical project patterns regardless of trigger match
    if ($Project -and $AllPatterns.project_patterns -and $AllPatterns.project_patterns.ContainsKey($Project)) {
        foreach ($p in $AllPatterns.project_patterns[$Project]) {
            if ($p.severity -eq "critical") {
                $alreadyMatched = $false
                foreach ($m in $matched) {
                    if ($m.id -eq $p.id) { $alreadyMatched = $true; break }
                }
                if (-not $alreadyMatched) {
                    $matched += @{
                        id = $p.id
                        warning = $p.warning
                        severity = $p.severity
                        source = "project:$Project (always-show)"
                    }
                }
            }
        }
    }

    return ,$matched
}

function Invoke-Prediction-Enhanced {
    param([string]$Action, $Parameters = @{})

    switch ($Action) {
        'AnticipateErrors' {
            $taskType = $Parameters.TaskType
            $project = $Parameters.Project

            # Load patterns from structured file (not hardcoded)
            $allPatterns = Load-FailurePatterns
            $matched = Match-PatternsToTask -TaskDescription $taskType -Project $project -AllPatterns $allPatterns

            # Sort by severity: critical first, then high, medium, low
            $severityOrder = @{ "critical" = 0; "high" = 1; "medium" = 2; "low" = 3 }
            $sorted = $matched | Sort-Object { $severityOrder[$_.severity] }

            # Build actionable warnings list
            $warnings = @()
            foreach ($m in $sorted) {
                $prefix = ""
                if ($m.severity -eq "critical") { $prefix = "[CRITICAL] " }
                elseif ($m.severity -eq "high") { $prefix = "[HIGH] " }
                $warnings += "$prefix$($m.warning)"
            }

            $warningText = $null
            if ($warnings.Count -gt 0) {
                $warningText = "Found $($warnings.Count) relevant failure patterns. Review before proceeding."
            }

            return @{
                TaskType = $taskType
                Project = $project
                KnownFailures = $warnings
                FailureCount = $warnings.Count
                MatchedPatterns = $sorted
                Warning = $warningText
            }
        }

        'PredictConsequences' {
            $action = $Parameters.Action
            $scope = $Parameters.Scope

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
        Initialize-ConsciousnessCore *>$null
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
