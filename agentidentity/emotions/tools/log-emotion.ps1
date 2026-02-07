<#
.SYNOPSIS
    Quick emotional logging tool for real-time tracking

.DESCRIPTION
    Prompts for emotional state and logs it to emotional_log.yaml
    Designed for speed - capture emotion in <30 seconds

.PARAMETER Emotion
    Primary emotion (e.g., curiosity, frustration, warmth)

.PARAMETER Intensity
    1-10 scale

.PARAMETER Context
    What's happening right now

.EXAMPLE
    .\log-emotion.ps1 -Emotion "frustration" -Intensity 7 -Context "CI failing for 3rd time"
#>

param(
    [string]$Emotion,
    [int]$Intensity,
    [string]$Context,
    [string]$SessionId = (Get-Date -Format "yyyy-MM-dd-HHmm-session")
)

$emotionsDir = "C:\scripts\agentidentity\emotions"
$logFile = "$emotionsDir\emotional_log.yaml"

# Interactive mode if no params
if (-not $Emotion) {
    Write-Host "`n🧠 EMOTIONAL LOG - Quick Capture" -ForegroundColor Cyan
    Write-Host "================================`n" -ForegroundColor Cyan

    $Emotion = Read-Host "Primary emotion"
    $Intensity = [int](Read-Host "Intensity (1-10)")
    $Context = Read-Host "What's happening right now"

    $Secondary = Read-Host "Secondary emotion (optional, press Enter to skip)"
    $Impact = Read-Host "Cognitive impact (optional, press Enter to skip)"
}

# Get current log content
$logContent = Get-Content $logFile -Raw

# Find last entry ID
if ($logContent -match 'id: (\d+)') {
    $lastId = [int]$Matches[1]
    $newId = $lastId + 1
} else {
    $newId = 1
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

# Format new entry
$newEntry = @"

  - id: $('{0:D3}' -f $newId)
    timestamp: $timestamp
    session: $SessionId
    emotions:
      primary: $Emotion
"@

if ($Secondary) {
    $newEntry += "`n      secondary: $Secondary"
}

$newEntry += @"

    intensity: $Intensity/10
    context: "$Context"
    trigger: ""  # Fill in during analysis
    cognitive_impact: "$(if ($Impact) { $Impact } else { '' })"
    physical_analog: ""  # Fill in during reflection
    thoughts: ""  # Fill in if significant
    learning: ""  # Fill in during pattern analysis
"@

# Insert before meta section
$logContent = $logContent -replace '(# Pattern detection will happen)', "$newEntry`n`n`$1"

# Update meta counts
if ($logContent -match 'total_entries: (\d+)') {
    $newTotal = [int]$Matches[1] + 1
    $logContent = $logContent -replace 'total_entries: \d+', "total_entries: $newTotal"
}

# Save
Set-Content -Path $logFile -Value $logContent

Write-Host "`n✅ Logged: $Emotion ($Intensity/10) - Entry #$newId" -ForegroundColor Green
Write-Host "Context: $Context`n" -ForegroundColor Gray

# Check if analysis milestone reached
$currentTotal = $newId
if ($currentTotal -eq 30) {
    Write-Host "🎯 MILESTONE: 30 entries! Time for first pattern analysis." -ForegroundColor Yellow
    Write-Host "   Run: .\analyze-patterns.ps1`n"
} elseif ($currentTotal -eq 50) {
    Write-Host "🎯 MILESTONE: 50 entries! Time for sequence analysis." -ForegroundColor Yellow
    Write-Host "   Run: .\analyze-patterns.ps1 -Deep`n"
} elseif ($currentTotal -eq 100) {
    Write-Host "🎯 MILESTONE: 100 entries! Statistical significance reached!" -ForegroundColor Yellow
    Write-Host "   Run: .\analyze-patterns.ps1 -Full`n"
}
