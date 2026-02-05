# Session Pattern Analyzer
# Analyzes historical conversation event logs to identify patterns

$eventLog = "C:\scripts\_machine\conversation-events.log.jsonl"

if (-not (Test-Path $eventLog)) {
    Write-Error "Event log not found: $eventLog"
    exit 1
}

$events = Get-Content $eventLog | ForEach-Object {
    $_ | ConvertFrom-Json
}

# Analyze file access patterns
$fileAccess = $events | Where-Object { $_.event -eq "file_read" } |
    Group-Object -Property { $_.data.file } |
    Sort-Object Count -Descending |
    Select-Object -First 20 @{N='File';E={$_.Name}}, Count, @{N='Percent';E={[math]::Round($_.Count/$events.Count*100,2)}}

Write-Host "`n=== Most Accessed Files ===" -ForegroundColor Cyan
$fileAccess | Format-Table -AutoSize

# Analyze conversation topics
$topics = $events | Where-Object { $_.event -eq "topic_discussed" } |
    Group-Object -Property { $_.data.topic } |
    Sort-Object Count -Descending

Write-Host "`n=== Common Topics ===" -ForegroundColor Cyan
$topics | Select-Object Name, Count | Format-Table

# Analyze file access sequences
$sequences = @{}
$previousFile = $null

foreach ($event in ($events | Where-Object { $_.event -eq "file_read" })) {
    $currentFile = $event.data.file
    if ($previousFile) {
        $key = "$previousFile → $currentFile"
        $sequences[$key] = ($sequences[$key] ?? 0) + 1
    }
    $previousFile = $currentFile
}

Write-Host "`n=== Common File Access Sequences ===" -ForegroundColor Cyan
$sequences.GetEnumerator() |
    Sort-Object Value -Descending |
    Select-Object -First 15 @{N='Sequence';E={$_.Key}}, @{N='Count';E={$_.Value}} |
    Format-Table -AutoSize

# Output prediction rules
$rules = @()
foreach ($seq in ($sequences.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10)) {
    $parts = $seq.Key -split ' → '
    $rules += @{
        trigger = $parts[0]
        preload = $parts[1]
        confidence = [math]::Round($seq.Value / $fileAccess[0].Count * 100, 2)
    }
}

$rulesOutput = "C:\scripts\_machine\context-prediction-rules.yaml"
@{
    generated = (Get-Date -Format "o")
    rules = $rules
} | ConvertTo-Yaml | Set-Content $rulesOutput

Write-Host "`nPrediction rules saved to: $rulesOutput" -ForegroundColor Green
