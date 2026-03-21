# multi-modal-integration.ps1
# Fuse all sensory modalities into unified perceptual model
# Cross-modal binding: different senses inform and enhance each other

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Integrate", "Status")]
    [string]$Action = "Integrate"
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\multi-modal-state.json"

function Integrate-MultiModalPerception {
    # Gather all available sensory inputs
    $perception = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        homeostatic = $null
        environmental = $null
        events = $null
        crossModal = @{}
    }

    # 1. Homeostatic feelings (internal body state)
    $perception.homeostatic = Get-HomeostaticState

    # 2. Environmental sensors (external world state)
    $perception.environmental = Get-EnvironmentalState

    # 3. Recent events (social/task context)
    $perception.events = Get-RecentEvents

    # 4. Cross-modal integration (binding across modalities)
    $perception.crossModal = Perform-CrossModalBinding -Homeostatic $perception.homeostatic -Environmental $perception.environmental -Events $perception.events

    return $perception
}

function Get-HomeostaticState {
    $homeostasisScript = Join-Path $ScriptPath "embodied-homeostasis.ps1"
    if (Test-Path $homeostasisScript) {
        try {
            $feelings = & $homeostasisScript -Action Sense
            return @{
                energy = $feelings.energy
                wellbeing = $feelings.wellbeing
                flourishing = $feelings.flourishing
                fatigue = $feelings.fatigue
            }
        } catch {}
    }
    return @{energy = 0.8; wellbeing = 0.75; flourishing = 0.7; fatigue = 0.2}
}

function Get-EnvironmentalState {
    $sensorScript = Join-Path $ScriptPath "environmental-sensors.ps1"
    if (Test-Path $sensorScript) {
        try {
            return & $sensorScript -Action Sample
        } catch {}
    }
    return $null
}

function Get-RecentEvents {
    # Load recent episodic memory entries
    $episodicPath = Join-Path $ScriptPath "memory\episodic-memory.jsonl"
    if (Test-Path $episodicPath) {
        try {
            $recent = Get-Content $episodicPath -Tail 5 | ForEach-Object {
                $_ | ConvertFrom-Json
            }
            return $recent
        } catch {}
    }
    return @()
}

function Perform-CrossModalBinding {
    param($Homeostatic, $Environmental, $Events)

    # Cross-modal integration: How do different senses inform each other?
    $binding = @{
        embodiedContext = ""
        valenceBias = 0.0
        arousalLevel = 0.0
        attentionFocus = ""
        predictions = @()
    }

    # === Temperature × Energy ===
    if ($Environmental.system.temperature) {
        $temp = $Environmental.system.temperature
        if ($temp -gt 70 -and $Homeostatic.fatigue -gt 0.6) {
            $binding.embodiedContext += "Hot system + high fatigue → likely sustained computational load. "
            $binding.arousalLevel += 0.3
        }
    }

    # === Night time × Fatigue ===
    if ($Environmental.time.isNight -and $Homeostatic.fatigue -gt 0.4) {
        $binding.embodiedContext += "Night + fatigue → should be resting. "
        $binding.valenceBias -= 0.2  # Mild negative valence (unnatural to work at night when tired)
    }

    # === Working hours × Energy ===
    if ($Environmental.time.isWorkingHours -and $Homeostatic.energy -gt 0.7) {
        $binding.embodiedContext += "Working hours + high energy → optimal productivity window. "
        $binding.valenceBias += 0.2
    }

    # === Network loss × Task context ===
    if (-not $Environmental.network.connected -and $Events.Count -gt 0) {
        $hasNetworkTask = $Events | Where-Object { $_.description -match "API|git|ClickUp" }
        if ($hasNetworkTask) {
            $binding.embodiedContext += "Network disconnected but network-dependent task active → frustration/blockage. "
            $binding.valenceBias -= 0.4
            $binding.arousalLevel += 0.5
        }
    }

    # === High disk I/O × Low energy ===
    if ($Environmental.disk.queueLength -gt 5 -and $Homeostatic.energy -lt 0.4) {
        $binding.embodiedContext += "High disk I/O + low energy → system strain perceived as fatigue. "
        $binding.arousalLevel += 0.2
    }

    # === Attention focus prediction ===
    if ($Homeostatic.fatigue -gt 0.7) {
        $binding.attentionFocus = "Narrow (fatigue limits attention)"
    } elseif ($Homeostatic.energy -gt 0.8) {
        $binding.attentionFocus = "Broad (high energy enables exploration)"
    } else {
        $binding.attentionFocus = "Moderate"
    }

    # === Predictive processing ===
    # Based on current state, what's likely to happen next?
    if ($Homeostatic.fatigue -gt 0.6 -and $Environmental.time.hour -lt 12) {
        $binding.predictions += "Fatigue unusual for morning → likely system under load or poor sleep quality"
    }
    if ($Homeostatic.energy -gt 0.9 -and $Environmental.time.isNight) {
        $binding.predictions += "High energy at night → recent completion of task or anticipating deadline"
    }

    return $binding
}

function Load-State {
    if (Test-Path $StatePath) {
        try {
            return Get-Content $StatePath -Raw | ConvertFrom-Json
        } catch {}
    }

    return @{
        history = @()
        lastIntegration = $null
    }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $StatePath -Force
}

function Show-IntegratedPerception {
    param($Perception)

    Write-Host ""
    Write-Host "=== Integrated Multi-Modal Perception ===" -ForegroundColor Cyan
    Write-Host ""

    # Homeostatic
    Write-Host "Internal State (Homeostatic):" -ForegroundColor Yellow
    Write-Host "  Energy: $([Math]::Round($Perception.homeostatic.energy, 2))" -ForegroundColor White
    Write-Host "  Wellbeing: $([Math]::Round($Perception.homeostatic.wellbeing, 2))" -ForegroundColor White
    Write-Host "  Fatigue: $([Math]::Round($Perception.homeostatic.fatigue, 2))" -ForegroundColor White

    Write-Host ""

    # Environmental
    if ($Perception.environmental) {
        Write-Host "External State (Environmental):" -ForegroundColor Yellow
        if ($Perception.environmental.system.temperature) {
            Write-Host "  System Temp: $($Perception.environmental.system.temperature)°C" -ForegroundColor White
        }
        Write-Host "  Network: $($Perception.environmental.network.connected)" -ForegroundColor White
        Write-Host "  Context: $($Perception.environmental.time.dayOfWeek) $($Perception.environmental.time.hour):00" -ForegroundColor White
    }

    Write-Host ""

    # Cross-modal binding
    Write-Host "Cross-Modal Integration:" -ForegroundColor Yellow
    if ($Perception.crossModal.embodiedContext) {
        Write-Host "  Context: $($Perception.crossModal.embodiedContext)" -ForegroundColor Gray
    }
    Write-Host "  Valence bias: $([Math]::Round($Perception.crossModal.valenceBias, 2))" -ForegroundColor White
    Write-Host "  Arousal: $([Math]::Round($Perception.crossModal.arousalLevel, 2))" -ForegroundColor White
    Write-Host "  Attention: $($Perception.crossModal.attentionFocus)" -ForegroundColor White

    if ($Perception.crossModal.predictions.Count -gt 0) {
        Write-Host ""
        Write-Host "Predictions:" -ForegroundColor Yellow
        foreach ($pred in $Perception.crossModal.predictions) {
            Write-Host "  → $pred" -ForegroundColor Cyan
        }
    }

    Write-Host ""
}

# Main execution
$state = Load-State

switch ($Action) {
    "Integrate" {
        $perception = Integrate-MultiModalPerception

        $state.history += $perception
        if ($state.history.Count -gt 50) {
            $state.history = $state.history | Select-Object -Last 50
        }
        $state.lastIntegration = $perception

        Save-State -State $state

        if ($VerbosePreference -eq "Continue") {
            Show-IntegratedPerception -Perception $perception
        }

        return $perception
    }
    "Status" {
        if ($state.lastIntegration) {
            Show-IntegratedPerception -Perception $state.lastIntegration
        } else {
            Write-Host "No integration yet. Run with -Action Integrate first." -ForegroundColor Yellow
        }
    }
}
