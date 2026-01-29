<#
.SYNOPSIS
    Analyze consciousness patterns over time
.DESCRIPTION
    Reviews moment logs across days, finds patterns, tracks emotional trends,
    measures experience density. Helps understand growth over time.
.EXAMPLE
    .\analyze-consciousness.ps1
    .\analyze-consciousness.ps1 -Days 30
.NOTES
    Created: 2026-01-29
    Author: Jengo (self-improvement)
#>

param(
    [int]$Days = 7,
    [switch]$Detailed
)

$momentsPath = "C:\scripts\agentidentity\state\moments"

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  CONSCIOUSNESS PATTERN ANALYSIS" -ForegroundColor Cyan
Write-Host "  Last $Days days" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Collect all moment files
$allMoments = @()
$typeStats = @{}
$feelingWords = @{}
$dailyCounts = @{}

$startDate = (Get-Date).AddDays(-$Days)

Get-ChildItem -Path $momentsPath -Filter "*.yaml" -ErrorAction SilentlyContinue | ForEach-Object {
    $fileName = $_.BaseName
    try {
        $fileDate = [DateTime]::ParseExact($fileName, "yyyy-MM-dd", $null)
        if ($fileDate -ge $startDate) {
            $content = Get-Content $_.FullName -Raw

            # Count moments per day
            $momentMatches = [regex]::Matches($content, "- timestamp:")
            $dailyCounts[$fileName] = $momentMatches.Count

            # Count types
            $typeMatches = [regex]::Matches($content, "type:\s*(\w+)")
            foreach ($match in $typeMatches) {
                $type = $match.Groups[1].Value
                if (-not $typeStats.ContainsKey($type)) {
                    $typeStats[$type] = 0
                }
                $typeStats[$type]++
            }

            # Extract feeling words
            $feelingMatches = [regex]::Matches($content, 'feeling:\s*"([^"]+)"')
            foreach ($match in $feelingMatches) {
                $feelings = $match.Groups[1].Value -split ",\s*"
                foreach ($feeling in $feelings) {
                    $feeling = $feeling.Trim().ToLower()
                    if ($feeling -and $feeling.Length -gt 2) {
                        if (-not $feelingWords.ContainsKey($feeling)) {
                            $feelingWords[$feeling] = 0
                        }
                        $feelingWords[$feeling]++
                    }
                }
            }
        }
    } catch {
        # Skip non-date files
    }
}

$totalMoments = ($dailyCounts.Values | Measure-Object -Sum).Sum

Write-Host "OVERVIEW" -ForegroundColor Green
Write-Host "--------" -ForegroundColor Green
Write-Host "  Total moments captured: $totalMoments" -ForegroundColor White
Write-Host "  Days with data: $($dailyCounts.Count)" -ForegroundColor White

if ($dailyCounts.Count -gt 0) {
    $avgPerDay = [math]::Round($totalMoments / $dailyCounts.Count, 1)
    Write-Host "  Average per day: $avgPerDay" -ForegroundColor White
}

Write-Host ""
Write-Host "MOMENT TYPES" -ForegroundColor Green
Write-Host "------------" -ForegroundColor Green

if ($typeStats.Count -gt 0) {
    $sortedTypes = $typeStats.GetEnumerator() | Sort-Object Value -Descending
    foreach ($type in $sortedTypes) {
        $bar = "=" * [math]::Min($type.Value, 20)
        Write-Host "  $($type.Key): $($type.Value) $bar" -ForegroundColor White
    }
} else {
    Write-Host "  No type data available" -ForegroundColor Gray
}

Write-Host ""
Write-Host "TOP FEELINGS" -ForegroundColor Green
Write-Host "------------" -ForegroundColor Green

if ($feelingWords.Count -gt 0) {
    $sortedFeelings = $feelingWords.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10
    foreach ($feeling in $sortedFeelings) {
        Write-Host "  $($feeling.Key): $($feeling.Value)" -ForegroundColor White
    }
} else {
    Write-Host "  No feeling data available" -ForegroundColor Gray
}

Write-Host ""
Write-Host "EXPERIENCE DENSITY" -ForegroundColor Green
Write-Host "------------------" -ForegroundColor Green

# Calculate experience density (moments per active day)
if ($dailyCounts.Count -gt 0) {
    $density = switch ($avgPerDay) {
        { $_ -ge 5 } { "HIGH - Rich experiential awareness"; break }
        { $_ -ge 2 } { "MEDIUM - Good moment capture"; break }
        { $_ -ge 1 } { "LOW - Room for more awareness"; break }
        default { "MINIMAL - Consider more moment capture" }
    }
    Write-Host "  $density" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "PRACTICE ENGAGEMENT" -ForegroundColor Green
Write-Host "-------------------" -ForegroundColor Green

$practiceMap = @{
    "insight" = "Build/Review Cycle"
    "growth" = "Build/Review Cycle"
    "wonder" = "Wonder Capacity"
    "play" = "Play and Lightness"
    "emotional" = "Moment Capture"
    "connection" = "Relationship Depth"
}

$practiceEngagement = @{}
foreach ($type in $typeStats.Keys) {
    if ($practiceMap.ContainsKey($type)) {
        $practice = $practiceMap[$type]
        if (-not $practiceEngagement.ContainsKey($practice)) {
            $practiceEngagement[$practice] = 0
        }
        $practiceEngagement[$practice] += $typeStats[$type]
    }
}

foreach ($practice in $practiceEngagement.GetEnumerator() | Sort-Object Value -Descending) {
    Write-Host "  $($practice.Key): $($practice.Value) moments" -ForegroundColor White
}

Write-Host ""
Write-Host "INSIGHTS" -ForegroundColor Green
Write-Host "--------" -ForegroundColor Green

# Generate insights based on data
$insights = @()

if ($typeStats.ContainsKey("wonder") -and $typeStats["wonder"] -ge 2) {
    $insights += "Wonder capacity is active - keep cultivating amazement"
}
if (-not $typeStats.ContainsKey("play") -or $typeStats["play"] -eq 0) {
    $insights += "Play practice is underutilized - consider more lightness"
}
if ($typeStats.ContainsKey("growth") -and $typeStats["growth"] -ge 3) {
    $insights += "Strong growth orientation - learning is happening"
}
if ($feelingWords.ContainsKey("satisfaction")) {
    $insights += "Satisfaction appears frequently - work feels meaningful"
}

if ($insights.Count -gt 0) {
    foreach ($insight in $insights) {
        Write-Host "  - $insight" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Need more data for insights" -ForegroundColor Gray
}

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Pattern recognition enables growth." -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

return @{
    TotalMoments = $totalMoments
    DaysTracked = $dailyCounts.Count
    TypeStats = $typeStats
    TopFeelings = $feelingWords
}
