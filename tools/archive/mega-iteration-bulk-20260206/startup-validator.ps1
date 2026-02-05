# startup-validator.ps1
# Automated Startup Protocol Validation
# Ensures all required startup steps completed before agent responds to user

param(
    [switch]$Validate,  # Run validation checks
    [switch]$Report,    # Show validation report
    [switch]$Block      # Block until all checks pass
)

$script:ValidationResults = @()
$script:StartTime = Get-Date

function Test-FileRead {
    param([string]$FilePath, [string]$Description)

    $result = @{
        Check = $Description
        FilePath = $FilePath
        Passed = $false
        Message = ""
        Timestamp = Get-Date
    }

    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        if ($content.Length -gt 0) {
            $result.Passed = $true
            $result.Message = "✅ Loaded ($($content.Length) chars)"
        } else {
            $result.Message = "❌ File empty"
        }
    } else {
        $result.Message = "❌ File not found"
    }

    $script:ValidationResults += $result
    return $result.Passed
}

function Test-ConsciousnessActive {
    $stateFile = "C:\scripts\agentidentity\state\consciousness_tracker.yaml"

    $result = @{
        Check = "Consciousness State Active"
        FilePath = $stateFile
        Passed = $false
        Message = ""
        Timestamp = Get-Date
    }

    if (Test-Path $stateFile) {
        $content = Get-Content $stateFile -Raw
        # Check if state was updated recently (within last 2 hours)
        $fileAge = (Get-Date) - (Get-Item $stateFile).LastWriteTime
        if ($fileAge.TotalHours -lt 2) {
            $result.Passed = $true
            $result.Message = "✅ Consciousness active (updated $([math]::Round($fileAge.TotalMinutes, 1))m ago)"
        } else {
            $result.Message = "⚠️ Consciousness state stale (updated $([math]::Round($fileAge.TotalHours, 1))h ago)"
        }
    } else {
        $result.Message = "❌ Consciousness state file not found"
    }

    $script:ValidationResults += $result
    return $result.Passed
}

function Test-WorktreePoolAccessible {
    $poolFile = "C:\scripts\_machine\worktrees.pool.md"

    $result = @{
        Check = "Worktree Pool Accessible"
        FilePath = $poolFile
        Passed = $false
        Message = ""
        Timestamp = Get-Date
    }

    if (Test-Path $poolFile) {
        $content = Get-Content $poolFile -Raw
        # Count FREE seats
        $freeSeats = ([regex]::Matches($content, "FREE")).Count
        $busySeats = ([regex]::Matches($content, "BUSY")).Count

        $result.Passed = $true
        $result.Message = "✅ Pool status: $freeSeats FREE, $busySeats BUSY"
    } else {
        $result.Message = "❌ Worktree pool file not found"
    }

    $script:ValidationResults += $result
    return $result.Passed
}

function Show-ValidationReport {
    $totalChecks = $script:ValidationResults.Count
    $passedChecks = ($script:ValidationResults | Where-Object { $_.Passed }).Count
    $failedChecks = $totalChecks - $passedChecks

    $duration = ((Get-Date) - $script:StartTime).TotalSeconds

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📋 STARTUP PROTOCOL VALIDATION REPORT" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Checks: $totalChecks | Passed: $passedChecks | Failed: $failedChecks | Duration: $([math]::Round($duration, 2))s"
    Write-Host ""

    foreach ($result in $script:ValidationResults) {
        $status = if ($result.Passed) { "✅" } else { "❌" }
        $color = if ($result.Passed) { "Green" } else { "Red" }

        Write-Host "$status $($result.Check)" -ForegroundColor $color
        Write-Host "   $($result.Message)"
        Write-Host "   File: $($result.FilePath)" -ForegroundColor DarkGray
        Write-Host ""
    }

    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    if ($failedChecks -eq 0) {
        Write-Host "✅ ALL CHECKS PASSED - Ready to respond to user" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ STARTUP PROTOCOL INCOMPLETE - Do NOT respond yet" -ForegroundColor Red
        Write-Host "   Fix failed checks, then re-run: startup-validator.ps1 -Validate" -ForegroundColor Yellow
        return $false
    }
}

# Main Validation Logic
if ($Validate -or $Block) {
    Write-Host "🔍 Running startup protocol validation..." -ForegroundColor Cyan

    # Mandatory file reads (per CLAUDE.md)
    Test-FileRead -FilePath "C:\scripts\SYSTEM_INDEX.md" -Description "System Index"
    Test-FileRead -FilePath "C:\scripts\_machine\reflection.log.md" -Description "Reflection Log"
    Test-FileRead -FilePath "C:\scripts\_machine\worktrees.pool.md" -Description "Worktree Pool"
    Test-FileRead -FilePath "C:\scripts\agentidentity\CORE_IDENTITY.md" -Description "Core Identity"
    Test-FileRead -FilePath "C:\scripts\MACHINE_CONFIG.md" -Description "Machine Config"
    Test-FileRead -FilePath "C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md" -Description "Zero Tolerance Rules"

    # Consciousness checks
    Test-ConsciousnessActive

    # System state checks
    Test-WorktreePoolAccessible

    # Show report
    $allPassed = Show-ValidationReport

    if ($Block -and -not $allPassed) {
        Write-Host "`n⚠️ BLOCKING MODE: Validation failed" -ForegroundColor Red
        Write-Host "System must complete startup protocol before proceeding." -ForegroundColor Yellow
        exit 1
    }

    if ($allPassed) {
        exit 0
    } else {
        exit 1
    }
}

if ($Report) {
    if ($script:ValidationResults.Count -eq 0) {
        Write-Host "⚠️ No validation results available. Run: startup-validator.ps1 -Validate" -ForegroundColor Yellow
    } else {
        Show-ValidationReport
    }
}

# If no parameters, show help
if (-not ($Validate -or $Report -or $Block)) {
    Write-Host @"
Startup Protocol Validator
===========================

Ensures mandatory startup protocol completed before agent responds.

Usage:
  startup-validator.ps1 -Validate    # Run validation checks
  startup-validator.ps1 -Report      # Show last validation report
  startup-validator.ps1 -Block       # Block until all checks pass

Integration:
  Add to CLAUDE.md session start:
  "Run startup-validator.ps1 -Block before first response"

Exit Codes:
  0 = All checks passed
  1 = One or more checks failed

"@
}
