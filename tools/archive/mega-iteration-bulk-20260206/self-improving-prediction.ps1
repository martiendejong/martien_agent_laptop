# Self-Improving Prediction Loop (R21-001)
# Tracks prediction accuracy and auto-adjusts weights

param(
    [switch]$Analyze,
    [switch]$UpdateWeights,
    [switch]$Report
)

$PredictionLogPath = "C:\scripts\_machine\prediction-accuracy.jsonl"
$WeightsPath = "C:\scripts\_machine\prediction-weights.yaml"

function Initialize-PredictionTracking {
    if (!(Test-Path $PredictionLogPath)) {
        New-Item -Path $PredictionLogPath -ItemType File -Force | Out-Null
    }
    if (!(Test-Path $WeightsPath)) {
        @"
# Prediction Weights (Auto-Adjusted)
# Updated by self-improving-prediction.ps1

weights:
  time_of_day: 1.0
  recent_files: 1.5
  conversation_intent: 1.2
  markov_chain: 1.0
  project_context: 1.3
  semantic_similarity: 1.1

meta:
  last_updated: "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  total_predictions: 0
  correct_predictions: 0
  accuracy: 0.0
"@ | Out-File -FilePath $WeightsPath -Encoding UTF8
    }
}

function Log-Prediction {
    param(
        [string]$Method,
        [string]$PredictedContext,
        [string]$ActualContext,
        [bool]$Correct
    )

    $entry = @{
        timestamp = Get-Date -Format 'o'
        method = $Method
        predicted = $PredictedContext
        actual = $ActualContext
        correct = $Correct
    } | ConvertTo-Json -Compress

    Add-Content -Path $PredictionLogPath -Value $entry
}

function Get-PredictionAccuracy {
    if (!(Test-Path $PredictionLogPath)) {
        return @{ total = 0; correct = 0; accuracy = 0.0; by_method = @{} }
    }

    $predictions = Get-Content $PredictionLogPath | ForEach-Object { $_ | ConvertFrom-Json }
    $total = $predictions.Count
    $correct = ($predictions | Where-Object { $_.correct -eq $true }).Count

    $byMethod = $predictions | Group-Object -Property method | ForEach-Object {
        $methodTotal = $_.Count
        $methodCorrect = ($_.Group | Where-Object { $_.correct -eq $true }).Count
        @{
            method = $_.Name
            total = $methodTotal
            correct = $methodCorrect
            accuracy = if ($methodTotal -gt 0) { [math]::Round($methodCorrect / $methodTotal, 3) } else { 0.0 }
        }
    }

    return @{
        total = $total
        correct = $correct
        accuracy = if ($total -gt 0) { [math]::Round($correct / $total, 3) } else { 0.0 }
        by_method = $byMethod
    }
}

function Update-PredictionWeights {
    $stats = Get-PredictionAccuracy

    if ($stats.total -lt 10) {
        Write-Host "Not enough data yet ($($stats.total) predictions). Need at least 10."
        return
    }

    $weights = Get-Content $WeightsPath | ConvertFrom-Yaml

    # Adjust weights based on method accuracy
    foreach ($method in $stats.by_method) {
        $methodName = $method.method
        $accuracy = $method.accuracy

        # Map method names to weight keys
        $weightKey = switch -Regex ($methodName) {
            "time" { "time_of_day" }
            "recent" { "recent_files" }
            "intent" { "conversation_intent" }
            "markov" { "markov_chain" }
            "project" { "project_context" }
            "semantic" { "semantic_similarity" }
            default { $null }
        }

        if ($weightKey -and $weights.weights.ContainsKey($weightKey)) {
            $oldWeight = $weights.weights[$weightKey]
            # Increase weight if accuracy > 0.7, decrease if < 0.5
            $adjustment = if ($accuracy -gt 0.7) { 1.1 } elseif ($accuracy -lt 0.5) { 0.9 } else { 1.0 }
            $newWeight = [math]::Round($oldWeight * $adjustment, 2)
            $weights.weights[$weightKey] = $newWeight

            Write-Host "[$weightKey] $oldWeight -> $newWeight (accuracy: $accuracy)"
        }
    }

    # Update metadata
    $weights.meta.last_updated = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $weights.meta.total_predictions = $stats.total
    $weights.meta.correct_predictions = $stats.correct
    $weights.meta.accuracy = $stats.accuracy

    # Save updated weights
    $weights | ConvertTo-Yaml | Out-File -FilePath $WeightsPath -Encoding UTF8

    Write-Host "`nWeights updated! Overall accuracy: $($stats.accuracy)"
}

function Show-Report {
    $stats = Get-PredictionAccuracy

    Write-Host "`n=== Prediction System Report ===" -ForegroundColor Cyan
    Write-Host "Total Predictions: $($stats.total)"
    Write-Host "Correct: $($stats.correct)"
    Write-Host "Overall Accuracy: $($stats.accuracy * 100)%`n"

    if ($stats.by_method) {
        Write-Host "By Method:" -ForegroundColor Yellow
        $stats.by_method | ForEach-Object {
            $pct = [math]::Round($_.accuracy * 100, 1)
            Write-Host "  $($_.method): $pct% ($($_.correct)/$($_.total))"
        }
    }

    Write-Host "`nCurrent Weights:" -ForegroundColor Yellow
    if (Test-Path $WeightsPath) {
        Get-Content $WeightsPath | Select-String -Pattern "^\s+\w+:" | ForEach-Object {
            Write-Host "  $_"
        }
    }
}

# Main execution
Initialize-PredictionTracking

if ($Analyze) {
    $stats = Get-PredictionAccuracy
    $stats | ConvertTo-Json -Depth 3
}
elseif ($UpdateWeights) {
    Update-PredictionWeights
}
elseif ($Report) {
    Show-Report
}
else {
    Write-Host "Usage: self-improving-prediction.ps1 [-Analyze] [-UpdateWeights] [-Report]"
    Write-Host "  -Analyze        : Show accuracy statistics (JSON)"
    Write-Host "  -UpdateWeights  : Auto-adjust weights based on accuracy"
    Write-Host "  -Report         : Human-readable report"
}
