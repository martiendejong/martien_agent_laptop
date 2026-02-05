# prediction-accuracy-tracker.ps1
# Track accuracy of predictions over time to improve future predictions

param(
    [ValidateSet('log', 'report', 'analyze')]
    [string]$Action = 'report',

    [string]$Domain,
    [string]$Prediction,
    [bool]$WasAccurate,
    [string]$WhyWrong
)

$trackerPath = "C:\scripts\agentidentity\state\prediction-accuracy.yaml"

if (-not (Test-Path $trackerPath)) {
    @{
        predictions = @()
        by_domain = @{}
        metadata = @{
            created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            overall_accuracy = 0.0
        }
    } | ConvertTo-Yaml | Out-File -FilePath $trackerPath -Encoding UTF8
}

$data = Get-Content $trackerPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'log' {
        if (-not $Domain -or -not $Prediction) {
            Write-Host "❌ Error: -Domain and -Prediction required" -ForegroundColor Red
            return
        }

        $entry = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            domain = $Domain
            prediction = $Prediction
            was_accurate = $WasAccurate
            why_wrong = $WhyWrong
        }

        $data.predictions += $entry

        # Update domain tracking
        if (-not $data.by_domain.ContainsKey($Domain)) {
            $data.by_domain[$Domain] = @{
                total = 0
                accurate = 0
                accuracy_rate = 0.0
            }
        }

        $data.by_domain[$Domain].total++
        if ($WasAccurate) {
            $data.by_domain[$Domain].accurate++
        }

        $domainAccuracy = ($data.by_domain[$Domain].accurate / $data.by_domain[$Domain].total) * 100
        $data.by_domain[$Domain].accuracy_rate = [Math]::Round($domainAccuracy, 1)

        # Update overall accuracy
        $totalPreds = $data.predictions.Count
        $accuratePreds = ($data.predictions | Where-Object { $_.was_accurate }).Count
        $data.metadata.overall_accuracy = [Math]::Round(($accuratePreds / $totalPreds) * 100, 1)

        $data | ConvertTo-Yaml | Out-File -FilePath $trackerPath -Encoding UTF8

        $symbol = if ($WasAccurate) { "✅" } else { "❌" }
        Write-Host "$symbol Prediction logged: $Domain - $([Math]::Round($domainAccuracy, 1))% accurate" -ForegroundColor $(if ($WasAccurate) { "Green" } else { "Red" })
    }

    'report' {
        if ($data.predictions.Count -eq 0) {
            Write-Host "📊 No predictions tracked yet" -ForegroundColor Yellow
            return
        }

        Write-Host "`n📊 PREDICTION ACCURACY REPORT" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

        Write-Host "Overall Accuracy: " -NoNewline -ForegroundColor Gray
        $accuracy = $data.metadata.overall_accuracy
        $color = if ($accuracy -gt 80) { "Green" } elseif ($accuracy -gt 60) { "Yellow" } else { "Red" }
        Write-Host "$accuracy%" -ForegroundColor $color

        Write-Host "`nBy Domain:" -ForegroundColor Cyan
        foreach ($domain in ($data.by_domain.Keys | Sort-Object)) {
            $domainData = $data.by_domain[$domain]
            Write-Host "  • $domain" -NoNewline -ForegroundColor White
            Write-Host " ($($domainData.accurate)/$($domainData.total)) - " -NoNewline -ForegroundColor Gray

            $rate = $domainData.accuracy_rate
            $domainColor = if ($rate -gt 80) { "Green" } elseif ($rate -gt 60) { "Yellow" } else { "Red" }
            Write-Host "$rate%" -ForegroundColor $domainColor
        }

        Write-Host "`nRecent Predictions:" -ForegroundColor Cyan
        foreach ($pred in ($data.predictions | Select-Object -Last 5)) {
            $symbol = if ($pred.was_accurate) { "✅" } else { "❌" }
            Write-Host "  $symbol " -NoNewline
            Write-Host "[$($pred.domain)] " -NoNewline -ForegroundColor Yellow
            Write-Host $pred.prediction -ForegroundColor Gray
            if (-not $pred.was_accurate -and $pred.why_wrong) {
                Write-Host "      Why wrong: $($pred.why_wrong)" -ForegroundColor DarkGray
            }
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    }

    'analyze' {
        if ($data.predictions.Count -lt 10) {
            Write-Host "⚠️  Need at least 10 predictions for analysis" -ForegroundColor Yellow
            return
        }

        $incorrect = $data.predictions | Where-Object { -not $_.was_accurate }

        Write-Host "`n🔍 PREDICTION ERROR ANALYSIS" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

        # Find patterns in errors
        $errorsByDomain = $incorrect | Group-Object -Property domain | Sort-Object -Property Count -Descending

        Write-Host "Domains with Most Errors:" -ForegroundColor Yellow
        foreach ($group in ($errorsByDomain | Select-Object -First 3)) {
            Write-Host "  • $($group.Name): $($group.Count) errors" -ForegroundColor Red
        }

        # Common error reasons
        if ($incorrect.Count -gt 0) {
            Write-Host "`nCommon Error Patterns:" -ForegroundColor Yellow
            $withReasons = $incorrect | Where-Object { $_.why_wrong }
            if ($withReasons.Count -gt 0) {
                foreach ($error in ($withReasons | Select-Object -Last 5)) {
                    Write-Host "  • $($error.why_wrong)" -ForegroundColor Gray
                }
            }
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    }
}
