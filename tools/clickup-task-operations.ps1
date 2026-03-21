# ClickUp Task Operations
# Atomic operations for common ClickUp workflows
# Created: 2026-02-15

param(
    [ValidateSet("GetUnassigned", "StartWork", "SubmitForReview")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [ValidateSet("client-manager", "hazina", "art-revisionist")]
    [string]$Project,

    [Parameter(Mandatory=$false)]
    [string]$Status,

    [Parameter(Mandatory=$false)]
    [string]$TaskId,

    [Parameter(Mandatory=$false)]
    [string]$PrUrl,

    [Parameter(Mandatory=$false)]
    [string]$Comment
)

$ErrorActionPreference = "Stop"

# Exit gracefully if no action specified (prevents interactive prompting)
if (-not $Action) {
    Write-Warning "clickup-task-operations.ps1: No -Action specified. Use: GetUnassigned, StartWork, SubmitForReview"
    exit 0
}

# Load ClickUp config
$ConfigPath = "C:\scripts\_machine\clickup-config.json"
if (-not (Test-Path $ConfigPath)) {
    throw "ClickUp config not found at $ConfigPath"
}

$Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$ApiKey = $Config.api_key
$DefaultAssignee = $Config.default_assignee  # 74525428 (Martien de Jong)

# Project list IDs
$ListIds = @{
    "client-manager" = "901214097647"
    "hazina" = "901215559249"
    "art-revisionist" = "901211612245"
}

# Headers for API calls
$Headers = @{
    "Authorization" = $ApiKey
    "Content-Type" = "application/json"
}

function Invoke-ClickUpAPI {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null
    )

    $Uri = "https://api.clickup.com/api/v2$Endpoint"

    try {
        if ($Body) {
            $JsonBody = $Body | ConvertTo-Json -Depth 10 -Compress
            $Response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $JsonBody
        } else {
            $Response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
        }
        return $Response
    } catch {
        Write-Host "API call failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        throw
    }
}

function Get-UnassignedTasks {
    param(
        [string]$Project,
        [string]$Status
    )

    if (-not $ListIds.ContainsKey($Project)) {
        throw "Unknown project: $Project. Valid: client-manager, hazina, art-revisionist"
    }

    $ListId = $ListIds[$Project]

    Write-Host "Fetching tasks from $Project (list $ListId)..." -ForegroundColor Cyan

    # Build query parameters
    $QueryParams = @(
        "archived=false"
        "subtasks=false"
    )

    if ($Status) {
        $QueryParams += "statuses[]=$Status"
    }

    $Query = $QueryParams -join "&"
    $Endpoint = "/list/$ListId/task?$Query"

    $Response = Invoke-ClickUpAPI -Method "GET" -Endpoint $Endpoint

    # Filter for unassigned tasks
    $UnassignedTasks = $Response.tasks | Where-Object {
        $_.assignees.Count -eq 0
    }

    Write-Host "`nFound $($UnassignedTasks.Count) unassigned tasks:" -ForegroundColor Green

    foreach ($Task in $UnassignedTasks) {
        Write-Host "  [$($Task.status.status)] $($Task.name)" -ForegroundColor Yellow
        Write-Host "    ID: $($Task.id)" -ForegroundColor Gray
        Write-Host "    URL: $($Task.url)" -ForegroundColor Gray
    }

    return $UnassignedTasks
}

function Start-TaskWork {
    param(
        [string]$TaskId
    )

    Write-Host "`n=== Starting work on task $TaskId ===" -ForegroundColor Cyan

    # Step 1: Get current task details
    Write-Host "Fetching task details..." -ForegroundColor Yellow
    $Task = Invoke-ClickUpAPI -Method "GET" -Endpoint "/task/$TaskId"

    Write-Host "Task: $($Task.name)" -ForegroundColor White
    Write-Host "Current status: $($Task.status.status)" -ForegroundColor Gray

    # Step 2: Update status to 'busy'
    Write-Host "Moving to 'busy' status..." -ForegroundColor Yellow
    $StatusBody = @{
        status = "busy"
    }
    Invoke-ClickUpAPI -Method "PUT" -Endpoint "/task/$TaskId" -Body $StatusBody | Out-Null

    # Step 3: Assign to default assignee
    Write-Host "Assigning to user $DefaultAssignee..." -ForegroundColor Yellow
    $AssignBody = @{
        assignees = @{
            add = @($DefaultAssignee)
        }
    }
    Invoke-ClickUpAPI -Method "PUT" -Endpoint "/task/$TaskId" -Body $AssignBody | Out-Null

    # Step 4: Post comment
    Write-Host "Posting comment 'Jengo work started'..." -ForegroundColor Yellow
    $CommentBody = @{
        comment_text = "Jengo work started"
    }
    Invoke-ClickUpAPI -Method "POST" -Endpoint "/task/$TaskId/comment" -Body $CommentBody | Out-Null

    Write-Host "`n✓ Task $TaskId ready for work!" -ForegroundColor Green
    Write-Host "  Status: busy" -ForegroundColor Gray
    Write-Host "  Assigned: $DefaultAssignee" -ForegroundColor Gray
    Write-Host "  Comment: Jengo work started" -ForegroundColor Gray
}

function Submit-TaskForReview {
    param(
        [string]$TaskId,
        [string]$PrUrl
    )

    Write-Host "`n=== Submitting task $TaskId for review ===" -ForegroundColor Cyan

    # Step 1: Get current task details
    Write-Host "Fetching task details..." -ForegroundColor Yellow
    $Task = Invoke-ClickUpAPI -Method "GET" -Endpoint "/task/$TaskId"

    Write-Host "Task: $($Task.name)" -ForegroundColor White
    Write-Host "Current status: $($Task.status.status)" -ForegroundColor Gray

    # Step 2: Update status to 'review'
    Write-Host "Moving to 'review' status..." -ForegroundColor Yellow
    $StatusBody = @{
        status = "review"
    }
    Invoke-ClickUpAPI -Method "PUT" -Endpoint "/task/$TaskId" -Body $StatusBody | Out-Null

    # Step 3: Remove all assignees
    Write-Host "Removing assignees..." -ForegroundColor Yellow
    $CurrentAssignees = $Task.assignees | ForEach-Object { $_.id }
    if ($CurrentAssignees.Count -gt 0) {
        $UnassignBody = @{
            assignees = @{
                rem = @($CurrentAssignees)
            }
        }
        Invoke-ClickUpAPI -Method "PUT" -Endpoint "/task/$TaskId" -Body $UnassignBody | Out-Null
    }

    # Step 4: Post comment with PR link
    $CommentText = if ($PrUrl) {
        "Taak ready voor review`nPR: $PrUrl"
    } else {
        "Taak ready voor review"
    }

    Write-Host "Posting review comment..." -ForegroundColor Yellow
    $CommentBody = @{
        comment_text = $CommentText
    }
    Invoke-ClickUpAPI -Method "POST" -Endpoint "/task/$TaskId/comment" -Body $CommentBody | Out-Null

    Write-Host "`n✓ Task $TaskId submitted for review!" -ForegroundColor Green
    Write-Host "  Status: review" -ForegroundColor Gray
    Write-Host "  Assigned: (none)" -ForegroundColor Gray
    Write-Host "  Comment: $CommentText" -ForegroundColor Gray
}

# Main execution
try {
    switch ($Action) {
        "GetUnassigned" {
            if (-not $Project) {
                throw "Project parameter required for GetUnassigned action"
            }
            Get-UnassignedTasks -Project $Project -Status $Status
        }

        "StartWork" {
            if (-not $TaskId) {
                throw "TaskId parameter required for StartWork action"
            }
            Start-TaskWork -TaskId $TaskId
        }

        "SubmitForReview" {
            if (-not $TaskId) {
                throw "TaskId parameter required for SubmitForReview action"
            }
            Submit-TaskForReview -TaskId $TaskId -PrUrl $PrUrl
        }
    }
} catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
