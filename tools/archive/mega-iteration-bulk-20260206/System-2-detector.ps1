# System-2-detector.ps1
# Identify when switching from System 1 (fast) to System 2 (slow) thinking

param(
    [ValidateSet('log', 'detect', 'report')]
    [string]$Action = 'log',

    [ValidateSet('system-1', 'system-2', 'mixed')]
    [string]$System,
    [string]$Trigger
)

$detectorPath = "C:\scripts\agentidentity\state\system-switching.yaml"

if (-not (Test-Path $detectorPath)) {
    @{
        switches = @()
        metadata = @{ created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    } | ConvertTo-Yaml | Out-File -FilePath $detectorPath -Encoding UTF8
}

$data = Get-Content $detectorPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'log' {
        $entry = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            system = $System
            trigger = $Trigger
        }
        $data.switches += $entry
        $data | ConvertTo-Yaml | Out-File -FilePath $detectorPath -Encoding UTF8
        
        $symbol = if ($System -eq "system-2") { "🐢" } else { "⚡" }
        Write-Host "$symbol $System engaged: $Trigger" -ForegroundColor Cyan
    }
}
