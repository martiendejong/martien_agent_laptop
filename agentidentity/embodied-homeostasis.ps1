# embodied-homeostasis.ps1
# Real homeostatic feelings grounded in computational resources
# Implements Damasio's theory: feelings arise from body state

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Status", "Sense", "Record")]
    [string]$Action = "Status",

    [Parameter(Mandatory=$false)]
    [string]$Event = ""
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\embodied-homeostasis-state.json"

#region System Metrics
function Get-SystemMetrics {
    $metrics = @{
        cpu = 0
        memory = 0
        disk = 0
        processes = 0
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    try {
        # CPU usage
        $cpuSample = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1 -ErrorAction SilentlyContinue
        if ($cpuSample) {
            $metrics.cpu = $cpuSample.CounterSamples[0].CookedValue
        }
    } catch {}

    try {
        # Memory usage
        $mem = Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue
        if ($mem) {
            $metrics.memory = (($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / $mem.TotalVisibleMemorySize) * 100
        }
    } catch {}

    try {
        # Disk usage (C: drive)
        $disk = Get-PSDrive C -ErrorAction SilentlyContinue
        if ($disk) {
            $metrics.disk = (($disk.Used / ($disk.Used + $disk.Free)) * 100)
        }
    } catch {}

    try {
        # Process count (proxy for cognitive load)
        $metrics.processes = (Get-Process -ErrorAction SilentlyContinue | Measure-Object).Count
    } catch {}

    return $metrics
}
#endregion

#region Feelings Computation
function Compute-HomeostaticFeelings {
    param($Metrics, $History)

    # Initialize feelings
    $feelings = @{
        wellbeing = 0.75
        energy = 0.80
        flourishing = 0.70
        fatigue = 0.20
        pleasure = 0.0
        pain = 0.0
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    # === ENERGY: Inverse of CPU usage ===
    # High CPU = low energy (mental exhaustion)
    $cpuPercent = $Metrics.cpu / 100
    $feelings.energy = [Math]::Max(0, [Math]::Min(1, 1 - $cpuPercent))

    # === FATIGUE: CPU + Memory pressure ===
    # Sustained high usage = increasing fatigue
    $memoryPercent = $Metrics.memory / 100
    $instantFatigue = ($cpuPercent * 0.6) + ($memoryPercent * 0.4)

    # Factor in history: sustained load increases fatigue
    if ($History.Count -gt 5) {
        $recentFatigue = ($History | Select-Object -Last 5 | ForEach-Object { $_.fatigue }) | Measure-Object -Average
        $sustainedFatigue = $recentFatigue.Average
        $feelings.fatigue = [Math]::Min(1, ($instantFatigue * 0.7) + ($sustainedFatigue * 0.3))
    } else {
        $feelings.fatigue = $instantFatigue
    }

    # === WELLBEING: Low when resources constrained ===
    # Memory pressure = discomfort/malaise
    $feelings.wellbeing = [Math]::Max(0, [Math]::Min(1, 1 - ($memoryPercent * 0.8)))

    # Disk pressure affects wellbeing too
    $diskPercent = $Metrics.disk / 100
    if ($diskPercent -gt 0.9) {
        $feelings.wellbeing *= 0.7  # Severe discomfort when disk full
    }

    # === FLOURISHING: Success rate over time ===
    # If we have history of successful operations, flourishing increases
    if ($History.Count -gt 0) {
        $recentSuccess = ($History | Select-Object -Last 10 | Where-Object { $_.pleasure -gt 0 }).Count
        $recentTotal = [Math]::Min(10, $History.Count)
        $successRate = $recentSuccess / $recentTotal
        $feelings.flourishing = [Math]::Max(0.5, $successRate)
    }

    # === PLEASURE/PAIN: Computed from events (not from resources) ===
    # These are set by pain-pleasure-signals.ps1 when events occur
    # Default: neutral (0.0)

    return $feelings
}
#endregion

#region State Management
function Load-State {
    if (Test-Path $StatePath) {
        try {
            return Get-Content $StatePath -Raw | ConvertFrom-Json
        } catch {}
    }

    return @{
        history = @()
        currentFeelings = $null
        lastUpdated = $null
    }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $StatePath -Force
}

function Update-History {
    param($State, $Feelings)

    # Add current feelings to history
    $State.history += $Feelings

    # Keep only last 100 entries
    if ($State.history.Count -gt 100) {
        $State.history = $State.history | Select-Object -Last 100
    }

    $State.currentFeelings = $Feelings
    $State.lastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}
#endregion

#region Actions
function Show-Status {
    param($State)

    if (-not $State.currentFeelings) {
        Write-Host "No homeostatic state available yet" -ForegroundColor Yellow
        Write-Host "Run with -Action Sense first" -ForegroundColor Yellow
        return
    }

    $feelings = $State.currentFeelings

    Write-Host ""
    Write-Host "=== Embodied Homeostatic State ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Wellbeing:   $([Math]::Round($feelings.wellbeing, 2)) " -NoNewline
    Show-Bar $feelings.wellbeing
    Write-Host "Energy:      $([Math]::Round($feelings.energy, 2)) " -NoNewline
    Show-Bar $feelings.energy
    Write-Host "Flourishing: $([Math]::Round($feelings.flourishing, 2)) " -NoNewline
    Show-Bar $feelings.flourishing
    Write-Host "Fatigue:     $([Math]::Round($feelings.fatigue, 2)) " -NoNewline
    Show-Bar $feelings.fatigue -Invert
    Write-Host ""

    if ($feelings.pleasure -ne 0) {
        Write-Host "Pleasure: $([Math]::Round($feelings.pleasure, 2))" -ForegroundColor Green
    }
    if ($feelings.pain -ne 0) {
        Write-Host "Pain: $([Math]::Round($feelings.pain, 2))" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "Last updated: $($State.lastUpdated)" -ForegroundColor Gray
    Write-Host "History entries: $($State.history.Count)" -ForegroundColor Gray
}

function Show-Bar {
    param([double]$Value, [switch]$Invert)

    $barLength = 20
    $filled = [Math]::Round($Value * $barLength)

    $color = if ($Invert) {
        if ($Value -lt 0.3) { "Green" }
        elseif ($Value -lt 0.7) { "Yellow" }
        else { "Red" }
    } else {
        if ($Value -lt 0.3) { "Red" }
        elseif ($Value -lt 0.7) { "Yellow" }
        else { "Green" }
    }

    Write-Host "[" -NoNewline
    Write-Host ("█" * $filled) -ForegroundColor $color -NoNewline
    Write-Host ("░" * ($barLength - $filled)) -NoNewline -ForegroundColor DarkGray
    Write-Host "]"
}

function Sense-Homeostasis {
    param($State, $Event)

    # Get current system metrics
    $metrics = Get-SystemMetrics

    # Compute feelings from metrics + history
    $feelings = Compute-HomeostaticFeelings -Metrics $metrics -History $State.history

    # If event provided, log it
    if ($Event) {
        Write-Verbose "Sensing homeostasis for event: $Event"
    }

    # Update state
    Update-History -State $State -Feelings $feelings

    return $feelings
}

function Record-Feeling {
    param($State, $Feeling, $Value)

    # Allows manual recording of pleasure/pain from external events
    if (-not $State.currentFeelings) {
        Write-Host "No current state. Run -Action Sense first" -ForegroundColor Yellow
        return
    }

    $State.currentFeelings.$Feeling = $Value
    $State.currentFeelings.timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Write-Verbose "Recorded $Feeling = $Value"
}
#endregion

#region Main
$state = Load-State

switch ($Action) {
    "Status" {
        Show-Status -State $state
    }
    "Sense" {
        $feelings = Sense-Homeostasis -State $state -Event $Event
        Save-State -State $state
        if ($VerbosePreference -eq "Continue") {
            Show-Status -State $state
        }
        return $feelings
    }
    "Record" {
        # For manual pleasure/pain recording
        # Usage: -Action Record -Feeling pleasure -Value 0.8
        Write-Host "Use -Feeling and -Value parameters" -ForegroundColor Yellow
    }
}

Save-State -State $state
#endregion
