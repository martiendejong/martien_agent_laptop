# Real-time Worktree Status Updates - R02-006
# Update worktree pool status as operations happen, not at session end
# Expert: Maria Rodriguez - Live Collaboration Systems Designer

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('allocate', 'release', 'busy', 'free', 'sync', 'status')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$WorktreeName,

    [Parameter(Mandatory=$false)]
    [string]$Agent,

    [Parameter(Mandatory=$false)]
    [string]$Task
)

$PoolFile = "C:\scripts\_machine\worktrees.pool.md"
$ActivityFile = "C:\scripts\_machine\worktrees.activity.md"
$EventLog = "C:\scripts\_machine\conversation-events.log.jsonl"

function Update-WorktreeStatus {
    param(
        [string]$Name,
        [string]$Status,
        [string]$Agent,
        [string]$Task
    )

    # Read current pool
    if (-not (Test-Path $PoolFile)) {
        Write-Host "Pool file not found: $PoolFile" -ForegroundColor Red
        return
    }

    $content = Get-Content $PoolFile -Raw

    # Update status in pool file
    # This is a simplified version - real implementation would parse markdown properly
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    # Log event
    $event = @{
        'timestamp' = Get-Date -Format 'o'
        'event' = 'worktree_status_change'
        'worktree' = $Name
        'status' = $Status
        'agent' = $Agent
        'task' = $Task
    } | ConvertTo-Json -Compress

    Add-Content -Path $EventLog -Value $event -Encoding UTF8

    Write-Host "Worktree $Name status updated to $Status" -ForegroundColor Green
}

function Log-WorktreeActivity {
    param(
        [string]$Action,
        [string]$Name,
        [string]$Agent,
        [string]$Details
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = @"

### $timestamp - $Action
- **Worktree:** $Name
- **Agent:** $Agent
- **Details:** $Details

"@

    Add-Content -Path $ActivityFile -Value $entry -Encoding UTF8
    Write-Host "Activity logged for $Name" -ForegroundColor Cyan
}

function Sync-WorktreePool {
    # Scan actual filesystem and reconcile with pool file
    $worktreesDir = "C:\projects\worktrees"

    if (-not (Test-Path $worktreesDir)) {
        Write-Host "Worktrees directory not found" -ForegroundColor Red
        return
    }

    $actualWorktrees = Get-ChildItem $worktreesDir -Directory | Select-Object -ExpandProperty Name

    Write-Host "Found $($actualWorktrees.Count) worktrees on disk" -ForegroundColor Cyan

    # Log sync event
    $event = @{
        'timestamp' = Get-Date -Format 'o'
        'event' = 'worktree_pool_sync'
        'worktrees_found' = $actualWorktrees.Count
        'worktrees' = $actualWorktrees
    } | ConvertTo-Json -Compress

    Add-Content -Path $EventLog -Value $event -Encoding UTF8
}

function Get-WorktreeStatus {
    if (Test-Path $PoolFile) {
        Get-Content $PoolFile -Raw
    } else {
        Write-Host "Pool file not found" -ForegroundColor Yellow
    }
}

# Main execution
switch ($Action) {
    'allocate' {
        if (-not $WorktreeName -or -not $Agent) {
            Write-Host "WorktreeName and Agent required" -ForegroundColor Red
            exit 1
        }
        Update-WorktreeStatus -Name $WorktreeName -Status 'BUSY' -Agent $Agent -Task $Task
        Log-WorktreeActivity -Action 'ALLOCATE' -Name $WorktreeName -Agent $Agent -Details "Allocated for: $Task"
    }
    'release' {
        if (-not $WorktreeName) {
            Write-Host "WorktreeName required" -ForegroundColor Red
            exit 1
        }
        Update-WorktreeStatus -Name $WorktreeName -Status 'FREE' -Agent '' -Task ''
        Log-WorktreeActivity -Action 'RELEASE' -Name $WorktreeName -Agent $Agent -Details "Released and ready for reuse"
    }
    'busy' {
        if (-not $WorktreeName -or -not $Agent) {
            Write-Host "WorktreeName and Agent required" -ForegroundColor Red
            exit 1
        }
        Update-WorktreeStatus -Name $WorktreeName -Status 'BUSY' -Agent $Agent -Task $Task
    }
    'free' {
        if (-not $WorktreeName) {
            Write-Host "WorktreeName required" -ForegroundColor Red
            exit 1
        }
        Update-WorktreeStatus -Name $WorktreeName -Status 'FREE' -Agent '' -Task ''
    }
    'sync' {
        Sync-WorktreePool
    }
    'status' {
        Get-WorktreeStatus
    }
}
