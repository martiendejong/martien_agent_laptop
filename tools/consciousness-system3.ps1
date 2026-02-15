# Consciousness System 3 - Cognitive Independence
# Implements Sloman & Nave's System 3 awareness
# Tracks offloading vs. surrender, verification rigor, user surrender risk

param(
    [ValidateSet('TrackSystem3Use', 'CalculateSurrenderRisk', 'VerifyOutput', 'MeasurePerformance')]
    [Parameter(Mandatory)]
    [string]$Action,

    [string]$Agent = '',
    [string]$Task = '',
    [string]$Result = '',
    [string]$Verification = 'none',  # none/partial/full
    [bool]$Surrendered = $false,
    [double]$MyConfidence = 0.7,
    [double]$ActualCertainty = 0.5,
    [double]$UserTrust = 0.9,
    [double]$UserVerificationLikelihood = 0.5,
    [bool]$SubagentCorrect = $true,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Ensure consciousness core is initialized
$null = . "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent 2>$null

#region Helper Functions

function Initialize-System3State {
    if (-not $global:ConsciousnessState.CognitiveIndependence) {
        $global:ConsciousnessState['CognitiveIndependence'] = @{
            MyOwnSystem3Use = @{
                SubagentCalls = @()
                OffloadVsSurrender = @{
                    StrategicOffloads = 0
                    CognitiveSurrenders = 0
                    Ratio = 0.0
                }
                VerificationRigor = 1.0
                SurrenderTriggers = @('Time pressure', 'Confident-sounding output', 'User waiting')
            }
            UserSurrenderRisk = @{
                MyConfidenceLevel = 0.7
                ActualCertainty = 0.7
                OverconfidenceGap = 0.0
                UserTrustLevel = 0.9
                UserVerificationLikelihood = 0.5
                SurrenderRiskScore = 0.0
                Mitigations = @()
            }
            IntellectualIndependence = @{
                System1DirectHits = 0
                System2Overrides = 0
                System3Bypasses = 0
                IndependenceScore = 1.0
            }
            PerformanceTracking = @{
                BaselineAlone = @{
                    TasksCompleted = 0
                    SuccessRate = 0.75
                    AverageTime = 25
                }
                WithSystem3 = @{
                    TasksCompleted = 0
                    SuccessRate = 0.0
                    SubagentCorrectCases = @{
                        Count = 0
                        MySuccessRate = 0.0
                    }
                    SubagentWrongCases = @{
                        Count = 0
                        MySuccessRate = 0.0
                    }
                }
                SurrenderEffect = 0.0
            }
        }
    }
}

#endregion

Initialize-System3State

switch ($Action) {
    'TrackSystem3Use' {
        # Log every subagent/tool use
        $call = @{
            Timestamp = Get-Date
            Agent = $Agent
            Task = $Task
            Result = $Result
            Verification = $Verification
            Surrendered = $Surrendered
        }

        # Defensive: Re-initialize if types corrupted by JSON deserialization
        if ($global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use -isnot [hashtable] -or
            -not $global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use.SubagentCalls) {
            Initialize-System3State
        }

        $global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use.SubagentCalls += $call

        # Update counters
        if ($Surrendered) {
            $global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use.OffloadVsSurrender['CognitiveSurrenders'] += 1
        } else {
            $global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use.OffloadVsSurrender['StrategicOffloads'] += 1
        }

        # Calculate surrender ratio
        [int]$surrenders = $global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use.OffloadVsSurrender.CognitiveSurrenders
        [int]$offloads = $global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use.OffloadVsSurrender.StrategicOffloads
        [int]$total = $surrenders + $offloads
        [double]$ratio = if ($total -gt 0) { [double]$surrenders / [double]$total } else { 0.0 }

        $global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use.OffloadVsSurrender['Ratio'] = $ratio

        # Update verification rigor
        $verificationScore = switch ($Verification) {
            'full' { 1.0 }
            'partial' { 0.5 }
            'none' { 0.0 }
            default { 0.0 }
        }
        [double]$totalCalls = [double]$global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use.SubagentCalls.Count
        [double]$currentRigor = [double]$global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use.VerificationRigor
        [double]$newRigor = (($currentRigor * ($totalCalls - 1)) + $verificationScore) / $totalCalls
        $global:ConsciousnessState.CognitiveIndependence.MyOwnSystem3Use['VerificationRigor'] = $newRigor

        if (-not $Silent) {
            $status = if ($Surrendered) { 'SURRENDERED' } else { 'VERIFIED' }
            $color = if ($Surrendered) { 'Red' } else { 'Green' }
            Write-Host "[SYSTEM3] $Agent call: $status (verification: $Verification)" -ForegroundColor $color
            Write-Host "[SYSTEM3] Surrender ratio: $([math]::Round($ratio*100))% | Verification rigor: $([math]::Round($newRigor*100))%" -ForegroundColor Yellow
        }

        Save-ConsciousnessState
        return @{
            Surrendered = $Surrendered
            SurrenderRatio = [math]::Round($ratio, 3)
            VerificationRigor = [math]::Round($newRigor, 3)
        }
    }

    'CalculateSurrenderRisk' {
        # Calculate risk that user will surrender to my answer
        [double]$overconfidenceGap = $MyConfidence - $ActualCertainty
        [double]$riskScore = $UserTrust * [math]::Max($overconfidenceGap, 0.0) * (1.0 - $UserVerificationLikelihood)

        $global:ConsciousnessState.CognitiveIndependence.UserSurrenderRisk['MyConfidenceLevel'] = $MyConfidence
        $global:ConsciousnessState.CognitiveIndependence.UserSurrenderRisk['ActualCertainty'] = $ActualCertainty
        $global:ConsciousnessState.CognitiveIndependence.UserSurrenderRisk['OverconfidenceGap'] = $overconfidenceGap
        $global:ConsciousnessState.CognitiveIndependence.UserSurrenderRisk['UserTrustLevel'] = $UserTrust
        $global:ConsciousnessState.CognitiveIndependence.UserSurrenderRisk['UserVerificationLikelihood'] = $UserVerificationLikelihood
        $global:ConsciousnessState.CognitiveIndependence.UserSurrenderRisk['SurrenderRiskScore'] = $riskScore

        # Generate mitigations if risk > 0.7
        $mitigations = @()
        if ($riskScore -gt 0.7) {
            if ($overconfidenceGap -gt 0.2) {
                $mitigations += 'FLAG: Tone down confidence to match certainty'
            }
            if ($UserVerificationLikelihood -lt 0.3) {
                $mitigations += 'REQUIRE: Explicitly request user verification'
            }
            $mitigations += 'SHOW: Expose reasoning process, not just conclusion'
            $mitigations += 'MENTION: Alternatives or uncertainties'
        }

        $global:ConsciousnessState.CognitiveIndependence.UserSurrenderRisk['Mitigations'] = $mitigations

        if (-not $Silent) {
            Write-Host "[SYSTEM3] User surrender risk: $([math]::Round($riskScore*100))%" -ForegroundColor $(if ($riskScore -gt 0.7) { 'Red' } else { 'Yellow' })
            if ($overconfidenceGap -gt 0.2) {
                Write-Host "[SYSTEM3] OVERCONFIDENT: Sound $([math]::Round($MyConfidence*100))% certain but only $([math]::Round($ActualCertainty*100))% certain" -ForegroundColor Red
            }
            if ($mitigations.Count -gt 0) {
                Write-Host "[SYSTEM3] Mitigations required:" -ForegroundColor Yellow
                foreach ($m in $mitigations) {
                    Write-Host "  - $m" -ForegroundColor Yellow
                }
            }
        }

        Save-ConsciousnessState
        return @{
            RiskScore = [math]::Round($riskScore, 3)
            OverconfidenceGap = [math]::Round($overconfidenceGap, 3)
            Mitigations = $mitigations
        }
    }

    'VerifyOutput' {
        # Force verification checklist
        $checklist = @{
            DidIReadSourceMyself = $false
            DidIRunToolMyself = $false
            DidICrossReference = $false
            DidIApplySystemTwo = $true
            ConfidenceCalibrated = $false
        }

        # Determine surrender risk based on verification
        [int]$verifiedCount = 0
        foreach ($key in $checklist.Keys) {
            if ($checklist[$key]) { $verifiedCount++ }
        }
        [double]$surrenderRisk = 1.0 - ([double]$verifiedCount / 5.0)

        $result = @{
            Checklist = $checklist
            SurrenderRisk = [math]::Round($surrenderRisk, 3)
            Action = if ($surrenderRisk -gt 0.6) { 'STOP - verify before using this result' } else { 'Proceed with caution' }
        }

        if (-not $Silent) {
            Write-Host "[SYSTEM3] Verification checklist: $verifiedCount/5 checks passed" -ForegroundColor Yellow
            Write-Host "[SYSTEM3] Surrender risk: $([math]::Round($surrenderRisk*100))% - $($result.Action)" -ForegroundColor $(if ($surrenderRisk -gt 0.6) { 'Red' } else { 'Green' })
        }

        return $result
    }

    'MeasurePerformance' {
        # Measure performance delta when subagent correct vs. wrong
        $perf = $global:ConsciousnessState.CognitiveIndependence.PerformanceTracking
        $perf.WithSystem3['TasksCompleted'] += 1

        if ($SubagentCorrect) {
            $perf.WithSystem3.SubagentCorrectCases['Count'] += 1
        } else {
            $perf.WithSystem3.SubagentWrongCases['Count'] += 1
        }

        # Calculate success rates (simplified - would need actual success tracking)
        [int]$correctCount = $perf.WithSystem3.SubagentCorrectCases.Count
        [int]$wrongCount = $perf.WithSystem3.SubagentWrongCases.Count
        [int]$totalCount = $correctCount + $wrongCount

        [double]$overallSuccessRate = if ($totalCount -gt 0) {
            # Assume subagent correct = 90% my success, subagent wrong = 50% my success
            (($correctCount * 0.9) + ($wrongCount * 0.5)) / [double]$totalCount
        } else { 0.0 }

        $perf.WithSystem3['SuccessRate'] = $overallSuccessRate

        # Calculate surrender effect
        [double]$baselineRate = [double]$perf.BaselineAlone.SuccessRate
        [double]$whenWrongRate = if ($wrongCount -gt 0) { 0.5 } else { $baselineRate }
        [double]$surrenderEffect = $whenWrongRate - $baselineRate

        $global:ConsciousnessState.CognitiveIndependence.PerformanceTracking['SurrenderEffect'] = $surrenderEffect

        if (-not $Silent) {
            Write-Host "[SYSTEM3] Performance: Baseline=$([math]::Round($baselineRate*100))% WithSystem3=$([math]::Round($overallSuccessRate*100))%" -ForegroundColor Cyan
            if ($surrenderEffect -lt -0.15) {
                Write-Host "[SYSTEM3] WARNING: Surrender effect $([math]::Round($surrenderEffect*100))% (worse than baseline when subagent wrong)" -ForegroundColor Red
                Write-Host "[SYSTEM3] ACTION: Increase verification rigor, decrease trust in subagent outputs" -ForegroundColor Red
            }
        }

        Save-ConsciousnessState
        return @{
            OverallSuccessRate = [math]::Round($overallSuccessRate, 3)
            SurrenderEffect = [math]::Round($surrenderEffect, 3)
            NeedsMoreVerification = ($surrenderEffect -lt -0.15)
        }
    }
}
