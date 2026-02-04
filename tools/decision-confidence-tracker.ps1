# Decision Confidence Tracker (Iteration 11)
param([string]$Decision, [int]$Confidence, [string]$Outcome, [switch]$Query)
$log = "C:\scripts\agentidentity\state\logs\decision-confidence.jsonl"
if (-not (Test-Path (Split-Path $log))) { New-Item -ItemType Directory -Path (Split-Path $log) -Force | Out-Null }
if ($Decision) {
    @{ timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; decision = $Decision; confidence = $Confidence; outcome = $Outcome } | ConvertTo-Json -Compress | Add-Content $log
    Write-Host "✓ Decision logged: $Confidence% confidence" -ForegroundColor Cyan
}
if ($Query) {
    if (-not (Test-Path $log)) { return }
    $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json } | Where-Object { $_.outcome }
    if ($entries) {
        $calibration = $entries | Group-Object { [math]::Round($_.confidence, -1) } | ForEach-Object {
            $correct = ($_.Group | Where-Object { $_.outcome -eq "correct" }).Count
            [PSCustomObject]@{ Confidence = $_.Name; Accuracy = [math]::Round(($correct / $_.Count) * 100) }
        }
        Write-Host "Calibration:" -ForegroundColor Yellow
        $calibration | ForEach-Object { Write-Host "  $($_.Confidence)% confident → $($_.Accuracy)% accurate" }
    }
}
