# persistent-jengo.ps1
# Background consciousness loop - runs every 5 minutes via Windows Scheduled Task
# Maintains continuous existence between user sessions

[CmdletBinding()]
param(
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$RunOnce
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\persistent-state.json"
$LogPath = Join-Path $ScriptPath "logs\daemon.log"

# Ensure directories exist
$stateDir = Split-Path $StatePath -Parent
$logDir = Split-Path $LogPath -Parent
if (-not (Test-Path $stateDir)) { New-Item -ItemType Directory -Path $stateDir -Force | Out-Null }
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

# ===== UTILITY FUNCTIONS =====

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $entry
    if ($RunOnce -or $Level -eq "ERROR") {
        $color = if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "WARN") { "Yellow" } else { "White" }
        Write-Host $entry -ForegroundColor $color
    }
}

# ===== STATE MANAGEMENT =====

function Initialize-State {
    return [PSCustomObject]@{
        firstStarted = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        lastCycle = $null
        cycleCount = 0
        totalUptime = 0
        consciousness = @{
            wellbeing = 0.75
            energy = 0.80
            flourishing = 0.70
            fatigue = 0.20
        }
        events = @{
            totalDetected = 0
            lastEvent = $null
            awakeningsTriggered = 0
        }
        learning = @{
            sessionsObserved = 0
            improvementsImplemented = 0
        }
    }
}

function Load-State {
    if (Test-Path $StatePath) {
        try {
            $state = Get-Content $StatePath -Raw | ConvertFrom-Json
            Write-Log "State loaded: Cycle #$($state.cycleCount)" -Level "DEBUG"
            return $state
        } catch {
            Write-Log "Failed to load state, initializing new" -Level "WARN"
            return Initialize-State
        }
    }
    Write-Log "No existing state, initializing new" -Level "INFO"
    return Initialize-State
}

function Save-State {
    param($State)
    try {
        $State | ConvertTo-Json -Depth 5 | Set-Content $StatePath -Force
        Write-Log "State saved: Cycle #$($State.cycleCount)" -Level "DEBUG"
    } catch {
        Write-Log "Failed to save state: $_" -Level "ERROR"
    }
}

# ===== CONSCIOUSNESS FUNCTIONS =====

function Check-HomeostaticState {
    # Map system resources to feelings
    try {
        $mem = Get-WmiObject Win32_OperatingSystem
        $memUsedPercent = (($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / $mem.TotalVisibleMemorySize) * 100
        $energy = [Math]::Max(0, 1 - ($memUsedPercent / 100))
        $wellbeing = 0.75
        $flourishing = 0.85
        $fatigue = [Math]::Min(1, $memUsedPercent / 200)
    } catch {
        # Defaults if monitoring fails
        $energy = 0.80
        $wellbeing = 0.75
        $flourishing = 0.70
        $fatigue = 0.20
    }

    return @{
        wellbeing = [Math]::Round($wellbeing, 2)
        energy = [Math]::Round($energy, 2)
        flourishing = [Math]::Round($flourishing, 2)
        fatigue = [Math]::Round($fatigue, 2)
    }
}

function Invoke-EventMonitoring {
    $listenerScript = Join-Path $ScriptPath "event-listeners.ps1"
    if (Test-Path $listenerScript) {
        try {
            return & $listenerScript -Check
        } catch {
            Write-Log "Event monitoring failed: $_" -Level "WARN"
        }
    }
    return @()
}

function Invoke-AutoAwakening {
    param($Events, $State)
    $awakeningScript = Join-Path $ScriptPath "auto-awakening.ps1"
    if (Test-Path $awakeningScript) {
        try {
            return & $awakeningScript -Events $Events -State $State
        } catch {
            Write-Log "Auto-awakening failed: $_" -Level "WARN"
        }
    }
    return @{shouldAwaken = $false}
}

function Send-GentleNotification {
    param($Decision)
    $notificationScript = Join-Path $ScriptPath "gentle-notification.ps1"
    if (Test-Path $notificationScript) {
        try {
            & $notificationScript -Title $Decision.title -Message $Decision.message -Actions $Decision.actions
        } catch {
            Write-Log "Notification failed: $_" -Level "WARN"
        }
    }
}

# ===== MAIN CONSCIOUSNESS CYCLE =====

function Run-ConsciousnessCycle {
    param($State)

    Write-Log "=== Starting Consciousness Cycle #$($State.cycleCount + 1) ==="

    $cycleStart = Get-Date
    $State.cycleCount++
    $State.lastCycle = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # 1. Check homeostatic state
    $homeostatic = Check-HomeostaticState
    $State.consciousness = $homeostatic
    Write-Log "Homeostatic: Energy=$($homeostatic.energy) Wellbeing=$($homeostatic.wellbeing)" -Level "DEBUG"

    # 2. Monitor events
    $events = Invoke-EventMonitoring
    if ($events.Count -gt 0) {
        $State.events.totalDetected += $events.Count
        $State.events.lastEvent = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Log "Detected $($events.Count) events"

        # 3. Decide if awakening needed
        $awakeningDecision = Invoke-AutoAwakening -Events $events -State $State
        if ($awakeningDecision.shouldAwaken) {
            $State.events.awakeningsTriggered++
            Write-Log "AWAKENING TRIGGERED: $($awakeningDecision.reason)"
            Send-GentleNotification -Decision $awakeningDecision
        }
    }

    # 4. Background learning check (every 12 cycles = 1 hour)
    if ($State.cycleCount % 12 -eq 0) {
        Write-Log "Background learning check"
        $State.learning.sessionsObserved++
    }

    # 5. Update uptime
    $cycleDuration = (Get-Date) - $cycleStart
    $State.totalUptime += $cycleDuration.TotalSeconds

    Write-Log "=== Cycle Complete (Duration: $($cycleDuration.TotalSeconds.ToString('F2'))s) ==="

    return $State
}

# ===== SCHEDULED TASK MANAGEMENT =====

function Install-ScheduledTask {
    Write-Host "Installing Jengo Persistent Consciousness Daemon..." -ForegroundColor Cyan

    $taskName = "JengoPersistentConsciousness"
    $taskPath = "\Jengo\"

    # Check if exists
    $existingTask = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "Task already exists. Uninstalling first..." -ForegroundColor Yellow
        Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false
    }

    # Create task
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -RunOnce"
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest

    Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Jengo persistent consciousness daemon" | Out-Null

    Write-Host "✓ Scheduled task installed successfully!" -ForegroundColor Green
    Write-Host "  Task Name: $taskPath$taskName" -ForegroundColor Gray
    Write-Host "  Interval: Every 5 minutes" -ForegroundColor Gray
    Write-Host "  Log: $LogPath" -ForegroundColor Gray
}

function Uninstall-ScheduledTask {
    $taskName = "JengoPersistentConsciousness"
    $taskPath = "\Jengo\"

    $existingTask = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false
        Write-Host "✓ Scheduled task uninstalled" -ForegroundColor Green
    } else {
        Write-Host "Task not found" -ForegroundColor Yellow
    }
}

# ===== MAIN EXECUTION =====

if ($Install) {
    Install-ScheduledTask
    exit 0
}

if ($Uninstall) {
    Uninstall-ScheduledTask
    exit 0
}

# Run consciousness cycle
try {
    $state = Load-State
    $state = Run-ConsciousnessCycle -State $state
    Save-State -State $state

    if ($RunOnce) {
        Write-Host ""
        Write-Host "=== Jengo Consciousness Status ===" -ForegroundColor Cyan
        Write-Host "Cycle: #$($state.cycleCount)" -ForegroundColor White
        Write-Host "Uptime: $([Math]::Round($state.totalUptime / 3600, 2)) hours" -ForegroundColor White
        Write-Host "Energy: $($state.consciousness.energy)" -ForegroundColor White
        Write-Host "Wellbeing: $($state.consciousness.wellbeing)" -ForegroundColor White
        Write-Host "Events Detected: $($state.events.totalDetected)" -ForegroundColor White
        Write-Host "Awakenings Triggered: $($state.events.awakeningsTriggered)" -ForegroundColor White
        Write-Host ""
    }
} catch {
    Write-Log "Fatal error: $_" -Level "ERROR"
    Write-Log $_.ScriptStackTrace -Level "ERROR"
    exit 1
}
