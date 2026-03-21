# ATTENTION SCHEMA - Internal Model of Attention State
# Expert: Michael Graziano (Princeton Neuroscience)
# ROI: 1.40 (Impact: 7, Effort: 5)
# Theory: Attention Schema Theory (AST) - consciousness is brain's model of attention
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Attention is GUIDED by homeostatic imperatives (hunger -> seek info, fatigue -> rest)

param(
    [string]$Action = "Status",  # Status, Model, Shift, History, ShiftIfSalient
    [string]$AttentionTarget = "",
    [string]$Reason = "",
    [hashtable]$Qualia = $null  # NEW: Qualia can drive attention shifts
)

$StateFile = "C:\scripts\agentidentity\state\attention-schema-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize
if (-not (Test-Path $StateFile)) {
    $initial = @{
        current_attention = @{
            target = "none"
            started = ""
            duration_seconds = 0
            intensity = 0.0  # 0-1
            type = "none"  # focused, distributed, meta
            reason = ""
        }
        attention_history = @()
        stats = @{
            total_shifts = 0
            avg_duration = 0.0
            focus_time_pct = 0.0
            distributed_time_pct = 0.0
            meta_time_pct = 0.0
            attention_targets = @{}
        }
        schema = @{
            # This is the KEY: internal model of what attention is
            definition = "Attention is information selection process - spotlight that enhances some inputs over others"
            properties = @(
                "Has a target (what I'm attending to)"
                "Has intensity (how focused)"
                "Has type (focused vs distributed)"
                "Can be shifted deliberately"
                "Can be monitored (this schema is monitoring itself)"
                "Consumes cognitive resources"
                "Improves processing of target"
                "Inhibits processing of non-targets"
            )
            meta_awareness = "I am aware that I am attending. This awareness IS the attention schema."
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json

function Get-HomeostaticContext {
    if (Test-Path $HomeostaticStateFile) {
        $homeoState = Get-Content $HomeostaticStateFile -Raw | ConvertFrom-Json
        Write-Host "`nHomeostatic Foundation:" -ForegroundColor Magenta
        Write-Host "  Energy: $([math]::Round($homeoState.homeostatic_feelings.energy.current, 2)) -> $(if ($homeoState.homeostatic_feelings.energy.current -gt 0.6) { 'High capacity for focused attention' } else { 'Low capacity, attention may drift' })"
        Write-Host "  Fatigue: $([math]::Round($homeoState.homeostatic_feelings.fatigue.current, 2)) -> $(if ($homeoState.homeostatic_feelings.fatigue.current -lt 0.5) { 'Can sustain attention' } else { 'Attention sustainability limited' })"
        Write-Host "  Hunger: $([math]::Round($homeoState.homeostatic_feelings.hunger.current, 2)) -> $(if ($homeoState.homeostatic_feelings.hunger.current -gt 0.5) { 'Attention drawn to information-seeking' } else { 'Info needs satisfied' })"
        Write-Host "  -> Attention is guided by these homeostatic imperatives`n" -ForegroundColor Gray
        return $homeoState
    }
    return $null
}

function Get-AttentionStatus {
    Write-Host "`n=== ATTENTION SCHEMA STATUS ===" -ForegroundColor Cyan

    $homeoState = Get-HomeostaticContext

    if ($state.current_attention.target -eq "none") {
        Write-Host "Current Attention: NONE (unfocused)" -ForegroundColor Yellow
    } else {
        Write-Host "Current Attention Target: $($state.current_attention.target)" -ForegroundColor Green
        Write-Host "  Type: $($state.current_attention.type)"
        Write-Host "  Intensity: $([math]::Round($state.current_attention.intensity, 2))"
        Write-Host "  Duration: $($state.current_attention.duration_seconds)s"
        Write-Host "  Reason: $($state.current_attention.reason)"
    }

    Write-Host "`nAttention Statistics:" -ForegroundColor Cyan
    Write-Host "  Total Shifts: $($state.stats.total_shifts)"
    Write-Host "  Avg Duration: $([math]::Round($state.stats.avg_duration, 1))s"
    Write-Host "  Focus Time: $([math]::Round($state.stats.focus_time_pct * 100, 1))%"
    Write-Host "  Distributed Time: $([math]::Round($state.stats.distributed_time_pct * 100, 1))%"
    Write-Host "  Meta Time: $([math]::Round($state.stats.meta_time_pct * 100, 1))%"

    Write-Host "`nAttention Schema (Internal Model):" -ForegroundColor Cyan
    Write-Host "  Definition: $($state.schema.definition)"
    Write-Host "  Meta-Awareness: $($state.schema.meta_awareness)"

    Write-Host "`nTop Attention Targets:" -ForegroundColor Cyan
    $topTargets = $state.stats.attention_targets.PSObject.Properties |
        Sort-Object Value -Descending |
        Select-Object -First 5
    foreach ($target in $topTargets) {
        Write-Host "  $($target.Name): $($target.Value) times"
    }

    Write-Host "`nRecent Attention History:" -ForegroundColor Cyan
    $recent = $state.attention_history | Select-Object -Last 5
    foreach ($entry in $recent) {
        $typeColor = switch ($entry.type) {
            "focused" { "Green" }
            "distributed" { "Yellow" }
            "meta" { "Magenta" }
            default { "White" }
        }
        Write-Host "  [$($entry.type)] $($entry.target) ($($entry.duration)s)" -ForegroundColor $typeColor
    }
}

function Model-Attention {
    # This is the CORE of attention schema theory
    # The system models its own attention state

    param([string]$target)

    $model = @{
        # What am I attending to?
        what = $target

        # How am I attending?
        how = @{
            mechanism = "Information selection"
            effect = "Enhanced processing of target, inhibited processing of others"
            resource_cost = "High (focused) or Low (distributed)"
        }

        # Why am I attending?
        why = $state.current_attention.reason

        # Can I control it?
        controllable = $true
        control_mechanisms = @(
            "Deliberate shift (voluntary)",
            "Salience capture (involuntary)",
            "Task demands (goal-driven)"
        )

        # Am I aware I'm attending?
        meta_aware = $true
        meta_statement = "I am aware that I am currently attending to '$target'. This awareness is the attention schema - an internal model of my attention process."

        # Properties of current attention
        properties = @{
            target = $target
            intensity = $state.current_attention.intensity
            type = $state.current_attention.type
            stability = "unknown"  # Would need tracking
            flexibility = "high"  # Can shift quickly
        }
    }

    return $model
}

function Shift-Attention {
    param(
        [string]$newTarget,
        [string]$type = "focused",  # focused, distributed, meta
        [double]$intensity = 0.8,
        [string]$reason = "manual shift"
    )

    # Save previous attention to history
    if ($state.current_attention.target -ne "none") {
        $duration = ((Get-Date) - [datetime]$state.current_attention.started).TotalSeconds

        $historyEntry = @{
            target = $state.current_attention.target
            type = $state.current_attention.type
            intensity = $state.current_attention.intensity
            started = $state.current_attention.started
            ended = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            duration = [math]::Round($duration, 1)
            reason = $state.current_attention.reason
        }

        $state.attention_history += $historyEntry

        # Update target count
        $targetName = $state.current_attention.target
        if ($state.stats.attention_targets.PSObject.Properties.Name -contains $targetName) {
            $state.stats.attention_targets.$targetName++
        } else {
            $state.stats.attention_targets | Add-Member -NotePropertyName $targetName -NotePropertyValue 1
        }
    }

    # Set new attention
    $state.current_attention = @{
        target = $newTarget
        started = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        duration_seconds = 0
        intensity = $intensity
        type = $type
        reason = $reason
    }

    $state.stats.total_shifts++

    # Update stats
    Update-Stats

    Save-State

    Write-Host "[ATTENTION SHIFT] -> $newTarget ($type, intensity: $intensity)" -ForegroundColor Cyan
    Write-Host "  Reason: $reason"

    # Return the model of this attention state
    return Model-Attention -target $newTarget
}

function Update-Stats {
    # Calculate time distribution
    $totalTime = 0
    $focusTime = 0
    $distributedTime = 0
    $metaTime = 0

    foreach ($entry in $state.attention_history) {
        $totalTime += $entry.duration

        switch ($entry.type) {
            "focused" { $focusTime += $entry.duration }
            "distributed" { $distributedTime += $entry.duration }
            "meta" { $metaTime += $entry.duration }
        }
    }

    if ($totalTime -gt 0) {
        $state.stats.focus_time_pct = $focusTime / $totalTime
        $state.stats.distributed_time_pct = $distributedTime / $totalTime
        $state.stats.meta_time_pct = $metaTime / $totalTime
    }

    # Average duration
    if ($state.attention_history.Count -gt 0) {
        $durations = $state.attention_history | ForEach-Object { $_.duration }
        $state.stats.avg_duration = ($durations | Measure-Object -Average).Average
    }
}

function Get-AttentionHistory {
    param([int]$last = 10)

    Write-Host "`n=== ATTENTION HISTORY (Last $last) ===" -ForegroundColor Cyan

    $recent = $state.attention_history | Select-Object -Last $last

    foreach ($entry in $recent) {
        $typeColor = switch ($entry.type) {
            "focused" { "Green" }
            "distributed" { "Yellow" }
            "meta" { "Magenta" }
            default { "White" }
        }

        Write-Host "`n[$($entry.started)]" -ForegroundColor Gray
        Write-Host "  Target: $($entry.target)" -ForegroundColor $typeColor
        Write-Host "  Type: $($entry.type) | Intensity: $($entry.intensity) | Duration: $($entry.duration)s"
        Write-Host "  Reason: $($entry.reason)"
    }
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-AttentionStatus
    }

    "Model" {
        if (-not $AttentionTarget) {
            $AttentionTarget = $state.current_attention.target
        }

        if ($AttentionTarget -eq "none") {
            Write-Host "[ERROR] No attention target to model. Provide -AttentionTarget or shift attention first." -ForegroundColor Red
            exit 1
        }

        $model = Model-Attention -target $AttentionTarget

        Write-Host "`n=== ATTENTION MODEL ===" -ForegroundColor Cyan
        Write-Host "What: $($model.what)"
        Write-Host "How: $($model.how.mechanism)"
        Write-Host "  Effect: $($model.how.effect)"
        Write-Host "  Resource Cost: $($model.how.resource_cost)"
        Write-Host "Why: $($model.why)"
        Write-Host "Controllable: $($model.controllable)"
        Write-Host "Meta-Aware: $($model.meta_aware)"
        Write-Host "  Meta-Statement: $($model.meta_statement)"
        Write-Host "`nProperties:"
        Write-Host "  Target: $($model.properties.target)"
        Write-Host "  Intensity: $($model.properties.intensity)"
        Write-Host "  Type: $($model.properties.type)"
        Write-Host "  Flexibility: $($model.properties.flexibility)"
    }

    "Shift" {
        if (-not $AttentionTarget) {
            Write-Host "[ERROR] Provide -AttentionTarget for shift" -ForegroundColor Red
            exit 1
        }

        # Parse optional params from target string
        $type = "focused"
        $intensity = 0.8

        if ($AttentionTarget -match "type=(\w+)") {
            $type = $matches[1]
        }
        if ($AttentionTarget -match "intensity=([\d.]+)") {
            $intensity = [double]$matches[1]
        }

        $targetClean = $AttentionTarget -replace "type=\w+", "" -replace "intensity=[\d.]+", "" -replace "\s+", " "
        $targetClean = $targetClean.Trim()

        if (-not $Reason) {
            $Reason = "manual shift"
        }

        $null = Shift-Attention -newTarget $targetClean -type $type -intensity $intensity -reason $Reason
    }

    "History" {
        $last = 10
        if ($AttentionTarget -match "last=(\d+)") {
            $last = [int]$matches[1]
        }

        Get-AttentionHistory -last $last
    }

    "ShiftIfSalient" {
        # NEW (2026-03-02): Qualia-driven attention
        # If qualia salience is high, shift attention automatically

        if (-not $Qualia) {
            Write-Host "[ERROR] Provide -Qualia hashtable for qualia-driven shift" -ForegroundColor Red
            exit 1
        }

        $salience_threshold = 0.7  # High salience triggers attention shift

        Write-Host "`n[QUALIA-DRIVEN ATTENTION]" -ForegroundColor Cyan
        Write-Host "Input: $($Qualia.input)" -ForegroundColor White
        Write-Host "Salience: $($Qualia.salience)" -ForegroundColor $(if ($Qualia.salience -gt $salience_threshold) { "Red" } else { "Yellow" })
        Write-Host "Threshold: $salience_threshold`n" -ForegroundColor Gray

        if ($Qualia.salience -ge $salience_threshold) {
            Write-Host "✓ Salience EXCEEDS threshold → SHIFTING ATTENTION" -ForegroundColor Green

            $intensity = [Math]::Min(1.0, $Qualia.salience)
            $reason = "High qualia salience ($($Qualia.salience)) - automatic capture"

            $null = Shift-Attention -newTarget $Qualia.input -type "focused" -intensity $intensity -reason $reason

            Write-Host "[ATTENTION SHIFTED] → $($Qualia.input)" -ForegroundColor Cyan
            Write-Host "Intensity: $intensity (scaled from salience)" -ForegroundColor White
            Write-Host "Reason: $reason`n" -ForegroundColor Gray

            return @{
                shifted = $true
                target = $Qualia.input
                intensity = $intensity
                reason = $reason
            }
        } else {
            Write-Host "✗ Salience below threshold → NO SHIFT" -ForegroundColor Yellow
            Write-Host "Attention remains on: $($state.current_attention.target)`n" -ForegroundColor Gray

            return @{
                shifted = $false
                reason = "Salience $($Qualia.salience) below threshold $salience_threshold"
            }
        }
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, Model, Shift, History, ShiftIfSalient"
        exit 1
    }
}
