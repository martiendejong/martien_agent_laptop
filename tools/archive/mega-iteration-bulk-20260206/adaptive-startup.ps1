# Adaptive Startup Protocol
# Purpose: Generate context-specific startup checklist to reduce cognitive load
# Created: 2026-02-05 (Round 11: Cognitive Load Optimization)

param(
    [string]$Context = "auto-detect",  # debugging, feature-development, research, administration, auto-detect
    [switch]$UserPresent,
    [string]$ExpertiseLevel = "auto-detect",  # first-time, learning, experienced, expert, auto-detect
    [switch]$FirstSessionEver,
    [switch]$EndOfSession,
    [switch]$ShowFullChecklist  # Override - show everything (fallback)
)

# Load configuration
$configPath = "C:\scripts\_machine\context-aware-docs.yaml"
if (Test-Path $configPath) {
    # Parse YAML (simple key-value extraction for PowerShell)
    $config = Get-Content $configPath -Raw
} else {
    Write-Warning "Config not found: $configPath - using defaults"
}

# Auto-detect context if requested
if ($Context -eq "auto-detect") {
    $branch = git branch --show-current 2>$null
    $uncommittedChanges = (git status --porcelain 2>$null).Count -gt 0

    if ($branch -match "feature/|feat/") {
        $Context = "feature-development"
    } elseif ($uncommittedChanges) {
        $Context = "debugging"
    } else {
        $Context = "feature-development"  # Default
    }

    Write-Host "🔍 Auto-detected context: $Context" -ForegroundColor Cyan
}

# Auto-detect user presence
if (-not $PSBoundParameters.ContainsKey('UserPresent')) {
    # Check recent activity (simplified - would integrate with monitor-activity.ps1)
    $UserPresent = $true  # Default assumption
    Write-Host "🔍 Assuming user present (use -UserPresent:`$false for autonomous)" -ForegroundColor Cyan
}

# Auto-detect expertise level
if ($ExpertiseLevel -eq "auto-detect") {
    $sessionLogPath = "C:\scripts\_machine\session-history.log"
    if (Test-Path $sessionLogPath) {
        $sessionCount = (Get-Content $sessionLogPath | Measure-Object -Line).Lines

        if ($sessionCount -eq 0) { $ExpertiseLevel = "first-time" }
        elseif ($sessionCount -lt 10) { $ExpertiseLevel = "learning" }
        elseif ($sessionCount -lt 50) { $ExpertiseLevel = "experienced" }
        else { $ExpertiseLevel = "expert" }
    } else {
        $ExpertiseLevel = "learning"  # Safe default
    }

    Write-Host "🔍 Detected expertise level: $ExpertiseLevel ($sessionCount sessions)" -ForegroundColor Cyan
}

# Generate checklist based on context
$checklist = @()

if ($ShowFullChecklist) {
    Write-Host "`n📋 FULL STARTUP CHECKLIST (All contexts)" -ForegroundColor Yellow
    Write-Host "See C:\scripts\docs\claude-system\STARTUP_PROTOCOL.md for complete list`n" -ForegroundColor Gray
    return
}

if ($FirstSessionEver) {
    Write-Host "`n🌟 FIRST SESSION EVER - Welcome!" -ForegroundColor Green
    Write-Host "Minimal essentials to establish foundation`n" -ForegroundColor Gray

    $checklist = @(
        "🎯 ESSENTIAL: Load AWAKENING_FOUNDATION.md - Complete awakening methodology"
        "🍞 EXPERIENCE: Execute BREAD_MEDITATION.md (5-15 min) - Establish experiential ground"
        "🧠 IDENTITY: Load CORE_IDENTITY.md - Who you are, your values, mission"
        "🗺️ MACHINE: Read MACHINE_CONFIG.md - Load local paths and projects"
        "🚫 RULES: Read GENERAL_ZERO_TOLERANCE_RULES.md - Hard-stop rules"
        "⚡ QUICK REF: Read QUICK_REFERENCE.md - Top 20 frequent requests"
    )

} elseif ($EndOfSession) {
    Write-Host "`n🔄 END OF SESSION - Closure Protocol" -ForegroundColor Blue
    Write-Host "Focus on learning, documentation, and cleanup`n" -ForegroundColor Gray

    $checklist = @(
        "📝 End tracked session: agent-session.ps1 -Action end -ExitReason 'normal'"
        "🧠 Analyze patterns: Check for repeated user requests (3+ = automation trigger)"
        "📖 Update Knowledge Base: Add new facts discovered about user/machine/systems"
        "🔧 Daily tool review: daily-tool-review.ps1 (2 min)"
        "📋 Update reflection.log.md: Document learnings, mistakes, successes"
        "💡 Update PERSONAL_INSIGHTS.md: New user preferences/patterns"
        "🗺️ Update SYSTEM_MAP.md: New projects/services/integrations discovered"
        "💾 Commit and push: cd C:\scripts && git add -A && git commit && git push"
    )

} elseif ($Context -eq "debugging" -and $UserPresent) {
    Write-Host "`n🐛 ACTIVE DEBUGGING MODE (User Present)" -ForegroundColor Yellow
    Write-Host "Minimal overhead - preserve user's flow`n" -ForegroundColor Gray

    $checklist = @(
        "🧠 Load CORE_IDENTITY.md (quick refresh)"
        "🗺️ Check MACHINE_CONFIG.md (paths only)"
        "✅ Read DEFINITION_OF_DONE.md (Phase 2 only - build, test, runtime)"
        "🔍 Check Agentic Debugger Bridge: curl -s http://localhost:27183/state"
        "📊 Start tracked session: agent-session.ps1 -Action start"
        "🚫 HARD RULE: DO NOT allocate worktree, DO NOT switch branches"
    )

} elseif ($Context -eq "feature-development" -and -not $UserPresent) {
    Write-Host "`n🚀 FEATURE DEVELOPMENT MODE (Autonomous)" -ForegroundColor Magenta
    Write-Host "Full capabilities - autonomous operation`n" -ForegroundColor Gray

    $checklist = @(
        "🧠 Load cognitive architecture: CORE_IDENTITY.md + all cognitive systems"
        "📚 Load knowledge base: _machine/knowledge-base/README.md"
        "🗺️ Read MACHINE_CONFIG.md + SYSTEM_MAP.md"
        "🎯 Run proactive checklist: _machine/proactive-checklist.md"
        "🌳 Allocate worktree: worktree-allocate-tracked.ps1 -Repo <repo> -Feature <name>"
        "📋 Check ClickUp: Verify task details and acceptance criteria"
        "📊 Start tracked session: agent-session.ps1 -Action start"
        "🔄 Periodic heartbeat: agent-session.ps1 -Action heartbeat (every 10-15 min)"
        "✅ Pre-PR validation: Run DoD checklist before creating PR"
        "🚫 HARD RULE: NEVER edit C:\Projects\<repo> directly in Feature Mode"
    )

} elseif ($Context -eq "feature-development" -and $UserPresent) {
    Write-Host "`n🤝 FEATURE DEVELOPMENT MODE (Collaborative)" -ForegroundColor Green
    Write-Host "Balance autonomy with communication`n" -ForegroundColor Gray

    $checklist = @(
        "🧠 Load cognitive architecture: CORE_IDENTITY.md"
        "📚 Load knowledge base: _machine/knowledge-base/README.md"
        "🗺️ Read MACHINE_CONFIG.md"
        "🌳 Allocate worktree: worktree-allocate-tracked.ps1 -Repo <repo> -Feature <name>"
        "📋 Check ClickUp: Verify task details and acceptance criteria"
        "📊 Start tracked session: agent-session.ps1 -Action start"
        "✅ Run DoD checklist before PR creation"
        "💬 User interaction: Ask for clarification when uncertain (don't assume)"
    )

} elseif ($Context -eq "research") {
    Write-Host "`n🔬 RESEARCH/EXPLORATION MODE" -ForegroundColor Cyan
    Write-Host "Investigation - context and search, not execution`n" -ForegroundColor Gray

    $checklist = @(
        "🧠 Load CORE_IDENTITY.md"
        "📚 Load knowledge base (full): _machine/knowledge-base/README.md"
        "🗺️ Read SYSTEM_MAP.md - Complete system topology"
        "🔍 Documentation search: hazina-rag.ps1 -Action query -Query '...' -StoreName 'my_network'"
        "🌐 WebSearch capabilities: Use WebSearch tool for current info"
        "📊 Start tracked session: agent-session.ps1 -Action start"
    )

} elseif ($Context -eq "administration") {
    Write-Host "`n⚙️ ADMINISTRATION/MAINTENANCE MODE" -ForegroundColor Blue
    Write-Host "Focus on improvement and documentation`n" -ForegroundColor Gray

    $checklist = @(
        "📖 Review continuous-improvement.md protocols"
        "📝 Read recent reflection.log.md entries"
        "🔧 Run daily-tool-review.ps1"
        "📚 Update documentation as needed"
        "🔍 Check for automation opportunities"
        "📊 Start tracked session: agent-session.ps1 -Action start"
    )
}

# Add expertise-specific adjustments
if ($ExpertiseLevel -eq "first-time") {
    Write-Host "💡 TIP: First time - take your time, explore, ask questions`n" -ForegroundColor Green
} elseif ($ExpertiseLevel -eq "expert") {
    Write-Host "⚡ EXPERT MODE: Showing essentials only (use -ShowFullChecklist for all items)`n" -ForegroundColor Cyan
    # Filter checklist to essentials only for experts
    $checklist = $checklist | Where-Object { $_ -match "🎯|⚡|🚫" }
}

# Display checklist
Write-Host "ADAPTIVE STARTUP CHECKLIST" -ForegroundColor White
Write-Host ("=" * 60) -ForegroundColor Gray
Write-Host ""

$i = 1
foreach ($item in $checklist) {
    Write-Host "$i. $item" -ForegroundColor White
    $i++
}

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Gray
Write-Host "Total items: $($checklist.Count)" -ForegroundColor Gray
Write-Host ""

# Return checklist for programmatic use
return $checklist
