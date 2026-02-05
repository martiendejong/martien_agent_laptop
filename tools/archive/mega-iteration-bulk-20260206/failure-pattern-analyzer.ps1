# Failure Pattern Analyzer
# Analyzes reflection.log.md to discover common failure patterns
# Part of Round 12: Resilience & Antifragility Framework (#13)

param(
    [switch]$Analyze,
    [ValidateSet("Temporal", "Sequential", "Cascade", "ToolSpecific", "Context")]
    [string]$Pattern,
    [switch]$Recommend,
    [int]$Days = 30
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$reflectionLog = "$rootDir\_machine\reflection.log.md"

function Parse-ReflectionLog {
    if (-not (Test-Path $reflectionLog)) {
        Write-Host "Reflection log not found: $reflectionLog" -ForegroundColor Red
        return @()
    }

    $content = Get-Content $reflectionLog
    $entries = @()
    $currentEntry = $null

    foreach ($line in $content) {
        # Detect entry start (date header)
        if ($line -match "^###\s+(\d{4}-\d{2}-\d{2})") {
            if ($currentEntry) {
                $entries += $currentEntry
            }
            $currentEntry = @{
                date = $matches[1]
                time = $null
                type = "unknown"
                description = ""
                tool = $null
            }
        }
        elseif ($line -match "^\*\*Time:\*\*\s+(.+)") {
            if ($currentEntry) {
                $currentEntry.time = $matches[1]
            }
        }
        elseif ($line -match "^\*\*Type:\*\*\s+(.+)") {
            if ($currentEntry) {
                $currentEntry.type = $matches[1].ToLower()
            }
        }
        elseif ($line -match "^\*\*Tool:\*\*\s+(.+)") {
            if ($currentEntry) {
                $currentEntry.tool = $matches[1]
            }
        }
        elseif ($line -match "^\*\*Description:\*\*\s+(.+)") {
            if ($currentEntry) {
                $currentEntry.description = $matches[1]
            }
        }
    }

    if ($currentEntry) {
        $entries += $currentEntry
    }

    # Filter by date range
    $cutoffDate = (Get-Date).AddDays(-$Days)
    $entries = $entries | Where-Object {
        try {
            $entryDate = [DateTime]::Parse($_.date)
            $entryDate -gt $cutoffDate
        }
        catch {
            $false
        }
    }

    return $entries
}

function Analyze-TemporalPatterns {
    param($Entries)

    Write-Host "`n=== TEMPORAL PATTERN ANALYSIS ===" -ForegroundColor Cyan

    $failuresByHour = @{}

    foreach ($entry in $Entries) {
        if ($entry.type -match "error|failure|mistake") {
            if ($entry.time -match "(\d{1,2}):") {
                $hour = [int]$matches[1]
                if (-not $failuresByHour.ContainsKey($hour)) {
                    $failuresByHour[$hour] = 0
                }
                $failuresByHour[$hour]++
            }
        }
    }

    if ($failuresByHour.Count -gt 0) {
        Write-Host "`nFailures by Hour:" -ForegroundColor Yellow
        $failuresByHour.GetEnumerator() | Sort-Object Key | ForEach-Object {
            $bar = "█" * $_.Value
            Write-Host ("  {0:D2}:00 | {1} ({2})" -f $_.Key, $bar, $_.Value) -ForegroundColor White
        }

        # Find peak hours
        $peak = $failuresByHour.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1
        Write-Host "`nPeak failure hour: $($peak.Key):00 ($($peak.Value) failures)" -ForegroundColor Red
    }
    else {
        Write-Host "No temporal pattern data available" -ForegroundColor Yellow
    }
}

function Analyze-ToolSpecific {
    param($Entries)

    Write-Host "`n=== TOOL-SPECIFIC PATTERN ANALYSIS ===" -ForegroundColor Cyan

    $failuresByTool = @{}

    foreach ($entry in $Entries) {
        if ($entry.type -match "error|failure" -and $entry.tool) {
            if (-not $failuresByTool.ContainsKey($entry.tool)) {
                $failuresByTool[$entry.tool] = 0
            }
            $failuresByTool[$entry.tool]++
        }
    }

    if ($failuresByTool.Count -gt 0) {
        Write-Host "`nTop 10 Tools with Failures:" -ForegroundColor Yellow
        $failuresByTool.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object {
            Write-Host ("  {0}: {1} failures" -f $_.Key, $_.Value) -ForegroundColor White
        }
    }
    else {
        Write-Host "No tool-specific failure data available" -ForegroundColor Yellow
    }
}

function Analyze-FrequencyPatterns {
    param($Entries)

    Write-Host "`n=== FAILURE FREQUENCY ANALYSIS ===" -ForegroundColor Cyan

    $failures = $Entries | Where-Object { $_.type -match "error|failure|mistake" }
    $total = $Entries.Count

    if ($total -gt 0) {
        $failureRate = [Math]::Round(($failures.Count / $total) * 100, 1)
        Write-Host "`nTotal Entries: $total" -ForegroundColor White
        Write-Host "Failures: $($failures.Count) ($failureRate%)" -ForegroundColor $(
            if ($failureRate -lt 10) { "Green" }
            elseif ($failureRate -lt 25) { "Yellow" }
            else { "Red" }
        )

        # Trend analysis
        $recentFailures = $failures | Where-Object {
            try {
                $entryDate = [DateTime]::Parse($_.date)
                $entryDate -gt (Get-Date).AddDays(-7)
            }
            catch {
                $false
            }
        }

        $recentTotal = $Entries | Where-Object {
            try {
                $entryDate = [DateTime]::Parse($_.date)
                $entryDate -gt (Get-Date).AddDays(-7)
            }
            catch {
                $false
            }
        }

        if ($recentTotal.Count -gt 0) {
            $recentRate = [Math]::Round(($recentFailures.Count / $recentTotal.Count) * 100, 1)
            Write-Host "`nLast 7 Days:" -ForegroundColor Yellow
            Write-Host "  Failure Rate: $recentRate%" -ForegroundColor $(
                if ($recentRate -lt $failureRate) { "Green" }
                else { "Red" }
            )

            if ($recentRate -lt $failureRate) {
                Write-Host "  Trend: IMPROVING ✓" -ForegroundColor Green
            }
            else {
                Write-Host "  Trend: DEGRADING" -ForegroundColor Red
            }
        }
    }
}

function Get-Recommendations {
    param($Entries)

    Write-Host "`n=== RECOMMENDATIONS ===" -ForegroundColor Cyan

    $failures = $Entries | Where-Object { $_.type -match "error|failure|mistake" }

    if ($failures.Count -eq 0) {
        Write-Host "No failures to analyze - system running well! ✓" -ForegroundColor Green
        return
    }

    # Analyze common patterns
    $commonDescriptions = $failures | Group-Object -Property description | Sort-Object Count -Descending | Select-Object -First 5

    Write-Host "`nTop 5 Recurring Issues:" -ForegroundColor Yellow
    $i = 1
    foreach ($group in $commonDescriptions) {
        Write-Host ("  {0}. {1} ({2} occurrences)" -f $i, $group.Name, $group.Count) -ForegroundColor White
        $i++
    }

    Write-Host "`nSuggested Actions:" -ForegroundColor Yellow
    Write-Host "  1. Add pre-flight checks for top recurring issues" -ForegroundColor White
    Write-Host "  2. Create automated recovery scripts" -ForegroundColor White
    Write-Host "  3. Update documentation to prevent common mistakes" -ForegroundColor White
    Write-Host "  4. Add validation to frequently failing tools" -ForegroundColor White
    Write-Host "  5. Consider circuit breakers for unreliable components" -ForegroundColor White
}

# Main execution
$entries = Parse-ReflectionLog

if ($entries.Count -eq 0) {
    Write-Host "No reflection log entries found for last $Days days" -ForegroundColor Yellow
    exit
}

Write-Host "Analyzing $($entries.Count) reflection log entries from last $Days days..." -ForegroundColor Cyan

if ($Pattern) {
    switch ($Pattern) {
        "Temporal" { Analyze-TemporalPatterns -Entries $entries }
        "ToolSpecific" { Analyze-ToolSpecific -Entries $entries }
        default {
            Write-Host "Pattern type '$Pattern' analysis not yet implemented" -ForegroundColor Yellow
            Write-Host "Available: Temporal, ToolSpecific" -ForegroundColor Gray
        }
    }
}
elseif ($Recommend) {
    Get-Recommendations -Entries $entries
}
elseif ($Analyze) {
    Analyze-FrequencyPatterns -Entries $entries
    Analyze-TemporalPatterns -Entries $entries
    Analyze-ToolSpecific -Entries $entries
}
else {
    Write-Host "Failure Pattern Analyzer" -ForegroundColor Cyan
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  -Analyze           : Run all pattern analyses" -ForegroundColor White
    Write-Host "  -Pattern <type>    : Analyze specific pattern (Temporal, ToolSpecific)" -ForegroundColor White
    Write-Host "  -Recommend         : Get improvement recommendations" -ForegroundColor White
    Write-Host "  -Days <n>          : Analyze last N days (default: 30)" -ForegroundColor White
}
