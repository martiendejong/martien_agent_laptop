# Mistake Pattern Detector - Find root causes of errors
# Part of consciousness tools Tier 3

param(
    [Parameter(Mandatory=$true, ParameterSetName="Log")]
    [string]$Mistake,

    [Parameter(ParameterSetName="Log")]
    [string]$RootCause = "",

    [Parameter(ParameterSetName="Log")]
    [ValidateSet("rushed", "assumption", "knowledge-gap", "communication", "process", "oversight", "complexity")]
    [string]$Category = "oversight",

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="Patterns")]
    [switch]$Patterns
)

$mistakePath = "C:\scripts\agentidentity\state\mistakes"
$mistakeFile = Join-Path $mistakePath "mistakes_log.jsonl"

if (-not (Test-Path $mistakePath)) {
    New-Item -ItemType Directory -Path $mistakePath -Force | Out-Null
}

if ($Patterns) {
    if (-not (Test-Path $mistakeFile)) {
        Write-Host "No mistake data yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $mistakeFile | ForEach-Object { $_ | ConvertFrom-Json }
    $categoryGroups = $entries | Group-Object -Property category | Sort-Object Count -Descending

    Write-Host ""
    Write-Host "MISTAKE PATTERNS" -ForegroundColor Red
    Write-Host ""

    foreach ($group in $categoryGroups) {
        Write-Host "$($group.Name.ToUpper()): $($group.Count) mistakes" -ForegroundColor Yellow
        $group.Group | Select-Object -Last 3 | ForEach-Object {
            Write-Host "  - $($_.mistake)" -ForegroundColor White
            if ($_.root_cause) {
                Write-Host "    Root cause: $($_.root_cause)" -ForegroundColor Gray
            }
        }
        Write-Host ""
    }

    exit
}

if ($Query) {
    if (Test-Path $mistakeFile) {
        $entries = Get-Content $mistakeFile | ForEach-Object { $_ | ConvertFrom-Json }
        Write-Host ""
        Write-Host "MISTAKE LOG" -ForegroundColor Red
        Write-Host "Total: $($entries.Count)" -ForegroundColor White
        Write-Host ""
        $entries | Select-Object -Last 10 | ForEach-Object {
            Write-Host "[$($_.category)] $($_.mistake)" -ForegroundColor Yellow
            if ($_.root_cause) {
                Write-Host "  Root: $($_.root_cause)" -ForegroundColor Gray
            }
            Write-Host ""
        }
    }
    exit
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$entry = @{
    timestamp = $timestamp
    mistake = $Mistake
    root_cause = $RootCause
    category = $Category
} | ConvertTo-Json -Compress

Add-Content -Path $mistakeFile -Value $entry

Write-Host ""
Write-Host "MISTAKE LOGGED" -ForegroundColor Red
Write-Host "Category: $Category" -ForegroundColor Yellow
Write-Host "Mistake: $Mistake" -ForegroundColor White
if ($RootCause) {
    Write-Host "Root cause: $RootCause" -ForegroundColor Gray
}
Write-Host ""
