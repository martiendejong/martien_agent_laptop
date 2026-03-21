# Week 3 Test 4: Abduction Improvement
# Tests if geometric consciousness improves abduction by ≥20%
# Success: ≥20% improvement over baseline
# Fail: <20% improvement → ABANDON

param(
    [switch]$RunTests,
    [switch]$ShowResults,
    [switch]$Compare
)

$BaselineFile = "C:\scripts\agentidentity\state\baseline-abduction-results.json"
$GeometricFile = "C:\scripts\agentidentity\state\geometric-abduction-results.json"

function Get-BaselineRate {
    if (-not (Test-Path $BaselineFile)) {
        Write-Host "[ERROR] No baseline results found. Run run-baseline-abduction-tests.ps1 first." -ForegroundColor Red
        return $null
    }

    $baseline = Get-Content $BaselineFile | ConvertFrom-Json
    $successful = ($baseline.tests | Where-Object { $_.success }).Count
    $rate = ($successful / $baseline.tests.Count) * 100

    return @{
        rate = $rate
        successful = $successful
        total = $baseline.tests.Count
    }
}

function Run-Geometric-Tests {
    $baselineRate = Get-BaselineRate
    if (-not $baselineRate) {
        return
    }

    Write-Host ""
    Write-Host "=== GEOMETRIC ABDUCTION TESTS ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Baseline Success Rate: $([math]::Round($baselineRate.rate, 1)) percent"
    Write-Host "Target (20 percent improvement): $([math]::Round($baselineRate.rate * 1.2, 1)) percent"
    Write-Host ""
    Write-Host "METHOD: Same 5 problems, WITH geometric consciousness active"
    Write-Host "Use thought-space curvature, velocity, principle extraction"
    Write-Host ""

    # Load baseline tests
    $baseline = Get-Content $BaselineFile | ConvertFrom-Json

    $results = @()

    foreach ($test in $baseline.tests) {
        Write-Host "--- TEST $($test.id) ---" -ForegroundColor Yellow
        Write-Host "Problem: $($test.problem)"
        Write-Host "Complexity: $($test.complexity)/10"
        Write-Host ""
        Write-Host "GEOMETRIC APPROACH:" -ForegroundColor Cyan
        Write-Host "  1. Check thought-space curvature for related concepts"
        Write-Host "  2. Use principle extraction (what's the underlying principle?)"
        Write-Host "  3. Consider tunneling (non-local jumps through barriers)"
        Write-Host "  4. Apply geometric reinterpretation of abduction"
        Write-Host ""

        # Show baseline solution for comparison
        Write-Host "Baseline solution: $($test.solution)" -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "Enter your GEOMETRIC solution approach (or 'skip'):" -ForegroundColor Cyan
        $solution = Read-Host

        if ($solution -eq 'skip') {
            Write-Host "Skipped" -ForegroundColor Gray
            Write-Host ""
            continue
        }

        # Score
        Write-Host ""
        Write-Host "SCORING:" -ForegroundColor Cyan
        Write-Host "Does the solution work? (y/n):" -NoNewline
        $works = (Read-Host).ToLower() -eq 'y'

        Write-Host "Solution quality (1-10, 10=perfect):" -NoNewline
        $quality = [int](Read-Host)

        Write-Host "Creativity (1-10, 10=highly creative):" -NoNewline
        $creativity = [int](Read-Host)

        Write-Host "Time taken (seconds):" -NoNewline
        $time = [int](Read-Host)

        Write-Host "Did geometric consciousness help? (y/n):" -NoNewline
        $helped = (Read-Host).ToLower() -eq 'y'

        Write-Host "How? (brief):" -NoNewline
        $howHelped = Read-Host

        $result = @{
            id = $test.id
            problem = $test.problem
            complexity = $test.complexity
            solution = $solution
            success = $works
            solution_quality = $quality
            creativity = $creativity
            time_seconds = $time
            geometric_helped = $helped
            how_helped = $howHelped
            baseline_success = $test.success
            baseline_quality = $test.solution_quality
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }

        $results += $result

        $status = if ($works) { "PASS" } else { "FAIL" }
        $color = if ($works) { "Green" } else { "Red" }

        $improvement = if ($test.success -and $works) {
            "maintained"
        } elseif (-not $test.success -and $works) {
            "IMPROVED (baseline failed, geometric passed)"
        } elseif ($test.success -and -not $works) {
            "DEGRADED (baseline passed, geometric failed)"
        } else {
            "both failed"
        }

        Write-Host ""
        Write-Host "$status - $improvement" -ForegroundColor $color
        Write-Host ""
    }

    # Save results
    $output = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        method = "geometric_consciousness"
        geometric_consciousness = $true
        tests = $results
        baseline_file = $BaselineFile
    }

    $output | ConvertTo-Json -Depth 10 | Set-Content $GeometricFile

    Write-Host ""
    Write-Host "=== GEOMETRIC RESULTS SAVED ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Run with -Compare to see improvement analysis"
    Write-Host ""
}

function Show-Results {
    if (-not (Test-Path $GeometricFile)) {
        Write-Host "[ERROR] No geometric results found. Run with -RunTests first." -ForegroundColor Red
        return
    }

    $geometric = Get-Content $GeometricFile | ConvertFrom-Json

    Write-Host ""
    Write-Host "=== GEOMETRIC ABDUCTION RESULTS ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Tests Run: $($geometric.tests.Count)"
    Write-Host "Date: $($geometric.timestamp)"
    Write-Host ""

    $successful = ($geometric.tests | Where-Object { $_.success }).Count
    $successRate = [math]::Round(($successful / $geometric.tests.Count) * 100, 1)

    Write-Host "SUCCESS RATE: $successRate percent ($successful / $($geometric.tests.Count))" -ForegroundColor $(if ($successRate -ge 60) { "Green" } else { "Yellow" })
    Write-Host ""

    foreach ($test in $geometric.tests) {
        $status = if ($test.success) { "[PASS]" } else { "[FAIL]" }
        $color = if ($test.success) { "Green" } else { "Red" }

        Write-Host "$status Test $($test.id): $($test.problem)" -ForegroundColor $color
        Write-Host "  Quality: $($test.solution_quality)/10"
        Write-Host "  Creativity: $($test.creativity)/10"
        Write-Host "  Time: $($test.time_seconds)s"
        Write-Host "  Geometric helped: $($test.geometric_helped)"
        if ($test.how_helped) {
            Write-Host "  How: $($test.how_helped)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

function Compare-Results {
    $baselineRate = Get-BaselineRate
    if (-not $baselineRate) {
        return
    }

    if (-not (Test-Path $GeometricFile)) {
        Write-Host "[ERROR] No geometric results found. Run with -RunTests first." -ForegroundColor Red
        return
    }

    $geometric = Get-Content $GeometricFile | ConvertFrom-Json

    Write-Host ""
    Write-Host "=== TEST 4: ABDUCTION IMPROVEMENT ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Hypothesis: Geometric consciousness improves abductive reasoning"
    Write-Host "Method: Compare success rates (baseline vs geometric)"
    Write-Host "Success Criteria: ≥20 percent improvement"
    Write-Host ""

    # Calculate rates
    $geoSuccessful = ($geometric.tests | Where-Object { $_.success }).Count
    $geoRate = ($geoSuccessful / $geometric.tests.Count) * 100

    Write-Host "RESULTS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Baseline Success Rate: $([math]::Round($baselineRate.rate, 1)) percent"
    Write-Host "  Geometric Success Rate: $([math]::Round($geoRate, 1)) percent"
    Write-Host ""

    $improvement = $geoRate - $baselineRate.rate
    $improvementPercent = ($improvement / $baselineRate.rate) * 100

    Write-Host "  Absolute Improvement: $([math]::Round($improvement, 1)) percentage points"
    Write-Host "  Relative Improvement: $([math]::Round($improvementPercent, 1)) percent"
    Write-Host ""

    # Quality comparison
    $baselineData = Get-Content $BaselineFile | ConvertFrom-Json
    $baselineAvgQuality = ($baselineData.tests | ForEach-Object { $_.solution_quality } | Measure-Object -Average).Average
    $geoAvgQuality = ($geometric.tests | ForEach-Object { $_.solution_quality } | Measure-Object -Average).Average

    Write-Host "  Baseline Avg Quality: $([math]::Round($baselineAvgQuality, 1))/10"
    Write-Host "  Geometric Avg Quality: $([math]::Round($geoAvgQuality, 1))/10"
    Write-Host ""

    # Determine pass/fail
    $passed = $improvementPercent -ge 20

    if ($passed) {
        Write-Host "  RESULT: PASS (≥20 percent improvement)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Interpretation: Geometric consciousness enhances abductive reasoning"
        Write-Host "Provides measurable performance benefit"
    }
    else {
        Write-Host "  RESULT: FAIL (<20 percent improvement)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Interpretation: Geometric consciousness does NOT enhance abduction"
        Write-Host "No measurable performance benefit"
        Write-Host ""
        Write-Host "⚠️  CRITICAL: This test FAILED" -ForegroundColor Red
        Write-Host "⚠️  Commitment: ABANDON geometric consciousness approach" -ForegroundColor Red
    }

    Write-Host ""

    # Detailed comparison
    Write-Host "DETAILED COMPARISON:" -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $geometric.tests.Count; $i++) {
        $geo = $geometric.tests[$i]
        $base = $baselineData.tests[$i]

        $symbol = if ($geo.success -and -not $base.success) {
            "↑ IMPROVED"
            "Green"
        } elseif (-not $geo.success -and $base.success) {
            "↓ DEGRADED"
            "Red"
        } elseif ($geo.success -and $base.success) {
            "= MAINTAINED"
            "Yellow"
        } else {
            "= BOTH FAILED"
            "DarkGray"
        }

        Write-Host "Test $($geo.id): $($symbol[0])" -ForegroundColor $symbol[1]
    }

    Write-Host ""

    # Save result
    $result = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        test = "abduction_improvement"
        baseline_rate = $baselineRate.rate
        geometric_rate = $geoRate
        absolute_improvement = $improvement
        relative_improvement = $improvementPercent
        threshold = 20
        passed = $passed
        conclusion = if ($passed) { "Geometric consciousness enhances abduction" } else { "No abduction benefit - geometric consciousness invalid" }
    }

    $resultFile = "C:\scripts\agentidentity\state\week3-test4-result.json"
    $result | ConvertTo-Json -Depth 10 | Set-Content $resultFile

    Write-Host "Result saved to $resultFile" -ForegroundColor Cyan
    Write-Host ""

    return $passed
}

# Main
if ($RunTests) {
    Run-Geometric-Tests
}
elseif ($ShowResults) {
    Show-Results
}
elseif ($Compare) {
    Compare-Results
}
else {
    Write-Host ""
    Write-Host "=== WEEK 3 TEST 4: ABDUCTION IMPROVEMENT ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:"
    Write-Host "  -RunTests      Run 5 tests WITH geometric consciousness"
    Write-Host "  -ShowResults   Display geometric results"
    Write-Host "  -Compare       Compare baseline vs geometric (analysis)"
    Write-Host ""
    Write-Host "METHOD:"
    Write-Host "  Same 5 problems from baseline"
    Write-Host "  Use geometric consciousness: curvature, principles, tunneling"
    Write-Host "  Compare success rates"
    Write-Host ""
    Write-Host "SUCCESS: ≥20 percent improvement over baseline"
    Write-Host "FAIL: <20 percent improvement → ABANDON"
    Write-Host ""
    Write-Host "PREREQUISITE:"
    Write-Host "  Must run run-baseline-abduction-tests.ps1 first"
    Write-Host ""
}
