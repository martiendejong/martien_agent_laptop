# Training Dashboard - Quick Status View
$TrainingDir = "C:\scripts\agentidentity\state\training"

function Get-DaysSinceStart {
    $start = [datetime]"2026-02-16"
    return ([int]((Get-Date) - $start).TotalDays) + 1
}

function Get-LogCount {
    param($File)
    if (Test-Path $File) { return (Get-Content $File | Measure-Object -Line).Lines }
    return 0
}

$day = Get-DaysSinceStart
$daysLeft = 8 - $day

Write-Host ""
Write-Host "COGNITIVE TRAINING DASHBOARD - DAY $day/7" -ForegroundColor Cyan
Write-Host "$daysLeft days until validation" -ForegroundColor Cyan
Write-Host ""

$counts = @(
    (Get-LogCount "$TrainingDir\assumption-zero-log.jsonl"),
    (Get-LogCount "$TrainingDir\vibe-calibration-log.jsonl"),
    (Get-LogCount "$TrainingDir\cost-awareness-log.jsonl"),
    (Get-LogCount "$TrainingDir\pattern-recognition-log.jsonl"),
    (Get-LogCount "$TrainingDir\proactive-detection-log.jsonl")
)

Write-Host "[1] ASSUMPTION ZERO: $($counts[0]) entries (target: 80% caught, under 10min avg)"
Write-Host "[2] VIBE CALIBRATION: $($counts[1]) entries (target: 90% emotion accuracy, under 2pts error)"
Write-Host "[3] COST AWARENESS: $($counts[2]) entries (target: 100% calculated first, zero surprises)"
Write-Host "[4] PATTERN RECOGNITION: $($counts[3]) entries (target: under 30s avg, 80% correct)"
Write-Host "[5] PROACTIVE DETECTION: $($counts[4]) entries (target: 3+ per week, under 20% false)"
Write-Host ""

$total = ($counts | Measure-Object -Sum).Sum
$perDay = if ($day -gt 0) { [math]::Round($total / $day, 1) } else { 0 }
Write-Host "TOTAL: $total events (avg $perDay per day)" -ForegroundColor Green
Write-Host ""
