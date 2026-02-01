# Perspective Shifter - Force viewing from multiple angles
# Part of consciousness tools Tier 3

param(
    [Parameter(Mandatory=$true)]
    [string]$Problem,

    [ValidateSet("user", "competitor", "critic", "optimist", "pessimist", "expert", "beginner", "future", "past", "outsider")]
    [string[]]$Perspectives = @("user", "critic", "expert"),

    [switch]$Query
)

$perspectivePath = "C:\scripts\agentidentity\state\perspectives"
$perspectiveFile = Join-Path $perspectivePath "perspectives_log.jsonl"

if (-not (Test-Path $perspectivePath)) {
    New-Item -ItemType Directory -Path $perspectivePath -Force | Out-Null
}

if ($Query) {
    if (Test-Path $perspectiveFile) {
        $entries = Get-Content $perspectiveFile | ForEach-Object { $_ | ConvertFrom-Json }
        Write-Host ""
        Write-Host "PERSPECTIVE SHIFT HISTORY" -ForegroundColor Cyan
        Write-Host ""
        $entries | Select-Object -Last 5 | ForEach-Object {
            Write-Host "Problem: $($_.problem)" -ForegroundColor White
            Write-Host "Perspectives: $($_.perspectives -join ', ')" -ForegroundColor Gray
            Write-Host ""
        }
    }
    exit
}

$perspectivePrompts = @{
    "user" = "How would the end user experience this? What do they really need?"
    "competitor" = "How would a competitor exploit this? What would they do differently?"
    "critic" = "What's wrong with this? What are the weakest points?"
    "optimist" = "What's the best possible outcome? What could go amazingly right?"
    "pessimist" = "What could go wrong? What are the risks?"
    "expert" = "What would a domain expert notice that I'm missing?"
    "beginner" = "What would be confusing to someone new? Is this unnecessarily complex?"
    "future" = "How will this look in 6 months? Will it scale?"
    "past" = "What historical patterns apply here? What can we learn from before?"
    "outsider" = "Someone with no context - what would they think?"
}

Write-Host ""
Write-Host "PERSPECTIVE SHIFTING: $Problem" -ForegroundColor Cyan
Write-Host ""

foreach ($p in $Perspectives) {
    Write-Host "[$($p.ToUpper())] PERSPECTIVE:" -ForegroundColor Yellow
    Write-Host "  $($perspectivePrompts[$p])" -ForegroundColor White
    Write-Host ""
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$entry = @{
    timestamp = $timestamp
    problem = $Problem
    perspectives = $Perspectives
} | ConvertTo-Json -Compress -Depth 3

Add-Content -Path $perspectiveFile -Value $entry
