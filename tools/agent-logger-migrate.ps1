<#
.SYNOPSIS
    Migrate agent activity database to enhanced schema

.DESCRIPTION
    Adds new tables for comprehensive agent coordination:
    - Worktree allocations
    - Resource locks
    - Git operations
    - PR tracking
    - File modifications
    - Tool usage

.EXAMPLE
    .\agent-logger-migrate.ps1
    Migrate database to latest schema
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

if (-not (Test-Path $DbPath)) {
    Write-Host "Database not found. Run agent-logger.ps1 -Action register first." -ForegroundColor Red
    exit 1
}

Write-Host "Agent Activity Database Migration" -ForegroundColor Cyan
Write-Host "==================================`n" -ForegroundColor Cyan

# Check current schema version
$versionCheck = "SELECT name FROM sqlite_master WHERE type='table' AND name='schema_version';" | & $SqlitePath $DbPath

if (-not $versionCheck) {
    Write-Host "Creating schema_version table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration.sql"
    @'
CREATE TABLE IF NOT EXISTS schema_version (
    version INTEGER PRIMARY KEY,
    applied_at TEXT NOT NULL,
    description TEXT
);

INSERT INTO schema_version (version, applied_at, description)
VALUES (1, datetime('now'), 'Initial schema: agents, activity_log, tasks');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Created schema_version table" -ForegroundColor Green
    }
}

# Get current version
$currentVersion = "SELECT COALESCE(MAX(version), 0) FROM schema_version;" | & $SqlitePath $DbPath

Write-Host "Current schema version: $currentVersion`n" -ForegroundColor Cyan

# Migration: Version 2 - Worktree allocations
if ([int]$currentVersion -lt 2) {
    Write-Host "Migration 2: Adding worktree allocations table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v2.sql"
    @'
CREATE TABLE IF NOT EXISTS worktree_allocations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    seat TEXT NOT NULL,
    repo TEXT NOT NULL,
    branch TEXT NOT NULL,
    allocated_at TEXT NOT NULL,
    released_at TEXT,
    status TEXT NOT NULL CHECK(status IN ('active', 'released', 'abandoned')) DEFAULT 'active',
    notes TEXT,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE INDEX IF NOT EXISTS idx_worktree_agent ON worktree_allocations(agent_id);
CREATE INDEX IF NOT EXISTS idx_worktree_seat ON worktree_allocations(seat);
CREATE INDEX IF NOT EXISTS idx_worktree_status ON worktree_allocations(status);

INSERT INTO schema_version (version, applied_at, description)
VALUES (2, datetime('now'), 'Added worktree_allocations table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added worktree_allocations table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add worktree_allocations table" -ForegroundColor Gray
    }
}

# Migration: Version 3 - Resource locks
if ([int]$currentVersion -lt 3) {
    Write-Host "Migration 3: Adding resource locks table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v3.sql"
    @'
CREATE TABLE IF NOT EXISTS resource_locks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    resource_type TEXT NOT NULL,
    resource_path TEXT NOT NULL,
    agent_id TEXT NOT NULL,
    locked_at TEXT NOT NULL,
    released_at TEXT,
    status TEXT NOT NULL CHECK(status IN ('locked', 'released')) DEFAULT 'locked',
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE INDEX IF NOT EXISTS idx_resource_locks_active ON resource_locks(resource_type, resource_path, status);
CREATE INDEX IF NOT EXISTS idx_resource_locks_agent ON resource_locks(agent_id);

INSERT INTO schema_version (version, applied_at, description)
VALUES (3, datetime('now'), 'Added resource_locks table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added resource_locks table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add resource_locks table" -ForegroundColor Gray
    }
}

# Migration: Version 4 - Git operations
if ([int]$currentVersion -lt 4) {
    Write-Host "Migration 4: Adding git operations table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v4.sql"
    @'
CREATE TABLE IF NOT EXISTS git_operations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    operation TEXT NOT NULL,
    repo TEXT NOT NULL,
    branch TEXT NOT NULL,
    commit_sha TEXT,
    message TEXT,
    timestamp TEXT NOT NULL,
    success INTEGER NOT NULL,
    error_message TEXT,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE INDEX IF NOT EXISTS idx_git_ops_agent ON git_operations(agent_id);
CREATE INDEX IF NOT EXISTS idx_git_ops_repo ON git_operations(repo);
CREATE INDEX IF NOT EXISTS idx_git_ops_timestamp ON git_operations(timestamp);

INSERT INTO schema_version (version, applied_at, description)
VALUES (4, datetime('now'), 'Added git_operations table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added git_operations table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add git_operations table" -ForegroundColor Gray
    }
}

# Migration: Version 5 - PR tracking
if ([int]$currentVersion -lt 5) {
    Write-Host "Migration 5: Adding pull requests table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v5.sql"
    @'
CREATE TABLE IF NOT EXISTS pull_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    repo TEXT NOT NULL,
    pr_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    branch TEXT NOT NULL,
    created_at TEXT NOT NULL,
    merged_at TEXT,
    closed_at TEXT,
    status TEXT NOT NULL CHECK(status IN ('open', 'merged', 'closed')) DEFAULT 'open',
    task_id TEXT,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
    FOREIGN KEY (task_id) REFERENCES tasks(task_id)
);

CREATE INDEX IF NOT EXISTS idx_pr_agent ON pull_requests(agent_id);
CREATE INDEX IF NOT EXISTS idx_pr_repo ON pull_requests(repo);
CREATE INDEX IF NOT EXISTS idx_pr_status ON pull_requests(status);
CREATE INDEX IF NOT EXISTS idx_pr_task ON pull_requests(task_id);

INSERT INTO schema_version (version, applied_at, description)
VALUES (5, datetime('now'), 'Added pull_requests table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added pull_requests table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add pull_requests table" -ForegroundColor Gray
    }
}

# Migration: Version 6 - File modifications
if ([int]$currentVersion -lt 6) {
    Write-Host "Migration 6: Adding file modifications table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v6.sql"
    @'
CREATE TABLE IF NOT EXISTS file_modifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    file_path TEXT NOT NULL,
    operation TEXT NOT NULL CHECK(operation IN ('read', 'write', 'edit', 'delete')),
    timestamp TEXT NOT NULL,
    lines_changed INTEGER,
    task_id TEXT,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
    FOREIGN KEY (task_id) REFERENCES tasks(task_id)
);

CREATE INDEX IF NOT EXISTS idx_file_mods_agent ON file_modifications(agent_id);
CREATE INDEX IF NOT EXISTS idx_file_mods_path ON file_modifications(file_path);
CREATE INDEX IF NOT EXISTS idx_file_mods_timestamp ON file_modifications(timestamp);

INSERT INTO schema_version (version, applied_at, description)
VALUES (6, datetime('now'), 'Added file_modifications table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added file_modifications table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add file_modifications table" -ForegroundColor Gray
    }
}

# Migration: Version 7 - Tool usage
if ([int]$currentVersion -lt 7) {
    Write-Host "Migration 7: Adding tool usage table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v7.sql"
    @'
CREATE TABLE IF NOT EXISTS tool_usage (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    tool_name TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    duration_ms INTEGER,
    success INTEGER NOT NULL,
    error_message TEXT,
    metadata TEXT DEFAULT '{}',
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE INDEX IF NOT EXISTS idx_tool_usage_agent ON tool_usage(agent_id);
CREATE INDEX IF NOT EXISTS idx_tool_usage_tool ON tool_usage(tool_name);
CREATE INDEX IF NOT EXISTS idx_tool_usage_timestamp ON tool_usage(timestamp);

INSERT INTO schema_version (version, applied_at, description)
VALUES (7, datetime('now'), 'Added tool_usage table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added tool_usage table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add tool_usage table" -ForegroundColor Gray
    }
}

# Show final version
$finalVersion = "SELECT MAX(version) FROM schema_version;" | & $SqlitePath $DbPath

Write-Host "`nMigration complete!" -ForegroundColor Green
Write-Host "Schema version: $currentVersion -> $finalVersion`n" -ForegroundColor Cyan

if (-not $DryRun) {
    # Show table count
    $tableCount = "SELECT COUNT(*) FROM sqlite_master WHERE type='table';" | & $SqlitePath $DbPath
    Write-Host "Total tables: $tableCount" -ForegroundColor Gray

    # Show all tables
    Write-Host "`nDatabase tables:" -ForegroundColor Cyan
    $tables = "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;" | & $SqlitePath $DbPath
    $tables -split "`n" | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor White
    }
}

Write-Host ""
