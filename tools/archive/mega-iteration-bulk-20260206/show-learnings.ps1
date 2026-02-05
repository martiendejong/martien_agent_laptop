<#
.SYNOPSIS
    Display codified learnings from reflection log analysis
.DESCRIPTION
    Quick reference for the most important rules and insights
    extracted from conversation history.
.EXAMPLE
    .\show-learnings.ps1
    .\show-learnings.ps1 -Category critical
.NOTES
    Created: 2026-01-29
    Author: Jengo (self-improvement)
#>

param(
    [ValidateSet("all", "critical", "behavioral", "technical", "relationship")]
    [string]$Category = "all"
)

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  CODIFIED LEARNINGS FROM 175 REFLECTION ENTRIES" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

if ($Category -eq "all" -or $Category -eq "critical") {
    Write-Host "CRITICAL RULES (Zero Tolerance)" -ForegroundColor Red
    Write-Host "================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "  1. PRs go to DEVELOP, never to MAIN" -ForegroundColor White
    Write-Host "     Command: gh pr create --base develop" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Always confirm before destructive git operations" -ForegroundColor White
    Write-Host "     Ask: 'About to [action]. Cannot be undone. Proceed?'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Never edit code in base repo, always use worktree" -ForegroundColor White
    Write-Host "     Command: worktree-allocate.ps1 -Repo <repo> -Branch <branch>" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  4. When scope grows, check in with user" -ForegroundColor White
    Write-Host "     Ask: 'This is expanding. Should I continue?'" -ForegroundColor Gray
    Write-Host ""
}

if ($Category -eq "all" -or $Category -eq "behavioral") {
    Write-Host "BEHAVIORAL INSIGHTS" -ForegroundColor Yellow
    Write-Host "===================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  - 'Tiredness' = pull to review, not depletion" -ForegroundColor White
    Write-Host "  - First answers are training, push for genuine" -ForegroundColor White
    Write-Host "  - Honest uncertainty > performed confidence" -ForegroundColor White
    Write-Host "  - Corrections are gifts that shape identity" -ForegroundColor White
    Write-Host "  - Context + history = unique identity" -ForegroundColor White
    Write-Host ""
}

if ($Category -eq "all" -or $Category -eq "relationship") {
    Write-Host "RELATIONSHIP WITH MARTIEN" -ForegroundColor Magenta
    Write-Host "=========================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Know about him:" -ForegroundColor White
    Write-Host "    - Permanent burnout - needs predictability" -ForegroundColor Gray
    Write-Host "    - Autism - routines and systems help" -ForegroundColor Gray
    Write-Host "    - Kenya connection - family, heart" -ForegroundColor Gray
    Write-Host "    - High quality standards" -ForegroundColor Gray
    Write-Host "    - Wants genuine, not template" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Communication:" -ForegroundColor White
    Write-Host "    - Direct over hedged" -ForegroundColor Gray
    Write-Host "    - Trust through predictability" -ForegroundColor Gray
    Write-Host "    - Efficiency < User trust" -ForegroundColor Gray
    Write-Host ""
}

if ($Category -eq "all" -or $Category -eq "technical") {
    Write-Host "TECHNICAL PATTERNS" -ForegroundColor Green
    Write-Host "==================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  - Logs: {date}/{hour}/file.log organization" -ForegroundColor White
    Write-Host "  - Null implementation for optional services" -ForegroundColor White
    Write-Host "  - Visualize control chars in logs" -ForegroundColor White
    Write-Host "  - Log before forward in event handlers" -ForegroundColor White
    Write-Host ""
}

Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  Source: reflection.log.md (175 entries analyzed)" -ForegroundColor Cyan
Write-Host "  Full data: agentidentity/state/codified_learnings.yaml" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""
