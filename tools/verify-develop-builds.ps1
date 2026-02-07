<#
.SYNOPSIS
    Verify all develop branches build successfully

.DESCRIPTION
    Checks that client-manager, hazina, and art-revisionist develop branches
    build without errors. Tests backends, frontends, and runs Playwright tests.

.PARAMETER Projects
    Which projects to verify (default: all)

.PARAMETER SkipTests
    Skip Playwright tests (only build verification)

.EXAMPLE
    .\verify-develop-builds.ps1
    .\verify-develop-builds.ps1 -Projects client-manager,hazina
    .\verify-develop-builds.ps1 -SkipTests

.NOTES
    This should be run:
    - After PR merges to develop
    - At session start (to verify clean state)
    - Before deploying
    - Daily as part of CI health check
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("client-manager", "hazina", "art-revisionist", "all")]
    [string[]]$Projects = @("all"),

    [Parameter(Mandatory=$false)]
    [switch]$SkipTests
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "🔨 DEVELOP BRANCH BUILD VERIFICATION" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$results = @()
$hasErrors = $false

# Determine which projects to check
$projectsToCheck = if ($Projects -contains "all") {
    @("client-manager", "hazina", "art-revisionist")
} else {
    $Projects
}

# Function to test build
function Test-Build {
    param(
        [string]$ProjectName,
        [string]$Path,
        [string]$BuildCommand,
        [string]$Type  # "backend", "frontend", "wordpress"
    )

    Write-Host ""
    Write-Host "[$ProjectName] $Type Build" -ForegroundColor Yellow
    Write-Host "-------------------" -ForegroundColor Gray

    if (-not (Test-Path $Path)) {
        Write-Host "  ❌ Path not found: $Path" -ForegroundColor Red
        return @{
            Project = $ProjectName
            Type = $Type
            Status = "ERROR"
            Message = "Path not found"
        }
    }

    Push-Location $Path
    try {
        # Check branch
        $branch = git branch --show-current
        if ($branch -ne "develop") {
            Write-Host "  ⚠️ WARNING: Not on develop branch (currently on: $branch)" -ForegroundColor Yellow
            Write-Host "  Switching to develop..." -ForegroundColor Yellow
            git checkout develop 2>&1 | Out-Null
            git pull origin develop 2>&1 | Out-Null
        }

        Write-Host "  Branch: develop" -ForegroundColor Green
        Write-Host "  Command: $BuildCommand" -ForegroundColor Gray

        # Execute build
        $output = Invoke-Expression $BuildCommand 2>&1
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Host "  ✅ Build successful" -ForegroundColor Green
            return @{
                Project = $ProjectName
                Type = $Type
                Status = "SUCCESS"
                Message = "Build completed"
            }
        } else {
            Write-Host "  ❌ Build failed (exit code: $exitCode)" -ForegroundColor Red

            # Show last 10 lines of errors
            $errorLines = $output | Select-Object -Last 10
            Write-Host "  Last 10 lines:" -ForegroundColor Red
            $errorLines | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }

            return @{
                Project = $ProjectName
                Type = $Type
                Status = "FAILED"
                Message = "Build failed with exit code $exitCode"
                ErrorOutput = $errorLines
            }
        }
    }
    catch {
        Write-Host "  ❌ Exception: $($_.Exception.Message)" -ForegroundColor Red
        return @{
            Project = $ProjectName
            Type = $Type
            Status = "ERROR"
            Message = $_.Exception.Message
        }
    }
    finally {
        Pop-Location
    }
}

# CLIENT-MANAGER
if ($projectsToCheck -contains "client-manager") {
    Write-Host ""
    Write-Host "==================== CLIENT-MANAGER ====================" -ForegroundColor Cyan

    # Backend
    $result = Test-Build -ProjectName "client-manager" `
                        -Path "C:\Projects\client-manager\ClientManagerAPI" `
                        -BuildCommand "dotnet build --configuration Release --no-restore" `
                        -Type "backend"
    $results += $result
    if ($result.Status -ne "SUCCESS") { $hasErrors = $true }

    # Frontend
    $result = Test-Build -ProjectName "client-manager" `
                        -Path "C:\Projects\client-manager\ClientManagerFrontend" `
                        -BuildCommand "npm run build" `
                        -Type "frontend"
    $results += $result
    if ($result.Status -ne "SUCCESS") { $hasErrors = $true }

    # Playwright tests (if not skipped)
    if (-not $SkipTests) {
        Write-Host ""
        Write-Host "[client-manager] Playwright Tests" -ForegroundColor Yellow
        Write-Host "-------------------" -ForegroundColor Gray

        $playwrightPath = "C:\Projects\client-manager\ClientManagerFrontend"
        if (Test-Path "$playwrightPath\playwright.config.ts") {
            Push-Location $playwrightPath
            try {
                $testOutput = npx playwright test 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✅ Playwright tests passed" -ForegroundColor Green
                    $results += @{
                        Project = "client-manager"
                        Type = "tests"
                        Status = "SUCCESS"
                        Message = "All tests passed"
                    }
                } else {
                    Write-Host "  ❌ Playwright tests failed" -ForegroundColor Red
                    $results += @{
                        Project = "client-manager"
                        Type = "tests"
                        Status = "FAILED"
                        Message = "Some tests failed"
                    }
                    $hasErrors = $true
                }
            }
            finally {
                Pop-Location
            }
        } else {
            Write-Host "  ⚠️ No Playwright tests found" -ForegroundColor Yellow
        }
    }
}

# HAZINA
if ($projectsToCheck -contains "hazina") {
    Write-Host ""
    Write-Host "======================== HAZINA ========================" -ForegroundColor Cyan

    $result = Test-Build -ProjectName "hazina" `
                        -Path "C:\Projects\hazina" `
                        -BuildCommand "dotnet build Hazina.sln --configuration Release --no-restore" `
                        -Type "backend"
    $results += $result
    if ($result.Status -ne "SUCCESS") { $hasErrors = $true }
}

# ART REVISIONIST
if ($projectsToCheck -contains "art-revisionist") {
    Write-Host ""
    Write-Host "=================== ART REVISIONIST ====================" -ForegroundColor Cyan

    # Backend (WordPress/PHP)
    Write-Host ""
    Write-Host "[art-revisionist] Backend (WordPress)" -ForegroundColor Yellow
    Write-Host "-------------------" -ForegroundColor Gray

    $wpPath = "C:\xampp\htdocs"
    $wpConfigPath = "$wpPath\wp-config.php"
    if ((Test-Path $wpPath) -and (Test-Path $wpConfigPath)) {
        Write-Host "  ✅ WordPress installation found at $wpPath" -ForegroundColor Green
        $results += @{
            Project = "art-revisionist"
            Type = "backend"
            Status = "SUCCESS"
            Message = "WordPress installation exists"
        }
    } else {
        Write-Host "  ❌ WordPress installation not found" -ForegroundColor Red
        $results += @{
            Project = "art-revisionist"
            Type = "backend"
            Status = "FAILED"
            Message = "WordPress path not found at $wpPath"
        }
        $hasErrors = $true
    }

    # Frontend
    $result = Test-Build -ProjectName "art-revisionist" `
                        -Path "C:\Projects\artrevisionist\artrevisionist" `
                        -BuildCommand "npm run build" `
                        -Type "frontend"
    $results += $result
    if ($result.Status -ne "SUCCESS") { $hasErrors = $true }
}

# SUMMARY
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "📊 BUILD VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$groupedResults = $results | Group-Object Project

foreach ($group in $groupedResults) {
    $projectName = $group.Name
    Write-Host "${projectName}:" -ForegroundColor White

    foreach ($result in $group.Group) {
        $icon = switch ($result.Status) {
            "SUCCESS" { "✅" }
            "FAILED" { "❌" }
            "ERROR" { "⚠️" }
            default { "❓" }
        }

        $color = switch ($result.Status) {
            "SUCCESS" { "Green" }
            "FAILED" { "Red" }
            "ERROR" { "Yellow" }
            default { "Gray" }
        }

        Write-Host "  $icon $($result.Type): $($result.Status)" -ForegroundColor $color
        if ($result.Message) {
            Write-Host "     $($result.Message)" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

Write-Host "==========================================" -ForegroundColor Cyan
if ($hasErrors) {
    Write-Host "❌ BUILD VERIFICATION FAILED" -ForegroundColor Red
    Write-Host "Please fix the errors above before continuing." -ForegroundColor Yellow
    Write-Host ""
    exit 1
} else {
    Write-Host "✅ ALL BUILDS SUCCESSFUL" -ForegroundColor Green
    Write-Host "Develop branches are in good state." -ForegroundColor Green
    Write-Host ""
    exit 0
}
