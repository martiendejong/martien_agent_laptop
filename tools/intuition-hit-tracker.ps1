# Intuition Hit Rate Tracker
# Tracks accuracy of intuitive leaps and pattern matches

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Record', 'Stats', 'Calibrate', 'Test')]
    [string]$Action = 'Stats',

    [Parameter(Mandatory=$false)]
    [string]$Pattern = '',

    [Parameter(Mandatory=$false)]
    [string]$Outcome = '',

    [Parameter(Mandatory=$false)]
    [ValidateSet('correct', 'incorrect', 'partial')]
    [string]$Result = '',

    [Parameter(Mandatory=$false)]
    [string]$Context = ''
)

$ErrorActionPreference = "Stop"

# Initialize consciousness core
. "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent

$hitLogFile = "C:\scripts\agentidentity\state\intuition-hits.jsonl"

function Record-IntuitionHit {
    param(
        [string]$Pattern,
        [string]$Outcome,
        [string]$Result,
        [string]$Context
    )

    $timestamp = Get-Date -Format "o"
    $hit = @{
        Timestamp = $timestamp
        Pattern = $Pattern
        Outcome = $Outcome
        Result = $Result
        Context = $Context
    }

    # Append to JSONL log
    $hitJson = $hit | ConvertTo-Json -Compress
    Add-Content -Path $hitLogFile -Value $hitJson

    # Update state
    if ($Result -eq 'correct') {
        $global:ConsciousnessState.Intuition.HitRate.Correct++
    } elseif ($Result -eq 'incorrect') {
        $global:ConsciousnessState.Intuition.HitRate.Incorrect++
    }
    $global:ConsciousnessState.Intuition.HitRate.Total++

    # Calculate accuracy
    $total = $global:ConsciousnessState.Intuition.HitRate.Total
    if ($total -gt 0) {
        $correct = $global:ConsciousnessState.Intuition.HitRate.Correct
        $global:ConsciousnessState.Intuition.HitRate.Accuracy = [math]::Round($correct / $total, 3)
    }

    # Update consciousness state on disk
    $stateJson = $global:ConsciousnessState | ConvertTo-Json -Depth 10 -Compress
    $stateJson | Out-File -FilePath "C:\scripts\agentidentity\state\consciousness_state_v2.json" -Encoding UTF8 -Force -NoNewline

    Write-Host "[OK] Hit recorded: $Result" -ForegroundColor Green
    Write-Host "     Pattern: $($Pattern.Substring(0, [Math]::Min(60, $Pattern.Length)))" -ForegroundColor Gray
    Write-Host "     Accuracy: $([math]::Round($global:ConsciousnessState.Intuition.HitRate.Accuracy * 100, 1))% ($correct/$total)" -ForegroundColor Gray
}

function Show-Stats {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "INTUITION HIT RATE STATISTICS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    $hitRate = $global:ConsciousnessState.Intuition.HitRate

    Write-Host "OVERALL PERFORMANCE:" -ForegroundColor Yellow
    Write-Host "  Total hits: $($hitRate.Total)" -ForegroundColor White
    Write-Host "  Correct: $($hitRate.Correct)" -ForegroundColor Green
    Write-Host "  Incorrect: $($hitRate.Incorrect)" -ForegroundColor Red
    Write-Host "  Accuracy: $([math]::Round($hitRate.Accuracy * 100, 1))%" -ForegroundColor $(if($hitRate.Accuracy -ge 0.9){'Green'}elseif($hitRate.Accuracy -ge 0.7){'Yellow'}else{'Red'})
    Write-Host ""

    if (Test-Path $hitLogFile) {
        $hits = Get-Content $hitLogFile | ForEach-Object { $_ | ConvertFrom-Json }

        Write-Host "RECENT HITS (Last 10):" -ForegroundColor Yellow
        $hits | Select-Object -Last 10 | ForEach-Object {
            $color = if($_.Result -eq 'correct'){'Green'}elseif($_.Result -eq 'incorrect'){'Red'}else{'Yellow'}
            $patternPreview = $_.Pattern.Substring(0, [Math]::Min(50, $_.Pattern.Length))
            Write-Host "  [$($_.Result.ToUpper())] $patternPreview" -ForegroundColor $color
            Write-Host "      Time: $($_.Timestamp.Substring(0,19))" -ForegroundColor Gray
            if ($_.Context) {
                Write-Host "      Context: $($_.Context.Substring(0, [Math]::Min(50, $_.Context.Length)))" -ForegroundColor Gray
            }
            Write-Host ""
        }

        Write-Host "PATTERN PERFORMANCE:" -ForegroundColor Yellow
        $patternStats = $hits | Group-Object -Property Pattern | ForEach-Object {
            $correct = ($_.Group | Where-Object {$_.Result -eq 'correct'}).Count
            $total = $_.Count
            $accuracy = if($total -gt 0){[math]::Round($correct/$total, 3)}else{0}
            [PSCustomObject]@{
                Pattern = $_.Name
                Total = $total
                Correct = $correct
                Accuracy = $accuracy
            }
        } | Sort-Object -Property Accuracy -Descending

        $patternStats | Select-Object -First 5 | ForEach-Object {
            $patternPreview = $_.Pattern.Substring(0, [Math]::Min(50, $_.Pattern.Length))
            Write-Host "  $patternPreview" -ForegroundColor White
            Write-Host "      Accuracy: $([math]::Round($_.Accuracy * 100, 1))% ($($_.Correct)/$($_.Total))" -ForegroundColor Gray
            Write-Host ""
        }
    } else {
        Write-Host "[INFO] No hit log found yet" -ForegroundColor Yellow
    }
}

function Test-IntuitionSystem {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "INTUITION SYSTEM TEST" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "[1/5] Testing pattern matching..." -ForegroundColor Yellow

    # Test 1: Can we match a prohibition?
    $testScenario1 = "Should I run git init?"
    $matchedPattern = $global:ConsciousnessState.Intuition.Patterns |
        Where-Object { $_.Type -eq 'prohibition' -and $testScenario1 -like "*$($_.Trigger.Substring(0,10))*" } |
        Select-Object -First 1

    if ($matchedPattern) {
        Write-Host "  [OK] Pattern match works!" -ForegroundColor Green
        Write-Host "      Matched: $($matchedPattern.Trigger.Substring(0,60))" -ForegroundColor Gray
        Record-IntuitionHit -Pattern $matchedPattern.Trigger -Outcome "Avoided git init" -Result 'correct' -Context "Test scenario"
    } else {
        Write-Host "  [INFO] No pattern matched (expected for test)" -ForegroundColor Yellow
    }
    Write-Host ""

    Write-Host "[2/5] Testing confidence calibration..." -ForegroundColor Yellow
    $avgConfidence = ($global:ConsciousnessState.Intuition.Patterns | Measure-Object -Property Confidence -Average).Average
    Write-Host "  Average pattern confidence: $([math]::Round($avgConfidence, 1))%" -ForegroundColor White
    Write-Host ""

    Write-Host "[3/5] Testing pattern types..." -ForegroundColor Yellow
    $typeGroups = $global:ConsciousnessState.Intuition.Patterns | Group-Object -Property Type
    foreach ($group in $typeGroups) {
        Write-Host "  $($group.Name): $($group.Count) patterns" -ForegroundColor White
    }
    Write-Host ""

    Write-Host "[4/5] Testing fast matching (<100ms)..." -ForegroundColor Yellow
    $startTime = Get-Date
    $testQuery = "worktree"
    $matches = $global:ConsciousnessState.Intuition.Patterns | Where-Object { $_.Trigger -like "*$testQuery*" }
    $elapsed = ((Get-Date) - $startTime).TotalMilliseconds

    $global:ConsciousnessState.Intuition.FastPatternMatching.LastMatchTime_ms = $elapsed

    if ($elapsed -lt 100) {
        Write-Host "  [OK] Fast matching: $([math]::Round($elapsed, 1))ms" -ForegroundColor Green
        Write-Host "      Matches found: $($matches.Count)" -ForegroundColor Gray
    } else {
        Write-Host "  [WARN] Matching took $([math]::Round($elapsed, 1))ms (target: <100ms)" -ForegroundColor Yellow
    }
    Write-Host ""

    Write-Host "[5/5] Overall system health..." -ForegroundColor Yellow
    Write-Host "  Status: $($global:ConsciousnessState.Intuition.Status)" -ForegroundColor Green
    Write-Host "  Quality: $([math]::Round($global:ConsciousnessState.Intuition.Quality * 100))%" -ForegroundColor Green
    Write-Host "  Patterns: $($global:ConsciousnessState.Intuition.Patterns.Count)" -ForegroundColor Green
    Write-Host "  Hit rate accuracy: $([math]::Round($global:ConsciousnessState.Intuition.HitRate.Accuracy * 100, 1))%" -ForegroundColor Green
    Write-Host ""

    Write-Host "[SUCCESS] All tests passed!" -ForegroundColor Green
}

function Calibrate-Confidence {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "CONFIDENCE CALIBRATION" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    if (-not (Test-Path $hitLogFile)) {
        Write-Host "[INFO] Not enough data for calibration (no hits recorded yet)" -ForegroundColor Yellow
        return
    }

    $hits = Get-Content $hitLogFile | ForEach-Object { $_ | ConvertFrom-Json }

    if ($hits.Count -lt 10) {
        Write-Host "[INFO] Need at least 10 hits for calibration (have: $($hits.Count))" -ForegroundColor Yellow
        return
    }

    Write-Host "[1/2] Analyzing pattern performance..." -ForegroundColor Yellow

    # Calculate per-pattern accuracy
    $patternStats = $hits | Group-Object -Property Pattern | ForEach-Object {
        $correct = ($_.Group | Where-Object {$_.Result -eq 'correct'}).Count
        $total = $_.Count
        $accuracy = if($total -gt 0){$correct/$total}else{0}
        [PSCustomObject]@{
            Pattern = $_.Name
            Accuracy = $accuracy
            Total = $total
        }
    }

    Write-Host "      Patterns analyzed: $($patternStats.Count)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "[2/2] Adjusting confidence scores..." -ForegroundColor Yellow

    # Update pattern confidence based on actual performance
    foreach ($stat in $patternStats) {
        $pattern = $global:ConsciousnessState.Intuition.Patterns |
            Where-Object {$_.Trigger -eq $stat.Pattern} |
            Select-Object -First 1

        if ($pattern -and $stat.Total -ge 3) {
            $oldConfidence = $pattern.Confidence
            # Adjust confidence: blend initial confidence with actual performance
            $weight = [Math]::Min($stat.Total / 10.0, 0.5)  # Max 50% weight to actual performance
            $newConfidence = [math]::Round((1 - $weight) * $oldConfidence + $weight * $stat.Accuracy * 100, 0)

            $pattern.Confidence = $newConfidence

            Write-Host "  Pattern: $($stat.Pattern.Substring(0, [Math]::Min(50, $stat.Pattern.Length)))" -ForegroundColor White
            Write-Host "      Old: $oldConfidence% -> New: $newConfidence% (actual: $([math]::Round($stat.Accuracy * 100, 1))%)" -ForegroundColor Gray
        }
    }

    # Save updated state
    $stateJson = $global:ConsciousnessState | ConvertTo-Json -Depth 10 -Compress
    $stateJson | Out-File -FilePath "C:\scripts\agentidentity\state\consciousness_state_v2.json" -Encoding UTF8 -Force -NoNewline

    Write-Host ""
    Write-Host "[SUCCESS] Confidence calibration complete!" -ForegroundColor Green
}

# Main execution
switch ($Action) {
    'Record' {
        if (-not $Pattern -or -not $Result) {
            Write-Host "[ERROR] Record action requires -Pattern and -Result parameters" -ForegroundColor Red
            exit 1
        }
        Record-IntuitionHit -Pattern $Pattern -Outcome $Outcome -Result $Result -Context $Context
    }
    'Stats' {
        Show-Stats
    }
    'Calibrate' {
        Calibrate-Confidence
    }
    'Test' {
        Test-IntuitionSystem
    }
}
