# uncertainty-communication.ps1
# Communicate uncertainty clearly to users

param(
    [Parameter(Mandatory=$true)]
    [string]$Statement,

    [Parameter(Mandatory=$true)]
    [ValidateRange(0,100)]
    [int]$ConfidencePercent,

    [switch]$GeneratePhrase
)

# Confidence phrases mapping
$confidencePhrases = @{
    95 = "almost certain"
    90 = "very confident"
    80 = "confident"
    70 = "fairly confident"
    60 = "more likely than not"
    50 = "uncertain"
    40 = "more unlikely than likely"
    30 = "fairly unlikely"
    20 = "quite unlikely"
    10 = "very unlikely"
    5 = "almost certainly not"
}

function Get-ConfidencePhrase {
    param([int]$confidence)

    # Find closest match
    $closest = $confidencePhrases.Keys | Sort-Object { [Math]::Abs($_ - $confidence) } | Select-Object -First 1
    return $confidencePhrases[$closest]
}

if ($GeneratePhrase) {
    $phrase = Get-ConfidencePhrase -confidence $ConfidencePercent

    Write-Host "`n💬 UNCERTAINTY COMMUNICATION" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "Statement: " -NoNewline -ForegroundColor Gray
    Write-Host $Statement -ForegroundColor White
    Write-Host "Confidence: " -NoNewline -ForegroundColor Gray
    Write-Host "$ConfidencePercent%" -ForegroundColor Yellow

    Write-Host "`nSuggested Phrasing:" -ForegroundColor Cyan
    Write-Host "  ""I'm $phrase that $Statement""" -ForegroundColor Green

    Write-Host "`nAlternatives:" -ForegroundColor Cyan
    if ($ConfidencePercent -ge 80) {
        Write-Host "  • ""Based on available evidence, $Statement""" -ForegroundColor Gray
        Write-Host "  • ""The data strongly suggests $Statement""" -ForegroundColor Gray
    } elseif ($ConfidencePercent -ge 60) {
        Write-Host "  • ""The evidence leans toward: $Statement""" -ForegroundColor Gray
        Write-Host "  • ""More likely than not, $Statement""" -ForegroundColor Gray
    } elseif ($ConfidencePercent -ge 40) {
        Write-Host "  • ""It's uncertain whether $Statement""" -ForegroundColor Gray
        Write-Host "  • ""The evidence is mixed on: $Statement""" -ForegroundColor Gray
    } else {
        Write-Host "  • ""The evidence doesn't support: $Statement""" -ForegroundColor Gray
        Write-Host "  • ""It's unlikely that $Statement""" -ForegroundColor Gray
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
}

# Log communication
$logPath = "C:\scripts\agentidentity\state\uncertainty-communications.yaml"
if (-not (Test-Path $logPath)) {
    @{
        communications = @()
        metadata = @{ created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    } | ConvertTo-Yaml | Out-File -FilePath $logPath -Encoding UTF8
}

$data = Get-Content $logPath -Raw | ConvertFrom-Yaml
$data.communications += @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    statement = $Statement
    confidence_percent = $ConfidencePercent
    phrase_used = Get-ConfidencePhrase -confidence $ConfidencePercent
}

# Keep last 100
if ($data.communications.Count -gt 100) {
    $data.communications = $data.communications[-100..-1]
}

$data | ConvertTo-Yaml | Out-File -FilePath $logPath -Encoding UTF8

Write-Output "Uncertainty communicated: $ConfidencePercent% confident"
