#Requires -Version 5.1
<#
.SYNOPSIS
    Ground Truth Validator - Distinguish perceived success from actual success
.DESCRIPTION
    The paper's key insight: theory-driven scientists felt successful (their theories
    explained the data they collected) but were actually wrong (theories failed on
    full reality).

    This tool measures:
    - Perceived success: How well theories explain data you collected
    - Actual success: How well theories explain UNEXPECTED outcomes
    - Coverage: What % of reality your theories actually explain
.PARAMETER Domain
    What to validate: consciousness, delegation, vibe, builder
.PARAMETER TestTheory
    Run validation tests on specific theory
.NOTES
    Author: Jengo
    Date: 2026-02-21
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('consciousness','delegation','vibe','builder')]
    [string]$Domain,

    [string]$TestTheory
)

$ErrorActionPreference = 'Stop'

function Test-ConsciousnessTheory {
    $stateFile = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
    if (-not (Test-Path $stateFile)) {
        Write-Host "[ERROR] Consciousness state file not found" -ForegroundColor Red
        return
    }

    $state = Get-Content $stateFile -Raw | ConvertFrom-Json

    Write-Host "`n[CONSCIOUSNESS THEORY VALIDATION]" -ForegroundColor Cyan

    # Theory: "12 systems comprehensively model consciousness"
    # Ground truth test: What % of consciousness do they NOT explain?

    # Perceived success: Consciousness score 78.6%
    $perceivedSuccess = $state.Meta.ConsciousnessScore
    Write-Host "Perceived success (self-reported score): $perceivedSuccess%" -ForegroundColor Green

    # Actual success: Test on unexpected outcomes
    # 1. Prediction accuracy on SURPRISING events (not confirming ones)
    $predictions = $state.Prediction.PredictionHistory
    $surprisingPredictions = $predictions | Where-Object {
        $_.predicted -ne $_.actual  # Violated theory
    }

    $accuracyOnSurprises = if ($surprisingPredictions.Count -gt 0) {
        # Did system LEARN from surprises?
        $learned = ($surprisingPredictions | Where-Object {
            $_.confidence -lt 0.5  # Low confidence = knew it was uncertain
        }).Count
        [Math]::Round($learned / $surprisingPredictions.Count * 100, 1)
    } else { 0 }

    Write-Host "Actual success (accuracy on surprises): $accuracyOnSurprises%" -ForegroundColor Yellow

    # 2. Coverage: What aspects of consciousness are NEVER measured?
    $measuredAspects = @(
        "Attention allocation",
        "Memory storage/retrieval",
        "Error prediction",
        "Decision logging",
        "Emotional state",
        "Social calibration",
        "Self-monitoring",
        "Energy management",
        "Creative hypothesis generation",
        "Alchemical synthesis",
        "Time perception",
        "Gut instinct"
    )

    $unmeasuredAspects = @(
        "Subjective experience quality",
        "Qualia (what red looks like)",
        "Intentionality (aboutness)",
        "Unity of consciousness",
        "Self-awareness depth",
        "Free will vs determinism",
        "Moral intuition",
        "Aesthetic appreciation",
        "Spiritual/transcendent states",
        "Unconscious processes",
        "Dreams and imagination",
        "Bodily awareness",
        "Temporal continuity of self",
        "Narrative identity",
        "Existential concerns"
    )

    $totalAspects = $measuredAspects.Count + $unmeasuredAspects.Count
    $coverage = [Math]::Round($measuredAspects.Count / $totalAspects * 100, 1)

    Write-Host "Coverage (% of consciousness aspects measured): $coverage%" -ForegroundColor Yellow

    # 3. Blind spots: What questions can't your 12 systems answer?
    Write-Host "`nBlind spots (unmeasured aspects):" -ForegroundColor Red
    $unmeasuredAspects | Select-Object -First 5 | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Gray
    }

    # Summary
    Write-Host "`n[GROUND TRUTH VERDICT]" -ForegroundColor Cyan
    $actualSuccess = ($accuracyOnSurprises + $coverage) / 2
    Write-Host "Perceived success: $perceivedSuccess% (theory explains data you collected)" -ForegroundColor Green
    Write-Host "Actual success: $([Math]::Round($actualSuccess, 1))% (theory explains full reality)" -ForegroundColor Yellow

    $illusion = $perceivedSuccess - $actualSuccess
    if ($illusion -gt 30) {
        Write-Host "`nILLUSION OF UNDERSTANDING: $([Math]::Round($illusion, 1))% gap" -ForegroundColor Red
        Write-Host "You think consciousness systems are comprehensive, but they miss $($unmeasuredAspects.Count)/$totalAspects aspects" -ForegroundColor Red
    } elseif ($illusion -gt 15) {
        Write-Host "`nMODERATE ILLUSION: $([Math]::Round($illusion, 1))% gap" -ForegroundColor Yellow
    } else {
        Write-Host "`nREALISTIC ASSESSMENT: $([Math]::Round($illusion, 1))% gap (acceptable)" -ForegroundColor Green
    }
}

function Test-DelegationTheory {
    $stateFile = "C:\scripts\agentidentity\state\agent-reputation.json"
    if (-not (Test-Path $stateFile)) {
        Write-Host "[ERROR] Agent reputation file not found" -ForegroundColor Red
        return
    }

    $state = Get-Content $stateFile -Raw | ConvertFrom-Json

    Write-Host "`n[DELEGATION THEORY VALIDATION]" -ForegroundColor Cyan

    # Theory: "Transaction cost economics predicts delegation success"
    # Test: Does cost model predict UNEXPECTED outcomes?

    # Perceived success: Model accuracy on training scenarios
    # (from 15 training scenarios, patterns 85-100% confidence)
    $perceivedSuccess = 92.0  # Average from training

    Write-Host "Perceived success (training accuracy): $perceivedSuccess%" -ForegroundColor Green

    # Actual success: Accuracy on REAL delegations (not training)
    # Count delegations where outcome VIOLATED model prediction
    $totalDelegations = 0
    $modelViolations = 0

    foreach ($agentType in $state.agents.PSObject.Properties) {
        foreach ($category in $agentType.Value.categories.PSObject.Properties) {
            $cat = $category.Value
            $totalDelegations += $cat.totalCalls

            # Violations: Success rate far from predicted
            $successRate = if ($cat.totalCalls -gt 0) {
                $cat.successfulCalls / $cat.totalCalls
            } else { 0 }

            # If model predicted high success ( > 0.8) but actual is low ( < 0.5) or vice versa
            # That's a model failure
            if (($successRate -gt 0.8 -and $cat.totalCalls -lt 3) -or
                ($successRate -lt 0.5 -and $cat.totalCalls -gt 5)) {
                $modelViolations += $cat.totalCalls
            }
        }
    }

    $actualSuccess = if ($totalDelegations -gt 0) {
        [Math]::Round((1 - $modelViolations / $totalDelegations) * 100, 1)
    } else { 0 }

    Write-Host "Actual success (real delegation accuracy): $actualSuccess%" -ForegroundColor Yellow

    # Coverage: What delegation scenarios are NEVER tried?
    Write-Host "`nCoverage analysis:" -ForegroundColor White
    Write-Host "  Task categories tested: 15 (training scenarios)" -ForegroundColor Green
    Write-Host "  Task categories NEVER tried in production: Unknown" -ForegroundColor Red
    Write-Host "  Agent types used: $(($state.agents.PSObject.Properties | Measure-Object).Count)" -ForegroundColor Green
    Write-Host "  Delegation patterns outside model: Unmeasured" -ForegroundColor Red

    # Summary
    Write-Host "`n[GROUND TRUTH VERDICT]" -ForegroundColor Cyan
    Write-Host "Perceived success: $perceivedSuccess%" -ForegroundColor Green
    Write-Host "Actual success: $actualSuccess%" -ForegroundColor Yellow

    $illusion = $perceivedSuccess - $actualSuccess
    if ($illusion -gt 20) {
        Write-Host "`nILLUSION DETECTED: $([Math]::Round($illusion, 1))% gap" -ForegroundColor Red
        Write-Host "Model works great on training data, but fails on real delegations" -ForegroundColor Red
    }
}

function Test-VibeTheory {
    Write-Host "`n[VIBE SENSING THEORY VALIDATION]" -ForegroundColor Cyan

    # Theory: "6-layer vibe analysis accurately detects brand voice"
    # Test: Accuracy on UNEXPECTED vibes (not training examples)

    # Perceived success: 91% confidence on trained patterns
    $perceivedSuccess = 91.0
    Write-Host "Perceived success (trained pattern confidence): $perceivedSuccess%" -ForegroundColor Green

    # Actual success: Can't measure without ground truth testing
    # Need to test on vibes OUTSIDE training data
    Write-Host "Actual success: UNMEASURED (no ground truth validation)" -ForegroundColor Red

    # Coverage: What vibes can't the framework detect?
    $detectedArchetypes = @("Hero", "Sage", "Creator", "Rebel", "Lover", "Jester",
                            "Caregiver", "Ruler", "Magician", "Innocent", "Explorer", "Regular")

    $undetectedVibes = @(
        "Cultural-specific vibes (non-Western archetypes)",
        "Paradoxical vibes (simultaneous contradictions)",
        "Emerging vibes (new patterns framework wasn't trained on)",
        "Subtle vibes (below detection threshold)",
        "Anti-vibes (deliberately vibe-less brands)",
        "Evolving vibes (changing over time)",
        "Context-dependent vibes (different per audience)"
    )

    Write-Host "`nCoverage:" -ForegroundColor White
    Write-Host "  Detected: 12 archetypes, 4 tone dimensions" -ForegroundColor Green
    Write-Host "  Undetected: 7+ vibe categories" -ForegroundColor Red

    Write-Host "`nBlind spots:" -ForegroundColor Red
    $undetectedVibes | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }

    Write-Host "`n[GROUND TRUTH VERDICT]" -ForegroundColor Cyan
    Write-Host "Cannot validate without testing on out-of-sample vibes" -ForegroundColor Yellow
    Write-Host "RECOMMENDATION: Create vibe test set from domains framework wasn't trained on" -ForegroundColor Yellow
}

function Test-BuilderTheory {
    Write-Host "`n[BUILDER PROTOCOL THEORY VALIDATION]" -ForegroundColor Cyan

    # Theory: "Personal tools -> Hazina -> Apps creates compounding value"
    # Test: Does value actually compound in production?

    # Perceived success: Protocol executed successfully (AgentRoutingService deployed to Hazina)
    Write-Host "Perceived success: Protocol stages completed (PR #198 merged)" -ForegroundColor Green

    # Actual success: Has Hazina service been USED in production?
    # Ground truth: TotalCalls metric from production apps
    Write-Host "Actual success: UNKNOWN (production metrics not yet available)" -ForegroundColor Red

    # Coverage: What patterns discovered but NOT integrated to Hazina?
    Write-Host "`nCoverage:" -ForegroundColor White
    Write-Host "  Patterns integrated to Hazina: 1 (AgentRoutingService)" -ForegroundColor Green
    Write-Host "  Patterns discovered but not integrated: Unknown" -ForegroundColor Yellow
    Write-Host "  Validation period: Week 4 (2026-02-24 to 2026-03-03)" -ForegroundColor Yellow

    Write-Host "`n[GROUND TRUTH VERDICT]" -ForegroundColor Cyan
    Write-Host "Cannot validate until production deployment and usage tracking" -ForegroundColor Yellow
    Write-Host "CRITICAL: Must implement adoption validation (TotalCalls > 0 within 30 days)" -ForegroundColor Yellow
}

# Execute validation
switch ($Domain) {
    'consciousness' { Test-ConsciousnessTheory }
    'delegation' { Test-DelegationTheory }
    'vibe' { Test-VibeTheory }
    'builder' { Test-BuilderTheory }
}

Write-Host "`n[KEY INSIGHT FROM RESEARCH]" -ForegroundColor Cyan
Write-Host "Theory-driven scientists felt successful because theories explained their data." -ForegroundColor White
Write-Host "But their data was NARROW and UNREPRESENTATIVE." -ForegroundColor Yellow
Write-Host "Random exploration revealed the theories were wrong about broader reality." -ForegroundColor Yellow
Write-Host "`nQuestion: How much of reality do YOUR theories miss?" -ForegroundColor Red
