#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Get all ClickUp tasks from a specific status column
.DESCRIPTION
    Retrieves all tasks from a specified status/column for one or all GigsHub boards.
    This is the CANONICAL way to fetch ClickUp tasks - use this script 100% of the time.

    ðŸš¨ ZERO TOLERANCE ENFORCEMENT:
    - Status parameter is MANDATORY (no default)
    - If no board specified, loops through ALL GigsHub boards
    - Returns comprehensive task list with full details
    - Used for ALL clickup task retrieval operations

.PARAMETER Status
    REQUIRED. The status/column name to fetch tasks from (e.g., "backlog", "todo", "review", "testing")
.PARAMETER Board
    OPTIONAL. Board/project name (e.g., "bliek", "client-manager", "seo-god")
    If omitted, loops through ALL GigsHub boards
.PARAMETER Workspace
    Which workspace to use (default: "gigshub")
.PARAMETER IncludeArchived
    Include archived tasks (default: false)
.PARAMETER IncludeSubtasks
    Include subtasks (default: false)
.PARAMETER Format
    Output format: "table" (default), "json", "count"
.PARAMETER GroupByBoard
    When fetching multiple boards, group results by board (default: true)
.PARAMETER Verbose
    Enable verbose logging
.EXAMPLE
    # Get all backlog tasks from Bliek Vastgoed
    .\clickup-get-tasks-by-status.ps1 -Status "backlog" -Board "bliek"

.EXAMPLE
    # Get all "review" tasks from ALL GigsHub boards
    .\clickup-get-tasks-by-status.ps1 -Status "review"

.EXAMPLE
    # Get all "todo" tasks, JSON output
    .\clickup-get-tasks-by-status.ps1 -Status "todo" -Format "json"

.EXAMPLE
    # Count tasks in "testing" across all boards
    .\clickup-get-tasks-by-status.ps1 -Status "testing" -Format "count"
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Status/column name to fetch tasks from (e.g., 'backlog', 'todo', 'review')")]
    [string]$Status,

    [Parameter(Mandatory=$false)]
    [string]$Board,

    [Parameter(Mandatory=$false)]
    [ValidateSet("gigshub", "personal", "company")]
    [string]$Workspace = "gigshub",

    [Parameter(Mandatory=$false)]
    [switch]$IncludeArchived,

    [Parameter(Mandatory=$false)]
    [switch]$IncludeSubtasks,

    [Parameter(Mandatory=$false)]
    [ValidateSet("table", "json", "count")]
    [string]$Format = "table",

    [Parameter(Mandatory=$false)]
    [switch]$GroupByBoard = $true,

    [Parameter(Mandatory=$false)]
    [switch]$VerboseLogging
)

$ErrorActionPreference = "Stop"

# Config paths
$ConfigPath = "C:\scripts\_machine\clickup-config.json"

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    throw "ClickUp config not found at $ConfigPath"
}

$Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$ApiKey = $Config.api_key
$ApiBase = $Config.api_base

$Headers = @{
    "Authorization" = $ApiKey
    "Content-Type" = "application/json"
}

# Logging
function Write-VerboseLog {
    param([string]$Message)
    if ($VerboseLogging) {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkGray
    }
}

# API call with error handling
function Invoke-ClickUpAPI {
    param(
        [string]$Endpoint,
        [string]$Method = "GET"
    )

    $Uri = "$ApiBase$Endpoint"
    Write-VerboseLog "API $Method $Uri"

    try {
        $Response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
        return $Response
    } catch {
        Write-Host "API call failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        throw
    }
}

# Get all boards in workspace
function Get-WorkspaceBoards {
    param([string]$WorkspaceName)

    Write-VerboseLog "Getting boards for workspace: $WorkspaceName"

    $AllBoards = @()

    # Navigate workspace structure
    $WorkspaceConfig = $Config.workspaces.$WorkspaceName
    if (-not $WorkspaceConfig) {
        throw "Unknown workspace: $WorkspaceName"
    }

    # Iterate through spaces
    foreach ($SpaceName in $WorkspaceConfig.spaces.PSObject.Properties.Name) {
        $Space = $WorkspaceConfig.spaces.$SpaceName
        Write-VerboseLog "  Checking space: $SpaceName (ID: $($Space.id))"

        # Check for folders
        if ($Space.folders) {
            foreach ($FolderName in $Space.folders.PSObject.Properties.Name) {
                $Folder = $Space.folders.$FolderName
                if ($Folder.lists) {
                    foreach ($ListName in $Folder.lists.PSObject.Properties.Name) {
                        $List = $Folder.lists.$ListName
                        $AllBoards += @{
                            list_id = $List.id
                            list_name = $List.name
                            folder = $FolderName
                            space = $SpaceName
                            workspace = $WorkspaceName
                        }
                        Write-VerboseLog "    Found board: $($List.name) (ID: $($List.id))"
                    }
                }
            }
        }

        # Check for direct lists (no folder)
        if ($Space.lists) {
            foreach ($ListName in $Space.lists.PSObject.Properties.Name) {
                $List = $Space.lists.$ListName
                $AllBoards += @{
                    list_id = $List.id
                    list_name = $List.name
                    folder = $null
                    space = $SpaceName
                    workspace = $WorkspaceName
                }
                Write-VerboseLog "    Found board: $($List.name) (ID: $($List.id))"
            }
        }
    }

    Write-Host "Found $($AllBoards.Count) boards in workspace '$WorkspaceName'" -ForegroundColor Cyan
    return $AllBoards
}

# Resolve board to list ID
function Resolve-BoardToListId {
    param([string]$BoardName)

    Write-VerboseLog "Resolving board: $BoardName"

    # Common aliases
    $Aliases = @{
        'stm' = 'simple-translation-manager'
        'brand-designer' = 'client-manager'
        'b2b' = 'brand2boost-birdseye'
    }
    if ($Aliases.ContainsKey($BoardName)) {
        $BoardName = $Aliases[$BoardName]
        Write-VerboseLog "  Resolved alias to: $BoardName"
    }

    # Check projects mapping first
    if ($Config.projects.$BoardName) {
        $ListId = $Config.projects.$BoardName.list_id
        Write-VerboseLog "  Resolved via projects mapping: $ListId"
        return @{
            list_id = $ListId
            list_name = $Config.projects.$BoardName.name
            source = "projects"
        }
    }

    # Check repo_mapping
    if ($Config.repo_mapping.$BoardName) {
        $ListId = $Config.repo_mapping.$BoardName.list_id
        $ListName = $Config.repo_mapping.$BoardName.list_name
        Write-VerboseLog "  Resolved via repo_mapping: $ListId"
        return @{
            list_id = $ListId
            list_name = $ListName
            source = "repo_mapping"
        }
    }

    throw "Unknown board: $BoardName"
}

# Get tasks from a list with status filter
function Get-TasksFromList {
    param(
        [string]$ListId,
        [string]$StatusFilter,
        [bool]$IncludeArchived = $false,
        [bool]$IncludeSubtasks = $false
    )

    Write-VerboseLog "Fetching tasks from list $ListId with status '$StatusFilter'"

    # Build query parameters
    $QueryParams = @()
    if (-not $IncludeArchived) {
        $QueryParams += "archived=false"
    }
    if (-not $IncludeSubtasks) {
        $QueryParams += "subtasks=false"
    }

    $QueryString = if ($QueryParams.Count -gt 0) { "?$($QueryParams -join '&')" } else { "" }
    $Endpoint = "/list/$ListId/task$QueryString"

    $Response = Invoke-ClickUpAPI -Endpoint $Endpoint

    # Filter by status (case-insensitive)
    $FilteredTasks = $Response.tasks | Where-Object {
        $_.status.status -eq $StatusFilter
    }

    Write-VerboseLog "  Found $($FilteredTasks.Count) tasks with status '$StatusFilter'"
    return $FilteredTasks
}

# Format task output
function Format-TaskOutput {
    param(
        [array]$Tasks,
        [string]$BoardName,
        [string]$OutputFormat,
        [bool]$ShowBoardHeader = $true
    )

    if ($Tasks.Count -eq 0) {
        if ($ShowBoardHeader) {
            Write-Host "  No tasks found" -ForegroundColor Gray
        }
        return
    }

    if ($OutputFormat -eq "json") {
        return $Tasks
    }

    if ($OutputFormat -eq "count") {
        if ($ShowBoardHeader) {
            Write-Host "  Tasks: $($Tasks.Count)" -ForegroundColor White
        }
        return $Tasks.Count
    }

    # Table format (default)
    foreach ($Task in $Tasks) {
        $Assignees = if ($Task.assignees.Count -gt 0) {
            ($Task.assignees | ForEach-Object { $_.username }) -join ", "
        } else {
            "Unassigned"
        }

        $Priority = if ($Task.priority) { $Task.priority.priority } else { "none" }
        $Tags = if ($Task.tags.Count -gt 0) {
            ($Task.tags | ForEach-Object { $_.name }) -join ", "
        } else {
            ""
        }

        Write-Host "  [$($Task.status.status)] $($Task.name)" -ForegroundColor Yellow
        Write-Host "    ID: $($Task.id)" -ForegroundColor Gray
        Write-Host "    Assignees: $Assignees" -ForegroundColor Gray
        Write-Host "    Priority: $Priority" -ForegroundColor Gray
        if ($Tags) {
            Write-Host "    Tags: $Tags" -ForegroundColor Gray
        }
        Write-Host "    URL: $($Task.url)" -ForegroundColor DarkGray
        Write-Host ""
    }
}

# Main execution

# Main execution
try {
    $script:StartTime = Get-Date

    Write-Host "`n=== ClickUp Tasks by Status ===" -ForegroundColor Cyan
    Write-Host "Status: '$Status'" -ForegroundColor White
    Write-Host "Workspace: $Workspace" -ForegroundColor White

    $AllResults = @()
    $TotalCount = 0

    if ($Board) {
        # Single board mode
        Write-Host "Board: $Board`n" -ForegroundColor White

        $BoardInfo = Resolve-BoardToListId -BoardName $Board
        $Tasks = Get-TasksFromList -ListId $BoardInfo.list_id -StatusFilter $Status -IncludeArchived:$IncludeArchived -IncludeSubtasks:$IncludeSubtasks

        if ($Format -eq "json") {
            $AllResults += $Tasks
        } else {
            Write-Host "`nBoard: $($BoardInfo.list_name)" -ForegroundColor Cyan
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
            Format-TaskOutput -Tasks $Tasks -BoardName $BoardInfo.list_name -OutputFormat $Format -ShowBoardHeader $true
        }

        $TotalCount = $Tasks.Count

    } else {
        # Multi-board mode (all GigsHub boards)
        Write-Host "Board: ALL (looping through all GigsHub boards)`n" -ForegroundColor White

        $AllBoards = Get-WorkspaceBoards -WorkspaceName $Workspace

        foreach ($BoardInfo in $AllBoards) {
            Write-VerboseLog "Processing board: $($BoardInfo.list_name)"

            $Tasks = Get-TasksFromList -ListId $BoardInfo.list_id -StatusFilter $Status -IncludeArchived:$IncludeArchived -IncludeSubtasks:$IncludeSubtasks

            if ($Tasks.Count -gt 0) {
                $TotalCount += $Tasks.Count

                if ($Format -eq "json") {
                    # Add board metadata to each task
                    foreach ($Task in $Tasks) {
                        $Task | Add-Member -NotePropertyName "_board_name" -NotePropertyValue $BoardInfo.list_name -Force
                        $Task | Add-Member -NotePropertyName "_board_id" -NotePropertyValue $BoardInfo.list_id -Force
                    }
                    $AllResults += $Tasks
                } else {
                    # Show board header
                    Write-Host "`n┌─────────────────────────────────────────────────┐" -ForegroundColor Cyan
                    Write-Host "│ Board: $($BoardInfo.list_name)" -ForegroundColor Cyan
                    Write-Host "│ Folder: $($BoardInfo.folder)" -ForegroundColor DarkCyan
                    Write-Host "│ Tasks: $($Tasks.Count)" -ForegroundColor White
                    Write-Host "└─────────────────────────────────────────────────┘" -ForegroundColor Cyan

                    Format-TaskOutput -Tasks $Tasks -BoardName $BoardInfo.list_name -OutputFormat $Format -ShowBoardHeader $false
                }
            } else {
                Write-VerboseLog "  No tasks found for board: $($BoardInfo.list_name)"
            }
        }
    }

    # Summary
    $Duration = ((Get-Date) - $script:StartTime).TotalMilliseconds
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "SUMMARY:" -ForegroundColor Cyan
    Write-Host "  Total tasks found: $TotalCount" -ForegroundColor White
    Write-Host "  Duration: $([math]::Round($Duration, 0))ms" -ForegroundColor Gray
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

    # JSON output
    if ($Format -eq "json") {
        $Output = @{
            status = $Status
            workspace = $Workspace
            board = if ($Board) { $Board } else { "ALL" }
            total_count = $TotalCount
            tasks = $AllResults
            duration_ms = $Duration
        }
        return $Output | ConvertTo-Json -Depth 10
    }

    # Count output
    if ($Format -eq "count") {
        return $TotalCount
    }

} catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    exit 1
}
