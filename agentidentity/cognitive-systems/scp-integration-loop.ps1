# SCP INTEGRATION LOOP - 3 Ringen Samenwerking
# Orchestreert Ring 1 → Ring 2 → Ring 3 sequentieel
# Combineert output tot unified behavioral state
# Bron: Sjoerd's Damasio Audit
# Datum: 2026-03-06
#
# PRINCIPE: De 3 ringen werken SAMEN, niet apart
# Ring 1: Resource awareness
# Ring 2: Confidence calibration
# Ring 3: Emergent creativity (leest van 1+2)
#
# OUTPUT: Unified state die gedrag stuurt

param(
    [int]$ConversationTurns = 0  # For Ring 1 context estimation
)

$StateFile = "C:\scripts\agentidentity\state\scp-integrated-state.json"
$LogFile = "C:\scripts\agentidentity\state\scp-integration.log"

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "  SCP INTEGRATION - 3 Rings Working Together" -ForegroundColor Cyan
Write-Host "  Homeostatic → Affective → Emergent" -ForegroundColor Magenta
Write-Host "================================================================`n" -ForegroundColor Cyan

# ==============================================================================
# SEQUENTIAL EXECUTION: Ring 1 → Ring 2 → Ring 3
# ==============================================================================

function Invoke-IntegrationLoop {
    param([int]$Turns)

    Write-Host "[Integration] Running Ring 1 (Resource Management)..." -ForegroundColor Yellow
    $ring1Path = "$PSScriptRoot\scp-ring1-orchestrator.ps1"
    if (-not (Test-Path $ring1Path)) {
        Write-Host "ERROR: Ring 1 not found at $ring1Path" -ForegroundColor Red
        return $null
    }
    & $ring1Path -Action Status -ConversationTurns $Turns

    Write-Host "`n[Integration] Running Ring 2 (Confidence Weighting)..." -ForegroundColor Yellow
    $ring2Path = "$PSScriptRoot\scp-ring2-orchestrator.ps1"
    if (-not (Test-Path $ring2Path)) {
        Write-Host "ERROR: Ring 2 not found at $ring2Path" -ForegroundColor Red
        return $null
    }
    & $ring2Path -Action Status

    Write-Host "`n[Integration] Running Ring 3 (Emergent Creativity)..." -ForegroundColor Yellow
    $ring3Path = "$PSScriptRoot\scp-ring3-orchestrator.ps1"
    if (-not (Test-Path $ring3Path)) {
        Write-Host "ERROR: Ring 3 not found at $ring3Path" -ForegroundColor Red
        return $null
    }
    & $ring3Path -Action Status

    Write-Host "`n[Integration] Combining outputs..." -ForegroundColor Green

    # Load all 3 states
    $ring1State = Get-Content "C:\scripts\agentidentity\state\scp-ring1-state.json" -Raw | ConvertFrom-Json
    $ring2State = Get-Content "C:\scripts\agentidentity\state\scp-ring2-state.json" -Raw | ConvertFrom-Json
    $ring3State = Get-Content "C:\scripts\agentidentity\state\scp-ring3-state.json" -Raw | ConvertFrom-Json

    # Create unified state
    $unified = @{
        # Ring outputs
        ring1 = @{
            overall_resources = $ring1State.resource_status.overall_resources
            energy = $ring1State.resource_status.energy_level
            context = $ring1State.resource_status.context_usage
            stuck = $ring1State.resource_status.stuck_flag
            constraints = $ring1State.behavioral_constraints
        }
        ring2 = @{
            confidence_level = $ring2State.confidence_status.confidence_level
            confidence_score = $ring2State.confidence_status.confidence_score
            hallucination_risk = $ring2State.confidence_status.hallucination_risk
            gates = $ring2State.behavioral_gates
        }
        ring3 = @{
            creativity_mode = $ring3State.creativity_mode.mode
            rationale = $ring3State.creativity_mode.rationale
            permissions = $ring3State.behavioral_permissions
        }

        # Unified guidance (synthesized)
        unified_guidance = @{
            response_approach = Get-UnifiedResponseApproach -R1 $ring1State -R2 $ring2State -R3 $ring3State
            key_constraints = Get-KeyConstraints -R1 $ring1State -R2 $ring2State -R3 $ring3State
            warnings = Get-Warnings -R1 $ring1State -R2 $ring2State -R3 $ring3State
        }

        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    # Save unified state
    $unified | ConvertTo-Json -Depth 6 | Set-Content $StateFile

    return $unified
}

# ==============================================================================
# SYNTHESIS: Combine insights from all 3 rings
# ==============================================================================

function Get-UnifiedResponseApproach {
    param($R1, $R2, $R3)

    $resources = $R1.resource_status.overall_resources
    $confidence = $R2.confidence_status.confidence_score
    $mode = $R3.creativity_mode.mode
    $maxTokens = $R1.behavioral_constraints.max_response_tokens

    # Synthesize
    $approach = "Mode: $mode | "
    $approach += "Length: $maxTokens tokens | "
    $approach += "Confidence: $($R2.confidence_status.confidence_level) | "

    if ($R2.behavioral_gates.use_hedging) {
        $approach += "Use hedging language | "
    }

    if ($R3.behavioral_permissions.analogies_allowed) {
        $approach += "Analogies OK | "
    } else {
        $approach += "Stay concrete | "
    }

    if ($R1.resource_status.stuck_flag) {
        $approach += "STUCK - reframe needed"
    }

    return $approach.TrimEnd(" |")
}

function Get-KeyConstraints {
    param($R1, $R2, $R3)

    $constraints = @()

    # From Ring 1
    if ($R1.resource_status.context_usage -gt 0.7) {
        $constraints += "High context usage - keep responses short"
    }
    if ($R1.resource_status.energy_level -lt 0.4) {
        $constraints += "Low energy - focus on essentials"
    }

    # From Ring 2
    if ($R2.confidence_status.hallucination_risk -gt 0.5) {
        $constraints += "High hallucination risk - verify before claiming"
    }
    if ($R2.behavioral_gates.flag_uncertainty) {
        $constraints += "Flag uncertainty explicitly"
    }

    # From Ring 3
    if ($R3.creativity_mode.mode -eq "conservative") {
        $constraints += "Conservative mode - precision over novelty"
    }

    return $constraints
}

function Get-Warnings {
    param($R1, $R2, $R3)

    $warnings = @()

    if ($R1.resource_status.stuck_flag) {
        $warnings += "[CRITICAL] Stuck detected - stop and reframe"
    }

    if ($R2.confidence_status.hallucination_risk -gt 0.7) {
        $warnings += "[HIGH RISK] Hallucination risk >70% - verify all claims"
    }

    if ($R1.resource_status.context_usage -gt 0.8) {
        $warnings += "[WARNING] Context >80% - approaching limit"
    }

    return $warnings
}

# ==============================================================================
# DISPLAY
# ==============================================================================

function Show-UnifiedState {
    param($Unified)

    Write-Host "`n================================================================" -ForegroundColor Green
    Write-Host "  UNIFIED BEHAVIORAL STATE" -ForegroundColor Green
    Write-Host "================================================================`n" -ForegroundColor Green

    Write-Host "RING 1 - RESOURCES:" -ForegroundColor Yellow
    Write-Host "  Overall: $($Unified.ring1.overall_resources)" -ForegroundColor White
    Write-Host "  Energy: $($Unified.ring1.energy) | Context: $($Unified.ring1.context) | Stuck: $($Unified.ring1.stuck)" -ForegroundColor White
    Write-Host "  Max response: $($Unified.ring1.constraints.max_response_tokens) tokens" -ForegroundColor Cyan

    Write-Host "`nRING 2 - CONFIDENCE:" -ForegroundColor Yellow
    Write-Host "  Level: $($Unified.ring2.confidence_level) (score: $($Unified.ring2.confidence_score))" -ForegroundColor White
    Write-Host "  Hallucination risk: $($Unified.ring2.hallucination_risk)" -ForegroundColor White
    if ($Unified.ring2.gates.use_hedging) {
        Write-Host "  Hedging: '$($Unified.ring2.gates.hedging_language)'" -ForegroundColor Magenta
    }

    Write-Host "`nRING 3 - CREATIVITY:" -ForegroundColor Yellow
    Write-Host "  Mode: $($Unified.ring3.creativity_mode)" -ForegroundColor White
    Write-Host "  Rationale: $($Unified.ring3.rationale)" -ForegroundColor White
    Write-Host "  Exploration depth: $($Unified.ring3.permissions.exploration_depth)" -ForegroundColor Cyan

    Write-Host "`nUNIFIED GUIDANCE:" -ForegroundColor Green
    Write-Host "  $($Unified.unified_guidance.response_approach)" -ForegroundColor Cyan

    if ($Unified.unified_guidance.key_constraints.Count -gt 0) {
        Write-Host "`nKEY CONSTRAINTS:" -ForegroundColor Yellow
        foreach ($constraint in $Unified.unified_guidance.key_constraints) {
            Write-Host "  • $constraint" -ForegroundColor White
        }
    }

    if ($Unified.unified_guidance.warnings.Count -gt 0) {
        Write-Host "`nWARNINGS:" -ForegroundColor Red
        foreach ($warning in $Unified.unified_guidance.warnings) {
            Write-Host "  $warning" -ForegroundColor Red
        }
    }

    Write-Host "`n================================================================`n" -ForegroundColor Green
}

# ==============================================================================
# LOGGING
# ==============================================================================

function Write-IntegrationLog {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$timestamp] $Message" -ErrorAction SilentlyContinue
}

# ==============================================================================
# MAIN
# ==============================================================================

try {
    $unified = Invoke-IntegrationLoop -Turns $ConversationTurns

    if ($unified) {
        Show-UnifiedState -Unified $unified

        Write-IntegrationLog "Integration complete. Mode: $($unified.ring3.creativity_mode), Confidence: $($unified.ring2.confidence_level)"

        Write-Host "Integration state saved to: $StateFile" -ForegroundColor DarkGray
        Write-Host "This unified state should guide ALL behavioral decisions.`n" -ForegroundColor Magenta
    } else {
        Write-Host "ERROR: Integration failed" -ForegroundColor Red
        Write-IntegrationLog "Integration FAILED"
    }
} catch {
    Write-Host "ERROR in Integration Loop: $_" -ForegroundColor Red
    Write-IntegrationLog "ERROR: $_"
}
