# Calculate Production Validation Score
# Version: 1.0
# Date: 2026-02-20

param(
    [string]$StatePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json",
    [switch]$UpdateState
)

Write-Host "[PRODUCTION VALIDATION SCORE]" -ForegroundColor Cyan
Write-Host ""

# === DATA COLLECTION ===

# 1. USAGE SCORE - Read usage logs
$usageLogs = @(
    "E:\jengo\documents\temp\opencode-usage.jsonl"
)

$systemsTracked = @()
$systemsUsed = @()

foreach ($logFile in $usageLogs) {
    if (Test-Path $logFile) {
        $systemName = [System.IO.Path]::GetFileNameWithoutExtension($logFile) -replace '-usage$', ''
        $systemsTracked += $systemName

        $records = Get-Content $logFile | ForEach-Object { $_ | ConvertFrom-Json }
        $totalCalls = $records.Count

        if ($totalCalls -gt 0) {
            $systemsUsed += $systemName
            Write-Host "  [OK] $systemName - $totalCalls calls" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $systemName - 0 calls (UNUSED)" -ForegroundColor Red
        }
    }
}

if ($systemsTracked.Count -eq 0) {
    Write-Host "  [WARN] No usage logs found - UsageScore = 0%" -ForegroundColor Yellow
    $usageScore = 0
} else {
    $usageScore = ($systemsUsed.Count / $systemsTracked.Count) * 100
}

# 2. VALIDATION SCORE - Parse reflection.log.md
$reflectionLog = "C:\scripts\_machine\reflection.log.md"
$testsPassed = 0
$totalTests = 0

if (Test-Path $reflectionLog) {
    $content = Get-Content $reflectionLog -Raw

    # Count tests in Production Validation sections
    $validationSections = [regex]::Matches($content, '### Production Validation[\s\S]*?(?=###|---|\z)')

    foreach ($section in $validationSections) {
        $text = $section.Value

        # Check for "Did it work as expected?"
        if ($text -match '\[x\]\s+YES') {
            $testsPassed++
            $totalTests++
        } elseif ($text -match '\[x\]\s+(PARTIAL|NO)') {
            $totalTests++
        }
    }
}

if ($totalTests -eq 0) {
    Write-Host "  [WARN] No validation tests found - ValidationScore = 0%" -ForegroundColor Yellow
    $validationScore = 0
} else {
    $validationScore = ($testsPassed / $totalTests) * 100
    Write-Host "  [OK] Validation tests: $testsPassed / $totalTests passed" -ForegroundColor Green
}

# 3. ROI SCORE - Parse reflection.log.md for ROI mentions
$roiValues = @()

if (Test-Path $reflectionLog) {
    $content = Get-Content $reflectionLog -Raw
    $roiMatches = [regex]::Matches($content, 'ROI[:\s]+([+-]?\d+\.?\d*)')

    foreach ($match in $roiMatches) {
        $roi = [double]$match.Groups[1].Value
        $roiValues += $roi
    }
}

if ($roiValues.Count -eq 0) {
    Write-Host "  [WARN] No ROI data found - ROIScore = 50% (neutral)" -ForegroundColor Yellow
    $roiScore = 50
} else {
    $avgROI = ($roiValues | Measure-Object -Average).Average

    if ($avgROI -gt 0) {
        $roiScore = [Math]::Min(100, $avgROI * 20)
    } elseif ($avgROI -lt 0) {
        $roiScore = [Math]::Max(0, 50 + ($avgROI * 20))
    } else {
        $roiScore = 50
    }

    Write-Host "  [OK] Average ROI: $([Math]::Round($avgROI, 2)) -> Score: $([Math]::Round($roiScore, 1))%" -ForegroundColor Green
}

# 4. FALSIFIABILITY SCORE - Count systems with defined tests
$systemsWithTests = 0
$totalSystems = 5

$dodPath = "C:\scripts\_machine\DEFINITION_OF_DONE.md"
if (Test-Path $dodPath) {
    $dodContent = Get-Content $dodPath -Raw
    $exampleCount = ([regex]::Matches($dodContent, 'TotalCalls\s*[><=]')).Count
    if ($exampleCount -gt 0) {
        $systemsWithTests = [Math]::Min($totalSystems, $exampleCount)
    }
}

if (Test-Path $reflectionLog) {
    $content = Get-Content $reflectionLog -Raw
    $falsifiableMatches = [regex]::Matches($content, 'Falsifiable test')
    $systemsWithTests = [Math]::Max($systemsWithTests, [Math]::Min($totalSystems, $falsifiableMatches.Count))
}

$falsifiabilityScore = ($systemsWithTests / $totalSystems) * 100
Write-Host "  [OK] Systems with falsifiable tests: $systemsWithTests / $totalSystems" -ForegroundColor Green

# === CALCULATE FINAL SCORE ===
Write-Host ""
Write-Host "=== PRODUCTION VALIDATION QUALITY ===" -ForegroundColor White
Write-Host ""

$quality = (
    ($usageScore * 0.40) +
    ($validationScore * 0.30) +
    ($roiScore * 0.20) +
    ($falsifiabilityScore * 0.10)
)

$usageWeighted = [Math]::Round($usageScore * 0.40, 1)
$validationWeighted = [Math]::Round($validationScore * 0.30, 1)
$roiWeighted = [Math]::Round($roiScore * 0.20, 1)
$falsifiabilityWeighted = [Math]::Round($falsifiabilityScore * 0.10, 1)

Write-Host "  Usage Score:         $([Math]::Round($usageScore, 1))% x 0.40 = $usageWeighted" -ForegroundColor Gray
Write-Host "  Validation Score:    $([Math]::Round($validationScore, 1))% x 0.30 = $validationWeighted" -ForegroundColor Gray
Write-Host "  ROI Score:           $([Math]::Round($roiScore, 1))% x 0.20 = $roiWeighted" -ForegroundColor Gray
Write-Host "  Falsifiability Score: $([Math]::Round($falsifiabilityScore, 1))% x 0.10 = $falsifiabilityWeighted" -ForegroundColor Gray
Write-Host ""
Write-Host "  PRODUCTION VALIDATION QUALITY: $([Math]::Round($quality, 1))%" -ForegroundColor Cyan

# === INTERPRETATION ===
Write-Host ""
Write-Host "=== INTERPRETATION ===" -ForegroundColor White

if ($quality -ge 90) {
    Write-Host "  Level: EXCELLENT (90-100%)" -ForegroundColor Green
    Write-Host "  Status: All systems used, validated, positive ROI" -ForegroundColor Gray
} elseif ($quality -ge 75) {
    Write-Host "  Level: GOOD (75-90%)" -ForegroundColor Cyan
    Write-Host "  Status: Most systems used, some validation gaps" -ForegroundColor Gray
} elseif ($quality -ge 60) {
    Write-Host "  Level: CONCERNING (60-75%)" -ForegroundColor Yellow
    Write-Host "  Status: Significant unused complexity" -ForegroundColor Gray
} elseif ($quality -ge 40) {
    Write-Host "  Level: POOR (40-60%)" -ForegroundColor Yellow
    Write-Host "  Status: Building without measuring" -ForegroundColor Gray
} else {
    Write-Host "  Level: CRITICAL (0-40%)" -ForegroundColor Red
    Write-Host "  Status: Complexity theater, no production value" -ForegroundColor Gray
}

# === UPDATE STATE ===
if ($UpdateState) {
    Write-Host ""
    Write-Host "=== UPDATING STATE ===" -ForegroundColor White

    if (Test-Path $StatePath) {
        $state = Get-Content $StatePath -Raw | ConvertFrom-Json

        # Check if ProductionValidation property exists
        $hasProductionValidation = $false
        foreach ($prop in $state.PSObject.Properties) {
            if ($prop.Name -eq 'ProductionValidation') {
                $hasProductionValidation = $true
                break
            }
        }

        if (-not $hasProductionValidation) {
            # Add new system at root level
            $state | Add-Member -NotePropertyName 'ProductionValidation' -NotePropertyValue ([PSCustomObject]@{
                quality = [Math]::Round($quality, 1)
                lastUpdated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
            }) -Force
        } else {
            # Update existing system
            $state.ProductionValidation.quality = [Math]::Round($quality, 1)
            $state.ProductionValidation.lastUpdated = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }

        $state | ConvertTo-Json -Depth 10 | Set-Content $StatePath

        Write-Host "  [OK] Updated ProductionValidation.quality = $([Math]::Round($quality, 1))" -ForegroundColor Green
    } else {
        Write-Host "  [ERROR] State file not found: $StatePath" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[COMPLETE] Production validation scoring complete" -ForegroundColor Cyan
