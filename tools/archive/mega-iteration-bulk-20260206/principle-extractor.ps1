# Principle Extractor (Iter 51)
param([string]$Experience, [string]$Principle, [switch]$Library)
$log = "C:\scripts\agentidentity\state\logs\principles.jsonl"
if ($Experience -and $Principle) {
    @{ts=Get-Date -Format "yyyy-MM-dd HH:mm:ss";experience=$Experience;principle=$Principle} | ConvertTo-Json -Compress | Add-Content $log
    Write-Host "✓ Principle extracted: $Principle" -ForegroundColor Green
}
if ($Library) {
    if (Test-Path $log) {
        $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json }
        Write-Host "Wisdom Library ($($entries.Count) principles):" -ForegroundColor Yellow
        $entries | Select-Object -Last 10 | ForEach-Object { Write-Host "  - $($_.principle)" -ForegroundColor White }
    }
}
