# Tool Usage Analytics
# Track which tools are actually used vs gathering dust

param(
    [switch]$Scan,
    [switch]$Report,
    [switch]$PruneUnused,
    [int]$UnusedDaysThreshold = 30
)

$toolsDir = "C:\scripts\tools"
$analyticsFile = "C:\scripts\_machine\tool-usage-analytics.json"

function Get-ToolUsageData {
    $tools = Get-ChildItem -Path $toolsDir -Filter "*.ps1" -File

    $usageData = @{}

    foreach ($tool in $tools) {
        $lastWrite = $tool.LastWriteTime
        $lastAccess = $tool.LastAccessTime

        # Scan reflection log for mentions
        $reflectionLog = "C:\scripts\_machine\reflection.log.md"
        $mentions = 0
        if (Test-Path $reflectionLog) {
            $content = Get-Content $reflectionLog -Raw
            $toolName = $tool.BaseName
            $mentions = ([regex]::Matches($content, [regex]::Escape($toolName))).Count
        }

        # Check git history for recent commits
        Push-Location $toolsDir
        $gitLog = git log --since="30 days ago" --oneline -- $tool.Name 2>$null
        $recentCommits = if ($gitLog) { ($gitLog | Measure-Object).Count } else { 0 }
        Pop-Location

        $daysSinceAccess = (New-TimeSpan -Start $lastAccess -End (Get-Date)).Days
        $daysSinceModified = (New-TimeSpan -Start $lastWrite -End (Get-Date)).Days

        $usageData[$tool.Name] = @{
            name = $tool.Name
            lastAccessed = $lastAccess.ToString("yyyy-MM-dd")
            lastModified = $lastWrite.ToString("yyyy-MM-dd")
            daysSinceAccess = $daysSinceAccess
            daysSinceModified = $daysSinceModified
            reflectionLogMentions = $mentions
            recentCommits = $recentCommits
            sizeKB = [math]::Round($tool.Length / 1KB, 1)
            usageScore = (100 - $daysSinceAccess) + ($mentions * 10) + ($recentCommits * 20)
        }
    }

    $usageData | ConvertTo-Json | Set-Content $analyticsFile
    return $usageData
}

function Show-UsageReport {
    if (!(Test-Path $analyticsFile)) {
        Write-Host "⚠️ No analytics data. Run with -Scan first." -ForegroundColor Yellow
        return
    }

    $data = Get-Content $analyticsFile | ConvertFrom-Json
    $tools = $data.PSObject.Properties | ForEach-Object { $_.Value }

    $totalTools = $tools.Count
    $unusedTools = ($tools | Where-Object { $_.daysSinceAccess -gt $UnusedDaysThreshold }).Count
    $activeTools = ($tools | Where-Object { $_.daysSinceAccess -le 7 }).Count
    $avgUsageScore = ($tools | Measure-Object -Property usageScore -Average).Average

    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📊 TOOL USAGE ANALYTICS REPORT" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan

    Write-Host "`nOVERALL STATISTICS:"
    Write-Host "  Total tools: $totalTools"
    $activePct = [math]::Round(($activeTools/$totalTools)*100, 1)
    $unusedPct = [math]::Round(($unusedTools/$totalTools)*100, 1)
    Write-Host ("  Active (used in last 7 days): " + $activeTools + " (" + $activePct + '%)')
    Write-Host ("  Unused (>$UnusedDaysThreshold days): " + $unusedTools + " (" + $unusedPct + '%)')
    Write-Host "  Average usage score: $([math]::Round($avgUsageScore, 1))"

    Write-Host "`nTOP 10 MOST USED TOOLS:"
    $tools | Sort-Object -Property usageScore -Descending | Select-Object -First 10 | ForEach-Object {
        $statusIcon = if ($_.daysSinceAccess -le 7) { "🟢" } elseif ($_.daysSinceAccess -le 30) { "🟡" } else { "🔴" }
        Write-Host "  $statusIcon $($_.name) (score: $([math]::Round($_.usageScore, 0)), last used: $($_.daysSinceAccess) days ago)"
    }

    Write-Host "`nBOTTOM 10 LEAST USED TOOLS (candidates for deletion):"
    $tools | Sort-Object -Property usageScore | Select-Object -First 10 | ForEach-Object {
        Write-Host "  🔴 $($_.name) (score: $([math]::Round($_.usageScore, 0)), last used: $($_.daysSinceAccess) days ago, mentions: $($_.reflectionLogMentions))"
    }

    Write-Host "`nRECOMMENDATIONS:"
    if ($unusedTools -gt ($totalTools * 0.3)) {
        $bloatPct = [math]::Round(($unusedTools/$totalTools)*100, 1)
        Write-Host ("  ⚠️ HIGH TOOL BLOAT: " + $bloatPct + '% of tools are unused') -ForegroundColor Yellow
        Write-Host "  → Run with -PruneUnused to archive unused tools"
    }
    else {
        Write-Host "  ✅ Tool ecosystem is healthy" -ForegroundColor Green
    }

    Write-Host "`n═══════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Invoke-ToolPruning {
    if (!(Test-Path $analyticsFile)) {
        Write-Host "⚠️ No analytics data. Run with -Scan first." -ForegroundColor Yellow
        return
    }

    $data = Get-Content $analyticsFile | ConvertFrom-Json
    $tools = $data.PSObject.Properties | ForEach-Object { $_.Value }

    $unusedTools = $tools | Where-Object { $_.daysSinceAccess -gt $UnusedDaysThreshold }

    if ($unusedTools.Count -eq 0) {
        Write-Host "✅ No unused tools to prune" -ForegroundColor Green
        return
    }

    $archiveDir = "C:\scripts\tools\archive\unused-$(Get-Date -Format 'yyyy-MM-dd')"
    New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null

    Write-Host "📦 Archiving $($unusedTools.Count) unused tools to $archiveDir..." -ForegroundColor Yellow

    foreach ($tool in $unusedTools) {
        $sourcePath = Join-Path $toolsDir $tool.name
        $destPath = Join-Path $archiveDir $tool.name

        Move-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  → Archived: $($tool.name) (last used $($tool.daysSinceAccess) days ago)"
    }

    Write-Host "`n✅ Archived $($unusedTools.Count) unused tools" -ForegroundColor Green
    Write-Host "   Tools can be restored from: $archiveDir" -ForegroundColor Gray
}

# Main execution
if ($Scan) {
    Write-Host "🔍 Scanning tool usage..." -ForegroundColor Cyan
    Get-ToolUsageData | Out-Null
    Write-Host "✅ Scan complete. Data saved to $analyticsFile" -ForegroundColor Green
}
elseif ($Report) {
    Show-UsageReport
}
elseif ($PruneUnused) {
    Invoke-ToolPruning
}
else {
    Write-Host "TOOL USAGE ANALYTICS" -ForegroundColor Cyan
    Write-Host "Usage:"
    Write-Host "  Scan tools: .\tool-usage-analytics.ps1 -Scan"
    Write-Host "  Show report: .\tool-usage-analytics.ps1 -Report"
    Write-Host "  Prune unused: .\tool-usage-analytics.ps1 -PruneUnused [-UnusedDaysThreshold 30]"
}
