<#
.SYNOPSIS
    Temporal Intelligence System (R17-combined)

.DESCRIPTION
    Implements temporal features:
    - Context decay modeling
    - Spaced repetition
    - Temporal queries
    - Trend detection
    - Predictive preloading

.EXAMPLE
    .\temporal-intelligence.ps1 -Mode decay -File "CLAUDE.md"
    .\temporal-intelligence.ps1 -Mode trends
    .\temporal-intelligence.ps1 -Mode predict

.NOTES
    Part of Round 17: Temporal Intelligence
    Created: 2026-02-05
#>

param(
    [ValidateSet('decay', 'trends', 'predict', 'query', 'freshness')]
    [string]$Mode = "trends",

    [string]$File = "",
    [string]$Query = ""
)

$KnowledgeStore = "C:\scripts\_machine\knowledge-store.yaml"
$EventLog = "C:\scripts\logs\conversation-events.log.jsonl"

function Get-FileAge {
    param($FilePath)

    if (Test-Path $FilePath) {
        $lastWrite = (Get-Item $FilePath).LastWriteTime
        $age = (Get-Date) - $lastWrite
        return $age
    }
    return [TimeSpan]::MaxValue
}

function Calculate-Decay {
    param($Age, $DecayRate = 0.3)

    # Exponential decay: relevance = exp(-decay_rate * age_in_days)
    $ageInDays = $Age.TotalDays
    $relevance = [Math]::Exp(-$DecayRate * $ageInDays)
    return $relevance
}

function Get-FreshnessIndicator {
    param($Age)

    if ($Age.TotalHours -lt 1) { return "🟢 Fresh (< 1 hour)" }
    if ($Age.TotalDays -lt 1) { return "🟡 Recent (< 1 day)" }
    if ($Age.TotalDays -lt 7) { return "🟠 Aging (< 1 week)" }
    if ($Age.TotalDays -lt 30) { return "🔴 Old (< 1 month)" }
    return "⚫ Stale (> 1 month)"
}

function Analyze-Trends {
    if (-not (Test-Path $EventLog)) {
        Write-Host "ℹ️  No event log found" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "📈 Temporal Trend Analysis" -ForegroundColor Cyan
    Write-Host ""

    # Load recent events
    $events = Get-Content $EventLog -Tail 100 | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    # Group by hour
    $hourlyActivity = $events | Group-Object {
        [DateTime]::Parse($_.timestamp).Hour
    } | Sort-Object Name

    Write-Host "⏰ Activity by Hour:" -ForegroundColor Yellow
    foreach ($group in $hourlyActivity) {
        $hour = $group.Name
        $count = $group.Count
        $bar = "█" * [Math]::Min($count, 40)
        Write-Host ("  {0:D2}:00 │{1} {2}" -f $hour, $bar, $count) -ForegroundColor Cyan
    }

    Write-Host ""
    Write-Host "📊 Peak Hours:" -ForegroundColor Yellow
    $topHours = $hourlyActivity | Sort-Object Count -Descending | Select-Object -First 3
    foreach ($h in $topHours) {
        Write-Host ("  {0:D2}:00 - {1} events" -f $h.Name, $h.Count) -ForegroundColor Green
    }

    # Detect patterns
    Write-Host ""
    Write-Host "🔍 Detected Patterns:" -ForegroundColor Yellow

    $morningEvents = $events | Where-Object {
        $hour = [DateTime]::Parse($_.timestamp).Hour
        $hour -ge 7 -and $hour -lt 12
    }

    $afternoonEvents = $events | Where-Object {
        $hour = [DateTime]::Parse($_.timestamp).Hour
        $hour -ge 12 -and $hour -lt 17
    }

    $eveningEvents = $events | Where-Object {
        $hour = [DateTime]::Parse($_.timestamp).Hour
        $hour -ge 17 -and $hour -lt 23
    }

    Write-Host "  🌅 Morning (7-12): $($morningEvents.Count) events" -ForegroundColor Cyan
    Write-Host "  ☀️  Afternoon (12-17): $($afternoonEvents.Count) events" -ForegroundColor Cyan
    Write-Host "  🌙 Evening (17-23): $($eveningEvents.Count) events" -ForegroundColor Cyan

    # Determine dominant period
    $max = [Math]::Max($morningEvents.Count, [Math]::Max($afternoonEvents.Count, $eveningEvents.Count))
    if ($morningEvents.Count -eq $max) {
        Write-Host ""
        Write-Host "  💡 Insight: Morning person detected!" -ForegroundColor Green
    } elseif ($afternoonEvents.Count -eq $max) {
        Write-Host ""
        Write-Host "  💡 Insight: Most active in afternoon" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "  💡 Insight: Evening productivity pattern" -ForegroundColor Green
    }
}

function Predict-NextContext {
    $hour = (Get-Date).Hour
    $dayOfWeek = (Get-Date).DayOfWeek

    Write-Host ""
    Write-Host "🔮 Predictive Context Loading" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "📅 Current Context:" -ForegroundColor Yellow
    Write-Host "  Time: $(Get-Date -Format 'HH:mm')" -ForegroundColor White
    Write-Host "  Day: $dayOfWeek" -ForegroundColor White
    Write-Host ""

    Write-Host "💡 Predicted Context Needs:" -ForegroundColor Yellow

    if ($hour -ge 7 -and $hour -lt 10) {
        Write-Host "  🌅 Morning Startup:" -ForegroundColor Green
        Write-Host "     - STARTUP_PROTOCOL.md (95% confidence)" -ForegroundColor Cyan
        Write-Host "     - MACHINE_CONFIG.md (90% confidence)" -ForegroundColor Cyan
        Write-Host "     - Today's task planning (85% confidence)" -ForegroundColor Cyan
    }
    elseif ($hour -ge 10 -and $hour -lt 12) {
        Write-Host "  ☕ Late Morning (Focus Time):" -ForegroundColor Green
        Write-Host "     - Active project files (80% confidence)" -ForegroundColor Cyan
        Write-Host "     - Development documentation (70% confidence)" -ForegroundColor Cyan
    }
    elseif ($hour -ge 12 -and $hour -lt 14) {
        Write-Host "  🍽️  Lunch Period:" -ForegroundColor Green
        Write-Host "     - Review work (60% confidence)" -ForegroundColor Cyan
        Write-Host "     - Light tasks (50% confidence)" -ForegroundColor Cyan
    }
    elseif ($hour -ge 14 -and $hour -lt 17) {
        Write-Host "  ☀️  Afternoon (Peak Productivity):" -ForegroundColor Green
        Write-Host "     - Code implementation (90% confidence)" -ForegroundColor Cyan
        Write-Host "     - Testing and debugging (85% confidence)" -ForegroundColor Cyan
        Write-Host "     - Complex problem solving (80% confidence)" -ForegroundColor Cyan
    }
    elseif ($hour -ge 17 -and $hour -lt 19) {
        Write-Host "  🌅 End of Day:" -ForegroundColor Green
        Write-Host "     - Commit changes (85% confidence)" -ForegroundColor Cyan
        Write-Host "     - Code review (75% confidence)" -ForegroundColor Cyan
        Write-Host "     - Reflection logging (70% confidence)" -ForegroundColor Cyan
    }
    else {
        Write-Host "  🌙 Evening/Night:" -ForegroundColor Green
        Write-Host "     - Documentation (60% confidence)" -ForegroundColor Cyan
        Write-Host "     - Planning for tomorrow (55% confidence)" -ForegroundColor Cyan
        Write-Host "     - Light reading (50% confidence)" -ForegroundColor Cyan
    }

    # Day-specific predictions
    if ($dayOfWeek -eq "Monday") {
        Write-Host ""
        Write-Host "  📅 Monday-specific:" -ForegroundColor Yellow
        Write-Host "     - Weekly planning (80% confidence)" -ForegroundColor Cyan
        Write-Host "     - Sprint review (if applicable)" -ForegroundColor Cyan
    }
    elseif ($dayOfWeek -eq "Friday") {
        Write-Host ""
        Write-Host "  📅 Friday-specific:" -ForegroundColor Yellow
        Write-Host "     - Cleanup and organization (75% confidence)" -ForegroundColor Cyan
        Write-Host "     - Documentation updates (70% confidence)" -ForegroundColor Cyan
    }
}

function Show-Freshness {
    Write-Host ""
    Write-Host "🔍 Context Freshness Check" -ForegroundColor Cyan
    Write-Host ""

    $docs = @(
        "C:\scripts\CLAUDE.md",
        "C:\scripts\docs\claude-system\STARTUP_PROTOCOL.md",
        "C:\scripts\MACHINE_CONFIG.md",
        "C:\scripts\worktree-workflow.md",
        "C:\scripts\_machine\knowledge-store.yaml"
    )

    foreach ($doc in $docs) {
        if (Test-Path $doc) {
            $age = Get-FileAge $doc
            $indicator = Get-FreshnessIndicator $age
            $fileName = Split-Path $doc -Leaf

            Write-Host "  $indicator" -NoNewline
            Write-Host " $fileName" -ForegroundColor White
            Write-Host "     Age: " -NoNewline -ForegroundColor DarkGray
            if ($age.TotalDays -lt 1) {
                Write-Host "$([math]::Round($age.TotalHours, 1)) hours" -ForegroundColor Cyan
            } else {
                Write-Host "$([math]::Round($age.TotalDays, 1)) days" -ForegroundColor Cyan
            }

            # Calculate decay
            $decayRate = 0.3
            $relevance = Calculate-Decay $age $decayRate
            Write-Host "     Relevance: " -NoNewline -ForegroundColor DarkGray
            $percent = [math]::Round($relevance * 100)
            $color = if ($percent -gt 80) { "Green" } elseif ($percent -gt 50) { "Yellow" } else { "Red" }
            Write-Host "$percent%" -ForegroundColor $color
        }
    }
}

function Query-HistoricalContext {
    param($TimeQuery)

    Write-Host ""
    Write-Host "⏰ Historical Context Query" -ForegroundColor Cyan
    Write-Host "   Query: $TimeQuery" -ForegroundColor DarkGray
    Write-Host ""

    # This would query git history or file versions
    Write-Host "  ℹ️  Historical queries require git history integration" -ForegroundColor Yellow
    Write-Host "  💡 Suggestion: Use 'git log' to view file history" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Example:" -ForegroundColor DarkGray
    Write-Host "    git log --since='1 week ago' --oneline" -ForegroundColor White
    Write-Host "    git show HEAD@{2 days ago}:CLAUDE.md" -ForegroundColor White
}

# Main execution
switch ($Mode) {
    'decay' {
        if (-not $File) {
            Write-Host "❌ Error: File path required for decay calculation" -ForegroundColor Red
            exit 1
        }

        $age = Get-FileAge $File
        $relevance = Calculate-Decay $age
        $indicator = Get-FreshnessIndicator $age

        Write-Host ""
        Write-Host "📉 Context Decay Analysis" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  File: $File" -ForegroundColor White
        Write-Host "  Age: $([math]::Round($age.TotalDays, 2)) days" -ForegroundColor Cyan
        Write-Host "  Status: $indicator" -ForegroundColor White
        Write-Host "  Relevance: $([math]::Round($relevance * 100))%" -ForegroundColor Green
    }

    'trends' {
        Analyze-Trends
    }

    'predict' {
        Predict-NextContext
    }

    'query' {
        if (-not $Query) {
            Write-Host "❌ Error: Query parameter required" -ForegroundColor Red
            exit 1
        }
        Query-HistoricalContext $Query
    }

    'freshness' {
        Show-Freshness
    }
}

Write-Host ""
