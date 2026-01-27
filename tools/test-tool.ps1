<#
.SYNOPSIS
    Run tests for generated tools

.DESCRIPTION
    Executes Pester tests for tools created by create-tool-from-pattern.ps1

.PARAMETER ToolName
    Name of tool to test (without .ps1 extension)

.PARAMETER Verbose
    Show detailed test output

.EXAMPLE
    .\test-tool.ps1 -ToolName "deploy-app"

.EXAMPLE
    .\test-tool.ps1 -ToolName "sync-database" -Verbose
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ToolName,

    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Tool Test Runner" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$testPath = "C:\scripts\tools\tests\$ToolName.Tests.ps1"

if (-not (Test-Path $testPath)) {
    Write-Host "❌ Test file not found: $testPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Generate tests with:" -ForegroundColor Yellow
    Write-Host "  .\create-tool-from-pattern.ps1 -ToolName `"$ToolName`" -GenerateTests" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "Running tests: $testPath" -ForegroundColor Cyan
Write-Host ""

# Check if Pester is installed
$pesterModule = Get-Module -ListAvailable -Name Pester

if (-not $pesterModule) {
    Write-Host "⚠️ Pester not installed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Install Pester:" -ForegroundColor Cyan
    Write-Host "  Install-Module -Name Pester -Force -SkipPublisherCheck" -ForegroundColor Gray
    Write-Host ""
    Write-Host "For now, doing basic syntax check..." -ForegroundColor Yellow
    Write-Host ""

    # Basic syntax check
    try {
        $null = [System.Management.Automation.Language.Parser]::ParseFile($testPath, [ref]$null, [ref]$errors)
        if ($errors.Count -eq 0) {
            Write-Host "✅ Test file syntax is valid" -ForegroundColor Green
        } else {
            Write-Host "❌ Syntax errors found:" -ForegroundColor Red
            $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        }
    } catch {
        Write-Host "❌ Error parsing test file: $_" -ForegroundColor Red
    }

    exit 0
}

# Run Pester tests
try {
    $config = New-PesterConfiguration
    $config.Run.Path = $testPath
    $config.Output.Verbosity = if ($Verbose) { 'Detailed' } else { 'Normal' }

    $result = Invoke-Pester -Configuration $config

    Write-Host ""
    if ($result.Result -eq 'Passed') {
        Write-Host "✅ All tests passed!" -ForegroundColor Green
    } else {
        Write-Host "❌ Some tests failed" -ForegroundColor Red
    }
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "Error running tests: $_" -ForegroundColor Red
    exit 1
}
