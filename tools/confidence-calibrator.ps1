# confidence-calibrator.ps1
# Learn when I'm over-confident or under-confident by tracking predictions vs outcomes

param(
    [ValidateSet('predict', 'outcome', 'calibrate', 'report')]
    [string]$Action = 'report',

    [string]$PredictionId,
    [string]$Prediction,
    [int]$ConfidencePercent,
    [bool]$ActualOutcome,
    [string]$WhatHappened
)

$calibratorPath = "C:\scripts\agentidentity\state\confidence-calibration.yaml"

if (-not (Test-Path $calibratorPath)) {
    @{
        predictions = @()
        calibration_data = @{
            overconfident_count = 0
            underconfident_count = 0
            well_calibrated_count = 0
            calibration_score = 0.0
        }
        metadata = @{
            created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        }
    } | ConvertTo-Yaml | Out-File -FilePath $calibratorPath -Encoding UTF8
}

$data = Get-Content $calibratorPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'predict' {
        if (-not $PredictionId -or -not $Prediction -or $ConfidencePercent -eq 0) {
            Write-Host "❌ Error: -PredictionId, -Prediction, and -ConfidencePercent required" -ForegroundColor Red
            return
        }

        $pred = @{
            id = $PredictionId
            prediction = $Prediction
            confidence_percent = $ConfidencePercent
            predicted_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            status = "pending"
        }

        $data.predictions += $pred
        $data | ConvertTo-Yaml | Out-File -FilePath $calibratorPath -Encoding UTF8

        Write-Host "✅ Prediction logged: $Prediction ($ConfidencePercent% confident)" -ForegroundColor Cyan
    }

    'outcome' {
        if (-not $PredictionId) {
            Write-Host "❌ Error: -PredictionId required" -ForegroundColor Red
            return
        }

        $pred = $data.predictions | Where-Object { $_.id -eq $PredictionId }
        if (-not $pred) {
            Write-Host "❌ Error: Prediction '$PredictionId' not found" -ForegroundColor Red
            return
        }

        $pred.actual_outcome = $ActualOutcome
        $pred.what_happened = $WhatHappened
        $pred.outcome_recorded_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $pred.status = "completed"

        # Determine calibration quality
        $wasCorrect = $ActualOutcome
        $confidence = $pred.confidence_percent

        if ($wasCorrect -and $confidence -gt 80) {
            $pred.calibration = "well_calibrated"
            $data.calibration_data.well_calibrated_count++
        } elseif ($wasCorrect -and $confidence -lt 50) {
            $pred.calibration = "underconfident"
            $data.calibration_data.underconfident_count++
        } elseif (-not $wasCorrect -and $confidence -gt 70) {
            $pred.calibration = "overconfident"
            $data.calibration_data.overconfident_count++
        } elseif (-not $wasCorrect -and $confidence -lt 50) {
            $pred.calibration = "well_calibrated"
            $data.calibration_data.well_calibrated_count++
        } else {
            $pred.calibration = "reasonable"
            $data.calibration_data.well_calibrated_count++
        }

        $data | ConvertTo-Yaml | Out-File -FilePath $calibratorPath -Encoding UTF8

        $color = switch ($pred.calibration) {
            'overconfident' { "Red" }
            'underconfident' { "Yellow" }
            default { "Green" }
        }

        Write-Host "📊 Calibration: " -NoNewline -ForegroundColor Gray
        Write-Host $pred.calibration -ForegroundColor $color
        Write-Host "   Predicted: $($pred.confidence_percent)% confident" -ForegroundColor Gray
        Write-Host "   Actual: $($if ($ActualOutcome) { 'Correct' } else { 'Incorrect' })" -ForegroundColor Gray
    }

    'calibrate' {
        $completed = $data.predictions | Where-Object { $_.status -eq "completed" }

        if ($completed.Count -lt 5) {
            Write-Host "⚠️  Need at least 5 completed predictions for calibration" -ForegroundColor Yellow
            return
        }

        # Calculate calibration score
        $total = $completed.Count
        $overconfident = $data.calibration_data.overconfident_count
        $underconfident = $data.calibration_data.underconfident_count
        $wellCalibrated = $data.calibration_data.well_calibrated_count

        $calibrationScore = [Math]::Round(($wellCalibrated / $total) * 100, 1)
        $data.calibration_data.calibration_score = $calibrationScore

        $data | ConvertTo-Yaml | Out-File -FilePath $calibratorPath -Encoding UTF8

        Write-Host "`n📊 CALIBRATION ANALYSIS" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "Total Predictions: $total" -ForegroundColor White
        Write-Host "Well Calibrated: " -NoNewline -ForegroundColor Gray
        Write-Host "$wellCalibrated ($([Math]::Round(($wellCalibrated/$total)*100,1))%)" -ForegroundColor Green
        Write-Host "Overconfident: " -NoNewline -ForegroundColor Gray
        Write-Host "$overconfident ($([Math]::Round(($overconfident/$total)*100,1))%)" -ForegroundColor Red
        Write-Host "Underconfident: " -NoNewline -ForegroundColor Gray
        Write-Host "$underconfident ($([Math]::Round(($underconfident/$total)*100,1))%)" -ForegroundColor Yellow

        Write-Host "`nCalibration Score: " -NoNewline -ForegroundColor Gray
        $scoreColor = if ($calibrationScore -gt 80) { "Green" } elseif ($calibrationScore -gt 60) { "Yellow" } else { "Red" }
        Write-Host "$calibrationScore%" -ForegroundColor $scoreColor

        if ($overconfident -gt $underconfident) {
            Write-Host "`n💡 Recommendation: Lower confidence estimates" -ForegroundColor Yellow
        } elseif ($underconfident -gt $overconfident) {
            Write-Host "`n💡 Recommendation: Increase confidence estimates" -ForegroundColor Cyan
        } else {
            Write-Host "`n✅ Calibration is balanced" -ForegroundColor Green
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    }

    'report' {
        $completed = $data.predictions | Where-Object { $_.status -eq "completed" }
        $pending = $data.predictions | Where-Object { $_.status -eq "pending" }

        Write-Host "`n📊 CONFIDENCE CALIBRATION REPORT" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "Completed: $($completed.Count)" -ForegroundColor White
        Write-Host "Pending: $($pending.Count)" -ForegroundColor Gray

        if ($completed.Count -gt 0) {
            Write-Host "`nCalibration Score: " -NoNewline -ForegroundColor Gray
            $score = $data.calibration_data.calibration_score
            $scoreColor = if ($score -gt 80) { "Green" } elseif ($score -gt 60) { "Yellow" } else { "Red" }
            Write-Host "$score%" -ForegroundColor $scoreColor

            Write-Host "`nRecent Predictions:" -ForegroundColor Cyan
            foreach ($pred in ($completed | Select-Object -Last 5)) {
                $symbol = switch ($pred.calibration) {
                    'overconfident' { "📈" }
                    'underconfident' { "📉" }
                    default { "✅" }
                }
                Write-Host "  $symbol " -NoNewline
                Write-Host "$($pred.prediction) " -NoNewline -ForegroundColor White
                Write-Host "($($pred.confidence_percent)% → $($if($pred.actual_outcome){'✓'}else{'✗'}))" -ForegroundColor Gray
            }
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    }
}
