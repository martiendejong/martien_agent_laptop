#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Comprehensive pre-PR validation - Full local CI suite

.DESCRIPTION
    Runs the complete test suite locally before creating a PR.
    This is the equivalent of what GitHub Actions would run, but locally.

.PARAMETER SkipDocker
    Skip Docker build checks (faster, for non-infrastructure changes)

.PARAMETER SkipFrontend
    Skip frontend tests (for backend-only changes)

.PARAMETER SkipBackend
    Skip backend tests (for frontend-only changes)

.EXAMPLE
    .\full-pre-pr-check.ps1
    # Run complete suite (~15 minutes)

.EXAMPLE
    .\full-pre-pr-check.ps1 -SkipDocker
    # Skip Docker builds (~10 minutes)
#>

param(
    [switch]$SkipDocker,
    [switch]$SkipFrontend,
    [switch]$SkipBackend
)

$ErrorActionPreference = "Stop"

function Write-Section($msg) {
    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  $msg" -ForegroundColor Magenta
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Magenta
}

Write-Section "🚀 Full Pre-PR Check - Comprehensive Local CI"

$StartTime = Get-Date
$script:AllPassed = $true

# ═══════════════════════════════════════════════
# STEP 1: Run standard pre-commit check
# ═══════════════════════════════════════════════
Write-Section "STEP 1/5: Standard Pre-Commit Checks"

$PreCommitScript = Join-Path $PSScriptRoot "pre-commit-check.ps1"
if (Test-Path $PreCommitScript) {
    & $PreCommitScript -Comprehensive
    if ($LASTEXITCODE -ne 0) {
        $script:AllPassed = $false
        Write-Host "❌ Pre-commit checks failed. Fix issues before proceeding." -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "⚠️  Pre-commit script not found, continuing..." -ForegroundColor Yellow
}

# ═══════════════════════════════════════════════
# STEP 2: Backend comprehensive tests
# ═══════════════════════════════════════════════
if (-not $SkipBackend) {
    Write-Section "STEP 2/5: Backend Comprehensive Tests"

    try {
        Write-Host "Running ALL backend tests (unit + integration)..." -ForegroundColor Cyan

        # Detect repo
        $CurrentDir = Get-Location
        if ($CurrentDir -like "*hazina*") {
            $TestOutput = dotnet test Hazina.sln --configuration Release --verbosity normal
        }
        elseif ($CurrentDir -like "*client-manager*") {
            Push-Location ClientManagerAPI
            $TestOutput = dotnet test --configuration Release --verbosity normal
            Pop-Location
        }

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ All backend tests passed" -ForegroundColor Green
        }
        else {
            Write-Host "❌ Backend tests failed" -ForegroundColor Red
            $script:AllPassed = $false
        }
    }
    catch {
        Write-Host "❌ Backend tests failed: $_" -ForegroundColor Red
        $script:AllPassed = $false
    }
}

# ═══════════════════════════════════════════════
# STEP 3: Frontend comprehensive tests
# ═══════════════════════════════════════════════
if (-not $SkipFrontend) {
    Write-Section "STEP 3/5: Frontend Comprehensive Tests"

    $FrontendDir = if (Test-Path "ClientManagerFrontend") { "ClientManagerFrontend" }
                   elseif (Test-Path "artrevisionist") { "artrevisionist" }
                   else { $null }

    if ($FrontendDir) {
        try {
            Push-Location $FrontendDir

            Write-Host "Running frontend tests with coverage..." -ForegroundColor Cyan
            npm test -- --run --coverage

            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Frontend tests passed" -ForegroundColor Green
            }
            else {
                Write-Host "❌ Frontend tests failed" -ForegroundColor Red
                $script:AllPassed = $false
            }

            Pop-Location
        }
        catch {
            Write-Host "❌ Frontend tests failed: $_" -ForegroundColor Red
            $script:AllPassed = $false
            Pop-Location
        }
    }
}

# ═══════════════════════════════════════════════
# STEP 4: Docker build validation
# ═══════════════════════════════════════════════
if (-not $SkipDocker) {
    Write-Section "STEP 4/5: Docker Build Validation"

    try {
        Write-Host "Building Docker images..." -ForegroundColor Cyan

        # Check if Dockerfile exists
        if (Test-Path "Dockerfile" -or Test-Path "ClientManagerAPI/Dockerfile") {
            $DockerScript = "C:\scripts\tools\local-ci\local-docker-build.ps1"
            if (Test-Path $DockerScript) {
                & $DockerScript -SkipPush
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ Docker builds successful" -ForegroundColor Green
                }
                else {
                    Write-Host "❌ Docker builds failed" -ForegroundColor Red
                    $script:AllPassed = $false
                }
            }
            else {
                Write-Host "⚠️  Docker build script not found, skipping..." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "ℹ️  No Dockerfile found, skipping Docker checks" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "❌ Docker build failed: $_" -ForegroundColor Red
        $script:AllPassed = $false
    }
}

# ═══════════════════════════════════════════════
# STEP 5: Final validation & PR readiness check
# ═══════════════════════════════════════════════
Write-Section "STEP 5/5: PR Readiness Validation"

Write-Host "Checking PR requirements..." -ForegroundColor Cyan

# Check 1: Branch is not main/develop
$CurrentBranch = git branch --show-current
if ($CurrentBranch -eq "main" -or $CurrentBranch -eq "develop") {
    Write-Host "❌ You're on $CurrentBranch branch. Create a feature branch first!" -ForegroundColor Red
    $script:AllPassed = $false
}
else {
    Write-Host "✅ On feature branch: $CurrentBranch" -ForegroundColor Green
}

# Check 2: Branch is pushed to remote
$RemoteBranch = git ls-remote --heads origin $CurrentBranch
if (-not $RemoteBranch) {
    Write-Host "⚠️  Branch not pushed to remote yet. Remember to push before creating PR." -ForegroundColor Yellow
}
else {
    Write-Host "✅ Branch exists on remote" -ForegroundColor Green
}

# Check 3: No uncommitted changes
$GitStatus = git status --porcelain
if ($GitStatus) {
    Write-Host "⚠️  Uncommitted changes detected. Commit all changes before PR." -ForegroundColor Yellow
}
else {
    Write-Host "✅ No uncommitted changes" -ForegroundColor Green
}

# Check 4: Commits are meaningful
$RecentCommits = git log --oneline -n 5
Write-Host "`nRecent commits:" -ForegroundColor Cyan
$RecentCommits | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

# ═══════════════════════════════════════════════
# FINAL SUMMARY
# ═══════════════════════════════════════════════
$EndTime = Get-Date
$Duration = $EndTime - $StartTime

Write-Section "📊 Full Pre-PR Check Summary"

Write-Host "⏱️  Total Duration: $([math]::Round($Duration.TotalMinutes, 1)) minutes`n" -ForegroundColor Cyan

if ($script:AllPassed) {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  ✅ ALL CHECKS PASSED - READY TO CREATE PR!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Green

    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Push your branch:" -ForegroundColor Gray
    Write-Host "     git push -u origin $CurrentBranch`n" -ForegroundColor Gray
    Write-Host "  2. Create PR:" -ForegroundColor Gray
    Write-Host "     gh pr create --title 'Your PR title' --body 'Description'`n" -ForegroundColor Gray

    exit 0
}
else {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  ❌ SOME CHECKS FAILED - FIX BEFORE PR" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Red

    Write-Host "Review failures above and fix before creating PR." -ForegroundColor Yellow
    exit 1
}
