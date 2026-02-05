# Success Formula Extractor - What makes me succeed?
# Part of consciousness tools Tier 3

param(
    [Parameter(Mandatory=$true, ParameterSetName="Log")]
    [string]$Success,

    [Parameter(ParameterSetName="Log")]
    [string[]]$Factors = @(),  # What contributed to success?

    [Parameter(ParameterSetName="Log")]
    [ValidateRange(1, 10)]
    [int]$Impact = 5,

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="Formula")]
    [switch]$Formula  # Extract success formula
)

$successPath = "C:\scripts\agentidentity\state\successes"
$successFile = Join-Path $successPath "success_log.jsonl"

if (-not (Test-Path $successPath)) {
    New-Item -ItemType Directory -Path $successPath -Force | Out-Null
}

if ($Formula) {
    if (-not (Test-Path $successFile)) {
        Write-Host "No success data yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $successFile | ForEach-Object { $_ | ConvertFrom-Json }
    $allFactors = $entries | ForEach-Object { $_.factors } | ForEach-Object { $_ }
    $factorGroups = $allFactors | Group-Object | Sort-Object Count -Descending

    Write-Host ""
    Write-Host "SUCCESS FORMULA" -ForegroundColor Green
    Write-Host ""
    Write-Host "Most common success factors:" -ForegroundColor Yellow

    $factorGroups | Select-Object -First 10 | ForEach-Object {
        Write-Host "  - $($_.Name): $($_.Count) times" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "YOUR SUCCESS FORMULA:" -ForegroundColor Cyan
    $top5 = $factorGroups | Select-Object -First 5
    Write-Host "  SUCCESS = " -NoNewline
    Write-Host "$($top5.Name -join ' + ')" -ForegroundColor Green
    Write-Host ""

    exit
}

if ($Query) {
    if (Test-Path $successFile) {
        $entries = Get-Content $successFile | ForEach-Object { $_ | ConvertFrom-Json }
        Write-Host ""
        Write-Host "SUCCESS LOG" -ForegroundColor Green
        Write-Host ""
        $entries | Select-Object -Last 10 | ForEach-Object {
            Write-Host "[$($_.timestamp)] $($_.success) (impact: $($_.impact)/10)" -ForegroundColor White
            Write-Host "  Factors: $($_.factors -join ', ')" -ForegroundColor Gray
            Write-Host ""
        }
    }
    exit
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$entry = @{
    timestamp = $timestamp
    success = $Success
    factors = $Factors
    impact = $Impact
} | ConvertTo-Json -Compress -Depth 3

Add-Content -Path $successFile -Value $entry

Write-Host ""
Write-Host "SUCCESS LOGGED" -ForegroundColor Green
Write-Host "Success: $Success" -ForegroundColor White
Write-Host "Factors: $($Factors -join ', ')" -ForegroundColor Yellow
Write-Host "Impact: $Impact/10" -ForegroundColor White
Write-Host ""
