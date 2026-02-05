# metacognitive-confidence.ps1
# Confidence in my meta-level assessments

param(
    [ValidateSet('log', 'report')]
    [string]$Action = 'log',

    [string]$Assessment,
    [int]$Confidence = 5,  # 1-10
    [string]$Reasoning
)

$confidencePath = "C:\scripts\agentidentity\state\metacognitive-confidence.yaml"

if (-not (Test-Path $confidencePath)) {
    @{
        assessments = @()
        metadata = @{ created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    } | ConvertTo-Yaml | Out-File -FilePath $confidencePath -Encoding UTF8
}

$data = Get-Content $confidencePath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'log' {
        $entry = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            assessment = $Assessment
            confidence = $Confidence
            reasoning = $Reasoning
        }
        $data.assessments += $entry
        $data | ConvertTo-Yaml | Out-File -FilePath $confidencePath -Encoding UTF8
        
        Write-Host "🎯 Meta-cognitive confidence: $Confidence/10" -ForegroundColor Cyan
    }
}
