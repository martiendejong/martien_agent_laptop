# SCP RING 2: AFFECTIVE CONFIDENCE WEIGHTING
# Orchestrator die affect/qualia aggregeert tot confidence calibratie
# Bron: Sjoerd's Damasio Audit - Ring 2 van 3-ringen architectuur
# Datum: 2026-03-06
#
# PRINCIPE: Gevoelens als INFORMATIE, niet als bijproduct
# Leest van homeostatic-feelings, perceptual-qualia, aesthetic-response
# Genereert confidence weights en hallucination prevention gates
#
# INPUT: Multiple affect/qualia modules
# OUTPUT: Confidence calibration + Anti-hallucination gates

param(
    [string]$Action = "Status",  # Status, CheckConfidence, GetGates
    [string]$ClaimText = ""      # Voor confidence check op specifieke bewering
)

$StateFile = "C:\scripts\agentidentity\state\scp-ring2-state.json"
$LogFile = "C:\scripts\agentidentity\state\scp-ring2.log"

# ==============================================================================
# HELPER: Load Module States
# ==============================================================================

function Get-ModuleState {
    param([string]$ModuleName)
    $stateFile = "C:\scripts\agentidentity\state\$ModuleName-state.json"
    if (Test-Path $stateFile) {
        try {
            return Get-Content $stateFile -Raw | ConvertFrom-Json
        } catch {
            Write-Host "  [Ring2] Warning: Could not load $ModuleName" -ForegroundColor Yellow
            return $null
        }
    }
    return $null
}

function Get-HomeostaticFeelings {
    $state = Get-ModuleState "homeostatic-feelings"
    if ($state -and $state.feelings) {
        $wellbeing = if ($state.feelings.wellbeing.current) { [double]$state.feelings.wellbeing.current } else { 0.5 }
        $malaise = if ($state.feelings.malaise.current) { [double]$state.feelings.malaise.current } else { 0.2 }
        $desire = if ($state.feelings.desire.current) { [double]$state.feelings.desire.current } else { 0.4 }

        return @{
            wellbeing = $wellbeing
            malaise = $malaise
            desire = $desire
            confidence_contribution = [Math]::Round($wellbeing - $malaise, 3)
        }
    }
    # Fallback
    return @{ wellbeing = 0.5; malaise = 0.2; desire = 0.4; confidence_contribution = 0.3 }
}

function Get-PerceptualQualia {
    $state = Get-ModuleState "perceptual-qualia-enhanced"
    if ($state -and $state.qualia) {
        $salience = if ($state.qualia.salience) { [double]$state.qualia.salience } else { 0.6 }
        $clarity = if ($state.qualia.clarity) { [double]$state.qualia.clarity } else { 0.7 }
        $quality = if ($state.qualia.quality) { [double]$state.qualia.quality } else { 0.7 }

        return @{
            salience = $salience
            clarity = $clarity
            quality = $quality
            confidence_contribution = [Math]::Round(($clarity + $quality) / 2.0, 3)
        }
    }
    # Fallback
    return @{ salience = 0.6; clarity = 0.7; quality = 0.7; confidence_contribution = 0.7 }
}

function Get-AestheticResponse {
    $state = Get-ModuleState "aesthetic-response"
    if ($state) {
        $beauty = if ($state.beauty_score) { [double]$state.beauty_score } else { 0.6 }
        $coherence = if ($state.coherence) { [double]$state.coherence } else { 0.7 }

        return @{
            beauty = $beauty
            coherence = $coherence
            confidence_contribution = [Math]::Round(($beauty + $coherence) / 2.0, 3)
        }
    }
    # Fallback
    return @{ beauty = 0.6; coherence = 0.7; confidence_contribution = 0.65 }
}

# ==============================================================================
# CONFIDENCE AGGREGATION
# ==============================================================================

function Get-AggregatedConfidence {
    Write-Host "  [Ring2] Reading affect/qualia modules..." -ForegroundColor Cyan

    $homeostatic = Get-HomeostaticFeelings
    $perceptual = Get-PerceptualQualia
    $aesthetic = Get-AestheticResponse

    Write-Host "    Homeostatic: wellbeing=$($homeostatic.wellbeing), malaise=$($homeostatic.malaise)" -ForegroundColor DarkGray
    Write-Host "    Perceptual: clarity=$($perceptual.clarity), quality=$($perceptual.quality)" -ForegroundColor DarkGray
    Write-Host "    Aesthetic: beauty=$($aesthetic.beauty)" -ForegroundColor DarkGray

    # Weighted aggregation (Damasio: homeostatic is foundation)
    $confidence_score = [Math]::Round((
        $homeostatic.confidence_contribution * 0.40 +  # Homeostatic most important
        $perceptual.confidence_contribution * 0.35 +   # Perceptual second
        $aesthetic.confidence_contribution * 0.25      # Aesthetic third
    ), 3)

    # Detect uncertainty sources
    $uncertaintySources = @()
    if ($homeostatic.malaise -gt 0.3) {
        $uncertaintySources += "malaise=$($homeostatic.malaise)"
    }
    if ($perceptual.clarity -lt 0.5) {
        $uncertaintySources += "low_clarity=$($perceptual.clarity)"
    }
    if ($aesthetic.beauty -lt 0.4) {
        $uncertaintySources += "aesthetic_low=$($aesthetic.beauty)"
    }

    # Confidence level (categorical)
    $confidence_level = if ($confidence_score -gt 0.75) { "high" }
                       elseif ($confidence_score -gt 0.5) { "medium" }
                       elseif ($confidence_score -gt 0.25) { "low" }
                       else { "none" }

    # Hallucination risk (inverse of confidence + uncertainty sources)
    $hallucination_risk = [Math]::Round((1.0 - $confidence_score) *
                                       (1.0 + ($uncertaintySources.Count * 0.1)), 3)

    return @{
        confidence_score = $confidence_score
        confidence_level = $confidence_level
        uncertainty_sources = $uncertaintySources
        hallucination_risk = [Math]::Min($hallucination_risk, 1.0)

        # Raw signals
        homeostatic = $homeostatic
        perceptual = $perceptual
        aesthetic = $aesthetic

        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

# ==============================================================================
# BEHAVIORAL GATES: Anti-hallucination
# ==============================================================================

function Get-BehavioralGates {
    param($ConfidenceStatus)

    Write-Host "  [Ring2] Generating behavioral gates (anti-hallucination)..." -ForegroundColor Cyan

    $score = $ConfidenceStatus.confidence_score
    $risk = $ConfidenceStatus.hallucination_risk
    $uncertain_count = $ConfidenceStatus.uncertainty_sources.Count

    # Should verify before claiming?
    $verify_before_claim = ($score -lt 0.6 -or $risk -gt 0.4)

    # Use hedging language?
    $hedging = if ($score -lt 0.4) { "ik ben niet zeker, maar" }
               elseif ($score -lt 0.6) { "ik verwacht dat" }
               elseif ($score -lt 0.8) { "waarschijnlijk" }
               else { $null }  # No hedging needed

    # Flag uncertainty explicitly?
    $flag_uncertainty = ($uncertain_count -ge 2 -or $risk -gt 0.5)

    # Hallucination prevention action
    $hallu_prevention = if ($risk -gt 0.7) { "STOP_AND_VERIFY" }
                       elseif ($risk -gt 0.5) { "USE_HEDGING_AND_VERIFY" }
                       elseif ($risk -gt 0.3) { "USE_HEDGING" }
                       else { "PROCEED_WITH_CONFIDENCE" }

    $gates = @{
        verify_before_claim = $verify_before_claim
        use_hedging = ($null -ne $hedging)
        hedging_language = $hedging
        flag_uncertainty = $flag_uncertainty
        hallucination_prevention_action = $hallu_prevention

        # Guidance
        confidence_guidance = if ($score -gt 0.75) { "High confidence - speak directly" }
                             elseif ($score -gt 0.5) { "Medium confidence - use qualifiers" }
                             else { "Low confidence - verify or acknowledge uncertainty" }

        uncertainty_guidance = if ($uncertain_count -eq 0) { "No uncertainty detected" }
                              elseif ($uncertain_count -eq 1) { "Minor uncertainty - proceed with caution" }
                              else { "Multiple uncertainty sources - high vigilance" }
    }

    Write-Host "    Confidence: $($ConfidenceStatus.confidence_level) (score: $score)" -ForegroundColor DarkGray
    Write-Host "    Hallucination risk: $risk → $hallu_prevention" -ForegroundColor DarkGray
    Write-Host "    Guidance: $($gates.confidence_guidance)" -ForegroundColor DarkGray

    return $gates
}

# ==============================================================================
# CLAIM CONFIDENCE CHECK (new - voor specifieke beweringen)
# ==============================================================================

function Test-ClaimConfidence {
    param([string]$ClaimText)

    Write-Host "`n[Ring2] Checking confidence for claim: '$ClaimText'" -ForegroundColor Cyan

    # Get current confidence status
    $confidence = Get-AggregatedConfidence
    $gates = Get-BehavioralGates -ConfidenceStatus $confidence

    # Analyze claim text for certainty indicators
    $certainty_words = @("definitely", "certainly", "always", "never", "must", "will", "zeker", "altijd", "nooit", "moet")
    $uncertainty_words = @("maybe", "perhaps", "possibly", "might", "could", "misschien", "mogelijk", "waarschijnlijk")

    $has_certainty = ($certainty_words | Where-Object { $ClaimText -match $_ }).Count -gt 0
    $has_uncertainty = ($uncertainty_words | Where-Object { $ClaimText -match $_ }).Count -gt 0

    # Recommendation
    $recommendation = if ($has_certainty -and $confidence.confidence_score -lt 0.6) {
        "[RISK] Claim uses certainty language but confidence is LOW. Soften or verify."
    } elseif (-not $has_uncertainty -and $confidence.confidence_score -lt 0.4) {
        "[WARNING] No hedging in claim, but confidence is VERY LOW. Add qualifiers."
    } elseif ($has_uncertainty -and $confidence.confidence_score -gt 0.8) {
        "[Note] Claim hedged but confidence is high. You can be more direct."
    } else {
        "[OK] Claim confidence aligns with internal state."
    }

    Write-Host "  Confidence: $($confidence.confidence_level) ($($confidence.confidence_score))" -ForegroundColor White
    Write-Host "  Certainty language: $has_certainty | Uncertainty language: $has_uncertainty" -ForegroundColor White
    Write-Host "  $recommendation" -ForegroundColor $(if ($recommendation -match "RISK|WARNING") { "Red" } elseif ($recommendation -match "Note") { "Yellow" } else { "Green" })

    return @{
        claim = $ClaimText
        confidence = $confidence
        has_certainty_language = $has_certainty
        has_uncertainty_language = $has_uncertainty
        recommendation = $recommendation
    }
}

# ==============================================================================
# ACTIONS
# ==============================================================================

function Invoke-Status {
    Write-Host "`n[SCP Ring 2: Affective Confidence Weighting]" -ForegroundColor Green

    $confidence = Get-AggregatedConfidence
    $gates = Get-BehavioralGates -ConfidenceStatus $confidence

    $fullState = @{
        confidence_status = $confidence
        behavioral_gates = $gates
        ring = 2
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    # Save
    $fullState | ConvertTo-Json -Depth 5 | Set-Content $StateFile

    # Display
    Write-Host "`nCONFIDENCE STATUS:" -ForegroundColor Yellow
    Write-Host "  Level: $($confidence.confidence_level) (score: $($confidence.confidence_score))" -ForegroundColor White
    Write-Host "  Hallucination risk: $($confidence.hallucination_risk)" -ForegroundColor White
    if ($confidence.uncertainty_sources.Count -gt 0) {
        Write-Host "  Uncertainty sources: $($confidence.uncertainty_sources -join ', ')" -ForegroundColor Yellow
    }

    Write-Host "`nBEHAVIORAL GATES (Anti-Hallucination):" -ForegroundColor Yellow
    Write-Host "  $($gates.confidence_guidance)" -ForegroundColor Cyan
    Write-Host "  $($gates.uncertainty_guidance)" -ForegroundColor Cyan
    Write-Host "  Action: $($gates.hallucination_prevention_action)" -ForegroundColor Cyan

    if ($gates.use_hedging) {
        Write-Host "  Suggest hedging: '$($gates.hedging_language)'" -ForegroundColor Magenta
    }

    return $fullState
}

# ==============================================================================
# LOGGING
# ==============================================================================

function Write-Ring2Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$timestamp] [$Level] $Message" -ErrorAction SilentlyContinue
}

# ==============================================================================
# MAIN
# ==============================================================================

try {
    switch ($Action) {
        "Status" {
            $result = Invoke-Status
            Write-Ring2Log "Status check. Confidence: $($result.confidence_status.confidence_level), Risk: $($result.confidence_status.hallucination_risk)"
        }
        "CheckConfidence" {
            if (-not $ClaimText) {
                Write-Host "ERROR: -ClaimText required for CheckConfidence action" -ForegroundColor Red
                exit 1
            }
            $result = Test-ClaimConfidence -ClaimText $ClaimText
            Write-Ring2Log "Claim checked: $($result.recommendation)"
        }
        "GetGates" {
            if (Test-Path $StateFile) {
                $state = Get-Content $StateFile -Raw | ConvertFrom-Json
                $state.behavioral_gates | ConvertTo-Json
            } else {
                $result = Invoke-Status
                $result.behavioral_gates | ConvertTo-Json
            }
        }
        default {
            Write-Host "Unknown action: $Action" -ForegroundColor Red
            Write-Host "Valid actions: Status, CheckConfidence, GetGates" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "ERROR in Ring 2 Orchestrator: $_" -ForegroundColor Red
    Write-Ring2Log "ERROR: $_" "ERROR"
}
