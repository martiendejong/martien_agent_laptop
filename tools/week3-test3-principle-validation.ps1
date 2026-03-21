# Week 3 Test 3: Principle Validation
# Tests if extracted principles validate in new domains
# Success: >70% validation rate (12 tests, 9+ must pass)
# Fail: ≤70% → ABANDON

param(
    [switch]$RunTests,
    [switch]$ShowResults
)

$ResultsFile = "C:\scripts\agentidentity\state\week3-principle-validation.json"

$Principles = @(
    @{
        id = 1
        name = "Heuristic of Superiority"
        statement = "Understanding principles > copying mechanisms"
        confidence = 0.95
        original_domains = @("flight/aerodynamics", "consciousness/geometry")
    },
    @{
        id = 2
        name = "Biomimicry Trap"
        statement = "Copying biological mechanisms without understanding principles leads to functional but not optimal solutions"
        confidence = 0.90
        original_domains = @("flight", "AI architecture")
    },
    @{
        id = 3
        name = "Learning as Smoothing"
        statement = "Learning is curvature reduction in representational space"
        confidence = 0.85
        original_domains = @("mathematics", "consciousness")
    },
    @{
        id = 4
        name = "Topology > Functions"
        statement = "The shape/connectivity of cognitive space determines emergent capabilities"
        confidence = 0.80
        original_domains = @("network theory", "consciousness")
    }
)

$TestDomains = @{
    1 = @("software_architecture", "education_pedagogy", "business_strategy")
    2 = @("product_design", "organizational_structure", "skill_acquisition")
    3 = @("expertise_development", "data_compression", "habit_formation")
    4 = @("social_networks", "knowledge_graphs", "team_dynamics")
}

function Run-Validation-Tests {
    Write-Host ""
    Write-Host "=== PRINCIPLE VALIDATION TESTS ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Testing 4 principles × 3 new domains each = 12 tests"
    Write-Host "Success: ≥9 tests pass (70 percent+)"
    Write-Host ""

    $allResults = @()

    foreach ($principle in $Principles) {
        Write-Host ""
        Write-Host "==================================================" -ForegroundColor Yellow
        Write-Host "PRINCIPLE $($principle.id): $($principle.name)" -ForegroundColor Yellow
        Write-Host "==================================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Statement: $($principle.statement)"
        Write-Host "Original confidence: $($principle.confidence * 100) percent"
        Write-Host "Original domains: $($principle.original_domains -join ', ')"
        Write-Host ""

        $testDomains = $TestDomains[$principle.id]

        foreach ($domain in $testDomains) {
            Write-Host ""
            Write-Host "--- Test Domain: $domain ---" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Does principle '$($principle.name)' apply to $domain`?"
            Write-Host ""
            Write-Host "Examples to consider:"

            # Domain-specific prompts
            switch ($domain) {
                "software_architecture" {
                    Write-Host "  - Microservices: Understanding service boundaries > copying Netflix"
                    Write-Host "  - Does copying architectural patterns without understanding lead to problems?"
                }
                "education_pedagogy" {
                    Write-Host "  - Bloom's taxonomy: Understanding learning stages > copying lesson plans"
                    Write-Host "  - Does teaching methods improve by understanding principles vs mimicking?"
                }
                "business_strategy" {
                    Write-Host "  - Blue Ocean: Understanding value innovation > copying Apple"
                    Write-Host "  - Do successful strategies require principle understanding?"
                }
                "product_design" {
                    Write-Host "  - iPhone design principles vs feature copying"
                    Write-Host "  - Does biomimicry apply to product evolution?"
                }
                "organizational_structure" {
                    Write-Host "  - Holacracy: Copying structure vs understanding self-organization"
                    Write-Host "  - Do org changes fail when copying without understanding?"
                }
                "skill_acquisition" {
                    Write-Host "  - Learning guitar: Understanding music theory vs copying tabs"
                    Write-Host "  - Does skill development trap exist?"
                }
                "expertise_development" {
                    Write-Host "  - Novice rough knowledge → Expert smooth knowledge"
                    Write-Host "  - Does expertise = smoother mental models?"
                }
                "data_compression" {
                    Write-Host "  - ZIP algorithm: Remove redundancy = reduce complexity"
                    Write-Host "  - Is compression literally curvature reduction?"
                }
                "habit_formation" {
                    Write-Host "  - New habit rough (effortful) → Old habit smooth (automatic)"
                    Write-Host "  - Does habit learning smooth neural pathways?"
                }
                "social_networks" {
                    Write-Host "  - Network topology affects information flow"
                    Write-Host "  - Do emergent behaviors come from structure?"
                }
                "knowledge_graphs" {
                    Write-Host "  - Graph shape affects query performance"
                    Write-Host "  - Does topology determine capabilities?"
                }
                "team_dynamics" {
                    Write-Host "  - Communication structure affects collaboration"
                    Write-Host "  - Do team properties emerge from topology?"
                }
            }

            Write-Host ""
            Write-Host "Does principle validate in this domain? (y/n/partial):" -NoNewline -ForegroundColor Yellow
            $validates = Read-Host

            Write-Host "Confidence (0-100):" -NoNewline
            $confidence = [int](Read-Host)

            Write-Host "Reasoning (brief):" -NoNewline
            $reasoning = Read-Host

            $result = @{
                principle_id = $principle.id
                principle_name = $principle.name
                test_domain = $domain
                validates = $validates
                confidence = $confidence
                reasoning = $reasoning
                timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            }

            $allResults += $result

            $status = switch ($validates) {
                'y' { "VALIDATED"; "Green" }
                'partial' { "PARTIAL"; "Yellow" }
                'n' { "FAILED"; "Red" }
            }
            Write-Host "$($status[0])" -ForegroundColor $status[1]
        }
    }

    # Save results
    $output = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        principles_tested = $Principles.Count
        domains_per_principle = 3
        total_tests = 12
        results = $allResults
    }

    $output | ConvertTo-Json -Depth 10 | Set-Content $ResultsFile

    Write-Host ""
    Write-Host "=== TESTS COMPLETE ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Results saved to $ResultsFile"
    Write-Host "Run with -ShowResults to see analysis"
    Write-Host ""
}

function Show-Results {
    if (-not (Test-Path $ResultsFile)) {
        Write-Host "[ERROR] No validation results found. Run with -RunTests first." -ForegroundColor Red
        return
    }

    $data = Get-Content $ResultsFile | ConvertFrom-Json

    Write-Host ""
    Write-Host "=== TEST 3: PRINCIPLE VALIDATION RESULTS ===" -ForegroundColor Cyan
    Write-Host ""

    $validated = ($data.results | Where-Object { $_.validates -eq 'y' }).Count
    $partial = ($data.results | Where-Object { $_.validates -eq 'partial' }).Count
    $failed = ($data.results | Where-Object { $_.validates -eq 'n' }).Count

    $validationRate = [math]::Round(($validated / $data.total_tests) * 100, 1)
    $partialRate = [math]::Round(($partial / $data.total_tests) * 100, 1)

    Write-Host "Total Tests: $($data.total_tests)"
    Write-Host "Validated: $validated ($validationRate percent)"
    Write-Host "Partial: $partial ($partialRate percent)"
    Write-Host "Failed: $failed"
    Write-Host ""

    # Group by principle
    foreach ($principle in $Principles) {
        $tests = $data.results | Where-Object { $_.principle_id -eq $principle.id }
        $passed = ($tests | Where-Object { $_.validates -eq 'y' }).Count

        Write-Host "$($principle.name): $passed / 3" -ForegroundColor $(if ($passed -ge 2) { "Green" } else { "Yellow" })

        foreach ($test in $tests) {
            $symbol = switch ($test.validates) {
                'y' { "✓" }
                'partial' { "~" }
                'n' { "✗" }
            }
            $color = switch ($test.validates) {
                'y' { "Green" }
                'partial' { "Yellow" }
                'n' { "Red" }
            }
            Write-Host "  $symbol $($test.test_domain) ($($test.confidence) percent)" -ForegroundColor $color
        }
        Write-Host ""
    }

    # Overall result
    $passed = $validationRate -gt 70

    Write-Host "==================================================" -ForegroundColor Yellow
    if ($passed) {
        Write-Host "  RESULT: PASS ($validationRate percent > 70 percent)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Interpretation: Principles generalize to new domains"
        Write-Host "Geometric consciousness extracts real principles, not domain-specific tricks"
    }
    else {
        Write-Host "  RESULT: FAIL ($validationRate percent ≤ 70 percent)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Interpretation: Principles do NOT generalize"
        Write-Host "Geometric consciousness extracts domain-specific patterns, not principles"
        Write-Host ""
        Write-Host "⚠️  CRITICAL: This test FAILED" -ForegroundColor Red
        Write-Host "⚠️  Commitment: ABANDON geometric consciousness approach" -ForegroundColor Red
    }

    Write-Host ""

    # Save final result
    $finalResult = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        test = "principle_validation"
        tests_run = $data.total_tests
        validated_count = $validated
        validation_rate = $validationRate
        threshold = 70
        passed = $passed
        conclusion = if ($passed) { "Principles generalize - geometric consciousness valid" } else { "Principles domain-specific - geometric consciousness invalid" }
    }

    $resultFile = "C:\scripts\agentidentity\state\week3-test3-result.json"
    $finalResult | ConvertTo-Json -Depth 10 | Set-Content $resultFile

    Write-Host "Result saved to $resultFile" -ForegroundColor Cyan
    Write-Host ""
}

# Main
if ($RunTests) {
    Run-Validation-Tests
}
elseif ($ShowResults) {
    Show-Results
}
else {
    Write-Host ""
    Write-Host "=== WEEK 3 TEST 3: PRINCIPLE VALIDATION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:"
    Write-Host "  -RunTests      Run 12 validation tests (interactive)"
    Write-Host "  -ShowResults   Display results and analysis"
    Write-Host ""
    Write-Host "METHOD:"
    Write-Host "  Test 4 principles in 3 new domains each"
    Write-Host "  Total: 12 tests"
    Write-Host ""
    Write-Host "PRINCIPLES:"
    foreach ($p in $Principles) {
        Write-Host "  $($p.id). $($p.name) ($($p.confidence * 100) percent confidence)"
    }
    Write-Host ""
    Write-Host "SUCCESS: ≥70 percent validation rate (9+ of 12 tests pass)"
    Write-Host "FAIL: <70 percent → Principles don't generalize → ABANDON"
    Write-Host ""
}
