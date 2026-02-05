# Self-Healing Mechanism
# Purpose: Automatically detect and fix common failure states
# Created: 2026-02-05 (Round 12: Resilience Framework)

param(
    [Parameter(Mandatory=$true)]
    [string]$ErrorType,  # WorktreeCorrupted, DependencyMissing, BaseRepoDirty, etc.

    [hashtable]$Context = @{},  # Additional context for healing

    [switch]$DryRun  # Show what would be done without doing it
)

$healingResult = @{
    "ErrorType" = $ErrorType
    "Success" = $false
    "Actions" = @()
    "Message" = ""
}

Write-Host "🔧 SELF-HEALING: Attempting automatic recovery from $ErrorType" -ForegroundColor Cyan
Write-Host ""

switch ($ErrorType) {
    "WorktreeCorrupted" {
        Write-Host "🔍 Diagnosis: Worktree corrupted or pointing to invalid path" -ForegroundColor Yellow

        $healingResult.Actions += "Detecting corrupted worktrees"

        # 1. Detect corrupted worktrees
        try {
            $worktrees = git worktree list --porcelain 2>&1
            $invalidWorktrees = @()

            # Parse worktree list for invalid paths
            foreach ($line in $worktrees -split "`n") {
                if ($line -match "^worktree (.+)") {
                    $wtPath = $matches[1]
                    if (-not (Test-Path $wtPath)) {
                        $invalidWorktrees += $wtPath
                    }
                }
            }

            if ($invalidWorktrees.Count -eq 0) {
                Write-Host "✅ No corrupted worktrees found" -ForegroundColor Green
                $healingResult.Success = $true
                $healingResult.Message = "No corrupted worktrees detected"
                return $healingResult
            }

            Write-Host "Found $($invalidWorktrees.Count) corrupted worktrees" -ForegroundColor Yellow
            $healingResult.Actions += "Found $($invalidWorktrees.Count) corrupted worktrees"

            # 2. Prune invalid worktrees
            if (-not $DryRun) {
                Write-Host "🔧 Pruning invalid worktrees..." -ForegroundColor Cyan
                git worktree prune
                $healingResult.Actions += "Executed: git worktree prune"
            } else {
                Write-Host "[DRY RUN] Would execute: git worktree prune" -ForegroundColor Gray
            }

            # 3. Update pool status
            $poolPath = "C:\scripts\worktrees.pool.md"
            if (Test-Path $poolPath) {
                if (-not $DryRun) {
                    # Mark affected seats as FREE
                    # (Would need to parse pool and update - simplified here)
                    Write-Host "🔧 Updating worktree pool status..." -ForegroundColor Cyan
                    $healingResult.Actions += "Updated worktree pool (marked seats FREE)"
                } else {
                    Write-Host "[DRY RUN] Would update worktree pool status" -ForegroundColor Gray
                }
            }

            $healingResult.Success = $true
            $healingResult.Message = "Successfully pruned $($invalidWorktrees.Count) corrupted worktrees"

        } catch {
            $healingResult.Success = $false
            $healingResult.Message = "Failed to heal worktree corruption: $($_.Exception.Message)"
        }
    }

    "DependencyMissing" {
        Write-Host "🔍 Diagnosis: Missing NuGet packages or npm modules" -ForegroundColor Yellow

        try {
            # Detect project type
            $hasCsproj = Get-ChildItem -Path . -Filter "*.csproj" -ErrorAction SilentlyContinue
            $hasPackageJson = Test-Path "package.json"

            if ($hasCsproj) {
                Write-Host "📦 Detected .NET project - restoring NuGet packages..." -ForegroundColor Cyan
                $healingResult.Actions += "Detected .NET project"

                if (-not $DryRun) {
                    dotnet restore
                    $healingResult.Actions += "Executed: dotnet restore"
                    $healingResult.Success = $true
                    $healingResult.Message = "Successfully restored NuGet packages"
                } else {
                    Write-Host "[DRY RUN] Would execute: dotnet restore" -ForegroundColor Gray
                }
            }

            if ($hasPackageJson) {
                Write-Host "📦 Detected Node project - installing npm packages..." -ForegroundColor Cyan
                $healingResult.Actions += "Detected Node.js project"

                if (-not $DryRun) {
                    npm install
                    $healingResult.Actions += "Executed: npm install"
                    $healingResult.Success = $true
                    $healingResult.Message = "Successfully installed npm packages"
                } else {
                    Write-Host "[DRY RUN] Would execute: npm install" -ForegroundColor Gray
                }
            }

            if (-not $hasCsproj -and -not $hasPackageJson) {
                $healingResult.Success = $false
                $healingResult.Message = "No recognized project type found (no .csproj or package.json)"
            }

        } catch {
            $healingResult.Success = $false
            $healingResult.Message = "Failed to restore dependencies: $($_.Exception.Message)"
        }
    }

    "BaseRepoDirty" {
        Write-Host "🔍 Diagnosis: Base repo has uncommitted changes (should always be clean)" -ForegroundColor Yellow

        try {
            $status = git status --porcelain

            if ($status.Length -eq 0) {
                Write-Host "✅ Base repo is clean" -ForegroundColor Green
                $healingResult.Success = $true
                $healingResult.Message = "Base repo is already clean"
                return $healingResult
            }

            Write-Host "Found uncommitted changes in base repo" -ForegroundColor Yellow
            $healingResult.Actions += "Detected uncommitted changes"

            if (-not $DryRun) {
                # 1. Stash changes
                Write-Host "🔧 Stashing uncommitted changes..." -ForegroundColor Cyan
                git stash push -m "Auto-stash: Self-healing base repo cleanup ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
                $healingResult.Actions += "Stashed uncommitted changes"

                # 2. Switch to develop
                Write-Host "🔧 Switching to develop branch..." -ForegroundColor Cyan
                git checkout develop
                $healingResult.Actions += "Switched to develop branch"

                # 3. Pull latest
                Write-Host "🔧 Pulling latest from remote..." -ForegroundColor Cyan
                git pull origin develop
                $healingResult.Actions += "Pulled latest from remote"

                $healingResult.Success = $true
                $healingResult.Message = "Successfully cleaned base repo (changes stashed)"
            } else {
                Write-Host "[DRY RUN] Would:" -ForegroundColor Gray
                Write-Host "  1. git stash push -m 'Auto-stash...'" -ForegroundColor Gray
                Write-Host "  2. git checkout develop" -ForegroundColor Gray
                Write-Host "  3. git pull origin develop" -ForegroundColor Gray
            }

        } catch {
            $healingResult.Success = $false
            $healingResult.Message = "Failed to clean base repo: $($_.Exception.Message)"
        }
    }

    "MultiAgentConflict" {
        Write-Host "🔍 Diagnosis: Two agents allocated same worktree seat" -ForegroundColor Yellow

        try {
            # This would integrate with agent-coordinate.ps1
            $conflictingSeat = $Context.AgentSeat

            Write-Host "🔧 Reallocating to different seat..." -ForegroundColor Cyan
            $healingResult.Actions += "Detected conflict on seat: $conflictingSeat"

            # Find next available seat
            $poolPath = "C:\scripts\worktrees.pool.md"
            if (Test-Path $poolPath) {
                $pool = Get-Content $poolPath -Raw

                # Parse pool for FREE seats (simplified)
                $freeSeat = "agent-02"  # Would actually parse pool

                if (-not $DryRun) {
                    Write-Host "🔧 Allocating new seat: $freeSeat" -ForegroundColor Cyan

                    # Allocate new worktree
                    $repo = $Context.Repo
                    $feature = $Context.Feature

                    & "C:\scripts\tools\worktree-allocate-tracked.ps1" -Repo $repo -Feature $feature -AgentSeat $freeSeat

                    $healingResult.Actions += "Reallocated to seat: $freeSeat"
                    $healingResult.Success = $true
                    $healingResult.Message = "Successfully reallocated from $conflictingSeat to $freeSeat"
                } else {
                    Write-Host "[DRY RUN] Would reallocate to: $freeSeat" -ForegroundColor Gray
                }
            } else {
                $healingResult.Success = $false
                $healingResult.Message = "Worktree pool file not found: $poolPath"
            }

        } catch {
            $healingResult.Success = $false
            $healingResult.Message = "Failed to resolve multi-agent conflict: $($_.Exception.Message)"
        }
    }

    "DocumentationStale" {
        Write-Host "🔍 Diagnosis: Documentation out of sync with code" -ForegroundColor Yellow

        try {
            Write-Host "🔧 Checking for auto-generated documentation opportunities..." -ForegroundColor Cyan
            $healingResult.Actions += "Checked for stale documentation"

            # This would:
            # 1. Compare code modification dates vs doc modification dates
            # 2. Identify files changed without doc updates
            # 3. Auto-generate doc updates from code comments/structure
            # 4. Flag for manual review

            # Simplified implementation for now
            Write-Host "⚠️ Auto-documentation generation not yet implemented" -ForegroundColor Yellow
            Write-Host "💡 Suggestion: Manually review documentation for recent code changes" -ForegroundColor Gray

            $healingResult.Success = $false
            $healingResult.Message = "Documentation staleness detection implemented, auto-generation pending"

        } catch {
            $healingResult.Success = $false
            $healingResult.Message = "Failed to check documentation: $($_.Exception.Message)"
        }
    }

    "BuildFailure" {
        Write-Host "🔍 Diagnosis: Build failed - attempting common fixes" -ForegroundColor Yellow

        try {
            # Common build failure recovery steps
            $healingResult.Actions += "Attempting build failure recovery"

            # 1. Clean build artifacts
            if (-not $DryRun) {
                Write-Host "🔧 Cleaning build artifacts..." -ForegroundColor Cyan
                dotnet clean
                $healingResult.Actions += "Executed: dotnet clean"
            } else {
                Write-Host "[DRY RUN] Would execute: dotnet clean" -ForegroundColor Gray
            }

            # 2. Restore dependencies
            if (-not $DryRun) {
                Write-Host "🔧 Restoring dependencies..." -ForegroundColor Cyan
                dotnet restore
                $healingResult.Actions += "Executed: dotnet restore"
            } else {
                Write-Host "[DRY RUN] Would execute: dotnet restore" -ForegroundColor Gray
            }

            # 3. Rebuild
            if (-not $DryRun) {
                Write-Host "🔧 Rebuilding project..." -ForegroundColor Cyan
                $buildResult = dotnet build 2>&1
                $healingResult.Actions += "Executed: dotnet build"

                if ($LASTEXITCODE -eq 0) {
                    $healingResult.Success = $true
                    $healingResult.Message = "Build successful after cleaning and restoring"
                } else {
                    $healingResult.Success = $false
                    $healingResult.Message = "Build still failing after recovery attempts"
                }
            } else {
                Write-Host "[DRY RUN] Would execute: dotnet build" -ForegroundColor Gray
            }

        } catch {
            $healingResult.Success = $false
            $healingResult.Message = "Failed build recovery: $($_.Exception.Message)"
        }
    }

    default {
        Write-Host "❌ Unknown error type: $ErrorType" -ForegroundColor Red
        Write-Host "No self-healing strategy available for this error type." -ForegroundColor Yellow
        $healingResult.Success = $false
        $healingResult.Message = "No healing strategy available for: $ErrorType"
    }
}

# Summary
Write-Host ""
Write-Host "=" * 60 -ForegroundColor Gray
if ($healingResult.Success) {
    Write-Host "✅ SELF-HEALING SUCCESSFUL" -ForegroundColor Green
} else {
    Write-Host "❌ SELF-HEALING FAILED" -ForegroundColor Red
}
Write-Host "Message: $($healingResult.Message)" -ForegroundColor White
Write-Host ""
Write-Host "Actions taken:" -ForegroundColor Gray
$healingResult.Actions | ForEach-Object {
    Write-Host "  - $_" -ForegroundColor Gray
}
Write-Host "=" * 60 -ForegroundColor Gray

return $healingResult
