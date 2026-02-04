# optimization-regret-detector.ps1
# Detects cases where we decided NOT to optimize, but should have

param(
    [ValidateSet('log', 'check', 'report')]
    [string]$Action = 'report',

    [string]$DecisionId,
    [string]$What,
    [string]$WhyNot,
    [string]$ActualImpact
)

$regretPath = "C:\scripts\agentidentity\state\optimization-regrets.yaml"

# Initialize if doesn't exist
if (-not (Test-Path $regretPath)) {
    @{
        no_optimize_decisions = @()
        regrets = @()
        metadata = @{
            created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            regret_rate = 0.0
        }
    } | ConvertTo-Yaml | Out-File -FilePath $regretPath -Encoding UTF8
}

# Read current data
$data = Get-Content $regretPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'log' {
        if (-not $DecisionId -or -not $What -or -not $WhyNot) {
            Write-Host "❌ Error: -DecisionId, -What, and -WhyNot required" -ForegroundColor Red
            return
        }

        $decision = @{
            id = $DecisionId
            what = $What
            why_not = $WhyNot
            decided_at = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            status = "monitoring"
        }

        $data.no_optimize_decisions += $decision
        $data | ConvertTo-Yaml | Out-File -FilePath $regretPath -Encoding UTF8

        Write-Host "✅ No-optimize decision logged: $What" -ForegroundColor Green
        Write-Host "   Reason: $WhyNot" -ForegroundColor DarkGray
        Write-Host "   ID: $DecisionId" -ForegroundColor DarkGray
    }

    'check' {
        if (-not $DecisionId -or -not $ActualImpact) {
            Write-Host "❌ Error: -DecisionId and -ActualImpact required" -ForegroundColor Red
            return
        }

        $decision = $data.no_optimize_decisions | Where-Object { $_.id -eq $DecisionId }
        if (-not $decision) {
            Write-Host "❌ Error: Decision ID '$DecisionId' not found" -ForegroundColor Red
            return
        }

        # Check if actual impact suggests we should have optimized
        $shouldHaveOptimized = $false
        $severity = "none"

        # Pattern matching on actual impact
        if ($ActualImpact -match "user.*complain" -or $ActualImpact -match "slow.*critical") {
            $shouldHaveOptimized = $true
            $severity = "high"
        } elseif ($ActualImpact -match "performance.*issue" -or $ActualImpact -match "bottleneck") {
            $shouldHaveOptimized = $true
            $severity = "medium"
        } elseif ($ActualImpact -match "could.*better" -or $ActualImpact -match "noticeable") {
            $shouldHaveOptimized = $true
            $severity = "low"
        }

        $decision.actual_impact = $ActualImpact
        $decision.checked_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        if ($shouldHaveOptimized) {
            $decision.status = "regret"
            $decision.severity = $severity

            # Add to regrets list
            $data.regrets += @{
                original_decision = $decision.id
                what = $decision.what
                why_not = $decision.why_not
                actual_impact = $ActualImpact
                severity = $severity
                learned_at = $decision.checked_at
            }

            # Update regret rate
            $totalDecisions = $data.no_optimize_decisions.Count
            $totalRegrets = $data.regrets.Count
            $data.metadata.regret_rate = [Math]::Round(($totalRegrets / $totalDecisions) * 100, 1)

            Write-Host "⚠️  REGRET DETECTED: Should have optimized!" -ForegroundColor Red
            Write-Host "   What: $($decision.what)" -ForegroundColor Yellow
            Write-Host "   Why we didn't: $($decision.why_not)" -ForegroundColor Gray
            Write-Host "   Actual impact: $ActualImpact" -ForegroundColor Yellow
            Write-Host "   Severity: " -NoNewline -ForegroundColor Gray

            switch ($severity) {
                'high' { Write-Host "HIGH" -ForegroundColor Red }
                'medium' { Write-Host "MEDIUM" -ForegroundColor Yellow }
                'low' { Write-Host "LOW" -ForegroundColor Cyan }
            }
        } else {
            $decision.status = "validated"
            Write-Host "✅ Decision validated: Correctly chose not to optimize" -ForegroundColor Green
            Write-Host "   What: $($decision.what)" -ForegroundColor White
            Write-Host "   Impact: $ActualImpact" -ForegroundColor Gray
        }

        $data | ConvertTo-Yaml | Out-File -FilePath $regretPath -Encoding UTF8
    }

    'report' {
        $totalDecisions = $data.no_optimize_decisions.Count
        $totalRegrets = $data.regrets.Count
        $validated = ($data.no_optimize_decisions | Where-Object { $_.status -eq "validated" }).Count

        if ($totalDecisions -eq 0) {
            Write-Host "`n📊 No optimization decisions tracked yet" -ForegroundColor Yellow
            return
        }

        Write-Host "`n📊 OPTIMIZATION REGRET ANALYSIS" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "Total 'No Optimize' Decisions: " -NoNewline -ForegroundColor Gray
        Write-Host $totalDecisions -ForegroundColor White
        Write-Host "Validated (Correct): " -NoNewline -ForegroundColor Gray
        Write-Host $validated -ForegroundColor Green
        Write-Host "Regrets (Should Have): " -NoNewline -ForegroundColor Gray
        Write-Host $totalRegrets -ForegroundColor $(if ($totalRegrets -gt 0) { "Red" } else { "Green" })
        Write-Host "Regret Rate: " -NoNewline -ForegroundColor Gray

        if ($totalDecisions -gt 0) {
            $regretRate = [Math]::Round(($totalRegrets / $totalDecisions) * 100, 1)
            $color = if ($regretRate -eq 0) { "Green" } elseif ($regretRate -lt 10) { "Yellow" } else { "Red" }
            Write-Host "$regretRate%" -ForegroundColor $color
        } else {
            Write-Host "N/A" -ForegroundColor DarkGray
        }

        if ($totalRegrets -gt 0) {
            Write-Host "`n⚠️  Recent Regrets:" -ForegroundColor Red
            foreach ($regret in ($data.regrets | Select-Object -Last 5)) {
                Write-Host "  • " -NoNewline -ForegroundColor DarkGray
                Write-Host $regret.what -NoNewline -ForegroundColor Yellow
                Write-Host " [$($regret.severity)]" -ForegroundColor $(
                    switch ($regret.severity) {
                        'high' { "Red" }
                        'medium' { "Yellow" }
                        'low' { "Cyan" }
                    }
                )
                Write-Host "    Impact: " -NoNewline -ForegroundColor DarkGray
                Write-Host $regret.actual_impact -ForegroundColor Gray
            }

            Write-Host "`n💡 Patterns to Learn:" -ForegroundColor Cyan
            $highSeverity = ($data.regrets | Where-Object { $_.severity -eq "high" }).Count
            if ($highSeverity -gt 0) {
                Write-Host "  • $highSeverity high-severity regrets - tighten thresholds" -ForegroundColor Red
            }

            # Pattern detection
            $reasons = $data.regrets | Group-Object -Property why_not
            if ($reasons.Count -gt 0) {
                Write-Host "  • Common bad reasons:" -ForegroundColor Yellow
                foreach ($reason in ($reasons | Sort-Object -Property Count -Descending | Select-Object -First 3)) {
                    Write-Host "    - '$($reason.Name)' ($($reason.Count) times)" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "`n✅ No regrets! All 'no optimize' decisions were correct." -ForegroundColor Green
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host ""
    }
}
