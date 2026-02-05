<#
.SYNOPSIS
    Phase 3 migrations for agent activity database

.DESCRIPTION
    Adds advanced tracking capabilities:
    - Agent messages (agent-to-agent communication)
    - Session metadata (complete session tracking)
    - Error tracking (structured error logging)
    - Performance metrics (task duration, bottlenecks)
    - Learnings (knowledge capture)

.EXAMPLE
    .\agent-logger-migrate-phase3.ps1
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

Write-Host "Agent Activity Database - Phase 3 Migration" -ForegroundColor Cyan
Write-Host "==========================================`n" -ForegroundColor Cyan

# Get current version
$currentVersion = "SELECT COALESCE(MAX(version), 0) FROM schema_version;" | & $SqlitePath $DbPath

Write-Host "Current schema version: $currentVersion`n" -ForegroundColor Cyan

# Migration: Version 8 - Agent messages
if ([int]$currentVersion -lt 8) {
    Write-Host "Migration 8: Adding agent messages table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v8.sql"
    @'
CREATE TABLE IF NOT EXISTS agent_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_agent_id TEXT NOT NULL,
    to_agent_id TEXT,
    message TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    read INTEGER DEFAULT 0,
    priority INTEGER DEFAULT 5,
    message_type TEXT DEFAULT 'info',
    metadata TEXT DEFAULT '{}',
    FOREIGN KEY (from_agent_id) REFERENCES agents(agent_id),
    FOREIGN KEY (to_agent_id) REFERENCES agents(agent_id)
);

CREATE INDEX IF NOT EXISTS idx_messages_to ON agent_messages(to_agent_id);
CREATE INDEX IF NOT EXISTS idx_messages_from ON agent_messages(from_agent_id);
CREATE INDEX IF NOT EXISTS idx_messages_read ON agent_messages(read);

INSERT INTO schema_version (version, applied_at, description)
VALUES (8, datetime('now'), 'Added agent_messages table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added agent_messages table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add agent_messages table" -ForegroundColor Gray
    }
}

# Migration: Version 9 - Session metadata
if ([int]$currentVersion -lt 9) {
    Write-Host "Migration 9: Adding sessions table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v9.sql"
    @'
CREATE TABLE IF NOT EXISTS sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL UNIQUE,
    agent_id TEXT NOT NULL,
    started_at TEXT NOT NULL,
    ended_at TEXT,
    duration_seconds INTEGER,
    tasks_completed INTEGER DEFAULT 0,
    tasks_failed INTEGER DEFAULT 0,
    exit_reason TEXT,
    metadata TEXT DEFAULT '{}',
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE INDEX IF NOT EXISTS idx_sessions_agent ON sessions(agent_id);
CREATE INDEX IF NOT EXISTS idx_sessions_started ON sessions(started_at);

INSERT INTO schema_version (version, applied_at, description)
VALUES (9, datetime('now'), 'Added sessions table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added sessions table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add sessions table" -ForegroundColor Gray
    }
}

# Migration: Version 10 - Error tracking
if ([int]$currentVersion -lt 10) {
    Write-Host "Migration 10: Adding errors table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v10.sql"
    @'
CREATE TABLE IF NOT EXISTS errors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    error_type TEXT NOT NULL,
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    file_path TEXT,
    line_number INTEGER,
    severity TEXT NOT NULL CHECK(severity IN ('warning', 'error', 'critical')),
    resolved INTEGER DEFAULT 0,
    task_id TEXT,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
    FOREIGN KEY (task_id) REFERENCES tasks(task_id)
);

CREATE INDEX IF NOT EXISTS idx_errors_agent ON errors(agent_id);
CREATE INDEX IF NOT EXISTS idx_errors_severity ON errors(severity);
CREATE INDEX IF NOT EXISTS idx_errors_resolved ON errors(resolved);
CREATE INDEX IF NOT EXISTS idx_errors_timestamp ON errors(timestamp);

INSERT INTO schema_version (version, applied_at, description)
VALUES (10, datetime('now'), 'Added errors table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added errors table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add errors table" -ForegroundColor Gray
    }
}

# Migration: Version 11 - Performance metrics
if ([int]$currentVersion -lt 11) {
    Write-Host "Migration 11: Adding metrics table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v11.sql"
    @'
CREATE TABLE IF NOT EXISTS metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    metric_name TEXT NOT NULL,
    metric_value REAL NOT NULL,
    unit TEXT,
    timestamp TEXT NOT NULL,
    context TEXT DEFAULT '{}',
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE INDEX IF NOT EXISTS idx_metrics_agent ON metrics(agent_id);
CREATE INDEX IF NOT EXISTS idx_metrics_name ON metrics(metric_name);
CREATE INDEX IF NOT EXISTS idx_metrics_timestamp ON metrics(timestamp);

INSERT INTO schema_version (version, applied_at, description)
VALUES (11, datetime('now'), 'Added metrics table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added metrics table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add metrics table" -ForegroundColor Gray
    }
}

# Migration: Version 12 - Learnings
if ([int]$currentVersion -lt 12) {
    Write-Host "Migration 12: Adding learnings table..." -ForegroundColor Yellow

    $schemaFile = "$env:TEMP\migration_v12.sql"
    @'
CREATE TABLE IF NOT EXISTS learnings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    context TEXT DEFAULT '{}',
    usefulness_score INTEGER DEFAULT 5,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE INDEX IF NOT EXISTS idx_learnings_agent ON learnings(agent_id);
CREATE INDEX IF NOT EXISTS idx_learnings_category ON learnings(category);
CREATE INDEX IF NOT EXISTS idx_learnings_timestamp ON learnings(timestamp);

INSERT INTO schema_version (version, applied_at, description)
VALUES (12, datetime('now'), 'Added learnings table');
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

    if (-not $DryRun) {
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "  Added learnings table" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would add learnings table" -ForegroundColor Gray
    }
}

# Show final version
$finalVersion = "SELECT MAX(version) FROM schema_version;" | & $SqlitePath $DbPath

Write-Host "`nPhase 3 Migration complete!" -ForegroundColor Green
Write-Host "Schema version: $currentVersion -> $finalVersion`n" -ForegroundColor Cyan

if (-not $DryRun) {
    # Show table count
    $tableCount = "SELECT COUNT(*) FROM sqlite_master WHERE type='table';" | & $SqlitePath $DbPath
    Write-Host "Total tables: $tableCount" -ForegroundColor Gray

    # Show new tables
    Write-Host "`nPhase 3 tables:" -ForegroundColor Cyan
    $tables = @('agent_messages', 'sessions', 'errors', 'metrics', 'learnings')
    foreach ($table in $tables) {
        $exists = "SELECT name FROM sqlite_master WHERE type='table' AND name='$table';" | & $SqlitePath $DbPath
        if ($exists) {
            Write-Host "  + $table" -ForegroundColor Green
        }
    }
}

Write-Host ""
