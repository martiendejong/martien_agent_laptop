# Simple ManicTime worker - minimal version that works
$ErrorActionPreference = "Continue"

$dbPath = "$env:LOCALAPPDATA\Finkit\ManicTime\ManicTimeReports.db"
$statePath = "E:\jengo\health\manictime-state.json"
$eventsPath = "E:\jengo\health\manictime-events.jsonl"

# Ensure dirs exist
New-Item -ItemType Directory -Path (Split-Path $statePath -Parent) -Force -ErrorAction SilentlyContinue | Out-Null

Write-Host "Database: $dbPath"
Write-Host "State: $statePath"
Write-Host "Events: $eventsPath"

# Load or initialize state
if (Test-Path $statePath) {
    $stateJson = Get-Content $statePath -Raw
    $state = $stateJson | ConvertFrom-Json
    $lastProcessed = $state.lastProcessedTimestamp
    Write-Host "Last processed: $lastProcessed"
} else {
    $lastProcessed = (Get-Date).AddHours(-1).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "First run - starting from: $lastProcessed"
}

# Query using Python
$query = @"
import sqlite3, json
from datetime import datetime

conn = sqlite3.connect(r'$dbPath')
cursor = conn.cursor()

cursor.execute('''
    SELECT ActivityId, Name, StartLocalTime, EndLocalTime
    FROM Ar_Activity
    WHERE StartLocalTime > ?
    ORDER BY StartLocalTime ASC
    LIMIT 50
''', ('$lastProcessed',))

activities = [{'id': r[0], 'name': r[1], 'start': r[2], 'end': r[3]} for r in cursor.fetchall()]
print(json.dumps(activities))
conn.close()
"@

$tempPy = "$env:TEMP\mt-query.py"
$query | Out-File $tempPy -Encoding UTF8

Write-Host "Running query..."
$result = python $tempPy
Remove-Item $tempPy -Force

if ($LASTEXITCODE -ne 0) {
    Write-Host "Python error: $result"
    exit 1
}

$activities = $result | ConvertFrom-Json
Write-Host "Found $($activities.Count) activities"

# Publish events
foreach ($act in $activities) {
    $event = @{
        timestamp = (Get-Date).ToString("o")
        eventType = "ActivityDetected"
        data = $act
    } | ConvertTo-Json -Compress

    Add-Content -Path $eventsPath -Value $event
}

# Update state
if ($activities.Count -gt 0) {
    $newState = @{
        lastProcessedTimestamp = $activities[-1].end
        lastRun = (Get-Date).ToString("o")
        count = $activities.Count
    } | ConvertTo-Json

    $newState | Out-File $statePath -Force
    Write-Host "State updated"
}

Write-Host "Done - processed $($activities.Count) activities"
