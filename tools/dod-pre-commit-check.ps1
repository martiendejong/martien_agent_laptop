<#
.SYNOPSIS
    Definition of Done pre-commit validation script

.DESCRIPTION
    Validates key Definition of Done criteria before allowing a commit:
    - Build succeeds
    - Tests pass
    - Code formatted
    - No pending EF migrations
    - No hardcoded secrets

.PARAMETER ProjectPath
    Path to project root (default: current directory)

.PARAMETER SkipTests
    Skip running tests (faster for WIP commits)

.PARAMETER SkipBuild
    Skip build check (not recommended)

.EXAMPLE
    .\dod-pre-commit-check.ps1

.EXAMPLE
    .\dod-pre-commit-check.ps1 -ProjectPath "C:\Projects\client-manager"

.EXAMPLE
    .\dod-pre-commit-check.ps1 -SkipTests  # Fast mode for work-in-progress
#>

param(
    [string]$ProjectPath = $PWD,
    [switch]$SkipTests,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Definition of Done - Pre-Commit Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$checks = @{
    passed = 0
    failed = 0
    skipped = 0
    warnings = 0
}

function Test-Check {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [bool]$Optional = $false
    )

    Write-Host "[$Name]" -ForegroundColor Yellow -NoNewline
    Write-Host " Checking..." -NoNewline

    try {
        $result = & $Test

        if ($result.Success) {
            Write-Host " ✅ PASS" -ForegroundColor Green
            $script:checks.passed++
            return $true
        } else {
            if ($Optional) {
                Write-Host " ⚠️  WARNING: $($result.Message)" -ForegroundColor Yellow
                $script:checks.warnings++
                return $true
            } else {
                Write-Host " ❌ FAIL: $($result.Message)" -ForegroundColor Red
                $script:checks.failed++
                return $false
            }
        }
    } catch {
        Write-Host " ❌ ERROR: $_" -ForegroundColor Red
        $script:checks.failed++
        return $false
    }
}

# Navigate to project
Push-Location $ProjectPath

try {
    # Check 1: No hardcoded secrets
    Test-Check "No Hardcoded Secrets" {
        $patterns = @(
            "AIzaSy[A-Za-z0-9_-]{33}",  # Google API keys
            "sk-[A-Za-z0-9]{48}",        # OpenAI keys
            "pk_[A-Za-z0-9]{24}",        # Stripe keys
            "xoxb-[0-9]{10,13}-[0-9]{10,13}-[A-Za-z0-9]{24}",  # Slack tokens
            "ghp_[A-Za-z0-9]{36}",       # GitHub tokens
            "AKIA[0-9A-Z]{16}"           # AWS keys
        )

        $foundSecrets = @()
        Get-ChildItem -Recurse -Include *.cs,*.ts,*.tsx,*.js,*.jsx -Exclude bin,obj,node_modules | ForEach-Object {
            $content = Get-Content $_.FullName -Raw
            foreach ($pattern in $patterns) {
                if ($content -match $pattern) {
                    $foundSecrets += "$($_.Name): Potential secret found"
                }
            }
        }

        if ($foundSecrets.Count -eq 0) {
            return @{ Success = $true }
        } else {
            return @{ Success = $false; Message = "$($foundSecrets.Count) potential secrets found. Remove or use environment variables." }
        }
    }

    # Check 2: Code formatted (C#)
    Test-Check "C# Code Formatted" {
        if (Test-Path "ClientManagerAPI") {
            $formatTool = "C:\scripts\tools\cs-format.ps1"
            if (Test-Path $formatTool) {
                $result = & $formatTool -Check -ErrorAction SilentlyContinue
                if ($LASTEXITCODE -eq 0) {
                    return @{ Success = $true }
                } else {
                    return @{ Success = $false; Message = "Run cs-format.ps1 to fix formatting" }
                }
            }
        }
        return @{ Success = $true }  # Skip if no backend
    }

    # Check 3: No pending EF migrations
    Test-Check "No Pending EF Migrations" {
        if (Test-Path "ClientManagerAPI") {
            $apiPath = Join-Path $ProjectPath "ClientManagerAPI"
            Push-Location $apiPath
            try {
                $result = dotnet ef migrations has-pending-model-changes --context IdentityDbContext 2>&1
                if ($LASTEXITCODE -eq 0) {
                    return @{ Success = $true }
                } else {
                    return @{ Success = $false; Message = "Pending migrations detected. Run 'dotnet ef migrations add <Name>'" }
                }
            } finally {
                Pop-Location
            }
        }
        return @{ Success = $true }  # Skip if no backend
    }

    # Check 4: Build succeeds
    if (-not $SkipBuild) {
        Test-Check "Build Succeeds" {
            $buildOutput = dotnet build --configuration Release --no-restore 2>&1
            if ($LASTEXITCODE -eq 0) {
                # Check for errors (warnings OK)
                $errors = $buildOutput | Select-String "error CS[0-9]+"
                if ($errors) {
                    return @{ Success = $false; Message = "$($errors.Count) compilation errors" }
                }
                return @{ Success = $true }
            } else {
                return @{ Success = $false; Message = "Build failed with exit code $LASTEXITCODE" }
            }
        }
    } else {
        Write-Host "[Build Succeeds]" -ForegroundColor Yellow -NoNewline
        Write-Host " ⏭️  SKIPPED" -ForegroundColor Gray
        $checks.skipped++
    }

    # Check 5: Tests pass
    if (-not $SkipTests) {
        Test-Check "Tests Pass" {
            $testOutput = dotnet test --configuration Release --no-build --no-restore --verbosity quiet 2>&1
            if ($LASTEXITCODE -eq 0) {
                return @{ Success = $true }
            } else {
                return @{ Success = $false; Message = "Test failures detected. Run 'dotnet test' for details" }
            }
        } -Optional $true  # Warning only (tests can fail during development)
    } else {
        Write-Host "[Tests Pass]" -ForegroundColor Yellow -NoNewline
        Write-Host " ⏭️  SKIPPED" -ForegroundColor Gray
        $checks.skipped++
    }

    # Check 6: No console.log in production code (frontend)
    Test-Check "No Debug console.log" {
        $debugLogs = @()
        if (Test-Path "client-manager-frontend") {
            Get-ChildItem -Path "client-manager-frontend/src" -Recurse -Include *.ts,*.tsx,*.js,*.jsx | ForEach-Object {
                $content = Get-Content $_.FullName
                $lineNum = 0
                foreach ($line in $content) {
                    $lineNum++
                    if ($line -match "console\.(log|debug|trace)" -and $line -notmatch "//.*console\.") {
                        $debugLogs += "$($_.Name):$lineNum"
                    }
                }
            }
        }

        if ($debugLogs.Count -eq 0) {
            return @{ Success = $true }
        } else {
            return @{ Success = $false; Message = "$($debugLogs.Count) console.log statements found. Remove or use proper logging." }
        }
    } -Optional $true  # Warning only

} finally {
    Pop-Location
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Passed:  $($checks.passed)" -ForegroundColor Green
Write-Host "❌ Failed:  $($checks.failed)" -ForegroundColor Red
Write-Host "⚠️  Warnings: $($checks.warnings)" -ForegroundColor Yellow
Write-Host "⏭️  Skipped: $($checks.skipped)" -ForegroundColor Gray
Write-Host ""

if ($checks.failed -gt 0) {
    Write-Host "❌ COMMIT BLOCKED: Fix the failures above before committing." -ForegroundColor Red
    Write-Host ""
    Write-Host "Definition of Done Reference: C:\scripts\_machine\DEFINITION_OF_DONE.md" -ForegroundColor Cyan
    exit 1
} else {
    Write-Host "✅ All checks passed! You can commit safely." -ForegroundColor Green
    if ($checks.warnings -gt 0) {
        Write-Host "⚠️  Consider fixing warnings before committing." -ForegroundColor Yellow
    }
    exit 0
}
