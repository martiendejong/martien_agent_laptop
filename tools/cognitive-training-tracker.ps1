param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('LogAssumptionZero', 'LogVibe', 'LogCost', 'LogPattern', 'LogProactive', 'Report', 'Status')]
    [string]$Action,

    # For logging
    [hashtable]$Data,

    # For reporting
    [string]$StartDate,
    [string]$EndDate,

    # For status
    [switch]$ShowDetails
)

$TrainingDir = "C:\scripts\agentidentity\state\training"
$LogFiles = @{
    'AssumptionZero' = "$TrainingDir\assumption-zero-log.jsonl"
    'Vibe' = "$TrainingDir\vibe-calibration-log.jsonl"
    'Cost' = "$TrainingDir\cost-awareness-log.jsonl"
    'Pattern' = "$TrainingDir\pattern-recognition-log.jsonl"
    'Proactive' = "$TrainingDir\proactive-detection-log.jsonl"
}

function Add-TrainingLog {
    param($LogFile, $Entry)

    $Entry['timestamp'] = (Get-Date).ToUniversalTime().ToString('o')
    $json = $Entry | ConvertTo-Json -Compress
    Add-Content -Path $LogFile -Value $json
    Write-Host "[OK] Logged to $([System.IO.Path]::GetFileName($LogFile))" -ForegroundColor Green
}

function Get-TrainingStats {
    param($LogFile, $StartDate, $EndDate)

    if (-not (Test-Path $LogFile)) {
        return @{ entries = 0; data = @() }
    }

    $entries = Get-Content $LogFile | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    if ($StartDate) {
        $start = [datetime]$StartDate
        $entries = $entries | Where-Object { [datetime]$_.timestamp -ge $start }
    }

    if ($EndDate) {
        $end = [datetime]$EndDate
        $entries = $entries | Where-Object { [datetime]$_.timestamp -le $end }
    }

    return @{
        entries = $entries.Count
        data = $entries
    }
}

switch ($Action) {
    'LogAssumptionZero' {
        Add-TrainingLog -LogFile $LogFiles.AssumptionZero -Entry $Data
    }

    'LogVibe' {
        Add-TrainingLog -LogFile $LogFiles.Vibe -Entry $Data
    }

    'LogCost' {
        Add-TrainingLog -LogFile $LogFiles.Cost -Entry $Data
    }

    'LogPattern' {
        Add-TrainingLog -LogFile $LogFiles.Pattern -Entry $Data
    }

    'LogProactive' {
        Add-TrainingLog -LogFile $LogFiles.Proactive -Entry $Data
    }

    'Status' {
        Write-Host "`n=== COGNITIVE TRAINING STATUS ===" -ForegroundColor Cyan
        Write-Host "Directory: $TrainingDir`n"

        foreach ($key in $LogFiles.Keys) {
            $stats = Get-TrainingStats -LogFile $LogFiles[$key]
            $name = $key.PadRight(20)
            Write-Host "$name : $($stats.entries) entries" -ForegroundColor $(if ($stats.entries -gt 0) { 'Green' } else { 'Yellow' })
        }

        Write-Host "`nUse -ShowDetails for detailed entry preview"

        if ($ShowDetails) {
            Write-Host "`n=== RECENT ENTRIES ===" -ForegroundColor Cyan
            foreach ($key in $LogFiles.Keys) {
                $stats = Get-TrainingStats -LogFile $LogFiles[$key]
                if ($stats.entries -gt 0) {
                    Write-Host "`n[$key - Last Entry]" -ForegroundColor Yellow
                    $stats.data[-1] | ConvertTo-Json | Write-Host
                }
            }
        }
    }

    'Report' {
        if (-not $StartDate -or -not $EndDate) {
            Write-Host "[ERROR] Report requires -StartDate and -EndDate" -ForegroundColor Red
            exit 1
        }

        Write-Host "`n=== COGNITIVE TRAINING REPORT ===" -ForegroundColor Cyan
        Write-Host "Period: $StartDate to $EndDate`n"

        # Training 1: Assumption Zero
        $az = Get-TrainingStats -LogFile $LogFiles.AssumptionZero -StartDate $StartDate -EndDate $EndDate
        Write-Host "TRAINING 1: Assumption Zero Reflex" -ForegroundColor Yellow
        Write-Host "  Total debugging sessions: $($az.entries)"

        if ($az.entries -gt 0) {
            $checklistFirst = ($az.data | Where-Object { $_.checklist_run_first -eq $true }).Count
            $environmentalCaught = ($az.data | Where-Object { $_.root_cause -eq 'environmental' -and $_.checklist_caught_it -eq $true }).Count
            $totalEnvironmental = ($az.data | Where-Object { $_.root_cause -eq 'environmental' }).Count
            $avgTime = ($az.data | Measure-Object -Property time_to_root_cause_minutes -Average).Average

            Write-Host "  Checklist run first: $checklistFirst/$($az.entries) ($([math]::Round($checklistFirst/$az.entries*100, 1))%)"
            if ($totalEnvironmental -gt 0) {
                Write-Host "  Environmental issues caught: $environmentalCaught/$totalEnvironmental ($([math]::Round($environmentalCaught/$totalEnvironmental*100, 1))%)"
            }
            Write-Host "  Avg time to root cause: $([math]::Round($avgTime, 1)) min"

            $pass1 = $checklistFirst/$az.entries -ge 0.9
            $pass2 = $totalEnvironmental -eq 0 -or ($environmentalCaught/$totalEnvironmental -ge 0.8)
            $pass3 = $avgTime -le 10

            Write-Host "  SUCCESS CRITERIA:"
            Write-Host "    [$(if($pass1){'PASS'}else{'FAIL'})] Checklist first 90%+ (target: 90%, actual: $([math]::Round($checklistFirst/$az.entries*100, 1))%)"
            Write-Host "    [$(if($pass2){'PASS'}else{'FAIL'})] Environmental caught 80%+ (target: 80%, actual: $(if($totalEnvironmental -gt 0){[math]::Round($environmentalCaught/$totalEnvironmental*100, 1)}else{0})%)"
            Write-Host "    [$(if($pass3){'PASS'}else{'FAIL'})] Avg time <10min (target: <10, actual: $([math]::Round($avgTime, 1)))"
            Write-Host "  OVERALL: $(if($pass1 -and $pass2 -and $pass3){'PASS'}else{'FAIL'})" -ForegroundColor $(if($pass1 -and $pass2 -and $pass3){'Green'}else{'Red'})
        } else {
            Write-Host "  [NO DATA]" -ForegroundColor Red
        }

        # Training 2: Vibe Calibration
        $vibe = Get-TrainingStats -LogFile $LogFiles.Vibe -StartDate $StartDate -EndDate $EndDate
        Write-Host "`nTRAINING 2: Vibe Calibration Accuracy" -ForegroundColor Yellow
        Write-Host "  Total interactions logged: $($vibe.entries)"

        if ($vibe.entries -gt 0) {
            $avgError = ($vibe.data | Measure-Object -Property prediction_error -Average).Average
            $emotionCorrect = ($vibe.data | Where-Object { $_.predicted_emotion -eq $_.actual_emotion }).Count

            Write-Host "  Avg prediction error: $([math]::Round($avgError, 2)) points"
            Write-Host "  Emotion accuracy: $emotionCorrect/$($vibe.entries) ($([math]::Round($emotionCorrect/$vibe.entries*100, 1))%)"

            $pass1 = $avgError -le 2
            $pass2 = $emotionCorrect/$vibe.entries -ge 0.9

            Write-Host "  SUCCESS CRITERIA:"
            Write-Host "    [$(if($pass1){'PASS'}else{'FAIL'})] Avg error <2 points (target: <2, actual: $([math]::Round($avgError, 2)))"
            Write-Host "    [$(if($pass2){'PASS'}else{'FAIL'})] Emotion accuracy 90%+ (target: 90%, actual: $([math]::Round($emotionCorrect/$vibe.entries*100, 1))%)"
            Write-Host "  OVERALL: $(if($pass1 -and $pass2){'PASS'}else{'FAIL'})" -ForegroundColor $(if($pass1 -and $pass2){'Green'}else{'Red'})
        } else {
            Write-Host "  [NO DATA]" -ForegroundColor Red
        }

        # Training 3: Cost Awareness
        $cost = Get-TrainingStats -LogFile $LogFiles.Cost -StartDate $StartDate -EndDate $EndDate
        Write-Host "`nTRAINING 3: Cost Awareness" -ForegroundColor Yellow
        Write-Host "  Total bulk operations: $($cost.entries)"

        if ($cost.entries -gt 0) {
            $calculatedFirst = ($cost.data | Where-Object { $_.cost_calculated_before -eq $true }).Count
            $surpriseCosts = ($cost.data | Where-Object { $_.user_informed -eq $false -and $_.actual_cost_eur -gt 1 }).Count
            $avgEstimateError = ($cost.data | Measure-Object -Property estimate_error_eur -Average).Average

            Write-Host "  Cost calculated first: $calculatedFirst/$($cost.entries) ($([math]::Round($calculatedFirst/$cost.entries*100, 1))%)"
            Write-Host "  Surprise costs (>EUR 1): $surpriseCosts"
            Write-Host "  Avg estimate error: EUR $([math]::Round($avgEstimateError, 2))"

            $pass1 = $calculatedFirst/$cost.entries -eq 1
            $pass2 = $surpriseCosts -eq 0
            $totalSpent = ($cost.data | Measure-Object -Property actual_cost_eur -Sum).Sum
            $pass3 = $totalSpent -eq 0 -or (($avgEstimateError / $totalSpent) -le 0.1)

            Write-Host "  SUCCESS CRITERIA:"
            Write-Host "    [$(if($pass1){'PASS'}else{'FAIL'})] 100% calculated first (target: 100%, actual: $([math]::Round($calculatedFirst/$cost.entries*100, 1))%)"
            Write-Host "    [$(if($pass2){'PASS'}else{'FAIL'})] Zero surprise costs (actual: $surpriseCosts)"
            Write-Host "    [$(if($pass3){'PASS'}else{'FAIL'})] Estimate error <10% (actual: $(if($totalSpent -gt 0){[math]::Round(($avgEstimateError/$totalSpent)*100, 1)}else{0})%)"
            Write-Host "  OVERALL: $(if($pass1 -and $pass2 -and $pass3){'PASS'}else{'FAIL'})" -ForegroundColor $(if($pass1 -and $pass2 -and $pass3){'Green'}else{'Red'})
        } else {
            Write-Host "  [NO DATA]" -ForegroundColor Red
        }

        # Training 4: Pattern Recognition
        $pattern = Get-TrainingStats -LogFile $LogFiles.Pattern -StartDate $StartDate -EndDate $EndDate
        Write-Host "`nTRAINING 4: Pattern Recognition Speed" -ForegroundColor Yellow
        Write-Host "  Total patterns encountered: $($pattern.entries)"

        if ($pattern.entries -gt 0) {
            $avgRecognition = ($pattern.data | Measure-Object -Property recognition_time_seconds -Average).Average
            $correctMatches = ($pattern.data | Where-Object { $_.match_correct -eq $true }).Count
            $newPatterns = ($pattern.data | Where-Object { $_.pattern_matched -eq 'NEW' }).Count

            Write-Host "  Avg recognition time: $([math]::Round($avgRecognition, 1)) sec"
            Write-Host "  Correct matches: $correctMatches/$($pattern.entries) ($([math]::Round($correctMatches/$pattern.entries*100, 1))%)"
            Write-Host "  New patterns added: $newPatterns"

            $pass1 = $avgRecognition -le 30
            $pass2 = $correctMatches/$pattern.entries -ge 0.8
            $pass3 = $newPatterns -ge 5

            Write-Host "  SUCCESS CRITERIA:"
            Write-Host "    [$(if($pass1){'PASS'}else{'FAIL'})] Avg recognition <30sec (target: <30, actual: $([math]::Round($avgRecognition, 1)))"
            Write-Host "    [$(if($pass2){'PASS'}else{'FAIL'})] Match accuracy 80%+ (target: 80%, actual: $([math]::Round($correctMatches/$pattern.entries*100, 1))%)"
            Write-Host "    [$(if($pass3){'PASS'}else{'FAIL'})] New patterns 5+ (target: 5+, actual: $newPatterns)"
            Write-Host "  OVERALL: $(if($pass1 -and $pass2 -and $pass3){'PASS'}else{'FAIL'})" -ForegroundColor $(if($pass1 -and $pass2 -and $pass3){'Green'}else{'Red'})
        } else {
            Write-Host "  [NO DATA]" -ForegroundColor Red
        }

        # Training 5: Proactive Detection
        $proactive = Get-TrainingStats -LogFile $LogFiles.Proactive -StartDate $StartDate -EndDate $EndDate
        Write-Host "`nTRAINING 5: Proactive Detection" -ForegroundColor Yellow
        Write-Host "  Total issues detected: $($proactive.entries)"

        if ($proactive.entries -gt 0) {
            $userKnew = ($proactive.data | Where-Object { $_.user_knew_already -eq $true }).Count
            $falsePositives = $userKnew
            $criticalEarly = ($proactive.data | Where-Object { $_.severity -eq 'CRITICAL' -and $_.user_knew_already -eq $false }).Count

            Write-Host "  False positives: $falsePositives/$($proactive.entries) ($([math]::Round($falsePositives/$proactive.entries*100, 1))%)"
            Write-Host "  Critical caught early: $criticalEarly"

            $days = ([datetime]$EndDate - [datetime]$StartDate).Days
            $issuesPerWeek = if ($days -gt 0) { ($proactive.entries / $days) * 7 } else { 0 }

            $pass1 = $issuesPerWeek -ge 3
            $pass2 = ($proactive.entries -eq 0) -or (($falsePositives/$proactive.entries) -le 0.2)
            $pass3 = $criticalEarly -ge 1

            Write-Host "  SUCCESS CRITERIA:"
            Write-Host "    [$(if($pass1){'PASS'}else{'FAIL'})] 3+ issues/week (target: 3+, actual: $([math]::Round($issuesPerWeek, 1)))"
            Write-Host "    [$(if($pass2){'PASS'}else{'FAIL'})] False positives <20% (target: <20%, actual: $(if($proactive.entries -gt 0){[math]::Round($falsePositives/$proactive.entries*100, 1)}else{0})%)"
            Write-Host "    [$(if($pass3){'PASS'}else{'FAIL'})] 1+ critical early (target: 1+, actual: $criticalEarly)"
            Write-Host "  OVERALL: $(if($pass1 -and $pass2 -and $pass3){'PASS'}else{'FAIL'})" -ForegroundColor $(if($pass1 -and $pass2 -and $pass3){'Green'}else{'Red'})
        } else {
            Write-Host "  [NO DATA]" -ForegroundColor Red
        }

        Write-Host "`n========================================" -ForegroundColor Cyan
    }
}
