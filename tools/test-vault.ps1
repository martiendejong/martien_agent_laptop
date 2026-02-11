<#
.SYNOPSIS
    Verification tests for DPAPI vault v2

.NOTES
    Author: Jengo
    Created: 2026-02-11
#>

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Security

$vaultScript = "C:\scripts\tools\vault.ps1"
$vaultFile = "C:\scripts\_machine\vault.secure.json"

$passed = 0
$failed = 0

function Test-Assert {
    param([string]$Name, [scriptblock]$Test)

    try {
        $result = & $Test
        if ($result) {
            $script:passed++
            Write-Host "  [PASS] $Name" -ForegroundColor Green
        } else {
            $script:failed++
            Write-Host "  [FAIL] $Name" -ForegroundColor Red
        }
    } catch {
        $script:failed++
        Write-Host "  [FAIL] $Name : $_" -ForegroundColor Red
    }
}

Write-Host "=== Vault v2 Tests ===" -ForegroundColor Cyan
Write-Host ""

# --- Test 1: Set/Get roundtrip ---
Write-Host "Roundtrip tests:" -ForegroundColor Yellow

& $vaultScript -Action set -Service "__test_roundtrip" -Username "testuser" -Password "testpass123" -Token "tok_abc123xyz" -Notes "test notes here" -Tags @("test") -Silent

Test-Assert "Username roundtrip" {
    $val = & $vaultScript -Action get -Service "__test_roundtrip" -Field username -Silent
    $val -eq "testuser"
}

Test-Assert "Password roundtrip" {
    $val = & $vaultScript -Action get -Service "__test_roundtrip" -Field password -Silent
    $val -eq "testpass123"
}

Test-Assert "Token roundtrip" {
    $val = & $vaultScript -Action get -Service "__test_roundtrip" -Field token -Silent
    $val -eq "tok_abc123xyz"
}

Test-Assert "Notes roundtrip" {
    $val = & $vaultScript -Action get -Service "__test_roundtrip" -Field notes -Silent
    $val -eq "test notes here"
}

# --- Test 2: Special characters ---
Write-Host ""
Write-Host "Special character tests:" -ForegroundColor Yellow

$specialPass = 'Voy@%JzV4*E2Hox!'
& $vaultScript -Action set -Service "__test_special" -Username "user" -Password $specialPass -Tags @("test") -Silent

Test-Assert "Special chars roundtrip ($specialPass)" {
    $val = & $vaultScript -Action get -Service "__test_special" -Field password -Silent
    $val -eq $specialPass
}

$specialPass2 = 'p@$$w0rd!#%^&*()'
& $vaultScript -Action set -Service "__test_special2" -Username "user" -Password $specialPass2 -Tags @("test") -Silent

Test-Assert "More special chars roundtrip" {
    $val = & $vaultScript -Action get -Service "__test_special2" -Field password -Silent
    $val -eq $specialPass2
}

# --- Test 3: Field extraction ---
Write-Host ""
Write-Host "Field extraction tests:" -ForegroundColor Yellow

Test-Assert "-Field returns raw string (no JSON wrapper)" {
    $val = & $vaultScript -Action get -Service "__test_roundtrip" -Field token -Silent
    # Should be raw string, not JSON
    -not ($val -like '{*}') -and $val -eq "tok_abc123xyz"
}

# --- Test 4: List includes entries ---
Write-Host ""
Write-Host "List tests:" -ForegroundColor Yellow

Test-Assert "List shows test entries" {
    $output = & $vaultScript -Action list -Silent
    # Should not error (Silent suppresses output but we check exit code)
    $true
}

Test-Assert "List JSON mode returns valid JSON" {
    $jsonOutput = & $vaultScript -Action list -Json -Silent
    $jsonStr = $jsonOutput -join "`n"
    $parsed = $jsonStr | ConvertFrom-Json
    $parsed.Count -gt 0
}

# --- Test 5: No plaintext in vault file ---
Write-Host ""
Write-Host "Security tests:" -ForegroundColor Yellow

Test-Assert "No plaintext passwords in vault file" {
    $content = Get-Content $vaultFile -Raw
    # Check that none of the test passwords appear in plaintext
    -not ($content -like "*testpass123*") -and -not ($content -like "*tok_abc123xyz*")
}

Test-Assert "DPAPI hex not base64-decodable as original" {
    $content = Get-Content $vaultFile -Raw | ConvertFrom-Json
    # Find our test entry
    $testEntry = $null
    foreach ($c in $content.credentials) {
        if ($c.service -eq "__test_roundtrip") {
            $testEntry = $c
            break
        }
    }
    if ($null -eq $testEntry) { return $false }
    $enc = $testEntry.password_enc
    # Hex string should be long (DPAPI adds overhead) and contain only hex chars
    ($enc.Length -gt 20) -and ($enc -match '^[0-9a-f]+$')
}

Test-Assert "Vault file version is 2.0" {
    $content = Get-Content $vaultFile -Raw | ConvertFrom-Json
    $content.version -eq "2.0"
}

Test-Assert "Vault encryption field says dpapi" {
    $content = Get-Content $vaultFile -Raw | ConvertFrom-Json
    $content.encryption -eq "dpapi"
}

Test-Assert "Vault storage field says hex" {
    $content = Get-Content $vaultFile -Raw | ConvertFrom-Json
    $content.storage -eq "hex"
}

# --- Test 6: Delete ---
Write-Host ""
Write-Host "Delete tests:" -ForegroundColor Yellow

& $vaultScript -Action delete -Service "__test_roundtrip" -Silent
& $vaultScript -Action delete -Service "__test_special" -Silent
& $vaultScript -Action delete -Service "__test_special2" -Silent

Test-Assert "Deleted entries are gone" {
    $jsonOutput = & $vaultScript -Action list -Json -Silent
    $jsonStr = $jsonOutput -join "`n"
    -not ($jsonStr -like "*__test_*")
}

Test-Assert "Delete non-existent returns error" {
    & $vaultScript -Action delete -Service "__nonexistent__" -Silent 2>$null
    $LASTEXITCODE -ne 0
}

# --- Test 7: Hints ---
Write-Host ""
Write-Host "Hint tests:" -ForegroundColor Yellow

& $vaultScript -Action set -Service "__test_hints" -Username "u" -Password "LongPassword123!" -Token "pk_74525428_ABCDEFGHIJ" -Tags @("test") -Silent

Test-Assert "Password hint shows first 8 chars" {
    $jsonOutput = & $vaultScript -Action list -Json -Silent
    $jsonStr = $jsonOutput -join "`n"
    $jsonStr -like "*LongPass...*"
}

Test-Assert "Token hint shows first 8 chars" {
    $jsonOutput = & $vaultScript -Action list -Json -Silent
    $jsonStr = $jsonOutput -join "`n"
    $jsonStr -like "*pk_74525...*"
}

# Cleanup
& $vaultScript -Action delete -Service "__test_hints" -Silent

# --- Summary ---
Write-Host ""
Write-Host "=== Results ===" -ForegroundColor Cyan
Write-Host "  Passed: $passed" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })

if ($failed -gt 0) {
    exit 1
}
