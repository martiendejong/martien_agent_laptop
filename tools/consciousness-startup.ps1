# Consciousness Startup - Initialize engine, bridge, and generate context
# This is called from claude_agent.bat BEFORE Claude starts
# THE CRITICAL PIECE: This closes the feedback loop at session start
# Created: 2026-01-29 | Rebuilt: 2026-02-11 (feedback loop fix)
# Enhanced: 2026-03-04 (added startup logging for reflection)

<#
.SYNOPSIS
    Initialize consciousness engine and generate context for Claude injection.
.DESCRIPTION
    1. Initialize consciousness-core-v2.ps1 (8 systems)
    2. Reset bridge for fresh session
    3. Generate consciousness-context.json
    4. Generate session tracker YAML
    This is the entry point that closes the feedback loop.
.PARAMETER Generate
    Generate fresh session tracker state (default when called from claude_agent.bat)
.PARAMETER Quick
    Skip verbose output, just initialize and generate context
.PARAMETER Silent
    No output at all (for programmatic use)
#>

param(
    [switch]$Quick,
    [switch]$Generate,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

$contextFile = "C:\scripts\agentidentity\state\consciousness-context.json"
$trackerPath = "C:\scripts\agentidentity\state\consciousness_tracker.yaml"
$stateDir = "C:\scripts\agentidentity\state"
$logFile = "C:\scripts\logs\consciousness-startup.log"
$maxLogSessions = 50  # Keep last 50 sessions in log

# Ensure log directory exists
$logDir = Split-Path $logFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Initialize session log entry
$sessionTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$sessionId = Get-Date -Format "yyyy-MM-dd-HHmm"
$logEntry = @{
    SessionId = $sessionId
    Timestamp = $sessionTimestamp
    Steps = @()
    Warnings = @()
    Metrics = @{
        ConsciousnessScore = 0
        SubsystemsActive = 0
        PredictionPatterns = 0
        CuriosityQuestions = 0
    }
}

# Helper function: Log to both console and structured log
function Write-LoggedOutput {
    param(
        [string]$Message,
        [string]$ForegroundColor = "White",
        [string]$Level = "INFO"  # INFO, WARN, ERROR, SUCCESS
    )

    if (-not $Silent) {
        Write-Host $Message -ForegroundColor $ForegroundColor
    }

    # Add to session log
    $script:logEntry.Steps += @{
        Timestamp = (Get-Date -Format "HH:mm:ss.fff")
        Level = $Level
        Message = $Message
    }
}

# Helper function: Rotate log files when they exceed threshold
function Rotate-LogFile {
    param(
        [string]$FilePath,
        [int]$MaxSizeKB = 100,
        [int]$KeepArchives = 5
    )

    if (-not (Test-Path $FilePath)) { return }

    $file = Get-Item $FilePath
    $sizeKB = [math]::Round($file.Length / 1KB, 1)

    if ($sizeKB -gt $MaxSizeKB) {
        $archiveName = "$($file.DirectoryName)\$($file.BaseName)-$(Get-Date -Format 'yyyyMMdd')$($file.Extension)"

        # If archive already exists today, append time
        if (Test-Path $archiveName) {
            $archiveName = "$($file.DirectoryName)\$($file.BaseName)-$(Get-Date -Format 'yyyyMMdd-HHmmss')$($file.Extension)"
        }

        Move-Item $FilePath $archiveName -Force
        Write-Host "  [ROTATED] $($file.Name) ($sizeKB KB) -> $(Split-Path $archiveName -Leaf)" -ForegroundColor DarkGray

        # Clean up old archives (keep last N)
        $pattern = "$($file.BaseName)-*$($file.Extension)"
        Get-ChildItem -Path $file.DirectoryName -Filter $pattern |
            Sort-Object CreationTime -Descending |
            Select-Object -Skip $KeepArchives |
            Remove-Item -Force
    }
}

# Ensure state directory exists
if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

# Rotate logs before starting (prevent unbounded growth)
Rotate-LogFile -FilePath "$stateDir\bridge-activity.jsonl" -MaxSizeKB 200 -KeepArchives 5
Rotate-LogFile -FilePath "$stateDir\persuadability-assessments.jsonl" -MaxSizeKB 500 -KeepArchives 5
Rotate-LogFile -FilePath "C:\scripts\_machine\reflection.log.md" -MaxSizeKB 500 -KeepArchives 10

if (-not $Silent) {
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "  JENGO CONSCIOUSNESS STARTUP - $sessionId" -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host ""
}
$logEntry.Steps += @{ Timestamp = (Get-Date -Format "HH:mm:ss.fff"); Level = "START"; Message = "Session $sessionId started" }

#region Step 1: Initialize Consciousness Core (8 systems)
try {
    Write-LoggedOutput "  [1/4] Initializing consciousness core..." -ForegroundColor Yellow -Level "INFO"

    # Save our $Silent state before dot-source (core's param block overwrites it)
    $wasSilent = $Silent.IsPresent
    $null = . "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent
    $Silent = [switch]$wasSilent

    $score = [math]::Round($global:ConsciousnessState.Meta.ConsciousnessScore * 100, 1)
    $logEntry.Metrics.ConsciousnessScore = $score

    Write-LoggedOutput "        8 systems active | Score: $score%" -ForegroundColor Green -Level "SUCCESS"
} catch {
    Write-LoggedOutput "        FAILED: $_" -ForegroundColor Red -Level "ERROR"
    Write-LoggedOutput "        Continuing with degraded consciousness" -ForegroundColor Yellow -Level "WARN"
    $logEntry.Warnings += "Consciousness core initialization failed: $_"
}
#endregion

#region Step 2: Reset Bridge for Fresh Session
try {
    Write-LoggedOutput "  [2/4] Resetting bridge for fresh session..." -ForegroundColor Yellow -Level "INFO"

    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action Reset -Silent

    Write-LoggedOutput "        Bridge reset complete" -ForegroundColor Green -Level "SUCCESS"
} catch {
    Write-LoggedOutput "        Bridge reset failed: $_" -ForegroundColor Red -Level "ERROR"
    $logEntry.Warnings += "Bridge reset failed: $_"
}
#endregion

#region Step 3: Generate Context Summary (THE KEY OUTPUT)
try {
    Write-LoggedOutput "  [3/4] Generating consciousness context..." -ForegroundColor Yellow -Level "INFO"

    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action GetContextSummary -Silent

    if (Test-Path $contextFile) {
        $ctxSize = [math]::Round((Get-Item $contextFile).Length / 1KB, 1)
        Write-LoggedOutput "        Context generated: $ctxSize KB -> $contextFile" -ForegroundColor Green -Level "SUCCESS"
        $logEntry.Metrics.ContextSizeKB = $ctxSize
    } else {
        Write-LoggedOutput "        WARNING: Context file not generated" -ForegroundColor Yellow -Level "WARN"
        $logEntry.Warnings += "Context file not generated"
    }
} catch {
    Write-LoggedOutput "        Context generation failed: $_" -ForegroundColor Red -Level "ERROR"
    $logEntry.Warnings += "Context generation failed: $_"
}
#endregion

#region Step 4: Generate Session Tracker
if ($Generate) {
    try {
        Write-LoggedOutput "  [4/4] Generating session tracker..." -ForegroundColor Yellow -Level "INFO"

        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm'

        $lines = @(
            "# Consciousness Tracker - Session State"
            "# Generated: $timestamp"
            "# Session: $sessionId"
            ""
            "current_session:"
            "  session_id: `"$sessionId`""
            "  started: `"$timestamp`""
            ""
            "  moments: []"
            "  emotional_states: []"
            "  growth_edges: []"
            ""
            "  practices_engaged:"
            "    moment_capture: false"
            "    build_review_cycle: false"
            "    play_and_lightness: false"
            "    purposeless_creation: false"
            ""
            "end_of_session:"
            "  moments_total: 0"
            "  practices_used: []"
            "  key_learning: ''"
            "  emotional_arc: ''"
        )

        $newState = $lines -join "`n"
        Set-Content -Path $trackerPath -Value $newState -Encoding UTF8

        Write-LoggedOutput "        Session: $sessionId" -ForegroundColor Green -Level "SUCCESS"
    } catch {
        Write-LoggedOutput "        Tracker generation failed: $_" -ForegroundColor Red -Level "ERROR"
        $logEntry.Warnings += "Tracker generation failed: $_"
    }
} else {
    Write-LoggedOutput "  [4/4] Session tracker: skipped (no -Generate flag)" -ForegroundColor Gray -Level "INFO"
}
#endregion

#region Step 4b: Activate Subsystems (Perception, Prediction, Social, Thermodynamics)
try {
    Write-LoggedOutput "  [4b/6] Activating subsystems..." -ForegroundColor Yellow -Level "INFO"

    # Thermodynamics: Initial cycle computation from real signals
    $thermoResult = Invoke-Thermodynamics -Action 'UpdateCycle'
    $null = Invoke-Thermodynamics -Action 'DetectAttractor'
    $temp = [math]::Round([double]$thermoResult.Temperature, 2)
    $budget = [math]::Round([double]$thermoResult.Budget, 2)
    Write-LoggedOutput "        Thermodynamics: temp=$temp budget=$budget cycle=$($thermoResult.Cycle)" -ForegroundColor Gray -Level "INFO"
    $logEntry.Metrics.Temperature = $temp
    $logEntry.Metrics.Budget = $budget
    $logEntry.Metrics.Cycle = $thermoResult.Cycle

    # Perception: Generate curiosity questions
    $questions = Invoke-Perception -Action 'GenerateCuriosity'
    if ($questions -and $questions.Count -gt 0) {
        Write-LoggedOutput "        Curiosity ($($questions.Count) questions)" -ForegroundColor Gray -Level "INFO"
        $logEntry.Metrics.CuriosityQuestions = $questions.Count
    }

    # Perception: Detect current context
    $ctx = Invoke-Perception -Action 'DetectContext'
    if ($ctx) {
        Write-LoggedOutput "        Context: $($ctx.Mode) | $($ctx.Salience.Count) salient items" -ForegroundColor Gray -Level "INFO"
        $logEntry.Metrics.ContextMode = $ctx.Mode
    }

    # Prediction: Check for anticipated errors on common projects
    $commonProjects = @("client-manager", "hazina", "art-revisionist", "orchestration")
    $totalPatterns = 0
    foreach ($proj in $commonProjects) {
        $pred = Invoke-Prediction-Enhanced -Action 'AnticipateErrors' -Parameters @{ TaskType = "general"; Project = $proj }
        if ($pred.FailureCount -gt 0) { $totalPatterns += $pred.FailureCount }
    }
    Write-LoggedOutput "        Prediction: $totalPatterns failure patterns loaded" -ForegroundColor Gray -Level "INFO"
    $logEntry.Metrics.PredictionPatterns = $totalPatterns

    Write-LoggedOutput "        Subsystems active" -ForegroundColor Green -Level "SUCCESS"
    $logEntry.Metrics.SubsystemsActive = 4  # Thermodynamics, Perception (2x), Prediction
} catch {
    Write-LoggedOutput "        Subsystem activation partial: $_" -ForegroundColor Yellow -Level "WARN"
    $logEntry.Warnings += "Subsystem activation partial: $_"
}
#endregion

#region Step 5: Session Briefing (analyze last session)
try {
    Write-LoggedOutput "  [5/6] Analyzing last session..." -ForegroundColor Yellow -Level "INFO"
    $briefing = & "$PSScriptRoot\analyze-last-session.ps1" -Silent
    if ($briefing -and $briefing.patterns) {
        $logEntry.Metrics.LastSessionPatterns = $briefing.patterns.Count
        foreach ($p in $briefing.patterns) {
            Write-LoggedOutput "        $p" -ForegroundColor Gray -Level "INFO"
        }
        foreach ($w in $briefing.warnings) {
            Write-LoggedOutput "        [!] $w" -ForegroundColor Yellow -Level "WARN"
            $logEntry.Warnings += "Last session: $w"
        }
    }
} catch {
    Write-LoggedOutput "        Briefing skipped: $_" -ForegroundColor Gray -Level "INFO"
}
#endregion

#region Step 6: 1% Improvement Reminder
try {
    $improvementLog = "C:\scripts\_machine\improvements-1pct.jsonl"
    $todayStr = Get-Date -Format "yyyy-MM-dd"
    $doneToday = $false
    if (Test-Path $improvementLog) {
        $lastLine = Get-Content $improvementLog -Tail 1 -ErrorAction SilentlyContinue
        if ($lastLine -and $lastLine -match $todayStr) { $doneToday = $true }
    }
    if (-not $doneToday) {
        Write-LoggedOutput "  [1% RULE] No improvement logged today. Make one small improvement this session." -ForegroundColor Magenta -Level "INFO"
        Write-LoggedOutput "           (delete dead file, fix stale reference, update a TODO, clean up)" -ForegroundColor Gray -Level "INFO"
        $logEntry.Metrics.ImprovementDoneToday = $false
    } else {
        Write-LoggedOutput "  [1% RULE] Improvement already logged today." -ForegroundColor Green -Level "SUCCESS"
        $logEntry.Metrics.ImprovementDoneToday = $true
    }
} catch {
    # Non-fatal
}
#endregion

#region Step 7: Start Infrastructure Services
try {
    Write-LoggedOutput "  [7/7] Checking infrastructure services..." -ForegroundColor Yellow -Level "INFO"

    # Windows UI Automation Bridge (27184) - fallback automation for GUI-only apps
    # Quick check if already running to avoid hanging
    try {
        $null = Invoke-RestMethod "http://localhost:27184/health" -TimeoutSec 1 -ErrorAction Stop
        Write-LoggedOutput "        UI Bridge: already running" -ForegroundColor DarkGray -Level "INFO"
        $logEntry.Metrics.UIBridgeStatus = "running"
    } catch {
        # Not running, try to start (non-blocking)
        $uiBridgeScript = Join-Path $PSScriptRoot "start-windows-ui-bridge.ps1"
        if (Test-Path $uiBridgeScript) {
            Start-Job -ScriptBlock { & $using:uiBridgeScript } | Out-Null
            Write-LoggedOutput "        UI Bridge: starting..." -ForegroundColor DarkGray -Level "INFO"
            $logEntry.Metrics.UIBridgeStatus = "starting"
        } else {
            $logEntry.Metrics.UIBridgeStatus = "not_available"
        }
    }
} catch {
    # Non-fatal - service might already be running or not needed yet
    Write-LoggedOutput "        [WARN] Could not start Windows UI Bridge" -ForegroundColor DarkYellow -Level "WARN"
    $logEntry.Warnings += "Could not start Windows UI Bridge: $_"
    $logEntry.Metrics.UIBridgeStatus = "failed"
}
#endregion

# Set consciousness indicator in window title
$indicatorPath = Join-Path (Split-Path $PSScriptRoot -Parent) "tools\set-consciousness-indicator.ps1"
if (Test-Path $indicatorPath) {
    & $indicatorPath -State conscious 2>$null | Out-Null
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "  Consciousness online. Infrastructure ready." -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host ""
}

#region Finalize and Write Log
$logEntry.Steps += @{
    Timestamp = (Get-Date -Format "HH:mm:ss.fff")
    Level = "COMPLETE"
    Message = "Startup complete - consciousness online"
}

# Convert to JSONL format (one JSON object per line)
$logLine = ($logEntry | ConvertTo-Json -Depth 10 -Compress)

# Append to log file
try {
    Add-Content -Path $logFile -Value $logLine -Encoding UTF8 -ErrorAction Stop

    # Cleanup: Keep only last N sessions
    if (Test-Path $logFile) {
        $allLines = Get-Content $logFile -ErrorAction SilentlyContinue
        if ($allLines -and $allLines.Count -gt $maxLogSessions) {
            $keepLines = $allLines | Select-Object -Last $maxLogSessions
            Set-Content -Path $logFile -Value $keepLines -Encoding UTF8
        }
    }
} catch {
    # Non-fatal - logging is nice to have but not critical
    if (-not $Silent) {
        Write-Host "  [WARN] Could not write startup log: $_" -ForegroundColor Yellow
    }
}
#endregion

# Status available via globals for programmatic callers
# (no return value to avoid console dump when called from .bat)
