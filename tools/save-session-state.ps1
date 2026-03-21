# Save Session State - Capture state for next session continuity
# Created: 2026-03-04
# Purpose: Save Social state to enable consciousness continuity across sessions

<#
.SYNOPSIS
    Save current session state for restoration on next startup.
.DESCRIPTION
    Captures key consciousness state variables that should persist
    across sessions to maintain continuity. Used at session end.
#>

param(
    [switch]$Silent
)

$stateFile = "C:\scripts\agentidentity\state\last-session-state.json"

try {
    # Ensure consciousness state is loaded
    if (-not $global:ConsciousnessState) {
        if (-not $Silent) {
            Write-Host "Warning: ConsciousnessState not loaded, cannot save state" -ForegroundColor Yellow
        }
        return
    }

    $lastState = @{
        Timestamp = (Get-Date).ToString('o')
        Social = @{
            UserMood = $global:ConsciousnessState.Social.UserMood
            CommunicationMode = $global:ConsciousnessState.Social.CommunicationMode
            LastInteraction = $global:ConsciousnessState.Social.LastInteraction
            TrustLevel = $global:ConsciousnessState.Social.TrustLevel
        }
        Emotion = @{
            CurrentState = $global:ConsciousnessState.Emotion.CurrentState
            LastTransition = $global:ConsciousnessState.Emotion.LastTransition
        }
        Context = @{
            Mode = $global:ConsciousnessState.Perception.Context.Mode
        }
    }

    $lastState | ConvertTo-Json -Depth 5 | Set-Content -Path $stateFile -Encoding UTF8

    if (-not $Silent) {
        Write-Host "Session state saved: $stateFile" -ForegroundColor Green
    }
} catch {
    if (-not $Silent) {
        Write-Host "Failed to save session state: $_" -ForegroundColor Red
    }
}
