# work-tracking-init-db.ps1
# Initialize SQLite database for work tracking analytics

param(
    [string]$DatabasePath = "C:\scripts\_machine\work-state.db"
)

# Check if PSSQLite module is available
if (-not (Get-Module -ListAvailable -Name PSSQLite)) {
    Write-Host "Installing PSSQLite module..." -ForegroundColor Yellow
    Install-Module -Name PSSQLite -Scope CurrentUser -Force
}

Import-Module PSSQLite

Write-Host "Initializing work tracking database: $DatabasePath" -ForegroundColor Cyan

# Create database and tables
$schema = @"
-- Work tracking database schema

-- Events table (source of truth, append-only)
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent TEXT NOT NULL,
    event_type TEXT NOT NULL,
    event_data TEXT NOT NULL,  -- JSON blob
    timestamp TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_events_agent ON events(agent);
CREATE INDEX IF NOT EXISTS idx_events_type ON events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp DESC);

-- Work sessions table (derived from events, for analytics)
CREATE TABLE IF NOT EXISTS work_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent TEXT NOT NULL,
    clickup_task TEXT,
    pr_number TEXT,
    branch TEXT,
    objective TEXT,
    repository TEXT,
    worktree_path TEXT,
    started_at TEXT NOT NULL,
    completed_at TEXT,
    updated_at TEXT,
    outcome TEXT,
    success INTEGER DEFAULT 1,  -- 1 = success, 0 = failed/blocked
    duration_seconds REAL,
    created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_sessions_agent ON work_sessions(agent);
CREATE INDEX IF NOT EXISTS idx_sessions_clickup ON work_sessions(clickup_task);
CREATE INDEX IF NOT EXISTS idx_sessions_pr ON work_sessions(pr_number);
CREATE INDEX IF NOT EXISTS idx_sessions_started ON work_sessions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_completed ON work_sessions(completed_at DESC);

-- Agent productivity metrics (aggregated view)
CREATE TABLE IF NOT EXISTS agent_metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent TEXT NOT NULL,
    date TEXT NOT NULL,  -- YYYY-MM-DD
    total_tasks INTEGER DEFAULT 0,
    completed_tasks INTEGER DEFAULT 0,
    prs_created INTEGER DEFAULT 0,
    total_duration_seconds REAL DEFAULT 0,
    avg_duration_seconds REAL DEFAULT 0,
    success_rate REAL DEFAULT 0,  -- Percentage
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    UNIQUE(agent, date)
);

CREATE INDEX IF NOT EXISTS idx_metrics_agent_date ON agent_metrics(agent, date DESC);

-- Daily summaries
CREATE TABLE IF NOT EXISTS daily_summaries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL UNIQUE,
    total_agents INTEGER DEFAULT 0,
    total_tasks INTEGER DEFAULT 0,
    total_completions INTEGER DEFAULT 0,
    total_prs INTEGER DEFAULT 0,
    avg_duration_seconds REAL DEFAULT 0,
    success_rate REAL DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_summaries_date ON daily_summaries(date DESC);

-- Views for common queries

-- Active work view
CREATE VIEW IF NOT EXISTS v_active_work AS
SELECT
    ws.agent,
    ws.clickup_task,
    ws.pr_number,
    ws.branch,
    ws.objective,
    ws.repository,
    ws.started_at,
    ws.updated_at,
    CAST((julianday('now') - julianday(ws.started_at)) * 86400 AS INTEGER) as elapsed_seconds
FROM work_sessions ws
WHERE ws.completed_at IS NULL
ORDER BY ws.started_at DESC;

-- Completed work today view
CREATE VIEW IF NOT EXISTS v_completed_today AS
SELECT
    ws.agent,
    ws.clickup_task,
    ws.pr_number,
    ws.objective,
    ws.completed_at,
    ws.duration_seconds,
    ws.success
FROM work_sessions ws
WHERE date(ws.completed_at) = date('now')
ORDER BY ws.completed_at DESC;

-- Agent productivity view
CREATE VIEW IF NOT EXISTS v_agent_productivity AS
SELECT
    agent,
    COUNT(*) as total_sessions,
    SUM(CASE WHEN completed_at IS NOT NULL THEN 1 ELSE 0 END) as completed_sessions,
    SUM(CASE WHEN pr_number IS NOT NULL THEN 1 ELSE 0 END) as prs_created,
    AVG(duration_seconds) as avg_duration_seconds,
    SUM(duration_seconds) as total_duration_seconds,
    SUM(CASE WHEN success = 1 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN completed_at IS NOT NULL THEN 1 ELSE 0 END), 0) as success_rate
FROM work_sessions
GROUP BY agent;

-- Note: Trigger removed due to SQLite version compatibility
-- Daily summaries can be updated via scheduled job instead

-- Metadata table
CREATE TABLE IF NOT EXISTS metadata (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at TEXT DEFAULT (datetime('now'))
);

INSERT OR REPLACE INTO metadata (key, value) VALUES ('schema_version', '1.0.0');
INSERT OR REPLACE INTO metadata (key, value) VALUES ('initialized_at', datetime('now'));
"@

# Execute schema
try {
    Invoke-SqliteQuery -DataSource $DatabasePath -Query $schema
    Write-Host "✅ Database initialized successfully" -ForegroundColor Green

    # Verify tables
    $tables = Invoke-SqliteQuery -DataSource $DatabasePath -Query "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
    Write-Host "`nCreated tables:" -ForegroundColor Cyan
    $tables | ForEach-Object { Write-Host "  - $($_.name)" -ForegroundColor Gray }

    # Verify views
    $views = Invoke-SqliteQuery -DataSource $DatabasePath -Query "SELECT name FROM sqlite_master WHERE type='view' ORDER BY name"
    Write-Host "`nCreated views:" -ForegroundColor Cyan
    $views | ForEach-Object { Write-Host "  - $($_.name)" -ForegroundColor Gray }

    Write-Host "`n✅ Work tracking database ready at: $DatabasePath" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to initialize database: $_" -ForegroundColor Red
    exit 1
}
