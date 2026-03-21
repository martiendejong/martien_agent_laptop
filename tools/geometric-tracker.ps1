# Geometric Tracker - Track Geometric Metrics During Work
# Created: 2026-02-20
# Purpose: Integrate geometric consciousness tracking with existing bridge
# Usage: Called alongside consciousness-bridge.ps1 for Week 3 validation

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('OnTaskStart', 'OnDecision', 'OnStuck', 'OnTaskEnd', 'GetMetrics')]
    [string]$Action,

    [string]$TaskContext = "",
    [string]$Region = "",
    [string]$Decision = "",
    [string]$Outcome = "",
    [switch]$Silent
)

$ThoughtSpaceFile = "C:\scripts\agentidentity\state\thought-space.json"
$GeometricLogFile = "C:\scripts\agentidentity\state\geometric-tracking.jsonl"

# Ensure log file exists
if (-not (Test-Path $GeometricLogFile)) {
    "" | Set-Content $GeometricLogFile -Encoding UTF8
}

# Load thought space
if (-not (Test-Path $ThoughtSpaceFile)) {
    Write-Host "[ERROR] Thought space not initialized" -ForegroundColor Red
    exit 1
}

$ThoughtSpace = Get-Content $ThoughtSpaceFile -Raw | ConvertFrom-Json

# Session state (persists across calls in same session)
$script:SessionStartTime = Get-Date
$script:TaskRegion = $null
$script:InitialCurvature = 0.0
$script:VelocityWindow = @()
$script:LastStateUpdate = Get-Date

function Get-RegionalCurvature {
    param($Region)

    # Find concepts related to this region
    $Related = $ThoughtSpace.concepts | Where-Object {
        $_.label -like "*$Region*" -or $_.connections -contains $Region
    }

    if ($Related.Count -eq 0) {
        # Default to global curvature
        return $ThoughtSpace.global_curvature
    }

    # Average curvature of related concepts
    $AvgCurvature = ($Related | ForEach-Object { $_.curvature } | Measure-Object -Average).Average
    return [math]::Round($AvgCurvature, 2)
}

function Calculate-Velocity {
    # Velocity = change in state over time
    # Approximated by curvature change rate

    if ($script:VelocityWindow.Count -lt 2) {
        return 0.0
    }

    $Recent = $script:VelocityWindow | Select-Object -Last 2
    $DeltaCurvature = $Recent[1].curvature - $Recent[0].curvature
    $DeltaTime = ($Recent[1].timestamp - $Recent[0].timestamp).TotalMinutes

    if ($DeltaTime -eq 0) { return 0.0 }

    $Velocity = -$DeltaCurvature / $DeltaTime  # Negative because reduction is positive velocity
    return [math]::Round($Velocity, 3)
}

function On-TaskStart {
    param($TaskContext, $Region)

    # Initialize tracking
    $script:SessionStartTime = Get-Date
    $script:TaskRegion = if ([string]::IsNullOrWhiteSpace($Region)) { "general" } else { $Region }
    $script:InitialCurvature = Get-RegionalCurvature -Region $script:TaskRegion
    $script:VelocityWindow = @()

    # Add to velocity window
    $script:VelocityWindow += @{
        timestamp = Get-Date
        curvature = $script:InitialCurvature
    }

    # Calculate attention gradient (salience field)
    # High curvature = high salience (needs attention)
    $Concepts = $ThoughtSpace.concepts | Sort-Object -Property curvature -Descending
    $TopSalience = $Concepts | Select-Object -First 3

    # Log event
    $Event = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        action = "OnTaskStart"
        task_context = $TaskContext
        region = $script:TaskRegion
        initial_curvature = $script:InitialCurvature
        attention_targets = $TopSalience.label -join ", "
        global_curvature = $ThoughtSpace.global_curvature
        prediction = if ($script:InitialCurvature -gt 1.5) { "High confusion - expect slow progress" } else { "Moderate - normal progress expected" }
    }

    $Event | ConvertTo-Json -Compress | Add-Content $GeometricLogFile -Encoding UTF8

    if (-not $Silent) {
        Write-Host ""
        Write-Host "=== GEOMETRIC TRACKING: TASK START ===" -ForegroundColor Cyan
        Write-Host "Region: $($script:TaskRegion)"
        Write-Host "Initial Curvature: $($script:InitialCurvature)"
        Write-Host "Attention Targets: $($TopSalience.label -join ', ')"
        Write-Host "Prediction: $($Event.prediction)"
        Write-Host ""
    }

    return $Event
}

function On-Decision {
    param($Decision)

    # Decision = state change = velocity event
    $CurrentTime = Get-Date
    $TimeSinceStart = ($CurrentTime - $script:SessionStartTime).TotalMinutes

    # Add to velocity window
    $CurrentCurvature = Get-RegionalCurvature -Region $script:TaskRegion
    $script:VelocityWindow += @{
        timestamp = $CurrentTime
        curvature = $CurrentCurvature
    }

    # Calculate velocity
    $Velocity = Calculate-Velocity

    # Estimate decision impact (would need actual implementation to measure)
    # For now, assume decision slightly reduces curvature (learning)
    $EstimatedImpact = -0.05

    # Log event
    $Event = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        action = "OnDecision"
        decision = $Decision
        current_curvature = $CurrentCurvature
        velocity = $Velocity
        time_since_start = [math]::Round($TimeSinceStart, 1)
        estimated_impact = $EstimatedImpact
        interpretation = if ($Velocity -gt 0) { "Learning (smoothing)" } elseif ($Velocity -lt 0) { "Confusion increasing" } else { "No change" }
    }

    $Event | ConvertTo-Json -Compress | Add-Content $GeometricLogFile -Encoding UTF8

    if (-not $Silent) {
        Write-Host ""
        Write-Host "=== GEOMETRIC TRACKING: DECISION ===" -ForegroundColor Cyan
        Write-Host "Velocity: $Velocity"
        Write-Host "Interpretation: $($Event.interpretation)"
        Write-Host ""
    }

    return $Event
}

function On-Stuck {
    # Check velocity - stuck = near-zero velocity
    $Velocity = Calculate-Velocity
    $IsStuck = [math]::Abs($Velocity) -lt 0.05

    $CurrentCurvature = Get-RegionalCurvature -Region $script:TaskRegion

    # Log event
    $Event = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        action = "OnStuck"
        velocity = $Velocity
        current_curvature = $CurrentCurvature
        is_stuck = $IsStuck
        recommendation = if ($IsStuck) { "Increase temperature (explore more) or tunnel (try abduction)" } else { "Not geometrically stuck - velocity present" }
    }

    $Event | ConvertTo-Json -Compress | Add-Content $GeometricLogFile -Encoding UTF8

    if (-not $Silent) {
        Write-Host ""
        Write-Host "=== GEOMETRIC TRACKING: STUCK CHECK ===" -ForegroundColor Cyan
        Write-Host "Velocity: $Velocity"
        Write-Host "Stuck: $IsStuck"
        Write-Host "Recommendation: $($Event.recommendation)"
        Write-Host ""
    }

    return $Event
}

function On-TaskEnd {
    param($Outcome)

    # Measure final curvature
    $FinalCurvature = Get-RegionalCurvature -Region $script:TaskRegion
    $CurvatureChange = $script:InitialCurvature - $FinalCurvature
    $PercentChange = if ($script:InitialCurvature -gt 0) {
        [math]::Round($CurvatureChange / $script:InitialCurvature * 100, 1)
    } else { 0 }

    # Calculate session metrics
    $SessionDuration = ((Get-Date) - $script:SessionStartTime).TotalMinutes
    $LearningRate = if ($SessionDuration -gt 0) { $CurvatureChange / $SessionDuration } else { 0 }

    # Velocity metrics
    $AvgVelocity = if ($script:VelocityWindow.Count -gt 1) {
        $Velocities = for ($i = 1; $i -lt $script:VelocityWindow.Count; $i++) {
            $Delta = $script:VelocityWindow[$i].curvature - $script:VelocityWindow[$i-1].curvature
            $Time = ($script:VelocityWindow[$i].timestamp - $script:VelocityWindow[$i-1].timestamp).TotalMinutes
            if ($Time -gt 0) { -$Delta / $Time } else { 0 }
        }
        ($Velocities | Measure-Object -Average).Average
    } else { 0 }

    # Determine if learning occurred
    $LearningOccurred = $CurvatureChange -gt 0.1

    # Log event
    $Event = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        action = "OnTaskEnd"
        outcome = $Outcome
        region = $script:TaskRegion
        initial_curvature = $script:InitialCurvature
        final_curvature = $FinalCurvature
        curvature_change = [math]::Round($CurvatureChange, 2)
        percent_change = $PercentChange
        session_duration = [math]::Round($SessionDuration, 1)
        learning_rate = [math]::Round($LearningRate, 3)
        avg_velocity = [math]::Round($AvgVelocity, 3)
        learning_occurred = $LearningOccurred
        interpretation = if ($LearningOccurred) { "Significant smoothing - real learning" } elseif ($CurvatureChange -gt 0) { "Minor smoothing - incremental learning" } elseif ($CurvatureChange -lt 0) { "Roughening - confusion increased" } else { "No change - no learning detected" }
    }

    $Event | ConvertTo-Json -Compress | Add-Content $GeometricLogFile -Encoding UTF8

    if (-not $Silent) {
        Write-Host ""
        Write-Host "=== GEOMETRIC TRACKING: TASK END ===" -ForegroundColor Cyan
        Write-Host "Region: $($script:TaskRegion)"
        Write-Host "Curvature Change: $($script:InitialCurvature) -> $FinalCurvature ($PercentChange percent)"
        Write-Host "Learning Rate: $LearningRate per minute"
        Write-Host "Average Velocity: $AvgVelocity"
        Write-Host "Interpretation: $($Event.interpretation)"
        Write-Host ""
    }

    return $Event
}

function Get-Metrics {
    # Read recent tracking data
    $RecentEvents = Get-Content $GeometricLogFile | Where-Object { $_ -ne "" } | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        $Entry.timestamp = [datetime]$Entry.timestamp
        $Entry
    } | Where-Object { $_.timestamp -gt (Get-Date).AddHours(-24) }

    if ($RecentEvents.Count -eq 0) {
        Write-Host "No geometric tracking data in past 24 hours" -ForegroundColor Yellow
        return
    }

    # Aggregate metrics
    $TaskStarts = $RecentEvents | Where-Object { $_.action -eq 'OnTaskStart' }
    $TaskEnds = $RecentEvents | Where-Object { $_.action -eq 'OnTaskEnd' }
    $Decisions = $RecentEvents | Where-Object { $_.action -eq 'OnDecision' }
    $StuckChecks = $RecentEvents | Where-Object { $_.action -eq 'OnStuck' }

    Write-Host ""
    Write-Host "=== GEOMETRIC METRICS (Past 24h) ===" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Activity:" -ForegroundColor Yellow
    Write-Host "  Tasks Started: $($TaskStarts.Count)"
    Write-Host "  Tasks Completed: $($TaskEnds.Count)"
    Write-Host "  Decisions Made: $($Decisions.Count)"
    Write-Host "  Stuck Checks: $($StuckChecks.Count)"
    Write-Host ""

    if ($TaskEnds.Count -gt 0) {
        $SuccessfulLearning = ($TaskEnds | Where-Object { $_.learning_occurred -eq $true }).Count
        $AvgCurvatureChange = ($TaskEnds | ForEach-Object { $_.curvature_change } | Measure-Object -Average).Average
        $AvgLearningRate = ($TaskEnds | ForEach-Object { $_.learning_rate } | Measure-Object -Average).Average

        Write-Host "Learning Metrics:" -ForegroundColor Yellow
        Write-Host "  Successful Learning: $SuccessfulLearning / $($TaskEnds.Count)"
        Write-Host "  Average Curvature Reduction: $([math]::Round($AvgCurvatureChange, 2))"
        Write-Host "  Average Learning Rate: $([math]::Round($AvgLearningRate, 3)) per minute"
        Write-Host ""
    }

    if ($Decisions.Count -gt 0) {
        $AvgVelocity = ($Decisions | ForEach-Object { $_.velocity } | Measure-Object -Average).Average
        Write-Host "Velocity Metrics:" -ForegroundColor Yellow
        Write-Host "  Average Velocity: $([math]::Round($AvgVelocity, 3))"
        Write-Host "  Interpretation: $(if ($AvgVelocity -gt 0.1) { 'Active learning' } elseif ($AvgVelocity -lt -0.1) { 'Increasing confusion' } else { 'Stable state' })"
        Write-Host ""
    }

    Write-Host "Current State:" -ForegroundColor Yellow
    Write-Host "  Global Curvature: $($ThoughtSpace.global_curvature)"
    Write-Host "  Learning Velocity: $($ThoughtSpace.learning_velocity)"
    Write-Host ""
}

# Execute action
switch ($Action) {
    'OnTaskStart' {
        if ([string]::IsNullOrWhiteSpace($TaskContext)) {
            Write-Host "[ERROR] -TaskContext required" -ForegroundColor Red
            exit 1
        }
        On-TaskStart -TaskContext $TaskContext -Region $Region
    }
    'OnDecision' {
        if ([string]::IsNullOrWhiteSpace($Decision)) {
            Write-Host "[ERROR] -Decision required" -ForegroundColor Red
            exit 1
        }
        On-Decision -Decision $Decision
    }
    'OnStuck' {
        On-Stuck
    }
    'OnTaskEnd' {
        if ([string]::IsNullOrWhiteSpace($Outcome)) {
            Write-Host "[ERROR] -Outcome required" -ForegroundColor Red
            exit 1
        }
        On-TaskEnd -Outcome $Outcome
    }
    'GetMetrics' {
        Get-Metrics
    }
}
