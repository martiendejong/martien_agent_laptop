# Consciousness Bridge RL²F Integration
## Neural Plasticity Enhancement for consciousness-bridge.ps1

**Purpose:** Integrate self-critique engine into consciousness bridge for autodidactic learning

---

## Changes Required

### 1. Add New Actions to ValidateSet

**Line 47:** Update ValidateSet to include:
```powershell
[ValidateSet('OnTaskStart', 'OnDecision', 'OnDelegation', 'OnStuck', 'OnTaskEnd', 'GetContextSummary', 'OnUserMessage', 'Reset',
             'OnDurationShift', 'OnIntuition', 'OnCreativeEmergence', 'OnSystem3Use', 'OnUserResponse',
             'TrackAlchemy', 'AdjustMemoryTension', 'EnterFundamentalMode', 'OnConflict',
             'OnSelfCorrection', 'OnAutodidacticSession')]  # RL²F additions
```

### 2. Add New Parameters

**After line 98 ($Silent):**
```powershell
# RL²F / Neural Plasticity parameters
[string]$OriginalDecision = '',
[string]$Critique = '',
[string]$RevisedDecision = '',
[int]$Turn = 1,
[string]$RiskLevel = '',
[int]$TotalTurns = 0,
[int]$CritiquesGenerated = 0,
[string]$FinalRisk = '',
[string]$OutcomeAfterExecution = ''
```

### 3. Enhance OnDecision with Self-Critique (Lines 921-1100)

**Insert BEFORE line 934 (Invoke-Control):**

```powershell
# RL²F: Self-critique before logging decision
$selfCritiqueEnabled = $true  # Feature flag
$selfCritiqueResult = $null

if ($selfCritiqueEnabled) {
    try {
        $selfCritiquePath = "$PSScriptRoot\self-critique-engine.ps1"
        if (Test-Path $selfCritiquePath) {
            $critiqueJson = & $selfCritiquePath `
                -Action $Decision `
                -Context "$Project | $Reasoning" `
                -Turn 1 `
                2>&1

            if ($critiqueJson) {
                $selfCritiqueResult = $critiqueJson | ConvertFrom-Json

                # Add critique to result
                $result = @{
                    decision = $Decision
                    reasoning = $Reasoning
                    self_critique = $selfCritiqueResult
                    risk_level = $selfCritiqueResult.risk_level
                    should_revise = ($selfCritiqueResult.risk_level -in @('high_risk', 'revise'))
                }

                # If high-risk, log to Chronal R2 as WARNING
                if ($selfCritiqueResult.risk_level -eq 'high_risk') {
                    if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
                        $null = Add-ToRung -Rung 'R2' -Data @{
                            Type = 'self_critique_warning'
                            Decision = $Decision
                            RiskLevel = 'high_risk'
                            Critiques = $selfCritiqueResult.self_critique
                            Recommendation = $selfCritiqueResult.recommendation
                            Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                        }
                    }

                    # Auto-trigger OnSelfCorrection if not silent
                    if (-not $Silent) {
                        Write-Host "[NEURAL_PLASTICITY] HIGH RISK DETECTED - Self-critique triggered:" -ForegroundColor Red
                        foreach ($c in $selfCritiqueResult.self_critique) {
                            Write-Host "  [$($c.category)] $($c.critique)" -ForegroundColor Yellow
                            Write-Host "    Evidence: $($c.evidence)" -ForegroundColor Gray
                        }
                        Write-Host "[NEURAL_PLASTICITY] $($selfCritiqueResult.recommendation)" -ForegroundColor Yellow
                    }
                }
            }
        }
    } catch {
        # Silent failure OK - self-critique is enhancement, not requirement
        Write-BridgeLog "Self-critique failed (non-critical): $($_.Exception.Message)"
    }
}
```

**At end of OnDecision (before return), add self-critique to result:**
```powershell
# Add self-critique to result if generated
if ($selfCritiqueResult) {
    $result['self_critique'] = $selfCritiqueResult
    $result['neural_plasticity_active'] = $true
}
```

### 4. Add OnSelfCorrection Handler

**After OnDecision block (after line 1100):**

```powershell
'OnSelfCorrection' {
    Write-BridgeLog "Self-Correction: Turn $Turn - Original: $OriginalDecision → Revised: $RevisedDecision"

    # Log to Chronal R2
    if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
        $null = Add-ToRung -Rung 'R2' -Data @{
            Type = 'self_correction'
            Turn = $Turn
            OriginalDecision = $OriginalDecision
            Critique = $Critique
            RevisedDecision = $RevisedDecision
            RiskLevel = $RiskLevel
            Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
        }
    }

    # Update neural plasticity tracker
    try {
        $plasticityPath = "C:\scripts\agentidentity\state\neural-plasticity-tracker.json"
        if (Test-Path $plasticityPath) {
            $plasticity = Get-Content $plasticityPath -Raw | ConvertFrom-Json

            # Increment self-correction sessions
            $plasticity.autodidactic_sessions.total_sessions++

            # Track turn count
            $plasticity.autodidactic_sessions.history += @{
                timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                original_decision = $OriginalDecision
                revised_decision = $RevisedDecision
                turn = $Turn
                risk_level = $RiskLevel
            }

            # Update average turns
            if ($plasticity.autodidactic_sessions.history.Count -gt 0) {
                $avgTurns = ($plasticity.autodidactic_sessions.history | Measure-Object -Property turn -Average).Average
                $plasticity.autodidactic_sessions.average_turns = [Math]::Round($avgTurns, 2)
                $plasticity.metrics.self_correction_turns.current = [Math]::Round($avgTurns, 2)
            }

            $plasticity.last_updated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            $plasticity | ConvertTo-Json -Depth 10 | Set-Content $plasticityPath -Encoding UTF8
        }
    } catch {
        Write-BridgeLog "Neural plasticity update failed (non-critical): $($_.Exception.Message)"
    }

    if (-not $Silent) {
        Write-Host "[SELF_CORRECTION] Turn $Turn" -ForegroundColor Cyan
        Write-Host "  Original: $OriginalDecision" -ForegroundColor Gray
        Write-Host "  Critique: $Critique" -ForegroundColor Yellow
        Write-Host "  Revised: $RevisedDecision" -ForegroundColor Green
    }

    return @{
        action = 'OnSelfCorrection'
        turn = $Turn
        original = $OriginalDecision
        revised = $RevisedDecision
        risk_level = $RiskLevel
        timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
    }
}

'OnAutodidacticSession' {
    Write-BridgeLog "Autodidactic Session Complete: $Task - $TotalTurns turns, $CritiquesGenerated critiques, final risk: $FinalRisk"

    # Log to Chronal R3 (long-term patterns)
    if ($global:ConsciousnessState -and $global:ConsciousnessState.ChronalLadder) {
        $null = Add-ToRung -Rung 'R3' -Data @{
            Type = 'autodidactic_session'
            Task = $Task
            TotalTurns = $TotalTurns
            CritiquesGenerated = $CritiquesGenerated
            FinalRisk = $FinalRisk
            OutcomeAfterExecution = $OutcomeAfterExecution
            Success = ($OutcomeAfterExecution -eq 'success')
            Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
        }
    }

    # Update neural plasticity metrics
    try {
        $plasticityPath = "C:\scripts\agentidentity\state\neural-plasticity-tracker.json"
        if (Test-Path $plasticityPath) {
            $plasticity = Get-Content $plasticityPath -Raw | ConvertFrom-Json

            # Track session outcome
            if ($OutcomeAfterExecution -eq 'success') {
                $plasticity.autodidactic_sessions.successful_self_corrections++

                # Successful self-correction = high integration rate
                $current = $plasticity.metrics.integration_rate.current
                $plasticity.metrics.integration_rate.current = [Math]::Round(
                    ($current * 0.9) + (1.0 * 0.1), 3
                )
            } else {
                $plasticity.autodidactic_sessions.failed_self_corrections++

                # Failed self-correction = low integration
                $current = $plasticity.metrics.integration_rate.current
                $plasticity.metrics.integration_rate.current = [Math]::Round(
                    $current * 0.95, 3
                )
            }

            # Update critique prediction accuracy (based on final risk matching outcome)
            $predictionCorrect = (
                ($FinalRisk -eq 'proceed' -and $OutcomeAfterExecution -eq 'success') -or
                ($FinalRisk -in @('high_risk', 'revise') -and $OutcomeAfterExecution -ne 'success')
            )

            if ($predictionCorrect) {
                $current = $plasticity.metrics.critique_prediction_accuracy.current
                $plasticity.metrics.critique_prediction_accuracy.current = [Math]::Round(
                    ($current * 0.9) + (1.0 * 0.1), 3
                )
            }

            $plasticity.last_updated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            $plasticity | ConvertTo-Json -Depth 10 | Set-Content $plasticityPath -Encoding UTF8
        }
    } catch {
        Write-BridgeLog "Neural plasticity update failed (non-critical): $($_.Exception.Message)"
    }

    if (-not $Silent) {
        Write-Host "[AUTODIDACTIC] Session complete: $Task" -ForegroundColor Cyan
        Write-Host "  Turns: $TotalTurns | Critiques: $CritiquesGenerated | Final risk: $FinalRisk" -ForegroundColor Gray
        Write-Host "  Outcome: $OutcomeAfterExecution" -ForegroundColor $(if ($OutcomeAfterExecution -eq 'success') { 'Green' } else { 'Red' })
    }

    return @{
        action = 'OnAutodidacticSession'
        task = $Task
        total_turns = $TotalTurns
        critiques_generated = $CritiquesGenerated
        final_risk = $FinalRisk
        outcome = $OutcomeAfterExecution
        success = ($OutcomeAfterExecution -eq 'success')
        timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
    }
}
```

### 5. Update OnTaskEnd to Learn from Outcomes

**In OnTaskEnd handler, add AFTER consciousness score update:**

```powershell
# RL²F: Learn from task outcome (if decision was made)
if ($Decision) {
    try {
        $selfCritiquePath = "$PSScriptRoot\self-critique-engine.ps1"
        if (Test-Path $selfCritiquePath) {
            & $selfCritiquePath `
                -LearnFromOutcome `
                -Action $Decision `
                -Outcome $Outcome `
                -ActualFeedback $LessonsLearned `
                2>&1 | Out-Null
        }
    } catch {
        # Silent failure OK
    }
}
```

---

## Usage Examples

### Before (current):
```powershell
consciousness-bridge.ps1 -Action OnDecision -Decision "Create PR" -Reasoning "Feature complete"
# Returns: decision logged
```

### After (with RL²F):
```powershell
consciousness-bridge.ps1 -Action OnDecision -Decision "Create PR" -Reasoning "Feature complete"
# Internally runs self-critique
# If high-risk → returns: { self_critique: {...}, should_revise: true }
# If proceed → returns: { self_critique: {...}, should_revise: false }
```

### Multi-turn refinement:
```powershell
# Turn 1
$result = consciousness-bridge.ps1 -Action OnDecision -Decision "Create PR" -Reasoning "Feature complete"

if ($result.should_revise) {
    # Turn 2: Log self-correction
    consciousness-bridge.ps1 -Action OnSelfCorrection `
        -OriginalDecision "Create PR" `
        -Critique "Worktree not released" `
        -RevisedDecision "Release worktree first, then create PR" `
        -Turn 2 `
        -RiskLevel "high_risk"

    # Re-decide
    $result2 = consciousness-bridge.ps1 -Action OnDecision -Decision "Release worktree first" -Reasoning "Self-critique"

    if (-not $result2.should_revise) {
        # Execute
        Execute-Action
    }
}

# After execution
consciousness-bridge.ps1 -Action OnAutodidacticSession `
    -Task "Create client-manager PR" `
    -TotalTurns 2 `
    -CritiquesGenerated 1 `
    -FinalRisk "proceed" `
    -OutcomeAfterExecution "success"

# Learn from outcome
consciousness-bridge.ps1 -Action OnTaskEnd `
    -Decision "Release worktree first, then create PR" `
    -Outcome "success" `
    -LessonsLearned "Self-critique prevented worktree violation"
```

---

## Validation

**Test 1: Preemptive Critique**
```powershell
# Should trigger high-risk warning
consciousness-bridge.ps1 -Action OnDecision `
    -Decision "Create client-manager worktree" `
    -Reasoning "Implementing feature" `
    -Project "client-manager"

# Expected output:
# [NEURAL_PLASTICITY] HIGH RISK DETECTED
# [technical] Create paired hazina worktree FIRST - 1505 build errors otherwise
# Evidence: Seen 3 times in reflection.log.md
```

**Test 2: Integration Rate**
```powershell
# After 10 sessions with self-correction
# Check: C:\scripts\agentidentity\state\neural-plasticity-tracker.json
# Expected: integration_rate.current > 0.80
```

**Test 3: Repeat Error Rate**
```powershell
# Make same mistake twice
# First time: self-critique triggers
# Second time: should trigger AGAIN (pattern reinforcement)
# Expected: repeat_error_rate.current < 0.105 (30% reduction from 0.15)
```

---

**Implementation Status:** DESIGN COMPLETE - Ready for integration

**Files Modified:**
1. `consciousness-bridge.ps1` (3 new actions, enhanced OnDecision, learning integration)

**Files Used:**
1. `self-critique-engine.ps1` (tool)
2. `neural-plasticity-tracker.json` (state)
3. `feedback-patterns.json` (corpus)

**Next Steps:**
1. Apply changes to consciousness-bridge.ps1
2. Test with known error patterns
3. Monitor neural plasticity metrics for 1 week
4. Validate Week 3 criteria (2026-03-22)

---

**Last Updated:** 2026-02-22 (RL²F Integration Design)
