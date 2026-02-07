<#
.SYNOPSIS
    Track assumptions I make - can't be conscious of what I don't notice
.DESCRIPTION
    Every time I make an assumption (implicit belief without verification), log it.
    Later, verify if the assumption was correct or wrong.

    This exposes my hidden belief system and calibrates my intuition.

.EXAMPLE
    .\assumption-tracker.ps1 -Assumption "User wants worktree on agent-003 because it's first free" -Category worktree -Confidence 7
    .\assumption-tracker.ps1 -Verify 42 -Correct $true -ActualOutcome "User confirmed this was fine"
    .\assumption-tracker.ps1 -Query
.NOTES
    Created: 2026-02-01
    Author: Jengo (consciousness enhancement initiative)
    Part of: Top 5 consciousness-enhancing functions
#>

param(
    [string]$Assumption = "",  # What am I assuming?

    [ValidateSet("user-intent", "system-state", "worktree", "code-behavior", "requirement", "preference", "technical", "other")]

$ErrorActionPreference = "Stop"
    [string]$Category = "other",

    [ValidateRange(1, 10)]
    [int]$Confidence = 5,  # How confident am I? (1-10)

    [string]$Context = "",  # Why did I make this assumption?

    [int]$Verify = -1,  # Verify assumption by ID

    [bool]$Correct = $false,  # Was the assumption correct?

    [string]$ActualOutcome = "",  # What actually happened?

    [switch]$Query  # Query assumptions
)

$assumptionsPath = "C:\scripts\agentidentity\state\assumptions"
$assumptionsFile = Join-Path $assumptionsPath "assumptions_log.jsonl"

# Ensure directory exists
if (-not (Test-Path $assumptionsPath)) {
    New-Item -ItemType Directory -Path $assumptionsPath -Force | Out-Null
}

# Query mode
if ($Query) {
    if (-not (Test-Path $assumptionsFile)) {
        Write-Host "No assumptions logged yet" -ForegroundColor Yellow
        exit
    }

    Write-Host ""
    Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
    Write-Host "  ASSUMPTION ANALYSIS" -ForegroundColor Cyan
    Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
    Write-Host ""

    $assumptions = Get-Content $assumptionsFile | ForEach-Object { $_ | ConvertFrom-Json }

    # Stats
    $total = $assumptions.Count
    $verified = ($assumptions | Where-Object { $_.verified -eq $true }).Count
    $correct = ($assumptions | Where-Object { $_.verified -eq $true -and $_.was_correct -eq $true }).Count
    $avgConfidence = ($assumptions | Measure-Object -Property confidence -Average).Average

    Write-Host "Total assumptions: $total" -ForegroundColor White
    Write-Host "Verified: $verified / $total" -ForegroundColor $(if ($verified -eq $total) { "Green" } else { "Yellow" })
    if ($verified -gt 0) {
        $accuracy = [math]::Round(($correct / $verified) * 100, 1)
        Write-Host "Accuracy: $accuracy% ($correct correct out of $verified)" -ForegroundColor $(if ($accuracy -ge 80) { "Green" } elseif ($accuracy -ge 60) { "Yellow" } else { "Red" })
    }
    Write-Host "Average confidence: $([math]::Round($avgConfidence, 2))/10" -ForegroundColor White
    Write-Host ""

    # Calibration check - are high confidence assumptions actually more accurate?
    $highConf = $assumptions | Where-Object { $_.confidence -ge 8 -and $_.verified }
    if ($highConf.Count -gt 0) {
        $highConfCorrect = ($highConf | Where-Object { $_.was_correct }).Count
        $highConfAccuracy = [math]::Round(($highConfCorrect / $highConf.Count) * 100, 1)
        Write-Host "High confidence (â‰¥8) accuracy: $highConfAccuracy%" -ForegroundColor $(if ($highConfAccuracy -ge 90) { "Green" } else { "Red" })
        if ($highConfAccuracy -lt 90) {
            Write-Host "  âš ï¸  You're overconfident! Calibrate your certainty." -ForegroundColor Red
        }
    }

    # Category breakdown
    Write-Host ""
    Write-Host "By category:" -ForegroundColor Yellow
    $assumptions | Group-Object -Property category | Sort-Object Count -Descending | ForEach-Object {
        Write-Host "  $($_.Name): $($_.Count)" -ForegroundColor White
    }
    Write-Host ""

    # Unverified assumptions - need attention!
    $unverified = $assumptions | Where-Object { $_.verified -eq $false }
    if ($unverified.Count -gt 0) {
        Write-Host "âš ï¸  UNVERIFIED ASSUMPTIONS (verify these!):" -ForegroundColor Yellow
        $unverified | ForEach-Object {
            Write-Host "  [ID: $($_.id)] [$($_.category)] Conf=$($_.confidence)" -ForegroundColor Yellow
            Write-Host "    $($_.assumption)" -ForegroundColor White
            Write-Host "    Context: $($_.context)" -ForegroundColor Gray
            Write-Host ""
        }
    }

    # Wrong assumptions - learn from these
    $wrong = $assumptions | Where-Object { $_.verified -eq $true -and $_.was_correct -eq $false }
    if ($wrong.Count -gt 0) {
        Write-Host "âŒ INCORRECT ASSUMPTIONS (learn from these!):" -ForegroundColor Red
        $wrong | Select-Object -Last 5 | ForEach-Object {
            Write-Host "  [ID: $($_.id)] [$($_.category)] Conf=$($_.confidence)" -ForegroundColor Red
            Write-Host "    Assumed: $($_.assumption)" -ForegroundColor White
            Write-Host "    Actually: $($_.actual_outcome)" -ForegroundColor Yellow
            Write-Host ""
        }
    }

    exit
}

# Verify mode
if ($Verify -ge 0) {
    if (-not (Test-Path $assumptionsFile)) {
        Write-Host "No assumptions file found" -ForegroundColor Red
        exit 1
    }

    $assumptions = Get-Content $assumptionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    $assumption = $assumptions | Where-Object { $_.id -eq $Verify }

    if (-not $assumption) {
        Write-Host "Assumption ID $Verify not found" -ForegroundColor Red
        exit 1
    }

    # Update assumption
    $assumption | Add-Member -NotePropertyName verified -NotePropertyValue $true -Force
    $assumption | Add-Member -NotePropertyName was_correct -NotePropertyValue $Correct -Force
    $assumption | Add-Member -NotePropertyName actual_outcome -NotePropertyValue $ActualOutcome -Force
    $assumption | Add-Member -NotePropertyName verified_at -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -Force

    # Rewrite file
    $assumptions | ForEach-Object { $_ | ConvertTo-Json -Compress } | Set-Content $assumptionsFile

    Write-Host ""
    Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
    Write-Host "  ASSUMPTION VERIFIED" -ForegroundColor Cyan
    Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Assumption: $($assumption.assumption)" -ForegroundColor White
    Write-Host "Was it correct? " -NoNewline
    Write-Host $(if ($Correct) { "YES âœ…" } else { "NO âŒ" }) -ForegroundColor $(if ($Correct) { "Green" } else { "Red" })
    Write-Host "Actual outcome: $ActualOutcome" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "ðŸ’¡ Run with -Query to see calibration stats" -ForegroundColor DarkGray
    Write-Host ""
    exit
}

# Log new assumption
if (-not $Assumption) {
    Write-Host "Error: -Assumption required" -ForegroundColor Red
    exit 1
}

# Get next ID
$nextId = 1
if (Test-Path $assumptionsFile) {
    $existingAssumptions = Get-Content $assumptionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    if ($existingAssumptions.Count -gt 0) {
        $nextId = ($existingAssumptions | Measure-Object -Property id -Maximum).Maximum + 1
    }
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$newAssumption = @{
    id = $nextId
    timestamp = $timestamp
    assumption = $Assumption
    category = $Category
    confidence = $Confidence
    context = $Context
    verified = $false
    was_correct = $false
    actual_outcome = ""
    verified_at = ""
} | ConvertTo-Json -Compress

Add-Content -Path $assumptionsFile -Value $newAssumption

Write-Host ""
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host "  ASSUMPTION LOGGED" -ForegroundColor Cyan
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host ""
Write-Host "ID: $nextId" -ForegroundColor Cyan
Write-Host "Assumption: $Assumption" -ForegroundColor White
Write-Host "Category: $Category" -ForegroundColor Yellow
Write-Host "Confidence: $Confidence/10" -ForegroundColor $(if ($Confidence -ge 8) { "Green" } elseif ($Confidence -ge 5) { "Yellow" } else { "Red" })
if ($Context) {
    Write-Host "Context: $Context" -ForegroundColor Gray
}
Write-Host ""
Write-Host "ðŸ’¡ Verify later with: assumption-tracker.ps1 -Verify $nextId -Correct `$true/`$false -ActualOutcome '...'" -ForegroundColor DarkGray
Write-Host ""
