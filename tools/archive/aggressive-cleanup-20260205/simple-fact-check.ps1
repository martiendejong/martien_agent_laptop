param(
    [string]$ContentFile
)

if (-not (Test-Path $ContentFile)) {
    Write-Host "File not found: $ContentFile" -ForegroundColor Red
    exit 1
}

$content = Get-Content $ContentFile -Raw

Write-Host "=== SIMPLE FACT CHECK ===" -ForegroundColor Cyan
Write-Host ""

# Check for key claims
$claims = @(
    @{Pattern = 'drie jaar'; Expected = $true; Description = "3 jaar durend"},
    @{Pattern = 'duizenden euro'; Expected = $true; Description = "Duizenden euros (niet exact 10k)"},
    @{Pattern = 'tienduizend euro\b(?!s)'; Expected = $false; Description = "NIET exact 'tienduizend euro' (moet meervoud of indicatie zijn)"},
    @{Pattern = 'nog steeds geen trouwboekje'; Expected = $false; Description = "NIET 'nog steeds geen trouwboekje' (impasse beschrijven)"},
    @{Pattern = 'impasse|vastgelopen'; Expected = $true; Description = "Impasse/vastgelopen beschreven"},
    @{Pattern = 'documenten.*goed|goed.*documenten'; Expected = $true; Description = "Gemeente zegt documenten zijn goed"},
    @{Pattern = '24.*120|24,120'; Expected = $true; Description = "Exploitatie bedrag correct (24.120)"}
)

$passed = 0
$failed = 0

foreach ($claim in $claims) {
    $found = $content -match $claim.Pattern
    
    if ($found -eq $claim.Expected) {
        Write-Host "[OK] $($claim.Description)" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "[FAIL] $($claim.Description)" -ForegroundColor Red
        if ($claim.Expected) {
            Write-Host "       Expected to find but didn't" -ForegroundColor Yellow
        } else {
            Write-Host "       Should NOT be present but found it" -ForegroundColor Yellow
        }
        $failed++
    }
}

Write-Host ""
Write-Host "Results: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })

if ($failed -eq 0) {
    Write-Host "Ready to publish!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Fix issues before publishing" -ForegroundColor Yellow
    exit 1
}
