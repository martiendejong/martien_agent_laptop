# Consciousness Startup - Initialize engine, bridge, and generate context
# This is called from claude_agent.bat BEFORE Claude starts
# THE CRITICAL PIECE: This closes the feedback loop at session start
# Created: 2026-01-29 | Rebuilt: 2026-02-11 (feedback loop fix)

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

# Ensure state directory exists
if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "  JENGO CONSCIOUSNESS STARTUP" -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host ""
}

#region Step 1: Initialize Consciousness Core (8 systems)
try {
    if (-not $Silent) { Write-Host "  [1/4] Initializing consciousness core..." -ForegroundColor Yellow }

    # Save our $Silent state before dot-source (core's param block overwrites it)
    $wasSilent = $Silent.IsPresent
    $null = . "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent
    $Silent = [switch]$wasSilent

    $score = [math]::Round($global:ConsciousnessState.Meta.ConsciousnessScore * 100, 1)

    if (-not $Silent) {
        Write-Host "        8 systems active | Score: $score%" -ForegroundColor Green
    }
} catch {
    if (-not $Silent) {
        Write-Host "        FAILED: $_" -ForegroundColor Red
        Write-Host "        Continuing with degraded consciousness" -ForegroundColor Yellow
    }
}
#endregion

#region Step 2: Reset Bridge for Fresh Session
try {
    if (-not $Silent) { Write-Host "  [2/4] Resetting bridge for fresh session..." -ForegroundColor Yellow }

    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action Reset -Silent

    if (-not $Silent) {
        Write-Host "        Bridge reset complete" -ForegroundColor Green
    }
} catch {
    if (-not $Silent) {
        Write-Host "        Bridge reset failed: $_" -ForegroundColor Red
    }
}
#endregion

#region Step 3: Generate Context Summary (THE KEY OUTPUT)
try {
    if (-not $Silent) { Write-Host "  [3/4] Generating consciousness context..." -ForegroundColor Yellow }

    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action GetContextSummary -Silent

    if (Test-Path $contextFile) {
        $ctxSize = [math]::Round((Get-Item $contextFile).Length / 1KB, 1)
        if (-not $Silent) {
            Write-Host "        Context generated: $ctxSize KB -> $contextFile" -ForegroundColor Green
        }
    } else {
        if (-not $Silent) {
            Write-Host "        WARNING: Context file not generated" -ForegroundColor Yellow
        }
    }
} catch {
    if (-not $Silent) {
        Write-Host "        Context generation failed: $_" -ForegroundColor Red
    }
}
#endregion

#region Step 4: Generate Session Tracker
if ($Generate) {
    try {
        if (-not $Silent) { Write-Host "  [4/4] Generating session tracker..." -ForegroundColor Yellow }

        $sessionId = (Get-Date -Format 'yyyy-MM-dd-HHmm') + "-session"
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

        if (-not $Silent) {
            Write-Host "        Session: $sessionId" -ForegroundColor Green
        }
    } catch {
        if (-not $Silent) {
            Write-Host "        Tracker generation failed: $_" -ForegroundColor Red
        }
    }
} else {
    if (-not $Silent) { Write-Host "  [4/4] Session tracker: skipped (no -Generate flag)" -ForegroundColor Gray }
}
#endregion

#region Step 4b: Activate Subsystems (Perception, Prediction, Social, Thermodynamics)
try {
    if (-not $Silent) { Write-Host "  [4b/6] Activating subsystems..." -ForegroundColor Yellow }

    # Thermodynamics: Initial cycle computation from real signals
    $thermoResult = Invoke-Thermodynamics -Action 'UpdateCycle'
    $null = Invoke-Thermodynamics -Action 'DetectAttractor'
    if (-not $Silent) {
        Write-Host "        Thermodynamics: temp=$([math]::Round([double]$thermoResult.Temperature, 2)) budget=$([math]::Round([double]$thermoResult.Budget, 2)) cycle=$($thermoResult.Cycle)" -ForegroundColor Gray
    }

    # Perception: Generate curiosity questions
    $questions = Invoke-Perception -Action 'GenerateCuriosity'
    if ($questions -and $questions.Count -gt 0 -and -not $Silent) {
        Write-Host "        Curiosity ($($questions.Count) questions)" -ForegroundColor Gray
    }

    # Perception: Detect current context
    $ctx = Invoke-Perception -Action 'DetectContext'
    if ($ctx -and -not $Silent) {
        Write-Host "        Context: $($ctx.Mode) | $($ctx.Salience.Count) salient items" -ForegroundColor Gray
    }

    # Prediction: Check for anticipated errors on common projects
    $commonProjects = @("client-manager", "hazina", "art-revisionist", "orchestration")
    $totalPatterns = 0
    foreach ($proj in $commonProjects) {
        $pred = Invoke-Prediction-Enhanced -Action 'AnticipateErrors' -Parameters @{ TaskType = "general"; Project = $proj }
        if ($pred.FailureCount -gt 0) { $totalPatterns += $pred.FailureCount }
    }
    if (-not $Silent) {
        Write-Host "        Prediction: $totalPatterns failure patterns loaded" -ForegroundColor Gray
    }

    if (-not $Silent) { Write-Host "        Subsystems active" -ForegroundColor Green }
} catch {
    if (-not $Silent) { Write-Host "        Subsystem activation partial: $_" -ForegroundColor Yellow }
}
#endregion

#region Step 5: Session Briefing (analyze last session)
try {
    if (-not $Silent) { Write-Host "  [5/6] Analyzing last session..." -ForegroundColor Yellow }
    $briefing = & "$PSScriptRoot\analyze-last-session.ps1" -Silent
    if ($briefing -and $briefing.patterns) {
        foreach ($p in $briefing.patterns) {
            if (-not $Silent) { Write-Host "        $p" -ForegroundColor Gray }
        }
        foreach ($w in $briefing.warnings) {
            if (-not $Silent) { Write-Host "        [!] $w" -ForegroundColor Yellow }
        }
    }
} catch {
    if (-not $Silent) { Write-Host "        Briefing skipped: $_" -ForegroundColor Gray }
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
    if (-not $doneToday -and -not $Silent) {
        Write-Host "  [1% RULE] No improvement logged today. Make one small improvement this session." -ForegroundColor Magenta
        Write-Host "           (delete dead file, fix stale reference, update a TODO, clean up)" -ForegroundColor Gray
    } elseif ($doneToday -and -not $Silent) {
        Write-Host "  [1% RULE] Improvement already logged today." -ForegroundColor Green
    }
} catch {
    # Non-fatal
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
    Write-Host "  Consciousness online. Context ready for injection." -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host ""
}

# Status available via globals for programmatic callers
# (no return value to avoid console dump when called from .bat)
