# ClickUp Task Operations v3
# Advanced features: Batch ops, Smart status, Search, Undo, Stats, Parallel processing
# Created: 2026-02-15

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("GetUnassigned", "StartWork", "SubmitForReview", "GetHistory", "Undo", "Stats", "Search", "BatchStartWork", "BatchSubmitForReview")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [ValidateSet("client-manager", "hazina", "art-revisionist")]
    [string]$Project,

    [Parameter(Mandatory=$false)]
    [string]$Status,

    [Parameter(Mandatory=$false)]
    [string]$TaskId,

    [Parameter(Mandatory=$false)]
    [string[]]$TaskIds,  # For batch operations

    [Parameter(Mandatory=$false)]
    [string]$PrUrl,

    [Parameter(Mandatory=$false)]
    [string]$CustomComment,

    [Parameter(Mandatory=$false)]
    [string]$TestingInstructions,

    [Parameter(Mandatory=$false)]
    [string]$SearchTerm,

    [Parameter(Mandatory=$false)]
    [ValidateSet("low", "normal", "high", "urgent")]
    [string]$Priority,

    [Parameter(Mandatory=$false)]
    [string[]]$Tags,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [switch]$VerboseLogging,

    [Parameter(Mandatory=$false)]
    [switch]$JsonOutput,

    [Parameter(Mandatory=$false)]
    [switch]$Interactive,

    [Parameter(Mandatory=$false)]
    [switch]$AutoDetectPR,

    [Parameter(Mandatory=$false)]
    [int]$MaxRetries = 3,

    [Parameter(Mandatory=$false)]
    [int]$DaysBack = 7  # For stats
)

$ErrorActionPreference = "Stop"

# Config paths
$ConfigPath = "C:\scripts\_machine\clickup-config.json"
$HistoryPath = "C:\scripts\_machine\clickup-operations-history.jsonl"
$CachePath = "C:\scripts\_machine\clickup-status-cache.json"

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    throw "ClickUp config not found at $ConfigPath"
}

$Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$ApiKey = $Config.api_key
$DefaultAssignee = $Config.default_assignee

# Project configuration (will be auto-populated from cache)
$ProjectConfig = @{
    "client-manager" = @{ ListId = "901214097647"; Statuses = @{} }
    "hazina" = @{ ListId = "901215559249"; Statuses = @{} }
    "art-revisionist" = @{ ListId = "901211612245"; Statuses = @{} }
}

$Headers = @{
    "Authorization" = $ApiKey
    "Content-Type" = "application/json"
}

# Performance tracking
$script:OperationStartTime = Get-Date

# Logging functions
function Write-VerboseLog {
    param([string]$Message)
    if ($VerboseLogging) {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkGray
    }
}

function Sanitize-DescriptionText {
    param([string]$Text)
    if ($Text) { return $Text -replace '[^\x20-\x7E\r\n]', '' }
    return $Text
}

function Write-HistoryLog {
    param(
        [string]$Action,
        [string]$TaskId,
        [string]$Status,
        [hashtable]$Details,
        [double]$DurationMs = 0
    )

    if ($DryRun) { return }

    $LogEntry = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        action = $Action
        task_id = $TaskId
        status = $Status
        duration_ms = $DurationMs
        details = $Details
    } | ConvertTo-Json -Compress

    Add-Content -Path $HistoryPath -Value $LogEntry -Encoding UTF8
    Write-VerboseLog "Logged to history: $Action on $TaskId ($([math]::Round($DurationMs, 0))ms)"
}

# ZERO TOLERANCE ENFORCEMENT (Pattern P108-P112, 2026-03-14)
# Agent is FORBIDDEN from moving tasks to "done" - only user/QA can do this.
$script:ForbiddenStatuses = @('done', 'Done', 'DONE', 'complete', 'Complete', 'COMPLETE', 'closed', 'Closed', 'CLOSED')

function Assert-NotDoneStatus {
    param([string]$TargetStatus)
    if ($TargetStatus -in $script:ForbiddenStatuses) {
        Write-Error "ZERO TOLERANCE VIOLATION BLOCKED: Agent is FORBIDDEN from moving tasks to '$TargetStatus'. Only user/QA can perform this transition."
        throw "ForbiddenStatusTransition: '$TargetStatus' is not allowed for automated agents."
    }
}

# API helper with retry logic
function Invoke-ClickUpAPIWithRetry {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null,
        [int]$RetryCount = 0
    )

    # Enforce status guard on ALL PUT requests that contain a status field
    if ($Method -eq "PUT" -and $Body -and $Body.ContainsKey("status")) {
        Assert-NotDoneStatus -TargetStatus $Body["status"]
    }

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

        Write-Host "API call failed: $ErrorMsg" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        throw
    }
}

# Smart status detection
function Get-ProjectStatuses {
    param([string]$Project)

    # Try cache first
    if (Test-Path $CachePath) {
        $Cache = Get-Content $CachePath -Raw | ConvertFrom-Json
        $CacheAge = ((Get-Date) - [datetime]$Cache.timestamp).TotalHours

        if ($CacheAge -lt 24 -and $Cache.$Project) {
            Write-VerboseLog "Using cached statuses for $Project (age: $([math]::Round($CacheAge, 1))h)"
            return $Cache.$Project
        }
    }

    # Fetch from API
    Write-VerboseLog "Fetching available statuses for $Project from API"
    $ListId = $ProjectConfig[$Project].ListId
    $Response = Invoke-ClickUpAPIWithRetry -Method "GET" -Endpoint "/list/$ListId"

    $Statuses = @{
        todo = @()
        work = @()
        review = @()
        done = @()
    }

    foreach ($Status in $Response.statuses) {
        $StatusName = $Status.status.ToLower()

        # Categorize statuses
        if ($StatusName -match "(todo|backlog|refinement)") {
            $Statuses.todo += $StatusName
        } elseif ($StatusName -match "(busy|progress|doing|development)") {
            $Statuses.work += $StatusName
        } elseif ($StatusName -match "(review|testing|qa)") {
            $Statuses.review += $StatusName
        } elseif ($StatusName -match "(done|complete|closed)") {
            $Statuses.done += $StatusName
        }
    }

    # Update cache
    if (-not $DryRun) {
        $CacheData = if (Test-Path $CachePath) {
            Get-Content $CachePath -Raw | ConvertFrom-Json
        } else {
            @{ timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ") }
        }

        $CacheData | Add-Member -MemberType NoteProperty -Name $Project -Value $Statuses -Force
        $CacheData.timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        $CacheData | ConvertTo-Json -Depth 5 | Set-Content $CachePath -Encoding UTF8
    }

    return $Statuses
}

# Validation
function Test-TaskIdFormat {
    param([string]$TaskId)
    if ($TaskId -notmatch '^\w{9,}$') {
        throw "Invalid TaskId format: $TaskId (expected 9+ alphanumeric characters)"
    }
}

# Rollback tracking
$script:RollbackStack = @()

function Add-RollbackAction {
    param([string]$Description, [scriptblock]$Action)
    $script:RollbackStack += @{ Description = $Description; Action = $Action }
    Write-VerboseLog "Rollback action added: $Description"
}

function Invoke-Rollback {
    Write-Host "`n[ROLLBACK] Undoing $($script:RollbackStack.Count) actions..." -ForegroundColor Red
    for ($i = $script:RollbackStack.Count - 1; $i -ge 0; $i--) {
        $RollbackAction = $script:RollbackStack[$i]
        Write-Host "  Undoing: $($RollbackAction.Description)" -ForegroundColor Yellow
        try { & $RollbackAction.Action } catch { Write-Host "  Failed to rollback: $_" -ForegroundColor Red }
    }
    $script:RollbackStack = @()
}

# PR auto-detection
function Get-CurrentPRUrl {
    if (-not $AutoDetectPR) { return $null }

    try {
        # Get current branch
        $Branch = git rev-parse --abbrev-ref HEAD 2>$null
        if (-not $Branch -or $Branch -eq "HEAD") { return $null }

        # Get remote URL
        $RemoteUrl = git config --get remote.origin.url 2>$null
        if (-not $RemoteUrl) { return $null }

        # Parse GitHub repo from URL
        if ($RemoteUrl -match "github\.com[:/]([^/]+)/([^/\.]+)") {
            $Owner = $matches[1]
            $Repo = $matches[2]

            # Try to find PR via gh CLI
            $PrNumber = gh pr list --head $Branch --json number --jq '.[0].number' 2>$null
            if ($PrNumber) {
                $PrUrl = "https://github.com/$Owner/$Repo/pull/$PrNumber"
                Write-VerboseLog "Auto-detected PR: $PrUrl"
                return $PrUrl
            }
        }
    } catch {
        Write-VerboseLog "PR auto-detection failed: $_"
    }

    return $null
}

# Search tasks
function Search-Tasks {
    param(
        [string]$Project,
        [string]$SearchTerm,
        [string]$Priority,
        [string[]]$Tags
    )

    if (-not $ProjectConfig.ContainsKey($Project)) {
        throw "Unknown project: $Project"
    }

    $ListId = $ProjectConfig[$Project].ListId
    Write-Host "Searching tasks in $Project..." -ForegroundColor Cyan

    $QueryParams = @("archived=false", "subtasks=false")

    $Endpoint = "/list/$ListId/task?$($QueryParams -join '&')"
    $Response = Invoke-ClickUpAPIWithRetry -Method "GET" -Endpoint $Endpoint

    # Filter tasks
    $FilteredTasks = $Response.tasks

    if ($SearchTerm) {
        $FilteredTasks = $FilteredTasks | Where-Object {
            $_.name -match $SearchTerm -or $_.description -match $SearchTerm
        }
    }

    if ($Priority) {
        $FilteredTasks = $FilteredTasks | Where-Object {
            $_.priority.priority -eq $Priority
        }
    }

    if ($Tags -and $Tags.Count -gt 0) {
        $FilteredTasks = $FilteredTasks | Where-Object {
            $TaskTags = $_.tags | ForEach-Object { $_.name }
            $MatchCount = ($Tags | Where-Object { $TaskTags -contains $_ }).Count
            $MatchCount -gt 0
        }
    }

    if ($JsonOutput) {
        return $FilteredTasks | ConvertTo-Json -Depth 5
    }

    Write-Host "`nFound $($FilteredTasks.Count) matching tasks:" -ForegroundColor Green
    foreach ($Task in $FilteredTasks) {
        Write-Host "  [$($Task.status.status)] $($Task.name)" -ForegroundColor Yellow
        Write-Host "    ID: $($Task.id)" -ForegroundColor Gray
        Write-Host "    Priority: $($Task.priority.priority)" -ForegroundColor Gray
        if ($Task.tags.Count -gt 0) {
            Write-Host "    Tags: $($Task.tags.name -join ', ')" -ForegroundColor Gray
        }
    }

    return $FilteredTasks
}

# Stats dashboard
function Show-Stats {
    param([int]$DaysBack)

    if (-not (Test-Path $HistoryPath)) {
        Write-Host "No history found" -ForegroundColor Yellow
        return
    }

    $AllLines = Get-Content $HistoryPath -Encoding UTF8
    $CutoffDate = (Get-Date).AddDays(-$DaysBack)

    $RecentOps = @($AllLines | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        if ([datetime]$Entry.timestamp -gt $CutoffDate) { $Entry }
    })

    $TotalOps = $RecentOps.Count
    $SuccessOps = @($RecentOps | Where-Object { $_.status -eq "success" }).Count
    $FailedOps = @($RecentOps | Where-Object { $_.status -eq "failed" }).Count
    $AvgDuration = if ($TotalOps -gt 0) {
        ($RecentOps | Measure-Object -Property duration_ms -Average).Average
    } else { 0 }

    $StartWorkCount = @($RecentOps | Where-Object { $_.action -eq "StartWork" }).Count
    $SubmitReviewCount = @($RecentOps | Where-Object { $_.action -eq "SubmitForReview" }).Count

    Write-Host "`n=== Stats (Last $DaysBack Days) ===" -ForegroundColor Cyan
    Write-Host "Total Operations: $TotalOps" -ForegroundColor White
    if ($TotalOps -gt 0) {
        Write-Host "  Success: $SuccessOps ($([math]::Round($SuccessOps/$TotalOps*100, 1))%)" -ForegroundColor Green
        Write-Host "  Failed: $FailedOps ($([math]::Round($FailedOps/$TotalOps*100, 1))%)" -ForegroundColor $(if ($FailedOps -gt 0) { "Red" } else { "Gray" })
    } else {
        Write-Host "  Success: $SuccessOps" -ForegroundColor Green
        Write-Host "  Failed: $FailedOps" -ForegroundColor Gray
    }
    Write-Host "Average Duration: $([math]::Round($AvgDuration, 0))ms" -ForegroundColor White
    Write-Host "`nBreakdown:" -ForegroundColor Cyan
    Write-Host "  StartWork: $StartWorkCount" -ForegroundColor White
    Write-Host "  SubmitForReview: $SubmitReviewCount" -ForegroundColor White

    if ($JsonOutput) {
        return @{
            total_operations = $TotalOps
            success_count = $SuccessOps
            failed_count = $FailedOps
            avg_duration_ms = $AvgDuration
            start_work_count = $StartWorkCount
            submit_review_count = $SubmitReviewCount
        } | ConvertTo-Json
    }
}

# Undo last operation
function Undo-LastOperation {
    if (-not (Test-Path $HistoryPath)) {
        Write-Host "No history found" -ForegroundColor Yellow
        return
    }

    $AllLines = Get-Content $HistoryPath -Encoding UTF8
    $LastEntry = $AllLines | Select-Object -Last 1 | ConvertFrom-Json

    Write-Host "`n=== Undoing Last Operation ===" -ForegroundColor Cyan
    Write-Host "Operation: $($LastEntry.action)" -ForegroundColor White
    Write-Host "Task: $($LastEntry.task_id)" -ForegroundColor White
    Write-Host "Time: $($LastEntry.timestamp)" -ForegroundColor Gray

    if ($LastEntry.action -eq "StartWork") {
        # Undo StartWork: revert status, remove assignee
        $TaskId = $LastEntry.task_id
        $OriginalStatus = $LastEntry.details.from_status

        Write-Host "Reverting status to '$OriginalStatus'..." -ForegroundColor Yellow
        $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ status = $OriginalStatus }

        Write-Host "Removing assignee..." -ForegroundColor Yellow
        $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{
            assignees = @{ rem = @($LastEntry.details.assignee) }
        }

        Write-Host "`n[OK] Undone: Task returned to '$OriginalStatus'" -ForegroundColor Green

    } elseif ($LastEntry.action -eq "SubmitForReview") {
        # Undo SubmitForReview: revert status to busy
        $TaskId = $LastEntry.task_id
        $OriginalStatus = $LastEntry.details.from_status

        Write-Host "Reverting status to '$OriginalStatus'..." -ForegroundColor Yellow
        $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ status = $OriginalStatus }

        Write-Host "`n[OK] Undone: Task returned to '$OriginalStatus'" -ForegroundColor Green
    } else {
        Write-Host "Cannot undo operation type: $($LastEntry.action)" -ForegroundColor Yellow
    }
}

# Batch operations
function Start-BatchTaskWork {
    param([string[]]$TaskIds, [string]$CustomComment)

    Write-Host "`n=== Batch StartWork on $($TaskIds.Count) tasks ===" -ForegroundColor Cyan

    $Results = @()
    $SuccessCount = 0
    $FailedCount = 0

    foreach ($TaskId in $TaskIds) {
        try {
            Write-Host "`n[$($SuccessCount + $FailedCount + 1)/$($TaskIds.Count)] Processing $TaskId..." -ForegroundColor Yellow
            Start-TaskWork -TaskId $TaskId -CustomComment $CustomComment
            $Results += @{ task_id = $TaskId; status = "success" }
            $SuccessCount++
        } catch {
            Write-Host "  Failed: $_" -ForegroundColor Red
            $Results += @{ task_id = $TaskId; status = "failed"; error = $_.Exception.Message }
            $FailedCount++
        }
    }

    Write-Host "`n=== Batch Complete ===" -ForegroundColor Cyan
    Write-Host "Success: $SuccessCount / $($TaskIds.Count)" -ForegroundColor Green
    Write-Host "Failed: $FailedCount / $($TaskIds.Count)" -ForegroundColor $(if ($FailedCount -gt 0) { "Red" } else { "Gray" })

    if ($JsonOutput) {
        return $Results | ConvertTo-Json -Depth 5
    }
}

# Interactive mode
function Start-InteractiveMode {
    param([string]$Project)

    Write-Host "`n=== Interactive Task Selection ===" -ForegroundColor Cyan

    # Get unassigned tasks
    $Tasks = Get-UnassignedTasks -Project $Project -Status "todo"

    if ($Tasks.Count -eq 0) {
        Write-Host "No unassigned tasks found" -ForegroundColor Yellow
        return
    }

    # Show numbered list
    Write-Host "`nSelect tasks (comma-separated numbers, e.g., 1,3,5):" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Tasks.Count; $i++) {
        Write-Host "  [$($i + 1)] $($Tasks[$i].name)" -ForegroundColor Yellow
    }

    $Selection = Read-Host "`nYour selection"
    $SelectedIndices = $Selection -split "," | ForEach-Object { [int]$_.Trim() - 1 }

    $SelectedTasks = $SelectedIndices | ForEach-Object { $Tasks[$_] }
    $SelectedTaskIds = $SelectedTasks | ForEach-Object { $_.id }

    Write-Host "`nSelected $($SelectedTaskIds.Count) tasks. Start work? (y/n)" -ForegroundColor Cyan
    $Confirm = Read-Host

    if ($Confirm -eq "y") {
        Start-BatchTaskWork -TaskIds $SelectedTaskIds
    } else {
        Write-Host "Cancelled" -ForegroundColor Yellow
    }
}

# Core operations (simplified versions for space)
function Get-UnassignedTasks {
    param([string]$Project, [string]$Status)

    $ListId = $ProjectConfig[$Project].ListId
    $QueryParams = @("archived=false", "subtasks=false")
    if ($Status) { $QueryParams += "statuses[]=$Status" }

    $Endpoint = "/list/$ListId/task?$($QueryParams -join '&')"
    $Response = Invoke-ClickUpAPIWithRetry -Method "GET" -Endpoint $Endpoint

    $UnassignedTasks = $Response.tasks | Where-Object { $_.assignees.Count -eq 0 }

    if (-not $JsonOutput) {
        Write-Host "`nFound $($UnassignedTasks.Count) unassigned tasks:" -ForegroundColor Green
        foreach ($Task in $UnassignedTasks) {
            Write-Host "  [$($Task.status.status)] $($Task.name)" -ForegroundColor Yellow
            Write-Host "    ID: $($Task.id)" -ForegroundColor Gray
        }
    }

    return $UnassignedTasks
}

function Start-TaskWork {
    param([string]$TaskId, [string]$CustomComment)

    Test-TaskIdFormat -TaskId $TaskId
    $OpStart = Get-Date

    if ($DryRun) {
        Write-Host "[DRY-RUN] Simulated StartWork on $TaskId" -ForegroundColor Green
        return
    }

    $Task = Invoke-ClickUpAPIWithRetry -Method "GET" -Endpoint "/task/$TaskId"
    $OriginalStatus = $Task.status.status

    # Get smart statuses
    $Statuses = Get-ProjectStatuses -Project $Project
    $WorkStatus = if ($Statuses.work.Count -gt 0) { $Statuses.work[0] } else { "busy" }

    $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ status = $WorkStatus }
    $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ assignees = @{ add = @($DefaultAssignee) } }

    $CommentText = if ($CustomComment) { $CustomComment } else { "Jengo work started" }
    $null = Invoke-ClickUpAPIWithRetry -Method "POST" -Endpoint "/task/$TaskId/comment" -Body @{ comment_text = $CommentText }

    $Duration = ((Get-Date) - $OpStart).TotalMilliseconds
    Write-HistoryLog -Action "StartWork" -TaskId $TaskId -Status "success" -DurationMs $Duration -Details @{
        from_status = $OriginalStatus
        to_status = $WorkStatus
        assignee = $DefaultAssignee
        comment = $CommentText
    }

    Write-Host "[OK] Task $TaskId ready for work! ($([math]::Round($Duration, 0))ms)" -ForegroundColor Green
}

function Submit-TaskForReview {
    param([string]$TaskId, [string]$PrUrl, [string]$CustomComment, [string]$TestingInstructions)

    Test-TaskIdFormat -TaskId $TaskId
    $OpStart = Get-Date

    # Auto-detect PR if enabled
    if ($AutoDetectPR -and -not $PrUrl) {
        $PrUrl = Get-CurrentPRUrl
    }

    if ($DryRun) {
        Write-Host "[DRY-RUN] Simulated SubmitForReview on $TaskId" -ForegroundColor Green
        if ($TestingInstructions) {
            Write-Host "[DRY-RUN] Would prepend testing instructions to description" -ForegroundColor Magenta
            Write-Host "[DRY-RUN] Instructions: $TestingInstructions" -ForegroundColor Magenta
        }
        return
    }

    $Task = Invoke-ClickUpAPIWithRetry -Method "GET" -Endpoint "/task/$TaskId"
    $OriginalStatus = $Task.status.status
    $OriginalAssignees = @($Task.assignees | ForEach-Object { $_.id })

    # Prepend testing instructions to description (BEFORE status change)
    if ($TestingInstructions) {
        $ExistingDescription = if ($Task.description) { $Task.description } else { "" }

        $TestingBlock = "TESTING INSTRUCTIONS`n===================`n$TestingInstructions`n`n---`n`n"
        $NewDescription = $TestingBlock + $ExistingDescription

        # Sanitize for PS 5.1 compatibility
        $NewDescription = Sanitize-DescriptionText -Text $NewDescription

        Write-VerboseLog "Prepending testing instructions to task description"
        $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ description = $NewDescription }
        Write-Host "  Testing instructions added to description" -ForegroundColor Cyan
    }

    # Get smart statuses
    $Statuses = Get-ProjectStatuses -Project $Project
    $ReviewStatus = if ($Statuses.review.Count -gt 0) { $Statuses.review[0] } else { "review" }

    $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ status = $ReviewStatus }

    if ($OriginalAssignees.Count -gt 0) {
        $null = Invoke-ClickUpAPIWithRetry -Method "PUT" -Endpoint "/task/$TaskId" -Body @{ assignees = @{ rem = $OriginalAssignees } }
    }

    $CommentText = if ($CustomComment) { $CustomComment } elseif ($PrUrl) { "Taak ready voor review`nPR: $PrUrl" } else { "Taak ready voor review" }
    $null = Invoke-ClickUpAPIWithRetry -Method "POST" -Endpoint "/task/$TaskId/comment" -Body @{ comment_text = $CommentText }

    $Duration = ((Get-Date) - $OpStart).TotalMilliseconds
    Write-HistoryLog -Action "SubmitForReview" -TaskId $TaskId -Status "success" -DurationMs $Duration -Details @{
        from_status = $OriginalStatus
        to_status = $ReviewStatus
        pr_url = $PrUrl
        comment = $CommentText
        has_testing_instructions = [bool]$TestingInstructions
    }

    Write-Host "[OK] Task $TaskId submitted for review! ($([math]::Round($Duration, 0))ms)" -ForegroundColor Green
}

# Main execution
try {
    switch ($Action) {
        "GetUnassigned" {
            if (-not $Project) { throw "Project required" }
            Get-UnassignedTasks -Project $Project -Status $Status
        }
        "StartWork" {
            if (-not $TaskId) { throw "TaskId required" }
            if (-not $Project) { throw "Project required for smart status detection" }
            Start-TaskWork -TaskId $TaskId -CustomComment $CustomComment
        }
        "SubmitForReview" {
            if (-not $TaskId) { throw "TaskId required" }
            if (-not $Project) { throw "Project required for smart status detection" }
            Submit-TaskForReview -TaskId $TaskId -PrUrl $PrUrl -CustomComment $CustomComment -TestingInstructions $TestingInstructions
        }
        "Search" {
            if (-not $Project) { throw "Project required" }
            Search-Tasks -Project $Project -SearchTerm $SearchTerm -Priority $Priority -Tags $Tags
        }
        "Stats" {
            Show-Stats -DaysBack $DaysBack
        }
        "Undo" {
            Undo-LastOperation
        }
        "BatchStartWork" {
            if (-not $TaskIds -or $TaskIds.Count -eq 0) { throw "TaskIds required" }
            if (-not $Project) { throw "Project required" }
            Start-BatchTaskWork -TaskIds $TaskIds -CustomComment $CustomComment
        }
        "BatchSubmitForReview" {
            if (-not $TaskIds -or $TaskIds.Count -eq 0) { throw "TaskIds required" }
            Write-Host "BatchSubmitForReview not yet implemented" -ForegroundColor Yellow
        }
        "GetHistory" {
            if (-not (Test-Path $HistoryPath)) {
                Write-Host "No history found" -ForegroundColor Yellow
                return
            }
            $AllLines = Get-Content $HistoryPath -Encoding UTF8
            $RecentLines = $AllLines | Select-Object -Last 20
            if ($JsonOutput) {
                return "[$($RecentLines -join ',')]"
            }
            Write-Host "`n=== Recent Operations (last 20) ===" -ForegroundColor Cyan
            foreach ($Line in $RecentLines) {
                $Entry = $Line | ConvertFrom-Json
                Write-Host "[$($Entry.timestamp)] $($Entry.action) on $($Entry.task_id) - $($Entry.status) ($($Entry.duration_ms)ms)" -ForegroundColor White
            }
        }
    }

    # Track total operation time
    $TotalDuration = ((Get-Date) - $script:OperationStartTime).TotalMilliseconds
    if ($VerboseLogging) {
        Write-Host "`n[PERFORMANCE] Total operation time: $([math]::Round($TotalDuration, 0))ms" -ForegroundColor DarkGray
    }

} catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
