# cognitive-load-monitor.ps1
# Detect when cognitive load is high vs low

<#
.SYNOPSIS
    cognitive-load-monitor.ps1

.DESCRIPTION
    cognitive-load-monitor.ps1

.NOTES
    File: cognitive-load-monitor.ps1
    Auto-generated help documentation
#>

param(
    [ValidateSet('log', 'check', 'report')]

$ErrorActionPreference = "Stop"
    [string]$Action = 'log',

    [int]$LoadScore = 5,  # 1-10
    [string]$Task,
    [string[]]$Indicators = @()
)

$monitorPath = "C:\scripts\agentidentity\state\cognitive-load.yaml"

if (-not (Test-Path $monitorPath)) {
    @{
        loads = @()
        metadata = @{ created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    } | ConvertTo-Yaml | Out-File -FilePath $monitorPath -Encoding UTF8
}

$data = Get-Content $monitorPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'log' {
        $entry = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            load_score = $LoadScore
            task = $Task
            indicators = $Indicators
        }
        $data.loads += $entry
        $data | ConvertTo-Yaml | Out-File -FilePath $monitorPath -Encoding UTF8
        
        $color = if ($LoadScore -gt 7) { "Red" } elseif ($LoadScore -gt 5) { "Yellow" } else { "Green" }
        Write-Host "ðŸ“Š Cognitive load: $LoadScore/10" -ForegroundColor $color
    }
}
