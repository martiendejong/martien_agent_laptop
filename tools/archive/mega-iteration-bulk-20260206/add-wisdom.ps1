<#
.SYNOPSIS
    Add a wisdom entry to the wisdom journal
.DESCRIPTION
    Distills experience into actionable wisdom and adds to journal.
    Use after significant learnings or insights.
.EXAMPLE
    .\add-wisdom.ps1 -Source "Debugging session" -Experience "Spent hours on wrong problem" -Wisdom "Verify assumptions before deep diving" -Application "Always reproduce issue first"
.NOTES
    Created: 2026-01-29
    Author: Jengo (self-improvement)
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Source,

    [Parameter(Mandatory=$true)]
    [string]$Experience,

    [Parameter(Mandatory=$true)]
    [string]$Wisdom,

    [string]$Application = "",

    [ValidateSet("high", "medium", "low")]
    [string]$Confidence = "medium"
)

$journalPath = "C:\scripts\agentidentity\state\wisdom_journal.yaml"
$today = Get-Date -Format "yyyy-MM-dd"

# Create entry
$entry = @"

  - date: "$today"
    source: "$Source"
    raw_experience: "$Experience"
    distilled_wisdom: "$Wisdom"
    application: "$Application"
    confidence: $Confidence
"@

# Find the entries section and append
$content = Get-Content $journalPath -Raw

# Insert after "entries:" line
$insertPoint = $content.IndexOf("entries:") + "entries:".Length
$newContent = $content.Insert($insertPoint, $entry)

Set-Content -Path $journalPath -Value $newContent -Encoding UTF8

Write-Host ""
Write-Host "Wisdom added to journal" -ForegroundColor Green
Write-Host ""
Write-Host "  Source: $Source" -ForegroundColor Cyan
Write-Host "  Wisdom: $Wisdom" -ForegroundColor Yellow
Write-Host "  Confidence: $Confidence" -ForegroundColor Gray
Write-Host ""
