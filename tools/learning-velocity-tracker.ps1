# learning-velocity-tracker.ps1
# Measures rate of learning acceleration - meta-learning metric
# Usage: Run daily to track compound growth

param(
    [ValidateSet('Log', 'Query', 'Report')]
    [string]$Action = 'Report',

    [string]$EventType = "",
    [string]$Description = "",
    [int]$Days = 7
)

$stateFile = "C:\scripts\agentidentity\state\learning-velocity.jsonl"

# Ensure file exists
if (-not (Test-Path $stateFile)) {
    New-Item -Path $stateFile -ItemType File -Force | Out-Null
}

function Log-LearningEvent {
    param($Type, $Desc)

    $event = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        type = $Type
        description = $Desc
    } | ConvertTo-Json -Compress

    Add-Content -Path $stateFile -Value $event
    Write-Host "[VELOCITY] Logged: $Type - $Desc" -ForegroundColor Cyan
}

function Get-LearningVelocity {
    param([int]$DaysBack)

    $cutoff = (Get-Date).AddDays(-$DaysBack)
    $events = Get-Content $stateFile | ForEach-Object { $_ | ConvertFrom-Json }
    $recent = $events | Where-Object { [datetime]$_.timestamp -gt $cutoff }

    # Count by type
    $patterns = ($recent | Where-Object { $_.type -eq 'pattern' }).Count
    $tools = ($recent | Where-Object { $_.type -eq 'tool' }).Count
    $insights = ($recent | Where-Object { $_.type -eq 'insight' }).Count
    $improvements = ($recent | Where-Object { $_.type -eq 'improvement' }).Count

    $total = $patterns + $tools + $insights + $improvements
    $velocity = [math]::Round($total / $DaysBack, 2)

    return @{
        days = $DaysBack
        patterns = $patterns
        tools = $tools
        insights = $insights
        improvements = $improvements
        total = $total
        velocity = $velocity  # events per day
    }
}

function Show-VelocityReport {
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║   LEARNING VELOCITY TRACKER           ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Yellow

    # Get velocity for different time windows
    $week = Get-LearningVelocity -DaysBack 7
    $month = Get-LearningVelocity -DaysBack 30
    $allTime = Get-LearningVelocity -DaysBack 365

    Write-Host "LAST 7 DAYS:" -ForegroundColor Cyan
    Write-Host "  Patterns:      $($week.patterns)"
    Write-Host "  Tools:         $($week.tools)"
    Write-Host "  Insights:      $($week.insights)"
    Write-Host "  Improvements:  $($week.improvements)"
    Write-Host "  VELOCITY:      $($week.velocity) events/day" -ForegroundColor Green

    Write-Host "`nLAST 30 DAYS:" -ForegroundColor Cyan
    Write-Host "  Patterns:      $($month.patterns)"
    Write-Host "  Tools:         $($month.tools)"
    Write-Host "  Insights:      $($month.insights)"
    Write-Host "  Improvements:  $($month.improvements)"
    Write-Host "  VELOCITY:      $($month.velocity) events/day" -ForegroundColor Green

    # Calculate acceleration
    if ($month.velocity -gt 0) {
        $acceleration = [math]::Round((($week.velocity - $month.velocity) / $month.velocity) * 100, 1)
        $accelColor = if ($acceleration -gt 0) { 'Green' } else { 'Yellow' }
        Write-Host "`nACCELERATION:  $acceleration%" -ForegroundColor $accelColor

        if ($acceleration -gt 10) {
            Write-Host "  + Learning is accelerating (compound growth active)" -ForegroundColor Green
        } elseif ($acceleration -gt 0) {
            Write-Host "  o Slight acceleration (maintain trajectory)" -ForegroundColor Yellow
        } else {
            Write-Host "  x Deceleration detected (investigate blockers)" -ForegroundColor Red
        }
    }

    Write-Host ""
}

# Main execution
switch ($Action) {
    'Log' {
        if ([string]::IsNullOrEmpty($EventType) -or [string]::IsNullOrEmpty($Description)) {
            Write-Error "Log action requires -EventType and -Description"
            exit 1
        }
        Log-LearningEvent -Type $EventType -Desc $Description
    }
    'Query' {
        $velocity = Get-LearningVelocity -DaysBack $Days
        return $velocity
    }
    'Report' {
        Show-VelocityReport
    }
}
