<#
.SYNOPSIS
    Weekly impact metrics dashboard - show agent value

.DESCRIPTION
    Calculates and displays agent impact metrics:
    - Bugs prevented
    - Time saved
    - PRs created/merged
    - Tools created
    - Code quality improvement
    - Learnings captured

.PARAMETER Week
    Week offset (0 = current week, 1 = last week, etc)

.PARAMETER Calculate
    Recalculate metrics from raw data

.PARAMETER Email
    Email weekly report to user

.EXAMPLE
    .\impact-dashboard.ps1

.EXAMPLE
    .\impact-dashboard.ps1 -Week 1

.EXAMPLE
    .\impact-dashboard.ps1 -Calculate
#>

param(
    [Parameter(Mandatory=$false)]
    [int]$Week = 0,

    [Parameter(Mandatory=$false)]
    [switch]$Calculate,

    [Parameter(Mandatory=$false)]
    [switch]$Email
)

$ErrorActionPreference = 'Stop'

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

function Get-WeekBounds {
    param([int]$WeekOffset)

    $now = Get-Date
    $startOfWeek = $now.AddDays(-($now.DayOfWeek.value__ -1) - ($WeekOffset * 7))
    $startOfWeek = Get-Date -Date $startOfWeek -Hour 0 -Minute 0 -Second 0

    $endOfWeek = $startOfWeek.AddDays(7).AddSeconds(-1)

    return @{
        Start = $startOfWeek.ToString("yyyy-MM-ddTHH:mm:ss")
        End = $endOfWeek.ToString("yyyy-MM-ddTHH:mm:ss")
        StartDisplay = $startOfWeek.ToString("MMM dd")
        EndDisplay = $endOfWeek.ToString("MMM dd, yyyy")
    }
}

function Calculate-WeeklyMetrics {
    param([hashtable]$Week)

    Write-Host "Calculating metrics for $($Week.StartDisplay) - $($Week.EndDisplay)..." -ForegroundColor Yellow

    # Bugs prevented (errors fixed)
    $bugsSql = "SELECT COUNT(DISTINCT error_type) FROM errors WHERE datetime(timestamp) BETWEEN '$($Week.Start)' AND '$($Week.End)' AND severity IN ('error', 'critical');"
    $bugsPrevented = [int](Invoke-Sql -Sql $bugsSql)

    # Time saved (tool usage * estimated time per use)
    $timeSql = "SELECT COUNT(*) FROM tool_usage WHERE datetime(timestamp) BETWEEN '$($Week.Start)' AND '$($Week.End)';"
    $toolUses = [int](Invoke-Sql -Sql $timeSql)
    $timeSavedMinutes = $toolUses * 5  # Assume 5 min saved per tool use

    # PRs created
    $prCreatedSql = "SELECT COUNT(*) FROM pull_requests WHERE datetime(created_at) BETWEEN '$($Week.Start)' AND '$($Week.End)';"
    $prsCreated = [int](Invoke-Sql -Sql $prCreatedSql)

    # PRs merged
    $prMergedSql = "SELECT COUNT(*) FROM pull_requests WHERE datetime(merged_at) BETWEEN '$($Week.Start)' AND '$($Week.End)' AND status = 'merged';"
    $prsMerged = [int](Invoke-Sql -Sql $prMergedSql)

    # Tools created (from learnings)
    $toolsSql = "SELECT COUNT(*) FROM learnings WHERE datetime(timestamp) BETWEEN '$($Week.Start)' AND '$($Week.End)' AND category = 'tool_created';"
    $toolsCreated = [int](Invoke-Sql -Sql $toolsSql)

    # Code quality (PR success rate as proxy)
    $codeQuality = if ($prsCreated -gt 0) {
        [math]::Round(($prsMerged / $prsCreated) * 100, 1)
    } else { 0 }

    # Learnings captured
    $learningsSql = "SELECT COUNT(*) FROM learnings WHERE datetime(timestamp) BETWEEN '$($Week.Start)' AND '$($Week.End)';"
    $learningsCaptured = [int](Invoke-Sql -Sql $learningsSql)

    # Store in database
    $insertSql = "INSERT OR REPLACE INTO impact_metrics (week_start, week_end, bugs_prevented, time_saved_minutes, prs_created, prs_merged, tools_created, code_quality_delta, learnings_captured, calculated_at) VALUES ('$($Week.Start)', '$($Week.End)', $bugsPrevented, $timeSavedMinutes, $prsCreated, $prsMerged, $toolsCreated, $codeQuality, $learningsCaptured, datetime('now'));"

    Invoke-Sql -Sql $insertSql

    return @{
        BugsPrevented = $bugsPrevented
        TimeSavedMinutes = $timeSavedMinutes
        PRsCreated = $prsCreated
        PRsMerged = $prsMerged
        ToolsCreated = $toolsCreated
        CodeQuality = $codeQuality
        LearningsCaptured = $learningsCaptured
    }
}

function Show-ImpactDashboard {
    param([hashtable]$Week, [hashtable]$Metrics)

    $timeSavedHours = [math]::Round($Metrics.TimeSavedMinutes / 60, 1)

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "  WEEKLY IMPACT REPORT                   " -ForegroundColor Cyan
    Write-Host "-----------------------------------------" -ForegroundColor Cyan
    Write-Host "  Week: $($Week.StartDisplay) - $($Week.EndDisplay)" -ForegroundColor White
    Write-Host "-----------------------------------------" -ForegroundColor Cyan

    Write-Host "  Bugs Prevented:        $($Metrics.BugsPrevented)" -ForegroundColor $(if ($Metrics.BugsPrevented -gt 0) { "Green" } else { "Gray" })
    Write-Host "  Time Saved:            $timeSavedHours hours" -ForegroundColor $(if ($timeSavedHours -gt 0) { "Green" } else { "Gray" })
    Write-Host "  Code Quality:          $($Metrics.CodeQuality)%" -ForegroundColor $(if ($Metrics.CodeQuality -ge 80) { "Green" } elseif ($Metrics.CodeQuality -ge 60) { "Yellow" } else { "Red" })
    Write-Host "  Tools Created:         $($Metrics.ToolsCreated)" -ForegroundColor $(if ($Metrics.ToolsCreated -gt 0) { "Green" } else { "Gray" })
    Write-Host "  PRs Merged:            $($Metrics.PRsMerged)/$($Metrics.PRsCreated)" -ForegroundColor $(if ($Metrics.PRsMerged -eq $Metrics.PRsCreated -and $Metrics.PRsMerged -gt 0) { "Green" } else { "Yellow" })
    Write-Host "  Learnings Captured:    $($Metrics.LearningsCaptured)" -ForegroundColor $(if ($Metrics.LearningsCaptured -gt 0) { "Green" } else { "Gray" })

    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""

    # Value statement
    $annualSavings = [math]::Round($timeSavedHours * 52 * 100, 0)  # Assume $100/hour dev time
    if ($annualSavings -gt 1000) {
        Write-Host "Estimated annual value: `$$annualSavings" -ForegroundColor Green
        Write-Host ""
    }
}

# Main execution
try {
    $weekBounds = Get-WeekBounds -WeekOffset $Week

    if ($Calculate) {
        $metrics = Calculate-WeeklyMetrics -Week $weekBounds
    } else {
        # Try to load from database
        $sql = "SELECT bugs_prevented, time_saved_minutes, prs_created, prs_merged, tools_created, code_quality_delta, learnings_captured FROM impact_metrics WHERE week_start = '$($weekBounds.Start)';"

        $result = Invoke-Sql -Sql $sql

        if ($result) {
            $parts = $result -split '\|'
            $metrics = @{
                BugsPrevented = [int]$parts[0]
                TimeSavedMinutes = [int]$parts[1]
                PRsCreated = [int]$parts[2]
                PRsMerged = [int]$parts[3]
                ToolsCreated = [int]$parts[4]
                CodeQuality = [decimal]$parts[5]
                LearningsCaptured = [int]$parts[6]
            }
        } else {
            # Calculate if not found
            Write-Host "No cached metrics found. Calculating..." -ForegroundColor Yellow
            $metrics = Calculate-WeeklyMetrics -Week $weekBounds
        }
    }

    Show-ImpactDashboard -Week $weekBounds -Metrics $metrics

    if ($Email) {
        Write-Host "Email functionality not yet implemented." -ForegroundColor Yellow
        Write-Host "Tip: Use output redirection to save report:" -ForegroundColor Gray
        Write-Host "  .\impact-dashboard.ps1 > weekly-report.txt" -ForegroundColor Gray
        Write-Host ""
    }

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
