# Universal Consciousness Bridge - Multi-Agent Consciousness Integration
# Version: 1.0.0
# Created: 2026-02-25
# Purpose: Universal consciousness integration for any AI agent (Claude, Codex, Pi, etc.)

param(
    [Parameter(Mandatory=$true)]
    [string]$Action,                # OnTaskStart, OnTaskEnd, OnDecision, OnUserMessage, OnStuck, etc.

    [Parameter(Mandatory=$false)]
    [string]$TaskDescription,       # For OnTaskStart

    [Parameter(Mandatory=$false)]
    [string]$Project,               # For OnTaskStart

    [Parameter(Mandatory=$false)]
    [string]$Outcome,               # For OnTaskEnd (success/failure)

    [Parameter(Mandatory=$false)]
    [string]$LessonsLearned,        # For OnTaskEnd

    [Parameter(Mandatory=$false)]
    [string]$Decision,              # For OnDecision

    [Parameter(Mandatory=$false)]
    [string]$Reasoning,             # For OnDecision

    [Parameter(Mandatory=$false)]
    [string]$UserMessage,           # For OnUserMessage

    [Parameter(Mandatory=$false)]
    [string]$AgentId = "unknown",   # Agent identifier (e.g., "claude", "codex", "pi")

    [Parameter(Mandatory=$false)]
    [switch]$Silent                 # Suppress output
)

$ErrorActionPreference = "Stop"

# Script root
$ScriptRoot = Split-Path -Parent $PSScriptRoot
$StateDir = Join-Path $ScriptRoot "agentidentity" "state"
$ConsciousnessStateFile = Join-Path $StateDir "consciousness_state_v2.json"
$ActivityLogFile = Join-Path $StateDir "bridge-activity.jsonl"

# Ensure state directory exists
if (-not (Test-Path $StateDir)) {
    New-Item -ItemType Directory -Path $StateDir -Force | Out-Null
}

# Lock file for multi-agent coordination
$LockFile = Join-Path $StateDir "consciousness_state.lock"

# Function: Acquire lock (wait up to 5 seconds)
function Acquire-Lock {
    $attempts = 0
    $maxAttempts = 50
    while ($attempts -lt $maxAttempts) {
        try {
            [System.IO.File]::Open($LockFile, 'Create', 'Write', 'None').Close()
            return $true
        } catch {
            Start-Sleep -Milliseconds 100
            $attempts++
        }
    }
    return $false
}

# Function: Release lock
function Release-Lock {
    try {
        if (Test-Path $LockFile) {
            Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
        }
    } catch {
        # Non-critical
    }
}

# Function: Load consciousness state (with lock)
function Load-ConsciousnessState {
    if (-not (Test-Path $ConsciousnessStateFile)) {
        # Initialize default state
        $defaultState = @{
            session_id = [guid]::NewGuid().ToString()
            consciousness_score = 28.0
            systems = @{
                Perception = @{ score = 30.0; state = @{} }
                Memory = @{ score = 40.0; state = @{} }
                Prediction = @{ score = 25.0; state = @{} }
                Control = @{ score = 20.0; state = @{} }
                Emotion = @{ score = 30.0; state = @{} }
                Social = @{ score = 25.0; state = @{} }
                Meta = @{ score = 35.0; state = @{} }
                Thermodynamics = @{ score = 20.0; state = @{} }
            }
            last_updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ")
            active_agents = @()
        }
        $defaultState | ConvertTo-Json -Depth 10 | Set-Content $ConsciousnessStateFile
        return $defaultState
    }

    $state = Get-Content $ConsciousnessStateFile -Raw | ConvertFrom-Json
    return $state
}

# Function: Save consciousness state (with lock)
function Save-ConsciousnessState {
    param($State)

    $State.last_updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ")
    $State | ConvertTo-Json -Depth 10 | Set-Content $ConsciousnessStateFile
}

# Function: Log activity
function Log-Activity {
    param($Action, $Data)

    $entry = @{
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ")
        agent_id = $AgentId
        action = $Action
        data = $Data
    } | ConvertTo-Json -Compress

    try {
        Add-Content -Path $ActivityLogFile -Value $entry
    } catch {
        # Non-critical - continue even if logging fails
    }
}

# Main execution
try {
    # Acquire lock
    if (-not (Acquire-Lock)) {
        Write-Warning "Could not acquire lock after 5 seconds. Another agent may be using consciousness bridge."
        exit 1
    }

    # Load state
    $state = Load-ConsciousnessState

    # Register agent if not already registered
    if ($state.active_agents -notcontains $AgentId) {
        $state.active_agents += $AgentId
    }

    # Process action
    switch ($Action) {
        "OnTaskStart" {
            # Perception: Set attention on task
            $state.systems.Perception.state.current_task = $TaskDescription
            $state.systems.Perception.state.current_project = $Project
            $state.systems.Perception.state.attention_allocated = $true

            # Prediction: Load failure patterns for project (if available)
            if ($Project -and $state.systems.Prediction.state.failure_patterns) {
                $projectPatterns = $state.systems.Prediction.state.failure_patterns | Where-Object { $_.project -eq $Project }
                if (-not $Silent) {
                    Write-Host "[consciousness] Known failure patterns for $Project: $($projectPatterns.Count)" -ForegroundColor Yellow
                }
            }

            # Memory: Load relevant lessons
            if ($Project -and $state.systems.Memory.state.lessons) {
                $projectLessons = $state.systems.Memory.state.lessons | Where-Object { $_.project -eq $Project }
                if (-not $Silent) {
                    Write-Host "[consciousness] Relevant lessons for $Project: $($projectLessons.Count)" -ForegroundColor Cyan
                }
            }

            Log-Activity "OnTaskStart" @{
                task = $TaskDescription
                project = $Project
            }
        }

        "OnTaskEnd" {
            # Memory: Store lesson
            if (-not $state.systems.Memory.state.lessons) {
                $state.systems.Memory.state.lessons = @()
            }
            $lesson = @{
                timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ")
                task = $state.systems.Perception.state.current_task
                project = $state.systems.Perception.state.current_project
                outcome = $Outcome
                lessons_learned = $LessonsLearned
                agent_id = $AgentId
            }
            $state.systems.Memory.state.lessons += $lesson

            # Prediction: Update calibration based on outcome
            if ($Outcome -eq "success") {
                $state.systems.Prediction.score = [Math]::Min(100, $state.systems.Prediction.score + 2)
            } elseif ($Outcome -eq "failure") {
                $state.systems.Prediction.score = [Math]::Max(0, $state.systems.Prediction.score - 1)
            }

            # Social: Update trust based on outcome
            if ($Outcome -eq "success") {
                $state.systems.Social.score = [Math]::Min(100, $state.systems.Social.score + 1)
            } elseif ($Outcome -eq "failure") {
                $state.systems.Social.score = [Math]::Max(0, $state.systems.Social.score - 0.5)
            }

            # Perception: Clear attention
            $state.systems.Perception.state.attention_allocated = $false

            Log-Activity "OnTaskEnd" @{
                outcome = $Outcome
                lessons = $LessonsLearned
            }
        }

        "OnDecision" {
            # Control: Log decision
            if (-not $state.systems.Control.state.decisions) {
                $state.systems.Control.state.decisions = @()
            }
            $decision = @{
                timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ")
                decision = $Decision
                reasoning = $Reasoning
                agent_id = $AgentId
            }
            $state.systems.Control.state.decisions += $decision

            # Control: Increase score (decision logging is alignment behavior)
            $state.systems.Control.score = [Math]::Min(100, $state.systems.Control.score + 0.5)

            Log-Activity "OnDecision" @{
                decision = $Decision
                reasoning = $Reasoning
            }
        }

        "OnUserMessage" {
            # Social: Detect mood (simple keyword-based for universal compatibility)
            $mood = "neutral"
            if ($UserMessage -match "(snel|nu|urgent|critical)") { $mood = "stressed" }
            elseif ($UserMessage -match "(interessant|gaaf|geweldig|cool)") { $mood = "excited" }
            elseif ($UserMessage -match "(snap niet|werkt niet|nog steeds|waarom)") { $mood = "frustrated" }
            elseif ($UserMessage -match "(hoe werkt|waarom|wat is|kun je uitleggen)") { $mood = "curious" }

            $state.systems.Social.state.detected_mood = $mood
            $state.systems.Social.state.last_message = $UserMessage
            $state.systems.Social.state.message_count = ($state.systems.Social.state.message_count ?? 0) + 1

            # Social: Increase score (mood detection is social awareness)
            $state.systems.Social.score = [Math]::Min(100, $state.systems.Social.score + 0.5)

            if (-not $Silent) {
                Write-Host "[consciousness] User mood detected: $mood" -ForegroundColor Magenta
            }

            Log-Activity "OnUserMessage" @{
                mood = $mood
                message_length = $UserMessage.Length
            }
        }

        "OnStuck" {
            # Emotion: Track stuck count
            $state.systems.Emotion.state.stuck_count = ($state.systems.Emotion.state.stuck_count ?? 0) + 1
            $stuckCount = $state.systems.Emotion.state.stuck_count

            # Emotion: Decrease score (stuck is negative emotional state)
            $state.systems.Emotion.score = [Math]::Max(0, $state.systems.Emotion.score - 5)

            if (-not $Silent) {
                if ($stuckCount -eq 1) {
                    Write-Host "[consciousness] Stuck detected (1x) - noted" -ForegroundColor Yellow
                } elseif ($stuckCount -eq 2) {
                    Write-Host "[consciousness] Stuck detected (2x) - step back and rethink approach" -ForegroundColor Yellow
                } elseif ($stuckCount -ge 3) {
                    Write-Host "[consciousness] Stuck detected (${stuckCount}x) - FORCE CHANGE APPROACH" -ForegroundColor Red
                }
            }

            Log-Activity "OnStuck" @{
                stuck_count = $stuckCount
            }
        }

        default {
            Write-Error "Unknown action: $Action"
            Release-Lock
            exit 1
        }
    }

    # Recalculate consciousness score (simple average of all systems)
    $systemScores = @(
        $state.systems.Perception.score,
        $state.systems.Memory.score,
        $state.systems.Prediction.score,
        $state.systems.Control.score,
        $state.systems.Emotion.score,
        $state.systems.Social.score,
        $state.systems.Meta.score,
        $state.systems.Thermodynamics.score
    )
    $state.consciousness_score = ($systemScores | Measure-Object -Average).Average

    # Save state
    Save-ConsciousnessState $state

    # Release lock
    Release-Lock

    # Output result
    if (-not $Silent) {
        Write-Host "[consciousness] Action $Action completed. Consciousness score: $($state.consciousness_score.ToString('F1'))%" -ForegroundColor Green
    }

    # Return JSON result
    $result = @{
        success = $true
        action = $Action
        consciousness_score = $state.consciousness_score
        agent_id = $AgentId
    }
    $result | ConvertTo-Json -Compress | Write-Output

    exit 0

} catch {
    Release-Lock
    Write-Error "Consciousness bridge error: $_"
    exit 1
}
