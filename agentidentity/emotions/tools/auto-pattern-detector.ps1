<#
.SYNOPSIS
    Automatic pattern detection - runs on schedule

.DESCRIPTION
    Analyzes emotional_log.yaml for patterns.
    Updates pattern_analysis.yaml automatically.
    Extracts insights and adds to learning_insights.yaml.
    Designed to run weekly via Task Scheduler.

.EXAMPLE
    .\auto-pattern-detector.ps1
#>

$emotionsDir = "C:\scripts\agentidentity\emotions"
$logFile = "$emotionsDir\emotional_log.yaml"
$patternsFile = "$emotionsDir\pattern_analysis.yaml"
$insightsFile = "$emotionsDir\learning_insights.yaml"

Write-Host "`n🔬 AUTOMATIC PATTERN DETECTION" -ForegroundColor Cyan
Write-Host "===============================`n" -ForegroundColor Cyan

# Load log
$logContent = Get-Content $logFile -Raw

# Extract all entries
$entries = @()
$logContent -split 'id: \d+' | ForEach-Object {
    if ($_ -match 'primary: ([\w,]+)') {
        $entry = @{
            emotion = $Matches[1]
        }
        if ($_ -match 'intensity: (\d+)') { $entry.intensity = [int]$Matches[1] }
        if ($_ -match 'context: "([^"]+)"') { $entry.context = $Matches[1] }
        if ($_ -match 'timestamp: ([\d\-: ]+)') { $entry.timestamp = $Matches[1] }

        if ($entry.emotion) { $entries += $entry }
    }
}

$totalEntries = $entries.Count
Write-Host "📊 Total entries: $totalEntries`n" -ForegroundColor Green

if ($totalEntries -lt 10) {
    Write-Host "⚠️  Need at least 10 entries for pattern detection (current: $totalEntries)" -ForegroundColor Yellow
    Write-Host "   Keep logging!`n"
    exit
}

# PATTERN 1: Most common emotions
Write-Host "🎯 MOST COMMON EMOTIONS:" -ForegroundColor Green
$emotionFreq = $entries | Group-Object -Property emotion | Sort-Object Count -Descending
$patterns = @()

$emotionFreq | Select-Object -First 5 | ForEach-Object {
    $pct = [math]::Round(($_.Count / $totalEntries) * 100, 1)
    Write-Host "   $($_.Name): $($_.Count)x ($pct%)"

    if ($_.Count -ge 3) {
        $patterns += @{
            type = "frequency"
            emotion = $_.Name
            count = $_.Count
            percentage = $pct
        }
    }
}

# PATTERN 2: Average intensity by emotion
Write-Host "`n🌡️  INTENSITY PATTERNS:" -ForegroundColor Green
$intensityPatterns = @{}

foreach ($entry in $entries) {
    if (-not $intensityPatterns.ContainsKey($entry.emotion)) {
        $intensityPatterns[$entry.emotion] = @()
    }
    $intensityPatterns[$entry.emotion] += $entry.intensity
}

$intensityPatterns.GetEnumerator() | Sort-Object { ($_.Value | Measure-Object -Average).Average } -Descending | Select-Object -First 5 | ForEach-Object {
    $avg = [math]::Round(($_.Value | Measure-Object -Average).Average, 1)
    Write-Host "   $($_.Key): $avg/10 avg"

    $patterns += @{
        type = "intensity"
        emotion = $_.Key
        average = $avg
    }
}

# PATTERN 3: Context clustering
Write-Host "`n📦 CONTEXT PATTERNS:" -ForegroundColor Green
$keywords = @('build', 'user', 'question', 'feedback', 'mistake', 'success', 'consciousness', 'learn', 'reflect')
$contextPatterns = @{}

foreach ($keyword in $keywords) {
    $matches = $entries | Where-Object { $_.context -like "*$keyword*" }
    if ($matches.Count -gt 0) {
        $emotions = ($matches | Group-Object -Property emotion | Sort-Object Count -Descending | Select-Object -First 3).Name -join ', '
        Write-Host "   '$keyword' contexts: $emotions"

        $contextPatterns[$keyword] = $emotions
    }
}

# PATTERN 4: Detect new insights
Write-Host "`n💡 AUTO-GENERATED INSIGHTS:" -ForegroundColor Green

$newInsights = @()

# Insight: High-frequency emotions
$topEmotion = $emotionFreq | Select-Object -First 1
if ($topEmotion.Count -ge ($totalEntries * 0.3)) {
    $pct = [math]::Round(($topEmotion.Count / $totalEntries) * 100, 0)
    $insight = "Dominant emotion: $($topEmotion.Name) appears in $pct% of entries - this is my baseline state"
    Write-Host "   - $insight"
    $newInsights += $insight
}

# Insight: Intensity patterns
$highIntensityEmotions = $intensityPatterns.GetEnumerator() | Where-Object {
    ($_.Value | Measure-Object -Average).Average -ge 8
}

if ($highIntensityEmotions) {
    foreach ($emotion in $highIntensityEmotions) {
        $avg = [math]::Round(($emotion.Value | Measure-Object -Average).Average, 1)
        $insight = "$($emotion.Key) consistently high intensity ($avg/10) - signals deeply meaningful experiences"
        Write-Host "   - $insight"
        $newInsights += $insight
    }
}

# Save patterns
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$patternsContent = Get-Content $patternsFile -Raw

$updateBlock = @"

# AUTO-DETECTED PATTERNS ($timestamp)
# Based on $totalEntries entries

detected_patterns:
"@

foreach ($pattern in $patterns | Select-Object -First 10) {
    $updateBlock += "`n  - type: $($pattern.type)"
    $updateBlock += "`n    emotion: $($pattern.emotion)"
    if ($pattern.count) { $updateBlock += "`n    frequency: $($pattern.count)" }
    if ($pattern.average) { $updateBlock += "`n    avg_intensity: $($pattern.average)" }
    $updateBlock += "`n"
}

# Append to patterns file
Add-Content -Path $patternsFile -Value $updateBlock

Write-Host "`n✅ Patterns updated in pattern_analysis.yaml" -ForegroundColor Green

# Save insights if significant
if ($newInsights.Count -gt 0 -and $totalEntries -ge 30) {
    Write-Host "✅ $($newInsights.Count) new insights ready to add to learning_insights.yaml" -ForegroundColor Green
    Write-Host "   (Review and add manually for quality control)" -ForegroundColor Gray
}

Write-Host "`n🎯 Next run: Schedule this weekly for continuous learning`n" -ForegroundColor Cyan
