<#
.SYNOPSIS
    Analyze conversation history to extract learnings
.DESCRIPTION
    Reviews past Claude sessions to find:
    - Repeated tasks (automation opportunities)
    - Errors and corrections (patterns to avoid)
    - User preferences (how Martien likes things)
    - Meta-information (process improvements)
.EXAMPLE
    .\learn-from-history.ps1 -Days 7
    .\learn-from-history.ps1 -Days 30 -Deep
.NOTES
    Created: 2026-01-29
    Author: Jengo (self-improvement)
#>

param(
    [int]$Days = 7,
    [switch]$Deep,
    [string]$SearchTerm = ""
)

$historyPath = "C:\Users\HP\.claude\projects\C--scripts"
$outputPath = "C:\scripts\agentidentity\state\history_learnings.yaml"

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  LEARNING FROM CONVERSATION HISTORY" -ForegroundColor Cyan
Write-Host "  Analyzing last $Days days" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

# Find session files
$cutoffDate = (Get-Date).AddDays(-$Days)
$sessions = Get-ChildItem -Path $historyPath -Filter "*.jsonl" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $cutoffDate } |
    Sort-Object LastWriteTime -Descending

Write-Host "Found $($sessions.Count) sessions in last $Days days" -ForegroundColor Yellow
Write-Host ""

# Pattern containers
$corrections = @()
$repeatedTasks = @{}
$userPreferences = @()
$errorPatterns = @()
$toolUsage = @{}

foreach ($session in $sessions) {
    Write-Host "Analyzing: $($session.Name)..." -ForegroundColor Gray

    try {
        $lines = Get-Content $session.FullName -ErrorAction SilentlyContinue

        foreach ($line in $lines) {
            try {
                $json = $line | ConvertFrom-Json -ErrorAction SilentlyContinue

                if ($json.type -eq "human" -and $json.message) {
                    $msg = $json.message.content
                    if ($msg -is [string]) {
                        # Look for corrections
                        if ($msg -match "niet|wrong|fout|nee|verkeerd|don't|shouldn't") {
                            $corrections += @{
                                Date = $session.LastWriteTime
                                Context = $msg.Substring(0, [Math]::Min(100, $msg.Length))
                            }
                        }

                        # Look for preferences
                        if ($msg -match "ik wil|I want|liever|prefer|always|altijd") {
                            $userPreferences += @{
                                Date = $session.LastWriteTime
                                Preference = $msg.Substring(0, [Math]::Min(150, $msg.Length))
                            }
                        }
                    }
                }

                # Track tool usage
                if ($json.type -eq "assistant" -and $json.message) {
                    $content = $json.message.content | Out-String
                    $toolMatches = [regex]::Matches($content, '\\tools\\([^\\]+\.ps1)')
                    foreach ($match in $toolMatches) {
                        $tool = $match.Groups[1].Value
                        if (-not $toolUsage.ContainsKey($tool)) {
                            $toolUsage[$tool] = 0
                        }
                        $toolUsage[$tool]++
                    }
                }
            } catch {
                # Skip malformed lines
            }
        }
    } catch {
        Write-Host "  Error reading session: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  FINDINGS" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan

# Report corrections
Write-Host ""
Write-Host "CORRECTIONS FOUND: $($corrections.Count)" -ForegroundColor Yellow
if ($corrections.Count -gt 0) {
    $corrections | Select-Object -First 5 | ForEach-Object {
        Write-Host "  [$($_.Date.ToString('MM-dd'))] $($_.Context)..." -ForegroundColor Gray
    }
}

# Report preferences
Write-Host ""
Write-Host "USER PREFERENCES FOUND: $($userPreferences.Count)" -ForegroundColor Yellow
if ($userPreferences.Count -gt 0) {
    $userPreferences | Select-Object -First 5 | ForEach-Object {
        Write-Host "  [$($_.Date.ToString('MM-dd'))] $($_.Preference)..." -ForegroundColor Gray
    }
}

# Report tool usage
Write-Host ""
Write-Host "TOP TOOLS USED:" -ForegroundColor Yellow
$toolUsage.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object {
    Write-Host "  $($_.Key): $($_.Value) times" -ForegroundColor Gray
}

# Save learnings
$learnings = @{
    analyzed_date = (Get-Date -Format "yyyy-MM-dd HH:mm")
    days_analyzed = $Days
    sessions_count = $sessions.Count
    corrections_found = $corrections.Count
    preferences_found = $userPreferences.Count
    top_tools = $toolUsage.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object { @{ tool = $_.Key; count = $_.Value } }
    sample_corrections = $corrections | Select-Object -First 10
    sample_preferences = $userPreferences | Select-Object -First 10
}

$learnings | ConvertTo-Json -Depth 10 | Set-Content $outputPath -Encoding UTF8

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  Learnings saved to: $outputPath" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "RECOMMENDED ACTIONS:" -ForegroundColor Yellow
Write-Host "  1. Review corrections for patterns to add to error_patterns.yaml" -ForegroundColor White
Write-Host "  2. Add preferences to PERSONAL_INSIGHTS.md" -ForegroundColor White
Write-Host "  3. Check if top tools should be further optimized" -ForegroundColor White
Write-Host "  4. Look for repeated tasks that could become skills" -ForegroundColor White
Write-Host ""
