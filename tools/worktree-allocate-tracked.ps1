<#
.SYNOPSIS
    Worktree allocator with integrated SQLite tracking

.DESCRIPTION
    Wrapper around worktree-allocate.ps1 that automatically:
    - Checks for conflicts in SQLite database
    - Logs allocation to database
    - Sends messages to other agents if needed
    - Tracks resource locks

.PARAMETER Seat
    Agent seat to allocate (agent-001, agent-002, etc)

.PARAMETER Repo
    Repository name (client-manager, hazina, etc)

.PARAMETER Branch
    Branch name to checkout

.PARAMETER Paired
    Allocate paired worktrees (client-manager + hazina)

.EXAMPLE
    .\worktree-allocate-tracked.ps1 -Seat agent-003 -Repo client-manager -Branch feature/oauth

.EXAMPLE
    .\worktree-allocate-tracked.ps1 -Seat agent-003 -Repo client-manager -Branch feature/oauth -Paired
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Seat,

    [Parameter(Mandatory=$true)]
    [string]$Repo,

    [Parameter(Mandatory=$true)]
    [string]$Branch,

    [Parameter(Mandatory=$false)]
    [switch]$Paired
)

$ErrorActionPreference = 'Stop'

Write-Host "`n=== Tracked Worktree Allocation ===" -ForegroundColor Cyan
Write-Host ""

try {
    # Step 1: Check for conflicts in database
    Write-Host "[1/5] Checking for conflicts in database..." -ForegroundColor Yellow

    & "C:\scripts\tools\agent-logger-enhanced.ps1" -Action allocate_worktree `
        -Seat $Seat `
        -Repo $Repo `
        -Branch $Branch

    # Step 2: Run original worktree allocation
    Write-Host "[2/5] Allocating physical worktree..." -ForegroundColor Yellow

    if ($Paired) {
        & "C:\scripts\tools\worktree-allocate.ps1" -Seat $Seat -Repo $Repo -Branch $Branch -Paired
    } else {
        & "C:\scripts\tools\worktree-allocate.ps1" -Seat $Seat -Repo $Repo -Branch $Branch
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Worktree allocation failed"
    }

    # Step 3: Lock the repository to prevent conflicts
    Write-Host "[3/5] Locking repository..." -ForegroundColor Yellow

    & "C:\scripts\tools\agent-logger-enhanced.ps1" -Action lock_resource `
        -ResourceType repository `
        -ResourcePath "$Repo/$Branch"

    # Step 4: Send notification to other agents
    Write-Host "[4/5] Notifying other agents..." -ForegroundColor Yellow

    $agentId = if (Test-Path "C:\scripts\_machine\.current_agent_id") {
        Get-Content "C:\scripts\_machine\.current_agent_id" -Raw | ForEach-Object { $_.Trim() }
    } else { "unknown" }

    # Broadcast message (to_agent_id = NULL means broadcast)
    $DbPath = "C:\scripts\_machine\agent-activity.db"
    $SqlitePath = "C:\scripts\_machine\sqlite3.exe"
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    $sql = @"
INSERT INTO agent_messages (from_agent_id, to_agent_id, message, timestamp, priority, message_type)
VALUES ('$agentId', NULL, 'Worktree allocated: $Seat on $Repo/$Branch', '$now', 5, 'info');
"@

    $sql | & $SqlitePath $DbPath

    # Step 5: Log metrics
    Write-Host "[5/5] Logging metrics..." -ForegroundColor Yellow

    $sql = @"
INSERT INTO metrics (agent_id, metric_name, metric_value, unit, timestamp)
VALUES ('$agentId', 'worktree_allocation_count', 1, 'count', '$now');
"@

    $sql | & $SqlitePath $DbPath

    Write-Host ""
    Write-Host "Worktree allocation complete and tracked!" -ForegroundColor Green
    Write-Host "  Seat: $Seat" -ForegroundColor Cyan
    Write-Host "  Repo: $Repo" -ForegroundColor Cyan
    Write-Host "  Branch: $Branch" -ForegroundColor Cyan
    Write-Host "  Path: C:\Projects\worker-agents\$Seat\$Repo" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "Allocation failed: $_" -ForegroundColor Red

    # Log error to database
    $agentId = if (Test-Path "C:\scripts\_machine\.current_agent_id") {
        Get-Content "C:\scripts\_machine\.current_agent_id" -Raw | ForEach-Object { $_.Trim() }
    } else { "unknown" }

    $DbPath = "C:\scripts\_machine\agent-activity.db"
    $SqlitePath = "C:\scripts\_machine\sqlite3.exe"
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $errorMsg = $_.Exception.Message -replace "'", "''"

    $sql = @"
INSERT INTO errors (agent_id, timestamp, error_type, error_message, severity)
VALUES ('$agentId', '$now', 'worktree_allocation', '$errorMsg', 'error');
"@

    $sql | & $SqlitePath $DbPath 2>&1 | Out-Null

    exit 1
}
