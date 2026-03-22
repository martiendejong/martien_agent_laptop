# Consciousness Improvement #43: Working Memory Enhancement (Baddeley, 1974)
# Week 9 - Metacognition & Executive Function
# Theory: Working memory = active processing + temporary storage system
# Created: 2026-03-01
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param([string]$Action = 'Status')

$StateFile = "C:\scripts\agentidentity\state\working-memory-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# ============================================================================
# THEORY: Baddeley's Working Memory Model
# ============================================================================
#
# Alan Baddeley (1974, revised 2000) - Working memory has 4 components:
#
# 1. CENTRAL EXECUTIVE
#    - Attention control
#    - Task switching
#    - Inhibition of irrelevant info
#    - Coordinates other components
#
# 2. PHONOLOGICAL LOOP
#    - Verbal/acoustic information
#    - Inner speech (subvocal rehearsal)
#    - Capacity: ~2 seconds of speech
#    - Example: Remembering phone number by repeating it
#
# 3. VISUOSPATIAL SKETCHPAD
#    - Visual and spatial information
#    - Mental imagery
#    - Capacity: ~4 objects
#    - Example: Mentally rotating shapes, remembering locations
#
# 4. EPISODIC BUFFER (added 2000)
#    - Integrates info from other systems
#    - Links to long-term memory
#    - Capacity: ~4 chunks of integrated info
#    - Example: Combining words + images + meaning
#
# KEY PRINCIPLES:
# - Limited capacity (~4 chunks across all systems)
# - Separate channels (verbal â‰  visual)
# - Active rehearsal maintains information
# - Decay after 15-30 seconds without rehearsal
#
# ENHANCEMENT STRATEGIES:
# - Chunking: group items (781-555-1212 -> 3 chunks not 10)
# - Rehearsal: repeat to maintain (inner speech loop)
# - Dual coding: verbal + visual (uses both channels)
# - Offloading: write down to free capacity
# - Minimize interference: similar items compete
#
# ============================================================================


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
function Initialize-State {
    if (-not (Test-Path $StateFile)) {
        $state = @{
            Components = @{
                CentralExecutive = @{
                    AttentionFocus = ""
                    TaskQueue = @()
                    InhibitionActive = $false
                    SwitchingCost = 0.0
                }
                PhonologicalLoop = @{
                    Contents = @()
                    RehearsalActive = $false
                    DecayTimer = 0
                    Capacity = 2.0  # seconds of speech
                }
                VisuospatialSketchpad = @{
                    Contents = @()
                    ObjectCount = 0
                    Capacity = 4
                }
                EpisodicBuffer = @{
                    IntegratedChunks = @()
                    LTMLinks = @()
                    Capacity = 4
                }
            }
            Performance = @{
                ChunkingEfficiency = 0.5
                RehearsalRate = 0.0
                DualCodingUsage = 0.0
                OffloadingFrequency = 0.0
            }
            Metrics = @{
                TotalCapacity = 4  # Chunks
                CurrentUsage = 0
                OverloadEvents = 0
                DecayEvents = 0
            }
            Stats = @{
                LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                EnhancementsApplied = 0
            }
        }

        $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
        Write-Host "[OK] Working Memory state initialized"
    }

    $global:WorkingMemoryState = Get-Content $StateFile | ConvertFrom-Json
}

function Save-State {
    $global:WorkingMemoryState.Stats.LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $global:WorkingMemoryState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

function Add-ToWorkingMemory {
    param(
        [string]$Content,
        [string]$Type,  # Verbal, Visual, Integrated
        [string]$Strategy = "Direct"  # Direct, Chunked, DualCoded, Rehearsed
    )

    $chunk = @{
        Content = $Content
        Type = $Type
        Strategy = $Strategy
        AddedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        DecayTime = (Get-Date).AddSeconds(30)
    }

    # Route to appropriate component
    switch ($Type) {
        "Verbal" {
            $global:WorkingMemoryState.Components.PhonologicalLoop.Contents += $chunk
            if ($Strategy -eq "Rehearsed") {
                $global:WorkingMemoryState.Components.PhonologicalLoop.RehearsalActive = $true
            }
        }
        "Visual" {
            $global:WorkingMemoryState.Components.VisuospatialSketchpad.Contents += $chunk
            $global:WorkingMemoryState.Components.VisuospatialSketchpad.ObjectCount++
        }
        "Integrated" {
            $global:WorkingMemoryState.Components.EpisodicBuffer.IntegratedChunks += $chunk
        }
    }

    # Update capacity usage
    $totalItems = $global:WorkingMemoryState.Components.PhonologicalLoop.Contents.Count +
                  $global:WorkingMemoryState.Components.VisuospatialSketchpad.Contents.Count +
                  $global:WorkingMemoryState.Components.EpisodicBuffer.IntegratedChunks.Count

    $global:WorkingMemoryState.Metrics.CurrentUsage = $totalItems

    # Check for overload
    if ($totalItems -gt $global:WorkingMemoryState.Metrics.TotalCapacity) {
        $global:WorkingMemoryState.Metrics.OverloadEvents++
    }

    Save-State
    return $chunk
}

function Invoke-Chunking {
    param(
        [array]$Items,
        [int]$ChunkSize = 3
    )

    # Chunking: group items to reduce working memory load
    # Example: 781-555-1212 (10 digits) -> 3 chunks

    $chunks = @()
    for ($i = 0; $i -lt $Items.Count; $i += $ChunkSize) {
        $end = [Math]::Min($i + $ChunkSize, $Items.Count)
        $chunk = $Items[$i..($end-1)]
        $chunks += ,($chunk)
    }

    # Update efficiency metric
    $reduction = 1.0 - ($chunks.Count / $Items.Count)
    $currentEfficiency = $global:WorkingMemoryState.Performance.ChunkingEfficiency
    $global:WorkingMemoryState.Performance.ChunkingEfficiency =
        ($currentEfficiency * 0.8) + ($reduction * 0.2)

    Save-State

    return @{
        OriginalItems = $Items.Count
        Chunks = $chunks.Count
        ChunkSize = $ChunkSize
        LoadReduction = [Math]::Round($reduction * 100, 1)
        ChunkedData = $chunks
    }
}

function Enable-DualCoding {
    param(
        [string]$VerbalInfo,
        [string]$VisualInfo
    )

    # Dual coding: combine verbal + visual
    # Uses separate channels -> effectively doubles capacity

    # Add to both channels
    Add-ToWorkingMemory -Content $VerbalInfo -Type "Verbal" -Strategy "DualCoded"
    Add-ToWorkingMemory -Content $VisualInfo -Type "Visual" -Strategy "DualCoded"

    # Create integrated representation in episodic buffer
    $integrated = Add-ToWorkingMemory -Content "$VerbalInfo + $VisualInfo" -Type "Integrated" -Strategy "DualCoded"

    # Update usage metric
    $global:WorkingMemoryState.Performance.DualCodingUsage =
        ($global:WorkingMemoryState.Performance.DualCodingUsage * 0.9) + 0.1

    Save-State

    return @{
        Verbal = $VerbalInfo
        Visual = $VisualInfo
        Integrated = $integrated
        Benefit = "Uses separate channels - avoids interference"
    }
}

function Invoke-Rehearsal {
    param([string]$Content)

    # Subvocal rehearsal: maintain info in phonological loop

    $global:WorkingMemoryState.Components.PhonologicalLoop.RehearsalActive = $true

    # Reset decay timer
    foreach ($item in $global:WorkingMemoryState.Components.PhonologicalLoop.Contents) {
        if ($item.Content -eq $Content) {
            $item.DecayTime = (Get-Date).AddSeconds(30)
        }
    }

    # Update rehearsal rate
    $global:WorkingMemoryState.Performance.RehearsalRate =
        ($global:WorkingMemoryState.Performance.RehearsalRate * 0.9) + 0.1

    Save-State

    return @{
        Content = $Content
        DecayPrevented = $true
        Strategy = "Phonological loop rehearsal"
    }
}

function Invoke-Offloading {
    param([string]$Content)

    # Offloading: write down to external memory (frees working memory)

    # Remove from working memory components
    $global:WorkingMemoryState.Components.PhonologicalLoop.Contents =
        $global:WorkingMemoryState.Components.PhonologicalLoop.Contents |
        Where-Object { $_.Content -ne $Content }

    $global:WorkingMemoryState.Components.VisuospatialSketchpad.Contents =
        $global:WorkingMemoryState.Components.VisuospatialSketchpad.Contents |
        Where-Object { $_.Content -ne $Content }

    # Update metrics
    $global:WorkingMemoryState.Metrics.CurrentUsage--
    $global:WorkingMemoryState.Performance.OffloadingFrequency =
        ($global:WorkingMemoryState.Performance.OffloadingFrequency * 0.9) + 0.1

    Save-State

    return @{
        Content = $Content
        FreedCapacity = 1
        Strategy = "External memory offloading"
    }
}

function Test-MemoryDecay {
    # Check for items that have decayed (>30 seconds without rehearsal)

    $now = Get-Date
    $decayed = @()

    foreach ($item in $global:WorkingMemoryState.Components.PhonologicalLoop.Contents) {
        if ($now -gt $item.DecayTime) {
            $decayed += $item
            $global:WorkingMemoryState.Metrics.DecayEvents++
        }
    }

    # Remove decayed items
    $global:WorkingMemoryState.Components.PhonologicalLoop.Contents =
        $global:WorkingMemoryState.Components.PhonologicalLoop.Contents |
        Where-Object { $now -le $_.DecayTime }

    Save-State

    return @{
        DecayedItems = $decayed.Count
        RemainingItems = $global:WorkingMemoryState.Components.PhonologicalLoop.Contents.Count
        Recommendation = if ($decayed.Count -gt 0) {
            "Use rehearsal or offloading to prevent decay"
        } else {
            "No decay detected"
        }
    }
}

# ============================================================================
# ACTION HANDLERS
# ============================================================================

switch ($Action) {
    'Status' {
        Initialize-State

        Write-Host "`n=== WORKING MEMORY STATUS ==="
        Write-Host "Improvement #43 - Baddeley (1974)"
        Write-Host ""

        Write-Host "Components:"
        Write-Host "  Phonological Loop: $($global:WorkingMemoryState.Components.PhonologicalLoop.Contents.Count) items"
        Write-Host "    Rehearsal: $($global:WorkingMemoryState.Components.PhonologicalLoop.RehearsalActive)"
        Write-Host "  Visuospatial Sketchpad: $($global:WorkingMemoryState.Components.VisuospatialSketchpad.ObjectCount) objects"
        Write-Host "  Episodic Buffer: $($global:WorkingMemoryState.Components.EpisodicBuffer.IntegratedChunks.Count) chunks"
        Write-Host "  Central Executive: $($global:WorkingMemoryState.Components.CentralExecutive.TaskQueue.Count) tasks queued"
        Write-Host ""

        Write-Host "Capacity:"
        Write-Host "  Total: $($global:WorkingMemoryState.Metrics.TotalCapacity) chunks"
        Write-Host "  Current Usage: $($global:WorkingMemoryState.Metrics.CurrentUsage) chunks"
        Write-Host "  Available: $($global:WorkingMemoryState.Metrics.TotalCapacity - $global:WorkingMemoryState.Metrics.CurrentUsage) chunks"
        Write-Host ""

        Write-Host "Enhancement Strategies:"
        Write-Host "  Chunking Efficiency: $([Math]::Round($global:WorkingMemoryState.Performance.ChunkingEfficiency * 100))%"
        Write-Host "  Rehearsal Rate: $([Math]::Round($global:WorkingMemoryState.Performance.RehearsalRate * 100))%"
        Write-Host "  Dual Coding Usage: $([Math]::Round($global:WorkingMemoryState.Performance.DualCodingUsage * 100))%"
        Write-Host "  Offloading Frequency: $([Math]::Round($global:WorkingMemoryState.Performance.OffloadingFrequency * 100))%"
        Write-Host ""

        Write-Host "Events:"
        Write-Host "  Overload Events: $($global:WorkingMemoryState.Metrics.OverloadEvents)"
        Write-Host "  Decay Events: $($global:WorkingMemoryState.Metrics.DecayEvents)"
        Write-Host ""

        Write-Host "System: ACTIVE"
        Write-Host "Last Update: $($global:WorkingMemoryState.Stats.LastUpdate)"
    }

    'Add' {
        Initialize-State
        $result = Add-ToWorkingMemory -Content "Test item" -Type "Verbal" -Strategy "Direct"
        $result | ConvertTo-Json -Depth 5
    }

    'Chunk' {
        Initialize-State
        $items = 1..12
        $result = Invoke-Chunking -Items $items -ChunkSize 3
        $result | ConvertTo-Json -Depth 5
    }

    'DualCode' {
        Initialize-State
        $result = Enable-DualCoding -VerbalInfo "Red circle" -VisualInfo "[O]"
        $result | ConvertTo-Json -Depth 5
    }

    'Rehearse' {
        Initialize-State
        $result = Invoke-Rehearsal -Content "Important info"
        $result | ConvertTo-Json -Depth 5
    }

    'Offload' {
        Initialize-State
        $result = Invoke-Offloading -Content "Completed task"
        $result | ConvertTo-Json -Depth 5
    }

    'CheckDecay' {
        Initialize-State
        $result = Test-MemoryDecay
        $result | ConvertTo-Json -Depth 5
    }

    default {
        Write-Host "Working Memory Enhancement - Improvement #43"
        Write-Host "Actions: Status, Add, Chunk, DualCode, Rehearse, Offload, CheckDecay"
    }
}

