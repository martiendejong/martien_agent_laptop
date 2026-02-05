#!/usr/bin/env pwsh
<#
.SYNOPSIS
    ClickHub Single Cycle - Process tasks once

.DESCRIPTION
    Processes one complete cycle of ClickUp task management:
    1. Fetch unassigned tasks
    2. Analyze for duplicates, uncertainties
    3. Post questions / move to blocked
    4. Execute todo tasks
    5. Review busy tasks

.PARAMETER Project
    Project to process (client-manager, art-revisionist)

.PARAMETER DryRun
    If set, shows what would happen without making changes

.PARAMETER MaxTasks
    Maximum number of tasks to process in this cycle (default: 5)
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('client-manager', 'art-revisionist')]
    [string]$Project = 'client-manager',

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [int]$MaxTasks = 5
)

$ErrorActionPreference = 'Continue'

# Paths
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$SYNC_SCRIPT = Join-Path $SCRIPT_DIR "clickup-sync.ps1"
$CONFIG_PATH = "C:\scripts\_machine\clickup-config.json"
$POOL_PATH = "C:\scripts\_machine\worktrees.pool.md"

# Colors
$COLOR_INFO = 'Cyan'
$COLOR_SUCCESS = 'Green'
$COLOR_WARNING = 'Yellow'
$COLOR_ERROR = 'Red'

# Load config
if (-not (Test-Path $CONFIG_PATH)) {
    Write-Host "ERROR: Config not found: $CONFIG_PATH" -ForegroundColor $COLOR_ERROR
    exit 1
}
$config = Get-Content $CONFIG_PATH | ConvertFrom-Json

# Get project config
if (-not $config.projects.$Project) {
    Write-Host "ERROR: Project '$Project' not found in config" -ForegroundColor $COLOR_ERROR
    exit 1
}
$listId = $config.projects.$Project.list_id
$assigneeId = "74525428"  # Default assignee (Martien de Jong)

Write-Host "INFO: ClickHub Single Cycle - $Project" -ForegroundColor $COLOR_INFO
Write-Host "   List ID: $listId" -ForegroundColor Gray
Write-Host "   Max Tasks: $MaxTasks" -ForegroundColor Gray
if ($DryRun) {
    Write-Host "   DRY RUN MODE (no changes will be made)" -ForegroundColor $COLOR_WARNING
}
Write-Host ""

# ============================================================================
# Helper Functions
# ============================================================================

function Get-UnassignedTasks {
    param([string]$Status)

    try {
        $output = & $SYNC_SCRIPT -Action list -Project $Project 2>&1

        # Parse output to extract tasks in specified status
        # This is a simplified parser - in production would use structured output
        $tasks = @()
        $inSection = $false

        foreach ($line in $output) {
            if ($line -match "\[$Status\]") {
                $inSection = $true
                continue
            }
            if ($inSection -and $line -match '^\s*$') {
                $inSection = $false
            }
            if ($inSection -and $line -match "^(\S+)\s+(.+?)\s+$Status\s+(\d{4}-\d{2}-\d{2})") {
                $tasks += @{
                    Id = $Matches[1]
                    Name = $Matches[2].Trim()
                    Status = $Status
                    Updated = $Matches[3]
                }
            }
        }

        return $tasks
    } catch {
        Write-Host "WARN:  Error fetching tasks: $_" -ForegroundColor $COLOR_WARNING
        return @()
    }
}

function Get-TaskDetails {
    param([string]$TaskId)

    try {
        $output = & $SYNC_SCRIPT -Action show -TaskId $TaskId 2>&1

        # Parse task details
        $task = @{
            Id = $TaskId
            Name = ""
            Status = ""
            Description = ""
            Comments = @()
            Url = ""
        }

        foreach ($line in $output) {
            if ($line -match '^Name:\s+(.+)$') {
                $task.Name = $Matches[1]
            }
            elseif ($line -match '^Status:\s+(.+)$') {
                $task.Status = $Matches[1]
            }
            elseif ($line -match '^URL:\s+(.+)$') {
                $task.Url = $Matches[1]
            }
            elseif ($line -match '^Description:') {
                $inDescription = $true
            }
            elseif ($inDescription) {
                $task.Description += $line + "`n"
            }
        }

        return $task
    } catch {
        Write-Host "WARN:  Error getting task details: $_" -ForegroundColor $COLOR_WARNING
        return $null
    }
}

function Test-TaskHasUncertainties {
    param([hashtable]$Task)

    # Analyze task for uncertainties that MUST be answered before implementation
    # This is a simplified heuristic - in production would use LLM analysis

    $uncertainties = @()

    # Check for vague descriptions
    if ($Task.Description.Length -lt 20) {
        $uncertainties += "Task description is very short - may lack detail"
    }

    # Check for question marks in description
    if ($Task.Description -match '\?') {
        $uncertainties += "Task description contains questions"
    }

    # Check for ambiguous words
    $ambiguousWords = @("maybe", "perhaps", "possibly", "could", "might", "should we")
    foreach ($word in $ambiguousWords) {
        if ($Task.Description -match $word) {
            $uncertainties += "Task description contains ambiguous language: '$word'"
            break
        }
    }

    return $uncertainties
}

function Get-FreeAgentSeat {
    # Read worktree pool and find a FREE seat
    try {
        $poolContent = Get-Content $POOL_PATH -Raw

        # Parse pool markdown table
        $lines = $poolContent -split "`n"
        foreach ($line in $lines) {
            if ($line -match '\| (agent-\d+) \|.*\| FREE \|') {
                return $Matches[1]
            }
        }

        Write-Host "WARNING: No FREE agent seats available" -ForegroundColor $COLOR_WARNING
        return $null
    } catch {
        Write-Host "WARNING: Error reading worktree pool: $_" -ForegroundColor $COLOR_WARNING
        return $null
    }
}

function Invoke-TaskImplementation {
    param(
        [hashtable]$Task,
        [string]$AgentSeat
    )

    Write-Host "IMPLEMENTING: Implementing task $($Task.Id): $($Task.Name)" -ForegroundColor $COLOR_INFO
    Write-Host "   Agent seat: $AgentSeat" -ForegroundColor Gray

    if ($DryRun) {
        Write-Host "   [DRY RUN] Would implement task here" -ForegroundColor $COLOR_WARNING
        return $true
    }

    # Post "AGENT WORKING" comment
    try {
        $agentId = $AgentSeat
        $sessionTime = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        $branchName = "feature/$($Task.Id)-$(($Task.Name -replace '[^a-zA-Z0-9]', '-').ToLower())"

        $workingComment = @"
AGENT WORKING

Agent ID: $agentId
Session Start: $sessionTime
Branch: $branchName
Worktree: C:/Projects/worker-agents/$agentId/client-manager

This task is now being actively worked on.
Other agents: Please do not pick up this task.

-- Claude Code Agent ($agentId)
"@

        & $SYNC_SCRIPT -Action comment -TaskId $Task.Id -Comment $workingComment

        # Update status to busy and assign
        & $SYNC_SCRIPT -Action update -TaskId $Task.Id -Status "busy" -Assignee $assigneeId

        Write-Host "   OK: Task marked as busy and assigned" -ForegroundColor $COLOR_SUCCESS

    } catch {
        Write-Host "   ERROR: Error updating task status: $_" -ForegroundColor $COLOR_ERROR
        return $false
    }

    # TODO: Actual implementation logic goes here
    # Options:
    # 1. Invoke Task tool to spawn implementation agent
    # 2. Call external script/tool for implementation
    # 3. Manual implementation step

    Write-Host "   WARN:  TODO: Actual implementation logic not yet implemented" -ForegroundColor $COLOR_WARNING
    Write-Host "   This would:" -ForegroundColor Gray
    Write-Host "   - Allocate worktree ($AgentSeat)" -ForegroundColor Gray
    Write-Host "   - Analyze codebase and implement changes" -ForegroundColor Gray
    Write-Host "   - Create PR with proper linking" -ForegroundColor Gray
    Write-Host "   - Release worktree" -ForegroundColor Gray
    Write-Host "   - Update task to 'review' status" -ForegroundColor Gray

    return $false  # Return false since not fully implemented yet
}

function Invoke-PostQuestions {
    param(
        [hashtable]$Task,
        [array]$Uncertainties
    )

    Write-Host "QUESTION: Posting questions for task $($Task.Id)" -ForegroundColor $COLOR_WARNING

    if ($DryRun) {
        Write-Host "   [DRY RUN] Would post these uncertainties:" -ForegroundColor $COLOR_WARNING
        foreach ($u in $Uncertainties) {
            Write-Host "   - $u" -ForegroundColor Gray
        }
        return $true
    }

    # Build questions comment
    $questionsComment = @"
QUESTIONS BEFORE IMPLEMENTATION:

"@

    $questionNum = 1
    foreach ($u in $Uncertainties) {
        $questionsComment += "${questionNum}. $u`n"
        $questionNum++
    }

    $questionsComment += @"

Please clarify before I proceed with implementation.

-- ClickHub Coding Agent
"@

    try {
        & $SYNC_SCRIPT -Action comment -TaskId $Task.Id -Comment $questionsComment
        & $SYNC_SCRIPT -Action update -TaskId $Task.Id -Status "blocked"

        Write-Host "   OK: Questions posted and task moved to blocked" -ForegroundColor $COLOR_SUCCESS
        return $true
    } catch {
        Write-Host "   ERROR: Error posting questions: $_" -ForegroundColor $COLOR_ERROR
        return $false
    }
}

# ============================================================================
# Main Cycle Logic
# ============================================================================

Write-Host "-----------------------------------------------------" -ForegroundColor $COLOR_INFO
Write-Host "STEP 1: Fetch Unassigned Tasks" -ForegroundColor $COLOR_INFO
Write-Host "-----------------------------------------------------" -ForegroundColor $COLOR_INFO

$todoTasks = Get-UnassignedTasks -Status "todo"
Write-Host "Found $($todoTasks.Count) unassigned 'todo' tasks" -ForegroundColor $COLOR_SUCCESS

if ($todoTasks.Count -eq 0) {
    Write-Host "OK: No todo tasks to process" -ForegroundColor $COLOR_SUCCESS
    Write-Host ""
    exit 0
}

# Limit tasks processed
$tasksToProcess = $todoTasks | Select-Object -First $MaxTasks
Write-Host "Processing $($tasksToProcess.Count) tasks (max: $MaxTasks)" -ForegroundColor $COLOR_INFO
Write-Host ""

$processedCount = 0
$implementedCount = 0
$blockedCount = 0
$errorCount = 0

foreach ($task in $tasksToProcess) {
    Write-Host "-----------------------------------------------------" -ForegroundColor Gray
    Write-Host "Processing Task: $($task.Id)" -ForegroundColor $COLOR_INFO
    Write-Host "Name: $($task.Name)" -ForegroundColor White
    Write-Host ""

    # Get full task details
    $taskDetails = Get-TaskDetails -TaskId $task.Id
    if (-not $taskDetails) {
        Write-Host "ERROR: Could not fetch task details" -ForegroundColor $COLOR_ERROR
        $errorCount++
        continue
    }

    Write-Host "STEP 2: Analyze Task" -ForegroundColor $COLOR_INFO

    # Check for uncertainties
    $uncertainties = Test-TaskHasUncertainties -Task $taskDetails

    if ($uncertainties.Count -gt 0) {
        Write-Host "WARN:  Found $($uncertainties.Count) uncertainties:" -ForegroundColor $COLOR_WARNING
        foreach ($u in $uncertainties) {
            Write-Host "   - $u" -ForegroundColor Gray
        }
        Write-Host ""

        Write-Host "STEP 3: Post Questions and Block Task" -ForegroundColor $COLOR_INFO
        $posted = Invoke-PostQuestions -Task $taskDetails -Uncertainties $uncertainties
        if ($posted) {
            $blockedCount++
        } else {
            $errorCount++
        }
        Write-Host ""
        continue
    }

    Write-Host "OK: Task appears clear - proceeding with implementation" -ForegroundColor $COLOR_SUCCESS
    Write-Host ""

    Write-Host "STEP 3: Find Free Agent Seat" -ForegroundColor $COLOR_INFO
    $agentSeat = Get-FreeAgentSeat

    if (-not $agentSeat) {
        Write-Host "WARN:  No free agent seats - skipping task" -ForegroundColor $COLOR_WARNING
        Write-Host ""
        continue
    }

    Write-Host "OK: Using agent seat: $agentSeat" -ForegroundColor $COLOR_SUCCESS
    Write-Host ""

    Write-Host "STEP 4: Execute Task Implementation" -ForegroundColor $COLOR_INFO
    $implemented = Invoke-TaskImplementation -Task $taskDetails -AgentSeat $agentSeat

    if ($implemented) {
        $implementedCount++
    } else {
        $errorCount++
    }

    Write-Host ""
    $processedCount++
}

# ============================================================================
# Summary
# ============================================================================

Write-Host "-----------------------------------------------------" -ForegroundColor $COLOR_INFO
Write-Host "Cycle Complete - Summary" -ForegroundColor $COLOR_INFO
Write-Host "-----------------------------------------------------" -ForegroundColor $COLOR_INFO
Write-Host ""
Write-Host "Tasks processed:    $processedCount" -ForegroundColor White
Write-Host "Tasks implemented:  $implementedCount" -ForegroundColor $COLOR_SUCCESS
Write-Host "Tasks blocked:      $blockedCount" -ForegroundColor $COLOR_WARNING
Write-Host "Errors:             $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { $COLOR_ERROR } else { $COLOR_SUCCESS })
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN COMPLETE - No actual changes were made" -ForegroundColor $COLOR_WARNING
}

exit 0
