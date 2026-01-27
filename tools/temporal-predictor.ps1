<#
.SYNOPSIS
    Predict user needs based on temporal patterns

.DESCRIPTION
    Uses learned temporal patterns to proactively assist:
    - If pattern: "Monday 9am status updates" → Pre-generate status report
    - If pattern: "Thursday 2pm deployments" → Run pre-deployment checks
    - If pattern: "Friday 5pm code freeze" → Verify all PRs merged

.PARAMETER CheckNow
    Check current time for predicted needs

.PARAMETER DayOfWeek
    Override day of week (0-6, 0=Sunday)

.PARAMETER Hour
    Override hour (0-23)

.EXAMPLE
    .\temporal-predictor.ps1 -CheckNow

.EXAMPLE
    .\temporal-predictor.ps1 -DayOfWeek 1 -Hour 9
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$CheckNow,

    [Parameter(Mandatory=$false)]
    [int]$DayOfWeek,

    [Parameter(Mandatory=$false)]
    [int]$Hour
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Temporal Pattern Prediction" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

# Get current or specified time
if ($CheckNow) {
    $now = Get-Date
    $DayOfWeek = [int]$now.DayOfWeek
    $Hour = $now.Hour
}

if ($null -eq $DayOfWeek -or $null -eq $Hour) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\temporal-predictor.ps1 -CheckNow" -ForegroundColor White
    Write-Host "  .\temporal-predictor.ps1 -DayOfWeek 1 -Hour 9" -ForegroundColor White
    Write-Host ""
    exit 0
}

$dayName = @('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')[$DayOfWeek]

Write-Host "Time: $dayName $($Hour):00" -ForegroundColor White
Write-Host ""

# Query patterns for this time
$sql = "SELECT pattern, pattern_type, confidence, occurrences FROM temporal_patterns WHERE day_of_week = $DayOfWeek AND hour_of_day = $Hour AND confidence >= 0.7 ORDER BY confidence DESC;"

$patterns = Invoke-Sql -Sql $sql

if (-not $patterns) {
    Write-Host "No strong patterns detected for this time" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Learn patterns with:" -ForegroundColor Yellow
    Write-Host "  .\temporal-learner.ps1 -Analyze" -ForegroundColor Gray
    Write-Host ""
    exit 0
}

Write-Host "🔮 Predicted Patterns:" -ForegroundColor Cyan
Write-Host ""

$predictions = @()

$patterns -split "`n" | ForEach-Object {
    if ($_ -match '\|') {
        $parts = $_ -split '\|'
        $pattern = $parts[0]
        $type = $parts[1]
        $conf = [decimal]$parts[2]
        $occ = $parts[3]

        $confPercent = [math]::Round($conf * 100)

        Write-Host "  [$confPercent% confidence] $pattern" -ForegroundColor White

        # Generate proactive suggestions
        switch ($type) {
            'tool_usage' {
                $predictions += "🔧 Tool likely to be used soon - ensure dependencies ready"
            }
            'pr_activity' {
                $predictions += "📝 PR creation expected - verify branch is ready"
            }
            'error_spike' {
                $predictions += "⚠️ Error spike historically occurs - monitor logs closely"
            }
        }
    }
}

if ($predictions.Count -gt 0) {
    Write-Host ""
    Write-Host "💡 Proactive Suggestions:" -ForegroundColor Yellow
    Write-Host ""

    $predictions | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "✅ Prediction complete!" -ForegroundColor Green
Write-Host ""
