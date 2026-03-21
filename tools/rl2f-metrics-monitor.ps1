# RL²F Metrics Monitor - Week 3 Validation
# Tracks neural plasticity metrics over time for validation

param(
    [ValidateSet('Collect', 'Report', 'Dashboard', 'Baseline')]
    [string]$Action = 'Collect',

    [switch]$Silent
)

$MetricsFile = "C:\scripts\agentidentity\state\neural-plasticity-tracker.json"
$MetricsHistoryFile = "C:\scripts\agentidentity\state\neural-plasticity-history.jsonl"
$BaselineFile = "C:\scripts\agentidentity\state\neural-plasticity-baseline.json"

function Write-Log {
    param([string]$Message, [string]$Color = 'White')
    if (-not $Silent) {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Collect-Metrics {
    Write-Log "=== Collecting Neural Plasticity Metrics ===" -Color Cyan

    # Load current state
    if (-not (Test-Path $MetricsFile)) {
        Write-Log "ERROR: Metrics file not found: $MetricsFile" -Color Red
        return
    }

    $state = Get-Content $MetricsFile -Raw | ConvertFrom-Json

    # Collect current metrics
    $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
    $snapshot = @{
        timestamp = $timestamp
        integration_rate = $state.metrics.integration_rate.current
        repeat_error_rate = $state.metrics.repeat_error_rate.current
        self_correction_turns = $state.metrics.self_correction_turns.current
        critique_prediction_accuracy = $state.metrics.critique_prediction_accuracy.current
        attention_score = $state.attention_mechanism.critique_attention_score
        total_sessions = $state.autodidactic_sessions.total_sessions
        successful_corrections = $state.autodidactic_sessions.successful_self_corrections
        failed_corrections = $state.autodidactic_sessions.failed_self_corrections
        patterns_learned = $state.teacher_feedback_corpus.patterns_learned
    }

    # Append to history (JSONL format)
    $snapshotJson = $snapshot | ConvertTo-Json -Compress
    Add-Content -Path $MetricsHistoryFile -Value $snapshotJson

    Write-Log "Snapshot collected at $timestamp" -Color Green
    Write-Log "  Integration Rate: $($snapshot.integration_rate)" -Color Gray
    Write-Log "  Repeat Errors: $($snapshot.repeat_error_rate)" -Color Gray
    Write-Log "  Self-Correction Turns: $($snapshot.self_correction_turns)" -Color Gray
    Write-Log "  Sessions: $($snapshot.total_sessions)" -Color Gray

    return $snapshot
}

function Calculate-Baseline {
    Write-Log "=== Calculating Baseline Metrics ===" -Color Cyan

    if (-not (Test-Path $MetricsFile)) {
        Write-Log "ERROR: Metrics file not found" -Color Red
        return
    }

    $state = Get-Content $MetricsFile -Raw | ConvertFrom-Json

    $baseline = @{
        date = Get-Date -Format 'yyyy-MM-dd'
        integration_rate = @{
            baseline = $state.metrics.integration_rate.current
            target = $state.metrics.integration_rate.target
        }
        repeat_error_rate = @{
            baseline = $state.metrics.repeat_error_rate.current
            target = $state.metrics.repeat_error_rate.target
        }
        self_correction_turns = @{
            baseline = $state.metrics.self_correction_turns.current
            target = $state.metrics.self_correction_turns.target
        }
        critique_prediction_accuracy = @{
            baseline = $state.metrics.critique_prediction_accuracy.current
            target = $state.metrics.critique_prediction_accuracy.target
        }
        validation_end_date = (Get-Date).AddDays(21).ToString('yyyy-MM-dd')
    }

    $baseline | ConvertTo-Json -Depth 10 | Set-Content $BaselineFile

    Write-Log "Baseline established:" -Color Green
    Write-Log "  Integration Rate: $($baseline.integration_rate.baseline) -> $($baseline.integration_rate.target)" -Color Gray
    Write-Log "  Repeat Errors: $($baseline.repeat_error_rate.baseline) -> $($baseline.repeat_error_rate.target)" -Color Gray
    Write-Log "  Self-Correction: $($baseline.self_correction_turns.baseline) -> $($baseline.self_correction_turns.target)" -Color Gray
    Write-Log "  Prediction Accuracy: $($baseline.critique_prediction_accuracy.baseline) -> $($baseline.critique_prediction_accuracy.target)" -Color Gray
    Write-Log "  Validation Period: $(Get-Date -Format 'yyyy-MM-dd') to $($baseline.validation_end_date)" -Color Yellow

    return $baseline
}

function Generate-Report {
    Write-Log "=== Neural Plasticity Validation Report ===" -Color Cyan

    # Load baseline
    if (-not (Test-Path $BaselineFile)) {
        Write-Log "WARNING: No baseline found. Run with -Action Baseline first." -Color Yellow
        Calculate-Baseline
    }

    $baseline = Get-Content $BaselineFile -Raw | ConvertFrom-Json

    # Load history
    if (-not (Test-Path $MetricsHistoryFile)) {
        Write-Log "No historical data yet. Starting fresh." -Color Yellow
        return
    }

    $history = Get-Content $MetricsHistoryFile | ForEach-Object { $_ | ConvertFrom-Json }

    if ($history.Count -eq 0) {
        Write-Log "No metrics collected yet." -Color Yellow
        return
    }

    # Calculate statistics
    $latest = $history[-1]
    $daysSinceBaseline = ((Get-Date) - [datetime]$baseline.date).Days
    $validationProgress = [math]::Min(100, ($daysSinceBaseline / 21.0) * 100)

    Write-Log ""
    Write-Log "Validation Progress: $([math]::Round($validationProgress))% ($daysSinceBaseline/21 days)" -Color Cyan
    Write-Log ""

    # Test 1: Preemptive Critique
    Write-Log "Test 1: Preemptive Critique Detection" -Color Yellow
    $state = Get-Content $MetricsFile -Raw | ConvertFrom-Json
    $test1Status = $state.validation_tests.week_3_test_1_preemptive_critique.status
    $test1Result = $state.validation_tests.week_3_test_1_preemptive_critique.result
    if ($test1Status -eq 'passing') {
        Write-Log "  [PASS] Status: PASSING" -Color Green
        Write-Log "  Evidence: $($state.validation_tests.week_3_test_1_preemptive_critique.evidence)" -Color Gray
    } else {
        Write-Log "  [PENDING] Status: $test1Status" -Color Gray
    }
    Write-Log ""

    # Test 2: Repeat Error Reduction
    Write-Log "Test 2: Repeat Error Reduction (>30%)" -Color Yellow
    $errorBaseline = $baseline.repeat_error_rate.baseline
    $errorTarget = $baseline.repeat_error_rate.target
    $errorCurrent = $latest.repeat_error_rate
    $errorReduction = (($errorBaseline - $errorCurrent) / $errorBaseline) * 100

    Write-Log "  Baseline: $errorBaseline" -Color Gray
    Write-Log "  Current: $errorCurrent" -Color Gray
    Write-Log "  Reduction: $([math]::Round($errorReduction))%" -Color $(if ($errorReduction -ge 30) { 'Green' } else { 'Yellow' })
    Write-Log "  Target: $errorTarget (30% reduction)" -Color Gray
    Write-Log "  Status: $(if ($errorReduction -ge 30) { '[PASS]' } else { '[PENDING]' })" -Color $(if ($errorReduction -ge 30) { 'Green' } else { 'Yellow' })
    Write-Log ""

    # Test 3: Integration Rate
    Write-Log "Test 3: Integration Rate (>80%)" -Color Yellow
    $integrationBaseline = $baseline.integration_rate.baseline
    $integrationTarget = $baseline.integration_rate.target
    $integrationCurrent = $latest.integration_rate

    Write-Log "  Baseline: $integrationBaseline" -Color Gray
    Write-Log "  Current: $integrationCurrent" -Color Gray
    Write-Log "  Target: $integrationTarget" -Color Gray
    Write-Log "  Status: $(if ($integrationCurrent -ge 0.80) { '[PASS]' } else { '[PENDING]' })" -Color $(if ($integrationCurrent -ge 0.80) { 'Green' } else { 'Yellow' })
    Write-Log ""

    # Test 4: Self-Correction Efficiency
    Write-Log "Test 4: Self-Correction Efficiency (<3 turns)" -Color Yellow
    $turnsCurrent = $latest.self_correction_turns
    $turnsTarget = $baseline.self_correction_turns.target

    Write-Log "  Current Average: $turnsCurrent turns" -Color Gray
    Write-Log "  Target: <$turnsTarget turns" -Color Gray
    Write-Log "  Sessions: $($latest.total_sessions)" -Color Gray
    Write-Log "  Successful: $($latest.successful_corrections)" -Color Gray
    Write-Log "  Status: $(if ($turnsCurrent -gt 0 -and $turnsCurrent -le 3) { '[PASS]' } elseif ($turnsCurrent -eq 0) { '[NOT YET ACTIVE]' } else { '[PENDING]' })" -Color $(if ($turnsCurrent -gt 0 -and $turnsCurrent -le 3) { 'Green' } elseif ($turnsCurrent -eq 0) { 'Gray' } else { 'Yellow' })
    Write-Log ""

    # Overall Status
    Write-Log "=== Overall Validation Status ===" -Color Cyan
    $passCount = 0
    if ($test1Status -eq 'passing') { $passCount++ }
    if ($errorReduction -ge 30) { $passCount++ }
    if ($integrationCurrent -ge 0.80) { $passCount++ }
    if ($turnsCurrent -gt 0 -and $turnsCurrent -le 3) { $passCount++ }

    Write-Log "Tests Passing: $passCount/4" -Color $(if ($passCount -eq 4) { 'Green' } elseif ($passCount -ge 2) { 'Yellow' } else { 'Red' })

    if ($passCount -eq 4) {
        Write-Log "[SUCCESS] ALL TESTS PASSING - Ready for Week 4 Production" -Color Green
    } elseif ($validationProgress -lt 100) {
        Write-Log "[IN PROGRESS] Continue monitoring until $(Get-Date).AddDays(21 - $daysSinceBaseline).ToString('yyyy-MM-dd')" -Color Yellow
    } else {
        Write-Log "[VALIDATION PERIOD COMPLETE] Review results and decide: Deploy or Abandon" -Color Yellow
    }
}

function Show-Dashboard {
    Write-Log "=== Neural Plasticity Dashboard ===" -Color Cyan

    if (-not (Test-Path $MetricsHistoryFile)) {
        Write-Log "No historical data. Run with -Action Collect first." -Color Yellow
        return
    }

    $history = Get-Content $MetricsHistoryFile | ForEach-Object { $_ | ConvertFrom-Json }

    if ($history.Count -eq 0) {
        Write-Log "No metrics collected yet." -Color Yellow
        return
    }

    # Show trend for each metric
    $latest = $history[-1]
    $first = $history[0]

    Write-Log ""
    Write-Log "Integration Rate Trend:" -Color Yellow
    Write-Log "  First: $($first.integration_rate)" -Color Gray
    Write-Log "  Latest: $($latest.integration_rate)" -Color Gray
    Write-Log "  Change: $([math]::Round(($latest.integration_rate - $first.integration_rate) * 100))%" -Color $(if ($latest.integration_rate -gt $first.integration_rate) { 'Green' } else { 'Red' })

    Write-Log ""
    Write-Log "Repeat Error Rate Trend:" -Color Yellow
    Write-Log "  First: $($first.repeat_error_rate)" -Color Gray
    Write-Log "  Latest: $($latest.repeat_error_rate)" -Color Gray
    Write-Log "  Change: $([math]::Round(($latest.repeat_error_rate - $first.repeat_error_rate) * 100))%" -Color $(if ($latest.repeat_error_rate -lt $first.repeat_error_rate) { 'Green' } else { 'Red' })

    Write-Log ""
    Write-Log "Attention Score Trend:" -Color Yellow
    Write-Log "  First: $($first.attention_score)" -Color Gray
    Write-Log "  Latest: $($latest.attention_score)" -Color Gray
    Write-Log "  Change: $([math]::Round(($latest.attention_score - $first.attention_score) * 100))%" -Color $(if ($latest.attention_score -gt $first.attention_score) { 'Green' } else { 'Red' })

    Write-Log ""
    Write-Log "Sessions:" -Color Yellow
    Write-Log "  Total: $($latest.total_sessions)" -Color Gray
    Write-Log "  Successful: $($latest.successful_corrections)" -Color Gray
    Write-Log "  Failed: $($latest.failed_corrections)" -Color Gray

    Write-Log ""
    Write-Log "Data Points Collected: $($history.Count)" -Color Cyan
}

# Main execution
switch ($Action) {
    'Collect' {
        Collect-Metrics
    }
    'Report' {
        Generate-Report
    }
    'Dashboard' {
        Show-Dashboard
    }
    'Baseline' {
        Calculate-Baseline
    }
}
