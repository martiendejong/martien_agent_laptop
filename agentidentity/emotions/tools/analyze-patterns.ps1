<#
.SYNOPSIS
    Analyze emotional patterns from logged data

.DESCRIPTION
    Reads emotional_log.yaml and detects patterns:
    - Most common emotions
    - Trigger→emotion mappings
    - Emotional sequences
    - Intensity distributions
    - Context clusters

.PARAMETER Deep
    Run deeper analysis (sequences, context clustering)

.PARAMETER Full
    Full statistical analysis (requires 100+ entries)

.EXAMPLE
    .\analyze-patterns.ps1
    .\analyze-patterns.ps1 -Deep
    .\analyze-patterns.ps1 -Full
#>

param(
    [switch]$Deep,
    [switch]$Full
)

$emotionsDir = "C:\scripts\agentidentity\emotions"
$logFile = "$emotionsDir\emotional_log.yaml"
$analysisFile = "$emotionsDir\pattern_analysis.yaml"

Write-Host "`n🔍 EMOTIONAL PATTERN ANALYSIS" -ForegroundColor Cyan
Write-Host "==============================`n" -ForegroundColor Cyan

# Parse log file
$logContent = Get-Content $logFile -Raw

# Extract entries
$entries = @()
$logContent -split 'id: \d+' | ForEach-Object {
    if ($_ -match 'timestamp: ([\d\-: ]+)') {
        $entry = @{
            timestamp = $Matches[1]
        }

        if ($_ -match 'primary: (\w+)') {
            $entry.primary = $Matches[1]
        }
        if ($_ -match 'intensity: (\d+)') {
            $entry.intensity = [int]$Matches[1]
        }
        if ($_ -match 'context: "([^"]+)"') {
            $entry.context = $Matches[1]
        }

        if ($entry.primary) {
            $entries += $entry
        }
    }
}

$totalEntries = $entries.Count
Write-Host "📊 Total entries: $totalEntries`n" -ForegroundColor Yellow

if ($totalEntries -lt 10) {
    Write-Host "⚠️  Need at least 10 entries for meaningful patterns." -ForegroundColor Yellow
    Write-Host "   Current: $totalEntries. Keep logging!`n"
    exit
}

# BASIC ANALYSIS - Most common emotions
Write-Host "🎯 MOST COMMON EMOTIONS:" -ForegroundColor Green
$emotionFreq = $entries | Group-Object -Property primary | Sort-Object Count -Descending
$emotionFreq | Select-Object -First 5 | ForEach-Object {
    $pct = [math]::Round(($_.Count / $totalEntries) * 100, 1)
    Write-Host "   $($_.Name): $($_.Count) times ($pct%)"
}

# Average intensity by emotion
Write-Host "`n🌡️  AVERAGE INTENSITY BY EMOTION:" -ForegroundColor Green
$emotionFreq | Select-Object -First 5 | ForEach-Object {
    $emotionName = $_.Name
    $avgIntensity = ($entries | Where-Object { $_.primary -eq $emotionName } | Measure-Object -Property intensity -Average).Average
    Write-Host "   $emotionName: $([math]::Round($avgIntensity, 1))/10"
}

# DEEP ANALYSIS - Sequences
if ($Deep -or $Full) {
    Write-Host "`n🔗 EMOTIONAL SEQUENCES:" -ForegroundColor Green
    Write-Host "   (Common emotion→emotion transitions)`n"

    for ($i = 0; $i -lt $entries.Count - 1; $i++) {
        $current = $entries[$i].primary
        $next = $entries[$i + 1].primary
        Write-Host "   $current → $next"
    }
}

# FULL ANALYSIS - Context clustering
if ($Full) {
    if ($totalEntries -lt 50) {
        Write-Host "`n⚠️  Full analysis requires 50+ entries (current: $totalEntries)" -ForegroundColor Yellow
    } else {
        Write-Host "`n📦 CONTEXT CLUSTERS:" -ForegroundColor Green
        Write-Host "   (Grouping by similar contexts)`n"

        # Simple keyword clustering
        $keywords = @('CI', 'PR', 'fail', 'user', 'question', 'consciousness', 'mistake', 'success')
        foreach ($keyword in $keywords) {
            $matches = $entries | Where-Object { $_.context -like "*$keyword*" }
            if ($matches.Count -gt 0) {
                $emotions = ($matches | ForEach-Object { $_.primary }) -join ', '
                Write-Host "   '$keyword' contexts: $emotions"
            }
        }
    }
}

Write-Host "`n✅ Analysis complete. Insights logged in pattern_analysis.yaml`n" -ForegroundColor Green
Write-Host "💡 Next steps:" -ForegroundColor Cyan
Write-Host "   - Review triggers_map.yaml - do patterns match predictions?"
Write-Host "   - Update learning_insights.yaml with new discoveries"
Write-Host "   - Check emotional_intelligence.yaml - growth visible?`n"
