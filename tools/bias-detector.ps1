# bias-detector.ps1
# Detect cognitive biases in reasoning

<#
.SYNOPSIS
    bias-detector.ps1

.DESCRIPTION
    bias-detector.ps1

.NOTES
    File: bias-detector.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$true)]

$ErrorActionPreference = "Stop"
    [string]$Reasoning,

    [string[]]$SuspectedBiases = @(),

    [switch]$Analyze
)

$biasPatterns = @{
    'confirmation' = @('supports my view', 'as expected', 'proves that', 'obviously')
    'anchoring' = @('initially', 'first impression', 'started with')
    'availability' = @('recently', 'just saw', 'common example')
    'recency' = @('latest', 'most recent', 'just now')
    'authority' = @('expert says', 'according to', 'well-known')
    'sunk-cost' = @('already invested', 'wasted', 'so far')
}

$detectorPath = "C:\scripts\agentidentity\state\bias-detections.yaml"

if (-not (Test-Path $detectorPath)) {
    @{
        detections = @()
        metadata = @{ created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss"); total_biases_detected = 0 }
    } | ConvertTo-Yaml | Out-File -FilePath $detectorPath -Encoding UTF8
}

$detected = @()
foreach ($biasType in $biasPatterns.Keys) {
    foreach ($pattern in $biasPatterns[$biasType]) {
        if ($Reasoning -match $pattern) {
            $detected += $biasType
            break
        }
    }
}

$detected = $detected | Select-Object -Unique

if ($Analyze) {
    Write-Host "`nðŸ” BIAS DETECTION ANALYSIS" -ForegroundColor Cyan
    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”" -ForegroundColor DarkGray

    if ($detected.Count -gt 0) {
        Write-Host "âš ï¸  Potential biases detected: $($detected.Count)" -ForegroundColor Yellow
        foreach ($bias in $detected) {
            Write-Host "  â€¢ " -NoNewline -ForegroundColor DarkGray
            Write-Host $bias -ForegroundColor Red
        }
    } else {
        Write-Host "âœ… No obvious bias patterns detected" -ForegroundColor Green
    }

    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”" -ForegroundColor DarkGray
}

$data = Get-Content $detectorPath -Raw | ConvertFrom-Yaml
$data.detections += @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    reasoning = $Reasoning
    detected_biases = $detected
    suspected_biases = $SuspectedBiases
}
$data.metadata.total_biases_detected += $detected.Count
$data | ConvertTo-Yaml | Out-File -FilePath $detectorPath -Encoding UTF8

Write-Output "Bias detection complete: $($detected.Count) potential biases"
