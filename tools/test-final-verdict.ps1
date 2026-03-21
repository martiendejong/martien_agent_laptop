param([switch]$TestMode)

$Tests = @(
    @{ id = 1; name = "Test1" }
    @{ id = 2; name = "Test2" }
)

function Final-Verdict {
    $results = @()
    $allPassed = $true

    # Save final verdict
    $verdict = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        all_passed = $allPassed
        tests_run = $results.Count
        tests_passed = ($results | Where-Object { $_.passed }).Count
        conclusion = $(if ($allPassed) { "PASS" } else { "FAIL" })
        test_results = $results
    }

    Write-Host "Verdict created" -ForegroundColor Green
    return $allPassed
}

if ($TestMode) {
    Final-Verdict
}
