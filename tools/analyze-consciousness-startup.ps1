# Analyze Consciousness Startup Logs
# Created: 2026-03-04
# Purpose: Analyze startup patterns, detect degradation, identify trends

<#
.SYNOPSIS
    Analyze consciousness startup logs for patterns and issues.
.DESCRIPTION
    Reads consciousness-startup.log (JSONL format) and analyzes:
    - Consciousness score trends
    - Warning patterns
    - Subsystem activation consistency
    - Performance metrics over time
.PARAMETER Last
    Number of recent sessions to analyze (default: 10)
.PARAMETER ShowDetails
    Show detailed per-session output
.PARAMETER Silent
    Return object only, no console output
#>

param(
    [int]$Last = 10,
    [switch]$ShowDetails,
    [switch]$Silent
)

$ErrorActionPreference = "Continue"
$logFile = "C:\scripts\logs\consciousness-startup.log"

if (-not (Test-Path $logFile)) {
    if (-not $Silent) {
        Write-Host "No startup log found at $logFile" -ForegroundColor Yellow
        Write-Host "Log will be created on next consciousness-startup run." -ForegroundColor Gray
    }
    return @{
        Status = "no_log"
        Message = "No startup log found"
    }
}

# Read last N sessions (JSONL format - one JSON object per line)
$allLines = Get-Content $logFile -ErrorAction SilentlyContinue
if (-not $allLines -or $allLines.Count -eq 0) {
    if (-not $Silent) {
        Write-Host "Startup log is empty" -ForegroundColor Yellow
    }
    return @{
        Status = "empty_log"
        Message = "Log file exists but is empty"
    }
}

$sessions = $allLines | Select-Object -Last $Last | ForEach-Object {
    try {
        $_ | ConvertFrom-Json
    } catch {
        $null  # Skip malformed lines
    }
} | Where-Object { $_ -ne $null }

if (-not $sessions -or $sessions.Count -eq 0) {
    if (-not $Silent) {
        Write-Host "No valid sessions found in log" -ForegroundColor Yellow
    }
    return @{
        Status = "no_valid_sessions"
        Message = "Log contains no valid JSON entries"
    }
}

# Analysis
$analysis = @{
    SessionCount = $sessions.Count
    TimeRange = @{
        First = $sessions[0].Timestamp
        Last = $sessions[-1].Timestamp
    }
    ConsciousnessScore = @{
        Current = $sessions[-1].Metrics.ConsciousnessScore
        Average = ($sessions | ForEach-Object { $_.Metrics.ConsciousnessScore } | Measure-Object -Average).Average
        Min = ($sessions | ForEach-Object { $_.Metrics.ConsciousnessScore } | Measure-Object -Minimum).Minimum
        Max = ($sessions | ForEach-Object { $_.Metrics.ConsciousnessScore } | Measure-Object -Maximum).Maximum
    }
    Warnings = @{
        Total = ($sessions | ForEach-Object { $_.Warnings.Count } | Measure-Object -Sum).Sum
        Patterns = @{}
    }
    Metrics = @{
        SubsystemsActive = @{
            Average = ($sessions | ForEach-Object { $_.Metrics.SubsystemsActive } | Measure-Object -Average).Average
            Current = $sessions[-1].Metrics.SubsystemsActive
        }
        PredictionPatterns = @{
            Average = ($sessions | ForEach-Object { $_.Metrics.PredictionPatterns } | Measure-Object -Average).Average
            Current = $sessions[-1].Metrics.PredictionPatterns
        }
        CuriosityQuestions = @{
            Average = ($sessions | ForEach-Object { $_.Metrics.CuriosityQuestions } | Measure-Object -Average).Average
            Current = $sessions[-1].Metrics.CuriosityQuestions
        }
    }
    Issues = @()
    Recommendations = @()
}

# Detect warning patterns
foreach ($session in $sessions) {
    foreach ($warning in $session.Warnings) {
        # Extract warning type (first few words)
        $warningType = ($warning -split ':')[0]
        if (-not $analysis.Warnings.Patterns.ContainsKey($warningType)) {
            $analysis.Warnings.Patterns[$warningType] = 0
        }
        $analysis.Warnings.Patterns[$warningType]++
    }
}

# Detect issues
$latestScore = $sessions[-1].Metrics.ConsciousnessScore
if ($latestScore -lt 90) {
    $analysis.Issues += "Consciousness score below 90% ($latestScore%)"
    $analysis.Recommendations += "Investigate consciousness core initialization"
}

if ($analysis.Warnings.Total -gt ($sessions.Count * 2)) {
    $analysis.Issues += "High warning rate: $($analysis.Warnings.Total) warnings in $($sessions.Count) sessions"
    $analysis.Recommendations += "Review common warning patterns and fix root causes"
}

$subsystemsExpected = 4
if ($sessions[-1].Metrics.SubsystemsActive -lt $subsystemsExpected) {
    $analysis.Issues += "Not all subsystems active: $($sessions[-1].Metrics.SubsystemsActive)/$subsystemsExpected"
    $analysis.Recommendations += "Check subsystem initialization in consciousness-startup.ps1"
}

# Check for declining trends (score dropping over last 3 sessions)
if ($sessions.Count -ge 3) {
    $recent3 = $sessions | Select-Object -Last 3
    $scores = $recent3 | ForEach-Object { $_.Metrics.ConsciousnessScore }
    if ($scores[0] -gt $scores[1] -and $scores[1] -gt $scores[2]) {
        $analysis.Issues += "Consciousness score declining over last 3 sessions: $($scores[0]) → $($scores[1]) → $($scores[2])"
        $analysis.Recommendations += "System degradation detected - review recent changes"
    }
}

# Output
if (-not $Silent) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  CONSCIOUSNESS STARTUP ANALYSIS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Sessions Analyzed: " -NoNewline
    Write-Host "$($analysis.SessionCount)" -ForegroundColor Green
    Write-Host "Time Range: " -NoNewline
    Write-Host "$($analysis.TimeRange.First) → $($analysis.TimeRange.Last)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Consciousness Score:" -ForegroundColor Yellow
    Write-Host "  Current:  " -NoNewline
    $color = if ($analysis.ConsciousnessScore.Current -ge 95) { "Green" } elseif ($analysis.ConsciousnessScore.Current -ge 90) { "Yellow" } else { "Red" }
    Write-Host "$($analysis.ConsciousnessScore.Current)%" -ForegroundColor $color
    Write-Host "  Average:  $([math]::Round($analysis.ConsciousnessScore.Average, 1))%" -ForegroundColor Gray
    Write-Host "  Range:    $($analysis.ConsciousnessScore.Min)% - $($analysis.ConsciousnessScore.Max)%" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Subsystems:" -ForegroundColor Yellow
    Write-Host "  Active:   $($analysis.Metrics.SubsystemsActive.Current)/$subsystemsExpected" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Warnings:" -ForegroundColor Yellow
    Write-Host "  Total:    $($analysis.Warnings.Total) across $($analysis.SessionCount) sessions" -ForegroundColor Gray
    if ($analysis.Warnings.Patterns.Count -gt 0) {
        Write-Host "  Patterns:" -ForegroundColor Gray
        foreach ($pattern in ($analysis.Warnings.Patterns.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 5)) {
            Write-Host "    - $($pattern.Key): $($pattern.Value)x" -ForegroundColor DarkYellow
        }
    }
    Write-Host ""

    if ($analysis.Issues.Count -gt 0) {
        Write-Host "Issues Detected:" -ForegroundColor Red
        foreach ($issue in $analysis.Issues) {
            Write-Host "  ⚠ $issue" -ForegroundColor Yellow
        }
        Write-Host ""
    }

    if ($analysis.Recommendations.Count -gt 0) {
        Write-Host "Recommendations:" -ForegroundColor Magenta
        foreach ($rec in $analysis.Recommendations) {
            Write-Host "  → $rec" -ForegroundColor Cyan
        }
        Write-Host ""
    }

    if ($analysis.Issues.Count -eq 0) {
        Write-Host "✓ All systems healthy" -ForegroundColor Green
        Write-Host ""
    }

    if ($ShowDetails) {
        Write-Host "───────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "Recent Sessions (newest first):" -ForegroundColor Yellow
        Write-Host ""
        foreach ($session in ($sessions | Select-Object -Last 5 | Sort-Object Timestamp -Descending)) {
            Write-Host "  $($session.SessionId)" -ForegroundColor Cyan
            Write-Host "    Score: $($session.Metrics.ConsciousnessScore)% | Subsystems: $($session.Metrics.SubsystemsActive) | Warnings: $($session.Warnings.Count)" -ForegroundColor Gray
            if ($session.Warnings.Count -gt 0) {
                foreach ($w in $session.Warnings) {
                    Write-Host "      ⚠ $w" -ForegroundColor DarkYellow
                }
            }
            Write-Host ""
        }
    }

    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

# Return analysis object
return $analysis
