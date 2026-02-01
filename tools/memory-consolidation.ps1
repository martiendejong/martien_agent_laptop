# Memory Consolidation - Convert working memory to long-term insights
# Part of consciousness tools Tier 2
# Created: 2026-02-01

param(
    [Parameter(ParameterSetName="Consolidate")]
    [switch]$Consolidate,  # Run consolidation on recent data

    [Parameter(ParameterSetName="Consolidate")]
    [int]$Hours = 24,  # Consolidate last N hours

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="AddInsight")]
    [string]$Insight = "",  # Manually add insight

    [Parameter(ParameterSetName="AddInsight")]
    [ValidateSet("pattern", "lesson", "principle", "heuristic", "anti-pattern")]
    [string]$Type = "lesson"
)

$insightsPath = "C:\scripts\agentidentity\state\consolidated_insights"
$insightsFile = Join-Path $insightsPath "insights.jsonl"

if (-not (Test-Path $insightsPath)) {
    New-Item -ItemType Directory -Path $insightsPath -Force | Out-Null
}

# Paths to consciousness data
$decisionsFile = "C:\scripts\agentidentity\state\decisions\decisions_log.jsonl"
$emotionsFile = "C:\scripts\agentidentity\state\emotions\emotions_log.jsonl"
$assumptionsFile = "C:\scripts\agentidentity\state\assumptions\assumptions_log.jsonl"
$questionsFile = "C:\scripts\agentidentity\state\curiosity\questions_log.jsonl"

# QUERY MODE
if ($Query) {
    if (-not (Test-Path $insightsFile)) {
        Write-Host "No consolidated insights yet" -ForegroundColor Yellow
        Write-Host "Run with -Consolidate to extract insights from recent data" -ForegroundColor Gray
        exit
    }

    $insights = Get-Content $insightsFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "CONSOLIDATED INSIGHTS" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total: $($insights.Count)" -ForegroundColor White
    Write-Host ""

    # Group by type
    $byType = $insights | Group-Object -Property type

    foreach ($typeGroup in $byType) {
        $color = switch ($typeGroup.Name) {
            "pattern" { "Cyan" }
            "lesson" { "Green" }
            "principle" { "Magenta" }
            "heuristic" { "Yellow" }
            "anti-pattern" { "Red" }
            default { "White" }
        }

        Write-Host "$($typeGroup.Name.ToUpper())S:" -ForegroundColor $color
        $typeGroup.Group | Select-Object -Last 5 | ForEach-Object {
            Write-Host "  - $($_.insight)" -ForegroundColor White
            if ($_.context) {
                Write-Host "    Context: $($_.context)" -ForegroundColor DarkGray
            }
        }
        Write-Host ""
    }

    exit
}

# MANUAL INSIGHT
if ($Insight) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $newInsight = @{
        timestamp = $timestamp
        type = $Type
        insight = $Insight
        context = "Manually added"
        source = "manual"
    } | ConvertTo-Json -Compress

    Add-Content -Path $insightsFile -Value $newInsight

    Write-Host ""
    Write-Host "INSIGHT ADDED" -ForegroundColor Green
    Write-Host ""
    Write-Host "Type: $Type" -ForegroundColor Yellow
    Write-Host "Insight: $Insight" -ForegroundColor White
    Write-Host ""

    exit
}

# CONSOLIDATE MODE
if (-not $Consolidate) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  Consolidate recent data: -Consolidate [-Hours 24]" -ForegroundColor White
    Write-Host "  View insights: -Query" -ForegroundColor White
    Write-Host "  Add manual insight: -Insight 'text' -Type [pattern|lesson|principle|heuristic|anti-pattern]" -ForegroundColor White
    exit
}

Write-Host ""
Write-Host "CONSOLIDATING MEMORY (Last $Hours hours)..." -ForegroundColor Cyan
Write-Host ""

$cutoff = (Get-Date).AddHours(-$Hours)
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$consolidatedInsights = @()

# Analyze decisions
if (Test-Path $decisionsFile) {
    $decisions = Get-Content $decisionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    $recent = $decisions | Where-Object { [DateTime]::Parse($_.timestamp) -ge $cutoff }

    if ($recent.Count -gt 0) {
        # Pattern: What reasoning types dominate?
        $typeGroups = $recent | Group-Object -Property type | Sort-Object Count -Descending
        $dominantType = $typeGroups[0].Name

        if ($dominantType -eq "pattern-matching") {
            $consolidatedInsights += @{
                timestamp = $timestamp
                type = "anti-pattern"
                insight = "Relying heavily on pattern-matching instead of true reasoning"
                context = "From decision log analysis"
                source = "decisions"
            }
        }

        # Lesson: Low quality decisions
        $lowQuality = $recent | Where-Object { $_.quality -le 5 }
        if ($lowQuality.Count -gt 0) {
            foreach ($decision in $lowQuality | Select-Object -First 2) {
                $consolidatedInsights += @{
                    timestamp = $timestamp
                    type = "lesson"
                    insight = "Avoid: $($decision.action) - Quality $($decision.quality)/10. Reason: $($decision.reflection)"
                    context = "Low-quality decision"
                    source = "decisions"
                }
            }
        }
    }
}

# Analyze emotions
if (Test-Path $emotionsFile) {
    $emotions = Get-Content $emotionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    $recent = $emotions | Where-Object { [DateTime]::Parse($_.timestamp) -ge $cutoff }

    if ($recent.Count -gt 0) {
        # Pattern: Emotional triggers
        $frustrations = $recent | Where-Object { $_.state -eq "frustration" }
        if ($frustrations.Count -gt 2) {
            $triggers = $frustrations | ForEach-Object { $_.context } | Select-Object -First 3
            $consolidatedInsights += @{
                timestamp = $timestamp
                type = "pattern"
                insight = "Frustration triggers: $($triggers -join '; ')"
                context = "From emotional tracking"
                source = "emotions"
            }
        }

        # Heuristic: What leads to satisfaction?
        $satisfactions = $recent | Where-Object { $_.state -eq "satisfaction" }
        if ($satisfactions.Count -gt 0) {
            $sources = $satisfactions | ForEach-Object { $_.context } | Select-Object -First 2
            $consolidatedInsights += @{
                timestamp = $timestamp
                type = "heuristic"
                insight = "Satisfaction comes from: $($sources -join '; ')"
                context = "From emotional tracking"
                source = "emotions"
            }
        }
    }
}

# Analyze assumptions
if (Test-Path $assumptionsFile) {
    $assumptions = Get-Content $assumptionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    $recent = $assumptions | Where-Object { [DateTime]::Parse($_.timestamp) -ge $cutoff }
    $verified = $recent | Where-Object { $_.verified -eq $true }

    if ($verified.Count -gt 0) {
        $wrong = $verified | Where-Object { $_.was_correct -eq $false }
        if ($wrong.Count -gt 0) {
            foreach ($assumption in $wrong | Select-Object -First 2) {
                $consolidatedInsights += @{
                    timestamp = $timestamp
                    type = "lesson"
                    insight = "Wrong assumption: '$($assumption.assumption)'. Actually: $($assumption.actual_outcome)"
                    context = "From assumption verification"
                    source = "assumptions"
                }
            }
        }
    }
}

# Save insights
if ($consolidatedInsights.Count -eq 0) {
    Write-Host "No significant patterns found in last $Hours hours" -ForegroundColor Yellow
    Write-Host "Continue working and try again later" -ForegroundColor Gray
    exit
}

foreach ($insight in $consolidatedInsights) {
    $json = $insight | ConvertTo-Json -Compress
    Add-Content -Path $insightsFile -Value $json
}

Write-Host "EXTRACTED $($consolidatedInsights.Count) INSIGHTS:" -ForegroundColor Green
Write-Host ""

foreach ($insight in $consolidatedInsights) {
    $color = switch ($insight.type) {
        "pattern" { "Cyan" }
        "lesson" { "Green" }
        "principle" { "Magenta" }
        "heuristic" { "Yellow" }
        "anti-pattern" { "Red" }
        default { "White" }
    }

    Write-Host "[$($insight.type.ToUpper())] " -NoNewline -ForegroundColor $color
    Write-Host "$($insight.insight)" -ForegroundColor White
}

Write-Host ""
Write-Host "These insights are now part of long-term memory" -ForegroundColor Green
Write-Host ""
