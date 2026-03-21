# Consciousness Improvement #42: Cognitive Load Management (Sweller, 1988)
# Week 9 - Metacognition & Executive Function
# Theory: Cognitive Load Theory - optimize working memory usage for learning
# Created: 2026-03-01
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param([string]$Action = 'Status')

$StateFile = "C:\scripts\agentidentity\state\cognitive-load-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# ============================================================================
# THEORY: Sweller's Cognitive Load Theory
# ============================================================================
#
# John Sweller (1988) identified three types of cognitive load:
#
# 1. INTRINSIC LOAD
#    - Inherent difficulty of material
#    - Example: Quantum physics > basic arithmetic
#    - Cannot be reduced (material is what it is)
#    - Strategy: Break into smaller chunks
#
# 2. EXTRANEOUS LOAD
#    - Poorly designed instruction adds unnecessary difficulty
#    - Example: Bad diagrams, confusing explanations, split attention
#    - CAN and SHOULD be reduced
#    - Strategy: Eliminate waste, optimize presentation
#
# 3. GERMANE LOAD
#    - Effort building schemas (actual learning)
#    - Example: Making connections, organizing knowledge
#    - SHOULD be maximized (this is productive work)
#    - Strategy: Encourage deep processing
#
# WORKING MEMORY LIMITS:
# - Miller (1956): 7 +/- 2 chunks
# - Cowan (2001): Actually ~4 chunks
# - Duration: 15-30 seconds without rehearsal
#
# COGNITIVE LOAD EFFECTS:
# - Split-attention: looking at two sources simultaneously
# - Redundancy: same info in multiple formats (wastes capacity)
# - Modality: audio + visual > visual + visual (separate channels)
# - Worked examples: studying solutions > solving from scratch (early learning)
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
            CurrentLoad = @{
                Intrinsic = 0.0      # 0-1: difficulty of current task
                Extraneous = 0.0     # 0-1: unnecessary load from poor design
                Germane = 0.0        # 0-1: productive learning effort
                Total = 0.0          # Sum of all three
            }
            WorkingMemory = @{
                Capacity = 4         # Chunks (Cowan 2001)
                CurrentUsage = 0     # Active chunks
                Overload = 0         # Times exceeded capacity
            }
            LoadHistory = @()
            Optimizations = @{
                ChunkingApplied = 0      # Times broke down complex material
                RedundancyRemoved = 0    # Times eliminated duplicate info
                SplitAttentionFixed = 0  # Times integrated split sources
                WorkedExamplesUsed = 0   # Times studied solutions first
            }
            Stats = @{
                LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                AverageLoad = 0.5
                OptimalLoadRange = @(0.5, 0.8)  # Sweet spot for learning
            }
        }

        $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
        Write-Host "[OK] Cognitive Load state initialized"
    }

    $global:CognitiveLoadState = Get-Content $StateFile | ConvertFrom-Json
}

function Save-State {
    $global:CognitiveLoadState.Stats.LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $global:CognitiveLoadState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

function Measure-CognitiveLoad {
    param(
        [string]$Task,
        [int]$ElementCount,        # How many things to track
        [string]$Presentation,      # Clear, Confusing, Mixed
        [string]$Complexity         # Simple, Moderate, Complex
    )

    # Intrinsic load: task complexity
    $intrinsic = switch ($Complexity) {
        "Simple"   { 0.2 }
        "Moderate" { 0.5 }
        "Complex"  { 0.9 }
        default    { 0.5 }
    }

    # Extraneous load: poor presentation adds waste
    $extraneous = switch ($Presentation) {
        "Clear"     { 0.1 }
        "Mixed"     { 0.3 }
        "Confusing" { 0.6 }
        default     { 0.2 }
    }

    # Germane load: productive learning effort
    # Increases with task complexity (more schema building needed)
    $germane = $intrinsic * 0.7

    $total = $intrinsic + $extraneous + $germane

    # Check working memory capacity
    $chunksNeeded = [Math]::Ceiling($ElementCount / 3.0)  # Chunk ~3 items
    $capacity = $global:CognitiveLoadState.WorkingMemory.Capacity
    $overloaded = $chunksNeeded -gt $capacity

    if ($overloaded) {
        $global:CognitiveLoadState.WorkingMemory.Overload++
    }

    # Update state
    $global:CognitiveLoadState.CurrentLoad.Intrinsic = $intrinsic
    $global:CognitiveLoadState.CurrentLoad.Extraneous = $extraneous
    $global:CognitiveLoadState.CurrentLoad.Germane = $germane
    $global:CognitiveLoadState.CurrentLoad.Total = $total
    $global:CognitiveLoadState.WorkingMemory.CurrentUsage = $chunksNeeded

    $entry = @{
        Task = $Task
        Intrinsic = $intrinsic
        Extraneous = $extraneous
        Germane = $germane
        Total = $total
        ChunksNeeded = $chunksNeeded
        Overloaded = $overloaded
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    $global:CognitiveLoadState.LoadHistory += $entry
    Save-State

    return $entry
}

function Optimize-CognitiveLoad {
    param([string]$Problem)

    # Sweller's optimization strategies

    $recommendations = @()

    # Strategy 1: Chunking (reduce intrinsic load)
    if ($Problem -match "too many|overwhelming|complex") {
        $recommendations += @{
            Strategy = "Chunking"
            Description = "Break task into 3-4 smaller chunks"
            Example = "Don't learn all 10 concepts at once. Group into themes of 3."
            LoadReduction = "Intrinsic"
        }
        $global:CognitiveLoadState.Optimizations.ChunkingApplied++
    }

    # Strategy 2: Remove redundancy (reduce extraneous load)
    if ($Problem -match "confusing|duplicate|repeated") {
        $recommendations += @{
            Strategy = "Remove Redundancy"
            Description = "Present information once in clearest format"
            Example = "Don't read text aloud while showing same text on screen"
            LoadReduction = "Extraneous"
        }
        $global:CognitiveLoadState.Optimizations.RedundancyRemoved++
    }

    # Strategy 3: Integrate split attention (reduce extraneous load)
    if ($Problem -match "switching|multiple sources|scattered") {
        $recommendations += @{
            Strategy = "Integrate Sources"
            Description = "Combine related information into single view"
            Example = "Put diagram labels ON diagram, not in separate legend"
            LoadReduction = "Extraneous"
        }
        $global:CognitiveLoadState.Optimizations.SplitAttentionFixed++
    }

    # Strategy 4: Worked examples (optimize germane load)
    if ($Problem -match "stuck|don't know where to start") {
        $recommendations += @{
            Strategy = "Study Worked Examples"
            Description = "Learn from complete solutions before solving yourself"
            Example = "Study 3 solved problems, then solve similar problem"
            LoadReduction = "None (increases germane load productively)"
        }
        $global:CognitiveLoadState.Optimizations.WorkedExamplesUsed++
    }

    # Strategy 5: Use dual channels (audio + visual)
    if ($Problem -match "reading while looking|visual overload") {
        $recommendations += @{
            Strategy = "Dual Modality"
            Description = "Combine audio explanation with visual diagram"
            Example = "Narration + diagram > text + diagram (uses separate channels)"
            LoadReduction = "Extraneous"
        }
    }

    Save-State

    return $recommendations
}

function Test-WorkingMemoryCapacity {
    param([int]$ItemCount)

    # Test if exceeding working memory capacity

    $capacity = $global:CognitiveLoadState.WorkingMemory.Capacity
    $chunksNeeded = [Math]::Ceiling($ItemCount / 3.0)

    $result = @{
        Items = $ItemCount
        ChunksNeeded = $chunksNeeded
        Capacity = $capacity
        Overloaded = $chunksNeeded -gt $capacity
        Recommendation = ""
    }

    if ($result.Overloaded) {
        $excess = $chunksNeeded - $capacity
        $result.Recommendation = "Reduce by $excess chunks. Break into smaller groups of 3-4 items max."
    }
    else {
        $available = $capacity - $chunksNeeded
        $result.Recommendation = "Within capacity. $available chunks still available."
    }

    return $result
}

function Measure-SplitAttention {
    param(
        [int]$SourceCount,  # How many places to look
        [string]$Integration # Integrated, Separated
    )

    # Split-attention effect: looking at multiple sources simultaneously

    $splitLoad = 0.0

    if ($Integration -eq "Separated") {
        # Each additional source adds cognitive load
        $splitLoad = ($SourceCount - 1) * 0.2  # 2 sources = 0.2, 3 sources = 0.4, etc.
    }
    else {
        # Integrated: minimal load
        $splitLoad = 0.05
    }

    $reduction = if ($Integration -eq "Integrated") {
        "Split-attention eliminated by integration"
    } else {
        "High split-attention: combine sources into single view"
    }

    return @{
        Sources = $SourceCount
        Integration = $Integration
        SplitLoad = $splitLoad
        Recommendation = $reduction
    }
}

function Get-OptimalLoadRange {
    # Sweller's sweet spot: not too easy, not overwhelming

    $current = $global:CognitiveLoadState.CurrentLoad.Total
    $optimal = $global:CognitiveLoadState.Stats.OptimalLoadRange

    $status = if ($current -lt $optimal[0]) {
        "TOO EASY - increase germane load (deeper processing)"
    }
    elseif ($current -gt $optimal[1]) {
        "OVERLOAD - reduce extraneous load or chunk material"
    }
    else {
        "OPTIMAL - in sweet spot for learning"
    }

    return @{
        CurrentLoad = $current
        OptimalRange = $optimal
        Status = $status
        InOptimalZone = ($current -ge $optimal[0] -and $current -le $optimal[1])
    }
}

# ============================================================================
# ACTION HANDLERS
# ============================================================================

switch ($Action) {
    'Status' {
        Initialize-State

        Write-Host "`n=== COGNITIVE LOAD MANAGEMENT STATUS ==="
        Write-Host "Improvement #42 - Sweller (1988)"
        Write-Host ""

        Write-Host "Current Load:"
        Write-Host "  Intrinsic: $([Math]::Round($global:CognitiveLoadState.CurrentLoad.Intrinsic * 100))%"
        Write-Host "  Extraneous: $([Math]::Round($global:CognitiveLoadState.CurrentLoad.Extraneous * 100))%"
        Write-Host "  Germane: $([Math]::Round($global:CognitiveLoadState.CurrentLoad.Germane * 100))%"
        Write-Host "  TOTAL: $([Math]::Round($global:CognitiveLoadState.CurrentLoad.Total * 100))%"
        Write-Host ""

        Write-Host "Working Memory:"
        Write-Host "  Capacity: $($global:CognitiveLoadState.WorkingMemory.Capacity) chunks"
        Write-Host "  Current Usage: $($global:CognitiveLoadState.WorkingMemory.CurrentUsage) chunks"
        Write-Host "  Overload Events: $($global:CognitiveLoadState.WorkingMemory.Overload)"
        Write-Host ""

        Write-Host "Optimizations Applied:"
        Write-Host "  Chunking: $($global:CognitiveLoadState.Optimizations.ChunkingApplied)"
        Write-Host "  Redundancy Removed: $($global:CognitiveLoadState.Optimizations.RedundancyRemoved)"
        Write-Host "  Split-Attention Fixed: $($global:CognitiveLoadState.Optimizations.SplitAttentionFixed)"
        Write-Host "  Worked Examples Used: $($global:CognitiveLoadState.Optimizations.WorkedExamplesUsed)"
        Write-Host ""

        $range = Get-OptimalLoadRange
        Write-Host "Load Status: $($range.Status)"
        Write-Host "Optimal Range: $($range.OptimalRange[0]*100)%-$($range.OptimalRange[1]*100)%"
        Write-Host ""

        Write-Host "System: ACTIVE"
        Write-Host "Last Update: $($global:CognitiveLoadState.Stats.LastUpdate)"
    }

    'Measure' {
        Initialize-State
        $result = Measure-CognitiveLoad -Task "Test" -ElementCount 8 -Presentation "Clear" -Complexity "Moderate"
        $result | ConvertTo-Json -Depth 5
    }

    'Optimize' {
        Initialize-State
        $result = Optimize-CognitiveLoad -Problem "too many concepts at once"
        $result | ConvertTo-Json -Depth 5
    }

    'TestCapacity' {
        Initialize-State
        $result = Test-WorkingMemoryCapacity -ItemCount 15
        $result | ConvertTo-Json -Depth 5
    }

    'CheckSplitAttention' {
        Initialize-State
        $result = Measure-SplitAttention -SourceCount 3 -Integration "Separated"
        $result | ConvertTo-Json -Depth 5
    }

    'CheckRange' {
        Initialize-State
        $result = Get-OptimalLoadRange
        $result | ConvertTo-Json -Depth 5
    }

    default {
        Write-Host "Cognitive Load Management - Improvement #42"
        Write-Host "Actions: Status, Measure, Optimize, TestCapacity, CheckSplitAttention, CheckRange"
    }
}

