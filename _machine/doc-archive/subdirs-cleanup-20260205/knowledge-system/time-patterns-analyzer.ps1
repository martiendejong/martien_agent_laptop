# Time-of-Day Patterns - R03-005
# Track what Martien typically does at different times (morning: PRs, afternoon: features)
# Expert: Alex Kim - Context-Aware Computing Specialist

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('analyze', 'predict', 'report', 'log')]
    [string]$Action = 'report',

    [Parameter(Mandatory=$false)]
    [string]$Activity,

    [Parameter(Mandatory=$false)]
    [int]$Hour = -1
)

$SequenceFile = "C:\scripts\_machine\knowledge-system\sequences.jsonl"
$TimePatternsFile = "C:\scripts\_machine\knowledge-system\time-patterns.json"

function Analyze-TimePatterns {
    if (-not (Test-Path $SequenceFile)) {
        Write-Host "No sequence data available" -ForegroundColor Red
        return
    }

    Write-Host "Analyzing time-of-day patterns..." -ForegroundColor Cyan

    $sequences = Get-Content $SequenceFile | ForEach-Object { $_ | ConvertFrom-Json }

    # Build histograms
    $hourlyActivity = @{}
    $dailyActivity = @{}
    $hourlyQueries = @{}

    for ($h = 0; $h -lt 24; $h++) {
        $hourlyActivity[$h] = @{
            'count' = 0
            'queries' = @()
            'contexts' = @()
        }
    }

    foreach ($day in @('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')) {
        $dailyActivity[$day] = @{
            'count' = 0
            'queries' = @()
        }
    }

    foreach ($seq in $sequences) {
        $hour = $seq.hour_of_day
        $day = $seq.day_of_week

        $hourlyActivity[$hour].count++
        $hourlyActivity[$hour].queries += $seq.query
        if ($seq.context_files) {
            $hourlyActivity[$hour].contexts += $seq.context_files
        }

        $dailyActivity[$day].count++
        $dailyActivity[$day].queries += $seq.query
    }

    # Analyze activity types by hour
    $activityPatterns = @{
        'debug' = @('debug', 'error', 'bug', 'fail', 'fix')
        'feature' = @('feature', 'implement', 'add', 'create', 'new')
        'docs' = @('docs', 'documentation', 'readme', 'update')
        'review' = @('review', 'check', 'verify', 'test')
        'planning' = @('plan', 'design', 'architecture', 'workflow')
    }

    $hourlyByType = @{}
    for ($h = 0; $h -lt 24; $h++) {
        $hourlyByType[$h] = @{}
        foreach ($type in $activityPatterns.Keys) {
            $hourlyByType[$h][$type] = 0
        }
    }

    foreach ($seq in $sequences) {
        $hour = $seq.hour_of_day
        $query = $seq.query.ToLower()

        foreach ($type in $activityPatterns.Keys) {
            foreach ($keyword in $activityPatterns[$type]) {
                if ($query -match [regex]::Escape($keyword)) {
                    $hourlyByType[$hour][$type]++
                    break
                }
            }
        }
    }

    # Save analysis
    $analysis = @{
        'analyzed' = Get-Date -Format 'o'
        'total_sequences' = $sequences.Count
        'hourly_activity' = $hourlyActivity
        'daily_activity' = $dailyActivity
        'hourly_by_type' = $hourlyByType
    }

    $analysis | ConvertTo-Json -Depth 10 | Out-File $TimePatternsFile -Encoding UTF8
    Write-Host "Time patterns analyzed and saved" -ForegroundColor Green
}

function Predict-ActivityForTime {
    param([int]$Hour)

    if ($Hour -eq -1) {
        $Hour = (Get-Date).Hour
    }

    if (-not (Test-Path $TimePatternsFile)) {
        Write-Host "No time pattern analysis available. Run 'analyze' first." -ForegroundColor Red
        return
    }

    $analysis = Get-Content $TimePatternsFile -Raw | ConvertFrom-Json

    $hourData = $analysis.hourly_by_type.$Hour.PSObject.Properties

    if ($hourData.Count -eq 0) {
        Write-Host "No data for hour $Hour" -ForegroundColor Yellow
        return
    }

    $total = ($hourData.Value | Measure-Object -Sum).Sum

    if ($total -eq 0) {
        Write-Host "No activity recorded for hour $Hour" -ForegroundColor Yellow
        return
    }

    Write-Host "`nPredicted Activity for Hour $Hour ($(Get-Date -Hour $Hour -Minute 0 -Format 'HH:mm')):" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan

    $predictions = $hourData |
        Where-Object { $_.Value -gt 0 } |
        ForEach-Object {
            @{
                'activity' = $_.Name
                'count' = $_.Value
                'probability' = [math]::Round(($_.Value / $total), 3)
                'percentage' = [math]::Round(($_.Value / $total) * 100, 1)
            }
        } |
        Sort-Object probability -Descending

    foreach ($pred in $predictions) {
        $bar = "#" * [math]::Floor($pred.percentage / 5)
        Write-Host "$($pred.activity): $($pred.percentage)% $bar" -ForegroundColor Yellow
    }

    # Suggest context to preload
    Write-Host "`nSuggested Context to Preload:" -ForegroundColor Green

    $topActivity = $predictions[0].activity

    $contextSuggestions = @{
        'debug' = @('ci-cd-troubleshooting.md', 'reflection.log.md')
        'feature' = @('worktree-workflow.md', 'development-patterns.md')
        'docs' = @('CLAUDE.md', 'STARTUP_PROTOCOL.md')
        'review' = @('git-workflow.md', 'DEFINITION_OF_DONE.md')
        'planning' = @('development-patterns.md', 'worktree-workflow.md')
    }

    if ($contextSuggestions.ContainsKey($topActivity)) {
        $contextSuggestions[$topActivity] | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Gray
        }
    }

    return $predictions
}

function Show-TimeReport {
    if (-not (Test-Path $TimePatternsFile)) {
        Write-Host "No time pattern analysis available. Run 'analyze' first." -ForegroundColor Red
        return
    }

    $analysis = Get-Content $TimePatternsFile -Raw | ConvertFrom-Json

    Write-Host "`n=== Time-of-Day Activity Patterns ===" -ForegroundColor Cyan
    Write-Host "Analyzed: $($analysis.analyzed)" -ForegroundColor Gray
    Write-Host "Total sequences: $($analysis.total_sequences)" -ForegroundColor Gray

    # Hourly distribution
    Write-Host "`n📊 Activity by Hour:" -ForegroundColor Yellow

    $hourlyData = $analysis.hourly_activity.PSObject.Properties |
        Sort-Object { [int]$_.Name }

    foreach ($hour in $hourlyData) {
        $h = [int]$hour.Name
        $count = $hour.Value.count

        if ($count -gt 0) {
            $bar = "█" * [math]::Min([math]::Floor($count / 2), 50)
            $timeStr = Get-Date -Hour $h -Minute 0 -Format 'HH:mm'
            Write-Host "$timeStr : $bar ($count)" -ForegroundColor $(
                if ($h -ge 8 -and $h -lt 12) { 'Green' }      # Morning
                elseif ($h -ge 12 -and $h -lt 18) { 'Yellow' } # Afternoon
                elseif ($h -ge 18 -and $h -lt 23) { 'Cyan' }   # Evening
                else { 'Gray' }                                 # Night
            )
        }
    }

    # Daily distribution
    Write-Host "`n📅 Activity by Day of Week:" -ForegroundColor Yellow

    $maxDaily = ($analysis.daily_activity.PSObject.Properties.Value.count | Measure-Object -Maximum).Maximum

    foreach ($day in @('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')) {
        $count = $analysis.daily_activity.$day.count
        if ($maxDaily -gt 0) {
            $bar = "█" * [math]::Floor(($count / $maxDaily) * 30)
            Write-Host "$day : $bar ($count)" -ForegroundColor Cyan
        }
    }

    # Peak hours
    Write-Host "`n⏰ Peak Activity Hours:" -ForegroundColor Yellow

    $peakHours = $hourlyData |
        Sort-Object { $_.Value.count } -Descending |
        Select-Object -First 3

    foreach ($peak in $peakHours) {
        $h = [int]$peak.Name
        $timeStr = Get-Date -Hour $h -Minute 0 -Format 'HH:mm'
        Write-Host "  #$($peakHours.IndexOf($peak) + 1): $timeStr ($($peak.Value.count) activities)" -ForegroundColor Green
    }

    # Activity type distribution by time of day
    Write-Host "`n🔍 Activity Types by Time Period:" -ForegroundColor Yellow

    $periods = @{
        'Morning (06-12)' = 6..11
        'Afternoon (12-18)' = 12..17
        'Evening (18-23)' = 18..22
        'Night (23-06)' = @(23, 0..5)
    }

    foreach ($period in $periods.Keys) {
        Write-Host "`n  $period" -ForegroundColor Cyan

        $periodCounts = @{}
        $activityTypes = @('debug', 'feature', 'docs', 'review', 'planning')

        foreach ($type in $activityTypes) {
            $periodCounts[$type] = 0
        }

        foreach ($h in $periods[$period]) {
            $hourData = $analysis.hourly_by_type.$h.PSObject.Properties

            foreach ($prop in $hourData) {
                if ($periodCounts.ContainsKey($prop.Name)) {
                    $periodCounts[$prop.Name] += $prop.Value
                }
            }
        }

        $total = ($periodCounts.Values | Measure-Object -Sum).Sum

        if ($total -gt 0) {
            $periodCounts.GetEnumerator() |
                Where-Object { $_.Value -gt 0 } |
                Sort-Object Value -Descending |
                ForEach-Object {
                    $pct = [math]::Round(($_.Value / $total) * 100, 1)
                    Write-Host "    $($_.Name): $pct%" -ForegroundColor Gray
                }
        } else {
            Write-Host "    No data" -ForegroundColor DarkGray
        }
    }
}

function Log-Activity {
    param([string]$Activity)

    $logEntry = @{
        'timestamp' = Get-Date -Format 'o'
        'hour' = (Get-Date).Hour
        'day' = (Get-Date).DayOfWeek.ToString()
        'activity' = $Activity
    } | ConvertTo-Json -Compress

    Add-Content -Path $SequenceFile -Value $logEntry -Encoding UTF8
    Write-Host "Activity logged: $Activity" -ForegroundColor Green
}

# Main execution
switch ($Action) {
    'analyze' {
        Analyze-TimePatterns
    }
    'predict' {
        Predict-ActivityForTime -Hour $Hour
    }
    'report' {
        Show-TimeReport
    }
    'log' {
        if (-not $Activity) {
            Write-Host "Activity required for logging" -ForegroundColor Red
            exit 1
        }
        Log-Activity -Activity $Activity
    }
}
