<#
.SYNOPSIS
Screen time dashboard - shows work hours and sleep patterns

.DESCRIPTION
Reads screen-time.jsonl log and displays:
- Today's work hours
- Estimated sleep hours (gap between last activity and first activity next day)
- Weekly averages

.PARAMETER Days
Number of days to show (default: 7)

.EXAMPLE
.\screen-time-dashboard.ps1
Shows today + 7 day average

.EXAMPLE
.\screen-time-dashboard.ps1 -Days 30
Shows today + 30 day average
#>

param(
    [int]$Days = 7
)

$ErrorActionPreference = "Stop"

$logPath = "E:\jengo\health\screen-time.jsonl"

# Check if log exists
if (-not (Test-Path $logPath)) {
    Write-Host ""
    Write-Host "Geen data beschikbaar."
    Write-Host "Monitor moet eerst draaien: .\setup-screen-time-monitor.ps1"
    Write-Host ""
    exit 1
}

# Read all log entries
Write-Host "Laden..." -NoNewline
$entries = Get-Content $logPath | ForEach-Object {
    try {
        $_ | ConvertFrom-Json
    } catch {
        # Skip malformed lines
    }
}
Write-Host " OK ($($entries.Count) entries)"

# Today's stats
$today = Get-Date -Format "yyyy-MM-dd"
$todayEntries = $entries | Where-Object { $_.timestamp -like "$today*" }

if ($todayEntries.Count -eq 0) {
    Write-Host ""
    Write-Host "Geen data voor vandaag. Monitor draait waarschijnlijk niet."
    Write-Host ""
    exit 1
}

# Calculate work hours today
$workMinutes = ($todayEntries | Where-Object { $_.activity -eq "work" }).Count
$workHours = [math]::Round($workMinutes / 60, 1)

# Calculate idle/other
$idleMinutes = ($todayEntries | Where-Object { $_.activity -eq "idle" }).Count
$idleHours = [math]::Round($idleMinutes / 60, 1)

$otherMinutes = ($todayEntries | Where-Object { $_.activity -eq "other" }).Count
$otherHours = [math]::Round($otherMinutes / 60, 1)

# Estimate sleep (last activity yesterday -> first activity today)
$yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
$yesterdayEntries = $entries | Where-Object { $_.timestamp -like "$yesterday*" }

if ($yesterdayEntries -and $yesterdayEntries.Count -gt 0) {
    $lastYesterday = ($yesterdayEntries | Select-Object -Last 1).timestamp
    $firstToday = ($todayEntries | Select-Object -First 1).timestamp

    if ($lastYesterday -and $firstToday) {
        $sleepStart = [datetime]::Parse($lastYesterday)
        $sleepEnd = [datetime]::Parse($firstToday)
        $sleepHours = [math]::Round(($sleepEnd - $sleepStart).TotalHours, 1)
    } else {
        $sleepHours = "?"
    }
} else {
    $sleepHours = "?"
}

# Display today
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " VANDAAG ($today)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Werk:     " -NoNewline
Write-Host "$workHours uur" -ForegroundColor $(if ($workHours -gt 12) { "Red" } elseif ($workHours -gt 8) { "Yellow" } else { "Green" })
Write-Host "  Slaap:    " -NoNewline
Write-Host "$sleepHours uur" -ForegroundColor $(if ($sleepHours -eq "?") { "Gray" } elseif ($sleepHours -lt 6) { "Red" } elseif ($sleepHours -lt 7) { "Yellow" } else { "Green" })
Write-Host "  Idle:     $idleHours uur" -ForegroundColor Gray
Write-Host "  Overig:   $otherHours uur" -ForegroundColor Gray
Write-Host ""

# Weekly/period averages
$cutoffDate = (Get-Date).AddDays(-$Days).ToString("yyyy-MM-dd")
$periodEntries = $entries | Where-Object {
    try {
        $ts = [datetime]::Parse($_.timestamp)
        $ts -ge [datetime]::Parse($cutoffDate)
    } catch {
        $false
    }
}

# Group by day
$dailyStats = $periodEntries | Group-Object {
    ([datetime]::Parse($_.timestamp)).ToString("yyyy-MM-dd")
} | ForEach-Object {
    $dayEntries = $_.Group
    $dayWork = ($dayEntries | Where-Object { $_.activity -eq "work" }).Count / 60

    [PSCustomObject]@{
        Date = $_.Name
        WorkHours = [math]::Round($dayWork, 1)
    }
}

if ($dailyStats.Count -gt 1) {
    $avgWork = [math]::Round(($dailyStats.WorkHours | Measure-Object -Average).Average, 1)
    $maxWork = ($dailyStats.WorkHours | Measure-Object -Maximum).Maximum
    $minWork = ($dailyStats.WorkHours | Measure-Object -Minimum).Minimum

    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host " LAATSTE $Days DAGEN" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Gemiddeld werk:  " -NoNewline
    Write-Host "$avgWork uur/dag" -ForegroundColor $(if ($avgWork -gt 12) { "Red" } elseif ($avgWork -gt 8) { "Yellow" } else { "Green" })
    Write-Host "  Maximum:         $maxWork uur" -ForegroundColor Gray
    Write-Host "  Minimum:         $minWork uur" -ForegroundColor Gray
    Write-Host ""

    # Show last 7 days in detail
    Write-Host "  Laatste dagen:" -ForegroundColor Gray
    $dailyStats | Select-Object -Last 7 | ForEach-Object {
        $color = if ($_.WorkHours -gt 12) { "Red" } elseif ($_.WorkHours -gt 8) { "Yellow" } else { "Green" }
        $bar = "█" * [Math]::Min([Math]::Floor($_.WorkHours), 20)
        Write-Host "    $($_.Date)  " -NoNewline -ForegroundColor Gray
        Write-Host "$($_.WorkHours) uur " -NoNewline -ForegroundColor $color
        Write-Host $bar -ForegroundColor $color
    }
    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Warning if extreme hours
if ($workHours -gt 14) {
    Write-Host "⚠ WARNING: >14 uur werk vandaag - dit is niet houdbaar" -ForegroundColor Red
    Write-Host ""
}

if ($sleepHours -ne "?" -and $sleepHours -lt 6) {
    Write-Host "⚠ WARNING: <6 uur slaap - verhoogd risico burnout/psychose" -ForegroundColor Red
    Write-Host ""
}
