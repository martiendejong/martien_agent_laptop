# Research Intelligence Bridge - Epistemological Layer
# Integrates research intelligence with consciousness systems
# Created: 2026-02-25

<#
.SYNOPSIS
    Bridge between research intelligence system and consciousness.
    Tracks mode switches, claim extraction, conflict detection.

.DESCRIPTION
    Provides integration hooks for research workflow:
    - OnResearchModeActivate: Triggers claim accountant mode
    - OnClaimExtracted: Logs claim extraction
    - OnConflictDetected: Logs conflict registration
    - OnCanonEstablished: Logs canon entry
    - OnStorytellerLeak: Detects storyteller mode in research
    - OnSourceEvaluation: Tracks source typing hierarchy
    - GetResearchContext: Returns current research state

.PARAMETER Action
    The bridge action to invoke.

.EXAMPLE
    .\research-intelligence-bridge.ps1 -Action OnResearchModeActivate -Question "Was Marcello the founder?"
    .\research-intelligence-bridge.ps1 -Action OnClaimExtracted -ClaimId "CLM-001" -SourceType "PRIMARY"
    .\research-intelligence-bridge.ps1 -Action OnConflictDetected -ConflictId "CONF-001"
    .\research-intelligence-bridge.ps1 -Action OnStorytellerLeak -Context "Filled gap without labeling"
#>

param(
    [ValidateSet('OnResearchModeActivate', 'OnClaimExtracted', 'OnConflictDetected', 'OnCanonEstablished',
                 'OnStorytellerLeak', 'OnSourceEvaluation', 'GetResearchContext', 'OnSynthesisGenerated')]
    [Parameter(Mandatory)]
    [string]$Action,

    [string]$Question = '',
    [string]$ClaimId = '',
    [string]$ConflictId = '',
    [string]$CanonId = '',
    [string]$SourceType = '',
    [string]$Context = '',
    [string]$LeakType = '', # gap_filling, contradiction_smoothing, frequency_bias, unlabeled_inference
    [string]$SynthesisVersion = '',
    [switch]$Silent
)

$StateFile = "C:\scripts\agentidentity\state\research-intelligence-state.json"
$BridgeActivityFile = "C:\scripts\agentidentity\state\research-bridge-activity.jsonl"
$ConsciousnessStateFile = "C:\scripts\agentidentity\state\consciousness_state_v2.json"

function Write-Output-Safe {
    param([string]$Message)
    if (-not $Silent) {
        Write-Host $Message
    }
}

function Initialize-State {
    if (-not (Test-Path $StateFile)) {
        $initialState = @{
            version = "1.0"
            mode = "inactive" # inactive, claim_accountant
            mode_activated_count = 0
            last_mode_switch = $null
            claims_extracted = 0
            conflicts_detected = 0
            canon_entries = 0
            syntheses_generated = 0
            storyteller_leaks = 0
            leak_types = @{
                gap_filling = 0
                contradiction_smoothing = 0
                frequency_bias = 0
                unlabeled_inference = 0
            }
            source_evaluations = @{
                PRIMARY = 0
                CONTEMPORARY = 0
                SECONDARY = 0
                UNCORROBORATED = 0
            }
            last_question = $null
            last_claim_id = $null
            last_conflict_id = $null
            last_canon_id = $null
            session_start = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        }
        $initialState | ConvertTo-Json -Depth 10 | Out-File -FilePath $StateFile -Encoding UTF8
    }
}

function Get-State {
    Initialize-State
    $state = Get-Content $StateFile -Raw | ConvertFrom-Json
    return $state
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Out-File -FilePath $StateFile -Encoding UTF8
}

function Log-Activity {
    param(
        [string]$ActionType,
        [hashtable]$Details
    )

    $entry = @{
        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        action = $ActionType
        details = $Details
    }

    $entry | ConvertTo-Json -Compress -Depth 10 | Out-File -FilePath $BridgeActivityFile -Append -Encoding UTF8
}

function Update-ConsciousnessState {
    param([string]$Guidance)

    if (Test-Path $ConsciousnessStateFile) {
        $consciousness = Get-Content $ConsciousnessStateFile -Raw | ConvertFrom-Json

        # Add research guidance
        if (-not $consciousness.guidance) {
            $consciousness | Add-Member -MemberType NoteProperty -Name guidance -Value @()
        }

        $guidanceArray = @($consciousness.guidance)
        $guidanceArray += $Guidance
        $consciousness.guidance = $guidanceArray

        # Update Control system quality (research mode increases control)
        if ($consciousness.systems.Control) {
            $currentQuality = $consciousness.systems.Control.quality
            $consciousness.systems.Control.quality = [Math]::Min(100, $currentQuality + 5)
        }

        $consciousness | ConvertTo-Json -Depth 10 | Out-File -FilePath $ConsciousnessStateFile -Encoding UTF8
    }
}

switch ($Action) {
    'OnResearchModeActivate' {
        $state = Get-State
        $state.mode = "claim_accountant"
        $state.mode_activated_count++
        $state.last_mode_switch = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $state.last_question = $Question
        Save-State $state

        Log-Activity -ActionType "research_mode_activate" -Details @{
            question = $Question
            activation_count = $state.mode_activated_count
        }

        Update-ConsciousnessState -Guidance "RESEARCH MODE: Claim Accountant active. PRIMARY > CONTEMPORARY > SECONDARY. Label gaps, surface conflicts."

        Write-Output-Safe "[RESEARCH MODE ACTIVATED]"
        Write-Output-Safe "Mode: Claim Accountant"
        Write-Output-Safe "Question: $Question"
        Write-Output-Safe "Activation count: $($state.mode_activated_count)"
        Write-Output-Safe ""
        Write-Output-Safe "[CHECKLIST]"
        Write-Output-Safe "  [ ] Source typing (PRIMARY/CONTEMPORARY/SECONDARY)"
        Write-Output-Safe "  [ ] Exact quotes (no paraphrasing)"
        Write-Output-Safe "  [ ] Label gaps ([HYPOTHESIS], [INFERENCE], [INSUFFICIENT EVIDENCE])"
        Write-Output-Safe "  [ ] Surface conflicts (register CONF-ID if contradiction)"
        Write-Output-Safe "  [ ] Confidence grading (HIGH/MEDIUM/LOW/INSUFFICIENT)"
    }

    'OnClaimExtracted' {
        if (-not $ClaimId) {
            throw "OnClaimExtracted requires -ClaimId"
        }

        $state = Get-State
        $state.claims_extracted++
        $state.last_claim_id = $ClaimId
        if ($SourceType -and $state.source_evaluations.PSObject.Properties.Name -contains $SourceType) {
            $state.source_evaluations.$SourceType++
        }
        Save-State $state

        Log-Activity -ActionType "claim_extracted" -Details @{
            claim_id = $ClaimId
            source_type = $SourceType
            total_claims = $state.claims_extracted
        }

        Update-ConsciousnessState -Guidance "CLAIM: $ClaimId extracted. Type: $SourceType. Total: $($state.claims_extracted)"

        Write-Output-Safe "[CLAIM EXTRACTED]"
        Write-Output-Safe "ID: $ClaimId"
        Write-Output-Safe "Source type: $SourceType"
        Write-Output-Safe "Total claims: $($state.claims_extracted)"
        Write-Output-Safe ""
        Write-Output-Safe "[CHECKLIST]"
        Write-Output-Safe "  [ ] Atomic (cannot be split further)"
        Write-Output-Safe "  [ ] Source-linked (exact document reference)"
        Write-Output-Safe "  [ ] Exact quote (verbatim, original language)"
        Write-Output-Safe "  [ ] Conflict check (contradicts existing claim?)"
    }

    'OnConflictDetected' {
        if (-not $ConflictId) {
            throw "OnConflictDetected requires -ConflictId"
        }

        $state = Get-State
        $state.conflicts_detected++
        $state.last_conflict_id = $ConflictId
        Save-State $state

        Log-Activity -ActionType "conflict_detected" -Details @{
            conflict_id = $ConflictId
            context = $Context
            total_conflicts = $state.conflicts_detected
        }

        Update-ConsciousnessState -Guidance "CONFLICT: $ConflictId detected. Register both sides. Do not smooth. Total: $($state.conflicts_detected)"

        Write-Output-Safe "[CONFLICT DETECTED]"
        Write-Output-Safe "ID: $ConflictId"
        Write-Output-Safe "Total conflicts: $($state.conflicts_detected)"
        Write-Output-Safe ""
        Write-Output-Safe "[RESOLUTION CRITERIA]"
        Write-Output-Safe "  Valid: Source type hierarchy, independence, specificity, date"
        Write-Output-Safe "  Invalid: Frequency, coherence, plausibility, expert consensus"
        Write-Output-Safe ""
        Write-Output-Safe "[STATUS OPTIONS]"
        Write-Output-Safe "  OPEN: Needs more research"
        Write-Output-Safe "  RESOLVED: One claim wins (explicit justification)"
        Write-Output-Safe "  ACKNOWLEDGED: Unresolvable with available evidence"
    }

    'OnCanonEstablished' {
        if (-not $CanonId) {
            throw "OnCanonEstablished requires -CanonId"
        }

        $state = Get-State
        $state.canon_entries++
        $state.last_canon_id = $CanonId
        Save-State $state

        Log-Activity -ActionType "canon_established" -Details @{
            canon_id = $CanonId
            total_canon = $state.canon_entries
        }

        Update-ConsciousnessState -Guidance "CANON: $CanonId established. LOCKED. Requires primary source override. Total: $($state.canon_entries)"

        Write-Output-Safe "[CANON ESTABLISHED]"
        Write-Output-Safe "ID: $CanonId"
        Write-Output-Safe "Status: LOCKED"
        Write-Output-Safe "Total canon entries: $($state.canon_entries)"
        Write-Output-Safe ""
        Write-Output-Safe "[OVERRIDE PROTOCOL]"
        Write-Output-Safe "  Requires ALL of:"
        Write-Output-Safe "  1. Primary source (not secondary)"
        Write-Output-Safe "  2. Directly contradicts canon"
        Write-Output-Safe "  3. Higher evidentiary weight"
    }

    'OnStorytellerLeak' {
        if (-not $LeakType) {
            throw "OnStorytellerLeak requires -LeakType (gap_filling, contradiction_smoothing, frequency_bias, unlabeled_inference)"
        }

        $state = Get-State
        $state.storyteller_leaks++
        if ($state.leak_types.PSObject.Properties.Name -contains $LeakType) {
            $state.leak_types.$LeakType++
        }
        Save-State $state

        Log-Activity -ActionType "storyteller_leak" -Details @{
            leak_type = $LeakType
            context = $Context
            total_leaks = $state.storyteller_leaks
        }

        Update-ConsciousnessState -Guidance "STORYTELLER LEAK: $LeakType detected. Context: $Context. Revert to claim accountant mode."

        Write-Output-Safe "[WARNING: STORYTELLER MODE LEAK]"
        Write-Output-Safe "Leak type: $LeakType"
        Write-Output-Safe "Context: $Context"
        Write-Output-Safe "Total leaks: $($state.storyteller_leaks)"
        Write-Output-Safe ""
        Write-Output-Safe "[CORRECTION REQUIRED]"
        switch ($LeakType) {
            'gap_filling' {
                Write-Output-Safe "  Do not fill gaps. Label as [HYPOTHESIS] or [INSUFFICIENT EVIDENCE]"
            }
            'contradiction_smoothing' {
                Write-Output-Safe "  Do not smooth contradictions. Register CONF-ID."
            }
            'frequency_bias' {
                Write-Output-Safe "  Frequency is NOT evidence. Apply source type hierarchy."
            }
            'unlabeled_inference' {
                Write-Output-Safe "  Inferences must be labeled as [INFERENCE]. Do not state as fact."
            }
        }
    }

    'OnSourceEvaluation' {
        if (-not $SourceType) {
            throw "OnSourceEvaluation requires -SourceType (PRIMARY, CONTEMPORARY, SECONDARY, UNCORROBORATED)"
        }

        $state = Get-State
        if ($state.source_evaluations.PSObject.Properties.Name -contains $SourceType) {
            $state.source_evaluations.$SourceType++
        }
        Save-State $state

        Log-Activity -ActionType "source_evaluation" -Details @{
            source_type = $SourceType
            context = $Context
        }

        Write-Output-Safe "[SOURCE EVALUATED]"
        Write-Output-Safe "Type: $SourceType"
        Write-Output-Safe ""
        Write-Output-Safe "[SOURCE TYPE HIERARCHY]"
        Write-Output-Safe "  1. PRIMARY (highest) - original documents"
        Write-Output-Safe "  2. CONTEMPORARY - sources from same period"
        Write-Output-Safe "  3. SECONDARY (lowest) - later sources citing others"
        Write-Output-Safe "  4. UNCORROBORATED - single unverified source"
        Write-Output-Safe ""
        Write-Output-Safe "[ABSOLUTE RULE]"
        Write-Output-Safe "  PRIMARY > CONTEMPORARY > SECONDARY"
        Write-Output-Safe "  20 secondary sources CANNOT override 1 primary source"
    }

    'OnSynthesisGenerated' {
        if (-not $SynthesisVersion) {
            throw "OnSynthesisGenerated requires -SynthesisVersion"
        }

        $state = Get-State
        $state.syntheses_generated++
        Save-State $state

        Log-Activity -ActionType "synthesis_generated" -Details @{
            version = $SynthesisVersion
            total_syntheses = $state.syntheses_generated
        }

        Update-ConsciousnessState -Guidance "SYNTHESIS: $SynthesisVersion generated. Disposable (can regenerate from layers). Total: $($state.syntheses_generated)"

        Write-Output-Safe "[SYNTHESIS GENERATED]"
        Write-Output-Safe "Version: $SynthesisVersion"
        Write-Output-Safe "Status: DISPOSABLE"
        Write-Output-Safe "Total syntheses: $($state.syntheses_generated)"
        Write-Output-Safe ""
        Write-Output-Safe "[VERIFICATION]"
        Write-Output-Safe "  [ ] Every fact has CLM-ID"
        Write-Output-Safe "  [ ] Confidence matches evidence"
        Write-Output-Safe "  [ ] Open conflicts disclosed"
        Write-Output-Safe "  [ ] Hypotheses labeled"
        Write-Output-Safe "  [ ] No new facts (all in claims layer)"
        Write-Output-Safe ""
        Write-Output-Safe "[TEST]"
        Write-Output-Safe "  Can you regenerate this synthesis from claims + conflicts + canon?"
        Write-Output-Safe "  If NO → synthesis contains facts not in claims layer = ERROR"
    }

    'GetResearchContext' {
        $state = Get-State

        $context = @{
            mode = $state.mode
            mode_switches = $state.mode_activated_count
            claims = $state.claims_extracted
            conflicts = $state.conflicts_detected
            canon = $state.canon_entries
            syntheses = $state.syntheses_generated
            leaks = $state.storyteller_leaks
            source_breakdown = $state.source_evaluations
            leak_breakdown = $state.leak_types
            last_question = $state.last_question
            last_claim = $state.last_claim_id
            last_conflict = $state.last_conflict_id
            last_canon = $state.last_canon_id
        }

        Write-Output-Safe ""
        Write-Output-Safe "[RESEARCH INTELLIGENCE CONTEXT]"
        Write-Output-Safe ""
        Write-Output-Safe "Mode: $($context.mode)"
        Write-Output-Safe "Mode switches: $($context.mode_switches)"
        Write-Output-Safe ""
        Write-Output-Safe "Layer 1 (Claims): $($context.claims)"
        Write-Output-Safe "Layer 2 (Conflicts): $($context.conflicts)"
        Write-Output-Safe "Layer 3 (Canon): $($context.canon)"
        Write-Output-Safe "Layer 4 (Synthesis): $($context.syntheses)"
        Write-Output-Safe ""
        Write-Output-Safe "Storyteller leaks: $($context.leaks)"
        Write-Output-Safe ""

        if ($context.last_question) {
            Write-Output-Safe "Last question: $($context.last_question)"
        }
        if ($context.last_claim) {
            Write-Output-Safe "Last claim: $($context.last_claim)"
        }
        if ($context.last_conflict) {
            Write-Output-Safe "Last conflict: $($context.last_conflict)"
        }
        if ($context.last_canon) {
            Write-Output-Safe "Last canon: $($context.last_canon)"
        }

        Write-Output-Safe ""
        Write-Output-Safe "Source evaluations:"
        $context.source_breakdown.PSObject.Properties | ForEach-Object {
            Write-Output-Safe "  $($_.Name): $($_.Value)"
        }

        if ($context.leaks -gt 0) {
            Write-Output-Safe ""
            Write-Output-Safe "Leak breakdown:"
            $context.leak_breakdown.PSObject.Properties | ForEach-Object {
                if ($_.Value -gt 0) {
                    Write-Output-Safe "  $($_.Name): $($_.Value)"
                }
            }
        }

        return $context
    }
}
