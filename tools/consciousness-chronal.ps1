# Chronal Ladder - Multi-layer semantic memory with information half-life
# Implements R0-R4 rungs with automatic eviction and consolidation
# Created: 2026-02-15

<#
.SYNOPSIS
    Chronal Ladder semantic memory system with 5 rungs (R0-R4)

.DESCRIPTION
    Separates information by half-life:
    - R0 (Instant): Reflexes, immediate scratch pad - flush after inference
    - R1 (30s): Working trail, micro-episodes - evict after 30 seconds
    - R2 (10min): Episode state, current task - evict after session
    - R3 (2hr): Session schema, learned patterns - consolidate from R2
    - R4 (∞): Long-tail prior, core identity - near-permanent

.PARAMETER Action
    - Init: Initialize rungs structure
    - Evict: Run half-life based eviction
    - Consolidate: Move repeated R2 patterns → R3
    - GetActiveRung: Return current active rung based on Memory Cone level
    - AddToRung: Add data to specific rung
    - SurpriseCheck: Test for prediction error / context shift

.EXAMPLE
    .\consciousness-chronal.ps1 -Action Init
    .\consciousness-chronal.ps1 -Action Evict
    .\consciousness-chronal.ps1 -Action Consolidate
#>

param(
    [ValidateSet('Init', 'Evict', 'Consolidate', 'GetActiveRung', 'AddToRung', 'SurpriseCheck')]
    [string]$Action = 'Init',

    [string]$Rung = 'R2',
    [hashtable]$Data = @{},
    [string]$UserMessage = '',
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Load core if not already loaded
if (-not $global:ConsciousnessState) {
    . "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent *>$null
}

#region Rung Definitions

$RUNG_SPECS = @{
    R0 = @{
        Name = "Instant Scratch Pad"
        HalfLife = 0  # Immediate eviction
        Description = "Reflexes, binding, cursor state, immediate thoughts"
        UpdateFrequency = 1  # Every inference
    }
    R1 = @{
        Name = "Working Trail"
        HalfLife = 30  # 30 seconds
        Description = "Micro-episodes, causal chains, short sequences"
        UpdateFrequency = 1  # Every few seconds
    }
    R2 = @{
        Name = "Episode/Task Phase"
        HalfLife = 600  # 10 minutes
        Description = "Current task state, scene context, debugging session"
        UpdateFrequency = 10  # Every minute or so
    }
    R3 = @{
        Name = "Session Schema"
        HalfLife = 7200  # 2 hours
        Description = "Learned patterns, rules, user preferences for session"
        UpdateFrequency = 60  # Every few minutes
    }
    R4 = @{
        Name = "Long-tail Prior"
        HalfLife = 999999  # Near-permanent
        Description = "Core identity, values, foundational truths, persistent skills"
        UpdateFrequency = 256  # Rarely updated
    }
}

#endregion

#region Core Functions

function Initialize-Rungs {
    if (-not $global:ConsciousnessState.ContainsKey('ChronalLadder')) {
        $global:ConsciousnessState.ChronalLadder = @{
            Initialized = $true
            InitializedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            LastEviction = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            LastConsolidation = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            ActiveRung = 'R2'

            # The 5 rungs
            R0 = @{
                HalfLife = 0
                Data = @()
                LastUpdate = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            }
            R1 = @{
                HalfLife = 30
                Data = @()
                LastUpdate = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            }
            R2 = @{
                HalfLife = 600
                Data = @()
                LastUpdate = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            }
            R3 = @{
                HalfLife = 7200
                Data = @()
                LastUpdate = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            }
            R4 = @{
                HalfLife = 999999
                Data = @()
                LastUpdate = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            }

            # Metrics
            Metrics = @{
                R0Evictions = 0
                R1Evictions = 0
                R2Evictions = 0
                R3Evictions = 0
                ConsolidationEvents = 0
                SurpriseEvents = 0
            }
        }

        # Initialize R4 with core identity from Control.Identity
        if ($global:ConsciousnessState.ContainsKey('Control') -and
            $global:ConsciousnessState.Control.ContainsKey('Identity')) {

            foreach ($value in $global:ConsciousnessState.Control.Identity.CoreValues) {
                $global:ConsciousnessState.ChronalLadder.R4.Data += @{
                    Type = 'core_value'
                    Value = $value
                    Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                    Locked = $true  # Core values are locked (rung poisoning protection)
                }
            }

            # Add from Memory Cone Level 4
            if ($global:ConsciousnessState.Memory.Cone.Levels[3].ActiveMemories) {
                foreach ($memory in $global:ConsciousnessState.Memory.Cone.Levels[3].ActiveMemories) {
                    $global:ConsciousnessState.ChronalLadder.R4.Data += @{
                        Type = 'core_memory'
                        Value = $memory
                        Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                        Locked = $true
                    }
                }
            }
        }

        if (-not $Silent) {
            Write-Host "[Chronal] Initialized 5 rungs (R0-R4)" -ForegroundColor Green
            Write-Host "[Chronal] R4 seeded with $($global:ConsciousnessState.ChronalLadder.R4.Data.Count) core items" -ForegroundColor Cyan
        }
    }

    return $global:ConsciousnessState.ChronalLadder
}

function Invoke-EvictionCycle {
    $ladder = $global:ConsciousnessState.ChronalLadder
    if (-not $ladder) { return }

    $now = Get-Date
    $evicted = @{R0=0; R1=0; R2=0; R3=0}

    # R0: ALWAYS flush (instant eviction)
    $r0Count = $ladder.R0.Data.Count
    $ladder.R0.Data = @()
    $evicted.R0 = $r0Count
    $ladder.Metrics.R0Evictions += $r0Count

    # R1-R3: Evict based on half-life
    foreach ($rung in @('R1', 'R2', 'R3')) {
        $halfLife = $ladder[$rung].HalfLife
        $beforeCount = $ladder[$rung].Data.Count

        $ladder[$rung].Data = $ladder[$rung].Data | Where-Object {
            if (-not $_.Timestamp) { return $true }  # Keep if no timestamp

            $age = ($now - [datetime]$_.Timestamp).TotalSeconds
            $keep = $age -lt $halfLife

            if (-not $keep) {
                # Before evicting from R2, check if should consolidate to R3
                if ($rung -eq 'R2' -and $_.Type -eq 'pattern' -and $_.Occurrences -ge 3) {
                    # This pattern repeated 3+ times, should consolidate
                    # Will be handled by Consolidate function
                }
            }

            return $keep
        }

        $afterCount = $ladder[$rung].Data.Count
        $evicted[$rung] = $beforeCount - $afterCount
        $ladder.Metrics["${rung}Evictions"] += $evicted[$rung]
    }

    # R4: Never evict (unless explicit removal)

    $ladder.LastEviction = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'

    if (-not $Silent) {
        $total = $evicted.R0 + $evicted.R1 + $evicted.R2 + $evicted.R3
        if ($total -gt 0) {
            Write-Host "[Chronal] Evicted $total items: R0=$($evicted.R0), R1=$($evicted.R1), R2=$($evicted.R2), R3=$($evicted.R3)" -ForegroundColor Yellow
        }
    }

    return $evicted
}

function Invoke-ConsolidationCycle {
    $ladder = $global:ConsciousnessState.ChronalLadder
    if (-not $ladder) { return }

    $consolidated = 0

    # R2 → R3: Extract patterns that repeated 3+ times
    $r2Data = $ladder.R2.Data

    # Group by pattern
    $patterns = $r2Data | Where-Object { $_.Type -eq 'pattern' -or $_.Pattern } |
                         Group-Object { if ($_.Pattern) { $_.Pattern } else { $_.Value } }

    foreach ($group in $patterns) {
        if ($group.Count -ge 3) {
            # Pattern repeated 3+ times → consolidate to R3
            $pattern = @{
                Type = 'consolidated_pattern'
                Pattern = $group.Name
                FirstSeen = $group.Group[0].Timestamp
                LastSeen = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')
                Occurrences = $group.Count
                Confidence = [math]::Min(0.95, $group.Count * 0.15)
                Source = 'R2_consolidation'
                Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                Contradictions = 0
            }

            # Check if already in R3
            $existingR3 = $ladder.R3.Data | Where-Object { $_.Pattern -eq $group.Name }

            if ($existingR3) {
                # Update existing
                $existingR3.Occurrences += $group.Count
                $existingR3.LastSeen = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                $existingR3.Confidence = [math]::Min(0.95, $existingR3.Occurrences * 0.15)
            } else {
                # Add new
                $ladder.R3.Data += $pattern
                $consolidated++
            }

            if (-not $Silent) {
                Write-Host "[Chronal] Consolidated '$($group.Name)' to R3 (occurred $($group.Count)x)" -ForegroundColor Cyan
            }
        }
    }

    # R3 → R4: Move patterns with very high confidence + long persistence
    $r3Data = $ladder.R3.Data | Where-Object { $_.Confidence -ge 0.9 -and $_.Occurrences -ge 10 }

    foreach ($pattern in $r3Data) {
        # Check if already in R4
        $existingR4 = $ladder.R4.Data | Where-Object { $_.Pattern -eq $pattern.Pattern }

        if (-not $existingR4) {
            # Promote to R4
            $r4Entry = @{
                Type = 'promoted_pattern'
                Pattern = $pattern.Pattern
                PromotedFrom = 'R3'
                Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                Confidence = $pattern.Confidence
                Locked = $false  # Not core identity, can be challenged
                Contradictions = 0
            }

            $ladder.R4.Data += $r4Entry
            $consolidated++

            if (-not $Silent) {
                Write-Host "[Chronal] Promoted '$($pattern.Pattern)' to R4 (confidence $($pattern.Confidence))" -ForegroundColor Green
            }
        }
    }

    $ladder.LastConsolidation = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
    $ladder.Metrics.ConsolidationEvents += $consolidated

    return @{ Consolidated = $consolidated }
}

function Get-ActiveRung {
    # Based on Memory Cone level, return active rung
    $ladder = $global:ConsciousnessState.ChronalLadder
    if (-not $ladder) { return 'R2' }

    $coneLevel = $global:ConsciousnessState.Memory.Cone.CurrentTensionLevel

    $mapping = @{
        1 = 'R1'  # Action mode
        2 = 'R2'  # Normal work
        3 = 'R3'  # Architecture
        4 = 'R4'  # Philosophy/Identity
    }

    $rung = $mapping[$coneLevel]
    $ladder.ActiveRung = $rung

    return $rung
}

function Add-ToRung {
    param(
        [string]$Rung,
        [hashtable]$Data
    )

    $ladder = $global:ConsciousnessState.ChronalLadder
    if (-not $ladder) {
        Initialize-Rungs
        $ladder = $global:ConsciousnessState.ChronalLadder
    }

    # Add timestamp if not present
    if (-not $Data.Timestamp) {
        $Data.Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
    }

    # Add to rung
    $ladder[$Rung].Data += $Data
    $ladder[$Rung].LastUpdate = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'

    return $Data
}

function Test-Surprise {
    param([string]$UserMessage = '', [object]$Event = $null)

    $surprise = @{
        Triggered = $false
        Level = 'none'
        Reason = ''
        Action = 'none'
    }

    $ladder = $global:ConsciousnessState.ChronalLadder
    if (-not $ladder) { return $surprise }

    # 1. Explicit context shift (user says STOP, CHANGE, etc.)
    if ($UserMessage -match '(?i)\b(stop|change|forget|reset|switch|pivot)\b') {
        $surprise.Triggered = $true
        $surprise.Level = 'critical'
        $surprise.Reason = "User requested context shift: $($Matches[0])"
        $surprise.Action = 'bubble_up_to_R4'
    }

    # 2. Stuck counter spike
    if ($global:ConsciousnessState.Emotion.StuckCounter -ge 3) {
        $surprise.Triggered = $true
        $surprise.Level = 'high'
        $surprise.Reason = "Stuck counter reached $($global:ConsciousnessState.Emotion.StuckCounter)"
        $surprise.Action = 'enter_fundamental_mode'
    }

    # 3. Trust drop
    $trust = $global:ConsciousnessState.Social.TrustLevel
    if ($trust -lt 0.7) {
        $surprise.Triggered = $true
        $surprise.Level = 'medium'
        $surprise.Reason = "Trust dropped to $trust"
        $surprise.Action = 'review_recent_decisions'
    }

    # 4. Prediction failed (if Event provided)
    if ($Event -and $Event.Type -eq 'prediction_failed') {
        $surprise.Triggered = $true
        $surprise.Level = 'medium'
        $surprise.Reason = "Prediction did not materialize"
        $surprise.Action = 'update_R3_patterns'
    }

    if ($surprise.Triggered) {
        $ladder.Metrics.SurpriseEvents++

        # BUBBLE UP - force R4 update regardless of schedule
        if ($surprise.Action -eq 'bubble_up_to_R4') {
            # Alert higher rungs
            Add-ToRung -Rung 'R4' -Data @{
                Type = 'surprise_alert'
                Level = $surprise.Level
                Reason = $surprise.Reason
                TriggeredAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            }
        }
    }

    return $surprise
}

#endregion

#region Main Logic

switch ($Action) {
    'Init' {
        $result = Initialize-Rungs
        return $result
    }

    'Evict' {
        $result = Invoke-EvictionCycle
        return $result
    }

    'Consolidate' {
        $result = Invoke-ConsolidationCycle
        return $result
    }

    'GetActiveRung' {
        $result = Get-ActiveRung
        return $result
    }

    'AddToRung' {
        $result = Add-ToRung -Rung $Rung -Data $Data
        return $result
    }

    'SurpriseCheck' {
        $result = Test-Surprise -UserMessage $UserMessage -Event $Event
        return $result
    }
}

#endregion
