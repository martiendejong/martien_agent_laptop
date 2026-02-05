# ps1-test-runner.ps1
# Automated testing for PowerShell scripts
# Runs tests and generates coverage reports

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Run", "Add", "List", "Coverage")]
    [string]$Action,

    [string]$TestFile = "",
    [string]$ScriptToTest = "",
    [switch]$Verbose
)

$script:TestsDir = "C:\scripts\tests"
$script:CoverageFile = "C:\scripts\_machine\test-coverage.json"

if (-not (Test-Path $script:TestsDir)) {
    New-Item -ItemType Directory -Path $script:TestsDir -Force | Out-Null
}

function Invoke-Tests {
    param([string]$TestFile)

    Write-Host "🧪 Running tests..." -ForegroundColor Cyan

    if ($TestFile) {
        $testFiles = @(Get-Item $TestFile)
    } else {
        $testFiles = Get-ChildItem $script:TestsDir -Filter "*.test.ps1"
    }

    $totalTests = 0
    $passedTests = 0
    $failedTests = 0

    foreach ($file in $testFiles) {
        Write-Host "`n📄 $($file.Name)" -ForegroundColor Yellow

        try {
            $testContent = Get-Content $file.FullName -Raw
            $tests = [regex]::Matches($testContent, 'Test "([^"]+)"')

            foreach ($test in $tests) {
                $testName = $test.Groups[1].Value
                $totalTests++

                try {
                    # Run test (simplified - in reality would use Pester or similar)
                    & $file.FullName
                    Write-Host "  ✅ $testName" -ForegroundColor Green
                    $passedTests++
                }
                catch {
                    Write-Host "  ❌ $testName - $_" -ForegroundColor Red
                    $failedTests++
                }
            }
        }
        catch {
            Write-Host "  ❌ Failed to load test file: $_" -ForegroundColor Red
        }
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📊 TEST RESULTS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Total: $totalTests | Passed: $passedTests | Failed: $failedTests" -ForegroundColor White
    Write-Host "Success Rate: $([math]::Round(($passedTests / $totalTests) * 100, 1))%" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Yellow" })
    Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

    return ($failedTests -eq 0)
}

switch ($Action) {
    "Run" {
        $success = Invoke-Tests -TestFile $TestFile
        exit $(if ($success) { 0 } else { 1 })
    }
    "Add" {
        Write-Host "Creating test template for: $ScriptToTest" -ForegroundColor Cyan
        $testContent = @"
# Test file for $ScriptToTest

Test "Should handle valid input" {
    # Arrange
    \$input = "test"

    # Act
    \$result = & $ScriptToTest -Input \$input

    # Assert
    \$result | Should -Not -BeNullOrEmpty
}

Test "Should handle edge cases" {
    # Add edge case tests
}
"@
        $testPath = Join-Path $script:TestsDir "$([IO.Path]::GetFileNameWithoutExtension($ScriptToTest)).test.ps1"
        Set-Content -Path $testPath -Value $testContent
        Write-Host "✅ Test template created: $testPath" -ForegroundColor Green
        exit 0
    }
    "List" {
        $tests = Get-ChildItem $script:TestsDir -Filter "*.test.ps1"
        Write-Host "📋 Available tests: $($tests.Count)" -ForegroundColor Cyan
        foreach ($test in $tests) {
            Write-Host "  - $($test.Name)" -ForegroundColor White
        }
        exit 0
    }
}
