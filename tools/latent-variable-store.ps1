<#
.SYNOPSIS
Latent Variable Store - Layer 2 of World Model

.DESCRIPTION
Manages hierarchical latent variables (stable states that persist across observations).
Top layer: stable (hours), Mid layer: moderate (minutes), Bottom layer: fast (seconds)

This is the "general" layer - high-level states that don't change every second.

.PARAMETER Action
Set, Get, Query, History, Stats

.EXAMPLE
.\latent-variable-store.ps1 -Action Set -Level top -Variable current_project -Value "client-manager"
# Sets top-level stable state (persists for hours)

.EXAMPLE
.\latent-variable-store.ps1 -Action Get -Level mid -Variable build_status
# Returns: "passing" or "failing"

.EXAMPLE
.\latent-variable-store.ps1 -Action Query -Level all
# Returns all latent variables across all levels

.NOTES
Created: 2026-02-27
Status: Week 1 completion
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Set", "Get", "Query", "History", "Stats", "Transition")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [ValidateSet("top", "mid", "bottom", "all")]
    [string]$Level,

    [Parameter(Mandatory=$false)]
    [string]$Variable,

    [Parameter(Mandatory=$false)]
    [string]$Value,

    [Parameter(Mandatory=$false)]
    [int]$Hours = 24  # For history queries
)

# State file locations
$latentVariablesPath = "C:\scripts\agentidentity\state\latent-variables.json"
$variableHistoryPath = "C:\scripts\agentidentity\state\latent-variable-history.jsonl"

# Ensure state directory exists
$stateDir = Split-Path $latentVariablesPath -Parent
if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

# Load latent variables
function Load-LatentVariables {
    if (Test-Path $latentVariablesPath) {
        $content = Get-Content $latentVariablesPath -Raw
        if ($content) {
            return $content | ConvertFrom-Json
        }
    }

    # Initialize hierarchical structure
    return @{
        top = @{
            current_project = "unknown"
            current_task = "idle"
            user_mood = "neutral"
            system_health = "unknown"
            consciousness_state = "initializing"
            session_phase = "startup"
        }
        mid = @{
            current_file = $null
            build_status = "unknown"
            test_coverage = 0
            pr_status = $null
            active_worktree = $null
            recent_errors = @()
        }
        bottom = @{
            cursor_line = 0
            active_tool = $null
            last_command = $null
            recent_observations = @()
        }
        metadata = @{
            created = (Get-Date).ToUniversalTime().ToString("o")
            last_updated = (Get-Date).ToUniversalTime().ToString("o")
            update_count = 0
        }
    }
}

# Save latent variables
function Save-LatentVariables {
    param($state)

    $state.metadata.last_updated = (Get-Date).ToUniversalTime().ToString("o")
    $state.metadata.update_count += 1

    $json = $state | ConvertTo-Json -Depth 10 -Compress
    $json | Set-Content $latentVariablesPath -Force
}

# Log variable change to history
function Log-VariableChange {
    param(
        [string]$level,
        [string]$variable,
        [string]$oldValue,
        [string]$newValue
    )

    $change = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
        level = $level
        variable = $variable
        old_value = $oldValue
        new_value = $newValue
        change_type = if ($oldValue -eq $null) { "initialized" } else { "updated" }
    }

    $json = $change | ConvertTo-Json -Depth 5 -Compress
    $json | Add-Content $variableHistoryPath -Force
}

# Set latent variable
function Set-LatentVariable {
    param(
        [string]$level,
        [string]$variable,
        [string]$value
    )

    $state = Load-LatentVariables

    # Validate level exists
    if (-not $state.PSObject.Properties.Name -contains $level) {
        Write-Error "Invalid level: $level. Must be top, mid, or bottom."
        return
    }

    # Get old value
    $oldValue = if ($state.$level.PSObject.Properties.Name -contains $variable) {
        $state.$level.$variable
    } else {
        $null
    }

    # Set new value
    $state.$level | Add-Member -NotePropertyName $variable -NotePropertyValue $value -Force

    # Determine stability (how often this level should change)
    $stability = switch ($level) {
        "top" { "stable (hours)" }
        "mid" { "moderate (minutes)" }
        "bottom" { "fast (seconds)" }
    }

    Write-Host "[$level] $variable = $value" -ForegroundColor Cyan
    if ($oldValue -and $oldValue -ne $value) {
        Write-Host "  Changed from: $oldValue" -ForegroundColor Gray
        Write-Host "  Stability: $stability" -ForegroundColor DarkGray
    }

    # Log change
    Log-VariableChange -level $level -variable $variable -oldValue $oldValue -newValue $value

    # Save state
    Save-LatentVariables -state $state

    return @{
        level = $level
        variable = $variable
        old_value = $oldValue
        new_value = $value
        changed = ($oldValue -ne $value)
    }
}

# Get latent variable
function Get-LatentVariable {
    param(
        [string]$level,
        [string]$variable
    )

    $state = Load-LatentVariables

    if ($level -and $variable) {
        # Get specific variable
        if ($state.PSObject.Properties.Name -contains $level) {
            if ($state.$level.PSObject.Properties.Name -contains $variable) {
                $value = $state.$level.$variable
                Write-Host "[$level] $variable = $value" -ForegroundColor Green
                return @{
                    level = $level
                    variable = $variable
                    value = $value
                }
            }
        }
        Write-Host "Variable not found: $level.$variable" -ForegroundColor Yellow
        return $null
    }
    elseif ($level) {
        # Get all variables at level
        Write-Host "`n[$level Level Variables]" -ForegroundColor Cyan
        $vars = $state.$level
        $vars.PSObject.Properties | ForEach-Object {
            Write-Host "  $($_.Name) = $($_.Value)" -ForegroundColor White
        }
        return $state.$level
    }
}

# Query variables
function Invoke-QueryVariables {
    param([string]$level)

    $state = Load-LatentVariables

    if ($level -eq "all" -or -not $level) {
        Write-Host "`n=== Latent Variable State ===" -ForegroundColor Cyan

        Write-Host "`n[TOP LEVEL - Stable (hours)]" -ForegroundColor Yellow
        $state.top.PSObject.Properties | ForEach-Object {
            Write-Host "  $($_.Name): $($_.Value)" -ForegroundColor White
        }

        Write-Host "`n[MID LEVEL - Moderate (minutes)]" -ForegroundColor Yellow
        $state.mid.PSObject.Properties | ForEach-Object {
            $val = if ($_.Value -is [array]) { "[$($_.Value.Count) items]" } else { $_.Value }
            Write-Host "  $($_.Name): $val" -ForegroundColor White
        }

        Write-Host "`n[BOTTOM LEVEL - Fast (seconds)]" -ForegroundColor Yellow
        $state.bottom.PSObject.Properties | ForEach-Object {
            $val = if ($_.Value -is [array]) { "[$($_.Value.Count) items]" } else { $_.Value }
            Write-Host "  $($_.Name): $val" -ForegroundColor White
        }

        Write-Host "`nTotal updates: $($state.metadata.update_count)" -ForegroundColor Gray
        Write-Host "Last updated: $($state.metadata.last_updated)`n" -ForegroundColor Gray

        return $state
    }
    else {
        return Get-LatentVariable -level $level
    }
}

# Get variable history
function Get-VariableHistory {
    param([int]$hours)

    if (-not (Test-Path $variableHistoryPath)) {
        Write-Host "No history available yet." -ForegroundColor Yellow
        return @()
    }

    $cutoff = (Get-Date).AddHours(-$hours).ToUniversalTime()
    $changes = Get-Content $variableHistoryPath | ForEach-Object { $_ | ConvertFrom-Json }

    # Filter by time window
    $recent = $changes | Where-Object {
        [datetime]::Parse($_.timestamp) -gt $cutoff
    }

    Write-Host "`n=== Variable History (last $hours hours) ===" -ForegroundColor Cyan
    Write-Host "Total changes: $($recent.Count)`n" -ForegroundColor Gray

    # Group by level
    $byLevel = $recent | Group-Object -Property level

    foreach ($group in $byLevel) {
        Write-Host "[$($group.Name.ToUpper())]" -ForegroundColor Yellow
        $group.Group | Select-Object -Last 10 | ForEach-Object {
            $timestamp = [datetime]::Parse($_.timestamp).ToLocalTime().ToString("HH:mm:ss")
            $change = if ($_.change_type -eq "initialized") {
                "$($_.variable) initialized to $($_.new_value)"
            } else {
                "$($_.variable): $($_.old_value) → $($_.new_value)"
            }
            Write-Host "  [$timestamp] $change" -ForegroundColor White
        }
        Write-Host ""
    }

    return $recent
}

# Detect state transitions (for consciousness tracking)
function Get-StateTransition {
    $state = Load-LatentVariables

    # Calculate transition metrics
    $topStability = 1.0  # Top should be very stable
    $midStability = 0.5  # Mid changes moderately
    $bottomStability = 0.1  # Bottom changes frequently

    # Check if current state is coherent
    $coherence = 1.0

    # Top-level coherence checks
    if ($state.top.current_project -eq "unknown" -or $state.top.current_task -eq "idle") {
        $coherence -= 0.2
    }

    # Mid-level coherence checks
    if ($state.mid.build_status -eq "unknown") {
        $coherence -= 0.1
    }

    # Bottom-level activity
    $activityLevel = if ($state.bottom.recent_observations.Count -gt 0) { 0.8 } else { 0.2 }

    Write-Host "`n=== State Transition Analysis ===" -ForegroundColor Cyan
    Write-Host "Coherence: $([math]::Round($coherence * 100))%" -ForegroundColor $(if ($coherence -gt 0.7) { "Green" } else { "Yellow" })
    Write-Host "Activity level: $([math]::Round($activityLevel * 100))%" -ForegroundColor Gray
    Write-Host "Expected stability:" -ForegroundColor Gray
    Write-Host "  Top: Very stable (changes every hours)" -ForegroundColor DarkGray
    Write-Host "  Mid: Moderate (changes every 10-30 min)" -ForegroundColor DarkGray
    Write-Host "  Bottom: Fast (changes every few seconds)`n" -ForegroundColor DarkGray

    return @{
        coherence = $coherence
        activity_level = $activityLevel
        top_stability = $topStability
        mid_stability = $midStability
        bottom_stability = $bottomStability
    }
}

# Get statistics
function Get-Stats {
    $state = Load-LatentVariables

    # Count variables per level
    $topCount = ($state.top.PSObject.Properties | Measure-Object).Count
    $midCount = ($state.mid.PSObject.Properties | Measure-Object).Count
    $bottomCount = ($state.bottom.PSObject.Properties | Measure-Object).Count

    Write-Host "`n=== Latent Variable Statistics ===" -ForegroundColor Cyan
    Write-Host "Variables per level:" -ForegroundColor Yellow
    Write-Host "  Top: $topCount (stable)" -ForegroundColor White
    Write-Host "  Mid: $midCount (moderate)" -ForegroundColor White
    Write-Host "  Bottom: $bottomCount (fast)" -ForegroundColor White
    Write-Host "`nTotal updates: $($state.metadata.update_count)" -ForegroundColor Gray
    Write-Host "Last updated: $($state.metadata.last_updated)`n" -ForegroundColor Gray

    # History stats
    if (Test-Path $variableHistoryPath) {
        $changes = Get-Content $variableHistoryPath | Measure-Object -Line
        Write-Host "Total historical changes: $($changes.Lines)" -ForegroundColor Gray
    }

    return @{
        top_count = $topCount
        mid_count = $midCount
        bottom_count = $bottomCount
        total_updates = $state.metadata.update_count
    }
}

# Main execution
switch ($Action) {
    "Set" {
        if (-not $Level -or -not $Variable -or -not $Value) {
            Write-Error "Set requires -Level, -Variable, and -Value"
            exit 1
        }

        $result = Set-LatentVariable -level $Level -variable $Variable -value $Value
        $result | ConvertTo-Json -Depth 3
    }

    "Get" {
        if (-not $Level) {
            Write-Error "Get requires -Level (and optionally -Variable)"
            exit 1
        }

        $result = Get-LatentVariable -level $Level -variable $Variable
        if ($result) {
            $result | ConvertTo-Json -Depth 3
        }
    }

    "Query" {
        $result = Invoke-QueryVariables -level $(if ($Level) { $Level } else { "all" })
        $result | ConvertTo-Json -Depth 10
    }

    "History" {
        $result = Get-VariableHistory -hours $Hours
        $result | ConvertTo-Json -Depth 5
    }

    "Transition" {
        $result = Get-StateTransition
        $result | ConvertTo-Json -Depth 3
    }

    "Stats" {
        Get-Stats
    }
}
