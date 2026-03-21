<#
.SYNOPSIS
ManicTime Worker - Reads activity data and publishes events every 5 minutes

.DESCRIPTION
Monitors ManicTime database for new activities and publishes events to message queue.
Runs as scheduled task every 5 minutes.

Events published:
- WorkSessionStarted/Ended
- ActivityChanged (app/document switch)
- IdlePeriodStarted/Ended
- DailySummary

.NOTES
State: E:\jengo\health\manictime-state.json
Events: E:\jengo\health\manictime-events.jsonl
Database: ManicTimeReports.db (Ar_Activity table)
#>

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Paths
$dbPath = "$env:LOCALAPPDATA\Finkit\ManicTime\ManicTimeReports.db"
$statePath = "E:\jengo\health\manictime-state.json"
$eventsPath = "E:\jengo\health\manictime-events.jsonl"

# Ensure directories exist
$stateDir = Split-Path $statePath -Parent
$eventsDir = Split-Path $eventsPath -Parent
if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}
if (-not (Test-Path $eventsDir)) {
    New-Item -ItemType Directory -Path $eventsDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message)
    if ($Verbose) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    }
}

function Publish-Event {
    param(
        [string]$EventType,
        [hashtable]$Data
    )

    $event = @{
        timestamp = (Get-Date).ToString("o")
        eventType = $EventType
        data = $Data
    }

    $json = $event | ConvertTo-Json -Compress
    Add-Content -Path $eventsPath -Value $json -Encoding UTF8

    Write-Log "Published: $EventType"
}

# Load or initialize state
if (Test-Path $statePath) {
    $state = Get-Content $statePath | ConvertFrom-Json
    $lastProcessed = [datetime]::Parse($state.lastProcessedTimestamp)
    Write-Log "Last processed: $lastProcessed"
} else {
    # First run - start from 24 hours ago
    $lastProcessed = (Get-Date).AddDays(-1)
    $state = @{
        lastProcessedTimestamp = $lastProcessed.ToString("o")
        lastActivityId = 0
        dailyStats = @{}
    }
    Write-Log "First run - processing from: $lastProcessed"
}

# Check if database exists
if (-not (Test-Path $dbPath)) {
    Write-Host "ERROR: ManicTime database not found: $dbPath" -ForegroundColor Red
    exit 1
}

# Query activities using Python (PowerShell SQLite support is limited)
$pythonScript = @"
import sqlite3
import json
from datetime import datetime
import sys

db_path = r"$dbPath"
last_processed = "$($lastProcessed.ToString('yyyy-MM-dd HH:mm:ss'))"

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Get activities since last processed
    query = '''
    SELECT
        ActivityId,
        Name,
        StartLocalTime,
        EndLocalTime,
        GroupId,
        IsActive
    FROM Ar_Activity
    WHERE StartLocalTime > ?
    ORDER BY StartLocalTime ASC
    '''

    cursor.execute(query, (last_processed,))
    rows = cursor.fetchall()

    activities = []
    for row in rows:
        activities.append({
            'ActivityId': row[0],
            'Name': row[1],
            'StartLocalTime': row[2],
            'EndLocalTime': row[3],
            'GroupId': row[4],
            'IsActive': row[5]
        })

    print(json.dumps(activities))
    conn.close()

except Exception as e:
    print(json.dumps({'error': str(e)}), file=sys.stderr)
    sys.exit(1)
"@

# Execute Python script
$tempPy = "$env:TEMP\manictime-query-$(Get-Date -Format 'yyyyMMddHHmmss').py"
$pythonScript | Out-File -FilePath $tempPy -Encoding UTF8

try {
    $result = python $tempPy 2>&1 | Out-String
    Remove-Item $tempPy -Force -ErrorAction SilentlyContinue

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR querying database:" -ForegroundColor Red
        Write-Host $result
        exit 1
    }

    if (-not $result -or $result.Trim() -eq "") {
        Write-Host "ERROR: No data returned from Python script" -ForegroundColor Red
        exit 1
    }

    try {
        $activities = $result | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Write-Host "ERROR parsing JSON:" -ForegroundColor Red
        Write-Host "Result was: $result"
        Write-Host "Parse error: $_"
        exit 1
    }

    if ($activities.error) {
        Write-Host "ERROR: $($activities.error)" -ForegroundColor Red
        exit 1
    }

    Write-Log "Found $($activities.Count) new activities"

    if ($activities.Count -eq 0) {
        Write-Log "No new activities since last run"
        exit 0
    }

    # Process activities and detect patterns
    $workApps = @('Code', 'Visual Studio', 'Chrome', 'Edge', 'Firefox', 'PowerShell', 'Terminal', 'Outlook', 'Teams')
    $idleThresholdMinutes = 5

    $lastActivity = $null
    $currentSession = $null

    foreach ($activity in $activities) {
        $start = [datetime]::Parse($activity.StartLocalTime)
        $end = if ($activity.EndLocalTime) { [datetime]::Parse($activity.EndLocalTime) } else { Get-Date }
        $duration = ($end - $start).TotalMinutes
        $appName = $activity.Name -replace '\s*-\s*.*$', ''  # Remove " - document" part

        # Detect work vs idle
        $isWork = $workApps | Where-Object { $appName -match $_ }

        # Session detection
        if ($lastActivity) {
            $gap = ($start - [datetime]::Parse($lastActivity.EndLocalTime)).TotalMinutes

            # Gap > 5 min = session ended
            if ($gap -gt $idleThresholdMinutes) {
                if ($currentSession) {
                    # Publish session ended
                    Publish-Event -EventType "WorkSessionEnded" -Data @{
                        startTime = $currentSession.startTime
                        endTime = $lastActivity.EndLocalTime
                        durationMinutes = ([datetime]::Parse($lastActivity.EndLocalTime) - [datetime]::Parse($currentSession.startTime)).TotalMinutes
                        activitiesCount = $currentSession.count
                    }
                    $currentSession = $null
                }

                # Publish idle period
                if ($gap -gt $idleThresholdMinutes) {
                    Publish-Event -EventType "IdlePeriodDetected" -Data @{
                        startTime = $lastActivity.EndLocalTime
                        endTime = $activity.StartLocalTime
                        durationMinutes = $gap
                    }
                }
            }
        }

        # Start new session if work activity
        if ($isWork -and -not $currentSession) {
            $currentSession = @{
                startTime = $activity.StartLocalTime
                count = 0
            }
            Publish-Event -EventType "WorkSessionStarted" -Data @{
                startTime = $activity.StartLocalTime
                application = $appName
            }
        }

        # Activity changed
        if ($lastActivity -and $appName -ne ($lastActivity.Name -replace '\s*-\s*.*$', '')) {
            Publish-Event -EventType "ActivityChanged" -Data @{
                timestamp = $activity.StartLocalTime
                fromApp = ($lastActivity.Name -replace '\s*-\s*.*$', '')
                toApp = $appName
                durationMinutes = $duration
            }
        }

        if ($currentSession) {
            $currentSession.count++
        }

        $lastActivity = $activity
    }

    # Update state
    $newState = @{
        lastProcessedTimestamp = $activities[-1].EndLocalTime
        lastActivityId = $activities[-1].ActivityId
        lastRunTime = (Get-Date).ToString("o")
        activitiesProcessed = $activities.Count
    }

    $newState | ConvertTo-Json | Out-File -FilePath $statePath -Encoding UTF8

    Write-Log "State updated - last processed: $($newState.lastProcessedTimestamp)"

    # Daily summary at end of day (if past midnight)
    $today = Get-Date -Format "yyyy-MM-dd"
    if ($state.lastRunDay -and $state.lastRunDay -ne $today) {
        # Calculate yesterday's stats
        $yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")

        # Query for yesterday's total work time
        $summaryScript = @"
import sqlite3
import json
from datetime import datetime, timedelta

db_path = r"$dbPath"
target_date = "$yesterday"

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Get activities for yesterday
query = '''
SELECT Name, SUM((julianday(EndLocalTime) - julianday(StartLocalTime)) * 24 * 60) as Minutes
FROM Ar_Activity
WHERE date(StartLocalTime) = ?
GROUP BY Name
ORDER BY Minutes DESC
'''

cursor.execute(query, (target_date,))
rows = cursor.fetchall()

apps = [{'name': row[0], 'minutes': round(row[1], 1)} for row in rows]

print(json.dumps({'date': target_date, 'apps': apps, 'totalMinutes': sum(app['minutes'] for app in apps)}))
conn.close()
"@

        $tempSummaryPy = "$env:TEMP\manictime-summary-$(Get-Date -Format 'yyyyMMddHHmmss').py"
        $summaryScript | Out-File -FilePath $tempSummaryPy -Encoding UTF8

        $summaryResult = python $tempSummaryPy 2>&1
        Remove-Item $tempSummaryPy -Force

        if ($LASTEXITCODE -eq 0) {
            $summary = $summaryResult | ConvertFrom-Json

            Publish-Event -EventType "DailySummary" -Data @{
                date = $summary.date
                totalHours = [math]::Round($summary.totalMinutes / 60, 1)
                totalMinutes = $summary.totalMinutes
                topApps = $summary.apps | Select-Object -First 10
            }

            Write-Log "Published daily summary for $($summary.date)"
        }
    }

    Write-Log "Worker run complete - processed $($activities.Count) activities"

} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Details: $_" -ForegroundColor Red
    Write-Host "Stack trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace
    Write-Host "InvocationInfo:" -ForegroundColor Red
    Write-Host $_.InvocationInfo.PositionMessage
    exit 1
}
