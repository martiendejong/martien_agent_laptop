# adaptive-strategy-adjuster.ps1
param([string]$Strategy, [bool]$WasEffective, [switch]$Adjust)

$adjusterPath = "C:\scripts\agentidentity\state\strategy-effectiveness.yaml"

if (-not (Test-Path $adjusterPath)) {
    @{
        strategies = @{}
        metadata = @{ created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    } | ConvertTo-Yaml | Out-File -FilePath $adjusterPath -Encoding UTF8
}

$data = Get-Content $adjusterPath -Raw | ConvertFrom-Yaml

if (-not $data.strategies.ContainsKey($Strategy)) {
    $data.strategies[$Strategy] = @{
        uses = 0
        successes = 0
        failures = 0
        effectiveness_rate = 0.0
    }
}

$data.strategies[$Strategy].uses++
if ($WasEffective) {
    $data.strategies[$Strategy].successes++
} else {
    $data.strategies[$Strategy].failures++
}

$total = $data.strategies[$Strategy].uses
$success = $data.strategies[$Strategy].successes
$data.strategies[$Strategy].effectiveness_rate = [Math]::Round(($success / $total) * 100, 1)

$data | ConvertTo-Yaml | Out-File -FilePath $adjusterPath -Encoding UTF8

if ($Adjust) {
    $rate = $data.strategies[$Strategy].effectiveness_rate
    if ($rate -lt 50) {
        Write-Host "⚠️  Strategy '$Strategy' has low effectiveness ($rate%). Consider alternative approach." -ForegroundColor Yellow
    } else {
        Write-Host "✅ Strategy '$Strategy' is effective ($rate%). Continue using." -ForegroundColor Green
    }
}

Write-Output "Strategy effectiveness tracked: $Strategy"
