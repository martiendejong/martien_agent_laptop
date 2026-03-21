<#
.SYNOPSIS
    Automated test execution and reporting for PRs

.DESCRIPTION
    Quality gate that automatically runs tests after PR creation:
    - Executes dotnet test (backend) and npm test (frontend)
    - Calculates coverage delta vs baseline
    - Analyzes failed tests (parse logs, extract root causes)
    - Posts results as PR comment with status badges
    - Integrates with Browser MCP for visual regression (future)

.PARAMETER PrNumber
    PR number to test

.PARAMETER Repo
    Repository name (e.g., "client-manager", "hazina")

.PARAMETER PostComment
    Post results as PR comment (default: true)

.PARAMETER UpdateBaseline
    Update coverage baseline after successful test run

.EXAMPLE
    .\test-automation-bridge.ps1 -PrNumber 587 -Repo client-manager
    .\test-automation-bridge.ps1 -PrNumber 195 -Repo hazina -UpdateBaseline
#>

param(
    [Parameter(Mandatory=$true)]
    [int]$PrNumber,

    [Parameter(Mandatory=$true)]
    [ValidateSet("client-manager", "hazina", "artrevisionist")]
    [string]$Repo,

    [switch]$PostComment = $true,
    [switch]$UpdateBaseline
)

$ErrorActionPreference = "Continue"

# Paths
$repoPath = "C:\Projects\$Repo"
$baselineDir = "C:\scripts\_machine\test-baselines\$Repo"
$reportPath = "E:\jengo\documents\temp\test-report-$Repo-$PrNumber.md"

# Ensure baseline directory exists
if (-not (Test-Path $baselineDir)) {
    New-Item -ItemType Directory -Path $baselineDir -Force | Out-Null
}

Write-Host "=== Automated Test Bridge ===" -ForegroundColor Cyan
Write-Host "Repository: $Repo" -ForegroundColor Gray
Write-Host "PR: #$PrNumber" -ForegroundColor Gray
Write-Host ""

# ============================================================================
# 1. CHECKOUT PR BRANCH
# ============================================================================

Write-Host "[1/5] Checking out PR branch..." -ForegroundColor Yellow

Push-Location $repoPath

try {
    # Get PR branch name
    $prInfo = gh pr view $PrNumber --json headRefName --jq .headRefName 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Could not find PR #$PrNumber" -ForegroundColor Red
        Pop-Location
        exit 1
    }

    $branch = $prInfo.Trim()
    Write-Host "  Branch: $branch" -ForegroundColor Gray

    # Fetch and checkout
    git fetch origin $branch 2>&1 | Out-Null
    git checkout $branch 2>&1 | Out-Null

    Write-Host "  Checked out $branch" -ForegroundColor Green
} catch {
    Write-Host "Error checking out branch: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

# ============================================================================
# 2. RUN BACKEND TESTS (.NET)
# ============================================================================

Write-Host "[2/5] Running backend tests..." -ForegroundColor Yellow

$dotnetTestResults = @{
    Ran = $false
    Success = $false
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    SkippedTests = 0
    Duration = 0
    Coverage = 0
    CoverageDelta = 0
    FailedTestDetails = @()
}

# Find test projects
$testProjects = Get-ChildItem -Path $repoPath -Filter "*.Tests.csproj" -Recurse

if ($testProjects.Count -gt 0) {
    $dotnetTestResults.Ran = $true

    foreach ($testProject in $testProjects) {
        Write-Host "  Testing $($testProject.Name)..." -ForegroundColor Gray

        $testOutput = dotnet test $testProject.FullName `
            --logger "trx;LogFileName=test-results.trx" `
            --collect:"XPlat Code Coverage" `
            --results-directory "TestResults" `
            2>&1 | Out-String

        # Parse test results
        if ($testOutput -match "Passed! *- *Failed: *(\d+), *Passed: *(\d+), *Skipped: *(\d+), *Total: *(\d+)") {
            $failed = [int]$matches[1]
            $passed = [int]$matches[2]
            $skipped = [int]$matches[3]
            $total = [int]$matches[4]

            $dotnetTestResults.TotalTests += $total
            $dotnetTestResults.PassedTests += $passed
            $dotnetTestResults.FailedTests += $failed
            $dotnetTestResults.SkippedTests += $skipped

            if ($failed -eq 0) {
                $dotnetTestResults.Success = $true
            }
        }

        # Parse duration
        if ($testOutput -match "Time: *(\d+\.\d+)s") {
            $dotnetTestResults.Duration += [double]$matches[1]
        }

        # Parse coverage (if available)
        $coverageFiles = Get-ChildItem -Path "TestResults" -Filter "coverage.cobertura.xml" -Recurse -ErrorAction SilentlyContinue

        if ($coverageFiles.Count -gt 0) {
            # Parse Cobertura coverage XML
            $coverageXml = [xml](Get-Content $coverageFiles[0].FullName)
            $lineRate = [double]$coverageXml.coverage.'line-rate'
            $dotnetTestResults.Coverage = [math]::Round($lineRate * 100, 1)

            # Compare with baseline
            $baselinePath = Join-Path $baselineDir "dotnet-coverage.txt"
            if (Test-Path $baselinePath) {
                $baselineCoverage = [double](Get-Content $baselinePath)
                $dotnetTestResults.CoverageDelta = [math]::Round($dotnetTestResults.Coverage - $baselineCoverage, 1)
            }

            # Update baseline if requested
            if ($UpdateBaseline) {
                $dotnetTestResults.Coverage | Out-File -FilePath $baselinePath -Encoding UTF8
            }
        }

        # Parse failed test details
        if ($dotnetTestResults.FailedTests -gt 0) {
            $trxFiles = Get-ChildItem -Path "TestResults" -Filter "*.trx" -Recurse -ErrorAction SilentlyContinue

            foreach ($trxFile in $trxFiles) {
                [xml]$trx = Get-Content $trxFile.FullName

                $failedTests = $trx.TestRun.Results.UnitTestResult | Where-Object { $_.outcome -eq "Failed" }

                foreach ($test in $failedTests) {
                    $testName = $test.testName
                    $errorMessage = $test.Output.ErrorInfo.Message
                    $stackTrace = $test.Output.ErrorInfo.StackTrace

                    $dotnetTestResults.FailedTestDetails += @{
                        Name = $testName
                        Message = $errorMessage
                        StackTrace = $stackTrace
                    }
                }
            }
        }
    }

    Write-Host "  Backend tests completed" -ForegroundColor Green
} else {
    Write-Host "  No .NET test projects found" -ForegroundColor Gray
}

# ============================================================================
# 3. RUN FRONTEND TESTS (npm)
# ============================================================================

Write-Host "[3/5] Running frontend tests..." -ForegroundColor Yellow

$npmTestResults = @{
    Ran = $false
    Success = $false
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    Duration = 0
    FailedTestDetails = @()
}

# Find package.json with test script (exclude node_modules)
$packageJsonFiles = Get-ChildItem -Path $repoPath -Filter "package.json" -Recurse | Where-Object {
    $_.FullName -notmatch "\\node_modules\\" -and
    (Test-Path (Join-Path $_.DirectoryName "package.json")) -and
    ($_ | Get-Content | ConvertFrom-Json).scripts.test -ne $null
}

if ($packageJsonFiles.Count -gt 0) {
    $npmTestResults.Ran = $true

    foreach ($packageJson in $packageJsonFiles) {
        $npmProjectDir = Split-Path $packageJson.FullName -Parent
        Push-Location $npmProjectDir

        Write-Host "  Testing npm project at $($npmProjectDir)..." -ForegroundColor Gray

        $npmOutput = npm test 2>&1 | Out-String

        # Parse Jest results (common format)
        if ($npmOutput -match "Tests: *(\d+) failed, *(\d+) passed, *(\d+) total") {
            $failed = [int]$matches[1]
            $passed = [int]$matches[2]
            $total = [int]$matches[3]

            $npmTestResults.TotalTests += $total
            $npmTestResults.PassedTests += $passed
            $npmTestResults.FailedTests += $failed

            if ($failed -eq 0) {
                $npmTestResults.Success = $true
            }
        } elseif ($npmOutput -match "Tests: *(\d+) passed, *(\d+) total") {
            $passed = [int]$matches[1]
            $total = [int]$matches[2]

            $npmTestResults.TotalTests += $total
            $npmTestResults.PassedTests += $passed
            $npmTestResults.Success = $true
        }

        # Parse duration
        if ($npmOutput -match "Time: *(\d+\.\d+) *s") {
            $npmTestResults.Duration += [double]$matches[1]
        }

        Pop-Location
    }

    Write-Host "  Frontend tests completed" -ForegroundColor Green
} else {
    Write-Host "  No npm test scripts found" -ForegroundColor Gray
}

# ============================================================================
# 4. GENERATE TEST REPORT
# ============================================================================

Write-Host "[4/5] Generating test report..." -ForegroundColor Yellow

$overallSuccess = ($dotnetTestResults.Ran -eq $false -or $dotnetTestResults.Success) -and
                  ($npmTestResults.Ran -eq $false -or $npmTestResults.Success)

$statusBadge = if ($overallSuccess) { "[PASS] PASSING" } else { "[FAIL] FAILING" }
$statusColor = if ($overallSuccess) { "green" } else { "red" }

$totalTests = $dotnetTestResults.TotalTests + $npmTestResults.TotalTests
$totalPassed = $dotnetTestResults.PassedTests + $npmTestResults.PassedTests
$totalFailed = $dotnetTestResults.FailedTests + $npmTestResults.FailedTests

$report = @"
# [TEST] Automated Test Report - PR #$PrNumber

**Status:** $statusBadge
**Repository:** $Repo
**Branch:** $branch
**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

## Summary

| Metric | Backend (.NET) | Frontend (npm) | Total |
|--------|----------------|----------------|-------|
| **Tests Run** | $($dotnetTestResults.TotalTests) | $($npmTestResults.TotalTests) | $totalTests |
| **Passed** | $($dotnetTestResults.PassedTests) | $($npmTestResults.PassedTests) | $totalPassed |
| **Failed** | $($dotnetTestResults.FailedTests) | $($npmTestResults.FailedTests) | $totalFailed |
| **Skipped** | $($dotnetTestResults.SkippedTests) | - | $($dotnetTestResults.SkippedTests) |
| **Duration** | $($dotnetTestResults.Duration)s | $($npmTestResults.Duration)s | $($dotnetTestResults.Duration + $npmTestResults.Duration)s |

---

## Coverage

$(if ($dotnetTestResults.Coverage -gt 0) {
@"
**Backend Coverage:** $($dotnetTestResults.Coverage)%
$(if ($dotnetTestResults.CoverageDelta -ne 0) {
    $deltaSymbol = if ($dotnetTestResults.CoverageDelta -gt 0) { "[UP]" } else { "[DOWN]" }
    $deltaSign = if ($dotnetTestResults.CoverageDelta -gt 0) { "+" } else { "" }
    "$deltaSymbol **Delta:** $deltaSign$($dotnetTestResults.CoverageDelta)%"
})
"@
} else {
    "_Coverage data not available_"
})

---

## Failed Tests

$(if ($totalFailed -eq 0) {
    "[PASS] All tests passed!"
} else {
    # Backend failures
    if ($dotnetTestResults.FailedTestDetails.Count -gt 0) {
        $backendFailures = @"
### Backend (.NET)

$($dotnetTestResults.FailedTestDetails | ForEach-Object {
@"
**Test:** ``$($_.Name)``

**Error:**
``````
$($_.Message)
``````

**Stack Trace:**
``````
$($_.StackTrace -split "`n" | Select-Object -First 10 | Out-String)
``````

---
"@
} | Out-String)
"@
        $backendFailures
    }

    # Frontend failures
    if ($npmTestResults.FailedTestDetails.Count -gt 0) {
        $frontendFailures = @"
### Frontend (npm)

$($npmTestResults.FailedTestDetails | ForEach-Object {
@"
**Test:** ``$($_.Name)``

**Error:**
``````
$($_.Message)
``````

---
"@
} | Out-String)
"@
        $frontendFailures
    }
})

---

## Recommended Actions

$(if ($overallSuccess) {
    "[PASS] All tests passing - ready for review!"
} else {
    @"
1. Review failed test details above
2. Fix failing tests locally
3. Push fixes to branch
4. Tests will re-run automatically

Common issues:
- Check for missing dependencies or configuration
- Verify test data and mocks are correct
- Run tests locally: ``dotnet test`` or ``npm test``
"@
})

---

**Next:** Tests will re-run automatically on next push to this PR branch.
"@

# Save report
$report | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "  Report saved: $reportPath" -ForegroundColor Green

# ============================================================================
# 5. POST PR COMMENT
# ============================================================================

if ($PostComment) {
    Write-Host "[5/5] Posting PR comment..." -ForegroundColor Yellow

    try {
        # Post comment to PR
        $comment = $report
        gh pr comment $PrNumber --repo "martiendejong/$Repo" --body $comment 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Comment posted to PR #$PrNumber" -ForegroundColor Green
        } else {
            Write-Host "  Warning: Could not post comment to PR" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  Warning: Could not post comment: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[5/5] Skipping PR comment (PostComment=$PostComment)" -ForegroundColor Gray
}

Pop-Location

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host ""
Write-Host "=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Status: $statusBadge" -ForegroundColor $statusColor
Write-Host "Total Tests: $totalTests ($totalPassed passed, $totalFailed failed)" -ForegroundColor Gray
if ($dotnetTestResults.Coverage -gt 0) {
    Write-Host "Coverage: $($dotnetTestResults.Coverage)% (delta: $($dotnetTestResults.CoverageDelta)%)" -ForegroundColor Gray
}
Write-Host "Report: $reportPath" -ForegroundColor Gray

# Return results object
return @{
    Success = $overallSuccess
    TotalTests = $totalTests
    PassedTests = $totalPassed
    FailedTests = $totalFailed
    Coverage = $dotnetTestResults.Coverage
    CoverageDelta = $dotnetTestResults.CoverageDelta
    ReportPath = $reportPath
    PrNumber = $PrNumber
    Repository = $Repo
    Branch = $branch
}
