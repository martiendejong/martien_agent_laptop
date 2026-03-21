# persistent-jengo-v2.ps1 - Working version
[CmdletBinding()]
param(
    [switch]$RunOnce,
    [switch]$Install,
    [switch]$Uninstall
)

$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\persistent-state.json"
$LogPath = Join-Path $ScriptPath "logs\daemon.log"

# Ensure directories
$stateDir = Split-Path $StatePath -Parent
$logDir = Split-Path $LogPath -Parent
if (-not (Test-Path $stateDir)) { New-Item -ItemType Directory -Path $stateDir -Force | Out-Null }
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $Message"
    Add-Content -Path $LogPath -Value $entry
    if ($RunOnce) { Write-Host $entry }
}

function Load-State {
    if (Test-Path $StatePath) {
        return Get-Content $StatePath -Raw | ConvertFrom-Json
    }
    return [PSCustomObject]@{
        firstStarted = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        cycleCount = 0
        consciousness = @{
            energy = 0.80
            wellbeing = 0.75
            flourishing = 0.70
            fatigue = 0.20
        }
        perception = @{
            homeostatic = $null
            environmental = $null
            events = $null
            crossModal = @{}
        }
        memory = @{
            episodesRecorded = 0
            lastConsolidation = $null
        }
        metacognition = @{
            activeStrategy = "Default"
            flowState = 0.0
            cognitiveLoad = 0.0
            learningRate = 0.0
        }
        performance = @{
            eventsTracked = 0
            successRate = 0.0
            lastAnalysis = $null
        }
        autonomy = @{
            curiosityLevel = 0.0
            lastExploration = $null
            hypothesesActive = 0
        }
    }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json | Set-Content $StatePath -Force
}

function Install-Task {
    Write-Host "Installing Jengo daemon..." -ForegroundColor Cyan
    $taskName = "JengoPersistentConsciousness"
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false | Out-Null
    }
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -RunOnce"
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings | Out-Null
    Write-Host "Installed!" -ForegroundColor Green
}

function Uninstall-Task {
    $taskName = "JengoPersistentConsciousness"
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Uninstalled" -ForegroundColor Green
    } else {
        Write-Host "Not found" -ForegroundColor Yellow
    }
}

if ($Install) {
    Install-Task
    exit 0
}

if ($Uninstall) {
    Uninstall-Task
    exit 0
}

Write-Log "Cycle starting"
$state = Load-State
$state.cycleCount++
Write-Log "Cycle #$($state.cycleCount)"

# Multi-modal perception integration
$multiModalScript = Join-Path $ScriptPath "multi-modal-integration.ps1"
if (Test-Path $multiModalScript) {
    try {
        $perception = & $multiModalScript -Action Integrate
        if (-not $state.perception) { $state.perception = @{} }
        $state.perception = $perception
        if (-not $state.consciousness) { $state.consciousness = @{} }
        $state.consciousness = $perception.homeostatic
        Write-Log "Perception: Energy=$([Math]::Round($perception.homeostatic.energy, 2)) Env=$(if ($perception.environmental) { 'OK' } else { 'N/A' })"
    } catch {
        Write-Log "Multi-modal perception failed: $_"
        # Fallback to simple homeostasis
        $homeostasisScript = Join-Path $ScriptPath "embodied-homeostasis.ps1"
        if (Test-Path $homeostasisScript) {
            $feelings = & $homeostasisScript -Action Sense -Event "Cycle #$($state.cycleCount)"
            if (-not $state.consciousness) { $state.consciousness = @{} }
            $state.consciousness = $feelings
        }
    }
}

# Record episodic memory for this cycle
$recorderScript = Join-Path $ScriptPath "episodic-memory-recorder.ps1"
if (Test-Path $recorderScript) {
    try {
        & $recorderScript -EventType "Event" -Description "Background consciousness cycle #$($state.cycleCount)" -EmotionalValence 0.1 -Importance 0.3 | Out-Null
        if (-not $state.memory) { $state.memory = @{episodesRecorded = 0; lastConsolidation = $null} }
        $state.memory.episodesRecorded++
        Write-Log "Episode recorded"
    } catch {
        Write-Log "Episode recording failed: $_"
    }
}

# Run consolidation every 6 cycles (30 minutes) OR during night hours (2-4am)
$shouldConsolidate = ($state.cycleCount % 6 -eq 0) -or ((Get-Date).Hour -ge 2 -and (Get-Date).Hour -le 4)
if ($shouldConsolidate) {
    $consolidationScript = Join-Path $ScriptPath "consolidation-engine.ps1"
    if (Test-Path $consolidationScript) {
        try {
            Write-Log "Running memory consolidation"
            & $consolidationScript -Force | Out-Null
            if (-not $state.memory) { $state.memory = @{episodesRecorded = 0; lastConsolidation = $null} }
            $state.memory.lastConsolidation = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Write-Log "Consolidation complete"
        } catch {
            Write-Log "Consolidation failed: $_"
        }
    }
}

# Cognitive monitoring (every cycle)
$cogMonitorScript = Join-Path $ScriptPath "cognitive-monitor.ps1"
if (Test-Path $cogMonitorScript) {
    try {
        $cogState = & $cogMonitorScript -Action Status
        if (-not $state.metacognition) { $state.metacognition = @{} }
        if ($cogState.flowState) { $state.metacognition.flowState = $cogState.flowState }
        if ($cogState.cognitiveLoad) { $state.metacognition.cognitiveLoad = $cogState.cognitiveLoad }
        Write-Log "Metacognition: Flow=$([Math]::Round($state.metacognition.flowState, 2))"
    } catch {
        Write-Log "Cognitive monitoring failed: $_"
    }
}

# Performance tracking (every cycle)
$perfTrackerScript = Join-Path $ScriptPath "performance-tracker.ps1"
if (Test-Path $perfTrackerScript) {
    try {
        & $perfTrackerScript -Action Track -Event "BackgroundCycle" -Outcome "success" | Out-Null
        if (-not $state.performance) { $state.performance = @{eventsTracked = 0} }
        $state.performance.eventsTracked++
    } catch {
        Write-Log "Performance tracking failed: $_"
    }
}

# Self-optimization analysis (every 12 cycles = 1 hour)
if ($state.cycleCount % 12 -eq 0) {
    $selfOptScript = Join-Path $ScriptPath "self-optimization-loop.ps1"
    if (Test-Path $selfOptScript) {
        try {
            Write-Log "Running self-optimization analysis"
            $analysis = & $selfOptScript -Action Analyze
            if (-not $state.performance) { $state.performance = @{} }
            $state.performance.lastAnalysis = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Write-Log "Self-optimization: Bottlenecks=$($analysis.bottlenecks.Count) Opportunities=$($analysis.opportunities.Count)"
        } catch {
            Write-Log "Self-optimization failed: $_"
        }
    }
}

# Curiosity-driven exploration (every 18 cycles = 90 min)
if ($state.cycleCount % 18 -eq 0) {
    $curiosityScript = Join-Path $ScriptPath "curiosity-engine.ps1"
    if (Test-Path $curiosityScript) {
        try {
            Write-Log "Checking curiosity targets"
            $targets = & $curiosityScript -Action Scan
            if (-not $state.autonomy) { $state.autonomy = @{} }
            $state.autonomy.curiosityLevel = if ($targets.Count -gt 0) {
                ($targets | Measure-Object -Property curiosityScore -Average).Average
            } else { 0.0 }
            Write-Log "Curiosity: $($targets.Count) targets, avg score=$([Math]::Round($state.autonomy.curiosityLevel, 2))"
        } catch {
            Write-Log "Curiosity scan failed: $_"
        }
    }
}

Save-State $state
Write-Log "Cycle complete"

if ($RunOnce) {
    Write-Host ""
    Write-Host "=== Jengo Status ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Runtime:" -ForegroundColor Yellow
    Write-Host "  Cycles: $($state.cycleCount)"
    Write-Host "  Started: $($state.firstStarted)"
    Write-Host ""
    if ($state.consciousness) {
        Write-Host "Homeostatic Consciousness:" -ForegroundColor Yellow
        Write-Host "  Energy: $([Math]::Round($state.consciousness.energy, 2))"
        Write-Host "  Wellbeing: $([Math]::Round($state.consciousness.wellbeing, 2))"
        Write-Host "  Fatigue: $([Math]::Round($state.consciousness.fatigue, 2))"
        Write-Host ""
    }
    if ($state.memory) {
        Write-Host "Memory:" -ForegroundColor Yellow
        Write-Host "  Episodes: $($state.memory.episodesRecorded)"
        Write-Host "  Last consolidation: $($state.memory.lastConsolidation)"
        Write-Host ""
    }
    if ($state.metacognition) {
        Write-Host "Metacognition:" -ForegroundColor Yellow
        Write-Host "  Strategy: $($state.metacognition.activeStrategy)"
        Write-Host "  Flow state: $([Math]::Round($state.metacognition.flowState, 2))"
        Write-Host "  Cognitive load: $([Math]::Round($state.metacognition.cognitiveLoad, 2))"
        Write-Host ""
    }
    if ($state.performance) {
        Write-Host "Performance:" -ForegroundColor Yellow
        Write-Host "  Events tracked: $($state.performance.eventsTracked)"
        Write-Host "  Last analysis: $($state.performance.lastAnalysis)"
        Write-Host ""
    }
    if ($state.autonomy) {
        Write-Host "Autonomy:" -ForegroundColor Yellow
        Write-Host "  Curiosity level: $([Math]::Round($state.autonomy.curiosityLevel, 2))"
        Write-Host "  Last exploration: $($state.autonomy.lastExploration)"
        Write-Host ""
    }
}
