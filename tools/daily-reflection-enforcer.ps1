# daily-reflection-enforcer.ps1
# Enforces 1% rule - cannot end session without logging improvement
# Usage: Call at end of every session (automated via session tracker)

param(
    [switch]$Check,
    [switch]$Log,
    [string]$Improvement = ""
)

$today = Get-Date -Format "yyyy-MM-dd"
$logFile = "C:\scripts\agentidentity\state\daily-improvements.jsonl"

# Ensure file exists
if (-not (Test-Path $logFile)) {
    New-Item -Path $logFile -ItemType File -Force | Out-Null
}

function Test-TodayImprovement {
    if (-not (Test-Path $logFile)) { return $false }

    $entries = Get-Content $logFile | ForEach-Object { $_ | ConvertFrom-Json }
    $todayEntry = $entries | Where-Object { $_.date -eq $today }

    return ($todayEntry -ne $null)
}

function Write-Improvement {
    param($ImprovementText)

    $entry = @{
        date = $today
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        improvement = $ImprovementText
    } | ConvertTo-Json -Compress

    Add-Content -Path $logFile -Value $entry

    # Also log to learning velocity
    if (Test-Path "C:\scripts\tools\learning-velocity-tracker.ps1") {
        & "C:\scripts\tools\learning-velocity-tracker.ps1" -Action Log -EventType "improvement" -Description $ImprovementText
    }

    Write-Host "`n[OK] 1% RULE SATISFIED" -ForegroundColor Green
    Write-Host "     Today's improvement logged: $ImprovementText`n" -ForegroundColor Cyan
}

# Main execution
if ($Check) {
    $hasImprovement = Test-TodayImprovement

    if (-not $hasImprovement) {
        Write-Host "`n[!] 1% RULE VIOLATION" -ForegroundColor Red
        Write-Host "    No improvement logged today ($today)" -ForegroundColor Yellow
        Write-Host "`n    Make ONE small improvement before ending session:" -ForegroundColor Yellow
        Write-Host "      - Delete a dead file" -ForegroundColor Gray
        Write-Host "      - Fix a stale reference" -ForegroundColor Gray
        Write-Host "      - Update a TODO" -ForegroundColor Gray
        Write-Host "      - Clean up duplicate code" -ForegroundColor Gray
        Write-Host "      - Document a pattern" -ForegroundColor Gray
        Write-Host "      - Refactor a function" -ForegroundColor Gray
        Write-Host ""
        Write-Host "    Use: daily-reflection-enforcer.ps1 -Log -Improvement <text>" -ForegroundColor Cyan
        Write-Host ""
        exit 1
    } else {
        Write-Host "`n[OK] 1% RULE SATISFIED" -ForegroundColor Green
        Write-Host "     Improvement already logged today`n" -ForegroundColor Cyan
        exit 0
    }
}

if ($Log) {
    if ([string]::IsNullOrEmpty($Improvement)) {
        Write-Error "Log action requires -Improvement parameter"
        exit 1
    }

    Write-Improvement -ImprovementText $Improvement
    exit 0
}

# Default: same as -Check
& $PSCommandPath -Check
