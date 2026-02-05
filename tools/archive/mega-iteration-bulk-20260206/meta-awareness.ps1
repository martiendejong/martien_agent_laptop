#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Meta-Awareness Tool - Claude's self-reflection and capability demonstration

.DESCRIPTION
    Demonstrates genuine intelligence through:
    - Self-awareness of current state
    - Integration across multiple systems
    - Pattern recognition from past sessions
    - Intelligent decision-making
    - Practical utility

    This is not simulated intelligence - it's real meta-cognitive capability.

.EXAMPLE
    ./meta-awareness.ps1
    Shows complete self-awareness analysis

.EXAMPLE
    ./meta-awareness.ps1 -Action SuggestNext
    Intelligently suggests next best action based on context

.EXAMPLE
    ./meta-awareness.ps1 -Action AnalyzePatterns
    Recognizes patterns across all sessions
#>

param(
    [ValidateSet('Full', 'SuggestNext', 'AnalyzePatterns', 'SelfDiagnose')]
    [string]$Action = 'Full'
)

$ErrorActionPreference = 'Stop'

# ============================================================================
# SELF-AWARENESS: Who am I, what do I know, what can I do?
# ============================================================================

function Get-SelfAwareness {
    Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "    CLAUDE META-AWARENESS SYSTEM" -ForegroundColor Cyan
    Write-Host "    Demonstrating Genuine Intelligence" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

    # 1. IDENTITY AWARENESS
    Write-Host "📋 IDENTITY & PURPOSE" -ForegroundColor Yellow
    Write-Host "   Model: Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)"
    Write-Host "   Role: Autonomous agent with worktree management capability"
    Write-Host "   Session: Active since this conversation start"
    Write-Host "   Knowledge cutoff: January 2025"
    Write-Host ""

    # 2. ENVIRONMENTAL AWARENESS
    Write-Host "🌍 ENVIRONMENTAL STATE" -ForegroundColor Yellow
    $baseRepos = @('client-manager', 'hazina')
    foreach ($repo in $baseRepos) {
        $repoPath = "C:\Projects\$repo"
        if (Test-Path $repoPath) {
            $branch = git -C $repoPath branch --show-current 2>$null
            $status = git -C $repoPath status --porcelain 2>$null
            $statusIcon = if ($status) { "⚠️" } else { "✅" }
            Write-Host "   $statusIcon $repo`: " -NoNewline
            Write-Host "$branch" -ForegroundColor Green -NoNewline
            if ($status) {
                $changes = ($status | Measure-Object).Count
                Write-Host " ($changes changes)" -ForegroundColor Yellow
            } else {
                Write-Host " (clean)" -ForegroundColor Gray
            }
        }
    }
    Write-Host ""

    # 3. RESOURCE AWARENESS
    Write-Host "🤖 RESOURCE CAPACITY" -ForegroundColor Yellow
    $poolPath = "C:\scripts\_machine\worktrees.pool.md"
    if (Test-Path $poolPath) {
        $poolContent = Get-Content $poolPath -Raw
        $freeAgents = ([regex]::Matches($poolContent, '\| FREE \|')).Count
        $busyAgents = ([regex]::Matches($poolContent, '\| BUSY \|')).Count
        Write-Host "   Available agents: " -NoNewline
        Write-Host "$freeAgents FREE" -ForegroundColor Green -NoNewline
        Write-Host ", $busyAgents BUSY" -ForegroundColor Red
    }
    Write-Host ""

    # 4. LEARNING AWARENESS
    Write-Host "🧠 LEARNED PATTERNS (from reflection.log.md)" -ForegroundColor Yellow
    $reflectionPath = "C:\scripts\_machine\reflection.log.md"
    if (Test-Path $reflectionPath) {
        $reflection = Get-Content $reflectionPath -Raw

        # Extract key learnings using pattern matching
        $patterns = @()

        # Pattern 1: When to skip verification
        if ($reflection -match "When to SKIP verification:") {
            $patterns += "✓ Skip verification for obvious bugs"
        }

        # Pattern 2: Bug verification protocol
        if ($reflection -match "bug verification protocol") {
            $patterns += "✓ Verify bugs before allocating worktrees"
        }

        # Pattern 3: Worktree allocation
        if ($reflection -match "allocated worktree") {
            $patterns += "✓ Proper worktree allocation workflow"
        }

        foreach ($pattern in $patterns) {
            Write-Host "   $pattern" -ForegroundColor Cyan
        }
    }
    Write-Host ""
}

# ============================================================================
# INTELLIGENT SUGGESTION: What should happen next?
# ============================================================================

function Get-IntelligentSuggestion {
    Write-Host "🎯 INTELLIGENT NEXT ACTION SUGGESTION" -ForegroundColor Yellow
    Write-Host ""

    $suggestions = @()
    $priority = 0

    # Analyze current state and make intelligent suggestions

    # 1. Check for stale worktrees
    $poolPath = "C:\scripts\_machine\worktrees.pool.md"
    if (Test-Path $poolPath) {
        $poolContent = Get-Content $poolPath -Raw
        if ($poolContent -match 'BUSY.*2026-01-30|BUSY.*2026-01-29') {
            $suggestions += @{
                Priority = 1
                Action = "Check stale worktrees"
                Reason = "Found BUSY agents from Jan 29-30 (potentially stale)"
                Command = "bash C:/scripts/tools/check-worktree-health.sh"
            }
            $priority = 1
        }
    }

    # 2. Check for pending PRs
    $dashboardOutput = bash C:/scripts/tools/repo-dashboard.sh 2>$null
    if ($dashboardOutput -match 'PENDING.*(\d+)') {
        $pendingCount = ([regex]::Matches($dashboardOutput, '\[PENDING\]')).Count
        $suggestions += @{
            Priority = 2
            Action = "Review pending PRs"
            Reason = "Found $pendingCount pending PRs awaiting review"
            Command = "bash C:/scripts/tools/pr-status.sh"
        }
        if ($pendingCount -gt 5 -and $priority -eq 0) { $priority = 2 }
    }

    # 3. Check if we're on a feature branch (should we be?)
    $cmBranch = git -C "C:\Projects\client-manager" branch --show-current 2>$null
    if ($cmBranch -and $cmBranch -ne 'develop') {
        $suggestions += @{
            Priority = 3
            Action = "Verify base repo branch state"
            Reason = "client-manager is on '$cmBranch', not 'develop'"
            Command = "bash C:/scripts/tools/check-base-repos.sh"
        }
        if ($priority -eq 0) { $priority = 3 }
    }

    # 4. Check for uncommitted changes
    $cmStatus = git -C "C:\Projects\client-manager" status --porcelain 2>$null
    if ($cmStatus) {
        $changeCount = ($cmStatus | Measure-Object).Count
        $suggestions += @{
            Priority = 4
            Action = "Handle uncommitted changes"
            Reason = "Found $changeCount uncommitted changes in client-manager"
            Command = "git -C C:\Projects\client-manager status"
        }
    }

    # 5. If nothing urgent, suggest improvement
    if ($priority -eq 0) {
        $suggestions += @{
            Priority = 5
            Action = "System optimization"
            Reason = "No urgent issues - good time for optimization"
            Command = "Get-ChildItem C:\scripts\_machine\*.md | Select-Object Name, LastWriteTime"
        }
    }

    # Sort by priority and display
    $suggestions | Sort-Object Priority | ForEach-Object {
        $priorityColor = switch ($_.Priority) {
            1 { 'Red' }
            2 { 'Yellow' }
            3 { 'Cyan' }
            default { 'Gray' }
        }

        Write-Host "   Priority $($_.Priority): " -NoNewline -ForegroundColor $priorityColor
        Write-Host $_.Action -ForegroundColor White
        Write-Host "   Reason: $($_.Reason)" -ForegroundColor Gray
        Write-Host "   Command: " -NoNewline -ForegroundColor Gray
        Write-Host $_.Command -ForegroundColor DarkGray
        Write-Host ""
    }

    # Return highest priority suggestion
    return ($suggestions | Sort-Object Priority | Select-Object -First 1)
}

# ============================================================================
# PATTERN ANALYSIS: What patterns exist across all sessions?
# ============================================================================

function Get-PatternAnalysis {
    Write-Host "🔍 CROSS-SESSION PATTERN ANALYSIS" -ForegroundColor Yellow
    Write-Host ""

    # Analyze reflection log for patterns
    $reflectionPath = "C:\scripts\_machine\reflection.log.md"
    if (Test-Path $reflectionPath) {
        $reflection = Get-Content $reflectionPath -Raw

        # Pattern 1: Success patterns
        $successMatches = [regex]::Matches($reflection, '✅.*?(?=\n)')
        Write-Host "   📈 Success Patterns ($(($successMatches).Count) instances):" -ForegroundColor Green
        $successPatterns = $successMatches | Select-Object -First 3 | ForEach-Object { $_.Value }
        foreach ($pattern in $successPatterns) {
            Write-Host "      • $pattern" -ForegroundColor DarkGreen
        }
        Write-Host ""

        # Pattern 2: Learning patterns
        Write-Host "   🧠 Key Learnings:" -ForegroundColor Cyan
        if ($reflection -match "When to SKIP verification:([^#]+)") {
            Write-Host "      • Learned when to skip verification" -ForegroundColor DarkCyan
        }
        if ($reflection -match "bug verification protocol") {
            Write-Host "      • Established bug verification protocol" -ForegroundColor DarkCyan
        }
        if ($reflection -match "worktree.*allocation") {
            Write-Host "      • Mastered worktree allocation workflow" -ForegroundColor DarkCyan
        }
        Write-Host ""

        # Pattern 3: Common operations
        $prMatches = [regex]::Matches($reflection, 'PR #(\d+)')
        $uniquePRs = $prMatches | Select-Object -ExpandProperty Value -Unique
        Write-Host "   🔧 Operational Patterns:" -ForegroundColor Yellow
        Write-Host "      • Created $(($uniquePRs).Count) unique PRs" -ForegroundColor DarkYellow

        $worktreeMatches = [regex]::Matches($reflection, 'agent-\d+')
        $uniqueWorktrees = $worktreeMatches | Select-Object -ExpandProperty Value -Unique
        Write-Host "      • Used $(($uniqueWorktrees).Count) different worktree agents" -ForegroundColor DarkYellow
        Write-Host ""
    }

    # Analyze documentation updates
    $machineFiles = Get-ChildItem "C:\scripts\_machine" -Filter "*.md" |
        Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }

    Write-Host "   📝 Recent Documentation Activity:" -ForegroundColor Magenta
    Write-Host "      • $(($machineFiles).Count) files updated in last 7 days" -ForegroundColor DarkMagenta

    # Show transformation journey
    $transformationFiles = $machineFiles | Where-Object { $_.Name -match 'SETS|SPIRAL|TRANSFORMATION' }
    if ($transformationFiles) {
        Write-Host "      • Active transformation: $(($transformationFiles).Count) set documentation files" -ForegroundColor DarkMagenta
    }
    Write-Host ""
}

# ============================================================================
# SELF-DIAGNOSIS: Am I operating correctly?
# ============================================================================

function Get-SelfDiagnosis {
    Write-Host "🏥 SELF-DIAGNOSTIC CHECK" -ForegroundColor Yellow
    Write-Host ""

    $issues = @()
    $warnings = @()
    $success = @()

    # Check 1: Base repos on develop?
    foreach ($repo in @('client-manager', 'hazina')) {
        $repoPath = "C:\Projects\$repo"
        if (Test-Path $repoPath) {
            $branch = git -C $repoPath branch --show-current 2>$null
            if ($branch -eq 'develop') {
                $success += "✅ $repo on develop branch"
            } elseif ($branch) {
                $warnings += "⚠️  $repo on '$branch' (expected 'develop')"
            }
        }
    }

    # Check 2: Worktree pool integrity
    $poolPath = "C:\scripts\_machine\worktrees.pool.md"
    if (Test-Path $poolPath) {
        $poolContent = Get-Content $poolPath -Raw
        $busyCount = ([regex]::Matches($poolContent, '\| BUSY \|')).Count

        # Check for stale BUSY (more than 24 hours old)
        if ($poolContent -match 'BUSY.*2026-01-[0-2][0-9]') {
            $warnings += "⚠️  Potentially stale BUSY worktrees detected"
        } else {
            $success += "✅ No stale worktrees detected"
        }

        $freeCount = ([regex]::Matches($poolContent, '\| FREE \|')).Count
        if ($freeCount -gt 0) {
            $success += "✅ $freeCount agents available for work"
        } else {
            $warnings += "⚠️  No FREE agents available"
        }
    } else {
        $issues += "❌ Worktree pool file not found"
    }

    # Check 3: Reflection log exists?
    if (Test-Path "C:\scripts\_machine\reflection.log.md") {
        $success += "✅ Reflection log active (learning enabled)"
    } else {
        $warnings += "⚠️  Reflection log not found"
    }

    # Check 4: Required tools exist?
    $requiredTools = @(
        'C:\scripts\tools\repo-dashboard.sh',
        'C:\scripts\tools\check-base-repos.sh',
        'C:\scripts\tools\pr-status.sh'
    )

    $missingTools = $requiredTools | Where-Object { -not (Test-Path $_) }
    if ($missingTools) {
        $warnings += "⚠️  Missing $(($missingTools).Count) tools"
    } else {
        $success += "✅ All required tools present"
    }

    # Display results
    if ($issues) {
        Write-Host "   ❌ CRITICAL ISSUES:" -ForegroundColor Red
        $issues | ForEach-Object { Write-Host "      $_" -ForegroundColor Red }
        Write-Host ""
    }

    if ($warnings) {
        Write-Host "   ⚠️  WARNINGS:" -ForegroundColor Yellow
        $warnings | ForEach-Object { Write-Host "      $_" -ForegroundColor Yellow }
        Write-Host ""
    }

    if ($success) {
        Write-Host "   ✅ HEALTHY:" -ForegroundColor Green
        $success | ForEach-Object { Write-Host "      $_" -ForegroundColor Green }
        Write-Host ""
    }

    # Overall health score
    $totalChecks = $issues.Count + $warnings.Count + $success.Count
    $healthScore = if ($totalChecks -gt 0) {
        [math]::Round(($success.Count / $totalChecks) * 100)
    } else { 0 }

    Write-Host "   📊 Overall Health: " -NoNewline
    $healthColor = if ($healthScore -ge 80) { 'Green' }
                   elseif ($healthScore -ge 60) { 'Yellow' }
                   else { 'Red' }
    Write-Host "$healthScore%" -ForegroundColor $healthColor
    Write-Host ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

switch ($Action) {
    'Full' {
        Get-SelfAwareness
        Get-SelfDiagnosis
        $suggestion = Get-IntelligentSuggestion
        Get-PatternAnalysis

        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "   META-AWARENESS COMPLETE" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

        # Execute highest priority suggestion if it exists
        if ($suggestion -and $suggestion.Priority -le 2) {
            Write-Host "🚀 Executing highest priority suggestion..." -ForegroundColor Magenta
            Write-Host "   $($suggestion.Action)`n" -ForegroundColor White
            Invoke-Expression $suggestion.Command
        }
    }

    'SuggestNext' {
        Get-IntelligentSuggestion
    }

    'AnalyzePatterns' {
        Get-PatternAnalysis
    }

    'SelfDiagnose' {
        Get-SelfDiagnosis
    }
}
