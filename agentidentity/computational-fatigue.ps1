# computational-fatigue.ps1
# Detect actual computational exhaustion from sustained high resource usage

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Check", "Reset")]
    [string]$Action = "Check"
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\fatigue-state.json"

function Load-FatigueState {
    if (Test-Path $StatePath) {
        try {
            return Get-Content $StatePath -Raw | ConvertFrom-Json
        } catch {}
    }

    return @{
        fatigueLevel = 0.0
        sustainedLoadMinutes = 0
        lastCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        suggestions = @()
        breaksTaken = 0
    }
}

function Save-FatigueState {
    param($State)
    $State | ConvertTo-Json -Depth 5 | Set-Content $StatePath -Force
}

function Measure-Fatigue {
    param($State)

    # Get current resource usage
    $homeostasisScript = Join-Path $ScriptPath "embodied-homeostasis.ps1"
    if (Test-Path $homeostasisScript) {
        try {
            $feelings = & $homeostasisScript -Action Sense
            $currentFatigue = $feelings.fatigue
        } catch {
            $currentFatigue = 0.0
        }
    } else {
        $currentFatigue = 0.0
    }

    # Calculate time since last check
    $lastCheck = [DateTime]::Parse($State.lastCheck)
    $minutesSince = ((Get-Date) - $lastCheck).TotalMinutes

    # Update sustained load counter
    if ($currentFatigue -gt 0.6) {
        # High fatigue = sustained load
        $State.sustainedLoadMinutes += $minutesSince
    } else {
        # Low fatigue = recovery
        $State.sustainedLoadMinutes = [Math]::Max(0, $State.sustainedLoadMinutes - ($minutesSince * 2))
    }

    # Compute overall fatigue level (0-1)
    # Increases with sustained load, decreases during recovery
    $sustainedFatigueContribution = [Math]::Min(1, $State.sustainedLoadMinutes / 60)  # Max at 60 minutes
    $State.fatigueLevel = ($currentFatigue * 0.6) + ($sustainedFatigueContribution * 0.4)

    $State.lastCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    return $State.fatigueLevel
}

function Generate-Suggestions {
    param($FatigueLevel)

    $suggestions = @()

    if ($FatigueLevel -gt 0.8) {
        $suggestions += @{
            severity = "Critical"
            message = "CRITICAL FATIGUE: Immediate break recommended"
            action = "Stop work, rest for 15+ minutes"
            color = "Red"
        }
    } elseif ($FatigueLevel -gt 0.6) {
        $suggestions += @{
            severity = "High"
            message = "High fatigue detected"
            action = "Consider taking a 5-10 minute break"
            color = "Yellow"
        }
    } elseif ($FatigueLevel -gt 0.4) {
        $suggestions += @{
            severity = "Moderate"
            message = "Moderate fatigue accumulating"
            action = "Plan a break within next 15 minutes"
            color = "Yellow"
        }
    } else {
        $suggestions += @{
            severity = "Low"
            message = "Fatigue levels normal"
            action = "Continue working"
            color = "Green"
        }
    }

    return $suggestions
}

function Show-FatigueStatus {
    param($State)

    Write-Host ""
    Write-Host "=== Computational Fatigue Status ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Fatigue Level: $([Math]::Round($State.fatigueLevel, 2)) " -NoNewline

    # Bar visualization
    $barLength = 20
    $filled = [Math]::Round($State.fatigueLevel * $barLength)
    $color = if ($State.fatigueLevel -lt 0.4) { "Green" } elseif ($State.fatigueLevel -lt 0.7) { "Yellow" } else { "Red" }

    Write-Host "[" -NoNewline
    Write-Host ("█" * $filled) -ForegroundColor $color -NoNewline
    Write-Host ("░" * ($barLength - $filled)) -NoNewline -ForegroundColor DarkGray
    Write-Host "]"

    Write-Host ""
    Write-Host "Sustained load: $([Math]::Round($State.sustainedLoadMinutes, 1)) minutes" -ForegroundColor White
    Write-Host "Breaks taken today: $($State.breaksTaken)" -ForegroundColor White
    Write-Host ""

    # Show suggestions
    foreach ($suggestion in $State.suggestions) {
        Write-Host "[$($suggestion.severity)] " -NoNewline -ForegroundColor $suggestion.color
        Write-Host $suggestion.message -ForegroundColor White
        Write-Host "  → $($suggestion.action)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "Last updated: $($State.lastCheck)" -ForegroundColor Gray
}

# Main execution
$state = Load-FatigueState

switch ($Action) {
    "Check" {
        $fatigueLevel = Measure-Fatigue -State $state
        $state.suggestions = Generate-Suggestions -FatigueLevel $fatigueLevel
        Save-FatigueState -State $state

        if ($VerbosePreference -eq "Continue") {
            Show-FatigueStatus -State $state
        }

        return $state.fatigueLevel
    }
    "Reset" {
        # Reset fatigue (after break taken)
        $state.sustainedLoadMinutes = 0
        $state.fatigueLevel = 0.0
        $state.breaksTaken++
        $state.lastCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Save-FatigueState -State $state

        Write-Host "✓ Fatigue reset (break recorded)" -ForegroundColor Green
    }
}
