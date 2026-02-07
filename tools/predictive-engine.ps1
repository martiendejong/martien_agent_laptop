#!/usr/bin/env pwsh
# predictive-engine.ps1 - Learn action sequences and predict next likely action
# Phase 1: Embedded Learning Architecture v2
# Builds probability model from historical session logs

<#
.SYNOPSIS
    !/usr/bin/env pwsh

.DESCRIPTION
    !/usr/bin/env pwsh

.NOTES
    File: predictive-engine.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$false)]

$ErrorActionPreference = "Stop"
    [string]$SessionLogsPath = "C:\scripts\_machine\session-logs",

    [Parameter(Mandatory=$false)]
    [string]$ModelOutputPath = "C:\scripts\_machine\prediction-model.json",

    [Parameter(Mandatory=$false)]
    [int]$MinSequenceLength = 2,

    [Parameter(Mandatory=$false)]
    [int]$MaxSequenceLength = 5,

    [Parameter(Mandatory=$false)]
    [double]$MinConfidence = 0.5,

    [Parameter(Mandatory=$false)]
    [switch]$Train = $false,

    [Parameter(Mandatory=$false)]
    [switch]$ShowModel = $false
)

# Load or initialize prediction model
if (Test-Path $ModelOutputPath) {
    $model = Get-Content $ModelOutputPath | ConvertFrom-Json
} else {
    $model = @{
        sequences = @{}
        metadata = @{
            trained_on = 0
            last_updated = $null
        }
    }
}

if ($Train) {
    Write-Host "ðŸ§  TRAINING PREDICTIVE MODEL" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    Write-Host ""

    if (-not (Test-Path $SessionLogsPath)) {
        Write-Host "âŒ Session logs directory not found: $SessionLogsPath" -ForegroundColor Red
        exit 1
    }

    # Load all historical session logs
    $sessionFiles = Get-ChildItem -Path $SessionLogsPath -Filter "*.jsonl" | Sort-Object LastWriteTime -Descending

    if ($sessionFiles.Count -eq 0) {
        Write-Host "âŒ No session logs found in $SessionLogsPath" -ForegroundColor Red
        exit 1
    }

    Write-Host "Found $($sessionFiles.Count) session logs" -ForegroundColor Gray
    Write-Host ""

    $sequenceCounts = @{}
    $totalSessions = 0

    foreach ($sessionFile in $sessionFiles) {
        $totalSessions++

        # Load session log
        $logEntries = Get-Content $sessionFile.FullName | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
            $_ | ConvertFrom-Json
        }

        if ($logEntries.Count -lt $MinSequenceLength) {
            continue
        }

        # Extract action sequences
        for ($i = 0; $i -lt $logEntries.Count - $MinSequenceLength + 1; $i++) {
            for ($seqLen = $MinSequenceLength; $seqLen -le [Math]::Min($MaxSequenceLength, $logEntries.Count - $i); $seqLen++) {
                $sequence = @()
                for ($j = 0; $j -lt $seqLen; $j++) {
                    $sequence += $logEntries[$i + $j].action
                }

                $seqKey = $sequence -join " â†’ "

                if (-not $sequenceCounts.ContainsKey($seqKey)) {
                    $sequenceCounts[$seqKey] = 0
                }
                $sequenceCounts[$seqKey]++
            }
        }
    }

    # Build probability model
    Write-Host "Building probability model..." -ForegroundColor Yellow

    $predictions = @{}

    foreach ($seqKey in $sequenceCounts.Keys) {
        $sequence = $seqKey -split " â†’ "

        if ($sequence.Count -lt 2) {
            continue
        }

        # Pattern: [A, B, C] â†’ Predict D
        # Context: [A, B, C]
        # Next: D

        $contextLength = $sequence.Count - 1
        $context = $sequence[0..($contextLength - 1)] -join " â†’ "
        $nextAction = $sequence[-1]

        if (-not $predictions.ContainsKey($context)) {
            $predictions[$context] = @{}
        }

        if (-not $predictions[$context].ContainsKey($nextAction)) {
            $predictions[$context][$nextAction] = 0
        }

        $predictions[$context][$nextAction] += $sequenceCounts[$seqKey]
    }

    # Calculate probabilities
    $model.sequences = @{}

    foreach ($context in $predictions.Keys) {
        $total = ($predictions[$context].Values | Measure-Object -Sum).Sum
        $nextActions = @{}

        foreach ($action in $predictions[$context].Keys) {
            $count = $predictions[$context][$action]
            $probability = [Math]::Round($count / $total, 3)

            if ($probability -ge $MinConfidence) {
                $nextActions[$action] = @{
                    probability = $probability
                    count = $count
                }
            }
        }

        if ($nextActions.Count -gt 0) {
            $model.sequences[$context] = $nextActions
        }
    }

    $model.metadata = @{
        trained_on = $totalSessions
        last_updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        total_patterns = $model.sequences.Count
    }

    # Save model
    $model | ConvertTo-Json -Depth 10 | Out-File -FilePath $ModelOutputPath -Encoding utf8

    Write-Host ""
    Write-Host "âœ… Training complete" -ForegroundColor Green
    Write-Host "   Sessions analyzed: $totalSessions" -ForegroundColor Gray
    Write-Host "   Patterns learned: $($model.sequences.Count)" -ForegroundColor Gray
    Write-Host "   Model saved: $ModelOutputPath" -ForegroundColor Gray
    Write-Host ""
}

if ($ShowModel) {
    Write-Host ""
    Write-Host "ðŸ“Š PREDICTION MODEL" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host ""

    if ($model.sequences.Count -eq 0) {
        Write-Host "âŒ Model is empty. Run with -Train to build model." -ForegroundColor Red
        exit 0
    }

    Write-Host "Metadata:" -ForegroundColor Yellow
    Write-Host "   Trained on: $($model.metadata.trained_on) sessions" -ForegroundColor Gray
    Write-Host "   Last updated: $($model.metadata.last_updated)" -ForegroundColor Gray
    Write-Host "   Total patterns: $($model.metadata.total_patterns)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Top Predictions (sorted by confidence):" -ForegroundColor Yellow
    Write-Host ""

    $sortedPatterns = $model.sequences.GetEnumerator() | ForEach-Object {
        $context = $_.Key
        $predictions = $_.Value

        foreach ($action in $predictions.Keys) {
            [PSCustomObject]@{
                Context = $context
                NextAction = $action
                Probability = $predictions[$action].probability
                Count = $predictions[$action].count
            }
        }
    } | Sort-Object Probability -Descending | Select-Object -First 20

    foreach ($pattern in $sortedPatterns) {
        $confidencePct = [Math]::Round($pattern.Probability * 100, 1)
        $color = if ($pattern.Probability -ge 0.8) { "Green" } elseif ($pattern.Probability -ge 0.6) { "Yellow" } else { "Gray" }

        Write-Host "[$confidencePct%] $($pattern.Context) â†’ $($pattern.NextAction)" -ForegroundColor $color
        Write-Host "       Seen $($pattern.Count) times" -ForegroundColor DarkGray
        Write-Host ""
    }
}

# Return model for programmatic use
return $model
