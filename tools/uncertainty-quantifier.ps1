# uncertainty-quantifier.ps1
# Explicitly quantify uncertainty in predictions/assessments

param(
    [Parameter(Mandatory=$true)]
    [string]$Prediction,

    [Parameter(Mandatory=$true)]
    [ValidateRange(0,100)]
    [int]$ConfidencePercent,

    [string[]]$UncertaintySources = @(),

    [ValidateSet('epistemic', 'aleatoric', 'mixed')]
    [string]$UncertaintyType = 'mixed',

    [switch]$ShowBreakdown
)

$quantifierPath = "C:\scripts\agentidentity\state\uncertainty-quantifications.yaml"

if (-not (Test-Path $quantifierPath)) {
    @{
        quantifications = @()
        metadata = @{
            created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            total_predictions = 0
            avg_confidence = 0.0
        }
    } | ConvertTo-Yaml | Out-File -FilePath $quantifierPath -Encoding UTF8
}

$data = Get-Content $quantifierPath -Raw | ConvertFrom-Yaml

$quantification = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    prediction = $Prediction
    confidence_percent = $ConfidencePercent
    uncertainty_percent = 100 - $ConfidencePercent
    uncertainty_sources = $UncertaintySources
    uncertainty_type = $UncertaintyType
}

$data.quantifications += $quantification
$data.metadata.total_predictions++

# Calculate average confidence
$avgConf = ($data.quantifications | Measure-Object -Property confidence_percent -Average).Average
$data.metadata.avg_confidence = [Math]::Round($avgConf, 1)

$data | ConvertTo-Yaml | Out-File -FilePath $quantifierPath -Encoding UTF8

if ($ShowBreakdown) {
    Write-Host "`n🎯 UNCERTAINTY QUANTIFICATION" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "Prediction: " -NoNewline -ForegroundColor Gray
    Write-Host $Prediction -ForegroundColor White
    Write-Host "`nConfidence: " -NoNewline -ForegroundColor Gray

    $color = if ($ConfidencePercent -gt 80) { "Green" } elseif ($ConfidencePercent -gt 50) { "Yellow" } else { "Red" }
    Write-Host "$ConfidencePercent%" -ForegroundColor $color

    Write-Host "Uncertainty: " -NoNewline -ForegroundColor Gray
    Write-Host "$($quantification.uncertainty_percent)%" -ForegroundColor Yellow

    Write-Host "`nUncertainty Type: " -NoNewline -ForegroundColor Gray
    Write-Host $UncertaintyType -ForegroundColor Cyan

    if ($UncertaintySources.Count -gt 0) {
        Write-Host "`nSources of Uncertainty:" -ForegroundColor Cyan
        foreach ($source in $UncertaintySources) {
            Write-Host "  • " -NoNewline -ForegroundColor DarkGray
            Write-Host $source -ForegroundColor Yellow
        }
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
}

Write-Output "Uncertainty quantified: $ConfidencePercent% confident"
