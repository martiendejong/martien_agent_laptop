# Quick Training Logger - Single-line calls
# Usage: .\log-training.ps1 -Type Vibe -Data @{...}

param(
    [Parameter(Mandatory)]
    [ValidateSet('Assumption', 'Vibe', 'Cost', 'Pattern', 'Proactive')]
    [string]$Type,

    [Parameter(Mandatory)]
    [hashtable]$Data
)

$LogFiles = @{
    'Assumption' = "C:\scripts\agentidentity\state\training\assumption-zero-log.jsonl"
    'Vibe' = "C:\scripts\agentidentity\state\training\vibe-calibration-log.jsonl"
    'Cost' = "C:\scripts\agentidentity\state\training\cost-awareness-log.jsonl"
    'Pattern' = "C:\scripts\agentidentity\state\training\pattern-recognition-log.jsonl"
    'Proactive' = "C:\scripts\agentidentity\state\training\proactive-detection-log.jsonl"
}

$Data['timestamp'] = (Get-Date).ToUniversalTime().ToString('o')
$json = $Data | ConvertTo-Json -Compress
Add-Content -Path $LogFiles[$Type] -Value $json

Write-Host "[LOGGED] $Type training event" -ForegroundColor Green
