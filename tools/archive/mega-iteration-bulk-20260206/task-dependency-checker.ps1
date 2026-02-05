<#
.SYNOPSIS
Automatic task dependency verification - Checks if dependency PRs are merged

.DESCRIPTION
Parses task description for dependency references (e.g., "Deps: Phase 4", "Dependencies: PR #123")
and automatically verifies if those dependencies are merged. Prevents wasted work on blocked tasks.

.PARAMETER TaskId
ClickUp task ID

.PARAMETER TaskDescription
Full task description text (including dependency mentions)

.PARAMETER Repo
Repository to check (default: martiendejong/client-manager)

.EXAMPLE
.\task-dependency-checker.ps1 -TaskId "869bzf5qc" -TaskDescription "Test Phase 5. Deps: Phase 4, Phase 5."

.OUTPUTS
JSON object with:
- hasDependencies: boolean
- dependencies: array of detected dependencies
- allMerged: boolean (true if all deps are merged)
- blockers: array of unmerged dependencies
- recommendation: "proceed" | "block"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,

    [Parameter(Mandatory=$true)]
    [string]$TaskDescription,

    [Parameter(Mandatory=$false)]
    [string]$Repo = "martiendejong/client-manager"
)

$ErrorActionPreference = "Stop"

function Parse-Dependencies {
    param([string]$text)

    $dependencies = @()

    # Pattern 1: "Deps: Phase 4, Phase 5"
    if ($text -match "Deps?:\s*(.+?)(?:\n|$)") {
        $depText = $matches[1]

        # Extract Phase numbers
        if ($depText -match "Phase\s+(\d+)") {
            $phaseNumbers = [regex]::Matches($depText, "Phase\s+(\d+)") | ForEach-Object { $_.Groups[1].Value }
            foreach ($num in $phaseNumbers) {
                $dependencies += @{
                    type = "phase"
                    value = "Phase $num"
                    searchTerm = "phase $num"
                }
            }
        }
    }

    # Pattern 2: "Dependencies: PR #123, PR #456"
    if ($text -match "Dependencies?:\s*(.+?)(?:\n|$)") {
        $depText = $matches[1]

        # Extract PR numbers
        $prNumbers = [regex]::Matches($depText, "PR\s*#?(\d+)") | ForEach-Object { $_.Groups[1].Value }
        foreach ($num in $prNumbers) {
            $dependencies += @{
                type = "pr"
                value = "PR #$num"
                prNumber = $num
            }
        }
    }

    # Pattern 3: "Depends on #123" (ClickUp task)
    if ($text -match "Depends?\s+on\s+#?(\w+)") {
        $taskId = $matches[1]
        $dependencies += @{
            type = "task"
            value = "Task #$taskId"
            taskId = $taskId
        }
    }

    return $dependencies
}

function Check-PhaseDependency {
    param([string]$searchTerm, [string]$repo)

    try {
        # Search for PRs matching the phase
        $prs = gh pr list --repo $repo --search $searchTerm --state all --limit 10 --json number,title,state,mergedAt 2>$null | ConvertFrom-Json

        if (-not $prs -or $prs.Count -eq 0) {
            return @{
                found = $false
                merged = $false
                prs = @()
            }
        }

        # Check if any matching PRs are merged
        $mergedPRs = $prs | Where-Object { $_.state -eq "MERGED" }
        $openPRs = $prs | Where-Object { $_.state -eq "OPEN" }

        return @{
            found = $true
            merged = ($mergedPRs.Count -gt 0)
            prs = $prs
            mergedCount = $mergedPRs.Count
            openCount = $openPRs.Count
        }
    } catch {
        return @{
            found = $false
            merged = $false
            error = $_.Exception.Message
        }
    }
}

function Check-PRDependency {
    param([int]$prNumber, [string]$repo)

    try {
        $pr = gh pr view $prNumber --repo $repo --json state,mergedAt,title 2>$null | ConvertFrom-Json

        return @{
            found = $true
            merged = ($pr.state -eq "MERGED")
            state = $pr.state
            title = $pr.title
            mergedAt = $pr.mergedAt
        }
    } catch {
        return @{
            found = $false
            merged = $false
            error = $_.Exception.Message
        }
    }
}

function Check-TaskDependency {
    param([string]$taskId)

    try {
        $task = & powershell.exe -File "C:/scripts/tools/clickup-sync.ps1" -Action show -TaskId $taskId 2>$null

        if ($task -match "Status:\s+(\w+)") {
            $status = $matches[1]
            return @{
                found = $true
                complete = ($status -eq "done" -or $status -eq "closed")
                status = $status
            }
        }

        return @{
            found = $false
            complete = $false
        }
    } catch {
        return @{
            found = $false
            complete = $false
            error = $_.Exception.Message
        }
    }
}

# Main execution
Write-Host "[DEPENDENCY CHECK] Task $TaskId" -ForegroundColor Cyan
Write-Host ""

# Parse dependencies
$dependencies = Parse-Dependencies -text $TaskDescription

if ($dependencies.Count -eq 0) {
    Write-Host "[OK] No dependencies found - safe to proceed" -ForegroundColor Green

    $result = @{
        taskId = $TaskId
        hasDependencies = $false
        dependencies = @()
        allMerged = $true
        blockers = @()
        recommendation = "proceed"
    }

    $result | ConvertTo-Json -Depth 5
    exit 0
}

Write-Host "[FOUND] $($dependencies.Count) dependencies:" -ForegroundColor Yellow
foreach ($dep in $dependencies) {
    Write-Host "   - $($dep.value)" -ForegroundColor Gray
}
Write-Host ""

# Check each dependency
$blockers = @()
$allMerged = $true

foreach ($dep in $dependencies) {
    Write-Host "[CHECK] $($dep.value)..." -ForegroundColor Cyan

    $checkResult = $null

    switch ($dep.type) {
        "phase" {
            $checkResult = Check-PhaseDependency -searchTerm $dep.searchTerm -repo $Repo

            if ($checkResult.found) {
                if ($checkResult.merged) {
                    Write-Host "   [OK] MERGED ($($checkResult.mergedCount) PRs)" -ForegroundColor Green
                } else {
                    Write-Host "   [BLOCKED] NOT MERGED ($($checkResult.openCount) PRs still open)" -ForegroundColor Red
                    $allMerged = $false
                    $blockers += @{
                        dependency = $dep.value
                        reason = "PRs not merged"
                        openPRs = $checkResult.openCount
                    }
                }
            } else {
                Write-Host "   [WARN] NOT FOUND (no matching PRs)" -ForegroundColor Yellow
                $allMerged = $false
                $blockers += @{
                    dependency = $dep.value
                    reason = "No PRs found"
                }
            }
        }

        "pr" {
            $checkResult = Check-PRDependency -prNumber $dep.prNumber -repo $Repo

            if ($checkResult.found) {
                if ($checkResult.merged) {
                    Write-Host "   [OK] MERGED: $($checkResult.title)" -ForegroundColor Green
                } else {
                    Write-Host "   [BLOCKED] $($checkResult.state): $($checkResult.title)" -ForegroundColor Red
                    $allMerged = $false
                    $blockers += @{
                        dependency = $dep.value
                        reason = "PR $($checkResult.state)"
                        title = $checkResult.title
                    }
                }
            } else {
                Write-Host "   [WARN] NOT FOUND" -ForegroundColor Yellow
                $allMerged = $false
                $blockers += @{
                    dependency = $dep.value
                    reason = "PR not found"
                }
            }
        }

        "task" {
            $checkResult = Check-TaskDependency -taskId $dep.taskId

            if ($checkResult.found) {
                if ($checkResult.complete) {
                    Write-Host "   [OK] COMPLETE ($($checkResult.status))" -ForegroundColor Green
                } else {
                    Write-Host "   [BLOCKED] NOT COMPLETE ($($checkResult.status))" -ForegroundColor Red
                    $allMerged = $false
                    $blockers += @{
                        dependency = $dep.value
                        reason = "Task status: $($checkResult.status)"
                    }
                }
            } else {
                Write-Host "   [WARN] NOT FOUND" -ForegroundColor Yellow
            }
        }
    }

    $dep | Add-Member -NotePropertyName "checkResult" -NotePropertyValue $checkResult -Force
}

Write-Host ""

# Final recommendation
$recommendation = if ($allMerged) { "proceed" } else { "block" }

if ($recommendation -eq "proceed") {
    Write-Host "[OK] ALL DEPENDENCIES SATISFIED - Safe to proceed" -ForegroundColor Green
} else {
    Write-Host "[BLOCKED] BLOCKERS DETECTED - Task should be blocked" -ForegroundColor Red
    Write-Host ""
    Write-Host "Blockers:" -ForegroundColor Red
    foreach ($blocker in $blockers) {
        Write-Host "   - $($blocker.dependency): $($blocker.reason)" -ForegroundColor Red
    }
}

# Output result
$result = @{
    taskId = $TaskId
    hasDependencies = $true
    dependencies = $dependencies
    allMerged = $allMerged
    blockers = $blockers
    recommendation = $recommendation
}

$result | ConvertTo-Json -Depth 5

# Exit code
exit $(if ($recommendation -eq "proceed") { 0 } else { 1 })
