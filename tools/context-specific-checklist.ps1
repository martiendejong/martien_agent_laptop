# Context-Specific Checklist Generator
# Generates minimal checklists based on detected context
# Part of Round 11: Cognitive Load Optimization (#6)

param(
    [ValidateSet("Auto", "FeatureDev", "Debugging", "Research", "Admin", "Idle")]
    [string]$Mode = "Auto",

    [switch]$UserPresent,
    [switch]$Minimal,
    [switch]$Full
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir

function Detect-Context {
    $context = @{
        mode = "unknown"
        branch = ""
        uncommitted_changes = 0
        user_present = $false
        worktree_active = $false
        build_status = "unknown"
    }

    # Detect git context
    try {
        $context.branch = git rev-parse --abbrev-ref HEAD 2>$null
        $context.uncommitted_changes = (git status --porcelain 2>$null | Measure-Object).Count
    }
    catch {
        # Not in git repo or git not available
    }

    # Detect user presence
    $vsRunning = Get-Process | Where-Object { $_.ProcessName -eq "devenv" }
    $context.user_present = $null -ne $vsRunning

    # Detect worktree
    $gitDir = git rev-parse --git-dir 2>$null
    if ($gitDir -match "worktrees") {
        $context.worktree_active = $true
    }

    # Determine mode
    if ($context.branch -match "^feature/") {
        $context.mode = "FeatureDev"
    }
    elseif ($context.branch -match "^fix/|^hotfix/|^bugfix/") {
        $context.mode = "Debugging"
    }
    elseif ($context.branch -eq "develop" -or $context.branch -eq "main") {
        if ($context.uncommitted_changes -gt 0) {
            $context.mode = "Debugging"
        }
        else {
            $context.mode = "Idle"
        }
    }

    return $context
}

function Get-FeatureDevChecklist {
    param([hashtable]$Context, [bool]$IsMinimal)

    if ($IsMinimal) {
        return @(
            "[ ] Allocate worktree (smart defaults enabled)"
            "[ ] Review task description from ClickUp"
            "[ ] Create feature implementation"
            "[ ] Run tests locally"
            "[ ] Create PR with auto-generated description"
            "[ ] Update ClickUp status to 'review'"
        )
    }

    return @(
        "=== FEATURE DEVELOPMENT CHECKLIST ==="
        ""
        "Pre-Work:"
        "[ ] Read MACHINE_CONFIG.md (paths, projects)"
        "[ ] Check worktree pool status"
        "[ ] Review ClickUp task description"
        ""
        "Development:"
        "[ ] Allocate worktree (.\tools\allocate-worktree.ps1)"
        "[ ] Implement feature following DEFINITION_OF_DONE.md"
        "[ ] Run local tests (dotnet test)"
        "[ ] Check for EF migrations if DB changes"
        ""
        "Code Review:"
        "[ ] Self-review: No debug statements, no secrets"
        "[ ] Run .\tools\pr-preflight.ps1"
        "[ ] Verify build passes"
        ""
        "Pull Request:"
        "[ ] Create PR with conventional commit title"
        "[ ] Link to ClickUp task in description"
        "[ ] Add Hazina dependency PR if applicable"
        "[ ] Request review"
        ""
        "Cleanup:"
        "[ ] Release worktree after PR created"
        "[ ] Update ClickUp status to 'review'"
        "[ ] Add agent completion comment"
    )
}

function Get-DebuggingChecklist {
    param([hashtable]$Context, [bool]$IsMinimal)

    if ($IsMinimal) {
        return @(
            "[ ] Reproduce issue locally"
            "[ ] Fix and verify solution"
            "[ ] Test edge cases"
            "[ ] Commit fix directly (no worktree needed)"
        )
    }

    return @(
        "=== DEBUGGING CHECKLIST ==="
        ""
        "Investigation:"
        "[ ] Reproduce issue consistently"
        "[ ] Check recent changes (git log)"
        "[ ] Review error logs/stack traces"
        "[ ] Identify root cause"
        ""
        "Fix:"
        "[ ] Implement fix in current branch"
        "[ ] Verify fix resolves issue"
        "[ ] Test edge cases"
        "[ ] Run relevant tests"
        ""
        "Verification:"
        "[ ] No regressions introduced"
        "[ ] Build passes"
        "[ ] Tests pass"
        ""
        "Commit:"
        "[ ] Commit with descriptive message"
        "[ ] Push changes"
        "[ ] Update issue tracker"
    )
}

function Get-ResearchChecklist {
    return @(
        "=== RESEARCH CHECKLIST ==="
        ""
        "[ ] Define research question clearly"
        "[ ] Search codebase (Grep, Glob)"
        "[ ] Review related documentation"
        "[ ] Check git history for context"
        "[ ] Document findings"
        "[ ] Share insights with team"
    )
}

function Get-AdminChecklist {
    return @(
        "=== ADMIN CHECKLIST ==="
        ""
        "[ ] Review session goals"
        "[ ] Check system health (disk space, services)"
        "[ ] Update documentation if needed"
        "[ ] Review pending PRs"
        "[ ] Process ClickUp backlog"
        "[ ] Plan next session"
    )
}

function Get-IdleChecklist {
    return @(
        "=== READY TO WORK ==="
        ""
        "[ ] Check ClickUp for tasks"
        "[ ] Review PR review requests"
        "[ ] Check build status"
        "[ ] Ready for next task"
    )
}

# Main execution
$context = Detect-Context

$displayMode = if ($Mode -eq "Auto") { $context.mode } else { $Mode }

Write-Host "`n=== CONTEXT DETECTION ===" -ForegroundColor Cyan
Write-Host "Mode: $displayMode" -ForegroundColor Yellow
Write-Host "Branch: $($context.branch)" -ForegroundColor White
Write-Host "Uncommitted Changes: $($context.uncommitted_changes)" -ForegroundColor White
Write-Host "User Present: $($context.user_present)" -ForegroundColor White
Write-Host "Worktree Active: $($context.worktree_active)" -ForegroundColor White

$isMinimal = $Minimal -or ($context.user_present -and -not $Full)

Write-Host "`n=== CHECKLIST ($(if ($isMinimal) { 'MINIMAL' } else { 'FULL' })) ===" -ForegroundColor Cyan

$checklist = switch ($displayMode) {
    "FeatureDev" { Get-FeatureDevChecklist -Context $context -IsMinimal $isMinimal }
    "Debugging" { Get-DebuggingChecklist -Context $context -IsMinimal $isMinimal }
    "Research" { Get-ResearchChecklist }
    "Admin" { Get-AdminChecklist }
    "Idle" { Get-IdleChecklist }
    default { @("[ ] Determine current mode and generate appropriate checklist") }
}

foreach ($item in $checklist) {
    if ($item -match "^===") {
        Write-Host $item -ForegroundColor Yellow
    }
    elseif ($item -match "^\[.\]") {
        Write-Host $item -ForegroundColor White
    }
    elseif ($item -match "^[A-Za-z].*:$") {
        Write-Host "`n$item" -ForegroundColor Green
    }
    else {
        Write-Host $item
    }
}

Write-Host "`n=== COGNITIVE LOAD ===" -ForegroundColor Cyan
$itemCount = ($checklist | Where-Object { $_ -match "^\[.\]" }).Count
Write-Host "Items to process: $itemCount" -ForegroundColor $(if ($itemCount -lt 10) { "Green" } elseif ($itemCount -lt 20) { "Yellow" } else { "Red" })

if ($isMinimal) {
    Write-Host "Checklist optimized for minimal cognitive load" -ForegroundColor Green
}
