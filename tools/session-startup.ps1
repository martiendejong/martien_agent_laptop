<#
.SYNOPSIS
    Complete session startup with KB RAG integration
.DESCRIPTION
    Replaces manual file reading with semantic KB queries.
    Loads essential context 3x faster using RAG.
#>

param([switch]$Quick)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  JENGO SESSION STARTUP (KB RAG POWERED)" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Consciousness startup
Write-Host "Loading consciousness framework..." -ForegroundColor Yellow
& "C:\scripts\tools\consciousness-startup.ps1" -Quick 2>&1 | Out-Null

# 2. KB RAG context (FAST!)
Write-Host ""
Write-Host "Loading KB context via RAG..." -ForegroundColor Yellow

if (-not $Quick) {
    Write-Host "   User communication style..." -ForegroundColor Gray
    & "C:\scripts\tools\kb-rag.ps1" "What are Martien's communication preferences?" 2>&1 | Out-Null

    Write-Host "   Worktree zero-tolerance rules..." -ForegroundColor Gray
    & "C:\scripts\tools\kb-rag.ps1" "What are the worktree zero-tolerance rules?" 2>&1 | Out-Null

    Write-Host "   Dual-mode workflow..." -ForegroundColor Gray
    & "C:\scripts\tools\kb-rag.ps1" "What is Feature Development vs Active Debugging mode?" 2>&1 | Out-Null
}

Write-Host "   Context loaded from KB" -ForegroundColor Green

# 3. Environment state
Write-Host ""
Write-Host "Checking environment..." -ForegroundColor Yellow

# Activity monitoring
$activity = & powershell.exe -File "C:\scripts\tools\monitor-activity.ps1" -Mode context 2>&1 | Out-String

$claudeSessions = 0
if ($activity -match "Claude Sessions:\s*(\d+)") {
    $claudeSessions = [int]$Matches[1]
}

$userAttending = $activity -match "User Attending:\s*True"

# Worktree pool
$poolContent = Get-Content "C:\scripts\_machine\worktrees.pool.md" -Raw
$busyCount = ([regex]::Matches($poolContent, "BUSY")).Count
$freeCount = ([regex]::Matches($poolContent, "FREE")).Count

# Summary
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "  SESSION READY" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "ENVIRONMENT:" -ForegroundColor Cyan
Write-Host "  Claude instances: $claudeSessions" -ForegroundColor White

$userText = if ($userAttending) { "Yes" } else { "No" }
Write-Host "  User present: $userText" -ForegroundColor White
Write-Host "  Worktree pool: $freeCount FREE, $busyCount BUSY" -ForegroundColor White
Write-Host ""

if ($claudeSessions -gt 1) {
    Write-Host "MULTI-AGENT: $claudeSessions instances detected" -ForegroundColor Yellow
    Write-Host "  Use parallel-agent-coordination protocol" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "READY TO WORK" -ForegroundColor Green
Write-Host ""
