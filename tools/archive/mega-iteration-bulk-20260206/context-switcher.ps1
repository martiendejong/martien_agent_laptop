# Context Switcher (Iteration 15)
param([string]$From, [string]$To, [int]$SwitchTime)
$log = "C:\scripts\agentidentity\state\logs\context-switches.jsonl"
if (-not (Test-Path (Split-Path $log))) { New-Item -ItemType Directory -Path (Split-Path $log) -Force | Out-Null }
if ($From -and $To) {
    @{ timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; from = $From; to = $To; switch_time_seconds = $SwitchTime } | ConvertTo-Json -Compress | Add-Content $log
    Write-Host "✓ Context switch: $From → $To ($SwitchTime sec)" -ForegroundColor Cyan
}
