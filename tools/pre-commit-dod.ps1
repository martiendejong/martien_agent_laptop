<#
.SYNOPSIS
    Pre-commit hook to verify Definition of Done (DoD) criteria

.DESCRIPTION
    Validates common DoD criteria before allowing commits:
    - Build succeeds
    - Tests pass
    - Code is formatted
    - No pending EF migrations
    - No hardcoded secrets
    - No debug statements in production code

.PARAMETER SkipBuild
    Skip build verification (faster for non-code changes)

.PARAMETER SkipTests
    Skip test verification (use sparingly)

.PARAMETER Context
    EF Core DbContext name for migration check (default: IdentityDbContext)

.EXAMPLE
    .\pre-commit-dod.ps1
    Run full DoD verification before commit

.EXAMPLE
    .\pre-commit-dod.ps1 -SkipBuild -SkipTests
    Quick verification (docs-only changes)

.NOTES
    Reference: C:\scripts\_machine\DEFINITION_OF_DONE.md
    Part of: MANDATORY_CODE_WORKFLOW.md Step 5
#>

param(
    [switch]$SkipBuild,
    [switch]$SkipTests,
    [string]$Context = "IdentityDbContext"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "🎯 Definition of Done Pre-Commit Verification" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

$failed = $false
$warnings = @()

# Detect repository root
$repoRoot = git rev-parse --show-toplevel 2>$null
if (-not $repoRoot) {
    Write-Host "❌ Not in a git repository" -ForegroundColor Red
    exit 1
}

Write-Host "📁 Repository: $repoRoot" -ForegroundColor Gray
Write-Host ""

# Check 1: No hardcoded secrets
Write-Host "🔐 Checking for hardcoded secrets..." -ForegroundColor Yellow
$secretPatterns = @(
    "password\s*=\s*[`"'][^`"']+[`"']",
    "api[_-]?key\s*=\s*[`"'][^`"']+[`"']",
    "secret\s*=\s*[`"'][^`"']+[`"']",
    "token\s*=\s*[`"'][^`"']+[`"']",
    "connectionstring\s*=\s*[`"'][^`"']+[`"']"
)

$stagedFiles = git diff --cached --name-only --diff-filter=ACM
foreach ($pattern in $secretPatterns) {
    foreach ($file in $stagedFiles) {
        if (Test-Path $file) {
            $matches = Select-String -Path $file -Pattern $pattern -CaseSensitive:$false
            if ($matches) {
                Write-Host "  ⚠️  Potential secret in: $file" -ForegroundColor Yellow
                $warnings += "Potential hardcoded secret in $file"
            }
        }
    }
}

if ($warnings.Count -eq 0) {
    Write-Host "  ✅ No obvious secrets detected" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  $($warnings.Count) potential secrets found" -ForegroundColor Yellow
}
Write-Host ""

# Check 2: No debug statements in C# files
Write-Host "🐛 Checking for debug statements..." -ForegroundColor Yellow
$debugCount = 0
$csFiles = $stagedFiles | Where-Object { $_ -match '\.cs$' }
foreach ($file in $csFiles) {
    if (Test-Path $file) {
        $debugLines = Select-String -Path $file -Pattern "Console\.WriteLine|Debugger\.Break|Debug\.WriteLine" -CaseSensitive
        if ($debugLines) {
            Write-Host "  ⚠️  Debug statement in: $file" -ForegroundColor Yellow
            $debugCount++
        }
    }
}

if ($debugCount -eq 0) {
    Write-Host "  ✅ No debug statements found" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  $debugCount files with debug statements" -ForegroundColor Yellow
    $warnings += "$debugCount files contain debug statements"
}
Write-Host ""

# Check 3: Build passes
if (-not $SkipBuild) {
    Write-Host "🔨 Building project..." -ForegroundColor Yellow

    # Find .csproj or .sln file
    $projectFile = Get-ChildItem -Path $repoRoot -Filter "*.sln" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $projectFile) {
        $projectFile = Get-ChildItem -Path $repoRoot -Filter "*.csproj" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    }

    if ($projectFile) {
        $buildResult = dotnet build "$($projectFile.FullName)" --configuration Release --verbosity quiet 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ❌ Build failed!" -ForegroundColor Red
            Write-Host $buildResult -ForegroundColor Red
            $failed = $true
        } else {
            Write-Host "  ✅ Build succeeded" -ForegroundColor Green
        }
    } else {
        Write-Host "  ⚠️  No .sln or .csproj found, skipping build" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⏭️  Build check skipped" -ForegroundColor Gray
}
Write-Host ""

# Check 4: Tests pass
if (-not $SkipTests -and -not $SkipBuild) {
    Write-Host "🧪 Running tests..." -ForegroundColor Yellow

    # Find test projects
    $testProjects = Get-ChildItem -Path $repoRoot -Filter "*Tests.csproj" -Recurse -ErrorAction SilentlyContinue

    if ($testProjects) {
        foreach ($testProj in $testProjects) {
            $testResult = dotnet test "$($testProj.FullName)" --configuration Release --verbosity quiet --no-build 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  ❌ Tests failed: $($testProj.Name)" -ForegroundColor Red
                $failed = $true
            } else {
                Write-Host "  ✅ Tests passed: $($testProj.Name)" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  ℹ️  No test projects found" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⏭️  Test check skipped" -ForegroundColor Gray
}
Write-Host ""

# Check 5: No pending EF Core migrations
Write-Host "📊 Checking for pending EF migrations..." -ForegroundColor Yellow

$efCoreProjects = Get-ChildItem -Path $repoRoot -Filter "*.csproj" -Recurse | Where-Object {
    $content = Get-Content $_.FullName -Raw
    $content -match "Microsoft\.EntityFrameworkCore"
}

if ($efCoreProjects) {
    foreach ($proj in $efCoreProjects) {
        Push-Location (Split-Path $proj.FullName)
        try {
            $migrationCheck = dotnet ef migrations has-pending-model-changes --context $Context 2>&1
            $exitCode = $LASTEXITCODE

            if ($exitCode -eq 0) {
                Write-Host "  ✅ No pending migrations ($Context)" -ForegroundColor Green
            } elseif ($exitCode -eq 1) {
                Write-Host "  ❌ Pending model changes detected!" -ForegroundColor Red
                Write-Host "  💡 Run: dotnet ef migrations add <Name> --context $Context" -ForegroundColor Yellow
                $failed = $true
            } else {
                Write-Host "  ⚠️  Could not check migrations ($Context)" -ForegroundColor Yellow
                $warnings += "Migration check failed for $Context"
            }
        } finally {
            Pop-Location
        }
        break # Only check first EF project
    }
} else {
    Write-Host "  ℹ️  No EF Core projects found" -ForegroundColor Gray
}
Write-Host ""

# Check 6: Code formatting (if cs-format.ps1 available)
$csFormatPath = "C:\scripts\tools\cs-format.ps1"
if (Test-Path $csFormatPath) {
    Write-Host "💅 Checking code formatting..." -ForegroundColor Yellow

    $formatResult = & $csFormatPath -Check -Path $repoRoot 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠️  Code formatting issues detected" -ForegroundColor Yellow
        Write-Host "  💡 Run: cs-format.ps1 -Path '$repoRoot'" -ForegroundColor Yellow
        $warnings += "Code formatting issues detected"
    } else {
        Write-Host "  ✅ Code properly formatted" -ForegroundColor Green
    }
} else {
    Write-Host "  ⏭️  cs-format.ps1 not found, skipping" -ForegroundColor Gray
}
Write-Host ""

# Summary
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

if ($failed) {
    Write-Host "❌ COMMIT BLOCKED: Definition of Done criteria not met" -ForegroundColor Red
    Write-Host ""
    Write-Host "Fix the issues above before committing." -ForegroundColor Yellow
    Write-Host "See: C:\scripts\_machine\DEFINITION_OF_DONE.md" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

if ($warnings.Count -gt 0) {
    Write-Host "⚠️  WARNINGS DETECTED:" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  • $warning" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Proceeding with commit, but please review warnings." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "✅ All DoD checks passed! Commit allowed." -ForegroundColor Green
Write-Host ""
exit 0
