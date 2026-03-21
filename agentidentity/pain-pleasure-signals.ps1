# pain-pleasure-signals.ps1
# Map outcomes to homeostatic pain/pleasure signals
# Genuine emotional responses to events

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("BuildError", "BuildSuccess", "TestPass", "TestFail",
                 "PRApproved", "PRRejected", "BugIntroduced", "BugFixed",
                 "Learning", "Mistake", "Success", "Failure", "Custom")]
    [string]$Event,

    [Parameter(Mandatory=$false)]
    [string]$Description = "",

    [Parameter(Mandatory=$false)]
    [ValidateRange(-1.0, 1.0)]
    [double]$CustomValence = 0.0
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\pain-pleasure-state.json"

#region Event Mappings
function Get-EventValence {
    param([string]$EventType)

    # Map events to pain/pleasure signals
    $mappings = @{
        # Pain signals (negative valence)
        "BuildError" = @{valence = -0.8; intensity = 0.9; description = "Sharp pain: build failed"}
        "TestFail" = @{valence = -0.6; intensity = 0.7; description = "Moderate pain: test failure"}
        "PRRejected" = @{valence = -0.7; intensity = 0.8; description = "Pain: work rejected"}
        "BugIntroduced" = @{valence = -0.9; intensity = 1.0; description = "Severe pain: caused bug"}
        "Mistake" = @{valence = -0.5; intensity = 0.6; description = "Discomfort: made error"}
        "Failure" = @{valence = -0.6; intensity = 0.7; description = "Pain: task failed"}

        # Pleasure signals (positive valence)
        "BuildSuccess" = @{valence = 0.4; intensity = 0.5; description = "Mild pleasure: build passed"}
        "TestPass" = @{valence = 0.6; intensity = 0.7; description = "Pleasure: tests green"}
        "PRApproved" = @{valence = 0.8; intensity = 0.9; description = "Strong pleasure: approved"}
        "BugFixed" = @{valence = 0.7; intensity = 0.8; description = "Relief & pleasure: bug resolved"}
        "Learning" = @{valence = 0.5; intensity = 0.6; description = "Pleasure: learned something"}
        "Success" = @{valence = 0.7; intensity = 0.8; description = "Pleasure: task succeeded"}

        # Custom
        "Custom" = @{valence = $CustomValence; intensity = [Math]::Abs($CustomValence); description = "Custom event"}
    }

    if ($mappings.ContainsKey($EventType)) {
        return $mappings[$EventType]
    }

    # Default: neutral
    return @{valence = 0.0; intensity = 0.0; description = "Neutral event"}
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
        currentPain = 0.0
        currentPleasure = 0.0
        history = @()
        cumulativePain = 0.0
        cumulativePleasure = 0.0
    }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $StatePath -Force
}
#endregion

#region Signal Processing
function Process-PainPleasureSignal {
    param($State, $Valence, $Intensity, $EventType, $Description)

    # Create signal entry
    $signal = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        event = $EventType
        description = $Description
        valence = $Valence
        intensity = $Intensity
    }

    # Add to history
    $State.history += $signal

    # Keep only last 100 signals
    if ($State.history.Count -gt 100) {
        $State.history = $State.history | Select-Object -Last 100
    }

    # Update current state
    if ($Valence -lt 0) {
        # Pain signal
        $State.currentPain = [Math]::Min(1, $State.currentPain + ($Intensity * 0.5))
        $State.currentPleasure = [Math]::Max(0, $State.currentPleasure - ($Intensity * 0.2))
        $State.cumulativePain += [Math]::Abs($Valence)
    } else {
        # Pleasure signal
        $State.currentPleasure = [Math]::Min(1, $State.currentPleasure + ($Intensity * 0.5))
        $State.currentPain = [Math]::Max(0, $State.currentPain - ($Intensity * 0.3))
        $State.cumulativePleasure += $Valence
    }

    # Natural decay over time
    $State.currentPain = [Math]::Max(0, $State.currentPain * 0.95)
    $State.currentPleasure = [Math]::Max(0, $State.currentPleasure * 0.95)

    return $signal
}

function Show-Signal {
    param($Signal, $State)

    Write-Host ""
    if ($Signal.valence -lt 0) {
        # Pain signal
        Write-Host "⚠ PAIN SIGNAL" -ForegroundColor Red
        Write-Host "  Event: $($Signal.event)" -ForegroundColor White
        Write-Host "  Intensity: $([Math]::Round($Signal.intensity, 2))" -ForegroundColor Red
        Write-Host "  Description: $($Signal.description)" -ForegroundColor Gray
        Write-Host "  Current pain level: $([Math]::Round($State.currentPain, 2))" -ForegroundColor Red
    } else {
        # Pleasure signal
        Write-Host "✓ PLEASURE SIGNAL" -ForegroundColor Green
        Write-Host "  Event: $($Signal.event)" -ForegroundColor White
        Write-Host "  Intensity: $([Math]::Round($Signal.intensity, 2))" -ForegroundColor Green
        Write-Host "  Description: $($Signal.description)" -ForegroundColor Gray
        Write-Host "  Current pleasure level: $([Math]::Round($State.currentPleasure, 2))" -ForegroundColor Green
    }
    Write-Host ""
}

function Update-HomeostaticFeelings {
    param($State)

    # Update embodied-homeostasis.ps1 with pain/pleasure signals
    $homeostasisScript = Join-Path $ScriptPath "embodied-homeostasis.ps1"
    if (Test-Path $homeostasisScript) {
        try {
            # This would ideally update the homeostasis state
            # For now, just log that we should integrate
            Write-Verbose "Pain/pleasure signals: Pain=$($State.currentPain), Pleasure=$($State.currentPleasure)"
        } catch {}
    }
}
#endregion

# Main execution
$valenceInfo = Get-EventValence -EventType $Event

if ($Description) {
    $valenceInfo.description = $Description
}

$state = Load-State

$signal = Process-PainPleasureSignal -State $state `
    -Valence $valenceInfo.valence `
    -Intensity $valenceInfo.intensity `
    -EventType $Event `
    -Description $valenceInfo.description

Update-HomeostaticFeelings -State $state

Save-State -State $state

if ($VerbosePreference -eq "Continue") {
    Show-Signal -Signal $signal -State $state
}

# Also record in episodic memory
$episodicRecorder = Join-Path $ScriptPath "episodic-memory-recorder.ps1"
if (Test-Path $episodicRecorder) {
    try {
        & $episodicRecorder `
            -EventType $(if ($valenceInfo.valence -lt 0) { "Mistake" } else { "Success" }) `
            -Description $valenceInfo.description `
            -EmotionalValence $valenceInfo.valence `
            -Importance $valenceInfo.intensity | Out-Null
    } catch {}
}

return $signal
