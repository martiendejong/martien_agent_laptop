<#
.SYNOPSIS
    Phase 4 Database Migration - Advanced Features

.DESCRIPTION
    Migrates database from v12 to v20 with tables for:
    - v13: action_sequences (proactive pattern detection)
    - v14: temporal_patterns (time-aware context)
    - v15: impact_metrics (value tracking)
    - v16: experiments (self-optimization)
    - v17: agent_profiles (personality/specialization)
    - v18: shared_knowledge (inter-agent learning)
    - v19: session_context (cross-session memory)
    - v20: checkpoints (rollback tracking)

.EXAMPLE
    .\agent-logger-migrate-phase4.ps1
#>

$ErrorActionPreference = 'Stop'

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

function Get-SchemaVersion {
    $version = Invoke-Sql "SELECT version FROM schema_version ORDER BY version DESC LIMIT 1;"
    if ($version) {
        return [int]$version
    }
    return 0
}

Write-Host "`n=== Phase 4 Database Migration ===" -ForegroundColor Cyan
Write-Host ""

# Check current version
$currentVersion = Get-SchemaVersion
Write-Host "Current schema version: v$currentVersion" -ForegroundColor White

if ($currentVersion -lt 12) {
    Write-Host "Error: Phase 4 requires Phase 3 (v12). Run agent-logger-migrate-phase3.ps1 first." -ForegroundColor Red
    exit 1
}

if ($currentVersion -ge 20) {
    Write-Host "Database already at v20 or higher. No migration needed." -ForegroundColor Yellow
    exit 0
}

# Backup database
Write-Host "Creating backup..." -ForegroundColor Yellow
$backupPath = "$DbPath.phase4-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $DbPath $backupPath
Write-Host "  Backup: $backupPath" -ForegroundColor Gray
Write-Host ""

try {
    # v13: action_sequences (proactive pattern detection)
    if ($currentVersion -lt 13) {
        Write-Host "[v13] Creating action_sequences table..." -ForegroundColor Yellow

        $sql = @"
CREATE TABLE action_sequences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    sequence_hash TEXT NOT NULL,
    sequence_json TEXT NOT NULL,
    count INTEGER DEFAULT 1,
    last_occurrence TEXT NOT NULL,
    first_occurrence TEXT NOT NULL,
    suggested_tool_name TEXT,
    tool_created INTEGER DEFAULT 0,
    UNIQUE(agent_id, sequence_hash)
);

CREATE INDEX idx_sequence_count ON action_sequences(count DESC);
CREATE INDEX idx_sequence_last ON action_sequences(last_occurrence DESC);

INSERT INTO schema_version (version, description, applied_at)
VALUES (13, 'action_sequences for proactive pattern detection', datetime('now'));
"@

        Invoke-Sql -Sql $sql
        Write-Host "  Table created: action_sequences" -ForegroundColor Green
    }

    # v14: temporal_patterns (time-aware context)
    if ($currentVersion -lt 14) {
        Write-Host "[v14] Creating temporal_patterns table..." -ForegroundColor Yellow

        $sql = @"
CREATE TABLE temporal_patterns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    day_of_week INTEGER CHECK(day_of_week BETWEEN 0 AND 6),
    hour_of_day INTEGER CHECK(hour_of_day BETWEEN 0 AND 23),
    pattern TEXT NOT NULL,
    pattern_type TEXT NOT NULL,
    confidence REAL DEFAULT 0.5 CHECK(confidence BETWEEN 0 AND 1),
    occurrences INTEGER DEFAULT 1,
    last_seen TEXT NOT NULL,
    metadata TEXT DEFAULT '{}'
);

CREATE INDEX idx_temporal_dow ON temporal_patterns(day_of_week);
CREATE INDEX idx_temporal_hour ON temporal_patterns(hour_of_day);
CREATE INDEX idx_temporal_confidence ON temporal_patterns(confidence DESC);

INSERT INTO schema_version (version, description, applied_at)
VALUES (14, 'temporal_patterns for time-aware context', datetime('now'));
"@

        Invoke-Sql -Sql $sql
        Write-Host "  Table created: temporal_patterns" -ForegroundColor Green
    }

    # v15: impact_metrics (value tracking)
    if ($currentVersion -lt 15) {
        Write-Host "[v15] Creating impact_metrics table..." -ForegroundColor Yellow

        $sql = @"
CREATE TABLE impact_metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    week_start TEXT NOT NULL,
    week_end TEXT NOT NULL,
    bugs_prevented INTEGER DEFAULT 0,
    time_saved_minutes INTEGER DEFAULT 0,
    prs_created INTEGER DEFAULT 0,
    prs_merged INTEGER DEFAULT 0,
    tools_created INTEGER DEFAULT 0,
    code_quality_delta REAL DEFAULT 0.0,
    learnings_captured INTEGER DEFAULT 0,
    calculated_at TEXT NOT NULL,
    UNIQUE(week_start)
);

CREATE INDEX idx_impact_week ON impact_metrics(week_start DESC);

INSERT INTO schema_version (version, description, applied_at)
VALUES (15, 'impact_metrics for value tracking', datetime('now'));
"@

        Invoke-Sql -Sql $sql
        Write-Host "  Table created: impact_metrics" -ForegroundColor Green
    }

    # v16: experiments (self-optimization)
    if ($currentVersion -lt 16) {
        Write-Host "[v16] Creating experiments table..." -ForegroundColor Yellow

        $sql = @"
CREATE TABLE experiments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    experiment_name TEXT NOT NULL,
    hypothesis TEXT NOT NULL,
    approach_a TEXT NOT NULL,
    approach_b TEXT NOT NULL,
    started_at TEXT NOT NULL,
    ended_at TEXT,
    status TEXT CHECK(status IN ('running', 'completed', 'cancelled')) DEFAULT 'running',
    a_success_count INTEGER DEFAULT 0,
    a_failure_count INTEGER DEFAULT 0,
    a_avg_duration REAL DEFAULT 0.0,
    b_success_count INTEGER DEFAULT 0,
    b_failure_count INTEGER DEFAULT 0,
    b_avg_duration REAL DEFAULT 0.0,
    winner TEXT,
    conclusion TEXT
);

CREATE INDEX idx_experiments_status ON experiments(status);

INSERT INTO schema_version (version, description, applied_at)
VALUES (16, 'experiments for self-optimization', datetime('now'));
"@

        Invoke-Sql -Sql $sql
        Write-Host "  Table created: experiments" -ForegroundColor Green
    }

    # v17: agent_profiles (personality/specialization)
    if ($currentVersion -lt 17) {
        Write-Host "[v17] Creating agent_profiles table..." -ForegroundColor Yellow

        $sql = @"
CREATE TABLE agent_profiles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL UNIQUE,
    specialization TEXT,
    strengths TEXT,
    weaknesses TEXT,
    preferred_tools TEXT,
    learning_focus TEXT,
    personality_traits TEXT DEFAULT '{}',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

INSERT INTO schema_version (version, description, applied_at)
VALUES (17, 'agent_profiles for specialization', datetime('now'));
"@

        Invoke-Sql -Sql $sql
        Write-Host "  Table created: agent_profiles" -ForegroundColor Green
    }

    # v18: shared_knowledge (inter-agent learning)
    if ($currentVersion -lt 18) {
        Write-Host "[v18] Creating shared_knowledge table..." -ForegroundColor Yellow

        $sql = @"
CREATE TABLE shared_knowledge (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_agent_id TEXT NOT NULL,
    knowledge_type TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    tags TEXT,
    confidence INTEGER DEFAULT 5 CHECK(confidence BETWEEN 1 AND 10),
    shared_at TEXT NOT NULL,
    imported_by TEXT,
    import_count INTEGER DEFAULT 0
);

CREATE INDEX idx_knowledge_type ON shared_knowledge(knowledge_type);
CREATE INDEX idx_knowledge_confidence ON shared_knowledge(confidence DESC);

INSERT INTO schema_version (version, description, applied_at)
VALUES (18, 'shared_knowledge for inter-agent learning', datetime('now'));
"@

        Invoke-Sql -Sql $sql
        Write-Host "  Table created: shared_knowledge" -ForegroundColor Green
    }

    # v19: session_context (cross-session memory)
    if ($currentVersion -lt 19) {
        Write-Host "[v19] Creating session_context table..." -ForegroundColor Yellow

        $sql = @"
CREATE TABLE session_context (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    context_key TEXT NOT NULL,
    context_value TEXT NOT NULL,
    context_type TEXT DEFAULT 'string',
    emotional_state TEXT,
    why_captured TEXT,
    timestamp TEXT NOT NULL,
    UNIQUE(session_id, context_key)
);

CREATE INDEX idx_session_ctx ON session_context(session_id);

INSERT INTO schema_version (version, description, applied_at)
VALUES (19, 'session_context for cross-session memory', datetime('now'));
"@

        Invoke-Sql -Sql $sql
        Write-Host "  Table created: session_context" -ForegroundColor Green
    }

    # v20: checkpoints (rollback tracking)
    if ($currentVersion -lt 20) {
        Write-Host "[v20] Creating checkpoints table..." -ForegroundColor Yellow

        $sql = @"
CREATE TABLE checkpoints (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tag TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    description TEXT,
    location TEXT NOT NULL,
    tool_count INTEGER,
    created_by TEXT NOT NULL,
    created_at TEXT NOT NULL,
    UNIQUE(tag, timestamp)
);

CREATE INDEX idx_checkpoints_created ON checkpoints(created_at DESC);

INSERT INTO schema_version (version, description, applied_at)
VALUES (20, 'checkpoints for rollback tracking', datetime('now'));
"@

        Invoke-Sql -Sql $sql
        Write-Host "  Table created: checkpoints" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Phase 4 migration complete! (v$currentVersion -> v20)" -ForegroundColor Green
    Write-Host ""
    Write-Host "New tables:" -ForegroundColor Cyan
    Write-Host "  - action_sequences (v13)" -ForegroundColor White
    Write-Host "  - temporal_patterns (v14)" -ForegroundColor White
    Write-Host "  - impact_metrics (v15)" -ForegroundColor White
    Write-Host "  - experiments (v16)" -ForegroundColor White
    Write-Host "  - agent_profiles (v17)" -ForegroundColor White
    Write-Host "  - shared_knowledge (v18)" -ForegroundColor White
    Write-Host "  - session_context (v19)" -ForegroundColor White
    Write-Host "  - checkpoints (v20)" -ForegroundColor White
    Write-Host ""
    Write-Host "Total tables: 24" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "Migration failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Restoring from backup..." -ForegroundColor Yellow
    Copy-Item $backupPath $DbPath -Force
    Write-Host "Database restored from backup." -ForegroundColor Green
    Write-Host ""
    exit 1
}
