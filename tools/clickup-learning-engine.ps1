# ClickUp Learning Engine - Extract Patterns, Update Models, Self-Improve
# Purpose: Learn from every task, calibrate predictions, improve continuously
# Author: Jengo
# Created: 2026-02-28

param(
    [ValidateSet('ExtractPattern', 'UpdateModel', 'PredictScope', 'GetLearnings')]
    [string]$Action = 'ExtractPattern',

    [string]$TaskId,
    [hashtable]$TaskData,
    [string]$TaskType
)

$ErrorActionPreference = 'Stop'

# Paths
$OutcomesFile = "C:\scripts\agentidentity\state\clickup-task-outcomes.jsonl"
$PatternsFile = "C:\scripts\agentidentity\state\clickup-learned-patterns.json"
$PredictionModelFile = "C:\scripts\agentidentity\state\clickup-prediction-model.json"

# Extract learnings from completed task
function Get-TaskLearnings {
    param($TaskId, $TaskData)

    $learnings = @{
        TaskId = $TaskId
        Timestamp = [DateTime]::UtcNow.ToString('o')
        TaskType = $TaskData.type
        Complexity = $TaskData.complexity
        PredictedHours = $TaskData.predicted_hours
        ActualHours = $TaskData.actual_hours
        Quality = $TaskData.quality
        Outcome = $TaskData.outcome  # success, partial, failure
        Decisions = $TaskData.decisions
        Blockers = $TaskData.blockers
        SuccessFactors = @()
        FailureFactors = @()
    }

    # Analyze what led to success
    if ($TaskData.outcome -eq 'success') {
        if ($TaskData.predicted_hours -and $TaskData.actual_hours) {
            $accuracy = 1 - [Math]::Abs($TaskData.predicted_hours - $TaskData.actual_hours) / $TaskData.predicted_hours
            if ($accuracy -gt 0.8) {
                $learnings.SuccessFactors += 'accurate_prediction'
            }
        }

        if ($TaskData.clarity_score -gt 0.8) {
            $learnings.SuccessFactors += 'clear_requirements'
        }

        if ($TaskData.blockers.Count -eq 0) {
            $learnings.SuccessFactors += 'no_blockers'
        }
    }

    # Analyze what led to failure/issues
    if ($TaskData.outcome -ne 'success') {
        if ($TaskData.clarity_score -lt 0.5) {
            $learnings.FailureFactors += 'unclear_requirements'
        }

        if ($TaskData.blockers.Count -gt 2) {
            $learnings.FailureFactors += 'multiple_blockers'
        }

        if ($TaskData.scope_creep) {
            $learnings.FailureFactors += 'scope_creep'
        }
    }

    # Save to outcomes log
    $learnings | ConvertTo-Json -Compress | Add-Content -Path $OutcomesFile

    return $learnings
}

# Extract patterns from historical outcomes
function Get-ExtractedPatterns {
    if (-not (Test-Path $OutcomesFile)) {
        return @{
            Patterns = @()
            LastExtraction = [DateTime]::UtcNow.ToString('o')
        }
    }

    $outcomes = Get-Content $OutcomesFile | ForEach-Object { $_ | ConvertFrom-Json }

    $patterns = @()

    # Pattern: Task types with high success rate
    $byType = $outcomes | Group-Object TaskType
    foreach ($group in $byType) {
        $successRate = ($group.Group | Where-Object { $_.Outcome -eq 'success' }).Count / $group.Count

        if ($successRate -gt 0.8) {
            $patterns += @{
                Type = 'high_success_task_type'
                TaskType = $group.Name
                SuccessRate = $successRate
                Count = $group.Count
                Confidence = if ($group.Count -gt 10) { 'high' } else { 'medium' }
            }
        }
    }

    # Pattern: Common blockers
    $allBlockers = $outcomes | Where-Object { $_.Blockers.Count -gt 0 } | ForEach-Object { $_.Blockers }
    $blockerGroups = $allBlockers | Group-Object | Sort-Object Count -Descending | Select-Object -First 5

    foreach ($blocker in $blockerGroups) {
        $patterns += @{
            Type = 'common_blocker'
            Blocker = $blocker.Name
            Frequency = $blocker.Count
            ImpactTasks = $blocker.Count / $outcomes.Count
        }
    }

    # Pattern: Success factors correlation
    $allSuccessFactors = $outcomes | Where-Object { $_.Outcome -eq 'success' } | ForEach-Object { $_.SuccessFactors }
    $factorGroups = $allSuccessFactors | Group-Object | Sort-Object Count -Descending

    foreach ($factor in $factorGroups) {
        $patterns += @{
            Type = 'success_factor'
            Factor = $factor.Name
            Frequency = $factor.Count
            Correlation = $factor.Count / ($outcomes | Where-Object { $_.Outcome -eq 'success' }).Count
        }
    }

    return @{
        Patterns = $patterns
        LastExtraction = [DateTime]::UtcNow.ToString('o')
        TasksAnalyzed = $outcomes.Count
    }
}

# Update prediction model coefficients
function Update-PredictionModel {
    if (-not (Test-Path $OutcomesFile)) {
        Write-Warning "No outcomes to learn from yet"
        return
    }

    $outcomes = Get-Content $OutcomesFile | ForEach-Object { $_ | ConvertFrom-Json }

    # Calculate coefficients by task type
    $byType = $outcomes | Group-Object TaskType

    $model = @{
        LastUpdated = [DateTime]::UtcNow.ToString('o')
        TasksAnalyzed = $outcomes.Count
        Coefficients = @{}
    }

    foreach ($group in $byType) {
        $validTasks = $group.Group | Where-Object { $_.PredictedHours -and $_.ActualHours }

        if ($validTasks.Count -gt 0) {
            $avgPredicted = ($validTasks | Measure-Object -Property PredictedHours -Average).Average
            $avgActual = ($validTasks | Measure-Object -Property ActualHours -Average).Average

            $coefficient = if ($avgPredicted -gt 0) { $avgActual / $avgPredicted } else { 1.0 }

            # Calculate accuracy
            $errors = $validTasks | ForEach-Object {
                [Math]::Abs($_.PredictedHours - $_.ActualHours) / $_.PredictedHours
            }
            $avgAccuracy = 1 - (($errors | Measure-Object -Average).Average)

            $model.Coefficients[$group.Name] = @{
                Coefficient = $coefficient
                Accuracy = $avgAccuracy
                SampleSize = $validTasks.Count
            }
        }
    }

    # Save model
    $model | ConvertTo-Json -Depth 10 | Set-Content $PredictionModelFile

    Write-Host "[Learning Engine] Updated prediction model with $($model.Coefficients.Count) task types"
    return $model
}

# Predict task scope using learned model
function Get-ScopePrediction {
    param($TaskType, $Complexity, $BaseEstimate)

    # Load model
    if (Test-Path $PredictionModelFile) {
        $model = Get-Content $PredictionModelFile -Raw | ConvertFrom-Json
    }
    else {
        # No model yet, use base estimate
        return @{
            PredictedHours = $BaseEstimate
            Confidence = 0.3
            Method = 'base_estimate'
        }
    }

    # Apply coefficient if available
    $coefficient = 1.0
    $accuracy = 0.5

    if ($model.Coefficients.PSObject.Properties[$TaskType]) {
        $typeData = $model.Coefficients.$TaskType
        $coefficient = $typeData.Coefficient
        $accuracy = $typeData.Accuracy
    }

    # Adjust for complexity
    $complexityMultiplier = switch ($Complexity) {
        { $_ -le 3 } { 0.8 }
        { $_ -le 6 } { 1.0 }
        { $_ -le 8 } { 1.3 }
        default { 1.8 }
    }

    $predicted = $BaseEstimate * $coefficient * $complexityMultiplier

    return @{
        PredictedHours = [Math]::Round($predicted, 1)
        Confidence = $accuracy
        Method = 'learned_model'
        Coefficient = $coefficient
        ComplexityMultiplier = $complexityMultiplier
    }
}

# Get all learnings summary
function Get-AllLearnings {
    $patterns = Get-ExtractedPatterns
    $model = if (Test-Path $PredictionModelFile) {
        Get-Content $PredictionModelFile -Raw | ConvertFrom-Json
    } else { $null }

    $outcomes = if (Test-Path $OutcomesFile) {
        Get-Content $OutcomesFile | ForEach-Object { $_ | ConvertFrom-Json }
    } else { @() }

    Write-Host "`n=== LEARNING ENGINE SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Tasks Completed: $($outcomes.Count)"
    Write-Host "Patterns Extracted: $($patterns.Patterns.Count)"

    if ($model) {
        Write-Host "Prediction Model: $($model.Coefficients.Count) task types"
        Write-Host "Avg Accuracy: $([Math]::Round((($model.Coefficients.PSObject.Properties.Value | Measure-Object -Property Accuracy -Average).Average * 100), 1))%"
    }

    Write-Host "`nTop Success Factors:"
    $patterns.Patterns | Where-Object { $_.Type -eq 'success_factor' } | Select-Object -First 3 | ForEach-Object {
        Write-Host "  - $($_.Factor): $([Math]::Round($_.Correlation * 100, 0))% correlation"
    }

    Write-Host "`nCommon Blockers:"
    $patterns.Patterns | Where-Object { $_.Type -eq 'common_blocker' } | Select-Object -First 3 | ForEach-Object {
        Write-Host "  - $($_.Blocker): $($_.Frequency) occurrences"
    }

    Write-Host "==============================`n"
}

# Execute action
switch ($Action) {
    'ExtractPattern' {
        if (-not $TaskId -or -not $TaskData) {
            throw "TaskId and TaskData required for ExtractPattern"
        }
        $learnings = Get-TaskLearnings -TaskId $TaskId -TaskData $TaskData
        $learnings | ConvertTo-Json -Depth 10
    }

    'UpdateModel' {
        $model = Update-PredictionModel
        $model | ConvertTo-Json -Depth 10
    }

    'PredictScope' {
        if (-not $TaskType) {
            throw "TaskType required for PredictScope"
        }
        $prediction = Get-ScopePrediction -TaskType $TaskType -Complexity $TaskData.complexity -BaseEstimate $TaskData.base_estimate
        $prediction | ConvertTo-Json -Depth 10
    }

    'GetLearnings' {
        Get-AllLearnings
    }
}
