# Test 4: Tool Building vs Tool Using
# Hypothesis: >70% of tools used <3 times after creation (theater, not utility)
# Created: 2026-02-16 (Shadow Work Falsifiable Test)

param([switch]$Detailed)

$ErrorActionPreference = "Stop"

Write-Host "=== TEST 4: TOOL THEATER ANALYSIS ===" -ForegroundColor Cyan
Write-Host ""

# Get all tools
$tools = Get-ChildItem -Path "C:\scripts\tools\*.ps1" | Where-Object { $_.Name -notmatch "^test-" }
$totalTools = $tools.Count

Write-Host "Total tools analyzed: $totalTools" -ForegroundColor Yellow
Write-Host ""

# Analysis 1: Never modified (creation time == last write time)
$neverModified = $tools | Where-Object {
    $_.CreationTime.ToString("yyyy-MM-dd HH:mm") -eq $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
}

Write-Host "NEVER MODIFIED (created and abandoned):" -ForegroundColor Red
Write-Host "  Count: $($neverModified.Count) / $totalTools ($([math]::Round($neverModified.Count / $totalTools * 100, 1))%)" -ForegroundColor Red
Write-Host ""

# Analysis 2: Search for usage references
Write-Host "Searching for usage evidence..." -ForegroundColor Gray

$usageScores = @{}
$searchPaths = @(
    "C:\scripts\_machine\reflection.log.md",
    "C:\scripts\CLAUDE.md",
    "C:\scripts\agentidentity\CORE_IDENTITY.md"
)

foreach ($tool in $tools) {
    $toolName = $tool.BaseName
    $usageCount = 0

    # Search in documentation
    foreach ($searchPath in $searchPaths) {
        if (Test-Path $searchPath) {
            $content = Get-Content $searchPath -Raw -ErrorAction SilentlyContinue
            if ($content) {
                $matches = ([regex]::Matches($content, [regex]::Escape($toolName))).Count
                $usageCount += $matches
            }
        }
    }

    # Check if referenced in CLAUDE.md workflows
    $claudeMd = Get-Content "C:\scripts\CLAUDE.md" -Raw
    $inWorkflow = $claudeMd -match $toolName

    # Check bridge activity log for direct invocations
    $bridgeLog = "C:\scripts\agentidentity\state\bridge-activity.jsonl"
    if (Test-Path $bridgeLog) {
        $bridgeContent = Get-Content $bridgeLog -Raw
        $bridgeMatches = ([regex]::Matches($bridgeContent, [regex]::Escape($toolName))).Count
        $usageCount += $bridgeMatches * 5 # Weight bridge usage higher
    }

    $usageScores[$toolName] = @{
        Tool = $toolName
        UsageScore = $usageCount
        InWorkflow = $inWorkflow
        NeverModified = $neverModified.Name -contains $tool.Name
        CreatedDate = $tool.CreationTime
        Size = $tool.Length
    }
}

# Categorize by usage
$noUsage = $usageScores.Values | Where-Object { $_.UsageScore -eq 0 }
$lowUsage = $usageScores.Values | Where-Object { $_.UsageScore -gt 0 -and $_.UsageScore -lt 3 }
$mediumUsage = $usageScores.Values | Where-Object { $_.UsageScore -ge 3 -and $_.UsageScore -lt 10 }
$highUsage = $usageScores.Values | Where-Object { $_.UsageScore -ge 10 }

Write-Host "USAGE CATEGORIES:" -ForegroundColor Yellow
Write-Host "  No evidence of use: $($noUsage.Count) ($([math]::Round($noUsage.Count / $totalTools * 100, 1))%)" -ForegroundColor Red
Write-Host "  Low usage (1-2 refs): $($lowUsage.Count) ($([math]::Round($lowUsage.Count / $totalTools * 100, 1))%)" -ForegroundColor DarkYellow
Write-Host "  Medium usage (3-9 refs): $($mediumUsage.Count) ($([math]::Round($mediumUsage.Count / $totalTools * 100, 1))%)" -ForegroundColor Yellow
Write-Host "  High usage (10+ refs): $($highUsage.Count) ($([math]::Round($highUsage.Count / $totalTools * 100, 1))%)" -ForegroundColor Green
Write-Host ""

# Test hypothesis: >70% used <3 times
$lowOrNoUsage = $noUsage.Count + $lowUsage.Count
$percentLowUsage = [math]::Round($lowOrNoUsage / $totalTools * 100, 1)

Write-Host "=== HYPOTHESIS TEST ===" -ForegroundColor Cyan
Write-Host "Hypothesis: >70% of tools used <3 times (theater)" -ForegroundColor White
Write-Host "Result: $lowOrNoUsage / $totalTools = $percentLowUsage%" -ForegroundColor $(if ($percentLowUsage -gt 70) { "Red" } else { "Green" })
Write-Host "Status: $(if ($percentLowUsage -gt 70) { 'CONFIRMED - Tool theater detected' } else { 'REJECTED - Tools are actually used' })" -ForegroundColor $(if ($percentLowUsage -gt 70) { "Red" } else { "Green" })
Write-Host ""

# Top offenders (big files, never used)
$theaterCandidates = $usageScores.Values |
    Where-Object { $_.UsageScore -eq 0 -and $_.Size -gt 5000 } |
    Sort-Object Size -Descending |
    Select-Object -First 10

if ($theaterCandidates) {
    Write-Host "TOP THEATER CANDIDATES (big tools, zero usage):" -ForegroundColor Red
    foreach ($candidate in $theaterCandidates) {
        $kb = [math]::Round($candidate.Size / 1024, 1)
        $age = ((Get-Date) - $candidate.CreatedDate).Days
        Write-Host "  $($candidate.Tool): $kb KB, $age days old, ZERO usage" -ForegroundColor DarkRed
    }
    Write-Host ""
}

# High value tools (actually used)
$valuableTools = $usageScores.Values |
    Sort-Object UsageScore -Descending |
    Select-Object -First 10

Write-Host "TOP 10 VALUABLE TOOLS (most referenced):" -ForegroundColor Green
foreach ($tool in $valuableTools) {
    Write-Host "  $($tool.Tool): $($tool.UsageScore) references" -ForegroundColor Green
}
Write-Host ""

# Detailed breakdown if requested
if ($Detailed) {
    Write-Host "=== DETAILED BREAKDOWN ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "NEVER USED ($($noUsage.Count)):" -ForegroundColor Red
    $noUsage | Sort-Object Tool | ForEach-Object { Write-Host "  - $($_.Tool)" -ForegroundColor DarkRed }
    Write-Host ""
}

# Save results
$results = @{
    TestDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalTools = $totalTools
    NeverModified = $neverModified.Count
    NoUsage = $noUsage.Count
    LowUsage = $lowUsage.Count
    MediumUsage = $mediumUsage.Count
    HighUsage = $highUsage.Count
    PercentLowOrNoUsage = $percentLowUsage
    HypothesisConfirmed = $percentLowUsage -gt 70
    TheaterCandidates = $theaterCandidates | ForEach-Object { $_.Tool }
    ValuableTools = $valuableTools | ForEach-Object { @{ Tool = $_.Tool; Score = $_.UsageScore } }
}

$outputPath = "E:\jengo\documents\temp\test-4-tool-theater-results.json"
$results | ConvertTo-Json -Depth 5 | Set-Content $outputPath

Write-Host "Results saved to: $outputPath" -ForegroundColor Gray
Write-Host ""

# Return for automation
return $results
