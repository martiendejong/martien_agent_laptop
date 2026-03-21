<#
.SYNOPSIS
ManicTime Worker v2 - Detects work sessions, idle periods, app switches

.DESCRIPTION
Reads ManicTime database every 5 minutes and publishes smart events:
- WorkSessionStarted/Ended
- ActivityChanged
- IdlePeriodDetected
- AppUsageSummary

State: E:\jengo\health\manictime-state.json
Events: E:\jengo\health\manictime-events.jsonl
#>

$ErrorActionPreference = "Continue"

$dbPath = "$env:LOCALAPPDATA\Finkit\ManicTime\ManicTimeReports.db"
$statePath = "E:\jengo\health\manictime-state.json"
$eventsPath = "E:\jengo\health\manictime-events.jsonl"

# Ensure dirs
New-Item -ItemType Directory -Path (Split-Path $statePath -Parent) -Force -ErrorAction SilentlyContinue | Out-Null

# Load state
if (Test-Path $statePath) {
    $state = (Get-Content $statePath -Raw) | ConvertFrom-Json
    $lastProcessed = $state.lastProcessedTimestamp
} else {
    $lastProcessed = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd HH:mm:ss")
}

# Query activities
$query = @"
import sqlite3, json
conn = sqlite3.connect(r'$dbPath')
cursor = conn.cursor()
cursor.execute('''
    SELECT ActivityId, Name, StartLocalTime, EndLocalTime, GroupId
    FROM Ar_Activity
    WHERE StartLocalTime > ?
    ORDER BY StartLocalTime ASC
''', ('$lastProcessed',))
activities = [{'id': r[0], 'name': r[1], 'start': r[2], 'end': r[3], 'group': r[4]} for r in cursor.fetchall()]
print(json.dumps(activities))
conn.close()
"@

$tempPy = "$env:TEMP\mt-query.py"
$query | Out-File $tempPy -Encoding UTF8
$result = python $tempPy
Remove-Item $tempPy -Force

if ($LASTEXITCODE -ne 0) { exit 1 }

$activities = $result | ConvertFrom-Json

if ($activities.Count -eq 0) { exit 0 }

# Work apps detection
$workApps = @('Code', 'Visual Studio', 'Chrome', 'Edge', 'Firefox', 'PowerShell', 'Terminal', 'Brave')
$idleThresholdMin = 5

$lastEnd = $null
$session = $null

foreach ($act in $activities) {
    $start = [datetime]::Parse($act.start)
    $end = if ($act.end) { [datetime]::Parse($act.end) } else { Get-Date }
    $duration = ($end - $start).TotalMinutes
    $appName = $act.name -replace '\s*[-�]\s*.*$', ''  # Remove " - document" part

    # Detect if work app
    $isWork = $workApps | Where-Object { $appName -match $_ }

    # Session logic
    if ($lastEnd) {
        $gap = ($start - $lastEnd).TotalMinutes

        # Gap > threshold = session ended
        if ($gap -gt $idleThresholdMin) {
            if ($session) {
                # Publish session end
                @{
                    timestamp = (Get-Date).ToString("o")
                    eventType = "WorkSessionEnded"
                    data = @{
                        startTime = $session.start
                        endTime = $lastEnd.ToString("yyyy-MM-dd HH:mm:ss")
                        durationMinutes = [math]::Round(($lastEnd - [datetime]::Parse($session.start)).TotalMinutes, 1)
                        activitiesCount = $session.count
                    }
                } | ConvertTo-Json -Compress | Add-Content $eventsPath

                $session = $null
            }

            # Publish idle
            @{
                timestamp = (Get-Date).ToString("o")
                eventType = "IdlePeriodDetected"
                data = @{
                    startTime = $lastEnd.ToString("yyyy-MM-dd HH:mm:ss")
                    endTime = $start.ToString("yyyy-MM-dd HH:mm:ss")
                    durationMinutes = [math]::Round($gap, 1)
                }
            } | ConvertTo-Json -Compress | Add-Content $eventsPath
        }
    }

    # Start session if work
    if ($isWork -and -not $session) {
        $session = @{
            start = $start.ToString("yyyy-MM-dd HH:mm:ss")
            count = 0
        }

        @{
            timestamp = (Get-Date).ToString("o")
            eventType = "WorkSessionStarted"
            data = @{
                startTime = $start.ToString("yyyy-MM-dd HH:mm:ss")
                application = $appName
            }
        } | ConvertTo-Json -Compress | Add-Content $eventsPath
    }

    # Activity change
    if ($lastEnd -and $appName -ne $lastApp) {
        @{
            timestamp = (Get-Date).ToString("o")
            eventType = "ActivityChanged"
            data = @{
                timestamp = $start.ToString("yyyy-MM-dd HH:mm:ss")
                fromApp = $lastApp
                toApp = $appName
                durationMinutes = [math]::Round($duration, 1)
            }
        } | ConvertTo-Json -Compress | Add-Content $eventsPath
    }

    if ($session) { $session.count++ }
    $lastEnd = $end
    $lastApp = $appName
}

# Update state
@{
    lastProcessedTimestamp = $activities[-1].end
    lastRun = (Get-Date).ToString("o")
    activitiesProcessed = $activities.Count
} | ConvertTo-Json | Out-File $statePath -Force
