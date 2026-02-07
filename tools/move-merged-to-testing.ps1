<#
.SYNOPSIS
    Move merged PRs from REVIEW to TESTING for acceptance testing

.DESCRIPTION
    Scans ClickUp tasks in "review" status, checks if linked PRs are merged,
    and moves them to "testing" status for human acceptance testing.

.PARAMETER Project
    Project name (client-manager, art-revisionist, hazina)

.PARAMETER Limit
    Maximum number of tasks to process (default: 50)

.EXAMPLE
    .\move-merged-to-testing.ps1 -Project client-manager
    .\move-merged-to-testing.ps1 -Project art-revisionist -Limit 20

.NOTES
    Workflow:
    - REVIEW → TESTING (PR merged, ready for acceptance test)
    - TESTING → DONE (user manually marks after testing)
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("client-manager", "art-revisionist", "hazina")]
    [string]$Project = "client-manager",

    [Parameter(Mandatory=$false)]
    [int]$Limit = 50
)

$ErrorActionPreference = "Stop"

# Load ClickUp config
$configPath = "C:\scripts\_machine\clickup-config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "Config not found: $configPath"
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$projectConfig = $config.projects.$Project

if (-not $projectConfig) {
    Write-Error "Project '$Project' not found in config"
    exit 1
}

$apiKey = $config.api_key
$headers = @{ "Authorization" = $apiKey }
$listId = $projectConfig.list_id

Write-Host ""
Write-Host "🔍 Moving merged PRs to TESTING status..." -ForegroundColor Cyan
Write-Host "Project: $Project" -ForegroundColor White
Write-Host "List ID: $listId" -ForegroundColor Gray
Write-Host "============================================================"
Write-Host ""

# Get all tasks in review
$tasksResponse = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?include_closed=false" -Headers $headers
$reviewTasks = $tasksResponse.tasks | Where-Object { $_.status.status -eq "review" } | Select-Object -First $Limit

Write-Host "Found $($reviewTasks.Count) tasks in review status" -ForegroundColor Yellow
Write-Host ""

$movedCount = 0
$skippedCount = 0
$repoPath = $projectConfig.local_path

foreach ($task in $reviewTasks) {
    $taskId = $task.id
    $taskName = $task.name
    $index = $movedCount + $skippedCount + 1

    Write-Host ""
    Write-Host "[$index/$($reviewTasks.Count)] $taskId" -ForegroundColor Cyan
    Write-Host $taskName -ForegroundColor White
    Write-Host "------------------------------------------------------------"

    # Look for PR number in description
    $prNumber = $null
    if ($task.description -match "#(\d+)" -or $task.description -match "pull/(\d+)") {
        $prNumber = $matches[1]
        Write-Host "  Found PR #$prNumber in description" -ForegroundColor Gray
    }

    # If no PR in description, search GitHub
    if (-not $prNumber -and $repoPath -and (Test-Path $repoPath)) {
        Push-Location $repoPath
        try {
            $searchResult = gh pr list --state all --limit 100 --search $taskId --json number,state,body 2>$null
            if ($searchResult) {
                $prs = $searchResult | ConvertFrom-Json
                foreach ($pr in $prs) {
                    if ($pr.body -match $taskId) {
                        $prNumber = $pr.number
                        Write-Host "  Found PR #$prNumber via GitHub search" -ForegroundColor Gray
                        break
                    }
                }
            }
        }
        catch {
            Write-Host "  GitHub search failed" -ForegroundColor Red
        }
        finally {
            Pop-Location
        }
    }

    # Check PR status
    if ($prNumber -and $repoPath -and (Test-Path $repoPath)) {
        Push-Location $repoPath
        try {
            $prJson = gh pr view $prNumber --json state,mergedAt,url 2>$null | ConvertFrom-Json

            if ($prJson.state -eq "MERGED") {
                Write-Host "  PR #$prNumber is MERGED" -ForegroundColor Green
                Write-Host "  Moving task to TESTING..." -ForegroundColor Yellow

                # Move to testing
                $comment = "🤖 AUTOMATED STATUS UPDATE

PR #$prNumber has been merged to develop.
URL: $($prJson.url)

Moving to TESTING for acceptance testing.
Please verify the feature works as expected before marking as DONE.

--- ClickHub Coding Agent"

                & 'C:\scripts\tools\clickup-sync.ps1' -Action comment -TaskId $taskId -Comment $comment 2>&1 | Out-Null
                & 'C:\scripts\tools\clickup-sync.ps1' -Action update -TaskId $taskId -Status 'testing' 2>&1 | Out-Null

                Write-Host "  ✅ Moved to TESTING" -ForegroundColor Green
                $movedCount++
            }
            elseif ($prJson.state -eq "OPEN") {
                Write-Host "  ⏳ PR #$prNumber is still OPEN" -ForegroundColor Yellow
                $skippedCount++
            }
            else {
                Write-Host "  ❌ PR #$prNumber is CLOSED (not merged)" -ForegroundColor Red
                $skippedCount++
            }
        }
        catch {
            Write-Host "  ❌ Failed to check PR" -ForegroundColor Red
            $skippedCount++
        }
        finally {
            Pop-Location
        }
    }
    else {
        Write-Host "  ⚠️ No PR found" -ForegroundColor Yellow
        $skippedCount++
    }

    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "============================================================"
Write-Host "📊 SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================"
Write-Host "Total reviewed: $($reviewTasks.Count)"
Write-Host "✅ Moved to TESTING: $movedCount" -ForegroundColor Green
Write-Host "⏭️ Skipped (open/closed/no PR): $skippedCount" -ForegroundColor Yellow
Write-Host "============================================================"
Write-Host ""

if ($movedCount -gt 0) {
    Write-Host "🧪 $movedCount task(s) ready for acceptance testing!" -ForegroundColor Green
    Write-Host "Please test these features and move to DONE when verified." -ForegroundColor White
    Write-Host ""
}
