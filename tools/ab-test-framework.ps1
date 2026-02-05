# A/B Testing Framework for Communication Styles
# Test different approaches, measure user response

param(
    [switch]$CreateTest,
    [string]$TestName,
    [string]$VariantA,
    [string]$VariantB,
    [switch]$RecordOutcome,
    [string]$TestId,
    [ValidateSet("success", "neutral", "correction")]
    [string]$Outcome,
    [switch]$ShowResults
)

$testsFile = "C:\scripts\_machine\ab-tests.json"

function New-ABTest {
    param($Name, $VarA, $VarB)

    $tests = if (Test-Path $testsFile) {
        Get-Content $testsFile | ConvertFrom-Json
    } else {
        @()
    }

    $testId = "ab-" + (Get-Date -Format "yyyyMMdd-HHmmss")

    $test = @{
        id = $testId
        name = $Name
        created = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        variantA = @{
            description = $VarA
            uses = 0
            success = 0
            neutral = 0
            corrections = 0
        }
        variantB = @{
            description = $VarB
            uses = 0
            success = 0
            neutral = 0
            corrections = 0
        }
        status = "active"
    }

    $tests += $test
    $tests | ConvertTo-Json -Depth 10 | Set-Content $testsFile

    Write-Host "A/B Test created: $testId" -ForegroundColor Green
    Write-Host "  Name: $Name"
    Write-Host "  Variant A: $VarA"
    Write-Host "  Variant B: $VarB"
    Write-Host ""
    Write-Host "Record outcomes with:" -ForegroundColor Cyan
    Write-Host "  .\ab-test-framework.ps1 -RecordOutcome -TestId $testId -Outcome success"

    return $testId
}

function Record-Outcome {
    param($TestId, $Outcome, $Variant)

    if (!(Test-Path $testsFile)) {
        Write-Host "No tests file found" -ForegroundColor Yellow
        return
    }

    $tests = Get-Content $testsFile | ConvertFrom-Json

    $test = $tests | Where-Object { $_.id -eq $TestId }
    if (!$test) {
        Write-Host "Test not found: $TestId" -ForegroundColor Red
        return
    }

    # Auto-detect variant if not specified (alternate)
    if (!$Variant) {
        $totalUses = $test.variantA.uses + $test.variantB.uses
        $Variant = if ($totalUses % 2 -eq 0) { "A" } else { "B" }
    }

    if ($Variant -eq "A") {
        $test.variantA.uses++
        switch ($Outcome) {
            "success" { $test.variantA.success++ }
            "neutral" { $test.variantA.neutral++ }
            "correction" { $test.variantA.corrections++ }
        }
    } else {
        $test.variantB.uses++
        switch ($Outcome) {
            "success" { $test.variantB.success++ }
            "neutral" { $test.variantB.neutral++ }
            "correction" { $test.variantB.corrections++ }
        }
    }

    # Update JSON
    $tests | ConvertTo-Json -Depth 10 | Set-Content $testsFile

    Write-Host "Outcome recorded:" -ForegroundColor Green
    Write-Host "  Test: $($test.name)"
    Write-Host "  Variant: $Variant"
    Write-Host "  Outcome: $Outcome"
}

function Show-TestResults {
    if (!(Test-Path $testsFile)) {
        Write-Host "No tests file found" -ForegroundColor Yellow
        return
    }

    $tests = Get-Content $testsFile | ConvertFrom-Json

    Write-Host "`nA/B TEST RESULTS" -ForegroundColor Cyan
    Write-Host "=" * 60

    foreach ($test in $tests) {
        Write-Host "`nTest: $($test.name) [$($test.id)]" -ForegroundColor Yellow
        Write-Host "Status: $($test.status)"
        Write-Host "Created: $($test.created)"

        $aSuccessRate = if ($test.variantA.uses -gt 0) {
            [math]::Round(($test.variantA.success / $test.variantA.uses) * 100, 1)
        } else { 0 }

        $bSuccessRate = if ($test.variantB.uses -gt 0) {
            [math]::Round(($test.variantB.success / $test.variantB.uses) * 100, 1)
        } else { 0 }

        Write-Host "`nVariant A: $($test.variantA.description)"
        Write-Host "  Uses: $($test.variantA.uses)"
        Write-Host "  Success: $($test.variantA.success) ($aSuccessRate%)"
        Write-Host "  Neutral: $($test.variantA.neutral)"
        Write-Host "  Corrections: $($test.variantA.corrections)"

        Write-Host "`nVariant B: $($test.variantB.description)"
        Write-Host "  Uses: $($test.variantB.uses)"
        Write-Host "  Success: $($test.variantB.success) ($bSuccessRate%)"
        Write-Host "  Neutral: $($test.variantB.neutral)"
        Write-Host "  Corrections: $($test.variantB.corrections)"

        if ($test.variantA.uses -ge 5 -and $test.variantB.uses -ge 5) {
            Write-Host "`nRECOMMENDATION:" -ForegroundColor Cyan
            if ($aSuccessRate -gt $bSuccessRate + 10) {
                Write-Host "  → Use Variant A (significantly better)" -ForegroundColor Green
            } elseif ($bSuccessRate -gt $aSuccessRate + 10) {
                Write-Host "  → Use Variant B (significantly better)" -ForegroundColor Green
            } else {
                Write-Host "  → No significant difference (continue testing or use preference)"
            }
        } else {
            Write-Host "`nRECOMMENDATION: Need more data (min 5 uses per variant)"
        }
    }

    Write-Host "`n" + ("=" * 60)
}

# Main execution
if ($CreateTest) {
    if (!$TestName -or !$VariantA -or !$VariantB) {
        Write-Host "Usage: .\ab-test-framework.ps1 -CreateTest -TestName 'Name' -VariantA 'Description A' -VariantB 'Description B'"
        return
    }
    New-ABTest -Name $TestName -VarA $VariantA -VarB $VariantB
}
elseif ($RecordOutcome) {
    if (!$TestId -or !$Outcome) {
        Write-Host "Usage: .\ab-test-framework.ps1 -RecordOutcome -TestId 'test-id' -Outcome success|neutral|correction"
        return
    }
    Record-Outcome -TestId $TestId -Outcome $Outcome
}
elseif ($ShowResults) {
    Show-TestResults
}
else {
    Write-Host "A/B TESTING FRAMEWORK" -ForegroundColor Cyan
    Write-Host "Usage:"
    Write-Host "  Create test:"
    Write-Host "    .\ab-test-framework.ps1 -CreateTest -TestName 'Concise vs Detailed' -VariantA 'Short response' -VariantB 'Detailed explanation'"
    Write-Host "  Record outcome:"
    Write-Host "    .\ab-test-framework.ps1 -RecordOutcome -TestId ab-20260205-123456 -Outcome success"
    Write-Host "  Show results:"
    Write-Host "    .\ab-test-framework.ps1 -ShowResults"
}
