# performance-baseline-tracker.ps1
# Track predicted vs actual performance gains from optimizations

param(
    [ValidateSet('predict', 'actual', 'compare', 'report')]
    [string]$Action = 'report',

    [string]$OptimizationId,
    [string]$Description,
    [int]$PredictedGainMs,
    [int]$ActualGainMs,
    [double]$ImplementationHours
)

$trackerPath = "C:\scripts\agentidentity\state\performance-baselines.yaml"

# Initialize if doesn't exist
if (-not (Test-Path $trackerPath)) {
    @{
        optimizations = @()
        metadata = @{
            created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            total_optimizations = 0
            prediction_accuracy = 0.0
        }
    } | ConvertTo-Yaml | Out-File -FilePath $trackerPath -Encoding UTF8
}

# Read current data
$data = Get-Content $trackerPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'predict' {
        if (-not $OptimizationId -or -not $Description -or $PredictedGainMs -le 0) {
            Write-Host "❌ Error: -OptimizationId, -Description, and -PredictedGainMs required" -ForegroundColor Red
            return
        }

        $optimization = @{
            id = $OptimizationId
            description = $Description
            predicted_gain_ms = $PredictedGainMs
            predicted_at = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            implementation_hours = $ImplementationHours
            status = "predicted"
        }

        $data.optimizations += $optimization
        $data | ConvertTo-Yaml | Out-File -FilePath $trackerPath -Encoding UTF8

        Write-Host "✅ Prediction logged for: $Description" -ForegroundColor Green
        Write-Host "   Predicted gain: ${PredictedGainMs}ms" -ForegroundColor Cyan
        Write-Host "   ID: $OptimizationId" -ForegroundColor DarkGray
    }

    'actual' {
        if (-not $OptimizationId -or $ActualGainMs -le 0) {
            Write-Host "❌ Error: -OptimizationId and -ActualGainMs required" -ForegroundColor Red
            return
        }

        $optimization = $data.optimizations | Where-Object { $_.id -eq $OptimizationId }
        if (-not $optimization) {
            Write-Host "❌ Error: Optimization ID '$OptimizationId' not found" -ForegroundColor Red
            return
        }

        $optimization.actual_gain_ms = $ActualGainMs
        $optimization.measured_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $optimization.status = "measured"

        # Calculate accuracy
        $predictedGain = $optimization.predicted_gain_ms
        $accuracyPct = [Math]::Round((1 - [Math]::Abs($ActualGainMs - $predictedGain) / $predictedGain) * 100, 1)
        $optimization.accuracy_pct = $accuracyPct

        $data | ConvertTo-Yaml | Out-File -FilePath $trackerPath -Encoding UTF8

        Write-Host "✅ Actual results logged for: $($optimization.description)" -ForegroundColor Green
        Write-Host "   Predicted: ${predictedGain}ms" -ForegroundColor Cyan
        Write-Host "   Actual: ${ActualGainMs}ms" -ForegroundColor Cyan
        Write-Host "   Accuracy: $accuracyPct%" -ForegroundColor $(if ($accuracyPct -gt 80) { "Green" } elseif ($accuracyPct -gt 50) { "Yellow" } else { "Red" })
    }

    'compare' {
        if (-not $OptimizationId) {
            Write-Host "❌ Error: -OptimizationId required" -ForegroundColor Red
            return
        }

        $optimization = $data.optimizations | Where-Object { $_.id -eq $OptimizationId }
        if (-not $optimization) {
            Write-Host "❌ Error: Optimization ID '$OptimizationId' not found" -ForegroundColor Red
            return
        }

        Write-Host "`n📊 OPTIMIZATION COMPARISON" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "Description: " -NoNewline -ForegroundColor Gray
        Write-Host $optimization.description -ForegroundColor White
        Write-Host "`nPredicted: " -NoNewline -ForegroundColor Gray
        Write-Host "$($optimization.predicted_gain_ms)ms" -ForegroundColor Cyan

        if ($optimization.status -eq "measured") {
            Write-Host "Actual: " -NoNewline -ForegroundColor Gray
            Write-Host "$($optimization.actual_gain_ms)ms" -ForegroundColor Cyan
            Write-Host "Accuracy: " -NoNewline -ForegroundColor Gray

            $accuracy = $optimization.accuracy_pct
            $color = if ($accuracy -gt 80) { "Green" } elseif ($accuracy -gt 50) { "Yellow" } else { "Red" }
            Write-Host "$accuracy%" -ForegroundColor $color

            $diff = $optimization.actual_gain_ms - $optimization.predicted_gain_ms
            if ($diff -gt 0) {
                Write-Host "`n✅ Better than predicted by ${diff}ms" -ForegroundColor Green
            } elseif ($diff -lt 0) {
                Write-Host "`n⚠️  Worse than predicted by $([Math]::Abs($diff))ms" -ForegroundColor Yellow
            } else {
                Write-Host "`n🎯 Exactly as predicted" -ForegroundColor Green
            }
        } else {
            Write-Host "Status: " -NoNewline -ForegroundColor Gray
            Write-Host "Not yet measured" -ForegroundColor Yellow
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    }

    'report' {
        $measured = $data.optimizations | Where-Object { $_.status -eq "measured" }
        $pending = $data.optimizations | Where-Object { $_.status -eq "predicted" }

        if ($measured.Count -eq 0) {
            Write-Host "`n📊 No measured optimizations yet" -ForegroundColor Yellow
            if ($pending.Count -gt 0) {
                Write-Host "   $($pending.Count) predictions pending measurement" -ForegroundColor Gray
            }
            return
        }

        $avgAccuracy = ($measured | Measure-Object -Property accuracy_pct -Average).Average

        Write-Host "`n📊 PERFORMANCE PREDICTION REPORT" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "Total Measured: " -NoNewline -ForegroundColor Gray
        Write-Host $measured.Count -ForegroundColor White
        Write-Host "Average Accuracy: " -NoNewline -ForegroundColor Gray

        $color = if ($avgAccuracy -gt 80) { "Green" } elseif ($avgAccuracy -gt 50) { "Yellow" } else { "Red" }
        Write-Host "$([Math]::Round($avgAccuracy, 1))%" -ForegroundColor $color

        Write-Host "`nRecent Optimizations:" -ForegroundColor Cyan
        foreach ($opt in ($measured | Select-Object -Last 5)) {
            Write-Host "  • " -NoNewline -ForegroundColor DarkGray
            Write-Host $opt.description -NoNewline -ForegroundColor White
            Write-Host " ($($opt.predicted_gain_ms)ms → $($opt.actual_gain_ms)ms, $($opt.accuracy_pct)%)" -ForegroundColor Gray
        }

        if ($pending.Count -gt 0) {
            Write-Host "`nPending Measurements:" -ForegroundColor Yellow
            foreach ($opt in $pending) {
                Write-Host "  • " -NoNewline -ForegroundColor DarkGray
                Write-Host "$($opt.description) " -NoNewline -ForegroundColor White
                Write-Host "[$($opt.id)]" -ForegroundColor DarkGray
            }
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host ""
    }
}
