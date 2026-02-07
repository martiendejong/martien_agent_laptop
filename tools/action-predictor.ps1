#!/usr/bin/env pwsh
# action-predictor.ps1 - Predict next likely action based on current context
# Phase 1: Embedded Learning Architecture v2
# Uses trained model to anticipate what comes next

param(
    [Parameter(Mandatory=$false)]
    [string]$SessionLogPath = "C:\scripts\_machine\current-session-log.jsonl",

    [Parameter(Mandatory=$false)]
    [string]$ModelPath = "C:\scripts\_machine\prediction-model.json",

    [Parameter(Mandatory=$false)]
    [int]$ContextWindow = 3,

    [Parameter(Mandatory=$false)]
    [double]$MinConfidence = 0.6,

    [Parameter(Mandatory=$false)]
    [switch]$AutoSuggest = $false
)

if (-not (Test-Path $ModelPath)) {
    Write-Verbose "No prediction model found. Run predictive-engine.ps1 -Train first."
    exit 0
}

if (-not (Test-Path $SessionLogPath)) {
    Write-Verbose "No session log found"
    exit 0
}

# Load model
$model = Get-Content $ModelPath | ConvertFrom-Json

if ($model.sequences.Count -eq 0) {
    Write-Verbose "Prediction model is empty"
    exit 0
}

# Load current session log
$logEntries = Get-Content $SessionLogPath | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
    $_ | ConvertFrom-Json
}

if ($logEntries.Count -eq 0) {
    Write-Verbose "Session log empty"
    exit 0
}

# Get recent actions for context
$recentActions = $logEntries | Select-Object -Last $ContextWindow | Select-Object -ExpandProperty action

# Try to find matching patterns in model
$predictions = @()

for ($i = $recentActions.Count - 1; $i -ge 0; $i--) {
    $context = $recentActions[$i..($recentActions.Count - 1)] -join " → "

    if ($model.sequences.PSObject.Properties.Name -contains $context) {
        $nextActions = $model.sequences.$context

        foreach ($action in $nextActions.PSObject.Properties.Name) {
            $probability = $nextActions.$action.probability

            if ($probability -ge $MinConfidence) {
                $predictions += [PSCustomObject]@{
                    Context = $context
                    NextAction = $action
                    Probability = $probability
                    Count = $nextActions.$action.count
                }
            }
        }

        # Found a match, no need to check shorter contexts
        if ($predictions.Count -gt 0) {
            break
        }
    }
}

if ($predictions.Count -eq 0) {
    Write-Verbose "No predictions available for current context"
    exit 0
}

# Sort by probability
$predictions = $predictions | Sort-Object Probability -Descending

Write-Host ""
Write-Host "🔮 PREDICTED NEXT ACTIONS" -ForegroundColor Magenta
Write-Host "=========================" -ForegroundColor Magenta
Write-Host ""

Write-Host "Current context: $($predictions[0].Context)" -ForegroundColor Yellow
Write-Host ""

foreach ($prediction in $predictions) {
    $confidencePct = [Math]::Round($prediction.Probability * 100, 1)
    $color = if ($prediction.Probability -ge 0.8) { "Green" } elseif ($prediction.Probability -ge 0.7) { "Yellow" } else { "Gray" }

    Write-Host "[$confidencePct%] Next: $($prediction.NextAction)" -ForegroundColor $color
    Write-Host "       Based on $($prediction.Count) historical occurrences" -ForegroundColor DarkGray

    if ($AutoSuggest -and $prediction.Probability -ge 0.8) {
        Write-Host "       💡 Auto-suggest: Proactively prepare for this action" -ForegroundColor Cyan
    }

    Write-Host ""
}

# Return predictions for programmatic use
return $predictions
