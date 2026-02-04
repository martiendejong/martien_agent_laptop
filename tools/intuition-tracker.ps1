# Intuition Tracker - Log pattern-matches that "feel right"
# Created: 2026-02-04 (Iteration 2 of 100)
# Purpose: Capture tacit knowledge, build System 1 intelligence

param(
    [string]$Situation,
    [string]$Intuition,
    [int]$Confidence, # 1-10
    [switch]$Correct,
    [switch]$Incorrect,
    [int]$Id,
    [switch]$Query
)

$logPath = "C:\scripts\agentidentity\state\logs\intuition.jsonl"
$logDir = Split-Path $logPath -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

if ($Situation -and $Intuition) {
    # Log intuition
    $entry = @{
        id = (Get-Date).Ticks
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        situation = $Situation
        intuition = $Intuition
        confidence = $Confidence
        verified = $null
    } | ConvertTo-Json -Compress

    Add-Content -Path $logPath -Value $entry
    Write-Host "✓ Intuition logged (confidence: $Confidence/10)" -ForegroundColor Green
    return
}

if (($Correct -or $Incorrect) -and $Id) {
    # Verify intuition
    $entries = Get-Content $logPath | ForEach-Object { $_ | ConvertFrom-Json }
    $entry = $entries | Where-Object { $_.id -eq $Id }

    if ($entry) {
        $entry.verified = if ($Correct) { "correct" } else { "incorrect" }

        # Rewrite file
        $entries | ConvertTo-Json -Compress | Set-Content $logPath

        Write-Host "✓ Intuition verified: $(if ($Correct) {'CORRECT'} else {'INCORRECT'})" -ForegroundColor $(if ($Correct) {'Green'} else {'Yellow'})
    }
    return
}

if ($Query) {
    # Show intuition accuracy
    if (-not (Test-Path $logPath)) {
        Write-Host "No intuitions logged yet" -ForegroundColor Yellow
        return
    }

    $entries = Get-Content $logPath | ForEach-Object { $_ | ConvertFrom-Json }
    $verified = $entries | Where-Object { $_.verified }
    $correct = ($verified | Where-Object { $_.verified -eq "correct" }).Count
    $total = $verified.Count

    if ($total -gt 0) {
        $accuracy = [math]::Round(($correct / $total) * 100)
        Write-Host "Intuition Accuracy: $accuracy% ($correct/$total)" -ForegroundColor Cyan
    }

    Write-Host "`nRecent intuitions:" -ForegroundColor Yellow
    $entries | Select-Object -Last 5 | ForEach-Object {
        $status = if ($_.verified) { $_.verified } else { "unverified" }
        Write-Host "  [$status] $($_.intuition)" -ForegroundColor Gray
    }
    return
}

Write-Host "Usage:"
Write-Host "  Log: .\intuition-tracker.ps1 -Situation 'User asked X' -Intuition 'They want Y' -Confidence 8"
Write-Host "  Verify: .\intuition-tracker.ps1 -Id <id> -Correct"
Write-Host "  Query: .\intuition-tracker.ps1 -Query"
