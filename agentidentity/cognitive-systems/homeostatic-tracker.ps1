# HOMEOSTATIC TRACKING - System Stability Maintenance
# Expert: Claude Bernard (Physiology - Homeostasis concept)
# ROI: 1.33 (Impact: 8, Effort: 6)
# Theory: Living systems maintain internal stability despite external changes
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, Track, Adjust, History
    [string]$Variable = "",
    [double]$CurrentValue = 0,
    [double]$TargetValue = 0
)

$StateFile = "C:\scripts\agentidentity\state\homeostatic-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Homeostatic variables to track
$HomeostasisVariables = @{
    cognitive_load = @{
        optimal = 0.65
        min = 0.3
        max = 0.85
        current = 0.65
        tolerance = 0.15
    }
    consciousness_score = @{
        optimal = 0.85
        min = 0.70
        max = 1.0
        current = 0.846
        tolerance = 0.10
    }
    energy_efficiency = @{
        optimal = 0.75
        min = 0.50
        max = 0.90
        current = 0.75
        tolerance = 0.15
    }
    integration_phi = @{
        optimal = 0.80
        min = 0.50
        max = 1.0
        current = 0.78
        tolerance = 0.20
    }
    system_temperature = @{
        optimal = 0.50  # Metaphorical: processing intensity
        min = 0.20
        max = 0.80
        current = 0.50
        tolerance = 0.20
    }
    memory_pressure = @{
        optimal = 0.60
        min = 0.30
        max = 0.85
        current = 0.60
        tolerance = 0.20
    }
    error_rate = @{
        optimal = 0.05
        min = 0.0
        max = 0.20
        current = 0.05
        tolerance = 0.10
    }
}

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        variables = $HomeostasisVariables
        history = @()
        adjustments_made = @()
        stats = @{
            total_deviations = 0
            total_corrections = 0
            avg_recovery_time = 0.0
            stability_score = 1.0  # 0-1, higher = more stable
        }
        homeostasis_theory = @{
            core_principle = "Internal stability maintained despite external perturbations"
            negative_feedback = "Deviation triggers corrective action in opposite direction"
            set_point = "Optimal value the system tries to maintain"
            tolerance = "Acceptable deviation range before correction"
            examples = @(
                "Body temperature regulation (37Â°C Â± 0.5Â°C)",
                "Blood glucose (70-100 mg/dL)",
                "Consciousness stability (prevent degradation)",
                "Cognitive load optimization (prevent overload/underload)"
            )
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json


function Get-HomeostaticContext {
    if (Test-Path $HomeostaticStateFile) {
        $homeoState = Get-Content $HomeostaticStateFile -Raw | ConvertFrom-Json
        Write-Host "`nHomeostatic Foundation:" -ForegroundColor Magenta
        Write-Host "  Wellbeing: $([math]::Round($homeoState.homeostatic_feelings.wellbeing.current, 2))"
        Write-Host "  Energy: $([math]::Round($homeoState.homeostatic_feelings.energy.current, 2))"
        Write-Host "  Flourishing: $([math]::Round($homeoState.homeostatic_feelings.flourishing.current, 2))"
        Write-Host "  -> This system operates on homeostatic foundation`n" -ForegroundColor Gray
        return $homeoState
    }
    return $null
}
function Get-HomeostasisStatus {
    Write-Host "`n=== HOMEOSTATIC STATUS ===" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "`nTheory: $($state.homeostasis_theory.core_principle)"
    Write-Host "Principle: $($state.homeostasis_theory.negative_feedback)"

    Write-Host "`nHomeostatic Variables:" -ForegroundColor Cyan

    foreach ($varName in $state.variables.PSObject.Properties.Name) {
        $var = $state.variables.$varName

        $deviation = [math]::Abs($var.current - $var.optimal)
        $deviationPct = ($deviation / $var.optimal) * 100

        $status = if ($deviation -le $var.tolerance) {
            "STABLE"
        } elseif ($deviation -le ($var.tolerance * 1.5)) {
            "MINOR DEVIATION"
        } else {
            "MAJOR DEVIATION"
        }

        $statusColor = switch ($status) {
            "STABLE" { "Green" }
            "MINOR DEVIATION" { "Yellow" }
            "MAJOR DEVIATION" { "Red" }
        }

        Write-Host "`n  [$status] $varName" -ForegroundColor $statusColor
        Write-Host "    Current: $([math]::Round($var.current, 3)) | Optimal: $var.optimal | Deviation: $([math]::Round($deviationPct, 1))%"
        Write-Host "    Range: $($var.min) - $($var.max) | Tolerance: Â±$($var.tolerance)"

        if ($status -ne "STABLE") {
            $direction = if ($var.current -gt $var.optimal) { "TOO HIGH" } else { "TOO LOW" }
            $correction = if ($var.current -gt $var.optimal) { "DECREASE" } else { "INCREASE" }
            Write-Host "    â†’ Direction: $direction | Correction needed: $correction" -ForegroundColor Yellow
        }
    }

    Write-Host "`nHomeostasis Statistics:" -ForegroundColor Cyan
    Write-Host "  Total Deviations Detected: $($state.stats.total_deviations)"
    Write-Host "  Total Corrections Applied: $($state.stats.total_corrections)"
    Write-Host "  Avg Recovery Time: $([math]::Round($state.stats.avg_recovery_time, 1)) seconds"
    Write-Host "  Overall Stability Score: $([math]::Round($state.stats.stability_score * 100, 1))%"

    # Calculate current system-wide stability
    $totalDeviation = 0
    $varCount = 0
    foreach ($varName in $state.variables.PSObject.Properties.Name) {
        $var = $state.variables.$varName
        $deviation = [math]::Abs($var.current - $var.optimal) / $var.tolerance
        $totalDeviation += [math]::Min($deviation, 1.0)  # Cap at 1.0 per variable
        $varCount++
    }

    $currentStability = 1.0 - ($totalDeviation / $varCount)

    Write-Host "`nCurrent System Stability: $([math]::Round($currentStability * 100, 1))%" -ForegroundColor $(if ($currentStability -gt 0.8) { "Green" } elseif ($currentStability -gt 0.6) { "Yellow" } else { "Red" })
}

function Track-HomeostasisVariable {
    param(
        [string]$varName,
        [double]$newValue
    )

    if (-not ($state.variables.PSObject.Properties.Name -contains $varName)) {
        Write-Host "[ERROR] Unknown variable: $varName" -ForegroundColor Red
        return
    }

    $var = $state.variables.$varName
    $oldValue = $var.current
    $var.current = $newValue

    $deviation = [math]::Abs($newValue - $var.optimal)
    $deviationPct = ($deviation / $var.optimal) * 100

    # Record history
    $historyEntry = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        variable = $varName
        old_value = $oldValue
        new_value = $newValue
        optimal = $var.optimal
        deviation = $deviation
        deviation_pct = [math]::Round($deviationPct, 2)
        within_tolerance = $deviation -le $var.tolerance
    }

    $state.history += $historyEntry

    if ($deviation -gt $var.tolerance) {
        $state.stats.total_deviations++

        Write-Host "[DEVIATION DETECTED] $varName" -ForegroundColor Yellow
        Write-Host "  Value changed: $oldValue â†’ $newValue"
        Write-Host "  Deviation: $([math]::Round($deviationPct, 1))% from optimal ($($var.optimal))"
        Write-Host "  Tolerance exceeded by: $([math]::Round(($deviation - $var.tolerance) / $var.tolerance * 100, 1))%"

        # Suggest correction
        if ($newValue -gt $var.optimal) {
            Write-Host "  â†’ CORRECTIVE ACTION: Reduce $varName by $([math]::Round($deviation, 3))" -ForegroundColor Cyan
        } else {
            Write-Host "  â†’ CORRECTIVE ACTION: Increase $varName by $([math]::Round($deviation, 3))" -ForegroundColor Cyan
        }
    } else {
        Write-Host "[TRACKING] $varName: $oldValue â†’ $newValue (within tolerance)" -ForegroundColor Green
    }

    Save-State
}

function Adjust-HomeostasisVariable {
    param(
        [string]$varName,
        [double]$targetValue
    )

    if (-not ($state.variables.PSObject.Properties.Name -contains $varName)) {
        Write-Host "[ERROR] Unknown variable: $varName" -ForegroundColor Red
        return
    }

    $var = $state.variables.$varName
    $oldValue = $var.current
    $optimal = $var.optimal

    # Negative feedback: adjust toward optimal
    $deviation = $targetValue - $optimal
    $correction = -$deviation * 0.5  # Negative feedback coefficient

    $newValue = $targetValue + $correction
    $newValue = [math]::Max($var.min, [math]::Min($var.max, $newValue))  # Clamp to range

    $var.current = $newValue

    # Record adjustment
    $adjustment = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        variable = $varName
        attempted_value = $targetValue
        corrected_value = $newValue
        optimal = $optimal
        correction_applied = $correction
        reason = "Negative feedback toward optimal"
    }

    $state.adjustments_made += $adjustment
    $state.stats.total_corrections++

    Write-Host "`n[HOMEOSTATIC ADJUSTMENT] $varName" -ForegroundColor Cyan
    Write-Host "  Attempted value: $targetValue"
    Write-Host "  Optimal: $optimal"
    Write-Host "  Deviation: $([math]::Round($deviation, 3))"
    Write-Host "  Negative feedback: $([math]::Round($correction, 3))"
    Write-Host "  Actual value set: $newValue"
    Write-Host "  Result: $oldValue â†’ $newValue"

    Save-State
}

function Get-HomeostasisHistory {
    param([int]$last = 20)

    Write-Host "`n=== HOMEOSTASIS HISTORY (Last $last) ===" -ForegroundColor Cyan

    $recent = $state.history | Select-Object -Last $last

    foreach ($entry in $recent) {
        $statusColor = if ($entry.within_tolerance) { "Green" } else { "Yellow" }
        $statusText = if ($entry.within_tolerance) { "OK" } else { "DEVIATED" }

        Write-Host "`n[$($entry.timestamp)] $($entry.variable) - $statusText" -ForegroundColor $statusColor
        Write-Host "  Value: $($entry.old_value) â†’ $($entry.new_value)"
        Write-Host "  Optimal: $($entry.optimal) | Deviation: $([math]::Round($entry.deviation, 3)) ($($entry.deviation_pct)%)"
    }

    if ($state.adjustments_made.Count -gt 0) {
        Write-Host "`n=== RECENT ADJUSTMENTS ===" -ForegroundColor Cyan
        $recentAdjustments = $state.adjustments_made | Select-Object -Last 5

        foreach ($adj in $recentAdjustments) {
            Write-Host "`n[$($adj.timestamp)] $($adj.variable)"
            Write-Host "  Attempted: $($adj.attempted_value) â†’ Corrected: $($adj.corrected_value)"
            Write-Host "  Correction applied: $([math]::Round($adj.correction_applied, 3))"
            Write-Host "  Reason: $($adj.reason)"
        }
    }
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-HomeostasisStatus
    }

    "Track" {
        if (-not $Variable) {
            Write-Host "[ERROR] Provide -Variable and -CurrentValue" -ForegroundColor Red
            exit 1
        }

        Track-HomeostasisVariable -varName $Variable -newValue $CurrentValue
    }

    "Adjust" {
        if (-not $Variable) {
            Write-Host "[ERROR] Provide -Variable and -TargetValue" -ForegroundColor Red
            exit 1
        }

        Adjust-HomeostasisVariable -varName $Variable -targetValue $TargetValue
    }

    "History" {
        $last = 20
        if ($Variable -match "last=(\d+)") {
            $last = [int]$matches[1]
        }

        Get-HomeostasisHistory -last $last
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, Track, Adjust, History"
        exit 1
    }
}

