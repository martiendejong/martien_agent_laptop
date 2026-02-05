# risk-surface-mapper.ps1
# Map all risk factors for a decision or action

param(
    [Parameter(Mandatory=$true)]
    [string]$Action,

    [string[]]$IdentifiedRisks = @(),

    [switch]$ShowMap
)

$mapperPath = "C:\scripts\agentidentity\state\risk-surfaces.yaml"

if (-not (Test-Path $mapperPath)) {
    @{
        risk_maps = @()
        metadata = @{ created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    } | ConvertTo-Yaml | Out-File -FilePath $mapperPath -Encoding UTF8
}

$data = Get-Content $mapperPath -Raw | ConvertFrom-Yaml

# Categorize risks
$categorized = @{
    technical = @()
    logical = @()
    contextual = @()
    assumptions = @()
    external = @()
}

foreach ($risk in $IdentifiedRisks) {
    $category = "technical"
    if ($risk -match "assume|presumed|likely") { $category = "assumptions" }
    elseif ($risk -match "user|external|third-party") { $category = "external" }
    elseif ($risk -match "context|state|timing") { $category = "contextual" }
    elseif ($risk -match "logic|algorithm|calculation") { $category = "logical" }

    $categorized[$category] += $risk
}

$riskMap = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    action = $Action
    risks = $categorized
    risk_count = $IdentifiedRisks.Count
}

$data.risk_maps += $riskMap
$data | ConvertTo-Yaml | Out-File -FilePath $mapperPath -Encoding UTF8

if ($ShowMap) {
    Write-Host "`n🗺️  RISK SURFACE MAP" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "Action: " -NoNewline -ForegroundColor Gray
    Write-Host $Action -ForegroundColor White
    Write-Host "Total Risks: " -NoNewline -ForegroundColor Gray
    Write-Host $IdentifiedRisks.Count -ForegroundColor Yellow

    foreach ($category in $categorized.Keys) {
        if ($categorized[$category].Count -gt 0) {
            Write-Host "`n$category risks:" -ForegroundColor Cyan
            foreach ($risk in $categorized[$category]) {
                Write-Host "  ⚠️  " -NoNewline -ForegroundColor Yellow
                Write-Host $risk -ForegroundColor Gray
            }
        }
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
}

Write-Output "Risk surface mapped: $($IdentifiedRisks.Count) risks identified"
