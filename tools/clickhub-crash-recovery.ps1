# ClickHub Crash Recovery System
# Version: 1.0.0
# Created: 2026-02-28
# Purpose: Save checkpoints and recover from crashes

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Checkpoint", "Recover", "List", "Clean")]
    [string]$Action = "Checkpoint",

    [Parameter(Mandatory=$false)]
    [string]$AgentId,

    [Parameter(Mandatory=$false)]
    [string]$TaskId,

    [Parameter(Mandatory=$false)]
    [string]$Project,

    [Parameter(Mandatory=$false)]
    [string]$Phase,  # "analysis", "implementation", "testing", "pr-creation"

    [Parameter(Mandatory=$false)]
    [hashtable]$Metadata
)

$checkpointDir = "C:\scripts\_machine\checkpoints"

# Ensure checkpoint directory exists
if (-not (Test-Path $checkpointDir)) {
    New-Item -ItemType Directory -Path $checkpointDir | Out-Null
}

# Create checkpoint
function Create-Checkpoint {
    param($agentId, $taskId, $project, $phase, $metadata)

    $sessionId = "session-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $checkpointFile = Join-Path $checkpointDir "$agentId-$taskId.json"

    $checkpoint = @{
        session_id = $sessionId
        agent_id = $agentId
        task_id = $taskId
        project = $project
        phase = $phase
        timestamp = Get-Date -Format "o"
        metadata = $metadata
        worktree_path = "C:/Projects/worker-agents/$agentId/$project"
        branch_name = $metadata.branch
        files_changed = @()
        commits = 0
        last_heartbeat = Get-Date -Format "o"
    }

    # Try to get worktree info if it exists
    $worktreePath = "C:/Projects/worker-agents/$agentId/$project"
    if (Test-Path $worktreePath) {
        Push-Location $worktreePath
        try {
            # Get modified files
            $modifiedFiles = git status --porcelain 2>$null | ForEach-Object { $_.Substring(3) }
            $checkpoint.files_changed = @($modifiedFiles)

            # Get commit count on current branch
            $commitCount = git rev-list --count HEAD 2>$null
            if ($commitCount) {
                $checkpoint.commits = [int]$commitCount
            }

            # Get current branch
            $currentBranch = git branch --show-current 2>$null
            if ($currentBranch) {
                $checkpoint.branch_name = $currentBranch
            }
        } catch {
            Write-Host "Warning: Could not get git info - $($_.Exception.Message)" -ForegroundColor Yellow
        }
        Pop-Location
    }

    # Save checkpoint
    $checkpoint | ConvertTo-Json -Depth 10 | Set-Content $checkpointFile

    if ($Verbose) {
        Write-Host "[CHECKPOINT] Saved for $agentId on task $taskId" -ForegroundColor Green
        Write-Host "  Phase: $phase" -ForegroundColor Gray
        Write-Host "  Files changed: $($checkpoint.files_changed.Count)" -ForegroundColor Gray
        Write-Host "  Commits: $($checkpoint.commits)" -ForegroundColor Gray
    }

    # Also update heartbeat file for monitoring
    Update-Heartbeat $agentId $taskId

    return $checkpointFile
}

# Update heartbeat (for monitoring if agent is still alive)
function Update-Heartbeat {
    param($agentId, $taskId)

    $heartbeatFile = Join-Path $checkpointDir "heartbeat-$agentId.json"

    $heartbeat = @{
        agent_id = $agentId
        task_id = $taskId
        last_seen = Get-Date -Format "o"
        status = "alive"
    }

    $heartbeat | ConvertTo-Json | Set-Content $heartbeatFile
}

# Recover from checkpoint
function Recover-From-Checkpoint {
    param($agentId, $taskId)

    $checkpointFile = Join-Path $checkpointDir "$agentId-$taskId.json"

    if (-not (Test-Path $checkpointFile)) {
        Write-Host "No checkpoint found for $agentId on task $taskId" -ForegroundColor Yellow
        return $null
    }

    $checkpoint = Get-Content $checkpointFile | ConvertFrom-Json

    Write-Host "`n=== CRASH RECOVERY ===" -ForegroundColor Cyan
    Write-Host "Agent: $($checkpoint.agent_id)" -ForegroundColor White
    Write-Host "Task: $($checkpoint.task_id)" -ForegroundColor White
    Write-Host "Project: $($checkpoint.project)" -ForegroundColor White
    Write-Host "Last Phase: $($checkpoint.phase)" -ForegroundColor White
    Write-Host "Timestamp: $($checkpoint.timestamp)" -ForegroundColor White
    Write-Host "Files Changed: $($checkpoint.files_changed.Count)" -ForegroundColor White
    Write-Host "Commits: $($checkpoint.commits)" -ForegroundColor White

    # Calculate time since checkpoint
    $timeSince = (Get-Date) - [DateTime]$checkpoint.timestamp
    Write-Host "Time Since Checkpoint: $([math]::Round($timeSince.TotalMinutes, 1)) minutes ago" -ForegroundColor Yellow

    # Check if worktree still exists
    if (Test-Path $checkpoint.worktree_path) {
        Write-Host "`nWorktree still exists at: $($checkpoint.worktree_path)" -ForegroundColor Green

        Push-Location $checkpoint.worktree_path
        try {
            # Show current git status
            Write-Host "`nGit Status:" -ForegroundColor Yellow
            git status

            Write-Host "`n=== RECOVERY OPTIONS ===" -ForegroundColor Cyan
            Write-Host "1. Continue from last checkpoint (resume work)" -ForegroundColor White
            Write-Host "2. Commit current changes and create PR" -ForegroundColor White
            Write-Host "3. Discard changes and start fresh" -ForegroundColor White
            Write-Host "4. Cancel recovery" -ForegroundColor White

        } finally {
            Pop-Location
        }
    } else {
        Write-Host "`nWorktree no longer exists. Work may be lost." -ForegroundColor Red
        Write-Host "Last known state:" -ForegroundColor Yellow
        Write-Host "  Branch: $($checkpoint.branch_name)" -ForegroundColor Gray
        Write-Host "  Files: $($checkpoint.files_changed -join ', ')" -ForegroundColor Gray
    }

    return $checkpoint
}

# List all checkpoints
function List-Checkpoints {
    $checkpoints = Get-ChildItem $checkpointDir -Filter "*.json" |
                   Where-Object { $_.Name -notmatch "heartbeat" } |
                   ForEach-Object {
                       $data = Get-Content $_.FullName | ConvertFrom-Json
                       $data | Add-Member -NotePropertyName "checkpoint_file" -NotePropertyValue $_.Name -Force
                       $data
                   }

    if ($checkpoints.Count -eq 0) {
        Write-Host "No checkpoints found" -ForegroundColor Yellow
        return
    }

    Write-Host "`n=== AVAILABLE CHECKPOINTS ===" -ForegroundColor Cyan

    foreach ($cp in $checkpoints | Sort-Object timestamp -Descending) {
        $timeSince = (Get-Date) - [DateTime]$cp.timestamp
        $status = if ($timeSince.TotalMinutes -lt 10) { "RECENT" }
                 elseif ($timeSince.TotalHours -lt 2) { "ACTIVE" }
                 else { "STALE" }

        $color = switch ($status) {
            "RECENT" { "Green" }
            "ACTIVE" { "Yellow" }
            "STALE" { "Gray" }
        }

        Write-Host "`n[$status] $($cp.agent_id) - Task $($cp.task_id)" -ForegroundColor $color
        Write-Host "  Project: $($cp.project)" -ForegroundColor Gray
        Write-Host "  Phase: $($cp.phase)" -ForegroundColor Gray
        Write-Host "  Time: $([math]::Round($timeSince.TotalMinutes, 1)) minutes ago" -ForegroundColor Gray
        Write-Host "  Files: $($cp.files_changed.Count) changed" -ForegroundColor Gray
    }
}

# Clean old checkpoints
function Clean-Checkpoints {
    param([int]$olderThanHours = 24)

    $cutoffTime = (Get-Date).AddHours(-$olderThanHours)

    $checkpoints = Get-ChildItem $checkpointDir -Filter "*.json"
    $removedCount = 0

    foreach ($file in $checkpoints) {
        try {
            $data = Get-Content $file.FullName | ConvertFrom-Json
            $checkpointTime = [DateTime]$data.timestamp

            if ($checkpointTime -lt $cutoffTime) {
                Remove-Item $file.FullName
                $removedCount++
                if ($Verbose) {
                    Write-Host "Removed old checkpoint: $($file.Name)" -ForegroundColor Gray
                }
            }
        } catch {
            # Skip invalid files
        }
    }

    Write-Host "Cleaned $removedCount old checkpoints (older than $olderThanHours hours)" -ForegroundColor Green
}

# Main execution
switch ($Action) {
    "Checkpoint" {
        if (-not $AgentId -or -not $TaskId -or -not $Project -or -not $Phase) {
            Write-Host "Error: AgentId, TaskId, Project, and Phase required for Checkpoint" -ForegroundColor Red
            exit 1
        }
        Create-Checkpoint -agentId $AgentId -taskId $TaskId -project $Project -phase $Phase -metadata $Metadata
    }

    "Recover" {
        if (-not $AgentId -or -not $TaskId) {
            Write-Host "Error: AgentId and TaskId required for Recover" -ForegroundColor Red
            exit 1
        }
        Recover-From-Checkpoint -agentId $AgentId -taskId $TaskId
    }

    "List" {
        List-Checkpoints
    }

    "Clean" {
        Clean-Checkpoints -olderThanHours 24
    }
}
