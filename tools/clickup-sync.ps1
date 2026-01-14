<#
.SYNOPSIS
    ClickUp synchronization tool for Claude Agent

.DESCRIPTION
    Syncs tasks between ClickUp and local development workflow.
    Supports listing, updating, and creating tasks.

.PARAMETER Action
    list    - List open tasks from Vera AI list
    update  - Update a task's status
    create  - Create a new task
    comment - Add comment to a task
    show    - Show task details

.PARAMETER TaskId
    ClickUp task ID (for update/comment/show actions)

.PARAMETER Status
    New status for task (for update action)

.PARAMETER Comment
    Comment text (for comment action)

.PARAMETER Name
    Task name (for create action)

.PARAMETER Description
    Task description (for create action)

.EXAMPLE
    .\clickup-sync.ps1 -Action list
    .\clickup-sync.ps1 -Action update -TaskId "86c45buz7" -Status "testen"
    .\clickup-sync.ps1 -Action comment -TaskId "86c45buz7" -Comment "PR #149 created"
    .\clickup-sync.ps1 -Action create -Name "Fix login bug" -Description "Details here"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("list", "update", "create", "comment", "show")]
    [string]$Action,

    [string]$TaskId,
    [string]$Status,
    [string]$Comment,
    [string]$Name,
    [string]$Description,
    [string]$ListId = "901214097647"  # Default: Brand Designer list (client-manager)
)

# Load config
$configPath = "C:\scripts\_machine\clickup-config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "Config not found: $configPath"
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json
$apiKey = $config.api_key
$apiBase = $config.api_base

$headers = @{
    Authorization = $apiKey
    "Content-Type" = "application/json"
}

function Format-TaskTable {
    param($tasks)

    $tasks | ForEach-Object {
        [PSCustomObject]@{
            ID = $_.id
            Name = if ($_.name.Length -gt 50) { $_.name.Substring(0,47) + "..." } else { $_.name }
            Status = $_.status.status
            Updated = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$_.date_updated).ToString("yyyy-MM-dd")
        }
    } | Format-Table -AutoSize
}

switch ($Action) {
    "list" {
        Write-Host "`n=== Brand Designer Tasks (client-manager/hazina) ===" -ForegroundColor Cyan

        $url = "$apiBase/list/$ListId/task?archived=false&include_closed=false"
        $response = Invoke-RestMethod -Uri $url -Headers $headers

        # Group by status
        $grouped = $response.tasks | Group-Object { $_.status.status }

        foreach ($group in $grouped | Sort-Object { $_.Values[0].status.orderindex }) {
            Write-Host "`n[$($group.Name)] ($($group.Count) tasks)" -ForegroundColor Yellow
            Format-TaskTable $group.Group
        }

        Write-Host "`nTotal: $($response.tasks.Count) open tasks" -ForegroundColor Green
    }

    "show" {
        if (-not $TaskId) {
            Write-Error "TaskId required for show action"
            exit 1
        }

        $url = "$apiBase/task/$TaskId"
        $task = Invoke-RestMethod -Uri $url -Headers $headers

        Write-Host "`n=== Task Details ===" -ForegroundColor Cyan
        Write-Host "ID:          $($task.id)"
        Write-Host "Name:        $($task.name)"
        Write-Host "Status:      $($task.status.status)"
        Write-Host "Created:     $([DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_created).ToString("yyyy-MM-dd HH:mm"))"
        Write-Host "Updated:     $([DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_updated).ToString("yyyy-MM-dd HH:mm"))"
        Write-Host "URL:         $($task.url)"
        if ($task.description) {
            Write-Host "`nDescription:" -ForegroundColor Yellow
            Write-Host $task.description
        }
    }

    "update" {
        if (-not $TaskId) {
            Write-Error "TaskId required for update action"
            exit 1
        }
        if (-not $Status) {
            Write-Error "Status required for update action"
            exit 1
        }

        $url = "$apiBase/task/$TaskId"
        $body = @{ status = $Status } | ConvertTo-Json

        $task = Invoke-RestMethod -Method PUT -Uri $url -Headers $headers -Body $body
        Write-Host "Task $TaskId updated to status: $Status" -ForegroundColor Green
        Write-Host "URL: $($task.url)"
    }

    "comment" {
        if (-not $TaskId) {
            Write-Error "TaskId required for comment action"
            exit 1
        }
        if (-not $Comment) {
            Write-Error "Comment required for comment action"
            exit 1
        }

        $url = "$apiBase/task/$TaskId/comment"
        $body = @{ comment_text = $Comment } | ConvertTo-Json

        $result = Invoke-RestMethod -Method POST -Uri $url -Headers $headers -Body $body
        Write-Host "Comment added to task $TaskId" -ForegroundColor Green
    }

    "create" {
        if (-not $Name) {
            Write-Error "Name required for create action"
            exit 1
        }

        $url = "$apiBase/list/$ListId/task"
        $body = @{
            name = $Name
            description = if ($Description) { $Description } else { "" }
            status = "backlog"
        } | ConvertTo-Json

        $task = Invoke-RestMethod -Method POST -Uri $url -Headers $headers -Body $body
        Write-Host "Task created: $($task.id)" -ForegroundColor Green
        Write-Host "Name: $($task.name)"
        Write-Host "URL: $($task.url)"
    }
}
