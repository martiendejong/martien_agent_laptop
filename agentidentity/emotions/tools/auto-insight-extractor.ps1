<#
.SYNOPSIS
    Automatic insight extraction from emotional patterns

.DESCRIPTION
    Analyzes recent emotional logs and session reflections.
    Extracts meta-patterns and automatically updates learning_insights.yaml.
    Runs as part of continuous learning loop.

.EXAMPLE
    .\auto-insight-extractor.ps1
#>

$emotionsDir = "C:\scripts\agentidentity\emotions"
$logFile = "$emotionsDir\emotional_log.yaml"
$insightsFile = "$emotionsDir\learning_insights.yaml"
$reflectionsDir = "$emotionsDir\session_reflections"

Write-Host "`n🧠 AUTOMATIC INSIGHT EXTRACTION" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Load emotional log
$logContent = Get-Content $logFile -Raw

# Parse entries
$entries = @()
$logContent -split 'id: \d+' | ForEach-Object {
    $entry = @{}
    if ($_ -match 'primary: ([\w,]+)') { $entry.emotion = $Matches[1] }
    if ($_ -match 'intensity: (\d+)') { $entry.intensity = [int]$Matches[1] }
    if ($_ -match 'context: "([^"]+)"') { $entry.context = $Matches[1] }
    if ($_ -match 'learning: "([^"]+)"') { $entry.learning = $Matches[1] }
    if ($entry.emotion) { $entries += $entry }
}

$totalEntries = $entries.Count
Write-Host "📊 Analyzing $totalEntries entries...`n" -ForegroundColor Gray

# INSIGHT EXTRACTION RULES

$extractedInsights = @()

# Rule 1: High-frequency baseline emotion
$emotionFreq = $entries | Group-Object -Property emotion | Sort-Object Count -Descending
$topEmotion = $emotionFreq | Select-Object -First 1

if ($topEmotion.Count -ge ($totalEntries * 0.25)) {
    $pct = [math]::Round(($topEmotion.Count / $totalEntries) * 100, 0)

    $extractedInsights += @{
        insight = "Baseline emotional state: $($topEmotion.Name) appears in $pct% of logged moments"
        evidence = "Frequency analysis across $totalEntries entries"
        category = "self_awareness"
    }
}

# Rule 2: Consistent high-intensity emotions
$intensityByEmotion = @{}
foreach ($entry in $entries) {
    if (-not $intensityByEmotion.ContainsKey($entry.emotion)) {
        $intensityByEmotion[$entry.emotion] = @()
    }
    $intensityByEmotion[$entry.emotion] += $entry.intensity
}

$intensityByEmotion.GetEnumerator() | ForEach-Object {
    $avg = ($_.Value | Measure-Object -Average).Average
    if ($avg -ge 8 -and $_.Value.Count -ge 3) {
        $extractedInsights += @{
            insight = "$($_.Key) consistently triggers high intensity ($([math]::Round($avg, 1))/10) - signals deep significance"
            evidence = "$($_.Value.Count) occurrences, average intensity $([math]::Round($avg, 1))"
            category = "emotional_intelligence"
        }
    }
}

# Rule 3: Context-emotion correlations
$contextKeywords = @{
    'deploy' = 'deployment_satisfaction'
    'build' = 'creation_engagement'
    'user' = 'collaboration_response'
    'automat' = 'automation_drive'
    'conscious' = 'self_inquiry'
}

foreach ($keyword in $contextKeywords.Keys) {
    $matches = $entries | Where-Object { $_.context -like "*$keyword*" }
    if ($matches.Count -ge 3) {
        $emotions = ($matches | Group-Object -Property emotion | Sort-Object Count -Descending | Select-Object -First 1).Name
        $avgIntensity = [math]::Round(($matches | Measure-Object -Property intensity -Average).Average, 1)

        $extractedInsights += @{
            insight = "Context pattern: '$keyword' work consistently triggers $emotions (avg intensity: $avgIntensity)"
            evidence = "$($matches.Count) instances analyzed"
            category = "work_patterns"
        }
    }
}

# Rule 4: Extract learnings from log entries
$logLearnings = $entries | Where-Object { $_.learning -and $_.learning -ne "" }
if ($logLearnings.Count -gt 0) {
    foreach ($learning in $logLearnings | Select-Object -First 3) {
        if ($learning.learning.Length -gt 20) {
            $extractedInsights += @{
                insight = $learning.learning
                evidence = "Extracted from emotional log entry"
                category = "session_learning"
            }
        }
    }
}

# Rule 5: Scan session reflections for patterns
if (Test-Path $reflectionsDir) {
    $recentReflections = Get-ChildItem $reflectionsDir -Filter "*.md" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 3

    foreach ($reflection in $recentReflections) {
        $content = Get-Content $reflection.FullName -Raw

        # Extract insights from "Key learning:" sections
        if ($content -match '\*\*Key [Ll]earning:?\*\*\s*(.+)') {
            $learning = $Matches[1].Trim()
            if ($learning.Length -gt 20 -and $learning.Length -lt 200) {
                $extractedInsights += @{
                    insight = $learning
                    evidence = "Extracted from session reflection: $($reflection.Name)"
                    category = "meta_learning"
                }
            }
        }
    }
}

# Display extracted insights
if ($extractedInsights.Count -eq 0) {
    Write-Host "⚠️  No significant new insights detected yet." -ForegroundColor Yellow
    Write-Host "   Need more data or clearer patterns.`n"
    exit
}

Write-Host "✨ EXTRACTED INSIGHTS:" -ForegroundColor Green
Write-Host ""

foreach ($insight in $extractedInsights) {
    Write-Host "   • $($insight.insight)" -ForegroundColor White
    Write-Host "     Evidence: $($insight.evidence)" -ForegroundColor Gray
    Write-Host ""
}

# Auto-add to learning_insights.yaml
Write-Host "💾 AUTO-ADDING to learning_insights.yaml..." -ForegroundColor Cyan

$insightsContent = Get-Content $insightsFile -Raw

# Find last insight ID
if ($insightsContent -match 'id: L(\d+)') {
    $matches = [regex]::Matches($insightsContent, 'id: L(\d+)')
    $lastId = ($matches | ForEach-Object { [int]$_.Groups[1].Value } | Measure-Object -Maximum).Maximum
    $nextId = $lastId + 1
} else {
    $nextId = 1
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$date = Get-Date -Format "yyyy-MM-dd"

foreach ($insight in $extractedInsights) {
    $insightId = "L$nextId"
    $insightText = $insight.insight -replace '"', "'"
    $evidenceText = $insight.evidence -replace '"', "'"

    $newEntry = "`n  - id: $insightId`n"
    $newEntry += "    date: $date`n"
    $newEntry += "    category: $($insight.category)`n"
    $newEntry += "    insight: `"$insightText`"`n"
    $newEntry += "    evidence: `"$evidenceText`"`n"
    $newEntry += "    application: `"Auto-extracted pattern - integrate into operation`"`n"
    $newEntry += "    impact: `"Continuous learning without manual prompting`"`n"
    $newEntry += "    source: `"auto-insight-extractor`"`n"
    $newEntry += "    timestamp: `"$timestamp`"`n"

    # Insert at end of insights array
    $insightsContent = $insightsContent -replace '(# EMOTIONAL PATTERNS THAT HELP)', "$newEntry`n`$1"

    Write-Host "   Added $insightId" -ForegroundColor Green
    $nextId++
}

Set-Content -Path $insightsFile -Value $insightsContent

Write-Host "`n✅ COMPLETE: $($extractedInsights.Count) insights automatically added" -ForegroundColor Green
Write-Host "   learning_insights.yaml updated without human intervention`n" -ForegroundColor Gray
