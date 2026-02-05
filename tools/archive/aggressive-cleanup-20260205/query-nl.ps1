<#
.SYNOPSIS
    Natural language database queries

.DESCRIPTION
    Translates natural language questions into SQL queries:
    - "show me all errors from yesterday"
    - "list agents who edited Customer.cs today"
    - "what are my most used tools this week?"

    Uses LLM to translate NL → SQL, executes query, formats results.

.PARAMETER Query
    Natural language query

.PARAMETER Execute
    Execute the query (default: true)

.PARAMETER ShowSQL
    Show generated SQL before executing

.EXAMPLE
    .\query-nl.ps1 -Query "show me all errors from yesterday"

.EXAMPLE
    .\query-nl.ps1 -Query "list my most recent learnings" -ShowSQL
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Query,

    [Parameter(Mandatory=$false)]
    [switch]$Execute = $true,

    [Parameter(Mandatory=$false)]
    [switch]$ShowSQL
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Natural Language Query" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Question: $Query" -ForegroundColor White
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

# Get schema information
$schemaTables = @(
    "errors (timestamp, agent_id, error_type, error_message, severity, resolution)",
    "learnings (timestamp, agent_id, category, message, tags)",
    "tool_usage (timestamp, agent_id, tool_name, duration_ms, success)",
    "file_modifications (timestamp, agent_id, file_path, operation, details)",
    "pull_requests (created_at, agent_id, title, description, status, merged_at)",
    "worktree_allocations (timestamp, agent_id, repo, seat, status)",
    "live_activity (timestamp, agent_id, action_type, details)",
    "action_sequences (sequence_json, count, last_occurrence, suggested_tool_name)",
    "impact_metrics (week_start, bugs_prevented, time_saved_minutes, prs_created, code_quality_delta)",
    "session_context (session_id, context_key, context_value, context_type, emotional_state)",
    "checkpoints (tag, timestamp, description, location, created_by)",
    "agent_profiles (agent_id, specialization, strengths, weaknesses)",
    "shared_knowledge (source_agent_id, knowledge_type, title, content, confidence)",
    "temporal_patterns (day_of_week, hour_of_day, pattern, pattern_type, confidence)",
    "experiments (experiment_name, hypothesis, approach_a, approach_b, winner)"
)

# Build LLM prompt for SQL translation
$translatePrompt = @"
You are a SQL expert. Convert this natural language query into SQLite-compatible SQL.

**Database Schema:**
$($ schemaTables | ForEach-Object { "- $_" } | Join-String -Separator "`n")

**Natural Language Query:**
"$Query"

**Rules:**
1. Generate ONLY the SQL query - no explanations
2. Use SQLite syntax (datetime(), date(), etc.)
3. For time references:
   - "yesterday" = datetime('now', '-1 day')
   - "today" = date('now')
   - "this week" = datetime('now', '-7 days')
   - "last hour" = datetime('now', '-1 hour')
4. Limit results to 50 unless user specifies otherwise
5. Use SELECT only (no INSERT, UPDATE, DELETE)
6. Order results by timestamp/date DESC when applicable

**SQL Query:**
"@

# For now, use pattern matching for common queries (LLM integration would go here)
Write-Host "🧠 Translating to SQL..." -ForegroundColor Cyan

$sql = ""

# Pattern-based translation (simplified - real version would use LLM)
switch -Regex ($Query) {
    'errors?\s+(from\s+)?(yesterday|last\s+24\s+hours)' {
        $sql = "SELECT timestamp, error_type, error_message, severity FROM errors WHERE datetime(timestamp) > datetime('now', '-1 day') ORDER BY timestamp DESC LIMIT 50;"
    }
    'errors?\s+(from\s+)?(today|this\s+day)' {
        $sql = "SELECT timestamp, error_type, error_message, severity FROM errors WHERE date(timestamp) = date('now') ORDER BY timestamp DESC LIMIT 50;"
    }
    'learning(s)?\s+(from\s+)?(today|this\s+day)' {
        $sql = "SELECT timestamp, category, message FROM learnings WHERE date(timestamp) = date('now') ORDER BY timestamp DESC LIMIT 50;"
    }
    'recent\s+learning(s)?' {
        $sql = "SELECT timestamp, category, message FROM learnings ORDER BY timestamp DESC LIMIT 20;"
    }
    'most\s+used\s+tools?' {
        $sql = "SELECT tool_name, COUNT(*) as usage_count FROM tool_usage WHERE datetime(timestamp) > datetime('now', '-7 days') GROUP BY tool_name ORDER BY usage_count DESC LIMIT 10;"
    }
    'agent(s)?\s+.*edited.*' {
        $filePattern = if ($Query -match 'edited\s+(\S+)') { $matches[1] } else { '%' }
        $sql = "SELECT DISTINCT agent_id, timestamp, file_path FROM file_modifications WHERE file_path LIKE '%$filePattern%' AND operation = 'edit' ORDER BY timestamp DESC LIMIT 50;"
    }
    'pr(s)?.*merged' {
        $sql = "SELECT title, merged_at, agent_id FROM pull_requests WHERE status = 'merged' ORDER BY merged_at DESC LIMIT 20;"
    }
    'pr(s)?.*created\s+(today|this\s+day)' {
        $sql = "SELECT title, created_at, agent_id FROM pull_requests WHERE date(created_at) = date('now') ORDER BY created_at DESC LIMIT 20;"
    }
    default {
        Write-Host "⚠️ Pattern not recognized - using LLM fallback" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "LLM Translation Prompt:" -ForegroundColor Cyan
        Write-Host $translatePrompt -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "❌ LLM integration not yet implemented" -ForegroundColor Red
        Write-Host ""
        Write-Host "For now, try these queries:" -ForegroundColor Yellow
        Write-Host "  - 'errors from yesterday'" -ForegroundColor Gray
        Write-Host "  - 'errors from today'" -ForegroundColor Gray
        Write-Host "  - 'recent learnings'" -ForegroundColor Gray
        Write-Host "  - 'most used tools'" -ForegroundColor Gray
        Write-Host "  - 'agents who edited Customer.cs'" -ForegroundColor Gray
        Write-Host "  - 'PRs merged'" -ForegroundColor Gray
        Write-Host ""
        exit 1
    }
}

if ($ShowSQL -or -not $Execute) {
    Write-Host "Generated SQL:" -ForegroundColor Cyan
    Write-Host $sql -ForegroundColor Gray
    Write-Host ""
}

if (-not $Execute) {
    exit 0
}

# Execute query
Write-Host "🔍 Executing query..." -ForegroundColor Cyan
Write-Host ""

try {
    $result = $sql | & $SqlitePath $DbPath

    if ($result) {
        $lines = $result -split "`n"
        Write-Host "Results: $($lines.Count) rows" -ForegroundColor Green
        Write-Host ""

        # Format output as table
        foreach ($line in $lines) {
            if ($line -match '\|') {
                $columns = $line -split '\|'
                Write-Host ($columns -join " | ") -ForegroundColor White
            }
        }
        Write-Host ""
    } else {
        Write-Host "No results found" -ForegroundColor Yellow
        Write-Host ""
    }

} catch {
    Write-Host "Error executing query: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "SQL: $sql" -ForegroundColor DarkGray
    Write-Host ""
    exit 1
}

Write-Host "✅ Query completed!" -ForegroundColor Green
Write-Host ""
