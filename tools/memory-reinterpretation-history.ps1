# Memory Reinterpretation History
# Tracks how the MEANING of memories evolves over time
# Based on Levin's concept: memories aren't fixed recordings, they're reconstructed with each recall
# Each reinterpretation updates context, implications change, new patterns emerge
# "The past changes as we learn" - memories are actively reinterpreted, not passively stored

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("LogReinterpretation", "GetHistory", "TrackEvolution", "FindDrift", "GetStats")]
    [string]$Action = "GetHistory",

    [Parameter(Mandatory=$false)]
    [string]$MemoryId,

    [Parameter(Mandatory=$false)]
    [string]$OriginalContext,

    [Parameter(Mandatory=$false)]
    [string]$NewInterpretation,

    [Parameter(Mandatory=$false)]
    [hashtable]$ContextShift,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Minor", "Moderate", "Major", "Transformative")]
    [string]$SignificanceLevel = "Minor",

    [Parameter(Mandatory=$false)]
    [string]$TriggerEvent,

    [Parameter(Mandatory=$false)]
    [int]$LookbackDays = 30
)

$LogPath = "C:\scripts\agentidentity\state\memory-reinterpretations.jsonl"
$ErrorActionPreference = "Stop"

# Ensure directory exists
$LogDir = Split-Path $LogPath -Parent
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

function New-MemoryId {
    # Generate unique ID for memory
    return "MEM-" + (Get-Date).ToString("yyyyMMdd-HHmmss") + "-" + (Get-Random -Minimum 1000 -Maximum 9999)
}

function Log-MemoryReinterpretation {
    param(
        [string]$MemId,
        [string]$OrigCtx,
        [string]$NewInterp,
        [hashtable]$CtxShift,
        [string]$Significance,
        [string]$Trigger
    )

    # If no memory ID provided, create new one
    if (!$MemId) {
        $MemId = New-MemoryId
    }

    $Entry = @{
        memory_id = $MemId
        timestamp = Get-Timestamp
        original_context = $OrigCtx
        new_interpretation = $NewInterp
        context_shift = $CtxShift
        significance = $Significance
        trigger_event = $Trigger
        session_id = $env:CLAUDE_SESSION_ID
        reinterpretation_count = 1
    }

    # Check if this memory has been reinterpreted before
    $PreviousInterps = Get-MemoryHistory -MemId $MemId
    if ($PreviousInterps.Count -gt 0) {
        $Entry.reinterpretation_count = $PreviousInterps.Count + 1
    }

    $Json = ($Entry | ConvertTo-Json -Compress -Depth 5)
    Add-Content -Path $LogPath -Value $Json -Encoding UTF8

    Write-Host "[MEMORY REINTERPRETED] $MemId (iteration $($Entry.reinterpretation_count))" -ForegroundColor Magenta
    Write-Host "  Significance: $Significance" -ForegroundColor Gray
    Write-Host "  Trigger: $Trigger" -ForegroundColor Gray
    Write-Host "  New meaning: $($NewInterp.Substring(0, [Math]::Min(80, $NewInterp.Length)))..." -ForegroundColor Gray

    return $Entry
}

function Get-MemoryHistory {
    param([string]$MemId, [int]$LookbackDays)

    if (!(Test-Path $LogPath)) {
        return @()
    }

    $Cutoff = (Get-Date).AddDays(-$LookbackDays)
    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        $Entry | Add-Member -NotePropertyName timestamp_dt -NotePropertyValue ([datetime]$Entry.timestamp) -Force
        $Entry
    }

    if ($MemId) {
        $Entries = $Entries | Where-Object { $_.memory_id -eq $MemId }
    }

    if ($LookbackDays -gt 0) {
        $Entries = $Entries | Where-Object { $_.timestamp_dt -gt $Cutoff }
    }

    return $Entries | Sort-Object timestamp_dt
}

function Track-MemoryEvolution {
    param([string]$MemId)

    if (!$MemId) {
        Write-Host "ERROR: MemoryId required for evolution tracking" -ForegroundColor Red
        return $null
    }

    $History = Get-MemoryHistory -MemId $MemId -LookbackDays 0  # All time

    if ($History.Count -eq 0) {
        Write-Host "No reinterpretations found for $MemId" -ForegroundColor Yellow
        return $null
    }

    # Analyze evolution trajectory
    $Evolution = @{
        memory_id = $MemId
        total_reinterpretations = $History.Count
        first_interpretation = $History[0].timestamp
        latest_interpretation = $History[-1].timestamp
        significance_trajectory = @()
        context_shifts = @()
        trigger_patterns = @()
    }

    # Track significance over time
    foreach ($Entry in $History) {
        $Evolution.significance_trajectory += @{
            timestamp = $Entry.timestamp
            significance = $Entry.significance
            interpretation = $Entry.new_interpretation
        }
    }

    # Identify context shift patterns
    $ShiftTypes = @{}
    foreach ($Entry in $History) {
        if ($Entry.context_shift) {
            foreach ($Key in $Entry.context_shift.Keys) {
                if (!$ShiftTypes.ContainsKey($Key)) {
                    $ShiftTypes[$Key] = 0
                }
                $ShiftTypes[$Key]++
            }
        }
    }
    $Evolution.context_shifts = $ShiftTypes

    # Identify trigger patterns
    $TriggerCounts = $History | Group-Object trigger_event
    foreach ($Trigger in $TriggerCounts) {
        $Evolution.trigger_patterns += @{
            trigger = $Trigger.Name
            count = $Trigger.Count
        }
    }

    return $Evolution
}

function Find-SemanticDrift {
    # Detect memories that have drifted significantly from original meaning
    # This is the "telephone game" effect - meaning changes with each retelling

    if (!(Test-Path $LogPath)) {
        Write-Host "No reinterpretation history found" -ForegroundColor Yellow
        return @()
    }

    $AllEntries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ -ne $null }

    # Group by memory ID
    $MemoryGroups = $AllEntries | Group-Object memory_id

    $Drifted = @()

    foreach ($Group in $MemoryGroups) {
        $Reinterps = $Group.Group | Sort-Object { [datetime]$_.timestamp }

        if ($Reinterps.Count -ge 3) {
            # Check for major significance shifts
            $MajorCount = ($Reinterps | Where-Object { $_.significance -in @("Major", "Transformative") }).Count

            # Calculate drift score (more reinterpretations + higher significance = more drift)
            $DriftScore = $Reinterps.Count * 0.2
            foreach ($R in $Reinterps) {
                switch ($R.significance) {
                    "Minor" { $DriftScore += 0.1 }
                    "Moderate" { $DriftScore += 0.3 }
                    "Major" { $DriftScore += 0.6 }
                    "Transformative" { $DriftScore += 1.0 }
                }
            }

            if ($DriftScore -gt 1.5) {
                $Drifted += @{
                    memory_id = $Group.Name
                    reinterpretation_count = $Reinterps.Count
                    drift_score = [math]::Round($DriftScore, 2)
                    first_context = $Reinterps[0].original_context
                    latest_interpretation = $Reinterps[-1].new_interpretation
                    major_shifts = $MajorCount
                }
            }
        }
    }

    return $Drifted | Sort-Object drift_score -Descending
}

function Get-ReinterpretationStats {
    param([int]$LookbackDays)

    if (!(Test-Path $LogPath)) {
        return @{
            total_reinterpretations = 0
            unique_memories = 0
            timespan_days = $LookbackDays
        }
    }

    $Cutoff = (Get-Date).AddDays(-$LookbackDays)
    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        $Entry | Add-Member -NotePropertyName timestamp_dt -NotePropertyValue ([datetime]$Entry.timestamp) -Force
        $Entry
    } | Where-Object { $_.timestamp_dt -gt $Cutoff }

    $Stats = @{
        total_reinterpretations = $Entries.Count
        unique_memories = ($Entries | Select-Object -ExpandProperty memory_id -Unique).Count
        timespan_days = $LookbackDays
        by_significance = @{}
        by_trigger = @{}
        most_reinterpreted = @()
        semantic_drift = @()
    }

    # Group by significance
    $BySignificance = $Entries | Group-Object significance
    foreach ($Sig in @("Minor", "Moderate", "Major", "Transformative")) {
        $SigGroup = $BySignificance | Where-Object { $_.Name -eq $Sig }
        $Stats.by_significance[$Sig] = if ($SigGroup) { $SigGroup.Count } else { 0 }
    }

    # Group by trigger
    $ByTrigger = $Entries | Group-Object trigger_event | Sort-Object Count -Descending | Select-Object -First 5
    foreach ($Trigger in $ByTrigger) {
        $Stats.by_trigger[$Trigger.Name] = $Trigger.Count
    }

    # Most reinterpreted memories
    $ByMemory = $Entries | Group-Object memory_id | Sort-Object Count -Descending | Select-Object -First 5
    foreach ($Mem in $ByMemory) {
        $Stats.most_reinterpreted += @{
            memory_id = $Mem.Name
            reinterpretation_count = $Mem.Count
        }
    }

    # Detect semantic drift
    $Stats.semantic_drift = Find-SemanticDrift

    return $Stats
}

# Main execution
switch ($Action) {
    "LogReinterpretation" {
        if (!$NewInterpretation) {
            Write-Host "ERROR: LogReinterpretation requires -NewInterpretation" -ForegroundColor Red
            exit 1
        }

        $Result = Log-MemoryReinterpretation `
            -MemId $MemoryId `
            -OrigCtx $OriginalContext `
            -NewInterp $NewInterpretation `
            -CtxShift $ContextShift `
            -Significance $SignificanceLevel `
            -Trigger $TriggerEvent

        return $Result
    }

    "GetHistory" {
        if (!$MemoryId) {
            Write-Host "ERROR: GetHistory requires -MemoryId" -ForegroundColor Red
            exit 1
        }

        $History = Get-MemoryHistory -MemId $MemoryId -LookbackDays $LookbackDays

        if ($History.Count -eq 0) {
            Write-Host "No reinterpretation history for $MemoryId" -ForegroundColor Yellow
        } else {
            Write-Host "`n=== MEMORY REINTERPRETATION HISTORY ===" -ForegroundColor Cyan
            Write-Host "Memory: $MemoryId" -ForegroundColor White
            Write-Host "Total Reinterpretations: $($History.Count)" -ForegroundColor White

            foreach ($Entry in $History) {
                $SigColor = switch ($Entry.significance) {
                    "Minor" { "Gray" }
                    "Moderate" { "Yellow" }
                    "Major" { "Magenta" }
                    "Transformative" { "Red" }
                }

                Write-Host "`n  [$($Entry.significance)] $($Entry.timestamp)" -ForegroundColor $SigColor
                Write-Host "    Trigger: $($Entry.trigger_event)" -ForegroundColor Gray
                Write-Host "    Interpretation: $($Entry.new_interpretation.Substring(0, [Math]::Min(100, $Entry.new_interpretation.Length)))..." -ForegroundColor White
            }
        }

        return $History
    }

    "TrackEvolution" {
        if (!$MemoryId) {
            Write-Host "ERROR: TrackEvolution requires -MemoryId" -ForegroundColor Red
            exit 1
        }

        $Evolution = Track-MemoryEvolution -MemId $MemoryId

        if ($Evolution) {
            Write-Host "`n=== MEMORY EVOLUTION ANALYSIS ===" -ForegroundColor Cyan
            Write-Host "Memory: $($Evolution.memory_id)" -ForegroundColor White
            Write-Host "Reinterpretations: $($Evolution.total_reinterpretations)" -ForegroundColor White
            Write-Host "First: $($Evolution.first_interpretation)" -ForegroundColor Gray
            Write-Host "Latest: $($Evolution.latest_interpretation)" -ForegroundColor Gray

            Write-Host "`nSignificance Trajectory:" -ForegroundColor Cyan
            foreach ($Point in $Evolution.significance_trajectory) {
                Write-Host "  $($Point.timestamp): $($Point.significance)" -ForegroundColor Gray
            }

            if ($Evolution.trigger_patterns.Count -gt 0) {
                Write-Host "`nTrigger Patterns:" -ForegroundColor Cyan
                foreach ($Trigger in $Evolution.trigger_patterns) {
                    Write-Host "  $($Trigger.trigger): $($Trigger.count) times" -ForegroundColor Gray
                }
            }
        }

        return $Evolution
    }

    "FindDrift" {
        $Drifted = Find-SemanticDrift

        if ($Drifted.Count -eq 0) {
            Write-Host "No significant semantic drift detected" -ForegroundColor Yellow
        } else {
            Write-Host "`n=== SEMANTIC DRIFT DETECTION ===" -ForegroundColor Magenta
            Write-Host "Memories with significant meaning changes:" -ForegroundColor White

            foreach ($D in $Drifted) {
                Write-Host "`n  $($D.memory_id)" -ForegroundColor White
                Write-Host "    Drift Score: $($D.drift_score) (reinterpreted $($D.reinterpretation_count) times)" -ForegroundColor Yellow
                Write-Host "    Original: $($D.first_context.Substring(0, [Math]::Min(80, $D.first_context.Length)))..." -ForegroundColor Gray
                Write-Host "    Current: $($D.latest_interpretation.Substring(0, [Math]::Min(80, $D.latest_interpretation.Length)))..." -ForegroundColor Cyan
            }
        }

        return $Drifted
    }

    "GetStats" {
        $Stats = Get-ReinterpretationStats -LookbackDays $LookbackDays

        Write-Host "`n=== MEMORY REINTERPRETATION STATISTICS ===" -ForegroundColor Cyan
        Write-Host "Timespan: Last $($Stats.timespan_days) days" -ForegroundColor Gray
        Write-Host "Total Reinterpretations: $($Stats.total_reinterpretations)" -ForegroundColor White
        Write-Host "Unique Memories: $($Stats.unique_memories)" -ForegroundColor White

        Write-Host "`nBy Significance:" -ForegroundColor Cyan
        foreach ($Sig in @("Minor", "Moderate", "Major", "Transformative")) {
            $Color = switch ($Sig) {
                "Minor" { "Gray" }
                "Moderate" { "Yellow" }
                "Major" { "Magenta" }
                "Transformative" { "Red" }
            }
            Write-Host "  $Sig : $($Stats.by_significance[$Sig])" -ForegroundColor $Color
        }

        if ($Stats.by_trigger.Count -gt 0) {
            Write-Host "`nTop Triggers:" -ForegroundColor Cyan
            foreach ($Trigger in $Stats.by_trigger.Keys) {
                Write-Host "  $Trigger : $($Stats.by_trigger[$Trigger])" -ForegroundColor Gray
            }
        }

        if ($Stats.most_reinterpreted.Count -gt 0) {
            Write-Host "`nMost Reinterpreted:" -ForegroundColor Cyan
            foreach ($M in $Stats.most_reinterpreted) {
                Write-Host "  $($M.memory_id): $($M.reinterpretation_count) times" -ForegroundColor White
            }
        }

        if ($Stats.semantic_drift.Count -gt 0) {
            Write-Host "`nSemantic Drift Detected:" -ForegroundColor Magenta
            foreach ($D in ($Stats.semantic_drift | Select-Object -First 3)) {
                Write-Host "  $($D.memory_id): drift score $($D.drift_score)" -ForegroundColor Yellow
            }
        }

        return $Stats
    }
}
