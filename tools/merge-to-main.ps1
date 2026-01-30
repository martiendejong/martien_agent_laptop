#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Safe two-step merge to main/master: main→develop, then develop→main
.DESCRIPTION
    Merges the main branch into develop first (resolving conflicts there),
    then merges develop into main. This keeps main clean and conflict-free.
.PARAMETER RepoPath
    Path to repository (defaults to current directory)
.PARAMETER DryRun
    Show what would be done without making changes
.PARAMETER AutoPush
    Automatically push after successful merge
.EXAMPLE
    merge-to-main.ps1
    merge-to-main.ps1 -RepoPath C:\Projects\client-manager -AutoPush
#>

param(
    [string]$RepoPath = ".",
    [switch]$DryRun,
    [switch]$AutoPush
)

$ErrorActionPreference = "Stop"

# Color output
function Write-Step { param($msg) Write-Host "🔄 $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Fail { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Blue }

# Navigate to repo
Push-Location $RepoPath
try {
    # Verify it's a git repo
    if (-not (Test-Path ".git")) {
        Write-Fail "Not a git repository: $RepoPath"
        exit 1
    }

    $repoName = Split-Path -Leaf (Get-Location)
    Write-Info "Repository: $repoName"
    Write-Info "Path: $(Get-Location)"

    # Detect main branch (main or master)
    Write-Step "Detecting main branch..."
    $mainBranch = $null

    $branches = git branch -a 2>$null
    if ($branches -match '\bmain\b') {
        $mainBranch = "main"
    } elseif ($branches -match '\bmaster\b') {
        $mainBranch = "master"
    } else {
        Write-Fail "Could not detect main/master branch"
        exit 1
    }

    Write-Success "Main branch: $mainBranch"

    # Check for uncommitted changes
    Write-Step "Checking for uncommitted changes..."
    $status = git status --porcelain 2>$null
    if ($status) {
        Write-Fail "Uncommitted changes detected. Commit or stash first:"
        git status --short
        exit 1
    }
    Write-Success "Working tree clean"

    # Fetch latest
    Write-Step "Fetching latest from remote..."
    if (-not $DryRun) {
        git fetch origin 2>&1 | Out-Null
    }
    Write-Success "Fetched latest"

    # Get current branch
    $currentBranch = git branch --show-current 2>$null

    # STEP 1: Merge main into develop
    Write-Step "STEP 1/2: Merging $mainBranch into develop..."

    if ($currentBranch -ne "develop") {
        Write-Info "Switching to develop..."
        if (-not $DryRun) {
            git checkout develop 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Fail "Failed to checkout develop"
                exit 1
            }
        }
    }

    if ($DryRun) {
        Write-Info "[DRY RUN] Would merge $mainBranch into develop"
    } else {
        $mergeOutput = git merge $mainBranch 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Merge conflict detected when merging $mainBranch into develop"
            Write-Warn "Please resolve conflicts manually:"
            Write-Host ""
            Write-Host "  1. Resolve conflicts in the files"
            Write-Host "  2. git add <resolved-files>"
            Write-Host "  3. git commit"
            Write-Host "  4. Run this script again"
            Write-Host ""
            git status
            exit 1
        }
    }
    Write-Success "Merged $mainBranch into develop"

    # STEP 2: Merge develop into main
    Write-Step "STEP 2/2: Merging develop into $mainBranch..."

    if (-not $DryRun) {
        git checkout $mainBranch 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Failed to checkout $mainBranch"
            exit 1
        }
    }

    if ($DryRun) {
        Write-Info "[DRY RUN] Would merge develop into $mainBranch"
    } else {
        $mergeOutput = git merge develop 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Merge failed when merging develop into $mainBranch"
            Write-Fail "This should not happen if step 1 succeeded"
            git status
            exit 1
        }
    }
    Write-Success "Merged develop into $mainBranch"

    # Push if requested
    if ($AutoPush -and -not $DryRun) {
        Write-Step "Pushing changes to remote..."

        # Push develop
        git checkout develop 2>&1 | Out-Null
        git push origin develop 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "Failed to push develop"
        } else {
            Write-Success "Pushed develop"
        }

        # Push main
        git checkout $mainBranch 2>&1 | Out-Null
        git push origin $mainBranch 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "Failed to push $mainBranch"
        } else {
            Write-Success "Pushed $mainBranch"
        }
    }

    # Return to original branch
    if ($currentBranch -and $currentBranch -ne $mainBranch) {
        if (-not $DryRun) {
            git checkout $currentBranch 2>&1 | Out-Null
            Write-Info "Returned to branch: $currentBranch"
        }
    }

    Write-Host ""
    Write-Success "═══════════════════════════════════════════"
    Write-Success "Merge to $mainBranch completed successfully!"
    Write-Success "═══════════════════════════════════════════"
    Write-Host ""

    if (-not $AutoPush) {
        Write-Info "💡 Use -AutoPush to automatically push changes"
    }

} finally {
    Pop-Location
}
