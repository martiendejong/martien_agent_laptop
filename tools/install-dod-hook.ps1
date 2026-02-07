<#
.SYNOPSIS
    Install Definition of Done pre-commit hook

.DESCRIPTION
    Installs the DoD validation hook into a Git repository's .git/hooks directory.
    The hook will run automatically before every commit to enforce quality standards.

.PARAMETER RepoPath
    Path to Git repository (default: current directory)

.PARAMETER Force
    Overwrite existing pre-commit hook if present

.EXAMPLE
    .\install-dod-hook.ps1

.EXAMPLE
    .\install-dod-hook.ps1 -RepoPath "C:\Projects\client-manager"

.EXAMPLE
    .\install-dod-hook.ps1 -Force  # Overwrite existing hook
#>

param(
    [string]$RepoPath = $PWD,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  DoD Pre-Commit Hook Installer" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to repo
Push-Location $RepoPath

try {
    # Verify this is a Git repo
    if (-not (Test-Path ".git")) {
        Write-Host "❌ ERROR: Not a Git repository" -ForegroundColor Red
        Write-Host "   Path: $RepoPath" -ForegroundColor Gray
        exit 1
    }

    Write-Host "✅ Git repository found" -ForegroundColor Green
    Write-Host "   Path: $RepoPath" -ForegroundColor Gray
    Write-Host ""

    # Check for existing hook
    $hookPath = ".git\hooks\pre-commit"
    $hookExists = Test-Path $hookPath

    if ($hookExists -and -not $Force) {
        Write-Host "⚠️  Pre-commit hook already exists" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Options:" -ForegroundColor Cyan
        Write-Host "  1. Backup and replace: .\install-dod-hook.ps1 -Force" -ForegroundColor Gray
        Write-Host "  2. Manually merge hooks" -ForegroundColor Gray
        Write-Host ""
        exit 0
    }

    # Backup existing hook
    if ($hookExists) {
        $backupPath = ".git\hooks\pre-commit.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Write-Host "📦 Backing up existing hook..." -ForegroundColor Yellow
        Copy-Item $hookPath $backupPath
        Write-Host "   Backup: $backupPath" -ForegroundColor Gray
        Write-Host ""
    }

    # Create hooks directory if doesn't exist
    $hooksDir = ".git\hooks"
    if (-not (Test-Path $hooksDir)) {
        New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
    }

    # Copy hook from example
    $examplePath = "C:\scripts\tools\pre-commit.example"
    if (Test-Path $examplePath) {
        Write-Host "📝 Installing pre-commit hook..." -ForegroundColor Cyan
        Copy-Item $examplePath $hookPath -Force
        Write-Host "   Installed: $hookPath" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "⚠️  Warning: Example hook not found at $examplePath" -ForegroundColor Yellow
        Write-Host "   Creating basic hook..." -ForegroundColor Gray

        # Create basic hook inline
        @"
#!/bin/sh
# Definition of Done Pre-Commit Hook
echo ""
echo "Running Definition of Done checks..."
echo ""

pwsh -File "C:\scripts\tools\dod-pre-commit-check.ps1" -ProjectPath "."

EXIT_CODE=`$?

if [ `$EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ COMMIT BLOCKED: Fix DoD failures above"
    echo ""
    echo "To bypass (not recommended): git commit --no-verify"
    echo ""
    exit 1
fi

echo ""
echo "✅ All DoD checks passed!"
echo ""
exit 0
"@ | Set-Content $hookPath -Encoding UTF8

        Write-Host "   Created: $hookPath" -ForegroundColor Gray
        Write-Host ""
    }

    # Make hook executable (Git Bash requirement)
    # Note: On Windows with Git Bash, this is handled by Git
    Write-Host "✅ Installation complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 What happens now:" -ForegroundColor Cyan
    Write-Host "  • Every 'git commit' will run DoD validation" -ForegroundColor Gray
    Write-Host "  • Checks: Build, tests, formatting, migrations, secrets" -ForegroundColor Gray
    Write-Host "  • Commit blocked if checks fail" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🧪 Test the hook:" -ForegroundColor Cyan
    Write-Host "  git commit -m 'test' --allow-empty" -ForegroundColor Gray
    Write-Host ""
    Write-Host "⏭️  Bypass hook (not recommended):" -ForegroundColor Cyan
    Write-Host "  git commit --no-verify" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔧 Uninstall:" -ForegroundColor Cyan
    Write-Host "  Remove-Item .git\hooks\pre-commit" -ForegroundColor Gray
    Write-Host ""

} finally {
    Pop-Location
}
