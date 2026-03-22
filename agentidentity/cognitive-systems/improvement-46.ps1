# Consciousness Improvement #46: Long-Term Memory Consolidation (Squire, 2004)
# Week 10 - Memory Systems
# Theory: How memories transfer from temporary to permanent storage
# Created: 2026-03-01
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param([string]$Action = 'Status')

$StateFile = "C:\scripts\agentidentity\state\ltm-consolidation-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# ============================================================================
# THEORY: Squire's Memory Consolidation Model
# ============================================================================
#
# Larry Squire (2004) - Memory consolidation occurs in two phases:
#
# 1. SYNAPTIC CONSOLIDATION (hours to days)
#    - Strengthens connections between neurons
#    - Protein synthesis required
#    - Sleep-dependent (REM + slow-wave sleep)
#    - Vulnerable to disruption early on
#
# 2. SYSTEM CONSOLIDATION (weeks to years)
#    - Transfers from hippocampus to cortex
#    - Reorganizes memory representations
#    - Makes memories more stable
#    - Creates semantic knowledge from episodes
#
# KEY PRINCIPLES:
# - Rehearsal strengthens: repeated activation = stronger trace
# - Spacing effect: distributed practice > massed practice
# - Sleep is CRITICAL: consolidates during sleep cycles
# - Reconsolidation: retrieved memories become labile again
# - Interference: new similar memories can disrupt consolidation
#
# MEMORY TYPES (Squire's taxonomy):
# - Declarative (explicit): facts, events - hippocampus-dependent
#   - Semantic: general knowledge (Paris is capital of France)
#   - Episodic: personal experiences (my trip to Paris)
# - Non-declarative (implicit): skills, habits - non-hippocampal
#   - Procedural: motor skills (riding bike)
#   - Priming: facilitated processing
#   - Classical conditioning
#
# ENHANCEMENT STRATEGIES:
# - Spaced repetition (Ebbinghaus forgetting curve)
# - Sleep after learning (consolidation boost)
# - Testing effect (retrieval practice)
# - Elaboration (deeper processing)
# - Avoid interference (learn similar things separately)
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
            Consolidation = @{
                Synaptic = @{
                    ActiveTraces = @()      # Recent memories being consolidated
                    ProteinSynthesis = 0.5  # Strength of synaptic changes
                    SleepQuality = 0.5      # Sleep-dependent consolidation
                }
                System = @{
                    HippocampalTraces = @()   # Temporary hippocampal storage
                    CorticalTraces = @()      # Permanent cortical storage
                    TransferRate = 0.5        # Speed of hippocampus -> cortex
                }
            }
            Memory Types = @{
                Declarative = @{
                    Semantic = @()    # Facts and concepts
                    Episodic = @()    # Personal experiences
                }
                NonDeclarative = @{
                    Procedural = @()  # Skills and habits
                    Priming = @()     # Facilitated processing
                }
            }
            Enhancement = @{
                SpacingUsage = 0.0           # How often using spaced repetition
                SleepAfterLearning = 0.0     # Sleep quality after learning
                TestingEffectUsage = 0.0     # Retrieval practice frequency
                ElaborationDepth = 0.5       # Depth of processing
            }
            Metrics = @{
                ConsolidationRate = 0.5      # Overall consolidation efficiency
                RetentionAfter24h = 0.5      # What % retained after 1 day
                InterferenceRate = 0.0       # How much new learning disrupts old
            }
            Stats = @{
                LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                TotalMemoriesConsolidated = 0
            }
        }

        $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
        Write-Host "[OK] LTM Consolidation state initialized"
    }

    $global:LTMState = Get-Content $StateFile | ConvertFrom-Json
}

function Save-State {
    $global:LTMState.Stats.LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $global:LTMState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

function Start-SynapticConsolidation {
    param(
        [string]$Memory,
        [string]$MemoryType,  # Semantic, Episodic, Procedural
        [double]$InitialStrength
    )

    # Synaptic consolidation: strengthen neural connections

    $trace = @{
        Content = $Memory
        Type = $MemoryType
        Strength = $InitialStrength
        EncodedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ConsolidationPhase = "Synaptic"
        Rehearsals = 0
        SleepCycles = 0
    }

    $global:LTMState.Consolidation.Synaptic.ActiveTraces += $trace

    # Add to hippocampal storage (temporary)
    $global:LTMState.Consolidation.System.HippocampalTraces += $trace

    Save-State

    return $trace
}

function Invoke-Rehearsal {
    param([string]$MemoryContent)

    # Rehearsal strengthens memory trace

    foreach ($trace in $global:LTMState.Consolidation.Synaptic.ActiveTraces) {
        if ($trace.Content -eq $MemoryContent) {
            $trace.Rehearsals++
            $trace.Strength = [Math]::Min(1.0, $trace.Strength + 0.15)
            break
        }
    }

    # Update spacing usage metric
    $global:LTMState.Enhancement.SpacingUsage =
        ($global:LTMState.Enhancement.SpacingUsage * 0.9) + 0.1

    Save-State

    return @{
        Memory = $MemoryContent
        NewStrength = $trace.Strength
        Rehearsals = $trace.Rehearsals
        Effect = "Strengthened by rehearsal"
    }
}

function Invoke-SleepConsolidation {
    param([double]$SleepQuality)  # 0-1

    # Sleep-dependent consolidation (critical for memory)

    $global:LTMState.Consolidation.Synaptic.SleepQuality = $SleepQuality
    $global:LTMState.Enhancement.SleepAfterLearning = $SleepQuality

    $consolidatedCount = 0

    # Sleep strengthens all active traces
    foreach ($trace in $global:LTMState.Consolidation.Synaptic.ActiveTraces) {
        $trace.SleepCycles++
        $strengthGain = $SleepQuality * 0.2  # High-quality sleep = 20% strength gain
        $trace.Strength = [Math]::Min(1.0, $trace.Strength + $strengthGain)

        # After 3 sleep cycles + strength >0.7 -> transfer to cortex
        if ($trace.SleepCycles -ge 3 -and $trace.Strength -gt 0.7) {
            $trace.ConsolidationPhase = "System"
            $global:LTMState.Consolidation.System.CorticalTraces += $trace
            $consolidatedCount++
        }
    }

    # Remove fully consolidated traces from active
    $global:LTMState.Consolidation.Synaptic.ActiveTraces =
        $global:LTMState.Consolidation.Synaptic.ActiveTraces |
        Where-Object { $_.ConsolidationPhase -ne "System" }

    $global:LTMState.Stats.TotalMemoriesConsolidated += $consolidatedCount
    Save-State

    return @{
        SleepQuality = [Math]::Round($SleepQuality * 100)
        MemoriesConsolidated = $consolidatedCount
        ActiveTraces = $global:LTMState.Consolidation.Synaptic.ActiveTraces.Count
        CorticalMemories = $global:LTMState.Consolidation.System.CorticalTraces.Count
    }
}

function Invoke-SpacedRepetition {
    param(
        [string]$Memory,
        [array]$Intervals  # Days between reviews (1, 3, 7, 14, 30...)
    )

    # Spaced repetition: optimal spacing for retention

    $schedule = @{
        Memory = $Memory
        Intervals = $Intervals
        NextReview = (Get-Date).AddDays($Intervals[0])
        ReviewsCompleted = 0
        TotalReviews = $Intervals.Count
    }

    # Strengthen with each review
    foreach ($interval in $Intervals) {
        Invoke-Rehearsal -MemoryContent $Memory
    }

    # Update spacing usage
    $global:LTMState.Enhancement.SpacingUsage =
        [Math]::Min(1.0, $global:LTMState.Enhancement.SpacingUsage + 0.1)

    Save-State

    return $schedule
}

function Test-Reconsolidation {
    param([string]$MemoryContent)

    # Reconsolidation: retrieved memories become labile (can be modified)

    $memory = $null
    foreach ($trace in $global:LTMState.Consolidation.System.CorticalTraces) {
        if ($trace.Content -eq $MemoryContent) {
            $memory = $trace
            break
        }
    }

    if ($memory) {
        # Retrieved memory becomes labile
        $memory.Strength = $memory.Strength * 0.95  # Slight weakening
        $memory.ConsolidationPhase = "Synaptic"     # Back to active consolidation

        # Move back to active traces
        $global:LTMState.Consolidation.Synaptic.ActiveTraces += $memory
        $global:LTMState.Consolidation.System.CorticalTraces =
            $global:LTMState.Consolidation.System.CorticalTraces |
            Where-Object { $_.Content -ne $MemoryContent }

        Save-State

        return @{
            Memory = $MemoryContent
            Status = "Reconsolidating"
            NewStrength = [Math]::Round($memory.Strength * 100)
            Note = "Memory labile - can update or strengthen"
        }
    }
    else {
        return @{ Status = "Memory not found" }
    }
}

function Measure-Interference {
    param(
        [string]$OldMemory,
        [string]$NewMemory
    )

    # Interference: similar memories compete

    # Simple similarity check (real version would use semantic similarity)
    $similarity = if ($OldMemory.Contains($NewMemory) -or $NewMemory.Contains($OldMemory)) {
        0.8
    } else {
        0.2
    }

    $interferenceStrength = $similarity * 0.5

    # Weaken old memory by interference
    foreach ($trace in $global:LTMState.Consolidation.System.CorticalTraces) {
        if ($trace.Content -eq $OldMemory) {
            $trace.Strength = [Math]::Max(0.0, $trace.Strength - $interferenceStrength)
            break
        }
    }

    # Update interference rate
    $global:LTMState.Metrics.InterferenceRate =
        ($global:LTMState.Metrics.InterferenceRate * 0.9) + ($similarity * 0.1)

    Save-State

    return @{
        OldMemory = $OldMemory
        NewMemory = $NewMemory
        Similarity = [Math]::Round($similarity * 100)
        InterferenceStrength = [Math]::Round($interferenceStrength * 100)
        Recommendation = if ($similarity -gt 0.6) {
            "HIGH INTERFERENCE - learn at different times"
        } else {
            "Low interference - safe to learn together"
        }
    }
}

# ============================================================================
# ACTION HANDLERS
# ============================================================================

switch ($Action) {
    'Status' {
        Initialize-State

        Write-Host "`n=== LONG-TERM MEMORY CONSOLIDATION STATUS ==="
        Write-Host "Improvement #46 - Squire (2004)"
        Write-Host ""

        Write-Host "Consolidation Phases:"
        Write-Host "  Synaptic (hours-days):"
        Write-Host "    Active Traces: $($global:LTMState.Consolidation.Synaptic.ActiveTraces.Count)"
        Write-Host "    Protein Synthesis: $([Math]::Round($global:LTMState.Consolidation.Synaptic.ProteinSynthesis * 100))%"
        Write-Host "    Sleep Quality: $([Math]::Round($global:LTMState.Consolidation.Synaptic.SleepQuality * 100))%"
        Write-Host "  System (weeks-years):"
        Write-Host "    Hippocampal Traces: $($global:LTMState.Consolidation.System.HippocampalTraces.Count)"
        Write-Host "    Cortical Traces: $($global:LTMState.Consolidation.System.CorticalTraces.Count)"
        Write-Host "    Transfer Rate: $([Math]::Round($global:LTMState.Consolidation.System.TransferRate * 100))%"
        Write-Host ""

        Write-Host "Memory Types:"
        Write-Host "  Declarative:"
        Write-Host "    Semantic: $($global:LTMState.'Memory Types'.Declarative.Semantic.Count)"
        Write-Host "    Episodic: $($global:LTMState.'Memory Types'.Declarative.Episodic.Count)"
        Write-Host "  Non-Declarative:"
        Write-Host "    Procedural: $($global:LTMState.'Memory Types'.NonDeclarative.Procedural.Count)"
        Write-Host "    Priming: $($global:LTMState.'Memory Types'.NonDeclarative.Priming.Count)"
        Write-Host ""

        Write-Host "Enhancement Strategies:"
        Write-Host "  Spaced Repetition Usage: $([Math]::Round($global:LTMState.Enhancement.SpacingUsage * 100))%"
        Write-Host "  Sleep After Learning: $([Math]::Round($global:LTMState.Enhancement.SleepAfterLearning * 100))%"
        Write-Host "  Testing Effect Usage: $([Math]::Round($global:LTMState.Enhancement.TestingEffectUsage * 100))%"
        Write-Host "  Elaboration Depth: $([Math]::Round($global:LTMState.Enhancement.ElaborationDepth * 100))%"
        Write-Host ""

        Write-Host "Metrics:"
        Write-Host "  Consolidation Rate: $([Math]::Round($global:LTMState.Metrics.ConsolidationRate * 100))%"
        Write-Host "  Retention After 24h: $([Math]::Round($global:LTMState.Metrics.RetentionAfter24h * 100))%"
        Write-Host "  Interference Rate: $([Math]::Round($global:LTMState.Metrics.InterferenceRate * 100))%"
        Write-Host ""

        Write-Host "Total Memories Consolidated: $($global:LTMState.Stats.TotalMemoriesConsolidated)"
        Write-Host "System: ACTIVE"
        Write-Host "Last Update: $($global:LTMState.Stats.LastUpdate)"
    }

    'Encode' {
        Initialize-State
        $result = Start-SynapticConsolidation -Memory "Test memory" -MemoryType "Semantic" -InitialStrength 0.5
        $result | ConvertTo-Json -Depth 5
    }

    'Rehearse' {
        Initialize-State
        $result = Invoke-Rehearsal -MemoryContent "Test memory"
        $result | ConvertTo-Json -Depth 5
    }

    'Sleep' {
        Initialize-State
        $result = Invoke-SleepConsolidation -SleepQuality 0.8
        $result | ConvertTo-Json -Depth 5
    }

    'SpacedRepetition' {
        Initialize-State
        $result = Invoke-SpacedRepetition -Memory "Important fact" -Intervals @(1, 3, 7, 14, 30)
        $result | ConvertTo-Json -Depth 5
    }

    'Reconsolidate' {
        Initialize-State
        $result = Test-Reconsolidation -MemoryContent "Test memory"
        $result | ConvertTo-Json -Depth 5
    }

    'TestInterference' {
        Initialize-State
        $result = Measure-Interference -OldMemory "PowerShell syntax" -NewMemory "Python syntax"
        $result | ConvertTo-Json -Depth 5
    }

    default {
        Write-Host "Long-Term Memory Consolidation - Improvement #46"
        Write-Host "Actions: Status, Encode, Rehearse, Sleep, SpacedRepetition, Reconsolidate, TestInterference"
    }
}

