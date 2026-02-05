# Outcome Predictor (Iter 21) - Predict action outcomes
param([string]$Action, [string]$PredictedOutcome, [string]$ActualOutcome, [switch]$Accuracy)
$log = "C:\scripts\agentidentity\state\logs\predictions.jsonl"
if ($Action) { @{ts=Get-Date -Format "yyyy-MM-dd HH:mm:ss";action=$Action;predicted=$PredictedOutcome;actual=$ActualOutcome} | ConvertTo-Json -Compress | Add-Content $log }
if ($Accuracy) {
    $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json } | Where-Object { $_.actual }
    $correct = ($entries | Where-Object { $_.predicted -eq $_.actual }).Count
    $accuracy = [math]::Round(($correct / $entries.Count) * 100)
    Write-Host "Prediction Accuracy: $accuracy% ($correct/$($entries.Count))" -ForegroundColor Cyan
}
