# confirmation-bias-checker.ps1
# Check if selectively gathering evidence that confirms initial belief

param(
    [string]$InitialBelief,
    [string[]]$EvidenceGathered = @(),
    [switch]$Check
)

$checkerPath = "C:\scripts\agentidentity\state\confirmation-bias-checks.yaml"

if (-not (Test-Path $checkerPath)) {
    @{
        checks = @()
        metadata = @{ created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    } | ConvertTo-Yaml | Out-File -FilePath $checkerPath -Encoding UTF8
}

if ($Check) {
    $supporting = 0
    $contradicting = 0

    foreach ($evidence in $EvidenceGathered) {
        if ($evidence -match 'supports|confirms|validates|proves') {
            $supporting++
        } elseif ($evidence -match 'contradicts|challenges|disproves|against') {
            $contradicting++
        }
    }

    Write-Host "`n🎯 CONFIRMATION BIAS CHECK" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "Supporting evidence: $supporting" -ForegroundColor Gray
    Write-Host "Contradicting evidence: $contradicting" -ForegroundColor Gray

    if ($supporting -gt $contradicting * 2) {
        Write-Host "`n⚠️  WARNING: Possible confirmation bias" -ForegroundColor Red
        Write-Host "   Ratio too skewed toward supporting evidence" -ForegroundColor Yellow
    } else {
        Write-Host "`n✅ Evidence gathering appears balanced" -ForegroundColor Green
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
}

Write-Output "Confirmation bias checked"
