<#
.SYNOPSIS
    Create system checkpoint for rollback

.DESCRIPTION
    Snapshots critical agent system state for safe rollback:
    - Database (agent-activity.db)
    - Worktree pool
    - Configuration files
    - Tool hashes

    Enables safe experimentation - rollback if things go wrong.

.PARAMETER Tag
    Checkpoint identifier (e.g., "before-phase4", "before-ml-features")

.PARAMETER Description
    Optional description of what you're about to change

.EXAMPLE
    .\agent-checkpoint.ps1 -Tag "before-phase4" -Description "Adding ML features"

.EXAMPLE
    .\agent-checkpoint.ps1 -Tag "working-state"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Tag,

    [Parameter(Mandatory=$false)]
    [string]$Description = ""
)

$ErrorActionPreference = 'Stop'

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$checkpointDir = "C:\scripts\_machine\checkpoints\$Tag-$timestamp"
$manifestPath = "$checkpointDir\manifest.json"

Write-Host "`n=== Creating System Checkpoint ===" -ForegroundColor Cyan
Write-Host ""

try {
    # Create checkpoint directory
    Write-Host "[1/6] Creating checkpoint directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $checkpointDir -Force | Out-Null
    Write-Host "  Created: $checkpointDir" -ForegroundColor Gray

    # Copy database
    Write-Host "[2/6] Snapshotting database..." -ForegroundColor Yellow
    $dbPath = "C:\scripts\_machine\agent-activity.db"
    if (Test-Path $dbPath) {
        Copy-Item $dbPath "$checkpointDir\agent-activity.db"
        $dbSize = (Get-Item $dbPath).Length / 1KB
        Write-Host "  Database: $([math]::Round($dbSize, 2)) KB" -ForegroundColor Gray
    } else {
        Write-Host "  Warning: Database not found" -ForegroundColor Yellow
    }

    # Copy worktree pool
    Write-Host "[3/6] Snapshotting worktree pool..." -ForegroundColor Yellow
    $poolPath = "C:\scripts\_machine\worktrees.pool.md"
    if (Test-Path $poolPath) {
        Copy-Item $poolPath "$checkpointDir\worktrees.pool.md"
        Write-Host "  Worktree pool: Captured" -ForegroundColor Gray
    }

    # Copy critical config files
    Write-Host "[4/6] Snapshotting configuration..." -ForegroundColor Yellow
    $configFiles = @(
        "C:\scripts\CLAUDE.md",
        "C:\scripts\_machine\PERSONAL_INSIGHTS.md",
        "C:\scripts\_machine\reflection.log.md"
    )

    foreach ($file in $configFiles) {
        if (Test-Path $file) {
            $fileName = Split-Path $file -Leaf
            Copy-Item $file "$checkpointDir\$fileName"
        }
    }
    Write-Host "  Config files: 3 captured" -ForegroundColor Gray

    # Calculate tool hashes
    Write-Host "[5/6] Calculating tool hashes..." -ForegroundColor Yellow
    $toolHashes = @{}
    Get-ChildItem "C:\scripts\tools\*.ps1" | ForEach-Object {
        $hash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
        $toolHashes[$_.Name] = $hash
    }
    Write-Host "  Tool count: $($toolHashes.Count)" -ForegroundColor Gray

    # Create manifest
    Write-Host "[6/6] Writing manifest..." -ForegroundColor Yellow
    $manifest = @{
        tag = $Tag
        timestamp = $timestamp
        created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        description = $Description
        machine = $env:COMPUTERNAME
        user = $env:USERNAME
        files = @{
            database = "agent-activity.db"
            pool = "worktrees.pool.md"
            claude_md = "CLAUDE.md"
            insights = "PERSONAL_INSIGHTS.md"
            reflection = "reflection.log.md"
        }
        tool_hashes = $toolHashes
        tool_count = $toolHashes.Count
    }

    $manifest | ConvertTo-Json -Depth 10 | Set-Content $manifestPath -Encoding UTF8
    Write-Host "  Manifest: Created" -ForegroundColor Gray

    Write-Host ""
    Write-Host "Checkpoint created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Tag:         $Tag" -ForegroundColor Cyan
    Write-Host "  Timestamp:   $timestamp" -ForegroundColor Cyan
    Write-Host "  Location:    $checkpointDir" -ForegroundColor Gray
    if ($Description) {
        Write-Host "  Description: $Description" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "To rollback: .\agent-rollback.ps1 -Tag $Tag-$timestamp" -ForegroundColor Yellow
    Write-Host ""

    # Log checkpoint to database
    if (Test-Path $dbPath) {
        $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        $agentId = if (Test-Path "C:\scripts\_machine\.current_agent_id") {
            Get-Content "C:\scripts\_machine\.current_agent_id" -Raw | ForEach-Object { $_.Trim() }
        } else { "system" }

        $sql = @"
INSERT INTO activity_log (agent_id, timestamp, action_type, message, metadata)
VALUES ('$agentId', '$now', 'checkpoint_created', 'System checkpoint: $Tag', '{\"tag\":\"$Tag\",\"timestamp\":\"$timestamp\"}');
"@

        $sql | & "C:\scripts\_machine\sqlite3.exe" $dbPath 2>&1 | Out-Null
    }

} catch {
    Write-Host ""
    Write-Host "Checkpoint failed: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
