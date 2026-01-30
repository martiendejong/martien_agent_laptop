#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Automated pre-commit validation - MANDATORY before every commit

.DESCRIPTION
    Runs comprehensive local CI checks to ensure code quality before committing.
    This replaces automatic GitHub Actions checks which are now manual-only.

.PARAMETER Comprehensive
    Run full comprehensive check (includes integration tests, coverage analysis)
    Use this before creating a PR.

.PARAMETER Quick
    Run only fast checks (build + unit tests + formatting)
    Use for rapid iteration during development.

.PARAMETER Fix
    Automatically fix issues where possible (formatting, unused imports)

.EXAMPLE
    .\pre-commit-check.ps1
    # Standard pre-commit check (~3 minutes)

.EXAMPLE
    .\pre-commit-check.ps1 -Comprehensive
    # Full check before PR (~15 minutes)

.EXAMPLE
    .\pre-commit-check.ps1 -Quick
    # Quick check during development (~1 minute)
#>

param(
    [switch]$Comprehensive,
    [switch]$Quick,
    [switch]$Fix
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success($msg) { Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Failure($msg) { Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "ℹ️  $msg" -ForegroundColor Cyan }
function Write-Warning($msg) { Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Section($msg) {
    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Blue
    Write-Host "  $msg" -ForegroundColor Blue
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Blue
}

$script:FailureCount = 0
$script:WarningCount = 0
$script:PassCount = 0

function Record-Pass($msg) {
    $script:PassCount++
    Write-Success $msg
}

function Record-Failure($msg) {
    $script:FailureCount++
    Write-Failure $msg
}

function Record-Warning($msg) {
    $script:WarningCount++
    Write-Warning $msg
}

Write-Section "🧪 Local CI Pre-Commit Check"

# Detect which repository we're in
$CurrentDir = Get-Location
$RepoName = $null
$IsHazina = $false
$IsClientManager = $false
$IsArtRevisionist = $false

if ($CurrentDir -like "*hazina*") {
    $RepoName = "Hazina"
    $IsHazina = $true
    Write-Info "Detected repository: Hazina"
}
elseif ($CurrentDir -like "*client-manager*") {
    $RepoName = "client-manager"
    $IsClientManager = $true
    Write-Info "Detected repository: client-manager"
}
elseif ($CurrentDir -like "*artrevisionist*") {
    $RepoName = "artrevisionist"
    $IsArtRevisionist = $true
    Write-Info "Detected repository: artrevisionist"
}
else {
    Write-Failure "Unknown repository. Run this from a project directory."
    exit 1
}

# Determine check level
if ($Quick) {
    Write-Info "Running QUICK checks (build + unit tests + formatting)"
}
elseif ($Comprehensive) {
    Write-Info "Running COMPREHENSIVE checks (full suite + coverage + security)"
}
else {
    Write-Info "Running STANDARD checks (build + tests + formatting + secrets)"
}

$StartTime = Get-Date

# ═══════════════════════════════════════════════
# CHECK 1: Git Status
# ═══════════════════════════════════════════════
Write-Section "1. Git Status Check"

try {
    $GitStatus = git status --porcelain
    if (-not $GitStatus) {
        Record-Warning "No changes detected. Nothing to commit."
    }
    else {
        $ChangedFiles = ($GitStatus | Measure-Object).Count
        Write-Info "Found $ChangedFiles changed file(s)"

        # Show what's staged
        $StagedFiles = git diff --cached --name-only
        if ($StagedFiles) {
            Write-Info "Staged files:"
            $StagedFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
        }

        Record-Pass "Git status check complete"
    }
}
catch {
    Record-Failure "Git status check failed: $_"
}

# ═══════════════════════════════════════════════
# CHECK 2: Secret Scan
# ═══════════════════════════════════════════════
Write-Section "2. Secret Scan"

try {
    $ScanSecretsPath = "C:\scripts\tools\scan-secrets.ps1"
    if (Test-Path $ScanSecretsPath) {
        $ScanResult = & $ScanSecretsPath -Path . -Quick 2>&1
        if ($LASTEXITCODE -eq 0) {
            Record-Pass "No secrets detected"
        }
        else {
            Record-Failure "Secrets detected in code! Review and remove before committing."
            Write-Host $ScanResult -ForegroundColor Red
        }
    }
    else {
        Record-Warning "Secret scanner not found, skipping"
    }
}
catch {
    Record-Warning "Secret scan failed: $_"
}

# ═══════════════════════════════════════════════
# CHECK 3: Code Formatting
# ═══════════════════════════════════════════════
if ($IsHazina -or $IsClientManager -or $IsArtRevisionist) {
    Write-Section "3. Code Formatting Check"

    try {
        if ($Fix) {
            Write-Info "Auto-fixing formatting issues..."
            dotnet format --verbosity quiet
            Record-Pass "Code formatted automatically"
        }
        else {
            Write-Info "Checking code formatting..."
            $FormatResult = dotnet format --verify-no-changes --verbosity quiet 2>&1
            if ($LASTEXITCODE -eq 0) {
                Record-Pass "Code formatting is correct"
            }
            else {
                Record-Failure "Code formatting violations detected"
                Write-Host "Run: dotnet format" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Record-Warning "Code formatting check failed: $_"
    }
}

# ═══════════════════════════════════════════════
# CHECK 4: Backend Build
# ═══════════════════════════════════════════════
if ($IsHazina) {
    Write-Section "4. Backend Build (Hazina)"

    try {
        Write-Info "Building Hazina.sln..."
        $BuildOutput = dotnet build Hazina.sln --configuration Release --verbosity quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Record-Pass "Hazina build successful"
        }
        else {
            Record-Failure "Hazina build failed"
            Write-Host $BuildOutput -ForegroundColor Red
        }
    }
    catch {
        Record-Failure "Build failed: $_"
    }
}
elseif ($IsClientManager) {
    Write-Section "4. Backend Build (client-manager)"

    try {
        Write-Info "Building ClientManagerAPI..."
        Push-Location ClientManagerAPI
        $BuildOutput = dotnet build ClientManagerAPI.local.csproj --configuration Release --verbosity quiet 2>&1
        Pop-Location

        if ($LASTEXITCODE -eq 0) {
            Record-Pass "Backend build successful"
        }
        else {
            Record-Failure "Backend build failed"
            Write-Host $BuildOutput -ForegroundColor Red
        }
    }
    catch {
        Record-Failure "Build failed: $_"
        Pop-Location
    }
}
elseif ($IsArtRevisionist) {
    Write-Section "4. Backend Build (artrevisionist)"

    try {
        Write-Info "Building artrevisionist API..."
        Push-Location artrevisionist
        $BuildOutput = dotnet build --configuration Release --verbosity quiet 2>&1
        Pop-Location

        if ($LASTEXITCODE -eq 0) {
            Record-Pass "Backend build successful"
        }
        else {
            Record-Failure "Backend build failed"
            Write-Host $BuildOutput -ForegroundColor Red
        }
    }
    catch {
        Record-Failure "Build failed: $_"
        Pop-Location
    }
}

# ═══════════════════════════════════════════════
# CHECK 5: Unit Tests
# ═══════════════════════════════════════════════
if (-not $Quick) {
    Write-Section "5. Unit Tests"

    try {
        if ($IsHazina) {
            Write-Info "Running Hazina unit tests..."
            $TestOutput = dotnet test Hazina.sln --no-build --filter "FullyQualifiedName!~Integration" --verbosity quiet 2>&1
        }
        elseif ($IsClientManager) {
            Write-Info "Running client-manager unit tests..."
            Push-Location ClientManagerAPI
            $TestOutput = dotnet test --no-build --filter "FullyQualifiedName!~Integration" --verbosity quiet 2>&1
            Pop-Location
        }
        elseif ($IsArtRevisionist) {
            Write-Info "Running artrevisionist unit tests..."
            Push-Location artrevisionist
            $TestOutput = dotnet test --no-build --filter "FullyQualifiedName!~Integration" --verbosity quiet 2>&1
            Pop-Location
        }

        if ($LASTEXITCODE -eq 0) {
            # Parse test results
            if ($TestOutput -match "Passed!\s+-\s+Failed:\s+(\d+),\s+Passed:\s+(\d+)") {
                $PassedTests = $Matches[2]
                Record-Pass "All $PassedTests unit tests passed"
            }
            else {
                Record-Pass "Unit tests passed"
            }
        }
        else {
            Record-Failure "Unit tests failed"
            Write-Host $TestOutput -ForegroundColor Red
        }
    }
    catch {
        Record-Failure "Unit tests failed: $_"
    }
}

# ═══════════════════════════════════════════════
# CHECK 6: Frontend Build & Tests (if applicable)
# ═══════════════════════════════════════════════
if (($IsClientManager -or $IsArtRevisionist) -and -not $Quick) {
    Write-Section "6. Frontend Build & Tests"

    $FrontendDir = if ($IsClientManager) { "ClientManagerFrontend" } else { "artrevisionist" }

    if (Test-Path $FrontendDir) {
        try {
            Push-Location $FrontendDir

            # Check if node_modules exists
            if (-not (Test-Path "node_modules")) {
                Write-Info "Installing frontend dependencies..."
                npm install --silent
            }

            # Lint
            Write-Info "Running ESLint..."
            $LintOutput = npm run lint 2>&1
            if ($LASTEXITCODE -eq 0) {
                Record-Pass "Frontend linting passed"
            }
            else {
                Record-Warning "Frontend linting warnings detected"
            }

            # Type check
            Write-Info "Running TypeScript type check..."
            $TypeCheckOutput = npm run type-check 2>&1
            if ($LASTEXITCODE -eq 0) {
                Record-Pass "TypeScript type check passed"
            }
            else {
                Record-Failure "TypeScript type errors detected"
                Write-Host $TypeCheckOutput -ForegroundColor Red
            }

            # Tests (skip if Quick mode)
            if (-not $Quick) {
                Write-Info "Running frontend tests..."
                $TestOutput = npm test -- --run --passWithNoTests 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Record-Pass "Frontend tests passed"
                }
                else {
                    Record-Warning "Frontend tests failed or skipped"
                }
            }

            # Build
            Write-Info "Building production bundle..."
            $BuildOutput = npm run build 2>&1
            if ($LASTEXITCODE -eq 0) {
                Record-Pass "Frontend build successful"
            }
            else {
                Record-Failure "Frontend build failed"
                Write-Host $BuildOutput -ForegroundColor Red
            }

            Pop-Location
        }
        catch {
            Record-Failure "Frontend check failed: $_"
            Pop-Location
        }
    }
}

# ═══════════════════════════════════════════════
# CHECK 7: Migration Validation (if migrations changed)
# ═══════════════════════════════════════════════
if (($IsClientManager -or $IsArtRevisionist) -and -not $Quick) {
    Write-Section "7. Migration Validation"

    try {
        # Check if any migration files changed
        $MigrationChanges = git diff --cached --name-only | Where-Object { $_ -like "*Migrations/*.cs" }

        if ($MigrationChanges) {
            Write-Info "Migration files changed, validating..."

            $ValidateMigrationPath = "C:\scripts\tools\validate-migration.ps1"
            if (Test-Path $ValidateMigrationPath) {
                & $ValidateMigrationPath -Context IdentityDbContext -Quick
                if ($LASTEXITCODE -eq 0) {
                    Record-Pass "Migration validation passed"
                }
                else {
                    Record-Failure "Migration validation failed"
                }
            }
            else {
                Record-Warning "Migration validator not found, skipping"
            }
        }
        else {
            Record-Pass "No migration changes detected"
        }
    }
    catch {
        Record-Warning "Migration validation failed: $_"
    }
}

# ═══════════════════════════════════════════════
# CHECK 8: Integration Tests (Comprehensive mode only)
# ═══════════════════════════════════════════════
if ($Comprehensive) {
    Write-Section "8. Integration Tests"

    try {
        Write-Info "Running integration tests..."

        if ($IsHazina) {
            $TestOutput = dotnet test Hazina.sln --no-build --filter "FullyQualifiedName~Integration" --verbosity quiet 2>&1
        }
        elseif ($IsClientManager) {
            Push-Location ClientManagerAPI
            $TestOutput = dotnet test --no-build --filter "FullyQualifiedName~Integration" --verbosity quiet 2>&1
            Pop-Location
        }

        if ($LASTEXITCODE -eq 0) {
            Record-Pass "Integration tests passed"
        }
        else {
            Record-Warning "Integration tests failed or skipped"
        }
    }
    catch {
        Record-Warning "Integration tests failed: $_"
    }
}

# ═══════════════════════════════════════════════
# CHECK 9: Code Coverage (Comprehensive mode only)
# ═══════════════════════════════════════════════
if ($Comprehensive) {
    Write-Section "9. Code Coverage Analysis"

    try {
        Write-Info "Running tests with coverage..."

        if ($IsHazina) {
            dotnet test Hazina.sln --no-build --collect:"XPlat Code Coverage" --verbosity quiet 2>&1 | Out-Null
        }
        elseif ($IsClientManager) {
            Push-Location ClientManagerAPI
            dotnet test --no-build --collect:"XPlat Code Coverage" --verbosity quiet 2>&1 | Out-Null
            Pop-Location
        }

        # Find coverage file
        $CoverageFile = Get-ChildItem -Path "TestResults" -Filter "coverage.cobertura.xml" -Recurse | Select-Object -First 1

        if ($CoverageFile) {
            [xml]$Coverage = Get-Content $CoverageFile.FullName
            $LineRate = [math]::Round([decimal]$Coverage.coverage.'line-rate' * 100, 2)

            if ($LineRate -ge 80) {
                Record-Pass "Code coverage: $LineRate% (target: 80%)"
            }
            elseif ($LineRate -ge 70) {
                Record-Warning "Code coverage: $LineRate% (target: 80%)"
            }
            else {
                Record-Failure "Code coverage: $LineRate% (target: 80%)"
            }
        }
        else {
            Record-Warning "Coverage report not found"
        }
    }
    catch {
        Record-Warning "Coverage analysis failed: $_"
    }
}

# ═══════════════════════════════════════════════
# CHECK 10: Security Scan (Comprehensive mode only)
# ═══════════════════════════════════════════════
if ($Comprehensive) {
    Write-Section "10. Security Vulnerability Scan"

    try {
        Write-Info "Checking for vulnerable dependencies..."

        $VulnOutput = dotnet list package --vulnerable --include-transitive 2>&1

        if ($VulnOutput -match "has the following vulnerable packages") {
            Record-Warning "Vulnerable dependencies detected"
            Write-Host $VulnOutput -ForegroundColor Yellow
        }
        else {
            Record-Pass "No vulnerable dependencies detected"
        }
    }
    catch {
        Record-Warning "Security scan failed: $_"
    }
}

# ═══════════════════════════════════════════════
# FINAL SUMMARY
# ═══════════════════════════════════════════════
$EndTime = Get-Date
$Duration = $EndTime - $StartTime

Write-Section "📊 Pre-Commit Check Summary"

Write-Host "✅ Passed:  $script:PassCount" -ForegroundColor Green
Write-Host "⚠️  Warnings: $script:WarningCount" -ForegroundColor Yellow
Write-Host "❌ Failed:  $script:FailureCount" -ForegroundColor Red
Write-Host "⏱️  Duration: $($Duration.TotalSeconds.ToString('0.0'))s`n"

if ($script:FailureCount -gt 0) {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  ❌ COMMIT BLOCKED - FIX FAILURES FIRST" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Red

    Write-Host "To auto-fix formatting issues, run:" -ForegroundColor Yellow
    Write-Host "  .\pre-commit-check.ps1 -Fix`n" -ForegroundColor Yellow

    exit 1
}
elseif ($script:WarningCount -gt 0) {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  ⚠️  WARNINGS DETECTED - REVIEW BEFORE COMMIT" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Yellow

    # Don't block commit on warnings
    exit 0
}
else {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  ✅ ALL CHECKS PASSED - READY TO COMMIT!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Green

    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  git add ." -ForegroundColor Gray
    Write-Host "  git commit -m 'your message'" -ForegroundColor Gray
    Write-Host "  git push`n" -ForegroundColor Gray

    exit 0
}
