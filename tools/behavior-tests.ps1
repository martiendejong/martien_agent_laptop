#!/usr/bin/env pwsh
# behavior-tests.ps1 - Behavioral Verification Testing
# Proves learnings are actually changing behavior over time

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("run", "report", "trend", "reset")]
    [string]$Action = "run",

    [Parameter(Mandatory=$false)]
    [string]$SessionLogPath = "C:\scripts\_machine\current-session-log.jsonl",

    [Parameter(Mandatory=$false)]
    [string]$TestsPath = "C:\scripts\_machine\behavior-tests.yaml",

    [Parameter(Mandatory=$false)]
    [switch]$Detailed = $false,

    [Parameter(Mandatory=$false)]
    [string]$TestId = $null
)

$ErrorActionPreference = "Stop"

# Load YAML functions
function ConvertFrom-Yaml {
    param([string]$Content)

    # Simple YAML parser for our structure
    # For production, use powershell-yaml module
    # This is a minimal parser for our specific format

    $lines = $Content -split "`n"
    $result = @{}
    $currentSection = $null
    $currentTest = $null
    $inTests = $false

    foreach ($line in $lines) {
        $line = $line.TrimEnd()

        if ($line -match '^tests:') {
            $inTests = $true
            $result['tests'] = @()
            continue
        }

        if ($inTests -and $line -match '^\s*-\s+id:\s*"(.+)"') {
            $currentTest = @{
                id = $Matches[1]
                trend = @()
            }
            $result['tests'] += $currentTest
            continue
        }

        if ($currentTest -and $line -match '^\s+(\w+):\s*(.+)') {
            $key = $Matches[1]
            $value = $Matches[2].Trim('"')

            # Parse special values
            if ($value -eq 'null') { $value = $null }
            elseif ($value -eq 'true') { $value = $true }
            elseif ($value -eq 'false') { $value = $false }
            elseif ($value -match '^\d+$') { $value = [int]$value }
            elseif ($value -eq '[]') { $value = @() }

            $currentTest[$key] = $value
        }
    }

    return $result
}

function ConvertTo-Yaml {
    param([hashtable]$Data)

    $yaml = @"
# Behavioral Verification Tests
# Auto-updated by behavior-tests.ps1
# Tracks if learnings are actually changing behavior over time

version: "1.0"
last_updated: "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')"

tests:
"@

    foreach ($test in $Data.tests) {
        $yaml += "`n  - id: `"$($test.id)`""
        foreach ($key in $test.Keys | Where-Object { $_ -ne 'id' -and $_ -ne 'trend' }) {
            $value = $test[$key]
            if ($null -eq $value) { $value = 'null' }
            elseif ($value -is [bool]) { $value = $value.ToString().ToLower() }
            elseif ($value -is [array] -and $value.Count -eq 0) { $value = '[]' }
            else { $value = "`"$value`"" }

            $yaml += "`n    $($key): $value"
        }

        # Handle trend array
        if ($test.trend -and $test.trend.Count -gt 0) {
            $yaml += "`n    trend:"
            foreach ($point in $test.trend) {
                $yaml += "`n      - {date: `"$($point.date)`", value: $($point.value)}"
            }
        } else {
            $yaml += "`n    trend: []"
        }
    }

    return $yaml
}

# Load tests configuration
if (-not (Test-Path $TestsPath)) {
    Write-Host "❌ Tests configuration not found: $TestsPath" -ForegroundColor Red
    Write-Host "   Run with -Action init to create default tests" -ForegroundColor Yellow
    exit 1
}

$testsContent = Get-Content $TestsPath -Raw
$tests = ConvertFrom-Yaml -Content $testsContent

switch ($Action) {
    "run" {
        Write-Host ""
        Write-Host "🧪 BEHAVIORAL VERIFICATION TESTS" -ForegroundColor Cyan
        Write-Host "=================================" -ForegroundColor Cyan
        Write-Host ""

        # Check if session log exists
        if (-not (Test-Path $SessionLogPath)) {
            Write-Host "⚠️  No session log found - cannot run tests yet" -ForegroundColor Yellow
            Write-Host "   Session log will be created during work" -ForegroundColor Gray
            exit 0
        }

        # Load session log
        $logContent = Get-Content $SessionLogPath -Raw -ErrorAction SilentlyContinue
        if (-not $logContent -or $logContent.Trim() -eq "") {
            Write-Host "⚠️  Session log is empty - not enough data" -ForegroundColor Yellow
            exit 0
        }

        $logEntries = $logContent -split "`n" | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
            $_ | ConvertFrom-Json
        }

        Write-Host "📊 Analyzing $($logEntries.Count) actions from current session..." -ForegroundColor Gray
        Write-Host ""

        $results = @{
            passed = 0
            failed = 0
            monitoring = 0
            skipped = 0
        }

        # Run each test
        foreach ($test in $tests.tests) {
            if ($TestId -and $test.id -ne $TestId) { continue }

            Write-Host "[$($test.id)]" -ForegroundColor Cyan -NoNewline
            Write-Host " $($test.name)"

            # Calculate current value based on test type
            $currentValue = $null
            $passed = $null

            switch ($test.category) {
                "frequency_reduction" {
                    # Count occurrences of action
                    $actionPattern = switch ($test.id) {
                        "doc-lookup-claude-md" { "Read CLAUDE.md" }
                        "doc-lookup-api-patterns" { "Read API_PATTERNS.md" }
                        default { $null }
                    }

                    if ($actionPattern) {
                        $count = ($logEntries | Where-Object { $_.action -like "*$actionPattern*" }).Count
                        $currentValue = $count

                        if ($null -eq $test.baseline) {
                            Write-Host "   📈 Baseline: $count (establishing baseline)" -ForegroundColor Yellow
                            $test.baseline = $count
                            $test.first_measured = Get-Date -Format "yyyy-MM-dd"
                            $results.monitoring++
                        } else {
                            $targetValue = [math]::Ceiling($test.baseline * 0.3)
                            $passed = $count -le $targetValue

                            if ($passed) {
                                Write-Host "   ✅ PASS: $count occurrences (target: ≤$targetValue, baseline: $($test.baseline))" -ForegroundColor Green
                                $test.last_pass = Get-Date -Format "yyyy-MM-dd"
                                $results.passed++
                            } else {
                                Write-Host "   ❌ FAIL: $count occurrences (target: ≤$targetValue, baseline: $($test.baseline))" -ForegroundColor Red
                                $test.fail_count++
                                $results.failed++
                            }
                        }
                    }
                }

                "prevention" {
                    # Check for repeated errors
                    $errorPattern = switch ($test.id) {
                        "no-repeated-build-errors" { "build" }
                        "no-repeated-migration-errors" { "migration" }
                        default { $null }
                    }

                    if ($errorPattern) {
                        $errors = $logEntries | Where-Object {
                            $_.outcome -like "*error*" -or $_.outcome -like "*fail*"
                        }
                        $errorActions = $errors | Group-Object -Property action
                        $repeatedErrors = $errorActions | Where-Object { $_.Count -ge 2 }

                        $currentValue = if ($repeatedErrors) { $true } else { $false }
                        $passed = -not $currentValue

                        if ($passed) {
                            Write-Host "   ✅ PASS: No repeated errors detected" -ForegroundColor Green
                            $test.last_pass = Get-Date -Format "yyyy-MM-dd"
                            $results.passed++
                        } else {
                            Write-Host "   ❌ FAIL: $($repeatedErrors.Count) action(s) failed multiple times" -ForegroundColor Red
                            foreach ($err in $repeatedErrors) {
                                Write-Host "      • $($err.Name) - failed $($err.Count) times" -ForegroundColor Red
                            }
                            $test.fail_count++
                            $results.failed++
                        }
                    }
                }

                "compliance" {
                    # Check workflow compliance
                    $checkPattern = switch ($test.id) {
                        "worktree-released-before-pr" {
                            # Check if worktree release happened before PR presentation
                            $prCreated = $logEntries | Where-Object { $_.action -like "*PR*" -or $_.action -like "*pull request*" }
                            $worktreeReleased = $logEntries | Where-Object { $_.action -like "*release*worktree*" -or $_.action -like "*worktree*release*" }

                            if ($prCreated.Count -gt 0) {
                                # Check timestamps
                                $compliant = $worktreeReleased.Count -ge $prCreated.Count
                                $currentValue = if ($compliant) { 100 } else { 0 }
                                $passed = $compliant

                                if ($passed) {
                                    Write-Host "   ✅ PASS: Worktree released before PR" -ForegroundColor Green
                                    $test.last_pass = Get-Date -Format "yyyy-MM-dd"
                                    $results.passed++
                                } else {
                                    Write-Host "   ❌ FAIL: PR created but worktree not released" -ForegroundColor Red
                                    $test.fail_count++
                                    $results.failed++
                                }
                            } else {
                                Write-Host "   ⏭️  SKIP: No PRs created this session" -ForegroundColor Gray
                                $results.skipped++
                            }
                        }

                        "develop-merged-before-pr" {
                            # Check if develop merge happened before PR
                            $prCreated = $logEntries | Where-Object { $_.action -like "*PR*" -or $_.action -like "*pull request*" }
                            $developMerged = $logEntries | Where-Object { $_.action -like "*merge*develop*" }

                            if ($prCreated.Count -gt 0) {
                                $compliant = $developMerged.Count -gt 0
                                $currentValue = if ($compliant) { 100 } else { 0 }
                                $passed = $compliant

                                if ($passed) {
                                    Write-Host "   ✅ PASS: Develop merged before PR" -ForegroundColor Green
                                    $test.last_pass = Get-Date -Format "yyyy-MM-dd"
                                    $results.passed++
                                } else {
                                    Write-Host "   ❌ FAIL: PR created without merging develop" -ForegroundColor Red
                                    $test.fail_count++
                                    $results.failed++
                                }
                            } else {
                                Write-Host "   ⏭️  SKIP: No PRs created this session" -ForegroundColor Gray
                                $results.skipped++
                            }
                        }

                        default {
                            Write-Host "   ⏭️  SKIP: Not implemented yet" -ForegroundColor Gray
                            $results.skipped++
                        }
                    }
                }

                "efficiency" {
                    # Efficiency metrics (time/count based)
                    switch ($test.id) {
                        "quick-refs-created" {
                            # Check _machine/quick-refs directory
                            $quickRefsPath = "C:\scripts\_machine\quick-refs"
                            if (Test-Path $quickRefsPath) {
                                $recentRefs = Get-ChildItem $quickRefsPath -Filter "*.md" -ErrorAction SilentlyContinue |
                                    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }
                                $currentValue = $recentRefs.Count

                                $passed = $currentValue -ge 1

                                if ($passed) {
                                    Write-Host "   ✅ PASS: $currentValue quick-ref(s) created this week" -ForegroundColor Green
                                    $test.last_pass = Get-Date -Format "yyyy-MM-dd"
                                    $results.passed++
                                } else {
                                    Write-Host "   ⚠️  WARN: No quick-refs created this week" -ForegroundColor Yellow
                                    $results.monitoring++
                                }
                            } else {
                                Write-Host "   ⏭️  SKIP: Quick-refs directory not found" -ForegroundColor Gray
                                $results.skipped++
                            }
                        }

                        "lessons-learned" {
                            # Check learned-lessons.md
                            $lessonsPath = "C:\scripts\_machine\learned-lessons.md"
                            if (Test-Path $lessonsPath) {
                                $content = Get-Content $lessonsPath -Raw
                                $recentLessons = ([regex]::Matches($content, '## 2026-\d{2}-\d{2}') |
                                    Where-Object {
                                        $date = [datetime]::ParseExact($_.Value.Substring(3), "yyyy-MM-dd", $null)
                                        $date -gt (Get-Date).AddDays(-7)
                                    }).Count

                                $currentValue = $recentLessons
                                $passed = $currentValue -ge 1

                                if ($passed) {
                                    Write-Host "   ✅ PASS: $currentValue lesson(s) logged this week" -ForegroundColor Green
                                    $test.last_pass = Get-Date -Format "yyyy-MM-dd"
                                    $results.passed++
                                } else {
                                    Write-Host "   ⏭️  INFO: No lessons logged this week (good if no errors!)" -ForegroundColor Gray
                                    $results.monitoring++
                                }
                            } else {
                                Write-Host "   ⏭️  SKIP: Lessons file not found" -ForegroundColor Gray
                                $results.skipped++
                            }
                        }

                        default {
                            Write-Host "   ⏭️  SKIP: Not implemented yet" -ForegroundColor Gray
                            $results.skipped++
                        }
                    }
                }
            }

            # Update test metrics
            if ($null -ne $currentValue) {
                $test.current_value = $currentValue
                $test.sessions_tracked++

                # Add to trend
                if (-not $test.trend) { $test.trend = @() }
                $test.trend += @{
                    date = Get-Date -Format "yyyy-MM-dd"
                    value = $currentValue
                }

                # Keep only last 30 data points
                if ($test.trend.Count -gt 30) {
                    $test.trend = $test.trend[-30..-1]
                }
            }

            if ($null -ne $passed) {
                $test.status = if ($passed) { "passing" } else { "failing" }
            }

            Write-Host ""
        }

        # Overall summary
        $total = $results.passed + $results.failed + $results.monitoring + $results.skipped
        $passRate = if ($total -gt 0) { [math]::Round(($results.passed / ($results.passed + $results.failed)) * 100, 1) } else { 0 }

        Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
        Write-Host "📊 SUMMARY" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Tests Run:      $total" -ForegroundColor White
        Write-Host "✅ Passed:      $($results.passed)" -ForegroundColor Green
        Write-Host "❌ Failed:      $($results.failed)" -ForegroundColor Red
        Write-Host "📈 Monitoring:  $($results.monitoring)" -ForegroundColor Yellow
        Write-Host "⏭️  Skipped:     $($results.skipped)" -ForegroundColor Gray
        Write-Host ""

        if ($results.passed + $results.failed -gt 0) {
            $healthColor = if ($passRate -ge 95) { "Green" }
                          elseif ($passRate -ge 85) { "Cyan" }
                          elseif ($passRate -ge 70) { "Yellow" }
                          else { "Red" }

            Write-Host "Pass Rate: $passRate%" -ForegroundColor $healthColor

            $health = if ($passRate -ge 95) { "EXCELLENT ⭐" }
                     elseif ($passRate -ge 85) { "GOOD ✅" }
                     elseif ($passRate -ge 70) { "WARNING ⚠️" }
                     else { "CRITICAL 🚨" }

            Write-Host "Overall Health: $health" -ForegroundColor $healthColor
        } else {
            Write-Host "Overall Health: INITIALIZING (not enough data)" -ForegroundColor Yellow
        }

        Write-Host ""

        # Save updated tests
        $updatedYaml = ConvertTo-Yaml -Data $tests
        $updatedYaml | Out-File -FilePath $TestsPath -Encoding utf8 -Force

        Write-Host "💾 Test results saved to: $TestsPath" -ForegroundColor Gray
        Write-Host ""
    }

    "report" {
        Write-Host ""
        Write-Host "📈 BEHAVIORAL TRENDS REPORT" -ForegroundColor Cyan
        Write-Host "============================" -ForegroundColor Cyan
        Write-Host ""

        foreach ($test in $tests.tests) {
            if ($TestId -and $test.id -ne $TestId) { continue }

            Write-Host "[$($test.id)] $($test.name)" -ForegroundColor Cyan
            Write-Host "   Category: $($test.category)" -ForegroundColor Gray
            Write-Host "   Status: $($test.status)" -ForegroundColor $(if ($test.status -eq 'passing') { 'Green' } elseif ($test.status -eq 'failing') { 'Red' } else { 'Yellow' })

            if ($test.baseline) {
                Write-Host "   Baseline: $($test.baseline)" -ForegroundColor Gray
            }

            if ($test.current_value) {
                Write-Host "   Current: $($test.current_value)" -ForegroundColor White
            }

            if ($test.trend -and $test.trend.Count -gt 0) {
                Write-Host "   Trend: ($($test.trend.Count) data points)" -ForegroundColor Gray

                # Simple ASCII trend visualization
                $values = $test.trend | ForEach-Object { $_.value }
                $min = ($values | Measure-Object -Minimum).Minimum
                $max = ($values | Measure-Object -Maximum).Maximum
                $range = $max - $min

                if ($range -gt 0) {
                    $normalized = $values | ForEach-Object {
                        [math]::Round((($_ - $min) / $range) * 10)
                    }

                    $chart = ""
                    foreach ($val in $normalized) {
                        $chart += switch ($val) {
                            { $_ -le 2 } { "▁" }
                            { $_ -le 4 } { "▃" }
                            { $_ -le 6 } { "▅" }
                            { $_ -le 8 } { "▇" }
                            default { "█" }
                        }
                    }

                    Write-Host "   $chart" -ForegroundColor Cyan
                    Write-Host "   ↓ Better (for frequency_reduction/efficiency)" -ForegroundColor Gray
                }
            }

            if ($test.fail_count -gt 0) {
                Write-Host "   Failures: $($test.fail_count)" -ForegroundColor Red
            }

            if ($test.last_pass) {
                Write-Host "   Last Pass: $($test.last_pass)" -ForegroundColor Green
            }

            Write-Host ""
        }
    }

    "trend" {
        # Show specific test trend in detail
        if (-not $TestId) {
            Write-Host "❌ -TestId required for trend view" -ForegroundColor Red
            exit 1
        }

        $test = $tests.tests | Where-Object { $_.id -eq $TestId } | Select-Object -First 1
        if (-not $test) {
            Write-Host "❌ Test not found: $TestId" -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "📊 TREND ANALYSIS: $($test.name)" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""

        if (-not $test.trend -or $test.trend.Count -eq 0) {
            Write-Host "⚠️  No trend data available yet" -ForegroundColor Yellow
            exit 0
        }

        # Show table
        Write-Host "Date         | Value | Change" -ForegroundColor Gray
        Write-Host "-------------|-------|-------" -ForegroundColor Gray

        $prevValue = $null
        foreach ($point in $test.trend) {
            $change = if ($prevValue) {
                $diff = $point.value - $prevValue
                $arrow = if ($diff -gt 0) { "↑" } elseif ($diff -lt 0) { "↓" } else { "→" }
                "$arrow $diff"
            } else {
                "-"
            }

            Write-Host "$($point.date) | $($point.value)     | $change"
            $prevValue = $point.value
        }

        Write-Host ""

        # Calculate improvement
        if ($test.trend.Count -ge 2) {
            $first = $test.trend[0].value
            $last = $test.trend[-1].value
            $improvement = $last - $first
            $improvementPct = if ($first -gt 0) { [math]::Round((($last - $first) / $first) * 100, 1) } else { 0 }

            $improvementColor = if ($improvement -lt 0) { "Green" } else { "Red" }  # For frequency reduction, lower is better
            Write-Host "Overall Change: $improvement ($improvementPct%)" -ForegroundColor $improvementColor
        }

        Write-Host ""
    }

    "reset" {
        Write-Host "🔄 Resetting all test data..." -ForegroundColor Yellow

        foreach ($test in $tests.tests) {
            $test.baseline = $null
            $test.current_value = $null
            $test.status = "monitoring"
            $test.first_measured = $null
            $test.last_pass = $null
            $test.fail_count = 0
            $test.sessions_tracked = 0
            $test.trend = @()
        }

        $updatedYaml = ConvertTo-Yaml -Data $tests
        $updatedYaml | Out-File -FilePath $TestsPath -Encoding utf8 -Force

        Write-Host "✅ All tests reset to initial state" -ForegroundColor Green
    }
}
