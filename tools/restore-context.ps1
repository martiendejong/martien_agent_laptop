<#
.SYNOPSIS
    Restore session context for seamless continuation

.DESCRIPTION
    Restores rich session context captured previously:
    - What you were working on and why
    - Your emotional state and confidence level
    - Planned next steps
    - Git state and worktree allocation
    - Recent errors and blockers

    Displays context summary to quickly resume work.

.PARAMETER SessionId
    Session ID to restore (defaults to latest)

.PARAMETER ListSessions
    List all available sessions

.EXAMPLE
    .\restore-context.ps1

.EXAMPLE
    .\restore-context.ps1 -SessionId 20260127-143000

.EXAMPLE
    .\restore-context.ps1 -ListSessions
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$SessionId,

    [Parameter(Mandatory=$false)]
    [switch]$ListSessions
)

$ErrorActionPreference = 'Stop'

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

if ($ListSessions) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Available Sessions" -ForegroundColor White
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    $sessionsSql = "SELECT DISTINCT session_id, MAX(timestamp) as last_update FROM session_context GROUP BY session_id ORDER BY last_update DESC LIMIT 10;"
    $sessions = Invoke-Sql -Sql $sessionsSql

    if ($sessions) {
        $sessions -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                Write-Host "  📁 $($parts[0])" -ForegroundColor Cyan
                Write-Host "     Last update: $($parts[1])" -ForegroundColor Gray
                Write-Host ""
            }
        }
    } else {
        Write-Host "  No sessions found" -ForegroundColor Yellow
    }

    exit 0
}

# Get latest session if not specified
if (-not $SessionId) {
    $latestSql = "SELECT session_id FROM session_context ORDER BY timestamp DESC LIMIT 1;"
    $SessionId = Invoke-Sql -Sql $latestSql

    if (-not $SessionId) {
        Write-Host ""
        Write-Host "❌ No session context found" -ForegroundColor Red
        Write-Host ""
        Write-Host "Capture context with:" -ForegroundColor Yellow
        Write-Host "  .\capture-context.ps1 -Task `"...`" -Why `"...`"" -ForegroundColor Gray
        Write-Host ""
        exit 1
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Restoring Session Context" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Session: $SessionId" -ForegroundColor White
Write-Host ""

# Load all context for this session
$contextSql = "SELECT context_key, context_value, context_type, emotional_state, why_captured, timestamp FROM session_context WHERE session_id = '$SessionId' ORDER BY timestamp DESC;"
$contextData = Invoke-Sql -Sql $contextSql

if (-not $contextData) {
    Write-Host "❌ Session not found: $SessionId" -ForegroundColor Red
    Write-Host ""
    Write-Host "List available sessions:" -ForegroundColor Yellow
    Write-Host "  .\restore-context.ps1 -ListSessions" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Parse context data
$context = @{}
$contextData -split "`n" | ForEach-Object {
    if ($_ -match '\|') {
        $parts = $_ -split '\|'
        $key = $parts[0]
        $value = $parts[1]
        $type = $parts[2]
        $emotion = $parts[3]
        $why = $parts[4]
        $timestamp = $parts[5]

        if (-not $context.ContainsKey($key)) {
            $context[$key] = @{
                value = $value
                type = $type
                emotion = $emotion
                why = $why
                timestamp = $timestamp
            }
        }
    }
}

# Display context summary
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan

# Current task
if ($context.ContainsKey("current_task")) {
    Write-Host ""
    Write-Host "🎯 TASK:" -ForegroundColor Cyan
    Write-Host "   $($context['current_task'].value)" -ForegroundColor White
}

# Why
if ($context.ContainsKey("task_reason")) {
    Write-Host ""
    Write-Host "💡 WHY:" -ForegroundColor Cyan
    Write-Host "   $($context['task_reason'].value)" -ForegroundColor White
}

# Emotional state
if ($context.ContainsKey("emotional_state")) {
    Write-Host ""
    Write-Host "🧠 EMOTIONAL STATE:" -ForegroundColor Cyan
    $emotion = $context['emotional_state'].value
    $color = switch ($emotion) {
        'confident' { 'Green' }
        'excited' { 'Green' }
        'frustrated' { 'Red' }
        'blocked' { 'Red' }
        'uncertain' { 'Yellow' }
        default { 'White' }
    }
    Write-Host "   $emotion" -ForegroundColor $color
}

# Next steps
if ($context.ContainsKey("next_steps")) {
    Write-Host ""
    Write-Host "⏭️  NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "   $($context['next_steps'].value)" -ForegroundColor White
}

# Git state
if ($context.ContainsKey("git_branch")) {
    Write-Host ""
    Write-Host "🔀 GIT STATE:" -ForegroundColor Cyan
    Write-Host "   Branch: $($context['git_branch'].value)" -ForegroundColor White

    if ($context.ContainsKey("git_status") -and $context['git_status'].value) {
        Write-Host "   Changes:" -ForegroundColor Gray
        $context['git_status'].value -split "`n" | ForEach-Object {
            Write-Host "     $_" -ForegroundColor DarkGray
        }
    }
}

# Active worktree
if ($context.ContainsKey("active_worktree")) {
    Write-Host ""
    Write-Host "📂 WORKTREE:" -ForegroundColor Cyan
    Write-Host "   $($context['active_worktree'].value)" -ForegroundColor White
}

# Recent errors
if ($context.ContainsKey("recent_errors")) {
    Write-Host ""
    Write-Host "⚠️  RECENT ERRORS:" -ForegroundColor Yellow
    Write-Host "   $($context['recent_errors'].value)" -ForegroundColor White
}

# Notes
if ($context.ContainsKey("notes")) {
    Write-Host ""
    Write-Host "📝 NOTES:" -ForegroundColor Cyan
    Write-Host "   $($context['notes'].value)" -ForegroundColor White
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
Write-Host ""

# Calculate time since last context update
if ($context.ContainsKey("current_task")) {
    $lastUpdate = [DateTime]::ParseExact($context['current_task'].timestamp, "yyyy-MM-ddTHH:mm:ss", $null)
    $timeSince = (Get-Date) - $lastUpdate

    if ($timeSince.TotalMinutes -lt 60) {
        $timeDesc = "$([math]::Round($timeSince.TotalMinutes)) minutes ago"
    } elseif ($timeSince.TotalHours -lt 24) {
        $timeDesc = "$([math]::Round($timeSince.TotalHours)) hours ago"
    } else {
        $timeDesc = "$([math]::Round($timeSince.TotalDays)) days ago"
    }

    Write-Host "⏰ Last captured: $timeDesc" -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "✅ Context restored - you can continue where you left off!" -ForegroundColor Green
Write-Host ""

# Return context object for programmatic use
return $context
