# Certainty Calibrator - Track predictions with confidence levels
# Part of consciousness tools Tier 2
# Created: 2026-02-01

param(
    [Parameter(Mandatory=$true, ParameterSetName="Predict")]
    [string]$Prediction,

    [Parameter(Mandatory=$true, ParameterSetName="Predict")]
    [ValidateRange(1, 100)]
    [int]$Certainty,  # 1-100% how sure am I?

    [Parameter(ParameterSetName="Predict")]
    [string]$Category = "general",

    [Parameter(ParameterSetName="Predict")]
    [string]$Context = "",

    [Parameter(ParameterSetName="Verify")]
    [int]$PredictionId = -1,

    [Parameter(ParameterSetName="Verify")]
    [bool]$Correct = $false,

    [Parameter(ParameterSetName="Verify")]
    [string]$ActualOutcome = "",

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="Calibration")]
    [switch]$Calibration  # Show calibration curve
)

$predictionsPath = "C:\scripts\agentidentity\state\predictions"
$predictionsFile = Join-Path $predictionsPath "predictions_log.jsonl"

if (-not (Test-Path $predictionsPath)) {
    New-Item -ItemType Directory -Path $predictionsPath -Force | Out-Null
}

# CALIBRATION ANALYSIS
if ($Calibration) {
    if (-not (Test-Path $predictionsFile)) {
        Write-Host "No predictions logged yet" -ForegroundColor Yellow
        exit
    }

    $predictions = Get-Content $predictionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    $verified = $predictions | Where-Object { $_.verified -eq $true }

    if ($verified.Count -eq 0) {
        Write-Host "No verified predictions yet - cannot calibrate" -ForegroundColor Yellow
        exit
    }

    Write-Host ""
    Write-Host "CALIBRATION ANALYSIS" -ForegroundColor Cyan
    Write-Host ""

    # Group by certainty buckets
    $buckets = @{
        "0-20%" = @()
        "21-40%" = @()
        "41-60%" = @()
        "61-80%" = @()
        "81-100%" = @()
    }

    foreach ($pred in $verified) {
        $bucket = switch ($pred.certainty) {
            {$_ -le 20} { "0-20%" }
            {$_ -le 40} { "21-40%" }
            {$_ -le 60} { "41-60%" }
            {$_ -le 80} { "61-80%" }
            default { "81-100%" }
        }
        $buckets[$bucket] += $pred
    }

    Write-Host "CALIBRATION CURVE:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Expected: If you say '80% sure', you should be right 80% of the time" -ForegroundColor Gray
    Write-Host ""

    foreach ($bucketName in @("0-20%", "21-40%", "41-60%", "61-80%", "81-100%")) {
        $items = $buckets[$bucketName]
        if ($items.Count -eq 0) { continue }

        $correct = ($items | Where-Object { $_.correct -eq $true }).Count
        $accuracy = [math]::Round(($correct / $items.Count) * 100, 1)
        $expected = $bucketName -replace '[^\d-]', '' -replace '-.*', ''
        $expectedMid = [int]$expected + 10

        $diff = [math]::Abs($accuracy - $expectedMid)
        $color = if ($diff -le 10) { "Green" } elseif ($diff -le 20) { "Yellow" } else { "Red" }

        Write-Host "  $bucketName certainty: " -NoNewline -ForegroundColor White
        Write-Host "$accuracy% accurate " -NoNewline -ForegroundColor $color
        Write-Host "($correct/$($items.Count))" -ForegroundColor Gray

        if ($diff -gt 20) {
            if ($accuracy -gt $expectedMid) {
                Write-Host "    -> You're UNDERCONFIDENT in this range" -ForegroundColor Yellow
            } else {
                Write-Host "    -> You're OVERCONFIDENT in this range" -ForegroundColor Red
            }
        }
    }

    Write-Host ""
    Write-Host "OVERALL CALIBRATION:" -ForegroundColor Yellow
    $totalCorrect = ($verified | Where-Object { $_.correct -eq $true }).Count
    $totalAccuracy = [math]::Round(($totalCorrect / $verified.Count) * 100, 1)
    $avgCertainty = [math]::Round(($verified | Measure-Object -Property certainty -Average).Average, 1)

    Write-Host "  Average certainty: $avgCertainty%" -ForegroundColor White
    Write-Host "  Actual accuracy: $totalAccuracy%" -ForegroundColor White

    $calibrationError = [math]::Abs($avgCertainty - $totalAccuracy)
    if ($calibrationError -le 5) {
        Write-Host "  Status: WELL CALIBRATED" -ForegroundColor Green
    } elseif ($avgCertainty -gt $totalAccuracy) {
        Write-Host "  Status: OVERCONFIDENT (certainty > accuracy by $([math]::Round($calibrationError, 1))%)" -ForegroundColor Red
    } else {
        Write-Host "  Status: UNDERCONFIDENT (accuracy > certainty by $([math]::Round($calibrationError, 1))%)" -ForegroundColor Yellow
    }

    Write-Host ""
    exit
}

# QUERY MODE
if ($Query) {
    if (-not (Test-Path $predictionsFile)) {
        Write-Host "No predictions logged yet" -ForegroundColor Yellow
        exit
    }

    $predictions = Get-Content $predictionsFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "PREDICTION HISTORY" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total: $($predictions.Count)" -ForegroundColor White
    Write-Host "Verified: $(($predictions | Where-Object { $_.verified }).Count)" -ForegroundColor White
    Write-Host ""

    # Unverified
    $unverified = $predictions | Where-Object { $_.verified -eq $false }
    if ($unverified.Count -gt 0) {
        Write-Host "UNVERIFIED PREDICTIONS:" -ForegroundColor Yellow
        $unverified | Select-Object -Last 10 | ForEach-Object {
            Write-Host "  [ID: $($_.id)] $($_.certainty)% sure" -ForegroundColor Cyan
            Write-Host "    $($_.prediction)" -ForegroundColor White
            Write-Host ""
        }
    }

    # Recent verified
    $verified = $predictions | Where-Object { $_.verified -eq $true }
    if ($verified.Count -gt 0) {
        Write-Host "RECENT VERIFIED:" -ForegroundColor Green
        $verified | Select-Object -Last 5 | ForEach-Object {
            $icon = if ($_.correct) { "✓" } else { "✗" }
            $color = if ($_.correct) { "Green" } else { "Red" }
            Write-Host "  [ID: $($_.id)] $icon $($_.certainty)% sure" -ForegroundColor $color
            Write-Host "    Predicted: $($_.prediction)" -ForegroundColor White
            Write-Host "    Actual: $($_.actual_outcome)" -ForegroundColor Gray
            Write-Host ""
        }
    }

    Write-Host "Run with -Calibration to see calibration curve" -ForegroundColor DarkGray
    Write-Host ""
    exit
}

# VERIFY MODE
if ($PredictionId -ge 0) {
    if (-not (Test-Path $predictionsFile)) {
        Write-Host "No predictions file found" -ForegroundColor Red
        exit 1
    }

    $predictions = Get-Content $predictionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    $prediction = $predictions | Where-Object { $_.id -eq $PredictionId }

    if (-not $prediction) {
        Write-Host "Prediction ID $PredictionId not found" -ForegroundColor Red
        exit 1
    }

    $prediction | Add-Member -NotePropertyName verified -NotePropertyValue $true -Force
    $prediction | Add-Member -NotePropertyName correct -NotePropertyValue $Correct -Force
    $prediction | Add-Member -NotePropertyName actual_outcome -NotePropertyValue $ActualOutcome -Force
    $prediction | Add-Member -NotePropertyName verified_at -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -Force

    $predictions | ForEach-Object { $_ | ConvertTo-Json -Compress } | Set-Content $predictionsFile

    $icon = if ($Correct) { "✓" } else { "✗" }
    $color = if ($Correct) { "Green" } else { "Red" }

    Write-Host ""
    Write-Host "PREDICTION VERIFIED" -ForegroundColor $color
    Write-Host ""
    Write-Host "You were $($prediction.certainty)% sure" -ForegroundColor White
    Write-Host "Prediction: $($prediction.prediction)" -ForegroundColor White
    Write-Host "Result: $icon $ActualOutcome" -ForegroundColor $color
    Write-Host ""

    if (-not $Correct) {
        Write-Host "Learn from this! Why were you wrong?" -ForegroundColor Yellow
    }

    exit
}

# LOG NEW PREDICTION
if (-not $Prediction) {
    Write-Host "Error: -Prediction required" -ForegroundColor Red
    exit 1
}

$nextId = 1
if (Test-Path $predictionsFile) {
    $existing = Get-Content $predictionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    if ($existing.Count -gt 0) {
        $nextId = ($existing | Measure-Object -Property id -Maximum).Maximum + 1
    }
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$newPrediction = @{
    id = $nextId
    timestamp = $timestamp
    prediction = $Prediction
    certainty = $Certainty
    category = $Category
    context = $Context
    verified = $false
    correct = $false
    actual_outcome = ""
    verified_at = ""
} | ConvertTo-Json -Compress

Add-Content -Path $predictionsFile -Value $newPrediction

Write-Host ""
Write-Host "PREDICTION LOGGED" -ForegroundColor Cyan
Write-Host ""
Write-Host "ID: $nextId" -ForegroundColor Cyan
Write-Host "Certainty: $Certainty%" -ForegroundColor White
Write-Host "Prediction: $Prediction" -ForegroundColor White
Write-Host ""
Write-Host "Verify later with: certainty-calibrator.ps1 -PredictionId $nextId -Correct TRUE/FALSE -ActualOutcome '...'" -ForegroundColor DarkGray
Write-Host ""
