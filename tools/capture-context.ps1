<#
.SYNOPSIS
    Capture rich session context for cross-session memory

.DESCRIPTION
    Captures comprehensive session context:
    - Current task and WHY working on it
    - Emotional state (confident, frustrated, blocked, etc.)
    - Progress and next steps
    - Open files and git state
    - Mental models and assumptions

    Stored in session_context table for restoration later.

.PARAMETER SessionId
    Session ID to capture for (defaults to current session)

.PARAMETER Task
    What are you working on?

.PARAMETER Why
    Why are you working on this?

.PARAMETER EmotionalState
    How do you feel? (confident, frustrated, blocked, uncertain, excited)

.PARAMETER NextSteps
    What are your planned next steps?

.PARAMETER Notes
    Additional context notes (JSON or string)

.EXAMPLE
    .\capture-context.ps1 -Task "Refactoring AuthService" -Why "Performance issues" -EmotionalState "confident" -NextSteps "Add unit tests"

.EXAMPLE
    .\capture-context.ps1 -Task "Debugging OAuth" -Why "Token expiry not handled" -EmotionalState "frustrated"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$SessionId,

    [Parameter(Mandatory=$false)]
    [string]$Task,

    [Parameter(Mandatory=$false)]
    [string]$Why,

    [Parameter(Mandatory=$false)]
    [ValidateSet('confident', 'frustrated', 'blocked', 'uncertain', 'excited', 'tired', 'focused')]
    [string]$EmotionalState,

    [Parameter(Mandatory=$false)]
    [string]$NextSteps,

    [Parameter(Mandatory=$false)]
    [string]$Notes
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Cross-Session Memory Capture" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Get current session ID
if (-not $SessionId) {
    if (Test-Path "C:\scripts\_machine\.current_session_id") {
        $SessionId = (Get-Content "C:\scripts\_machine\.current_session_id" -Raw).Trim()
    } else {
        $SessionId = (Get-Date).ToString("yyyyMMdd-HHmmss")
    }
}

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

function Capture-KeyValue {
    param(
        [string]$Key,
        [string]$Value,
        [string]$Type = "string",
        [string]$Why = ""
    )

    if (-not $Value) { return }

    $valueEscaped = $Value -replace "'", "''"
    $whyEscaped = $Why -replace "'", "''"
    $timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")

    $sql = @"
INSERT OR REPLACE INTO session_context (session_id, context_key, context_value, context_type, why_captured, timestamp)
VALUES ('$SessionId', '$Key', '$valueEscaped', '$Type', '$whyEscaped', '$timestamp');
"@

    Invoke-Sql -Sql $sql
    Write-Host "  ✅ Captured: $Key" -ForegroundColor Green
}

Write-Host "Session: $SessionId" -ForegroundColor White
Write-Host ""

# Capture provided context
if ($Task) {
    Capture-KeyValue -Key "current_task" -Value $Task -Why "What I'm working on"
}

if ($Why) {
    Capture-KeyValue -Key "task_reason" -Value $Why -Why "Why I'm working on this"
}

if ($EmotionalState) {
    Capture-KeyValue -Key "emotional_state" -Value $EmotionalState -Type "emotion" -Why "How I feel about current work"
}

if ($NextSteps) {
    Capture-KeyValue -Key "next_steps" -Value $NextSteps -Type "intention" -Why "What I plan to do next"
}

if ($Notes) {
    Capture-KeyValue -Key "notes" -Value $Notes -Type "json" -Why "Additional context"
}

# Auto-capture environmental context
Write-Host "📊 Auto-capturing environmental context..." -ForegroundColor Cyan

# Git state
try {
    $gitBranch = git branch --show-current 2>$null
    if ($gitBranch) {
        Capture-KeyValue -Key "git_branch" -Value $gitBranch -Why "Current git branch"
    }

    $gitStatus = git status --short 2>$null | Out-String
    if ($gitStatus) {
        Capture-KeyValue -Key "git_status" -Value $gitStatus.Trim() -Why "Uncommitted changes"
    }
} catch {
    Write-Host "  ⚠️ Git context unavailable" -ForegroundColor DarkGray
}

# Open worktree
$worktreePoolPath = "C:\scripts\_machine\worktrees.pool.md"
if (Test-Path $worktreePoolPath) {
    $poolContent = Get-Content $worktreePoolPath -Raw
    if ($poolContent -match 'BUSY') {
        $busyLines = $poolContent -split "`n" | Where-Object { $_ -match 'BUSY' }
        if ($busyLines) {
            $worktreeInfo = $busyLines[0]
            Capture-KeyValue -Key "active_worktree" -Value $worktreeInfo -Why "Current worktree allocation"
        }
    }
}

# Recent errors (if any)
$errorsSql = "SELECT error_type, error_message FROM errors WHERE timestamp > datetime('now', '-1 hour') ORDER BY timestamp DESC LIMIT 3;"
$recentErrors = Invoke-Sql -Sql $errorsSql

if ($recentErrors) {
    $errorContext = ($recentErrors -split "`n" | ForEach-Object {
        if ($_ -match '\|') {
            $parts = $_ -split '\|'
            "$($parts[0]): $($parts[1])"
        }
    }) -join "; "

    if ($errorContext) {
        Capture-KeyValue -Key "recent_errors" -Value $errorContext -Why "Errors in last hour"
    }
}

Write-Host ""
Write-Host "✅ Session context captured!" -ForegroundColor Green
Write-Host ""
Write-Host "Restore with:" -ForegroundColor Cyan
Write-Host "  .\restore-context.ps1 -SessionId $SessionId" -ForegroundColor Gray
Write-Host ""
