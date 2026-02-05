# Regression Test Suite
# Prevent previously fixed bugs from returning

param(
    [switch]$Run,
    [switch]$AddTest,
    [string]$TestName,
    [string]$TestScript,
    [switch]$ListTests
)

$testsDir = "C:\scripts\_machine\regression-tests"
$resultsFile = "C:\scripts\_machine\regression-test-results.json"

if (!(Test-Path $testsDir)) {
    New-Item -ItemType Directory -Path $testsDir -Force | Out-Null
}

function Add-RegressionTest {
    param($Name, $Script)

    $testId = "reg-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    $testFile = Join-Path $testsDir "$testId.ps1"

    $testContent = @"
# Regression Test: $Name
# Created: $(Get-Date -Format "yyyy-MM-dd HH:mm")
# Test ID: $testId

# Test script
$Script

# Return 0 for pass, 1 for fail
"@

    $testContent | Set-Content $testFile

    Write-Host "Regression test added: $testId" -ForegroundColor Green
    Write-Host "  Name: $Name"
    Write-Host "  File: $testFile"
}

function Run-RegressionTests {
    Write-Host "Running regression tests..." -ForegroundColor Cyan

    $testFiles = Get-ChildItem -Path $testsDir -Filter "*.ps1"

    if ($testFiles.Count -eq 0) {
        Write-Host "No regression tests found" -ForegroundColor Yellow
        return
    }

    $results = @()
    $passed = 0
    $failed = 0

    foreach ($testFile in $testFiles) {
        Write-Host "`nRunning: $($testFile.Name)" -ForegroundColor Gray

        try {
            $exitCode = & $testFile.FullName
            $success = ($exitCode -eq 0)

            if ($success) {
                Write-Host "  PASS" -ForegroundColor Green
                $passed++
            } else {
                Write-Host "  FAIL (exit code: $exitCode)" -ForegroundColor Red
                $failed++
            }

            $results += @{
                test = $testFile.Name
                success = $success
                exitCode = $exitCode
                timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            }
        } catch {
            Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
            $failed++

            $results += @{
                test = $testFile.Name
                success = $false
                error = $_.Exception.Message
                timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            }
        }
    }

    # Save results
    $results | ConvertTo-Json -Depth 10 | Set-Content $resultsFile

    # Summary
    Write-Host "`n" + ("=" * 60)
    Write-Host "REGRESSION TEST SUMMARY" -ForegroundColor Cyan
    Write-Host ("=" * 60)
    Write-Host "Total tests: $($testFiles.Count)"
    Write-Host "Passed: $passed" -ForegroundColor Green
    Write-Host "Failed: $failed" $(if ($failed -gt 0) { "(ForegroundColor Red)" } else { "" })
    Write-Host ("=" * 60)

    if ($failed -gt 0) {
        exit 1
    } else {
        exit 0
    }
}

function List-RegressionTests {
    $testFiles = Get-ChildItem -Path $testsDir -Filter "*.ps1"

    Write-Host "`nREGRESSION TESTS" -ForegroundColor Cyan
    Write-Host ("=" * 60)

    if ($testFiles.Count -eq 0) {
        Write-Host "No regression tests found" -ForegroundColor Yellow
        return
    }

    foreach ($testFile in $testFiles) {
        $content = Get-Content $testFile.FullName -Raw
        $nameMatch = [regex]::Match($content, '# Regression Test: (.+)')
        $name = if ($nameMatch.Success) { $nameMatch.Groups[1].Value } else { "Unknown" }

        Write-Host "`n$($testFile.Name)" -ForegroundColor Yellow
        Write-Host "  Name: $name"
        Write-Host "  File: $($testFile.FullName)"
    }

    Write-Host "`n" + ("=" * 60)
}

# Main execution
if ($Run) {
    Run-RegressionTests
}
elseif ($AddTest) {
    if (!$TestName -or !$TestScript) {
        Write-Host "Usage: .\regression-test-suite.ps1 -AddTest -TestName 'Test name' -TestScript 'script content'"
        return
    }
    Add-RegressionTest -Name $TestName -Script $TestScript
}
elseif ($ListTests) {
    List-RegressionTests
}
else {
    Write-Host "REGRESSION TEST SUITE" -ForegroundColor Cyan
    Write-Host "Usage:"
    Write-Host "  Run tests: .\regression-test-suite.ps1 -Run"
    Write-Host "  Add test: .\regression-test-suite.ps1 -AddTest -TestName 'Name' -TestScript 'script'"
    Write-Host "  List tests: .\regression-test-suite.ps1 -ListTests"
    Write-Host ""
    Write-Host "Example:"
    Write-Host '  .\regression-test-suite.ps1 -AddTest -TestName "Tool syntax check" -TestScript "powershell -NoProfile -ExecutionPolicy Bypass -File tools/scan-tools-simple.ps1; return 0"'
}
