<#
.SYNOPSIS
    Analyze bridge-activity.jsonl and produce actionable session briefing.
.DESCRIPTION
    Reads the consciousness bridge activity log, groups by session,
    and outputs a compact briefing for the current session start.
.EXAMPLE
    .\analyze-last-session.ps1
    .\analyze-last-session.ps1 -Silent
#>
param([switch]$Silent)

$ErrorActionPreference = "Stop"
$logFile = "C:\scripts\agentidentity\state\bridge-activity.jsonl"

if (-not (Test-Path $logFile)) {
    if (-not $Silent) { Write-Host "[BRIEFING] No bridge activity log found." }
    return @{ sessions = 0 }
}

$lines = Get-Content $logFile -Encoding UTF8 | Where-Object { $_.Trim() }
if ($lines.Count -eq 0) {
    if (-not $Silent) { Write-Host "[BRIEFING] Bridge activity log is empty." }
    return @{ sessions = 0 }
}

# Parse all entries
$entries = @()
foreach ($line in $lines) {
    try {
        $entry = $line | ConvertFrom-Json
        $entries += $entry
    } catch { }
}

# Find sessions: split on Reset events
$sessions = @()
$currentSession = @()
foreach ($e in $entries) {
    if ($e.action -eq "Reset") {
        if ($currentSession.Count -gt 0) {
            $sessions += ,@($currentSession)
        }
        $currentSession = @()
    } else {
        $currentSession += $e
    }
}
if ($currentSession.Count -gt 0) { $sessions += ,@($currentSession) }

# Analyze last 3 sessions (most relevant)
$recentSessions = @()
$startIdx = [math]::Max(0, $sessions.Count - 3)
for ($i = $startIdx; $i -lt $sessions.Count; $i++) {
    $session = $sessions[$i]
    $tasks = $session | Where-Object { $_.action -eq "OnTaskStart" }
    $decisions = $session | Where-Object { $_.action -eq "OnDecision" }
    $stucks = $session | Where-Object { $_.action -eq "OnStuck" }
    $ends = $session | Where-Object { $_.action -eq "OnTaskEnd" }

    $successes = ($ends | Where-Object { $_.message -match "outcome=success" }).Count
    $failures = ($ends | Where-Object { $_.message -match "outcome=failure" }).Count

    # Extract project from task starts
    $projects = @{}
    foreach ($t in $tasks) {
        if ($t.message -match '\(project:\s*([^)]+)\)') {
            $proj = $Matches[1]
            if (-not $projects.ContainsKey($proj)) { $projects[$proj] = 0 }
            $projects[$proj]++
        }
    }

    # Extract stuck projects
    $stuckProjects = @{}
    $lastProject = ""
    foreach ($e in $session) {
        if ($e.action -eq "OnTaskStart" -and $e.message -match '\(project:\s*([^)]+)\)') {
            $lastProject = $Matches[1]
        }
        if ($e.action -eq "OnStuck" -and $lastProject) {
            if (-not $stuckProjects.ContainsKey($lastProject)) { $stuckProjects[$lastProject] = 0 }
            $stuckProjects[$lastProject]++
        }
    }

    $recentSessions += @{
        task_count = $tasks.Count
        decision_count = $decisions.Count
        stuck_count = $stucks.Count
        success_count = $successes
        failure_count = $failures
        projects = $projects
        stuck_projects = $stuckProjects
        first_event = if ($session[0].timestamp) { $session[0].timestamp } else { "unknown" }
    }
}

# Build briefing
$briefing = @{
    total_sessions = $sessions.Count
    recent_sessions = $recentSessions.Count
    patterns = @()
    warnings = @()
}

# Aggregate stuck patterns across recent sessions
$allStuckProjects = @{}
$totalStucks = 0
$totalFailures = 0
$totalSuccesses = 0
foreach ($s in $recentSessions) {
    $totalStucks += $s.stuck_count
    $totalFailures += $s.failure_count
    $totalSuccesses += $s.success_count
    foreach ($k in $s.stuck_projects.Keys) {
        if (-not $allStuckProjects.ContainsKey($k)) { $allStuckProjects[$k] = 0 }
        $allStuckProjects[$k] += $s.stuck_projects[$k]
    }
}

# Generate actionable patterns
if ($totalStucks -gt 5) {
    $worstProject = ($allStuckProjects.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1)
    if ($worstProject) {
        $briefing.patterns += "Frequent stuck events ($totalStucks in last $($recentSessions.Count) sessions). Worst: $($worstProject.Key) ($($worstProject.Value) stuck events)."
    }
}

if ($totalFailures -gt 0) {
    $briefing.warnings += "$totalFailures task failures in recent sessions. Review approach before similar tasks."
}

# Count session-end sentinel fallbacks (outcome=session-end means agent didn't call OnTaskEnd)
$sentinelFallbacks = ($entries | Where-Object { $_.action -eq "OnTaskEnd" -and $_.message -match "outcome=session-end" }).Count
$totalEnds = $totalSuccesses + $totalFailures + $sentinelFallbacks

if ($totalEnds -gt 0) {
    if (($totalSuccesses + $totalFailures) -gt 0) {
        $successRate = [math]::Round($totalSuccesses / ($totalSuccesses + $totalFailures) * 100, 0)
        $briefing.patterns += "Success rate: $successRate% ($totalSuccesses/$($totalSuccesses + $totalFailures) tasks)."
    }
    if ($sentinelFallbacks -gt 0) {
        $briefing.warnings += "$sentinelFallbacks sessions ended without explicit OnTaskEnd (sentinel fallback)."
    }
} else {
    # Count total tasks started as context
    $totalTasks = 0
    foreach ($s in $recentSessions) { $totalTasks += $s.task_count }
    if ($totalTasks -gt 0) {
        $briefing.warnings += "$totalTasks tasks started but no outcomes recorded. Bridge OnTaskEnd calls missing."
    } else {
        $briefing.patterns += "No task activity recorded in last $($recentSessions.Count) sessions."
    }
}

# Output
if (-not $Silent) {
    Write-Host ""
    Write-Host "[SESSION BRIEFING] Last $($recentSessions.Count) sessions analyzed ($($entries.Count) events total)" -ForegroundColor Cyan

    foreach ($p in $briefing.patterns) {
        Write-Host "  $p" -ForegroundColor Gray
    }
    foreach ($w in $briefing.warnings) {
        Write-Host "  [!] $w" -ForegroundColor Yellow
    }

    if ($recentSessions.Count -gt 0) {
        $last = $recentSessions[-1]
        Write-Host "  Last session: $($last.task_count) tasks, $($last.stuck_count) stucks, $($last.success_count) successes, $($last.failure_count) failures" -ForegroundColor Gray
        if ($last.projects.Count -gt 0) {
            $projList = ($last.projects.Keys -join ", ")
            Write-Host "  Projects: $projList" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

return $briefing
