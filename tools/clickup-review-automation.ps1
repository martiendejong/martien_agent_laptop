<#
.SYNOPSIS
    ClickUp Code Review Automation

.DESCRIPTION
    Reviews ClickUp tasks in "review" status by analyzing linked PRs

.PARAMETER Project
    Project name (art-revisionist, client-manager, hazina)

.EXAMPLE
    .\clickup-review-automation.ps1 -Project art-revisionist
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("art-revisionist", "client-manager", "hazina", "")]
    [string]$Project = "art-revisionist"
)

$ErrorActionPreference = "Stop"

# Load config
$configPath = "C:\scripts\_machine\clickup-config.json"
$config = Get-Content $configPath | ConvertFrom-Json
$projectConfig = $config.projects.$Project

if (-not $projectConfig) {
    Write-Error "Project '$Project' not found in config"
    exit 1
}

Write-Host "🔍 ClickUp Code Reviewer" -ForegroundColor Cyan
Write-Host "Project: $Project" -ForegroundColor White
Write-Host "List ID: $($projectConfig.list_id)" -ForegroundColor Gray
Write-Host "`n" + ("="*60) + "`n"

# Get tasks in review
$reviewTasks = & "C:\scripts\tools\clickup-sync.ps1" -Action list -Project $Project 2>&1 |
    Out-String |
    Select-String -Pattern "\[review\]" -Context 0,20

if (-not $reviewTasks) {
    Write-Host "✅ No tasks in review status" -ForegroundColor Green
    exit 0
}

# Parse review tasks
$taskLines = $reviewTasks.ToString() -split "`n" | Where-Object { $_ -match "^(\w{9})\s+(.+?)\s+review\s+" }
$reviewTaskIds = @()

foreach ($line in $taskLines) {
    if ($line -match "^(\w{9})\s+(.+?)\s+review\s+") {
        $reviewTaskIds += $matches[1]
    }
}

Write-Host "Found $($reviewTaskIds.Count) task(s) in review status`n" -ForegroundColor Yellow

# Review each task
foreach ($taskId in $reviewTaskIds) {
    Write-Host "`n" + ("="*60)
    Write-Host "Reviewing Task: $taskId" -ForegroundColor Cyan
    Write-Host ("="*60) + "`n"

    # Get task details
    $taskDetails = & "C:\scripts\tools\clickup-sync.ps1" -Action show -TaskId $taskId 2>&1 | Out-String

    Write-Host $taskDetails

    # Extract task name
    $taskName = ""
    if ($taskDetails -match "Name:\s+(.+)") {
        $taskName = $matches[1].Trim()
    }

    # Look for PR in description
    $prNumber = $null
    if ($taskDetails -match "#(\d+)") {
        $prNumber = $matches[1]
        Write-Host "Found PR reference: #$prNumber" -ForegroundColor Green
    }

    # If no PR in description, search GitHub
    if (-not $prNumber) {
        Write-Host "Searching GitHub for PR mentioning task $taskId..." -ForegroundColor Yellow

        $repoPath = switch ($Project) {
            "art-revisionist" { "C:\Projects\artrevisionist" }
            "client-manager" { "C:\Projects\client-manager" }
            "hazina" { "C:\Projects\hazina" }
        }

        if (Test-Path $repoPath) {
            Push-Location $repoPath
            try {
                $searchResult = gh pr list --state all --limit 50 --json number,body,title --search $taskId 2>$null
                if ($searchResult) {
                    $prs = $searchResult | ConvertFrom-Json
                    if ($prs.Count -gt 0) {
                        $prNumber = $prs[0].number
                        Write-Host "Found PR #$prNumber via GitHub search" -ForegroundColor Green
                    }
                }
            }
            catch {
                Write-Host "GitHub search failed: $_" -ForegroundColor Red
            }
            finally {
                Pop-Location
            }
        }
    }

    # Generate review
    $review = @"
📝 CODE REVIEW (Automated by Claude Code Agent)

"@

    if ($prNumber) {
        # Fetch PR details
        Push-Location $repoPath
        try {
            $prJson = gh pr view $prNumber --json number,title,state,files,commits,body 2>$null | ConvertFrom-Json

            $review += @"
## PR Analysis
- **PR #**: $($prJson.number)
- **Title**: $($prJson.title)
- **Status**: $($prJson.state)
- **Files Changed**: $($prJson.files.Count)
- **Commits**: $($prJson.commits.Count)

## Quick Review
Automated review completed. PR found and analyzed.

Files changed:
$($prJson.files | ForEach-Object { "- $($_.path)" } | Out-String)

## Verdict
ℹ️ HUMAN REVIEW RECOMMENDED
Automated analysis complete. Please review code changes manually for:
- Functionality correctness
- Code quality and patterns
- Test coverage
- Documentation completeness

---
Review conducted by Claude Code Agent
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm")
Task: $taskId
"@
        }
        catch {
            $review += @"
❌ ERROR: Could not fetch PR details
Error: $_

---
Review conducted by Claude Code Agent
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm")
"@
        }
        finally {
            Pop-Location
        }
    }
    else {
        # No PR found
        $review += @"
## Status
⚠️ Task is in REVIEW status but no linked PR was found.

## Possible Reasons
1. PR not yet created
2. PR link not added to task description
3. Task waiting for requirements review (not code review)
4. PR in different repository

## Recommendations
- If code is complete: Create PR and link it to task (add #$taskId to PR description)
- If waiting for requirements: Move to "planned" or "blocked"
- If PR exists: Add link to task description

## Next Steps
Please clarify the review status:
- Is code ready for review? → Create PR
- Is this requirements review? → Update status
- Is PR elsewhere? → Link it

---
Review conducted by Claude Code Agent
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm")
Task: $taskId
"@
    }

    # Post review comment
    Write-Host "`nPosting review comment..." -ForegroundColor Cyan
    & "C:\scripts\tools\clickup-sync.ps1" -Action comment -TaskId $taskId -Comment $review

    Write-Host "✅ Review posted to task $taskId" -ForegroundColor Green
}

Write-Host "`n" + ("="*60)
Write-Host "✅ Review complete for all tasks in review status" -ForegroundColor Green
Write-Host ("="*60) + "`n"
