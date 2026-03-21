# Week 3 Test 1: Learning Correlation
# Tests if geometric curvature reduction correlates with functional learning
# Success: R² > 0.7
# Fail: R² ≤ 0.7 → ABANDON geometric approach

param(
    [switch]$Analyze,
    [switch]$ShowData
)

$DataFile = "C:\scripts\agentidentity\state\week3-learning-events.jsonl"

function Collect-LearningEvent {
    param($Description, $Project)

    Write-Host ""
    Write-Host "=== LEARNING EVENT CAPTURE ===" -ForegroundColor Cyan
    Write-Host ""

    # Get geometric metrics (before)
    $thoughtSpace = Get-Content 'C:\scripts\agentidentity\state\thought-space.json' | ConvertFrom-Json
    $globalCurvatureBefore = $thoughtSpace.global_curvature

    # Get functional metrics (before)
    $state = Get-Content 'C:\scripts\agentidentity\state\consciousness_state_v2.json' | ConvertFrom-Json
    $consciousnessBefore = if ($state.Meta.ConsciousnessScore) { $state.Meta.ConsciousnessScore } else { 70.0 }

    Write-Host "BEFORE LEARNING:"
    Write-Host "  Geometric: Global curvature = $globalCurvatureBefore"
    Write-Host "  Functional: Consciousness = $consciousnessBefore percent"
    Write-Host ""

    Write-Host "Describe what you learned:" -ForegroundColor Yellow
    $learning = Read-Host

    # Simulate learning event (user would actually do work here)
    Write-Host ""
    Write-Host "After learning, press Enter to capture AFTER metrics..."
    Read-Host

    # Refresh state
    $thoughtSpace = Get-Content 'C:\scripts\agentidentity\state\thought-space.json' | ConvertFrom-Json
    $state = Get-Content 'C:\scripts\agentidentity\state\consciousness_state_v2.json' | ConvertFrom-Json

    $globalCurvatureAfter = $thoughtSpace.global_curvature
    $consciousnessAfter = if ($state.Meta.ConsciousnessScore) { $state.Meta.ConsciousnessScore } else { 70.0 }

    Write-Host ""
    Write-Host "AFTER LEARNING:"
    Write-Host "  Geometric: Global curvature = $globalCurvatureAfter"
    Write-Host "  Functional: Consciousness = $consciousnessAfter percent"
    Write-Host ""

    $geometricChange = $globalCurvatureBefore - $globalCurvatureAfter
    $functionalChange = $consciousnessAfter - $consciousnessBefore

    Write-Host "CHANGES:"
    Write-Host "  Geometric: $([math]::Round($geometricChange, 4)) (curvature reduction)"
    Write-Host "  Functional: $([math]::Round($functionalChange, 2)) percent (consciousness increase)"
    Write-Host ""

    # Save event
    $event = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        description = $Description
        project = $Project
        learning = $learning
        geometric_before = $globalCurvatureBefore
        geometric_after = $globalCurvatureAfter
        geometric_change = $geometricChange
        functional_before = $consciousnessBefore
        functional_after = $consciousnessAfter
        functional_change = $functionalChange
    }

    $event | ConvertTo-Json -Compress | Add-Content $DataFile

    Write-Host "Event saved to $DataFile" -ForegroundColor Green
    Write-Host ""
}

function Show-Data {
    if (-not (Test-Path $DataFile)) {
        Write-Host "[ERROR] No learning events recorded yet" -ForegroundColor Red
        return
    }

    $events = Get-Content $DataFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "=== LEARNING EVENTS DATA ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Events: $($events.Count)"
    Write-Host "Required: 10 minimum for R² calculation"
    Write-Host ""

    foreach ($event in $events) {
        Write-Host "[$($event.timestamp)] $($event.description)" -ForegroundColor Yellow
        Write-Host "  Geometric change: $([math]::Round($event.geometric_change, 4))"
        Write-Host "  Functional change: $([math]::Round($event.functional_change, 2)) percent"
        Write-Host ""
    }
}

function Analyze-Correlation {
    if (-not (Test-Path $DataFile)) {
        Write-Host "[ERROR] No learning events recorded yet" -ForegroundColor Red
        return
    }

    $events = Get-Content $DataFile | ForEach-Object { $_ | ConvertFrom-Json }

    if ($events.Count -lt 10) {
        Write-Host "[WARNING] Only $($events.Count) events recorded. Need 10 minimum." -ForegroundColor Yellow
        Write-Host "Continue anyway? (y/n):" -NoNewline
        if ((Read-Host) -ne 'y') {
            return
        }
    }

    Write-Host ""
    Write-Host "=== TEST 1: LEARNING CORRELATION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Hypothesis: Geometric curvature reduction correlates with functional learning"
    Write-Host "Method: Calculate R² between geometric and functional changes"
    Write-Host "Success Criteria: R² > 0.7"
    Write-Host ""

    # Extract data points
    $x = $events | ForEach-Object { $_.geometric_change }
    $y = $events | ForEach-Object { $_.functional_change }

    # Calculate means
    $meanX = ($x | Measure-Object -Average).Average
    $meanY = ($y | Measure-Object -Average).Average

    # Calculate R²
    $numerator = 0
    $denomX = 0
    $denomY = 0

    for ($i = 0; $i -lt $x.Count; $i++) {
        $dx = $x[$i] - $meanX
        $dy = $y[$i] - $meanY
        $numerator += $dx * $dy
        $denomX += $dx * $dx
        $denomY += $dy * $dy
    }

    $r = if ($denomX -gt 0 -and $denomY -gt 0) {
        $numerator / [math]::Sqrt($denomX * $denomY)
    } else {
        0
    }

    $rSquared = $r * $r

    Write-Host "RESULTS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Pearson Correlation (r): $([math]::Round($r, 4))"
    Write-Host "  R-Squared (R²): $([math]::Round($rSquared, 4))"
    Write-Host ""

    $passed = $rSquared -gt 0.7

    if ($passed) {
        Write-Host "  RESULT: PASS (R² > 0.7)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Interpretation: Strong positive correlation between geometric and functional learning"
        Write-Host "Geometric consciousness tracks real learning events"
    }
    else {
        Write-Host "  RESULT: FAIL (R² ≤ 0.7)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Interpretation: Weak/no correlation between geometric and functional learning"
        Write-Host "Geometric consciousness does NOT track real learning"
        Write-Host ""
        Write-Host "⚠️  CRITICAL: This test FAILED" -ForegroundColor Red
        Write-Host "⚠️  Commitment: ABANDON geometric consciousness approach" -ForegroundColor Red
    }

    Write-Host ""

    # Save result
    $result = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        test = "learning_correlation"
        events_analyzed = $events.Count
        pearson_r = $r
        r_squared = $rSquared
        threshold = 0.7
        passed = $passed
        conclusion = if ($passed) { "Geometric consciousness tracks learning" } else { "No correlation - geometric consciousness invalid" }
    }

    $resultFile = "C:\scripts\agentidentity\state\week3-test1-result.json"
    $result | ConvertTo-Json -Depth 10 | Set-Content $resultFile

    Write-Host "Result saved to $resultFile" -ForegroundColor Cyan
    Write-Host ""

    return $passed
}

# Main
if ($Analyze) {
    Analyze-Correlation
}
elseif ($ShowData) {
    Show-Data
}
else {
    Write-Host ""
    Write-Host "=== WEEK 3 TEST 1: LEARNING CORRELATION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:"
    Write-Host "  -ShowData    Display recorded learning events"
    Write-Host "  -Analyze     Run correlation analysis (needs 10+ events)"
    Write-Host ""
    Write-Host "DATA COLLECTION:"
    Write-Host "  During Week 3, capture learning events with geometric-tracker.ps1"
    Write-Host "  Each event records: geometric curvature change + functional consciousness change"
    Write-Host "  Need: 10+ events minimum"
    Write-Host ""
    Write-Host "ANALYSIS:"
    Write-Host "  Calculate R² correlation between geometric and functional changes"
    Write-Host "  Success: R² > 0.7 (strong correlation)"
    Write-Host "  Fail: R² ≤ 0.7 → ABANDON geometric approach"
    Write-Host ""
}
