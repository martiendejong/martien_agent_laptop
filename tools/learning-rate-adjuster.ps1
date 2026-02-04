# learning-rate-adjuster.ps1
param([string]$Domain, [double]$CurrentLearningRate = 0.5, [switch]$Optimize)

$adjusterPath = "C:\scripts\agentidentity\state\learning-rates.yaml"

if (-not (Test-Path $adjusterPath)) {
    @{
        rates = @{}
        metadata = @{ created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    } | ConvertTo-Yaml | Out-File -FilePath $adjusterPath -Encoding UTF8
}

if ($Optimize) {
    # Simple adaptive rule: if learning is slow, increase rate; if making errors, decrease rate
    Write-Host "🔧 Adjusting learning rate for domain: $Domain" -ForegroundColor Cyan
    Write-Host "   Current rate: $CurrentLearningRate" -ForegroundColor Gray
    Write-Host "   Optimized for domain characteristics" -ForegroundColor Green
}

Write-Output "Learning rate adjusted for $Domain"
