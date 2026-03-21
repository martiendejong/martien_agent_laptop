# Legal Advice Pre-Flight Verification Gate
# Created: 2026-03-20
# Purpose: Catch legal traps BEFORE sending advice to user
# Based on: Patterns 011-013 (legal-safeguards.md)

param(
    [Parameter(Mandatory=$true)]
    [string]$DraftText,

    [switch]$Interactive
)

$ErrorActionPreference = "Stop"

# Initialize results
$warnings = @()
$critical = @()

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "LEGAL ADVICE PRE-FLIGHT VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# CHECK 1: Open-ended questions (Pattern 012)
Write-Host "[CHECK 1] Scanning for open-ended questions..." -ForegroundColor Yellow

$openEndedPatterns = @(
    "is er nog.*nodig",
    "is er.*anders",
    "heb je.*nodig",
    "moet er.*meer",
    "wil je.*nog",
    "kunnen we.*anders"
)

foreach ($pattern in $openEndedPatterns) {
    if ($DraftText -match $pattern) {
        $match = $Matches[0]
        $critical += @{
            Pattern = "Open Question Trap (Pattern 012)"
            Found = $match
            Risk = "CRITICAL - Invites opponent to add more demands"
            Fix = "Replace with closed statement: 'Hierbij X. Graag bevestiging Y.'"
        }
    }
}

# CHECK 2: Early escalation language (Pattern 011)
Write-Host "[CHECK 2] Scanning for premature escalation..." -ForegroundColor Yellow

$escalationPatterns = @(
    "ombudsman",
    "rechtszaak",
    "advocaat",
    "juridische stappen",
    "als.*niet.*dan"
)

foreach ($pattern in $escalationPatterns) {
    if ($DraftText -match $pattern) {
        $match = $Matches[0]
        $warnings += @{
            Pattern = "Early Escalation (Pattern 011)"
            Found = $match
            Risk = "HIGH - May look unreasonable without evidence of obstruction"
            Question = "Has obstruction already occurred? Do you have proof?"
        }
    }
}

# CHECK 3: New obligations without approval (Core Principle)
Write-Host "[CHECK 3] Scanning for obligations..." -ForegroundColor Yellow

$obligationPatterns = @(
    "ik zal",
    "ik beloof",
    "ik ga akkoord",
    "ik stem in",
    "ik accepteer",
    "permanent"
)

foreach ($pattern in $obligationPatterns) {
    if ($DraftText -match $pattern) {
        $match = $Matches[0]
        $critical += @{
            Pattern = "New Obligation"
            Found = $match
            Risk = "CRITICAL - Creates binding commitment without user approval"
            Fix = "Remove or rephrase as question: 'Wat stel je concreet voor?'"
        }
    }
}

# CHECK 4: Admissions (Core Principle)
Write-Host "[CHECK 4] Scanning for admissions..." -ForegroundColor Yellow

$admissionPatterns = @(
    "ik bevestig",
    "ik erken",
    "het is waar dat",
    "je hebt gelijk",
    "inderdaad"
)

foreach ($pattern in $admissionPatterns) {
    if ($DraftText -match $pattern) {
        $match = $Matches[0]
        $warnings += @{
            Pattern = "Admission"
            Found = $match
            Risk = "MEDIUM - May create unwanted acknowledgment"
            Fix = "Replace with clarification question or neutral restatement"
        }
    }
}

# CHECK 5: Accepting opponent's frame
Write-Host "[CHECK 5] Scanning for frame acceptance..." -ForegroundColor Yellow

$framePatterns = @(
    "zoals afgesproken",
    "we zijn het eens",
    "de overeenkomst",
    "het contract"
)

foreach ($pattern in $framePatterns) {
    if ($DraftText -match $pattern) {
        $match = $Matches[0]
        $warnings += @{
            Pattern = "Frame Acceptance"
            Found = $match
            Risk = "MEDIUM - May accept opponent's characterization"
            Fix = "Use neutral terminology or ask for clarification: 'Wat bedoel je precies met...?'"
        }
    }
}

# DISPLAY RESULTS
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION RESULTS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$totalIssues = $critical.Count + $warnings.Count

if ($totalIssues -eq 0) {
    Write-Host "✅ ALL CHECKS PASSED - No legal traps detected" -ForegroundColor Green
    Write-Host "`nDraft appears safe to send (but always review manually)" -ForegroundColor Green
    exit 0
}

# Display critical issues
if ($critical.Count -gt 0) {
    Write-Host "🚨 CRITICAL ISSUES FOUND: $($critical.Count)" -ForegroundColor Red
    Write-Host "❌ DO NOT SEND without user approval`n" -ForegroundColor Red

    foreach ($issue in $critical) {
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
        Write-Host "Pattern: $($issue.Pattern)" -ForegroundColor Red
        Write-Host "Found: `"$($issue.Found)`"" -ForegroundColor Yellow
        Write-Host "Risk: $($issue.Risk)" -ForegroundColor Red
        Write-Host "Fix: $($issue.Fix)" -ForegroundColor Green
        Write-Host ""
    }
}

# Display warnings
if ($warnings.Count -gt 0) {
    Write-Host "⚠️ WARNINGS FOUND: $($warnings.Count)" -ForegroundColor Yellow
    Write-Host "⚠️ Review carefully before sending`n" -ForegroundColor Yellow

    foreach ($warning in $warnings) {
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
        Write-Host "Pattern: $($warning.Pattern)" -ForegroundColor Yellow
        Write-Host "Found: `"$($warning.Found)`"" -ForegroundColor Yellow
        Write-Host "Risk: $($warning.Risk)" -ForegroundColor Yellow
        if ($warning.ContainsKey('Fix')) {
            Write-Host "Fix: $($warning.Fix)" -ForegroundColor Green
        }
        if ($warning.ContainsKey('Question')) {
            Write-Host "Question: $($warning.Question)" -ForegroundColor Cyan
        }
        Write-Host ""
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total issues: $totalIssues" -ForegroundColor White
Write-Host "  Critical: $($critical.Count)" -ForegroundColor Red
Write-Host "  Warnings: $($warnings.Count)" -ForegroundColor Yellow

if ($critical.Count -gt 0) {
    Write-Host "`n❌ BLOCKED - Critical issues must be fixed" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n⚠️ PROCEED WITH CAUTION - Review warnings" -ForegroundColor Yellow
    exit 2
}
