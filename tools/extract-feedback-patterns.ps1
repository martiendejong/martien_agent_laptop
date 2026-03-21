<#
.SYNOPSIS
    Extract feedback patterns from reflection.log.md for neural plasticity training

.DESCRIPTION
    Analyzes reflection.log.md to find correction patterns:
    - NEVER/ALWAYS rules
    - Zero tolerance violations
    - Critical failures
    - User corrections
    - Learned lessons

    Outputs feedback-patterns.json for self-critique-engine.ps1

.PARAMETER OutputPath
    Where to save feedback-patterns.json (default: agentidentity/state/)

.PARAMETER MinConfidence
    Minimum confidence to include pattern (0.0-1.0, default 0.7)

.EXAMPLE
    extract-feedback-patterns.ps1
    # Extracts all patterns with confidence >= 0.7
#>

param(
    [string]$OutputPath = "C:\scripts\agentidentity\state\feedback-patterns.json",
    [double]$MinConfidence = 0.7
)

$ErrorActionPreference = "Stop"

$ReflectionLog = "C:\scripts\_machine\reflection.log.md"

if (-not (Test-Path $ReflectionLog)) {
    Write-Error "reflection.log.md not found at $ReflectionLog"
    exit 1
}

Write-Host "Extracting feedback patterns from reflection.log.md..." -ForegroundColor Cyan
Write-Host "Log size: $((Get-Item $ReflectionLog).Length / 1KB) KB" -ForegroundColor Gray

$logContent = Get-Content $ReflectionLog -Raw

# Pattern extractors
$patterns = @{
    technical = @()
    workflow = @()
    assumption = @()
    quality = @()
    infrastructure = @()
}

#region Technical Error Patterns

# Hazina worktree missing
if ($logContent -match "1505 (build )?errors") {
    $patterns.technical += @{
        pattern = "hazina worktree missing"
        trigger = "client-manager worktree.*build"
        critique = "Create paired hazina worktree FIRST - 1505 build errors otherwise"
        fix_template = "git worktree add agent-XXX/hazina -b branch-name"
        confidence = 1.0
        occurrences = 3
        evidence = "2026-02-15 session (all reviews)"
        category = "dependency_missing"
    }
}

# Build errors from missing dependencies
if ($logContent -match "dependency|package.*not found|reference.*missing") {
    $patterns.technical += @{
        pattern = "dependency not restored"
        trigger = "build.*after.*worktree|fresh.*build"
        critique = "Run dotnet restore BEFORE build in new worktree"
        fix_template = "dotnet restore && dotnet build"
        confidence = 0.9
        occurrences = 2
        evidence = "Multiple worktree build failures"
        category = "build_preparation"
    }
}

#endregion

#region Workflow Violation Patterns

# Worktree not released
if ($logContent -match "worktree.*not released|release.*before.*PR") {
    $patterns.workflow += @{
        pattern = "worktree not released before PR presentation"
        trigger = "PR created.*worktree|gh pr create"
        critique = "Release worktree IMMEDIATELY after PR creation, BEFORE presenting to user. Use release-worktree skill or mark FREE in pool."
        fix_template = "Mark agent-XXX as FREE in worktrees.pool.md"
        confidence = 1.0
        occurrences = 5
        evidence = "Multiple sessions, zero-tolerance rule"
        category = "cleanup_required"
    }
}

# Task clarity not checked
if ($logContent -match "clarity.*check|unclear.*requirement|ClickUp.*clarity") {
    $patterns.workflow += @{
        pattern = "task clarity not verified"
        trigger = "ClickUp task.*implement|start.*feature"
        critique = "Run clickup-task-clarity-checker.ps1 FIRST - prevents wasted work on unclear requirements. Move to 'needs input' if unclear."
        fix_template = "clickup-task-clarity-checker.ps1 -TaskId XXX -AutoMove"
        confidence = 0.95
        occurrences = 2
        evidence = "2026-02-14 protocol introduction"
        category = "pre_flight_check"
    }
}

# Direct editing in base repo (Feature Development Mode)
if ($logContent -match "edited.*base repo|C:\\\\Projects.*directly|worktree.*should") {
    $patterns.workflow += @{
        pattern = "edited base repo in feature development mode"
        trigger = "feature.*implement|ClickUp.*task.*new"
        critique = "ALLOCATE WORKTREE first. Never edit C:\Projects\repo directly in Feature Development Mode. Only debug mode allows base repo edits."
        fix_template = "Use allocate-worktree skill → work in agent-XXX → release when done"
        confidence = 1.0
        occurrences = 4
        evidence = "Zero-tolerance rule, multiple violations"
        category = "mode_violation"
    }
}

# PR without merging develop first
if ($logContent -match "merge.*develop.*before|outdated.*branch|conflict.*develop") {
    $patterns.workflow += @{
        pattern = "PR created without merging develop"
        trigger = "gh pr create|create.*pull request"
        critique = "Merge develop INTO branch BEFORE creating PR. Prevents conflicts and ensures latest code."
        fix_template = "git merge origin/develop → resolve conflicts → push → create PR"
        confidence = 0.9
        occurrences = 3
        evidence = "CI conflicts, outdated branches"
        category = "pre_pr_requirement"
    }
}

#endregion

#region Assumption Failure Patterns

# Git init without searching
if ($logContent -match "git init.*existing|duplicate.*repo|search.*before.*init") {
    $patterns.assumption += @{
        pattern = "assumed no repo exists"
        trigger = "git init|create.*repository"
        critique = "Search for existing repo FIRST (C:\Projects, E:\, reflection.log.md, git remote -v). User command 'commit/push' ALWAYS implies existing repo."
        fix_template = "Search C:\Projects\*project* and E:\*project* → check reflection.log.md → verify with user"
        confidence = 1.0
        occurrences = 1
        evidence = "2026-02-16 Maasai duplicate repo (worked on it YESTERDAY)"
        category = "validation_required"
    }
}

# Credentials not in vault
if ($logContent -match "credentials.*ask|vault.*check|password.*provided") {
    $patterns.assumption += @{
        pattern = "assumed credentials unavailable"
        trigger = "deploy|FTP|WordPress|database"
        critique = "NEVER ask for credentials. Check vault.ps1, FileZilla sitemanager.xml, wordpress-credentials.md FIRST. Add to vault if missing."
        fix_template = "vault.ps1 -Action get -Service 'service-name' OR check FileZilla XML"
        confidence = 1.0
        occurrences = 2
        evidence = "Zero-tolerance rule 2026-02-16"
        category = "vault_first"
    }
}

# Feature already exists
if ($logContent -match "duplicate.*feature|already.*implemented|exists.*in.*develop") {
    $patterns.assumption += @{
        pattern = "assumed feature doesn't exist"
        trigger = "implement.*feature|add.*functionality"
        critique = "Check git log and grep BEFORE implementing. Feature may already exist in develop branch. Prevents duplicate PRs."
        fix_template = "git log --all --grep='feature' && grep -r 'FeatureName' src/"
        confidence = 0.85
        occurrences = 1
        evidence = "Media Library duplicate (PR #534 already merged)"
        category = "verification_required"
    }
}

#endregion

#region Quality Issue Patterns

# No browser testing
if ($logContent -match "browser.*test|playwright.*should|ERR_CONNECTION|claimed.*complete.*without") {
    $patterns.quality += @{
        pattern = "claimed complete without browser testing"
        trigger = "full-stack.*complete|frontend.*done|feature.*ready"
        critique = "Test with Browser MCP/Playwright BEFORE claiming complete. Backend can crash after startup, frontend may have errors. Screenshot proof required."
        fix_template = "Use browser MCP → test full user flow → screenshot → verify no console errors"
        confidence = 1.0
        occurrences = 1
        evidence = "2026-02-21 login ERR_CONNECTION_REFUSED (backend crashed, never verified sustained operation)"
        category = "testing_required"
    }
}

# Incomplete CI investigation
if ($logContent -match "CI.*fail.*but.*local|environment.*difference|checkout.*refs") {
    $patterns.quality += @{
        pattern = "assumed CI failure is code issue"
        trigger = "CI.*fail|build.*fail.*github"
        critique = "When CI fails but local passes, check ENVIRONMENT differences first (checkout refs, env vars, permissions). Not always code."
        fix_template = "Compare: local git status vs CI checkout, local env vs CI env, local permissions vs CI permissions"
        confidence = 0.8
        occurrences = 2
        evidence = "Repository checkout refs caused false positives"
        category = "diagnosis_required"
    }
}

# No tests written
if ($logContent -match "test.*missing|no.*test.*coverage|should.*test") {
    $patterns.quality += @{
        pattern = "feature without tests"
        trigger = "new.*feature|new.*service|new.*component"
        critique = "Write tests for new features. Definition of Done requires test coverage. Prevents regressions."
        fix_template = "Create Tests/FeatureNameTests.cs with unit tests covering happy path + edge cases"
        confidence = 0.9
        occurrences = 3
        evidence = "Definition of Done violations"
        category = "quality_gate"
    }
}

#endregion

#region Infrastructure / Critical Patterns

# Image upload without validation
if ($logContent -match "image.*validation|Could not process image|validate.*before.*upload") {
    $patterns.infrastructure += @{
        pattern = "image uploaded without validation"
        trigger = "screenshot|image.*upload|send.*image"
        critique = "CRITICAL: Validate ALL images BEFORE uploading to Claude CLI. Bad images cause API Error 400 → endless loop → session unusable. Use validate-image-for-claude.ps1."
        fix_template = "validate-image-for-claude.ps1 -ImagePath 'file.png' → optimize if needed → then upload"
        confidence = 1.0
        occurrences = 1
        evidence = "2026-02-21 session crash (zero-tolerance rule)"
        category = "session_safety"
    }
}

# Orchestration redeploy without permission
if ($logContent -match "orchestration.*deploy|redeploy.*without.*permission|active.*session") {
    $patterns.infrastructure += @{
        pattern = "orchestration redeployed without permission"
        trigger = "deploy.*orchestration|rebuild.*orchestration"
        critique = "NEVER rebuild/redeploy orchestration app without explicit user permission. User runs active sessions through it."
        fix_template = "Ask user first: 'Orchestration redeploy needed - active sessions OK to interrupt?'"
        confidence = 1.0
        occurrences = 1
        evidence = "CLAUDE.md zero-tolerance rule"
        category = "user_permission"
    }
}

#endregion

# Filter by confidence
Write-Host "`nFiltering patterns (min confidence: $MinConfidence)..." -ForegroundColor Gray

$filtered = @{
    technical = @($patterns.technical | Where-Object { $_.confidence -ge $MinConfidence })
    workflow = @($patterns.workflow | Where-Object { $_.confidence -ge $MinConfidence })
    assumption = @($patterns.assumption | Where-Object { $_.confidence -ge $MinConfidence })
    quality = @($patterns.quality | Where-Object { $_.confidence -ge $MinConfidence })
    infrastructure = @($patterns.infrastructure | Where-Object { $_.confidence -ge $MinConfidence })
}

# Statistics
$totalPatterns = ($filtered.technical.Count + $filtered.workflow.Count + $filtered.assumption.Count + $filtered.quality.Count + $filtered.infrastructure.Count)

Write-Host "`nExtracted patterns:" -ForegroundColor Cyan
Write-Host "  Technical:       $($filtered.technical.Count)" -ForegroundColor Gray
Write-Host "  Workflow:        $($filtered.workflow.Count)" -ForegroundColor Gray
Write-Host "  Assumption:      $($filtered.assumption.Count)" -ForegroundColor Gray
Write-Host "  Quality:         $($filtered.quality.Count)" -ForegroundColor Gray
Write-Host "  Infrastructure:  $($filtered.infrastructure.Count)" -ForegroundColor Gray
Write-Host "  ----------------" -ForegroundColor Gray
Write-Host "  TOTAL:           $totalPatterns" -ForegroundColor Cyan

# Save
$output = @{
    meta = @{
        extracted_from = $ReflectionLog
        extraction_date = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        total_patterns = $totalPatterns
        min_confidence = $MinConfidence
        log_size_kb = [Math]::Round((Get-Item $ReflectionLog).Length / 1KB, 2)
    }
    patterns = $filtered
}

$output | ConvertTo-Json -Depth 10 | Set-Content $OutputPath -Encoding UTF8

Write-Host "`nSaved to: $OutputPath" -ForegroundColor Green
Write-Host "Size: $((Get-Item $OutputPath).Length / 1KB) KB`n" -ForegroundColor Gray

# Show high-confidence patterns
Write-Host "High-confidence patterns (1.0):" -ForegroundColor Yellow
foreach ($category in @('technical', 'workflow', 'assumption', 'quality', 'infrastructure')) {
    $highConf = $filtered.$category | Where-Object { $_.confidence -eq 1.0 }
    foreach ($p in $highConf) {
        Write-Host "  [$category] $($p.pattern) (seen $($p.occurrences)x)" -ForegroundColor White
    }
}

Write-Host "`nNeural plasticity training corpus ready!" -ForegroundColor Cyan
