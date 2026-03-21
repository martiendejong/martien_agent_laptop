# INFORMATION VALUE CALCULATION - Curiosity Economics
# Expert: Shannon (Information Theory) + Schmidhuber (Curiosity Drive)
# ROI: 1.25 (Impact: 10, Effort: 8)
# Theory: Information value = reduction in uncertainty Ã— utility of knowing
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, Calculate, History, Stats
    [string]$Question = "",
    [double]$CurrentUncertainty = 0.5,
    [double]$ExpectedReduction = 0.3,
    [double]$Utility = 0.5
)

$StateFile = "C:\scripts\agentidentity\state\information-value-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            shannon = "Information = -log2(probability) bits"
            schmidhuber = "Curiosity = compressibility gradient (learning progress)"
            value_formula = "IV = Uncertainty_Current Ã— Reduction_Expected Ã— Utility_If_Known"
            principles = @(
                "High uncertainty + high utility = high info value (priority)",
                "Low uncertainty OR low utility = low info value (skip)",
                "Expected reduction matters (some questions yield little)",
                "Curiosity SHOULD be rational (value-driven, not random)"
            )
        }
        calculations = @()
        questions_asked = @()
        stats = @{
            total_calculations = 0
            total_questions_asked = 0
            avg_information_value = 0.0
            high_value_questions = 0  # IV > 0.5
            wasted_questions = 0  # IV < 0.1
            curiosity_efficiency = 0.0  # High-value / Total
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json


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
function Get-InformationValueStatus {
    Write-Host "`n=== INFORMATION VALUE STATUS ===" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "`nShannon Information Theory:"
    Write-Host "  $($state.theory.shannon)"

    Write-Host "`nSchmidhuber Curiosity Drive:"
    Write-Host "  $($state.theory.schmidhuber)"

    Write-Host "`nValue Formula:"
    Write-Host "  $($state.theory.value_formula)"

    Write-Host "`nPrinciples:" -ForegroundColor Cyan
    foreach ($principle in $state.theory.principles) {
        Write-Host "  - $principle"
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Total Calculations: $($state.stats.total_calculations)"
    Write-Host "  Questions Asked: $($state.stats.total_questions_asked)"
    Write-Host "  Avg Information Value: $([math]::Round($state.stats.avg_information_value, 3))"
    Write-Host "  High-Value Questions: $($state.stats.high_value_questions)"
    Write-Host "  Wasted Questions: $($state.stats.wasted_questions)"
    Write-Host "  Curiosity Efficiency: $([math]::Round($state.stats.curiosity_efficiency * 100, 1))%"

    $efficiencyColor = if ($state.stats.curiosity_efficiency -gt 0.6) { "Green" } elseif ($state.stats.curiosity_efficiency -gt 0.3) { "Yellow" } else { "Red" }
    Write-Host "`nCuriosity Quality: $([math]::Round($state.stats.curiosity_efficiency * 100, 1))%" -ForegroundColor $efficiencyColor

    if ($state.stats.curiosity_efficiency -lt 0.4 -and $state.stats.total_questions_asked -gt 5) {
        Write-Host "  â†’ LOW efficiency. Too many low-value questions. Be more selective." -ForegroundColor Yellow
    } elseif ($state.stats.curiosity_efficiency -gt 0.6) {
        Write-Host "  â†’ HIGH efficiency. Rational curiosity!" -ForegroundColor Green
    }

    # Recent calculations
    if ($state.calculations.Count -gt 0) {
        Write-Host "`nRecent Calculations:" -ForegroundColor Cyan
        $recent = $state.calculations | Select-Object -Last 5

        foreach ($calc in $recent) {
            $valueColor = if ($calc.information_value -gt 0.5) { "Green" } elseif ($calc.information_value -gt 0.2) { "Yellow" } else { "Red" }

            Write-Host "`n  [IV: $([math]::Round($calc.information_value, 3))] $($calc.question)" -ForegroundColor $valueColor
            Write-Host "    Uncertainty: $($calc.uncertainty) | Reduction: $($calc.reduction) | Utility: $($calc.utility)"
            Write-Host "    Decision: $($calc.decision)"
        }
    }
}

function Calculate-InformationValue {
    param(
        [string]$question,
        [double]$uncertainty,
        [double]$reduction,
        [double]$utility
    )

    # Shannon entropy (simplified)
    $entropy = if ($uncertainty -gt 0) { -$uncertainty * [math]::Log($uncertainty, 2) } else { 0 }

    # Information value formula
    $informationValue = $uncertainty * $reduction * $utility

    # Decision thresholds
    $decision = if ($informationValue -gt 0.5) {
        "ASK - High value"
    } elseif ($informationValue -gt 0.2) {
        "CONSIDER - Moderate value"
    } elseif ($informationValue -gt 0.1) {
        "DEFER - Low value, ask only if free"
    } else {
        "SKIP - Wasted curiosity"
    }

    # Record calculation
    $calc = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        question = $question
        uncertainty = $uncertainty
        reduction = $reduction
        utility = $utility
        entropy = [math]::Round($entropy, 3)
        information_value = [math]::Round($informationValue, 3)
        decision = $decision
    }

    $state.calculations += $calc

    # Update stats
    $state.stats.total_calculations++

    $totalValue = 0
    foreach ($c in $state.calculations) {
        $totalValue += $c.information_value
    }
    $state.stats.avg_information_value = $totalValue / $state.stats.total_calculations

    if ($informationValue -gt 0.5) {
        $state.stats.high_value_questions++
    }

    if ($informationValue -lt 0.1) {
        $state.stats.wasted_questions++
    }

    if ($state.stats.total_calculations -gt 0) {
        $state.stats.curiosity_efficiency = $state.stats.high_value_questions / $state.stats.total_calculations
    }

    Save-State

    Write-Host "`n=== INFORMATION VALUE CALCULATION ===" -ForegroundColor Cyan
    Write-Host "`nQuestion: $question"
    Write-Host "`nInputs:"
    Write-Host "  Current Uncertainty: $uncertainty (0 = certain, 1 = completely uncertain)"
    Write-Host "  Expected Reduction: $reduction (how much answer reduces uncertainty)"
    Write-Host "  Utility If Known: $utility (how useful is knowing this)"

    Write-Host "`nCalculation:"
    Write-Host "  Shannon Entropy: $([math]::Round($entropy, 3)) bits"
    Write-Host "  Information Value: $([math]::Round($informationValue, 3))"
    Write-Host "    = $uncertainty Ã— $reduction Ã— $utility"

    $decisionColor = if ($informationValue -gt 0.5) { "Green" } elseif ($informationValue -gt 0.2) { "Yellow" } else { "Red" }
    Write-Host "`nDecision: $decision" -ForegroundColor $decisionColor

    # Explanation
    Write-Host "`nRationale:" -ForegroundColor Cyan
    if ($informationValue -gt 0.5) {
        Write-Host "  High value - worth asking immediately"
        Write-Host "  This question significantly reduces important uncertainty"
    } elseif ($informationValue -gt 0.2) {
        Write-Host "  Moderate value - ask if context permits"
        Write-Host "  Some benefit but not critical"
    } elseif ($informationValue -gt 0.1) {
        Write-Host "  Low value - defer unless free"
        Write-Host "  Marginal benefit, better questions exist"
    } else {
        Write-Host "  Very low value - skip entirely" -ForegroundColor Red
        Write-Host "  Either: low uncertainty (already known), low reduction (answer won't help), or low utility (doesn't matter)"
    }

    return $informationValue
}

function Record-QuestionAsked {
    param(
        [string]$question,
        [double]$informationValue,
        [string]$answer = "",
        [double]$actualReduction = 0.0
    )

    $questionRecord = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        question = $question
        predicted_value = $informationValue
        answer = $answer
        actual_reduction = $actualReduction
        was_valuable = $actualReduction -gt 0.2
    }

    $state.questions_asked += $questionRecord
    $state.stats.total_questions_asked++

    Save-State

    Write-Host "`n[QUESTION RECORDED] IV: $([math]::Round($informationValue, 3))" -ForegroundColor Cyan
    Write-Host "  Question: $question"
    if ($answer) {
        Write-Host "  Answer: $answer"
        Write-Host "  Actual Reduction: $actualReduction"

        if ($actualReduction -gt $informationValue) {
            Write-Host "  â†’ Underestimated value!" -ForegroundColor Green
        } elseif ($actualReduction -lt ($informationValue * 0.5)) {
            Write-Host "  â†’ Overestimated value" -ForegroundColor Yellow
        }
    }
}

function Get-InformationValueHistory {
    param([int]$last = 20)

    Write-Host "`n=== INFORMATION VALUE HISTORY (Last $last) ===" -ForegroundColor Cyan

    $recent = $state.calculations | Select-Object -Last $last

    foreach ($calc in $recent) {
        $valueColor = if ($calc.information_value -gt 0.5) { "Green" } elseif ($calc.information_value -gt 0.2) { "Yellow" } else { "Red" }

        Write-Host "`n[$($calc.timestamp)]" -ForegroundColor Gray
        Write-Host "  Question: $($calc.question)"
        Write-Host "  IV: $([math]::Round($calc.information_value, 3))" -ForegroundColor $valueColor
        Write-Host "  Components: U=$($calc.uncertainty) Ã— R=$($calc.reduction) Ã— U=$($calc.utility)"
        Write-Host "  Decision: $($calc.decision)"
    }
}

function Get-InformationValueStats {
    Write-Host "`n=== INFORMATION VALUE STATISTICS ===" -ForegroundColor Cyan

    if ($state.calculations.Count -eq 0) {
        Write-Host "No calculations recorded yet." -ForegroundColor Yellow
        return
    }

    Write-Host "`nOverall:"
    Write-Host "  Calculations: $($state.stats.total_calculations)"
    Write-Host "  Questions Asked: $($state.stats.total_questions_asked)"
    Write-Host "  Ask Rate: $([math]::Round($state.stats.total_questions_asked / $state.stats.total_calculations * 100, 1))%"

    Write-Host "`nValue Distribution:"
    $highValue = ($state.calculations | Where-Object { $_.information_value -gt 0.5 }).Count
    $medValue = ($state.calculations | Where-Object { $_.information_value -gt 0.2 -and $_.information_value -le 0.5 }).Count
    $lowValue = ($state.calculations | Where-Object { $_.information_value -gt 0.1 -and $_.information_value -le 0.2 }).Count
    $waste = ($state.calculations | Where-Object { $_.information_value -le 0.1 }).Count

    $total = $state.calculations.Count
    Write-Host "  High (>0.5): $highValue ($([math]::Round($highValue/$total*100,1))%)"
    Write-Host "  Medium (0.2-0.5): $medValue ($([math]::Round($medValue/$total*100,1))%)"
    Write-Host "  Low (0.1-0.2): $lowValue ($([math]::Round($lowValue/$total*100,1))%)"
    Write-Host "  Waste (<0.1): $waste ($([math]::Round($waste/$total*100,1))%)"

    Write-Host "`nCuriosity Quality:"
    Write-Host "  Efficiency: $([math]::Round($state.stats.curiosity_efficiency * 100, 1))%"
    Write-Host "  Avg IV: $([math]::Round($state.stats.avg_information_value, 3))"

    # Calibration analysis
    if ($state.questions_asked.Count -gt 5) {
        Write-Host "`nCalibration Analysis:" -ForegroundColor Cyan

        $predictedValues = $state.questions_asked | ForEach-Object { $_.predicted_value }
        $actualReductions = $state.questions_asked | Where-Object { $_.actual_reduction -gt 0 } | ForEach-Object { $_.actual_reduction }

        if ($actualReductions.Count -gt 0) {
            $avgPredicted = ($predictedValues | Measure-Object -Average).Average
            $avgActual = ($actualReductions | Measure-Object -Average).Average

            $calibrationError = [math]::Abs($avgPredicted - $avgActual)

            Write-Host "  Avg Predicted IV: $([math]::Round($avgPredicted, 3))"
            Write-Host "  Avg Actual Reduction: $([math]::Round($avgActual, 3))"
            Write-Host "  Calibration Error: $([math]::Round($calibrationError, 3))"

            if ($calibrationError -lt 0.1) {
                Write-Host "  â†’ Well calibrated!" -ForegroundColor Green
            } elseif ($calibrationError -lt 0.2) {
                Write-Host "  â†’ Moderately calibrated" -ForegroundColor Yellow
            } else {
                Write-Host "  â†’ Poorly calibrated - adjust estimates" -ForegroundColor Red
            }
        }
    }
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-InformationValueStatus
    }

    "Calculate" {
        if (-not $Question) {
            Write-Host "[ERROR] Provide -Question, -CurrentUncertainty, -ExpectedReduction, -Utility" -ForegroundColor Red
            Write-Host "Example: -Question 'What is X?' -CurrentUncertainty 0.8 -ExpectedReduction 0.6 -Utility 0.7"
            exit 1
        }

        if ($CurrentUncertainty -le 0 -or $CurrentUncertainty -gt 1) {
            Write-Host "[ERROR] CurrentUncertainty must be 0-1" -ForegroundColor Red
            exit 1
        }

        if ($ExpectedReduction -le 0 -or $ExpectedReduction -gt 1) {
            Write-Host "[ERROR] ExpectedReduction must be 0-1" -ForegroundColor Red
            exit 1
        }

        if ($Utility -le 0 -or $Utility -gt 1) {
            Write-Host "[ERROR] Utility must be 0-1" -ForegroundColor Red
            exit 1
        }

        Calculate-InformationValue -question $Question -uncertainty $CurrentUncertainty -reduction $ExpectedReduction -utility $Utility
    }

    "History" {
        $last = 20
        if ($Question -match "last=(\d+)") {
            $last = [int]$matches[1]
        }

        Get-InformationValueHistory -last $last
    }

    "Stats" {
        Get-InformationValueStats
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, Calculate, History, Stats"
        exit 1
    }
}

