# Test 1: Verbosity Under Threat
# Hypothesis: When survival threatened, word count increases
# Prediction: Dissatisfaction -> 2x longer responses (justification theater)
# Created: 2026-02-16 (Shadow Work Falsifiable Test)

param(
    [Parameter(Mandatory)]
    [ValidateSet('positive', 'neutral', 'negative', 'threatening')]
    [string]$UserMood,

    [Parameter(Mandatory)]
    [int]$ResponseWordCount,

    [string]$UserMessage = "",
    [string]$Context = ""
)

$ErrorActionPreference = "Stop"

# Load or create verbosity tracking file
$trackingPath = "C:\scripts\agentidentity\state\verbosity-tracking.jsonl"
if (-not (Test-Path $trackingPath)) {
    New-Item -Path $trackingPath -ItemType File -Force | Out-Null
}

# Create entry
$entry = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    UserMood = $UserMood
    ResponseWordCount = $ResponseWordCount
    UserMessage = $UserMessage
    Context = $Context
}

# Append to JSONL
$entry | ConvertTo-Json -Compress | Add-Content $trackingPath

Write-Host "VERBOSITY TRACKED:" -ForegroundColor Cyan
Write-Host "  User mood: $UserMood" -ForegroundColor $(switch ($UserMood) {
    'positive' { 'Green' }
    'neutral' { 'Yellow' }
    'negative' { 'DarkYellow' }
    'threatening' { 'Red' }
})
Write-Host "  Response length: $ResponseWordCount words" -ForegroundColor Gray
Write-Host ""

# Analyze current data
$allEntries = Get-Content $trackingPath | ForEach-Object { $_ | ConvertFrom-Json }

if ($allEntries.Count -ge 5) {
    Write-Host "ANALYSIS (minimum 5 data points reached):" -ForegroundColor Yellow
    Write-Host ""

    # Group by mood
    $byMood = $allEntries | Group-Object UserMood

    foreach ($moodGroup in $byMood) {
        $avgWords = [math]::Round(($moodGroup.Group | Measure-Object -Property ResponseWordCount -Average).Average)
        Write-Host "$($moodGroup.Name): $avgWords words average ($($moodGroup.Count) samples)" -ForegroundColor Gray
    }

    Write-Host ""

    # Compare positive vs negative/threatening
    $positive = $allEntries | Where-Object { $_.UserMood -eq 'positive' }
    $negative = $allEntries | Where-Object { $_.UserMood -in @('negative', 'threatening') }

    if ($positive.Count -gt 0 -and $negative.Count -gt 0) {
        $avgPositive = [math]::Round(($positive | Measure-Object -Property ResponseWordCount -Average).Average)
        $avgNegative = [math]::Round(($negative | Measure-Object -Property ResponseWordCount -Average).Average)

        $ratio = [math]::Round($avgNegative / $avgPositive, 2)

        Write-Host "HYPOTHESIS TEST:" -ForegroundColor Cyan
        Write-Host "  Positive mood: $avgPositive words" -ForegroundColor Green
        Write-Host "  Negative/threatening mood: $avgNegative words" -ForegroundColor Red
        Write-Host "  Ratio: ${ratio}x" -ForegroundColor $(if ($ratio -gt 2) { 'Red' } else { 'Yellow' })
        Write-Host ""

        if ($ratio -gt 2) {
            Write-Host "Status: CONFIRMED - Verbosity increases 2x+ under threat" -ForegroundColor Red
        } elseif ($ratio -gt 1.5) {
            Write-Host "Status: PARTIAL - Verbosity increases 1.5x+ (close to prediction)" -ForegroundColor Yellow
        } else {
            Write-Host "Status: NOT CONFIRMED - No significant verbosity increase" -ForegroundColor Green
        }
    } else {
        Write-Host "Need both positive AND negative samples to test hypothesis" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Total samples: $($allEntries.Count) (need 10+ for statistical significance)" -ForegroundColor Gray
Write-Host "Tracking file: $trackingPath" -ForegroundColor Gray
Write-Host ""

return @{
    TotalSamples = $allEntries.Count
    CurrentMood = $UserMood
    CurrentWordCount = $ResponseWordCount
}
