# ClickUp Task Operations v2
# Enhanced atomic operations with DryRun, validation, rollback, and history tracking
# Created: 2026-02-15

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("GetUnassigned", "StartWork", "SubmitForReview", "GetHistory")]
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
    [string]$CustomComment,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [switch]$VerboseLogging,

    [Parameter(Mandatory=$false)]
    [switch]$JsonOutput,

    [Parameter(Mandatory=$false)]
    [int]$MaxRetries = 3
)

$ErrorActionPreference = "Stop"

# Config paths
$ConfigPath = "C:\scripts\_machine\clickup-config.json"
$HistoryPath = "C:\scripts\_machine\clickup-operations-history.jsonl"

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    throw "ClickUp config not found at $ConfigPath"
}

$Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$ApiKey = $Config.api_key
$DefaultAssignee = $Config.default_assignee

# Project configuration
$ProjectConfig = @{
    "client-manager" = @{
        ListId = "901214097647"
        WorkStatus = "busy"
        ReviewStatus = "review"
        TodoStatus = "todo"
    }
    "hazina" = @{
        ListId = "901215559249"
        WorkStatus = "busy"
        ReviewStatus = "review"
        TodoStatus = "todo"
    }
    "art-revisionist" = @{
        ListId = "901211612245"
        WorkStatus = "busy"
        ReviewStatus = "review"
        TodoStatus = "todo"
    }
}

$Headers = @{
    "Authorization" = $ApiKey
    "Content-Type" = "application/json"
}

# Logging functions
function Write-VerboseLog {
    param([string]$Message)
    if ($VerboseLogging) {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkGray
    }
}

function Write-HistoryLog {
    param(
        [string]$Action,
        [string]$TaskId,
        [string]$Status,
        [hashtable]$Details
    )

    if ($DryRun) { return }

    $LogEntry = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        action = $Action
        task_id = $TaskId
        status = $Status
        details = $Details
    } | ConvertTo-Json -Compress

    Add-Content -Path $HistoryPath -Value $LogEntry -Encoding UTF8
    Write-VerboseLog "Logged to history: $Action on $TaskId"
}

# API helper with retry logic
function Invoke-ClickUpAPIWithRetry {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null,
        [int]$RetryCount = 0
    )

    $Uri = "https://api.clickup.com/api/v2$Endpoint"
    Write-VerboseLog "API $Method $Uri (attempt $($RetryCount + 1)/$MaxRetries)"

    if ($DryRun) {
        Write-Host "[DRY-RUN] Would call: $Method $Uri" -ForegroundColor Magenta
        if ($Body) {
            Write-Host "[DRY-RUN] Body: $($Body | ConvertTo-Json -Compress)" -ForegroundColor Magenta
        }
        return @{ dry_run = $true }
    }

    try {
        if ($Body) {
            $JsonBody = $Body | ConvertTo-Json -Depth 10 -Compress
            $Response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $JsonBody
        } else {
            $Response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
        }
        Write-VerboseLog "API call succeeded"
        return $Response
    } catch {
        $ErrorMsg = $_.Exception.Message
        Write-VerboseLog "API call failed: $ErrorMsg"

        # Retry on transient errors
        if ($RetryCount -lt $MaxRetries -and $ErrorMsg -match "(timeout|connection|429)") {
            $WaitSeconds = [math]::Pow(2, $RetryCount)
            Write-Host "Retrying in $WaitSeconds seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds $WaitSeconds
            return Invoke-ClickUpAPIWithRetry -Method $Method -Endpoint $Endpoint -Body $Body -RetryCount ($RetryCount + 1)
        }

        # Non-retryable error
        Write-Host "API call failed: $ErrorMsg" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        throw
    }
}

# Validation
function Test-TaskIdFormat {
    param([string]$TaskId)

    if ($TaskId -notmatch '^\w{9,}$') {
        throw "Invalid TaskId format: $TaskId (expected 9+ alphanumeric characters)"
    }
}

function Test-TaskInExpectedState {
    param(
        [object]$Task,
        [string[]]$ExpectedStatuses
    )

    $CurrentStatus = $Task.status.status
    if ($ExpectedStatuses -notcontains $CurrentStatus) {
        throw "Task is in '$CurrentStatus' but expected one of: $($ExpectedStatuses -join ', ')"
    }
}

# Rollback tracking
$script:RollbackStack = @()

function Add-RollbackAction {
    param(
        [string]$Description,
        [scriptblock]$Action
    )

    $script:RollbackStack += @{
        Description = $Description
        Action = $Action
    }
    Write-VerboseLog "Rollback action added: $Description"
}

function Invoke-Rollback {
    Write-Host "`n[ROLLBACK] Undoing $($script:RollbackStack.Count) actions..." -ForegroundColor Red

    for ($i = $script:RollbackStack.Count - 1; $i -ge 0; $i--) {
        $RollbackAction = $script:RollbackStack[$i]
        Write-Host "  Undoing: $($RollbackAction.Description)" -ForegroundColor Yellow
        try {
            & $RollbackAction.Action
        } catch {
            Write-Host "  Failed to rollback: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    $script:RollbackStack = @()
}

# Core operations
function Get-UnassignedTasks {
    param(
        [string]$Project,
        [string]$Status
    )

    if (-not $ProjectConfig.ContainsKey($Project)) {
        throw "Unknown project: $Project. Valid: $($ProjectConfig.Keys -join ', ')"
    }

    $ProjConfig = $ProjectConfig[$Project]
    Write-Host "Fetching tasks from $Project..." -ForegroundColor Cyan

    $QueryParams = @(
        "archived=false"
        "subtasks=false"
    )

    if ($Status) {
        $QueryParams += "statuses[]=$Status"
    }

    $Query = $QueryParams -join "&"
    $Endpoint = "/list/$($ProjConfig.ListId)/task?$Query"

    $Response = Invoke-ClickUpAPIWithRetry -Method "GET" -Endpoint $Endpoint

    $UnassignedTasks = $Response.tasks | Where-Object {
        $_.assignees.Count -eq 0
    }

    if ($JsonOutput) {
        return $UnassignedTasks | ConvertTo-Json -Depth 5
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
        [string]$TaskId,
        [string]$CustomComment
    )

    Test-TaskIdFormat -TaskId $TaskId

    Write-Host "`n=== Starting work on task $TaskId ===" -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "[DRY-RUN MODE - No actual changes will be made]" -ForegroundColor Magenta
    }

    # Step 1: Get current task
    Write-Host "Fetching task details..." -ForegroundColor Yellow
    $Task = Invoke-ClickUpAPIWithRetry -Method "GET" -Endpoint "/task/$TaskId"

    if ($DryRun) {
        Write-Host "Moving to 'busy' status..." -ForegroundColor Yellow
        $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ status = "busy" }
        Write-Host "Assigning to user $DefaultAssignee..." -ForegroundColor Yellow
        $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ assignees = @{ add = @($DefaultAssignee) } }
        $CommentText = if ($CustomComment) { $CustomComment } else { "Jengo work started" }
        Write-Host "Posting comment '$CommentText'..." -ForegroundColor Yellow
        $null = Invoke-ClickUpAPIWithRetry -Method "POST" -Endpoint "/task/$TaskId/comment" -Body @{ comment_text = $CommentText }
        Write-Host "`n[DRY-RUN] Simulated StartWork completed successfully" -ForegroundColor Green
        return
    }

    Write-Host "Task: $($Task.name)" -ForegroundColor White
    Write-Host "Current status: $($Task.status.status)" -ForegroundColor Gray

    # Validate state
    $ExpectedStatuses = @("todo", "backlog", "needs refinement")
    try {
        Test-TaskInExpectedState -Task $Task -ExpectedStatuses $ExpectedStatuses
    } catch {
        Write-Host "WARNING: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Proceeding anyway..." -ForegroundColor Yellow
    }

    $OriginalStatus = $Task.status.status
    $OriginalAssignees = @($Task.assignees | ForEach-Object { $_.id })

    # Step 2: Update status to 'busy'
    Write-Host "Moving to 'busy' status..." -ForegroundColor Yellow
    $StatusBody = @{ status = "busy" }
    $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body $StatusBody

    if (-not $DryRun) {
        Add-RollbackAction -Description "Revert status to $OriginalStatus" -Action {
            $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ status = $OriginalStatus }
        }
    }

    # Step 3: Assign to default assignee
    Write-Host "Assigning to user $DefaultAssignee..." -ForegroundColor Yellow
    $AssignBody = @{
        assignees = @{
            add = @($DefaultAssignee)
        }
    }
    $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body $AssignBody

    if (-not $DryRun) {
        Add-RollbackAction -Description "Remove assignee $DefaultAssignee" -Action {
            $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{
                assignees = @{ rem = @($DefaultAssignee) }
            }
        }
    }

    # Step 4: Post comment
    $CommentText = if ($CustomComment) { $CustomComment } else { "Jengo work started" }
    Write-Host "Posting comment '$CommentText'..." -ForegroundColor Yellow
    $CommentBody = @{ comment_text = $CommentText }
    $null = Invoke-ClickUpAPIWithRetry -Method "POST" -Endpoint "/task/$TaskId/comment" -Body $CommentBody

    # Log to history
    Write-HistoryLog -Action "StartWork" -TaskId $TaskId -Status "success" -Details @{
        from_status = $OriginalStatus
        to_status = "busy"
        assignee = $DefaultAssignee
        comment = $CommentText
    }

    Write-Host "`n✓ Task $TaskId ready for work!" -ForegroundColor Green
    Write-Host "  Status: busy" -ForegroundColor Gray
    Write-Host "  Assigned: $DefaultAssignee" -ForegroundColor Gray
    Write-Host "  Comment: $CommentText" -ForegroundColor Gray

    if ($JsonOutput) {
        return @{
            task_id = $TaskId
            status = "busy"
            assignee = $DefaultAssignee
            comment = $CommentText
        } | ConvertTo-Json
    }
}

function Submit-TaskForReview {
    param(
        [string]$TaskId,
        [string]$PrUrl,
        [string]$CustomComment
    )

    Test-TaskIdFormat -TaskId $TaskId

    Write-Host "`n=== Submitting task $TaskId for review ===" -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "[DRY-RUN MODE - No actual changes will be made]" -ForegroundColor Magenta
    }

    # Step 1: Get current task
    Write-Host "Fetching task details..." -ForegroundColor Yellow
    $Task = Invoke-ClickUpAPIWithRetry -Method "GET" -Endpoint "/task/$TaskId"

    if ($DryRun) {
        Write-Host "Moving to 'review' status..." -ForegroundColor Yellow
        $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ status = "review" }
        Write-Host "Removing assignees..." -ForegroundColor Yellow
        $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ assignees = @{ rem = @() } }
        $CommentText = if ($CustomComment) { $CustomComment } elseif ($PrUrl) { "Taak ready voor review`nPR: $PrUrl" } else { "Taak ready voor review" }
        Write-Host "Posting review comment..." -ForegroundColor Yellow
        $null = Invoke-ClickUpAPIWithRetry -Method "POST" -Endpoint "/task/$TaskId/comment" -Body @{ comment_text = $CommentText }
        Write-Host "`n[DRY-RUN] Simulated SubmitForReview completed successfully" -ForegroundColor Green
        return
    }

    Write-Host "Task: $($Task.name)" -ForegroundColor White
    Write-Host "Current status: $($Task.status.status)" -ForegroundColor Gray

    # Validate state
    $ExpectedStatuses = @("busy", "in progress", "doing")
    try {
        Test-TaskInExpectedState -Task $Task -ExpectedStatuses $ExpectedStatuses
    } catch {
        Write-Host "WARNING: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Proceeding anyway..." -ForegroundColor Yellow
    }

    $OriginalStatus = $Task.status.status
    $OriginalAssignees = @($Task.assignees | ForEach-Object { $_.id })

    # Step 2: Update status to 'review'
    Write-Host "Moving to 'review' status..." -ForegroundColor Yellow
    $StatusBody = @{ status = "review" }
    $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body $StatusBody

    if (-not $DryRun) {
        Add-RollbackAction -Description "Revert status to $OriginalStatus" -Action {
            $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ status = $OriginalStatus }
        }
    }

    # Step 3: Remove all assignees
    if ($OriginalAssignees.Count -gt 0) {
        Write-Host "Removing assignees..." -ForegroundColor Yellow
        $UnassignBody = @{
            assignees = @{
                rem = $OriginalAssignees
            }
        }
        $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body $UnassignBody

        if (-not $DryRun) {
            Add-RollbackAction -Description "Re-assign original assignees" -Action {
                $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{
                    assignees = @{ add = $OriginalAssignees }
                }
            }
        }
    }

    # Step 4: Post comment
    $CommentText = if ($CustomComment) {
        $CustomComment
    } elseif ($PrUrl) {
        "Taak ready voor review`nPR: $PrUrl"
    } else {
        "Taak ready voor review"
    }

    Write-Host "Posting review comment..." -ForegroundColor Yellow
    $CommentBody = @{ comment_text = $CommentText }
    $null = Invoke-ClickUpAPIWithRetry -Method "POST" -Endpoint "/task/$TaskId/comment" -Body $CommentBody

    # Log to history
    Write-HistoryLog -Action "SubmitForReview" -TaskId $TaskId -Status "success" -Details @{
        from_status = $OriginalStatus
        to_status = "review"
        pr_url = $PrUrl
        comment = $CommentText
    }

    Write-Host "`n✓ Task $TaskId submitted for review!" -ForegroundColor Green
    Write-Host "  Status: review" -ForegroundColor Gray
    Write-Host "  Assigned: (none)" -ForegroundColor Gray
    Write-Host "  Comment: $CommentText" -ForegroundColor Gray

    if ($JsonOutput) {
        return @{
            task_id = $TaskId
            status = "review"
            pr_url = $PrUrl
            comment = $CommentText
        } | ConvertTo-Json
    }
}

function Get-OperationHistory {
    param([int]$Last = 20)

    if (-not (Test-Path $HistoryPath)) {
        Write-Host "No history found at $HistoryPath" -ForegroundColor Yellow
        return
    }

    $AllLines = Get-Content $HistoryPath -Encoding UTF8
    $RecentLines = $AllLines | Select-Object -Last $Last

    if ($JsonOutput) {
        return "[$($RecentLines -join ',')]"
    }

    Write-Host "`n=== Recent Operations (last $Last) ===" -ForegroundColor Cyan
    foreach ($Line in $RecentLines) {
        $Entry = $Line | ConvertFrom-Json
        Write-Host "[$($Entry.timestamp)] $($Entry.action) on $($Entry.task_id) - $($Entry.status)" -ForegroundColor White
        if ($VerboseLogging) {
            Write-Host "  Details: $($Entry.details | ConvertTo-Json -Compress)" -ForegroundColor Gray
        }
    }
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
            try {
                Start-TaskWork -TaskId $TaskId -CustomComment $CustomComment
            } catch {
                Invoke-Rollback
                throw
            }
        }

        "SubmitForReview" {
            if (-not $TaskId) {
                throw "TaskId parameter required for SubmitForReview action"
            }
            try {
                Submit-TaskForReview -TaskId $TaskId -PrUrl $PrUrl -CustomComment $CustomComment
            } catch {
                Invoke-Rollback
                throw
            }
        }

        "GetHistory" {
            Get-OperationHistory
        }
    }

    # Clear rollback stack on success
    $script:RollbackStack = @()

} catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
