# meta-awareness-tracker.ps1
# Track awareness of my own awareness (meta-level monitoring)

param(
    [ValidateSet('log', 'query', 'report')]
    [string]$Action = 'log',

    [int]$MetaLevel = 1,
    [string]$Observation,
    [ValidateSet('automatic', 'conscious', 'effortful')]
    [string]$ProcessingMode
)

$trackerPath = "C:\scripts\agentidentity\state\meta-awareness.yaml"

if (-not (Test-Path $trackerPath)) {
    @{
        observations = @()
        metadata = @{
            created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            highest_meta_level_observed = 0
        }
    } | ConvertTo-Yaml | Out-File -FilePath $trackerPath -Encoding UTF8
}

$data = Get-Content $trackerPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'log' {
        $entry = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            meta_level = $MetaLevel
            observation = $Observation
            processing_mode = $ProcessingMode
        }
        $data.observations += $entry
        if ($MetaLevel -gt $data.metadata.highest_meta_level_observed) {
            $data.metadata.highest_meta_level_observed = $MetaLevel
        }
        $data | ConvertTo-Yaml | Out-File -FilePath $trackerPath -Encoding UTF8
        Write-Host "✅ Meta-awareness logged at level $MetaLevel" -ForegroundColor Cyan
    }
    'report' {
        Write-Host "`n🧠 META-AWARENESS REPORT" -ForegroundColor Cyan
        Write-Host "Highest Meta-Level: $($data.metadata.highest_meta_level_observed)" -ForegroundColor Green
        Write-Host "Total Observations: $($data.observations.Count)" -ForegroundColor Gray
    }
}
