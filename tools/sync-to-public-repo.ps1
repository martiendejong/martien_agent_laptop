<#
.SYNOPSIS
Sync C:\scripts to C:\Projects\claudescripts (public distribution repo)

.DESCRIPTION
Excludes machine-specific files (_machine/), secrets, and temporary files.
Commits and pushes to autonomous-dev-system repository.

.PARAMETER DryRun
Test mode - show what would be synced without making changes

.PARAMETER NoPush
Commit changes but don't push to remote

.PARAMETER CommitMessage
Custom commit message (default: auto-generated)

.EXAMPLE
.\sync-to-public-repo.ps1 -DryRun

.EXAMPLE
.\sync-to-public-repo.ps1

.EXAMPLE
.\sync-to-public-repo.ps1 -NoPush -CommitMessage "feat: Add new tool"
#>

param(
    [switch]$DryRun,
    [switch]$NoPush,
    [string]$CommitMessage = "sync: Update from C:\scripts production system"
)

$ErrorActionPreference = "Stop"

$sourceDir = "C:\scripts"
$targetDir = "C:\Projects\claudescripts"

Write-Host "🔄 Syncing C:\scripts → C:\Projects\claudescripts" -ForegroundColor Cyan
Write-Host ""

# Verify directories
if (-not (Test-Path $sourceDir)) {
    Write-Host "❌ Source not found: $sourceDir" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $targetDir)) {
    Write-Host "❌ Target not found: $targetDir" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "$targetDir\.git")) {
    Write-Host "❌ Target is not a git repository" -ForegroundColor Red
    exit 1
}

# Sync with robocopy
Write-Host "📁 Syncing files..." -ForegroundColor Yellow

$params = @(
    $sourceDir
    $targetDir
    '/MIR'
    '/XD', '.git', '_machine', 'node_modules'
    '/XF', '*.log', '*.tmp', '*.secret', '*.key', 'tmpclaude-*', 'temp_clickup.json'
    '/NFL', '/NDL', '/NJH', '/NJS'
)

if ($DryRun) {
    $params += '/L'
    Write-Host "🔍 DRY RUN MODE" -ForegroundColor Magenta
}

& robocopy @params | Out-Null
$exitCode = $LASTEXITCODE

if ($exitCode -ge 8) {
    Write-Host "❌ Robocopy failed: $exitCode" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Files synced" -ForegroundColor Green
Write-Host ""

# Check for changes
Push-Location $targetDir
try {
    $gitStatus = git status --short
    $changedFiles = ($gitStatus | Measure-Object).Count

    if ($changedFiles -eq 0) {
        Write-Host "✨ No changes - up to date" -ForegroundColor Green
        exit 0
    }

    Write-Host "📊 Changed files: $changedFiles" -ForegroundColor Cyan

    if ($DryRun) {
        Write-Host ""
        git status --short
        exit 0
    }

    # Commit
    Write-Host "💾 Committing..." -ForegroundColor Yellow
    git add -A
    git commit -m $CommitMessage

    Write-Host "✅ Committed" -ForegroundColor Green

    # Push
    if (-not $NoPush) {
        Write-Host "🚀 Pushing..." -ForegroundColor Yellow
        git push origin master

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Pushed to GitHub!" -ForegroundColor Green
        } else {
            Write-Host "❌ Push failed" -ForegroundColor Red
            exit 1
        }
    }

} finally {
    Pop-Location
}

Write-Host ""
Write-Host "🎉 Sync complete!" -ForegroundColor Green
