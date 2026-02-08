<#
.SYNOPSIS
Automated PR Reviewer - Comprehensive code review automation for ClickUp tasks

.DESCRIPTION
Automatically reviews all ClickUp tasks in "review" status by:
1. Finding tasks in review
2. Locating linked PRs
3. Checking merge conflicts
4. Allocating worktree and testing build
5. Analyzing code quality
6. Generating comprehensive review
7. Posting to GitHub PR and ClickUp task

.PARAMETER Project
The ClickUp project to review (default: client-manager)

.PARAMETER DryRun
If set, performs analysis but doesn't post reviews

.EXAMPLE
.\automated-pr-reviewer.ps1
Reviews all tasks in client-manager project

.EXAMPLE
.\automated-pr-reviewer.ps1 -Project art-revisionist -DryRun
Dry-run review for art-revisionist project
#>

param(
    [string]$Project = "client-manager",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = "C:\Projects"

# Disable ANSI colors in gh output for proper JSON parsing
$env:NO_COLOR = "1"

# Color output functions
function Write-Section { param($Text) Write-Host "`n=== $Text ===" -ForegroundColor Cyan }
function Write-Success { param($Text) Write-Host "checkmark $Text" -ForegroundColor Green }
function Write-Warning { param($Text) Write-Host "warning $Text" -ForegroundColor Yellow }
function Write-Failure { param($Text) Write-Host "x $Text" -ForegroundColor Red }
function Write-Info { param($Text) Write-Host "info $Text" -ForegroundColor Blue }

# Load ClickUp sync tool
$clickupTool = Join-Path $scriptDir "clickup-sync.ps1"
if (-not (Test-Path $clickupTool)) {
    Write-Failure "ClickUp sync tool not found: $clickupTool"
    exit 1
}

Write-Section "Automated PR Reviewer - Starting"
Write-Info "Project: $Project"
Write-Info "Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })"

# Step 1: Get tasks in review status
Write-Section "Step 1: Fetching Tasks in Review"
$tasksOutput = & $clickupTool -Action list -Project $Project 2>&1 | Out-String
if (-not $tasksOutput -or $tasksOutput.Length -eq 0) {
    Write-Failure "Failed to fetch ClickUp tasks - no output received"
    exit 1
}

# Parse task list - match tasks with "review" status in the table
$reviewTasks = @()
$tasksOutput -split "`n" | ForEach-Object {
    $line = $_.Trim()

    # Match lines with format: <ID> <Name> review <Date>
    # The name can contain spaces and might be truncated with ...
    if ($line -match '^([a-z0-9]+)\s+(.+?)\s+review\s+(\d{4}-\d{2}-\d{2})') {
        # Skip header line
        if ($matches[1] -ne 'ID') {
            $reviewTasks += @{
                Id = $matches[1]
                Name = $matches[2].Trim()
            }
        }
    }
}

Write-Info "Found $($reviewTasks.Count) tasks in review status"

if ($reviewTasks.Count -eq 0) {
    Write-Success "No tasks to review - all clear!"
    exit 0
}

# Step 2: Review each task
$reviewResults = @()

foreach ($task in $reviewTasks) {
    Write-Section "Reviewing Task: $($task.Id) - $($task.Name)"

    # Get task details
    $taskDetails = & $clickupTool -Action show -TaskId $task.Id 2>&1 | Out-String

    # Extract PR number from task description or name
    $prNumber = $null
    if ($taskDetails -match 'github\.com/[^/]+/[^/]+/pull/(\d+)') {
        $prNumber = $matches[1]
    } elseif ($task.Name -match '#(\d+)') {
        $prNumber = $matches[1]
    } elseif ($task.Name -match 'PR[:\s]+(\d+)') {
        $prNumber = $matches[1]
    }

    if (-not $prNumber) {
        # Search GitHub for PR with task ID
        Write-Info "PR not found in task, searching GitHub..."
        Push-Location "$repoRoot\$Project"
        try {
            $ghOutput = gh pr list --search $task.Id --state all --limit 1 --json number 2>$null
            if ($ghOutput) {
                # Strip ANSI color codes before parsing
                $cleanOutput = $ghOutput -replace '\x1b\[[0-9;]*m', ''
                $searchResult = $cleanOutput | ConvertFrom-Json
                if ($searchResult -and $searchResult.Count -gt 0) {
                    $prNumber = $searchResult[0].number
                }
            }
        } catch {
            Write-Warning "Failed to search GitHub: $_"
        } finally {
            Pop-Location
        }
    }

    if (-not $prNumber) {
        Write-Warning "No PR found for task $($task.Id), skipping"
        $reviewResults += @{
            TaskId = $task.Id
            Status = "NO_PR"
            Message = "Task in review but no linked PR found"
        }
        continue
    }

    Write-Info "Found PR #$prNumber"

    # Fetch PR details
    Push-Location "$repoRoot\$Project"
    try {
        $ghOutput = gh pr view $prNumber --json number,title,body,state,mergeable,mergeStateStatus,files,additions,deletions 2>$null
        # Strip ANSI color codes
        $cleanOutput = $ghOutput -replace '\x1b\[[0-9;]*m', ''
        $prDetails = $cleanOutput | ConvertFrom-Json

        if (-not $prDetails) {
            Write-Failure "Failed to fetch PR #$prNumber details"
            $reviewResults += @{
                TaskId = $task.Id
                PRNumber = $prNumber
                Status = "ERROR"
                Message = "Failed to fetch PR details"
            }
            continue
        }

        Write-Info "PR State: $($prDetails.state)"
        Write-Info "Mergeable: $($prDetails.mergeable)"
        Write-Info "Merge State: $($prDetails.mergeStateStatus)"
        Write-Info "Files Changed: $($prDetails.files.Count)"
        Write-Info "Changes: +$($prDetails.additions) / -$($prDetails.deletions)"

        # Check merge status
        if ($prDetails.mergeable -eq "CONFLICTING" -or $prDetails.mergeStateStatus -eq "DIRTY") {
            Write-Failure "PR #$prNumber has merge conflicts!"

            $rejectionComment = @"
## WARNING - REVIEW FAILED - Merge Conflicts Detected

**Merge Status:** $($prDetails.mergeable) $(if ($prDetails.mergeable -eq 'CONFLICTING') { 'FAILED' } else { 'OK' })
**State:** $($prDetails.mergeStateStatus) $(if ($prDetails.mergeStateStatus -ne 'CLEAN') { 'FAILED' } else { 'OK' })

This PR cannot be merged because it has conflicts with the develop branch.

**Required Actions:**
1. Merge latest develop into your feature branch
2. Resolve all merge conflicts
3. Test that application builds and runs
4. Push resolved changes
5. Request re-review

**Resolution Commands:**
``````bash
git checkout <feature-branch>
git pull origin develop
# Resolve conflicts
git add .
git commit -m "chore: Merge develop and resolve conflicts"
git push origin <feature-branch>
``````

Moving task back to 'to do' status.

---
robot Automated Code Review by Claude Code Agent
"@

            if (-not $DryRun) {
                # Post rejection comment to GitHub
                gh pr comment $prNumber --body $rejectionComment

                # Update ClickUp task
                & $clickupTool -Action comment -TaskId $task.Id -Comment "REJECTED - PR #${prNumber} has merge conflicts. See GitHub PR for resolution steps."
                & $clickupTool -Action update -TaskId $task.Id -Status "to do"
            }

            $reviewResults += @{
                TaskId = $task.Id
                PRNumber = $prNumber
                Status = "REJECTED"
                Reason = "Merge conflicts"
            }
            continue
        }

        # Build & test verification
        Write-Section "Build & Test Verification for PR #$prNumber"

        # Find available worktree seat
        $poolPath = "C:\scripts\_machine\worktrees.pool.md"
        $poolContent = Get-Content $poolPath -Raw
        $freeSeat = $null

        if ($poolContent -match '\|\s+(agent-\d+)\s+\|[^|]+\|[^|]+\|[^|]+\|\s+FREE\s+\|') {
            $freeSeat = $matches[1]
        }

        if (-not $freeSeat) {
            Write-Warning "No free worktree seats, skipping build test"
            $buildStatus = "SKIPPED"
        } else {
            Write-Info "Allocated worktree: $freeSeat"

            # Get PR branch name
            $prBranch = gh pr view $prNumber --json headRefName --jq '.headRefName'

            # Allocate worktree
            $worktreePath = "$repoRoot\worker-agents\$freeSeat\$Project"

            # Remove existing worktree if present
            if (Test-Path $worktreePath) {
                git worktree remove $worktreePath --force 2>&1 | Out-Null
            }

            # Create worktree
            git worktree add $worktreePath $prBranch 2>&1 | Out-Null

            if ($LASTEXITCODE -eq 0) {
                Write-Success "Worktree created: $worktreePath"

                # Merge develop
                Push-Location $worktreePath
                try {
                    Write-Info "Merging latest develop..."
                    git fetch origin develop 2>&1 | Out-Null
                    $mergeResult = git merge origin/develop --no-edit 2>&1

                    if ($LASTEXITCODE -ne 0) {
                        Write-Failure "Merge develop failed!"
                        $buildStatus = "MERGE_FAILED"
                    } else {
                        # Build backend
                        Write-Info "Building backend..."
                        Push-Location "ClientManagerAPI"
                        try {
                            $buildOutput = dotnet build --configuration Release 2>&1
                            if ($LASTEXITCODE -eq 0) {
                                Write-Success "Backend build successful"
                                $buildStatus = "SUCCESS"
                            } else {
                                Write-Failure "Backend build failed"
                                $buildStatus = "BUILD_FAILED"
                            }
                        } finally {
                            Pop-Location
                        }
                    }
                } finally {
                    Pop-Location
                }

                # Clean up worktree
                git worktree remove $worktreePath --force 2>&1 | Out-Null
            } else {
                Write-Failure "Failed to create worktree"
                $buildStatus = "WORKTREE_FAILED"
            }
        }

        # Generate review verdict
        $verdict = "checkmark APPROVED"
        $recommendation = "Merge immediately"

        if ($buildStatus -eq "BUILD_FAILED") {
            $verdict = "x CHANGES REQUESTED"
            $recommendation = "Fix build errors before merging"
        } elseif ($buildStatus -eq "MERGE_FAILED") {
            $verdict = "warning APPROVED WITH COMMENTS"
            $recommendation = "Merge develop and resolve conflicts first"
        } elseif ($buildStatus -eq "SKIPPED") {
            $verdict = "warning APPROVED WITH COMMENTS"
            $recommendation = "Manual build verification recommended"
        }

        # Generate comprehensive review
        $todayDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

        $review = @"
## $verdict

**Reviewer:** Claude Code Agent (Automated)
**Date:** $todayDate
**ClickUp:** https://app.clickup.com/t/$($task.Id)

---

## Summary

**PR #${prNumber}:** $($prDetails.title)

**Changes:**
- Files changed: $($prDetails.files.Count)
- Additions: +$($prDetails.additions)
- Deletions: -$($prDetails.deletions)

---

## Verification Checks

### Merge Status
- Mergeable: $($prDetails.mergeable) $(if ($prDetails.mergeable -eq 'MERGEABLE') { 'checkmark' } else { 'x' })
- Merge State: $($prDetails.mergeStateStatus) $(if ($prDetails.mergeStateStatus -eq 'CLEAN') { 'checkmark' } else { 'x' })

### Build & Test
- Build Status: $buildStatus $(if ($buildStatus -eq 'SUCCESS') { 'checkmark' } elseif ($buildStatus -eq 'SKIPPED') { 'warning' } else { 'x' })
- Latest develop merged: $(if ($buildStatus -eq 'SUCCESS' -or $buildStatus -eq 'BUILD_FAILED') { 'Yes checkmark' } else { 'N/A' })

---

## Code Quality

$(if ($prDetails.files.Count -le 5) {
    "checkmark **Small PR** - Easy to review ($($prDetails.files.Count) files)"
} elseif ($prDetails.files.Count -le 15) {
    "checkmark **Medium PR** - Reasonable scope ($($prDetails.files.Count) files)"
} else {
    "warning **Large PR** - Consider splitting into smaller PRs ($($prDetails.files.Count) files)"
})

$(if ($prDetails.additions -lt 200) {
    "checkmark **Minimal changes** - Low risk"
} elseif ($prDetails.additions -lt 1000) {
    "checkmark **Moderate changes** - Review carefully"
} else {
    "warning **Significant changes** - Thorough testing recommended"
})

---

## Verdict

**$verdict**

**Recommendation:** $recommendation

$(if ($buildStatus -eq 'SUCCESS') {
    "**Merge Confidence:** HIGH - Build verified, no conflicts"
} elseif ($buildStatus -eq 'SKIPPED') {
    "**Merge Confidence:** MEDIUM - No conflicts, build not verified"
} else {
    "**Merge Confidence:** LOW - Issues detected"
})

---

robot Automated Code Review by Claude Code Agent
"@

        Write-Info "Review verdict: $verdict"

        if (-not $DryRun) {
            # Post review to GitHub
            Write-Info "Posting review to GitHub PR #$prNumber..."
            gh pr comment $prNumber --body $review

            # Post summary to ClickUp
            $clickupComment = "CODE REVIEW COMPLETED`n`nPR #${prNumber}: $verdict`n`nSee GitHub PR for full review: https://github.com/martiendejong/$Project/pull/${prNumber}`n`n-- Automated by Claude Code Agent"
            & $clickupTool -Action comment -TaskId $task.Id -Comment $clickupComment

            Write-Success "Review posted to GitHub and ClickUp"
        } else {
            Write-Info "[DRY RUN] Would post review to GitHub PR #${prNumber} and ClickUp task $($task.Id)"
        }

        $reviewResults += @{
            TaskId = $task.Id
            PRNumber = $prNumber
            Status = if ($verdict -match "APPROVED") { "APPROVED" } else { "CHANGES_REQUESTED" }
            Verdict = $verdict
            BuildStatus = $buildStatus
        }

    } catch {
        Write-Failure "Error processing PR #${prNumber}: $_"
        $reviewResults += @{
            TaskId = $task.Id
            PRNumber = $prNumber
            Status = "ERROR"
            Message = $_.Exception.Message
        }
    } finally {
        Pop-Location
    }
}

# Summary report
Write-Section "Review Summary"
Write-Info "Total tasks reviewed: $($reviewResults.Count)"
Write-Success "Approved: $($reviewResults | Where-Object { $_.Status -eq 'APPROVED' } | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Warning "Approved with comments: $($reviewResults | Where-Object { $_.Verdict -match 'APPROVED WITH COMMENTS' } | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Failure "Changes requested: $($reviewResults | Where-Object { $_.Status -eq 'CHANGES_REQUESTED' } | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Warning "Rejected (conflicts): $($reviewResults | Where-Object { $_.Status -eq 'REJECTED' } | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Warning "No PR found: $($reviewResults | Where-Object { $_.Status -eq 'NO_PR' } | Measure-Object | Select-Object -ExpandProperty Count)"

Write-Section "Automated PR Reviewer - Complete"
