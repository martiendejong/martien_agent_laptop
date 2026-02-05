# Just-In-Time Documentation Lookup
# Purpose: Surface documentation at moment of need, not upfront
# Created: 2026-02-05 (Round 11: Cognitive Load Optimization)

param(
    [Parameter(Mandatory=$true)]
    [string]$Action,  # allocate-worktree, create-pr, ef-migration, fix-build, etc.

    [string]$CurrentStep = "",  # Optional - current step in multi-step process

    [switch]$Essential,  # Layer 0: What I need right now
    [switch]$Tactical,   # Layer 1: Step-by-step procedure
    [switch]$Strategic,  # Layer 2: Alternatives and trade-offs
    [switch]$DeepDive,   # Layer 3: Theory, edge cases, complete examples

    [switch]$AllLayers   # Show all layers
)

# Default to Essential if no layer specified
if (-not $Essential -and -not $Tactical -and -not $Strategic -and -not $DeepDive -and -not $AllLayers) {
    $Essential = $true
}

# Knowledge base - action to documentation mapping
$actionDocs = @{
    "allocate-worktree" = @{
        Essential = @(
            "⚡ NEXT: worktree-allocate-tracked.ps1 -Repo <repo> -Feature <name>"
            "🚫 HARD RULE: This auto-updates worktrees.pool.md (seat marked BUSY)"
            "💡 TIP: Use first available FREE seat (auto-selected)"
        )
        Tactical = @(
            "📋 PROCEDURE:"
            "1. Run: worktree-allocate-tracked.ps1 -Repo client-manager -Feature 'feature-name'"
            "2. Navigate: cd C:\Projects\worker-agents\agent-XX\client-manager"
            "3. Verify: git branch --show-current (should be feature/feature-name)"
            "4. Start work in worktree"
            ""
            "⚠️ GOTCHAS:"
            "- Verify seat is FREE before allocating (check worktrees.pool.md)"
            "- Base repo MUST be on 'develop' branch"
            "- Release worktree IMMEDIATELY after PR creation"
        )
        Strategic = @(
            "🧠 DECISION: When to use worktree?"
            "- ✅ Feature Development Mode (new features, refactoring)"
            "- ✅ ClickUp URL present (always Feature Mode)"
            "- ✅ Autonomous work (user absent)"
            "- ❌ Active Debugging Mode (user present, fixing build errors)"
            "- ❌ Quick hotfixes (consider patch workflow instead)"
            ""
            "🔄 ALTERNATIVES:"
            "- Manual: git worktree add + manual pool update"
            "- Patch workflow: For single-file hotfixes"
            "- Direct editing: Only in Active Debugging Mode"
        )
        DeepDive = @(
            "🔬 THEORY:"
            "Worktrees provide filesystem-level isolation for parallel development."
            "Each worktree is a separate working directory pointing to same .git folder."
            "Enables multi-agent work without branch switching conflicts."
            ""
            "📚 COMPLETE DOCS: C:\scripts\worktree-workflow.md"
            "📚 RELATED: C:\scripts\_machine\worktrees.protocol.md"
            "📚 MULTI-AGENT: C:\scripts\_machine\MULTI_AGENT_CONFLICT_DETECTION.md"
        )
    }

    "create-pr" = @{
        Essential = @(
            "⚡ NEXT: gh pr create --title '...' --body '...'"
            "🚫 HARD RULE: Run DoD checklist FIRST (verify-dod.ps1)"
            "🚫 HARD RULE: Release worktree IMMEDIATELY after PR"
        )
        Tactical = @(
            "📋 PROCEDURE:"
            "1. Run DoD checklist: verify-dod.ps1 (MANDATORY)"
            "2. Review changes: git diff develop...HEAD"
            "3. Create PR: gh pr create --title 'feat: ...' --body '...'"
            "4. Release worktree: worktree-release-tracked.ps1 -AgentSeat 'agent-XX'"
            "5. Switch to develop: cd C:\Projects\<repo> && git checkout develop"
            ""
            "⚠️ GOTCHAS:"
            "- Never create PR with failing tests"
            "- Never forget to release worktree after PR"
            "- Use conventional commit format in title (feat:, fix:, docs:, etc.)"
        )
        Strategic = @(
            "🧠 DECISION: PR type?"
            "- Draft PR: If tests failing, work in progress, needs review before completion"
            "- Regular PR: Ready to merge, all tests passing, DoD met"
            "- Hotfix PR: Target 'main' branch instead of 'develop'"
            ""
            "🔄 CROSS-REPO DEPENDENCIES:"
            "If PR depends on another repo's PR:"
            "1. Document in pr-dependencies.yaml"
            "2. Link related PRs in description"
            "3. Coordinate merge order (backend → frontend usually)"
        )
        DeepDive = @(
            "🔬 COMPLETE PR WORKFLOW:"
            "See C:\scripts\git-workflow.md § PR Creation"
            ""
            "📚 RELATED:"
            "- DEFINITION_OF_DONE.md - What 'done' means"
            "- pr-dependencies.yaml - Cross-repo coordination"
            "- git-workflow.md § Merge Conflicts - How to resolve"
        )
    }

    "ef-migration" = @{
        Essential = @(
            "⚡ NEXT: dotnet ef migrations add <Name> --context <DbContext>"
            "🚫 HARD RULE: ALWAYS check pending changes BEFORE commit"
            "🚫 HARD RULE: Commit migration WITH the feature (never separate)"
        )
        Tactical = @(
            "📋 PROCEDURE:"
            "1. Check pending: dotnet ef migrations has-pending-model-changes --context IdentityDbContext"
            "   - Exit 0: No changes, skip migration"
            "   - Exit 1: CREATE MIGRATION (step 2)"
            "2. Create migration: dotnet ef migrations add AddUserAuth --context IdentityDbContext"
            "3. Review migration: Open Migrations/*.cs, verify Up/Down methods"
            "4. Commit together: git add . && git commit -m 'feat: add user auth + migration'"
            ""
            "⚠️ GOTCHAS:"
            "- Never commit code without migration (causes PendingModelChangesWarning)"
            "- Never create empty migration (check Up/Down methods)"
            "- Multiple DbContexts: Specify --context explicitly"
        )
        Strategic = @(
            "🧠 MIGRATION SAFETY:"
            "- Data-destructive changes: Add manual data migration in Up() method"
            "- Rollback safety: Ensure Down() method properly reverses Up()"
            "- Production considerations: Test migration on copy of production DB first"
            ""
            "🔄 ALTERNATIVES:"
            "- Scaffold and modify: Create blank migration, manually write Up/Down"
            "- Reverse engineering: dotnet ef dbcontext scaffold (from existing DB)"
        )
        DeepDive = @(
            "🔬 COMPLETE MIGRATION GUIDE:"
            "See C:\scripts\_machine\migration-patterns.md"
            ""
            "📚 RELATED:"
            "- EF Core docs: https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/"
            "- Skill: ef-migration-safety (auto-discoverable)"
        )
    }

    "fix-build" = @{
        Essential = @(
            "⚡ NEXT: dotnet build (to see error)"
            "🚫 HARD RULE: Active Debugging Mode - DON'T allocate worktree"
            "🚫 HARD RULE: Preserve user's current branch (DON'T switch)"
        )
        Tactical = @(
            "📋 PROCEDURE:"
            "1. Identify error: dotnet build"
            "2. Fix in place: Edit C:\Projects\<repo> directly"
            "3. Test fix: dotnet build (verify success)"
            "4. Commit: git add . && git commit -m 'fix: ...'"
            ""
            "⚠️ GOTCHAS:"
            "- User is debugging - fast turnaround critical"
            "- Don't switch branches (user's context is current branch)"
            "- Don't create PR unless user explicitly asks"
        )
        Strategic = @(
            "🧠 DECISION: Build error type?"
            "- Syntax error: Fix directly, fast iteration"
            "- Missing dependency: Check NuGet packages, versions"
            "- Configuration issue: Check appsettings.json, environment variables"
            ""
            "🔄 DIAGNOSTIC TOOLS:"
            "- Agentic Debugger Bridge: http://localhost:27183/state"
            "- Visual Studio Build Output: More detailed error info"
            "- dotnet build -v detailed: Verbose build output"
        )
        DeepDive = @(
            "🔬 COMPLETE BUILD TROUBLESHOOTING:"
            "See C:\scripts\ci-cd-troubleshooting.md"
            ""
            "📚 RELATED:"
            "- DEFINITION_OF_DONE.md § Phase 2: Build Validation"
            "- Agentic Debugger Bridge: Full Visual Studio control"
        )
    }

    "verify-dod" = @{
        Essential = @(
            "⚡ NEXT: verify-dod.ps1 (auto-checks all phases)"
            "🚫 HARD RULE: Must pass ALL phases before PR creation"
            "💡 TIP: Run frequently during development (catch issues early)"
        )
        Tactical = @(
            "📋 DEFINITION OF DONE PHASES:"
            "1. Code Quality: No TODOs, no commented code, proper naming"
            "2. Build Validation: dotnet build succeeds"
            "3. Test Coverage: Tests pass, new features have tests"
            "4. Documentation: README updated, API documented"
            "5. Integration: Works with other components"
            ""
            "⚠️ GOTCHAS:"
            "- Phase 1 is SUBJECTIVE (manual review)"
            "- Phase 2+ are OBJECTIVE (automated checks)"
            "- EF Core: Check pending migrations BEFORE commit"
        )
        Strategic = @(
            "🧠 DoD PHILOSOPHY:"
            "Done = Could deploy to production right now"
            "Not done = Would cause issues if deployed"
            ""
            "🔄 WHEN TO CHECK:"
            "- Before first commit (catch issues early)"
            "- Before PR creation (MANDATORY)"
            "- After merge conflict resolution (verify nothing broke)"
        )
        DeepDive = @(
            "🔬 COMPLETE DoD REFERENCE:"
            "See C:\scripts\_machine\DEFINITION_OF_DONE.md"
            ""
            "📚 RELATED:"
            "- SOFTWARE_DEVELOPMENT_PRINCIPLES.md § Boy Scout Rule"
            "- git-workflow.md § Pre-PR Validation"
        )
    }
}

# Get documentation for requested action
if (-not $actionDocs.ContainsKey($Action)) {
    Write-Host "❌ Unknown action: $Action" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available actions:" -ForegroundColor Yellow
    $actionDocs.Keys | Sort-Object | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Gray
    }
    return
}

$docs = $actionDocs[$Action]

# Display requested layers
Write-Host ""
Write-Host "📚 JUST-IN-TIME DOCUMENTATION: $Action" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Gray
Write-Host ""

if ($Essential -or $AllLayers) {
    Write-Host "🎯 ESSENTIAL (What you need right now):" -ForegroundColor Green
    Write-Host ""
    $docs.Essential | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }
    Write-Host ""
}

if ($Tactical -or $AllLayers) {
    Write-Host "📋 TACTICAL (Step-by-step procedure):" -ForegroundColor Yellow
    Write-Host ""
    $docs.Tactical | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }
    Write-Host ""
}

if ($Strategic -or $AllLayers) {
    Write-Host "🧠 STRATEGIC (Alternatives and trade-offs):" -ForegroundColor Magenta
    Write-Host ""
    $docs.Strategic | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }
    Write-Host ""
}

if ($DeepDive -or $AllLayers) {
    Write-Host "🔬 DEEP DIVE (Theory and complete docs):" -ForegroundColor Cyan
    Write-Host ""
    $docs.DeepDive | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }
    Write-Host ""
}

Write-Host ("=" * 60) -ForegroundColor Gray
Write-Host "💡 TIP: Use -AllLayers to see complete information" -ForegroundColor Gray
Write-Host ""

# Return docs for programmatic use
return $docs
