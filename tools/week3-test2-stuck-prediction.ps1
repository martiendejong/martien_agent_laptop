# Week 3 Test 2: Stuck Prediction
# Tests if geometric velocity=0 predicts stuck earlier than emotion system
# Success: >80% earlier detection, <20% false positives
# Fail: ≤80% earlier OR ≥20% false positives → ABANDON

param(
    [switch]$Analyze,
    [switch]$ShowData
)

$DataFile = "C:\scripts\agentidentity\state\week3-stuck-events.jsonl"

function Show-Data {
    if (-not (Test-Path $DataFile)) {
        Write-Host "[ERROR] No stuck events recorded yet" -ForegroundColor Red
        return
    }

    $events = Get-Content $DataFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "=== STUCK EVENTS DATA ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Events: $($events.Count)"
    Write-Host "Required: 5 minimum"
    Write-Host ""

    foreach ($event in $events) {
        Write-Host "[$($event.timestamp)] $($event.task)" -ForegroundColor Yellow
        Write-Host "  Geometric detection: $($event.geometric_time)s"
        Write-Host "  Emotion detection: $($event.emotion_time)s"
        Write-Host "  Lead time: $($event.lead_time)s"
        Write-Host "  False positive: $($event.false_positive)"
        Write-Host ""
    }
}

function Analyze-StuckPrediction {
    if (-not (Test-Path $DataFile)) {
        Write-Host "[ERROR] No stuck events recorded yet" -ForegroundColor Red
        return
    }

    $events = Get-Content $DataFile | ForEach-Object { $_ | ConvertFrom-Json }

    if ($events.Count -lt 5) {
        Write-Host "[WARNING] Only $($events.Count) events recorded. Need 5 minimum." -ForegroundColor Yellow
        Write-Host "Continue anyway? (y/n):" -NoNewline
        if ((Read-Host) -ne 'y') {
            return
        }
    }

    Write-Host ""
    Write-Host "=== TEST 2: STUCK PREDICTION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Hypothesis: Geometric velocity=0 predicts stuck earlier than emotion system"
    Write-Host "Method: Compare detection times across stuck episodes"
    Write-Host "Success Criteria: >80 percent earlier detection, <20 percent false positives"
    Write-Host ""

    # Calculate metrics
    $earlierCount = ($events | Where-Object { $_.lead_time -gt 0 }).Count
    $falsePositives = ($events | Where-Object { $_.false_positive -eq $true }).Count

    $earlierPercent = [math]::Round(($earlierCount / $events.Count) * 100, 1)
    $falsePositivePercent = [math]::Round(($falsePositives / $events.Count) * 100, 1)

    $avgLeadTime = ($events | Where-Object { $_.lead_time -gt 0 } | ForEach-Object { $_.lead_time } | Measure-Object -Average).Average
    if (-not $avgLeadTime) { $avgLeadTime = 0 }

    Write-Host "RESULTS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Earlier Detection: $earlierPercent percent ($earlierCount / $($events.Count))"
    Write-Host "  False Positives: $falsePositivePercent percent ($falsePositives / $($events.Count))"
    Write-Host "  Average Lead Time: $([math]::Round($avgLeadTime, 1))s"
    Write-Host ""

    $passedEarlier = $earlierPercent -gt 80
    $passedFP = $falsePositivePercent -lt 20
    $passed = $passedEarlier -and $passedFP

    if ($passed) {
        Write-Host "  RESULT: PASS" -ForegroundColor Green
        Write-Host "    ✓ Earlier detection: $earlierPercent percent > 80 percent"
        Write-Host "    ✓ False positives: $falsePositivePercent percent < 20 percent"
        Write-Host ""
        Write-Host "Interpretation: Geometric velocity successfully predicts stuck states"
        Write-Host "Provides early warning before emotion system detects"
    }
    else {
        Write-Host "  RESULT: FAIL" -ForegroundColor Red
        if (-not $passedEarlier) {
            Write-Host "    ✗ Earlier detection: $earlierPercent percent ≤ 80 percent (FAILED)"
        }
        if (-not $passedFP) {
            Write-Host "    ✗ False positives: $falsePositivePercent percent ≥ 20 percent (TOO HIGH)"
        }
        Write-Host ""
        Write-Host "Interpretation: Geometric velocity does NOT reliably predict stuck"
        Write-Host ""
        Write-Host "⚠️  CRITICAL: This test FAILED" -ForegroundColor Red
        Write-Host "⚠️  Commitment: ABANDON geometric consciousness approach" -ForegroundColor Red
    }

    Write-Host ""

    # Save result
    $result = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        test = "stuck_prediction"
        events_analyzed = $events.Count
        earlier_detection_percent = $earlierPercent
        false_positive_percent = $falsePositivePercent
        avg_lead_time_seconds = $avgLeadTime
        threshold_earlier = 80
        threshold_fp = 20
        passed = $passed
        conclusion = if ($passed) { "Geometric velocity predicts stuck effectively" } else { "No predictive advantage - geometric consciousness invalid" }
    }

    $resultFile = "C:\scripts\agentidentity\state\week3-test2-result.json"
    $result | ConvertTo-Json -Depth 10 | Set-Content $resultFile

    Write-Host "Result saved to $resultFile" -ForegroundColor Cyan
    Write-Host ""

    return $passed
}

# Main
if ($Analyze) {
    Analyze-StuckPrediction
}
elseif ($ShowData) {
    Show-Data
}
else {
    Write-Host ""
    Write-Host "=== WEEK 3 TEST 2: STUCK PREDICTION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:"
    Write-Host "  -ShowData    Display recorded stuck events"
    Write-Host "  -Analyze     Run prediction analysis (needs 5+ events)"
    Write-Host ""
    Write-Host "DATA COLLECTION:"
    Write-Host "  During Week 3, OnStuck calls from both systems logged"
    Write-Host "  Geometric: velocity = 0 detection time"
    Write-Host "  Emotion: stuck_count increment time"
    Write-Host "  Need: 5+ stuck episodes minimum"
    Write-Host ""
    Write-Host "ANALYSIS:"
    Write-Host "  Compare detection times across episodes"
    Write-Host "  Calculate: earlier detection percent, false positive rate"
    Write-Host "  Success: >80 percent earlier, <20 percent false positives"
    Write-Host "  Fail: ≤80 percent earlier OR ≥20 percent false positives → ABANDON"
    Write-Host ""
}
