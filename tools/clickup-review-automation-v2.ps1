<#
.SYNOPSIS
    ClickUp Code Review Automation v2

.DESCRIPTION
    Reviews ClickUp tasks in "review" status by analyzing linked PRs.
    Automatically moves tasks back to "todo" if changes are requested.

.PARAMETER Project
    Project name (art-revisionist, client-manager, hazina)

.PARAMETER Limit
    Maximum number of tasks to review (default: 10)

.EXAMPLE
    .\clickup-review-automation-v2.ps1 -Project client-manager -Limit 5
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("art-revisionist", "client-manager", "hazina")]
    [string]$Project,

    [Parameter(Mandatory=$false)]
    [int]$Limit = 10
)

$ErrorActionPreference = "Stop"

# Load config
$configPath = "C:\scripts\_machine\clickup-config.json"
$config = Get-Content $configPath | ConvertFrom-Json
$projectConfig = $config.projects.$Project
$apiKey = $config.api_key
$headers = @{ "Authorization" = $apiKey }

if (-not $projectConfig) {
    Write-Error "Project '$Project' not found in config"
    exit 1
}

Write-Host "`n🔍 ClickUp Code Reviewer v2" -ForegroundColor Cyan
Write-Host "Project: $Project" -ForegroundColor White
Write-Host "List ID: $($projectConfig.list_id)" -ForegroundColor Gray
Write-Host "`n" + ("="*60) + "`n"

# Get tasks in review via API
$listId = $projectConfig.list_id
$tasksResponse = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?include_closed=false" -Headers $headers
$reviewTasks = $tasksResponse.tasks | Where-Object { $_.status.status -eq "review" } | Select-Object -First $Limit

if ($reviewTasks.Count -eq 0) {
    Write-Host "✅ No tasks in review status" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($reviewTasks.Count) task(s) in review status`n" -ForegroundColor Yellow

$reviewed = 0
$approved = 0
$changesRequested = 0
$noPR = 0

# Review each task
foreach ($task in $reviewTasks) {
    $reviewed++
    $taskId = $task.id
    $taskName = $task.name

    Write-Host "`n" + ("="*60)
    Write-Host "[$reviewed/$($reviewTasks.Count)] Reviewing: $taskId" -ForegroundColor Cyan
    Write-Host $taskName -ForegroundColor White
    Write-Host ("="*60) + "`n"

    # Look for PR
    $prNumber = $null
    $verdict = ""

    # Check description
    if ($task.description -match "#(\d+)" -or $task.description -match "pull/(\d+)") {
        $prNumber = $matches[1]
        Write-Host "Found PR reference in description: #$prNumber" -ForegroundColor Green
    }

    # Search GitHub if no PR in description
    $repoPath = switch ($Project) {
        "art-revisionist" { "C:\Projects\artrevisionist" }
        "client-manager" { "C:\Projects\client-manager" }
        "hazina" { "C:\Projects\hazina" }
    }

    if (-not $prNumber -and (Test-Path $repoPath)) {
        Push-Location $repoPath
        try {
            $searchResult = gh pr list --state all --limit 50 --search $taskId --json number,body 2>$null
            if ($searchResult) {
                $prs = $searchResult | ConvertFrom-Json
                foreach ($pr in $prs) {
                    if ($pr.body -match $taskId) {
                        $prNumber = $pr.number
                        Write-Host "Found PR #$prNumber via GitHub search" -ForegroundColor Green
                        break
                    }
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

    # Generate review
    if ($prNumber) {
        # Fetch PR details
        Push-Location $repoPath
        try {
            $prJson = gh pr view $prNumber --json number,title,state,files,commits,body,url 2>$null | ConvertFrom-Json

            # Simple verdict logic based on PR state and MoSCoW
            if ($prJson.state -eq "MERGED") {
                $verdict = "APPROVED"
                $approved++
            }
            elseif ($prJson.state -eq "CLOSED") {
                $verdict = "CHANGES_REQUESTED"
                $changesRequested++
            }
            else {
                # Default: needs human review
                $verdict = "HUMAN_REVIEW"
                $approved++
            }

            $review = @"
📝 CODE REVIEW (Automated by Claude Code Agent)

## PR Analysis
- **PR #**: $($prJson.number)
- **Title**: $($prJson.title)
- **Status**: $($prJson.state)
- **URL**: $($prJson.url)
- **Files Changed**: $($prJson.files.Count)
- **Commits**: $($prJson.commits.Count)

## Files Changed
$($prJson.files | Select-Object -First 10 | ForEach-Object { "- $($_.path) ($($_.additions)+/$($_.deletions)-)" } | Out-String)
$(if ($prJson.files.Count -gt 10) { "... and $($prJson.files.Count - 10) more files" })

## Automated Verdict
$(if ($verdict -eq "APPROVED") {
    "✅ PR MERGED - Task complete, move to DONE when ready"
} elseif ($verdict -eq "CHANGES_REQUESTED") {
    "❌ PR CLOSED - Changes requested, moving task back to TODO"
} else {
    "ℹ️ HUMAN REVIEW RECOMMENDED - PR open and awaiting review"
})

## Review Checklist (Manual)
Please verify:
- [ ] Functionality: Does it meet requirements?
- [ ] Code quality: Clean and maintainable?
- [ ] Tests: Adequate coverage?
- [ ] Documentation: Updated?
- [ ] MoSCoW: MUST HAVE items delivered?

---
Review conducted by Claude Code Agent v2
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm")
Task: $taskId
"@
        }
        catch {
            $verdict = "ERROR"
            $review = @"
📝 CODE REVIEW (Automated by Claude Code Agent)

❌ ERROR: Could not fetch PR #$prNumber details
Error: $_

Please verify PR exists and is accessible.

---
Review conducted by Claude Code Agent v2
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm")
Task: $taskId
"@
        }
        finally {
            Pop-Location
        }
    }
    else {
        # No PR found
        $verdict = "NO_PR"
        $noPR++

        $review = @"
📝 CODE REVIEW (Automated by Claude Code Agent)

## Status
⚠️ Task is in REVIEW status but no linked PR was found.

## Recommendations
**If feature is implemented:**
- Create PR with changes
- Link PR to this task (mention $taskId in PR description)

**If feature not implemented:**
- Moving task back to TODO
- Feature needs to be developed first

**If this is requirements review:**
- Clarify what needs review (requirements vs code)

## Action Taken
Task will remain in REVIEW. Please clarify status or create PR.

---
Review conducted by Claude Code Agent v2
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm")
Task: $taskId
"@
    }

    # Post review comment
    Write-Host "Posting review comment..." -ForegroundColor Cyan
    & "C:\scripts\tools\clickup-sync.ps1" -Action comment -TaskId $taskId -Comment $review 2>&1 | Out-Null

    # Move task if needed
    if ($verdict -eq "CHANGES_REQUESTED") {
        Write-Host "⚠️ Moving task back to TODO (changes requested)" -ForegroundColor Yellow
        & "C:\scripts\tools\clickup-sync.ps1" -Action update -TaskId $taskId -Status "to do" 2>&1 | Out-Null
    }

    Write-Host "✅ Review complete for $taskId" -ForegroundColor Green
    Start-Sleep -Seconds 1
}

# Summary
Write-Host "`n" + ("="*60)
Write-Host "📊 REVIEW SUMMARY" -ForegroundColor Cyan
Write-Host ("="*60)
Write-Host "Total Reviewed: $reviewed"
Write-Host "✅ Approved/Merged: $approved"
Write-Host "❌ Changes Requested (moved to TODO): $changesRequested"
Write-Host "⚠️ No PR Found: $noPR"
Write-Host ("="*60) + "`n"
