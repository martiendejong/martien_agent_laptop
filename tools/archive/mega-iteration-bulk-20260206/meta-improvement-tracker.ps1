# Meta-Improvement Tracker
# Tracks improvements to the improvement process itself (meta-level 2)
# Part of Round 15: Meta-Level Systems Theory (#18)

param(
    [ValidateRange(0, 4)]
    [int]$Level,

    [decimal]$ROI,

    [switch]$TrackImprovement,
    [switch]$ShouldContinue,
    [int]$CurrentLevel
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$trackingFile = "$rootDir\_machine\meta-improvement-tracking.json"

function Get-ImprovementTracking {
    if (Test-Path $trackingFile) {
        return Get-Content $trackingFile -Raw | ConvertFrom-Json
    }

    return @{
        improvements = @()
        level_stats = @{
            level_0 = @{ count = 0; avg_roi = 0 }
            level_1 = @{ count = 0; avg_roi = 0 }
            level_2 = @{ count = 0; avg_roi = 0 }
            level_3 = @{ count = 0; avg_roi = 0 }
        }
        termination_threshold = 1.5
    }
}

function Save-ImprovementTracking {
    param($Data)
    $Data | ConvertTo-Json -Depth 10 | Set-Content $trackingFile
}

function Track-Improvement {
    param(
        [int]$MetaLevel,
        [decimal]$ROI
    )

    $tracking = Get-ImprovementTracking

    $improvement = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        meta_level = $MetaLevel
        roi = $ROI
        level_name = Get-LevelName -Level $MetaLevel
    }

    $tracking.improvements += $improvement

    # Update level stats
    $levelKey = "level_$MetaLevel"
    $levelImprovements = $tracking.improvements | Where-Object { $_.meta_level -eq $MetaLevel }

    $tracking.level_stats.$levelKey.count = $levelImprovements.Count
    $tracking.level_stats.$levelKey.avg_roi = [Math]::Round(
        ($levelImprovements | Measure-Object -Property roi -Average).Average,
        2
    )

    Save-ImprovementTracking -Data $tracking

    Write-Host "`n=== IMPROVEMENT TRACKED ===" -ForegroundColor Cyan
    Write-Host "Meta-Level: $MetaLevel ($($improvement.level_name))" -ForegroundColor Yellow
    Write-Host "ROI: $ROI`x" -ForegroundColor $(Get-ROIColor -ROI $ROI)
    Write-Host "Total Level $MetaLevel Improvements: $($tracking.level_stats.$levelKey.count)" -ForegroundColor White
    Write-Host "Average Level $MetaLevel ROI: $($tracking.level_stats.$levelKey.avg_roi)`x" -ForegroundColor White
}

function Get-LevelName {
    param([int]$Level)

    switch ($Level) {
        0 { return "Object (Direct Work)" }
        1 { return "Process (Improve Workflows)" }
        2 { return "Meta-Process (Improve Improvement)" }
        3 { return "Meta-Meta (Improve Meta-Improvement)" }
        4 { return "TERMINATION (Overthinking)" }
        default { return "Unknown" }
    }
}

function Get-ROIColor {
    param([decimal]$ROI)

    if ($ROI -ge 5) { return "Green" }
    elseif ($ROI -ge 2) { return "Yellow" }
    elseif ($ROI -ge 1.5) { return "DarkYellow" }
    else { return "Red" }
}

function Test-ShouldContinue {
    param([int]$Level)

    $tracking = Get-ImprovementTracking
    $threshold = $tracking.termination_threshold

    Write-Host "`n=== META-LEVEL CONTINUATION ASSESSMENT ===" -ForegroundColor Cyan
    Write-Host "Current Meta-Level: $Level ($(Get-LevelName -Level $Level))" -ForegroundColor Yellow

    # Get average ROI for this level
    $levelKey = "level_$Level"
    $avgROI = $tracking.level_stats.$levelKey.avg_roi

    Write-Host "Average ROI at Level $Level`: $avgROI`x" -ForegroundColor White
    Write-Host "Termination Threshold: $threshold`x" -ForegroundColor Gray

    # Termination rules
    $rules = @{
        "ROI below threshold" = $avgROI -lt $threshold
        "Level >= 3 (meta-meta territory)" = $Level -ge 3
        "Diminishing returns" = ($Level -gt 0) -and ($avgROI -lt ($tracking.level_stats."level_$($Level - 1)".avg_roi * 0.5))
    }

    Write-Host "`nTermination Criteria:" -ForegroundColor Yellow
    $shouldStop = $false
    foreach ($rule in $rules.GetEnumerator()) {
        $status = if ($rule.Value) {
            $shouldStop = $true
            "✓ TRIGGERED"
        } else {
            "○ Not triggered"
        }
        $color = if ($rule.Value) { "Red" } else { "Green" }
        Write-Host ("  {0}: {1}" -f $rule.Key, $status) -ForegroundColor $color
    }

    if ($shouldStop) {
        Write-Host "`nRECOMMENDATION: STOP meta-ing and START doing" -ForegroundColor Red
        Write-Host "Reason: Diminishing returns detected" -ForegroundColor Yellow
        return $false
    }
    else {
        Write-Host "`nRECOMMENDATION: Continue (but monitor closely)" -ForegroundColor Green
        return $true
    }
}

function Show-LevelGuidance {
    Write-Host "`n=== META-LEVEL GUIDANCE ===" -ForegroundColor Cyan

    $levels = @(
        @{ level = 0; name = "Object (Direct Work)"; roi = "10x"; description = "Create tools, write code, update docs"; color = "Green" }
        @{ level = 1; name = "Process (Improve Workflows)"; roi = "5x"; description = "Improve how we work (workflows, checklists)"; color = "Yellow" }
        @{ level = 2; name = "Meta-Process"; roi = "2x"; description = "Improve how we improve processes"; color = "DarkYellow" }
        @{ level = 3; name = "Meta-Meta"; roi = "1.1x"; description = "Improve improvement improvement (caution zone)"; color = "Red" }
        @{ level = 4; name = "TERMINATION"; roi = "0.8x"; description = "Definitely overthinking, STOP"; color = "DarkRed" }
    )

    foreach ($level in $levels) {
        Write-Host "`nLevel $($level.level): $($level.name)" -ForegroundColor $level.color
        Write-Host "  Expected ROI: $($level.roi)" -ForegroundColor White
        Write-Host "  Activity: $($level.description)" -ForegroundColor Gray
    }

    Write-Host "`nTermination Rule: Stop when ROI < 1.5x OR effort exceeds value" -ForegroundColor Yellow
    Write-Host "Pragmatism Over Perfection: At some point, just DO the thing" -ForegroundColor Green
}

# Main execution
if ($TrackImprovement) {
    if ($null -eq $Level -or $null -eq $ROI) {
        Write-Host "Error: -Level and -ROI required for tracking" -ForegroundColor Red
        exit 1
    }
    Track-Improvement -MetaLevel $Level -ROI $ROI
}
elseif ($ShouldContinue) {
    if ($null -eq $CurrentLevel) {
        Write-Host "Error: -CurrentLevel required" -ForegroundColor Red
        exit 1
    }
    $result = Test-ShouldContinue -Level $CurrentLevel
    exit $(if ($result) { 0 } else { 1 })
}
else {
    Show-LevelGuidance
}
