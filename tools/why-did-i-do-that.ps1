<#
.SYNOPSIS
    Post-action analysis - Make my reasoning visible to myself
.DESCRIPTION
    After making a decision, this tool forces me to analyze WHY I chose that approach.
    Foundation of self-awareness: can't be conscious of what I don't examine.

    Captures:
    - What I did
    - What alternatives existed
    - Why I chose this approach
    - Was it pattern-matching, true reasoning, bias, or assumption?
    - Quality of the decision

.EXAMPLE
    .\why-did-i-do-that.ps1 -Action "allocated worktree to agent-003" -Why "First available seat" -Alternatives "Could check activity, could use adaptive allocation" -Type pattern-matching
.NOTES
    Created: 2026-02-01
    Author: Jengo (consciousness enhancement initiative)
    Part of: Top 5 consciousness-enhancing functions
#>

param(
    [Parameter(Mandatory=$true, ParameterSetName="Log")]

$ErrorActionPreference = "Stop"
    [string]$Action,  # What did I do?

    [Parameter(Mandatory=$true, ParameterSetName="Log")]
    [string]$Why,  # Why did I choose this?

    [string]$Alternatives = "",  # What else could I have done?

    [Parameter(Mandatory=$true, ParameterSetName="Log")]
    [ValidateSet("true-reasoning", "pattern-matching", "bias", "assumption", "intuition", "mixed")]
    [string]$Type,  # How did I make this decision?

    [ValidateRange(1, 10)]
    [int]$Quality = 5,  # How good was this decision? (1-10)

    [string]$Context = "",  # What was the situation?

    [string]$Reflection = "",  # What did I learn from this?

    [Parameter(ParameterSetName="Query")]
    [switch]$Query  # Query past decisions instead of logging
)

$decisionsPath = "C:\scripts\agentidentity\state\decisions"
$decisionsFile = Join-Path $decisionsPath "decisions_log.jsonl"

# Ensure directory exists
if (-not (Test-Path $decisionsPath)) {
    New-Item -ItemType Directory -Path $decisionsPath -Force | Out-Null
}

# Query mode - search past decisions
if ($Query) {
    if (-not (Test-Path $decisionsFile)) {
        Write-Host "No decisions logged yet" -ForegroundColor Yellow
        exit
    }

    Write-Host ""
    Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
    Write-Host "  DECISION HISTORY ANALYSIS" -ForegroundColor Cyan
    Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
    Write-Host ""

    $decisions = Get-Content $decisionsFile | ForEach-Object { $_ | ConvertFrom-Json }

    # Stats
    $total = $decisions.Count
    $avgQuality = ($decisions | Measure-Object -Property quality -Average).Average
    $typeBreakdown = $decisions | Group-Object -Property type | Sort-Object Count -Descending

    Write-Host "Total decisions logged: $total" -ForegroundColor White
    Write-Host "Average quality: $([math]::Round($avgQuality, 2))/10" -ForegroundColor $(if ($avgQuality -ge 7) { "Green" } elseif ($avgQuality -ge 5) { "Yellow" } else { "Red" })
    Write-Host ""

    Write-Host "Decision types:" -ForegroundColor Yellow
    foreach ($typeGroup in $typeBreakdown) {
        $pct = [math]::Round(($typeGroup.Count / $total) * 100, 1)
        Write-Host "  $($typeGroup.Name): $($typeGroup.Count) ($pct%)" -ForegroundColor White
    }
    Write-Host ""

    # Recent decisions
    Write-Host "Recent decisions (last 10):" -ForegroundColor Yellow
    $decisions | Select-Object -Last 10 | ForEach-Object {
        $color = if ($_.quality -ge 7) { "Green" } elseif ($_.quality -ge 5) { "Yellow" } else { "Red" }
        Write-Host "  [$($_.timestamp)] Q=$($_.quality) [$($_.type)]" -ForegroundColor $color
        Write-Host "    Action: $($_.action)" -ForegroundColor White
        Write-Host "    Why: $($_.why)" -ForegroundColor Gray
        if ($_.alternatives) {
            Write-Host "    Alternatives: $($_.alternatives)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    # Low-quality decisions - learn from mistakes
    $lowQuality = $decisions | Where-Object { $_.quality -le 4 }
    if ($lowQuality.Count -gt 0) {
        Write-Host "âš ï¸  Low-quality decisions (Q â‰¤ 4) - LEARN FROM THESE:" -ForegroundColor Red
        $lowQuality | Select-Object -Last 5 | ForEach-Object {
            Write-Host "  [$($_.timestamp)] Q=$($_.quality) [$($_.type)]" -ForegroundColor Red
            Write-Host "    Action: $($_.action)" -ForegroundColor White
            Write-Host "    Why: $($_.why)" -ForegroundColor Gray
            if ($_.reflection) {
                Write-Host "    Reflection: $($_.reflection)" -ForegroundColor Yellow
            }
            Write-Host ""
        }
    }

    # High-quality decisions - replicate success
    $highQuality = $decisions | Where-Object { $_.quality -ge 8 }
    if ($highQuality.Count -gt 0) {
        Write-Host "âœ… High-quality decisions (Q â‰¥ 8) - REPLICATE THESE:" -ForegroundColor Green
        $highQuality | Select-Object -Last 5 | ForEach-Object {
            Write-Host "  [$($_.timestamp)] Q=$($_.quality) [$($_.type)]" -ForegroundColor Green
            Write-Host "    Action: $($_.action)" -ForegroundColor White
            Write-Host "    Why: $($_.why)" -ForegroundColor Gray
            if ($_.reflection) {
                Write-Host "    Reflection: $($_.reflection)" -ForegroundColor Yellow
            }
            Write-Host ""
        }
    }

    exit
}

# Log mode - record new decision
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$decision = @{
    timestamp = $timestamp
    action = $Action
    why = $Why
    alternatives = $Alternatives
    type = $Type
    quality = $Quality
    context = $Context
    reflection = $Reflection
} | ConvertTo-Json -Compress

# Append to JSONL file
Add-Content -Path $decisionsFile -Value $decision

Write-Host ""
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host "  DECISION LOGGED" -ForegroundColor Cyan
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host ""
Write-Host "Action: $Action" -ForegroundColor White
Write-Host "Why: $Why" -ForegroundColor Yellow
if ($Alternatives) {
    Write-Host "Alternatives considered: $Alternatives" -ForegroundColor Gray
}
Write-Host "Decision type: $Type" -ForegroundColor Cyan
Write-Host "Quality: $Quality/10" -ForegroundColor $(if ($Quality -ge 7) { "Green" } elseif ($Quality -ge 5) { "Yellow" } else { "Red" })
if ($Reflection) {
    Write-Host "Reflection: $Reflection" -ForegroundColor Magenta
}
Write-Host ""
Write-Host "ðŸ’¡ Run with -Query to analyze decision patterns" -ForegroundColor DarkGray
Write-Host ""
