<#
.SYNOPSIS
    Track predictions to measure and improve accuracy
.DESCRIPTION
    Log predictions about outcomes, then track whether they were accurate.
    Improves calibration and anticipation over time.
.EXAMPLE
    .\track-prediction.ps1 -Prediction "This PR will need revisions" -Confidence 70 -Category code
    .\track-prediction.ps1 -Resolve -Id 1 -Outcome "correct"
.NOTES
    Created: 2026-01-29
    Author: Jengo (self-improvement)
#>

param(
    [string]$Prediction,
    [int]$Confidence = 50,
    [ValidateSet("code", "user", "system", "other")]
    [string]$Category = "other",

    [switch]$Resolve,
    [int]$Id,
    [ValidateSet("correct", "incorrect", "partial")]
    [string]$Outcome,

    [switch]$Report
)

$predictionsPath = "C:\scripts\agentidentity\state\predictions.json"

# Initialize file if needed
if (-not (Test-Path $predictionsPath)) {
    @{
        predictions = @()
        stats = @{
            total = 0
            correct = 0
            incorrect = 0
            partial = 0
        }
    } | ConvertTo-Json -Depth 10 | Set-Content $predictionsPath -Encoding UTF8
}

$data = Get-Content $predictionsPath -Raw | ConvertFrom-Json

if ($Report) {
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "  PREDICTION ACCURACY REPORT" -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host ""

    $stats = $data.stats
    $total = $stats.total
    if ($total -gt 0) {
        $accuracy = [math]::Round(($stats.correct / $total) * 100, 1)
        Write-Host "  Total predictions: $total" -ForegroundColor White
        Write-Host "  Correct: $($stats.correct)" -ForegroundColor Green
        Write-Host "  Incorrect: $($stats.incorrect)" -ForegroundColor Red
        Write-Host "  Partial: $($stats.partial)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Accuracy: $accuracy%" -ForegroundColor Cyan
    } else {
        Write-Host "  No predictions tracked yet" -ForegroundColor Gray
    }

    # Show recent predictions
    $recent = $data.predictions | Select-Object -Last 5
    if ($recent.Count -gt 0) {
        Write-Host ""
        Write-Host "  Recent predictions:" -ForegroundColor White
        foreach ($p in $recent) {
            $status = if ($p.resolved) { "[$($p.outcome)]" } else { "[pending]" }
            Write-Host "    $($p.id): $($p.prediction) - $status" -ForegroundColor Gray
        }
    }

    Write-Host ""
    return
}

if ($Resolve) {
    # Find and resolve prediction
    $pred = $data.predictions | Where-Object { $_.id -eq $Id }
    if ($pred) {
        $pred.resolved = $true
        $pred.outcome = $Outcome
        $pred.resolved_date = (Get-Date -Format "yyyy-MM-dd HH:mm")

        # Update stats
        $data.stats.$Outcome++

        $data | ConvertTo-Json -Depth 10 | Set-Content $predictionsPath -Encoding UTF8

        Write-Host ""
        Write-Host "Prediction resolved: $Outcome" -ForegroundColor Green
        Write-Host "  $($pred.prediction)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "Prediction $Id not found" -ForegroundColor Red
    }
    return
}

if ($Prediction) {
    # Add new prediction
    $newId = ($data.predictions | Measure-Object -Property id -Maximum).Maximum + 1
    if (-not $newId) { $newId = 1 }

    $newPred = @{
        id = $newId
        prediction = $Prediction
        confidence = $Confidence
        category = $Category
        date = (Get-Date -Format "yyyy-MM-dd HH:mm")
        resolved = $false
        outcome = $null
    }

    $data.predictions += $newPred
    $data.stats.total++

    $data | ConvertTo-Json -Depth 10 | Set-Content $predictionsPath -Encoding UTF8

    Write-Host ""
    Write-Host "Prediction tracked (ID: $newId)" -ForegroundColor Green
    Write-Host "  $Prediction" -ForegroundColor White
    Write-Host "  Confidence: $Confidence%" -ForegroundColor Gray
    Write-Host ""
}
