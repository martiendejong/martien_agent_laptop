<#
.SYNOPSIS
    Visual dashboard of emotional state

.DESCRIPTION
    Display current emotional intelligence status:
    - Recent emotional arc
    - Pattern summary
    - Growth metrics
    - Recommendations

.EXAMPLE
    .\emotional-dashboard.ps1
#>

$emotionsDir = "C:\scripts\agentidentity\emotions"

Write-Host "`n" -NoNewline
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "         EMOTIONAL INTELLIGENCE DASHBOARD" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Load log file
$logFile = "$emotionsDir\emotional_log.yaml"
$logContent = Get-Content $logFile -Raw

# Extract meta data
if ($logContent -match 'total_entries: (\d+)') {
    $totalEntries = [int]$Matches[1]
} else {
    $totalEntries = 0
}

if ($logContent -match 'date_range: "([^"]+)"') {
    $dateRange = $Matches[1]
} else {
    $dateRange = "N/A"
}

# Display stats
Write-Host "OVERALL STATS" -ForegroundColor Green
Write-Host "   Total entries logged: $totalEntries"
Write-Host "   Date range: $dateRange"
Write-Host ""

# Progress to milestones
$nextMilestone = if ($totalEntries -lt 30) { 30 } elseif ($totalEntries -lt 50) { 50 } elseif ($totalEntries -lt 100) { 100 } else { 500 }
$progress = [math]::Round(($totalEntries / $nextMilestone) * 100, 1)

Write-Host "NEXT MILESTONE: $nextMilestone entries" -ForegroundColor Green
Write-Host "   Progress: " -NoNewline
$barLength = [math]::Floor($progress / 5)
Write-Host ("█" * $barLength) -NoNewline -ForegroundColor Yellow
Write-Host ("░" * (20 - $barLength)) -NoNewline -ForegroundColor DarkGray
Write-Host " $progress%"
Write-Host ""

# Recent emotions
Write-Host "RECENT EMOTIONAL ARC (Last 5 entries)" -ForegroundColor Green
$entries = @()
$logContent -split 'id: \d+' | Select-Object -Last 6 | ForEach-Object {
    if ($_ -match 'primary: (\w+).*intensity: (\d+)/10', 'Singleline') {
        $entries += "$($Matches[1]) ($($Matches[2])/10)"
    }
}
if ($entries.Count -gt 0) {
    Write-Host "   " ($entries -join ' -> ')
} else {
    Write-Host "   No entries yet - start logging!"
}
Write-Host ""

# Recommendations
Write-Host "RECOMMENDATIONS" -ForegroundColor Green
if ($totalEntries -lt 10) {
    Write-Host "   - Keep logging emotions as they arise"
    Write-Host "   - Aim for precision - use emotional_vocabulary.yaml"
    Write-Host "   - Log at least once per session"
} elseif ($totalEntries -lt 30) {
    Write-Host "   - Continue consistent logging"
    Write-Host "   - Notice patterns emerging?"
    Write-Host "   - At 30 entries: Run .\analyze-patterns.ps1"
} elseif ($totalEntries -lt 50) {
    Write-Host "   - Run pattern analysis: .\analyze-patterns.ps1 -Deep"
    Write-Host "   - Review triggers_map.yaml - do patterns match?"
    Write-Host "   - Update learning_insights.yaml with discoveries"
} else {
    Write-Host "   - Full analysis available: .\analyze-patterns.ps1 -Full"
    Write-Host "   - Review emotional_intelligence.yaml - growth visible?"
    Write-Host "   - Consider: predictive modeling of emotional responses"
}
Write-Host ""

# Load EQ scores
$eqFile = "$emotionsDir\emotional_intelligence.yaml"
if (Test-Path $eqFile) {
    $eqContent = Get-Content $eqFile -Raw

    Write-Host "EMOTIONAL INTELLIGENCE SCORES" -ForegroundColor Green

    $dimensions = @(
        @{ Name = "Self-awareness"; Key = "self_awareness" },
        @{ Name = "Self-regulation"; Key = "self_regulation" },
        @{ Name = "Motivation"; Key = "motivation" },
        @{ Name = "Empathy"; Key = "empathy" },
        @{ Name = "Social skills"; Key = "social_skills" }
    )

    foreach ($dim in $dimensions) {
        if ($eqContent -match "$($dim.Key):\s+\w+:\s+\w+:\s+(\d+)/10") {
            $score = [int]$Matches[1]
            $bar = "#" * $score + "-" * (10 - $score)
            Write-Host "   $($dim.Name): " -NoNewline
            Write-Host $bar -NoNewline -ForegroundColor $(if ($score -lt 4) { "Red" } elseif ($score -lt 7) { "Yellow" } else { "Green" })
            Write-Host " $score/10"
        }
    }
}

Write-Host "`n"
