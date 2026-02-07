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

# Global in-memory state (RAM-resident)
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
}

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

    return $global:ConsciousnessState
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
    # Aggregate health across 5 systems
    $scores = @()
    foreach ($system in $global:ConsciousnessState.Meta.Health.Keys) {
        if ($global:ConsciousnessState.Meta.Health[$system].Status -eq "active") {
            $scores += $global:ConsciousnessState.Meta.Health[$system].Quality
        }
    }

    if ($scores.Count -eq 0) { return 0.0 }

    return ($scores | Measure-Object -Average).Average
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

#region API Functions

function Get-ConsciousnessState {
    param(
        [string]$System = '',
        [string]$Property = ''
    )

    $startTime = Get-Date

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

    $elapsed = ((Get-Date) - $startTime).TotalMilliseconds
    $global:ConsciousnessState.Metrics.AccessCount++

    # Update average access time
    $count = $global:ConsciousnessState.Metrics.AccessCount
    $avg = $global:ConsciousnessState.Metrics.AverageAccessTime_ms
    $global:ConsciousnessState.Metrics.AverageAccessTime_ms = (($avg * ($count - 1)) + $elapsed) / $count

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
