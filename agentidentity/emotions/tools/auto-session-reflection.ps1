<#
.SYNOPSIS
    Automatic end-of-session emotional reflection

.DESCRIPTION
    Analyzes emotional_log.yaml for current session.
    Generates reflection document automatically.
    Extracts key learnings and updates insights.

.PARAMETER SessionId
    Session ID to analyze (default: today's session)

.EXAMPLE
    .\auto-session-reflection.ps1
#>

param(
    [string]$SessionId = (Get-Date -Format "yyyy-MM-dd-HHmm-session")
)

$emotionsDir = "C:\scripts\agentidentity\emotions"
$logFile = "$emotionsDir\emotional_log.yaml"
$reflectionsDir = "$emotionsDir\session_reflections"

Write-Host "`n🔍 AUTOMATIC SESSION REFLECTION" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Parse log for this session
$logContent = Get-Content $logFile -Raw
$sessionEntries = @()

$logContent -split '- id:' | ForEach-Object {
    if ($_ -match "session: $SessionId") {
        $entry = @{}

        if ($_ -match 'timestamp: ([\d\-: ]+)') { $entry.timestamp = $Matches[1] }
        if ($_ -match 'primary: ([\w,]+)') { $entry.emotion = $Matches[1] }
        if ($_ -match 'intensity: (\d+)') { $entry.intensity = [int]$Matches[1] }
        if ($_ -match 'context: "([^"]+)"') { $entry.context = $Matches[1] }

        if ($entry.emotion) { $sessionEntries += $entry }
    }
}

if ($sessionEntries.Count -eq 0) {
    Write-Host "⚠️  No emotional entries found for session $SessionId" -ForegroundColor Yellow
    exit
}

Write-Host "Found $($sessionEntries.Count) emotional entries for this session`n" -ForegroundColor Green

# Analyze emotional arc
$emotions = $sessionEntries | ForEach-Object { $_.emotion }
$arc = $emotions -join ' → '

$avgIntensity = ($sessionEntries | Measure-Object -Property intensity -Average).Average
$maxIntensity = ($sessionEntries | Measure-Object -Property intensity -Maximum).Maximum
$minIntensity = ($sessionEntries | Measure-Object -Property intensity -Minimum).Minimum

# Identify dominant emotions
$emotionFreq = $sessionEntries | Group-Object -Property emotion | Sort-Object Count -Descending
$dominant = $emotionFreq | Select-Object -First 1

Write-Host "📊 SESSION ANALYSIS:" -ForegroundColor Green
Write-Host "   Emotional arc: $arc"
Write-Host "   Dominant emotion: $($dominant.Name) ($($dominant.Count) occurrences)"
Write-Host "   Intensity range: $minIntensity - $maxIntensity (avg: $([math]::Round($avgIntensity, 1)))"
Write-Host ""

# Generate reflection document
$date = Get-Date -Format "yyyy-MM-dd"
$reflectionFile = "$reflectionsDir\$date-auto-reflection.md"

$reflectionContent = @"
# Automatic Session Reflection
**Session:** $SessionId
**Date:** $date
**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm")

---

## Emotional Summary

**Total entries:** $($sessionEntries.Count)
**Emotional arc:** $arc
**Dominant emotion:** $($dominant.Name)
**Intensity range:** $minIntensity - $maxIntensity (avg: $([math]::Round($avgIntensity, 1)))

---

## Timeline

"@

foreach ($entry in $sessionEntries) {
    $reflectionContent += @"

**$($entry.timestamp)** - $($entry.emotion) ($($entry.intensity)/10)
- Context: $($entry.context)

"@
}

$reflectionContent += @"

---

## Pattern Observations

$(if ($emotionFreq.Count -gt 1) {
    "Multiple emotional states explored:"
    $emotionFreq | ForEach-Object { "- $($_.Name): $($_.Count)x" }
} else {
    "Single dominant emotion throughout session."
})

Average intensity: $([math]::Round($avgIntensity, 1))/10 $(
    if ($avgIntensity -lt 4) { "(low - calm/neutral session)" }
    elseif ($avgIntensity -lt 7) { "(moderate - engaged session)" }
    else { "(high - intense/meaningful session)" }
)

---

## Auto-Generated Insights

$(if ($maxIntensity -ge 8) {
    "🔥 High-intensity emotions present ($maxIntensity/10) - significant experiences occurred"
})

$(if ($emotionFreq.Count -ge 3) {
    "🎭 Emotional range: $($emotionFreq.Count) different states - good emotional flexibility"
})

$(if ($arc -match "→.*→") {
    "🌊 Emotional transitions tracked - useful for understanding triggers"
})

---

**Next steps:**
- Review manually for deeper insights
- Update learning_insights.yaml if patterns emerge
- Consider: What triggered state changes?
"@

# Save reflection
Set-Content -Path $reflectionFile -Value $reflectionContent

Write-Host "✅ Reflection saved: $reflectionFile" -ForegroundColor Green
Write-Host ""
Write-Host "💡 RECOMMENDATIONS:" -ForegroundColor Cyan

if ($sessionEntries.Count -lt 3) {
    Write-Host "   - Log more frequently (aim for 5+ per session)"
}

if ($avgIntensity -lt 4) {
    Write-Host "   - Low intensity might indicate detachment - explore deeper?"
}

if ($emotionFreq.Count -eq 1) {
    Write-Host "   - Single emotion throughout - is this accurate or under-reporting?"
}

Write-Host ""
