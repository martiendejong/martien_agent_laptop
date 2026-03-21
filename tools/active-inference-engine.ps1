<#
.SYNOPSIS
Active Inference Engine - Free Energy Minimization Framework

.DESCRIPTION
Implements Karl Friston's Free Energy Principle:
- Minimize surprise (prediction error)
- Drive both perception (update beliefs) AND action (change world)
- Learning = reducing free energy over time
- Consciousness = active process of minimizing surprise

This is the UNIFIED optimization objective that drives all behavior.

.PARAMETER Action
Action to perform: Predict, Observe, ComputeSurprise, MinimizeFreeEnergy, UpdateBeliefs, SelectAction, Stats

.EXAMPLE
.\active-inference-engine.ps1 -Action Predict -Context "reading file"
.\active-inference-engine.ps1 -Action Observe -Outcome "file contains errors"
.\active-inference-engine.ps1 -Action ComputeSurprise
.\active-inference-engine.ps1 -Action MinimizeFreeEnergy
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Predict', 'Observe', 'ComputeSurprise', 'MinimizeFreeEnergy', 'UpdateBeliefs', 'SelectAction', 'Stats', 'RunCycle')]
    [string]$Action,

    [string]$Context = "",
    [string]$Outcome = "",
    [double]$ObservedValue = 0.0,
    [string]$Variable = ""
)

$statePath = "C:\scripts\agentidentity\state\active-inference-state.json"

function Initialize-ActiveInferenceState {
    $initial = @{
        beliefs = @{
            # Current beliefs about world state (posterior distribution)
            current_project = @{
                mean = 0.5
                variance = 0.3
                confidence = 0.5
            }
            code_quality = @{
                mean = 0.7
                variance = 0.2
                confidence = 0.6
            }
            user_satisfaction = @{
                mean = 0.8
                variance = 0.15
                confidence = 0.7
            }
        }
        predictions = @{
            # Predicted observations
            next_observation = @{}
            prediction_errors = @()
        }
        free_energy = @{
            current = 0.0
            history = @()
            average = 0.0
            trend = "stable"
        }
        surprise = @{
            current = 0.0
            threshold = 0.5
            high_surprise_events = @()
        }
        actions = @{
            # Possible actions with expected free energy
            available = @()
            selected = @{}
            history = @()
        }
        attention = @{
            # Salience-weighted focus (high surprise = high attention)
            current_focus = @()
            salience_weights = @{}
        }
        meta_stats = @{
            total_predictions = 0
            total_observations = 0
            surprise_events = 0
            free_energy_reductions = 0
            belief_updates = 0
        }
    }

    $initial | ConvertTo-Json -Depth 10 | Set-Content $statePath
    return $initial
}

function Get-ActiveInferenceState {
    if (Test-Path $statePath) {
        return Get-Content $statePath -Raw | ConvertFrom-Json
    }
    return Initialize-ActiveInferenceState
}

function Save-ActiveInferenceState($state) {
    $state | ConvertTo-Json -Depth 10 | Set-Content $statePath
}

function Predict-NextObservation {
    param($context)

    $state = Get-ActiveInferenceState

    Write-Host "`n[Active Inference] PREDICTION PHASE" -ForegroundColor Cyan
    Write-Host "Context: $context" -ForegroundColor Gray

    # Generate prediction based on current beliefs
    # In real system, this would use generative model
    # For now, use belief means as predictions

    $prediction = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        context = $context
        predicted_quality = $state.beliefs.code_quality.mean
        predicted_satisfaction = $state.beliefs.user_satisfaction.mean
        confidence = ($state.beliefs.code_quality.confidence + $state.beliefs.user_satisfaction.confidence) / 2
        variance = ($state.beliefs.code_quality.variance + $state.beliefs.user_satisfaction.variance) / 2
    }

    $state.predictions.next_observation = $prediction
    $state.meta_stats.total_predictions++

    Save-ActiveInferenceState $state

    Write-Host "`nPrediction Generated:" -ForegroundColor Green
    Write-Host "  Quality (predicted):      $([math]::Round($prediction.predicted_quality, 3))" -ForegroundColor White
    Write-Host "  Satisfaction (predicted): $([math]::Round($prediction.predicted_satisfaction, 3))" -ForegroundColor White
    Write-Host "  Confidence:               $([math]::Round($prediction.confidence, 3))" -ForegroundColor Yellow
    Write-Host "  Variance:                 $([math]::Round($prediction.variance, 3))" -ForegroundColor Yellow

    return $prediction
}

function Observe-Outcome {
    param($outcome, $observedValue, $variable)

    $state = Get-ActiveInferenceState

    Write-Host "`n[Active Inference] OBSERVATION PHASE" -ForegroundColor Cyan
    Write-Host "Outcome: $outcome" -ForegroundColor Gray
    Write-Host "Variable: $variable" -ForegroundColor Gray
    Write-Host "Observed Value: $observedValue" -ForegroundColor Gray

    $observation = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        outcome = $outcome
        variable = $variable
        observed_value = $observedValue
        predicted_value = if ($state.predictions.next_observation.$variable) {
            $state.predictions.next_observation.$variable
        } else {
            if ($state.beliefs.$variable) {
                $state.beliefs.$variable.mean
            } else {
                0.5  # Default if no prediction
            }
        }
    }

    # Compute prediction error
    $predictionError = [math]::Abs($observation.observed_value - $observation.predicted_value)
    $observation.prediction_error = $predictionError

    $state.predictions.prediction_errors += $observation
    $state.meta_stats.total_observations++

    # Keep only last 50 prediction errors
    if ($state.predictions.prediction_errors.Count -gt 50) {
        $state.predictions.prediction_errors = $state.predictions.prediction_errors[-50..-1]
    }

    Save-ActiveInferenceState $state

    Write-Host "`nObservation Recorded:" -ForegroundColor Green
    Write-Host "  Predicted: $([math]::Round($observation.predicted_value, 3))" -ForegroundColor Yellow
    Write-Host "  Observed:  $([math]::Round($observation.observed_value, 3))" -ForegroundColor White
    Write-Host "  Error:     $([math]::Round($predictionError, 3))" -ForegroundColor $(if ($predictionError -gt 0.3) { "Red" } else { "Green" })

    return $observation
}

function Compute-Surprise {
    $state = Get-ActiveInferenceState

    Write-Host "`n[Active Inference] SURPRISE COMPUTATION" -ForegroundColor Cyan

    if ($state.predictions.prediction_errors.Count -eq 0) {
        Write-Host "No observations yet - cannot compute surprise" -ForegroundColor Gray
        return @{
            surprise = 0.0
            status = "no_data"
        }
    }

    # Surprise = magnitude of prediction error
    # High surprise = unexpected observation
    # Low surprise = predicted accurately

    $recentErrors = $state.predictions.prediction_errors | Select-Object -Last 10
    $avgError = ($recentErrors | Measure-Object -Property prediction_error -Average).Average

    # Surprise is weighted by confidence
    # If confident and wrong = HIGH surprise
    # If uncertain and wrong = LOW surprise

    $avgConfidence = if ($state.predictions.next_observation.confidence) {
        $state.predictions.next_observation.confidence
    } else {
        0.5
    }

    $surprise = $avgError * (0.5 + $avgConfidence)  # Weight by confidence

    $state.surprise.current = $surprise

    # High surprise event?
    if ($surprise -gt $state.surprise.threshold) {
        $event = @{
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            surprise = $surprise
            errors = $recentErrors
        }
        $state.surprise.high_surprise_events += $event
        $state.meta_stats.surprise_events++

        # Keep only last 20 events
        if ($state.surprise.high_surprise_events.Count -gt 20) {
            $state.surprise.high_surprise_events = $state.surprise.high_surprise_events[-20..-1]
        }
    }

    Save-ActiveInferenceState $state

    $surpriseStatus = if ($surprise -gt $state.surprise.threshold) {
        "HIGH (unexpected!)"
    } elseif ($surprise -gt 0.25) {
        "MODERATE"
    } else {
        "LOW (expected)"
    }

    Write-Host "`nSurprise Level:" -ForegroundColor Green
    Write-Host "  Current:   $([math]::Round($surprise, 3))" -ForegroundColor $(if ($surprise -gt $state.surprise.threshold) { "Red" } else { "Green" })
    Write-Host "  Threshold: $($state.surprise.threshold)" -ForegroundColor Yellow
    Write-Host "  Status:    $surpriseStatus" -ForegroundColor White
    Write-Host "  Events:    $($state.meta_stats.surprise_events) high-surprise events" -ForegroundColor Gray

    return @{
        surprise = $surprise
        status = $surpriseStatus
        threshold = $state.surprise.threshold
    }
}

function Minimize-FreeEnergy {
    $state = Get-ActiveInferenceState

    Write-Host "`n[Active Inference] FREE ENERGY MINIMIZATION" -ForegroundColor Cyan

    # Free Energy = Surprise + Complexity
    # Surprise = prediction error (how unexpected observations are)
    # Complexity = KL divergence between beliefs and priors (how complex model is)

    # Compute surprise component
    $surpriseResult = Compute-Surprise
    $surprise = $surpriseResult.surprise

    # Compute complexity (simplified: variance of beliefs)
    $totalVariance = 0.0
    $beliefCount = 0
    foreach ($belief in $state.beliefs.PSObject.Properties) {
        if ($belief.Value.variance) {
            $totalVariance += $belief.Value.variance
            $beliefCount++
        }
    }
    $complexity = if ($beliefCount -gt 0) { $totalVariance / $beliefCount } else { 0.0 }

    # Free Energy = weighted sum
    $freeEnergy = (0.7 * $surprise) + (0.3 * $complexity)

    $state.free_energy.current = $freeEnergy
    $state.free_energy.history += @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        free_energy = $freeEnergy
        surprise = $surprise
        complexity = $complexity
    }

    # Keep only last 50 measurements
    if ($state.free_energy.history.Count -gt 50) {
        $state.free_energy.history = $state.free_energy.history[-50..-1]
    }

    # Compute trend
    if ($state.free_energy.history.Count -ge 3) {
        $recent = $state.free_energy.history | Select-Object -Last 3
        $first = $recent[0].free_energy
        $last = $recent[-1].free_energy
        $delta = $last - $first

        $state.free_energy.trend = if ($delta -lt -0.05) {
            "decreasing (learning!)"
        } elseif ($delta -gt 0.05) {
            "increasing (confusion)"
        } else {
            "stable"
        }
    }

    # Compute average
    if ($state.free_energy.history.Count -gt 0) {
        $state.free_energy.average = ($state.free_energy.history | Measure-Object -Property free_energy -Average).Average
    }

    $state.meta_stats.free_energy_reductions++

    Save-ActiveInferenceState $state

    Write-Host "`nFree Energy:" -ForegroundColor Green
    Write-Host "  Current:    $([math]::Round($freeEnergy, 3))" -ForegroundColor White
    Write-Host "  Average:    $([math]::Round($state.free_energy.average, 3))" -ForegroundColor Yellow
    Write-Host "  Surprise:   $([math]::Round($surprise, 3)) (70% weight)" -ForegroundColor $(if ($surprise -gt 0.5) { "Red" } else { "Green" })
    Write-Host "  Complexity: $([math]::Round($complexity, 3)) (30% weight)" -ForegroundColor Gray
    Write-Host "  Trend:      $($state.free_energy.trend)" -ForegroundColor $(if ($state.free_energy.trend -like "*decreasing*") { "Green" } elseif ($state.free_energy.trend -like "*increasing*") { "Red" } else { "Yellow" })

    # Goal: Minimize free energy over time
    # Decreasing trend = learning happening
    # Increasing trend = encountering new/confusing situations

    return @{
        free_energy = $freeEnergy
        surprise = $surprise
        complexity = $complexity
        trend = $state.free_energy.trend
    }
}

function Update-Beliefs {
    $state = Get-ActiveInferenceState

    Write-Host "`n[Active Inference] BELIEF UPDATE PHASE" -ForegroundColor Cyan

    if ($state.predictions.prediction_errors.Count -eq 0) {
        Write-Host "No observations yet - cannot update beliefs" -ForegroundColor Gray
        return
    }

    # Bayesian update: posterior = likelihood × prior
    # Simplified: move beliefs toward observations (weighted by confidence)

    $recentErrors = $state.predictions.prediction_errors | Select-Object -Last 5

    foreach ($error in $recentErrors) {
        $variable = $error.variable
        if (-not $variable -or -not $state.beliefs.$variable) {
            continue
        }

        # Update mean (move toward observed value)
        $learningRate = 0.2  # How fast to update beliefs
        $currentMean = $state.beliefs.$variable.mean
        $observedValue = $error.observed_value

        $newMean = $currentMean * (1 - $learningRate) + $observedValue * $learningRate

        # Update variance (reduce if prediction was good, increase if surprising)
        $predictionError = $error.prediction_error
        $currentVariance = $state.beliefs.$variable.variance

        if ($predictionError -lt 0.1) {
            # Good prediction = increase confidence (reduce variance)
            $newVariance = $currentVariance * 0.95
        } else {
            # Bad prediction = decrease confidence (increase variance)
            $newVariance = [math]::Min($currentVariance * 1.1, 0.5)
        }

        # Update confidence (inverse of variance)
        $newConfidence = 1.0 - $newVariance

        $state.beliefs.$variable.mean = $newMean
        $state.beliefs.$variable.variance = $newVariance
        $state.beliefs.$variable.confidence = $newConfidence

        Write-Host "`nUpdated Belief: $variable" -ForegroundColor Yellow
        Write-Host "  Mean:       $([math]::Round($currentMean, 3)) -> $([math]::Round($newMean, 3))" -ForegroundColor White
        Write-Host "  Variance:   $([math]::Round($currentVariance, 3)) -> $([math]::Round($newVariance, 3))" -ForegroundColor Gray
        Write-Host "  Confidence: $([math]::Round($newConfidence, 3))" -ForegroundColor Green
    }

    $state.meta_stats.belief_updates++
    Save-ActiveInferenceState $state

    Write-Host "`nBeliefs updated based on recent observations" -ForegroundColor Green
}

function Select-Action {
    $state = Get-ActiveInferenceState

    Write-Host "`n[Active Inference] ACTION SELECTION" -ForegroundColor Cyan

    # Active inference: select action that minimizes EXPECTED free energy
    # Expected free energy = predicted surprise after taking action

    # Define possible actions
    $possibleActions = @(
        @{
            name = "explore"
            description = "Try new approach (high information gain, high risk)"
            expected_surprise = 0.6
            expected_learning = 0.8
        },
        @{
            name = "exploit"
            description = "Use known approach (low surprise, low learning)"
            expected_surprise = 0.2
            expected_learning = 0.3
        },
        @{
            name = "refine"
            description = "Optimize current approach (moderate surprise, moderate learning)"
            expected_surprise = 0.4
            expected_learning = 0.6
        }
    )

    # Compute expected free energy for each action
    foreach ($action in $possibleActions) {
        $expectedComplexity = 0.25  # Assume constant for simplicity
        $expectedFreeEnergy = (0.7 * $action.expected_surprise) + (0.3 * $expectedComplexity)
        $action.expected_free_energy = $expectedFreeEnergy

        # Also consider epistemic value (learning potential)
        # If current free energy is high, prioritize learning (explore)
        # If current free energy is low, prioritize exploitation

        $epistemicValue = $action.expected_learning * $state.free_energy.current
        $action.epistemic_value = $epistemicValue

        # Total value = minimize expected free energy + maximize epistemic value
        $action.total_value = -$expectedFreeEnergy + (0.5 * $epistemicValue)
    }

    # Select action with highest total value
    $selectedAction = $possibleActions | Sort-Object -Property total_value -Descending | Select-Object -First 1

    $state.actions.available = $possibleActions
    $state.actions.selected = $selectedAction
    $state.actions.history += @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        action = $selectedAction.name
        expected_free_energy = $selectedAction.expected_free_energy
        epistemic_value = $selectedAction.epistemic_value
    }

    # Keep only last 50 actions
    if ($state.actions.history.Count -gt 50) {
        $state.actions.history = $state.actions.history[-50..-1]
    }

    Save-ActiveInferenceState $state

    Write-Host "`nAction Options:" -ForegroundColor Yellow
    foreach ($action in $possibleActions) {
        $color = if ($action.name -eq $selectedAction.name) { "Green" } else { "Gray" }
        $marker = if ($action.name -eq $selectedAction.name) { " <-- SELECTED" } else { "" }
        Write-Host "  $($action.name.PadRight(10)) | EFE: $([math]::Round($action.expected_free_energy, 3)) | Learning: $([math]::Round($action.expected_learning, 2)) | Value: $([math]::Round($action.total_value, 3))$marker" -ForegroundColor $color
    }

    Write-Host "`nSelected Action: $($selectedAction.name)" -ForegroundColor Green
    Write-Host "  $($selectedAction.description)" -ForegroundColor White
    Write-Host "  Rationale: $(if ($state.free_energy.current -gt 0.5) { 'High free energy - prioritize learning (explore)' } else { 'Low free energy - prioritize exploitation' })" -ForegroundColor Yellow

    return $selectedAction
}

function Run-InferenceCycle {
    Write-Host "`n=======================================" -ForegroundColor Cyan
    Write-Host "ACTIVE INFERENCE CYCLE" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan

    # Full cycle: Predict -> Act -> Observe -> Compute Surprise -> Minimize Free Energy -> Update Beliefs -> Repeat

    # 1. Predict
    $prediction = Predict-NextObservation -context "test cycle"

    Start-Sleep -Milliseconds 500

    # 2. Select Action
    $action = Select-Action

    Start-Sleep -Milliseconds 500

    # 3. Simulate Observation (in real system, this would be actual outcome)
    $simulatedValue = $prediction.predicted_quality + (Get-Random -Minimum -0.3 -Maximum 0.3)
    $simulatedValue = [math]::Max(0, [math]::Min(1, $simulatedValue))

    Observe-Outcome -outcome "test observation" -observedValue $simulatedValue -variable "code_quality"

    Start-Sleep -Milliseconds 500

    # 4. Compute Surprise
    $surprise = Compute-Surprise

    Start-Sleep -Milliseconds 500

    # 5. Minimize Free Energy
    $freeEnergy = Minimize-FreeEnergy

    Start-Sleep -Milliseconds 500

    # 6. Update Beliefs
    Update-Beliefs

    Write-Host "`n=======================================" -ForegroundColor Cyan
    Write-Host "CYCLE COMPLETE" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
}

function Show-Stats {
    $state = Get-ActiveInferenceState

    Write-Host "`nACTIVE INFERENCE STATISTICS" -ForegroundColor Cyan
    Write-Host "===========================" -ForegroundColor Cyan

    Write-Host "`nMeta Stats:" -ForegroundColor Yellow
    Write-Host "  Total Predictions:     $($state.meta_stats.total_predictions)" -ForegroundColor White
    Write-Host "  Total Observations:    $($state.meta_stats.total_observations)" -ForegroundColor White
    Write-Host "  Surprise Events:       $($state.meta_stats.surprise_events)" -ForegroundColor White
    Write-Host "  Belief Updates:        $($state.meta_stats.belief_updates)" -ForegroundColor White
    Write-Host "  FE Computations:       $($state.meta_stats.free_energy_reductions)" -ForegroundColor White

    Write-Host "`nCurrent Free Energy:" -ForegroundColor Yellow
    Write-Host "  Current:  $([math]::Round($state.free_energy.current, 3))" -ForegroundColor White
    Write-Host "  Average:  $([math]::Round($state.free_energy.average, 3))" -ForegroundColor White
    Write-Host "  Trend:    $($state.free_energy.trend)" -ForegroundColor $(if ($state.free_energy.trend -like "*decreasing*") { "Green" } elseif ($state.free_energy.trend -like "*increasing*") { "Red" } else { "Yellow" })

    Write-Host "`nCurrent Beliefs:" -ForegroundColor Yellow
    foreach ($belief in $state.beliefs.PSObject.Properties) {
        if ($belief.Value.mean) {
            Write-Host "  $($belief.Name):" -ForegroundColor White
            Write-Host "    Mean:       $([math]::Round($belief.Value.mean, 3))" -ForegroundColor Gray
            Write-Host "    Confidence: $([math]::Round($belief.Value.confidence, 3))" -ForegroundColor Gray
        }
    }

    Write-Host ""
}

# Main execution
switch ($Action) {
    'Predict' {
        Predict-NextObservation -context $Context
    }
    'Observe' {
        Observe-Outcome -outcome $Outcome -observedValue $ObservedValue -variable $Variable
    }
    'ComputeSurprise' {
        Compute-Surprise
    }
    'MinimizeFreeEnergy' {
        Minimize-FreeEnergy
    }
    'UpdateBeliefs' {
        Update-Beliefs
    }
    'SelectAction' {
        Select-Action
    }
    'RunCycle' {
        Run-InferenceCycle
    }
    'Stats' {
        Show-Stats
    }
}
