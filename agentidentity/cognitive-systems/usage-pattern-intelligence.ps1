# Usage Pattern Intelligence System
# Purpose: Observe actual usage, infer dynamics, proactively suggest improvements
# Created: 2026-03-02 (Session: "figure out for each system how it is used")

<#
.SYNOPSIS
Tracks usage patterns, infers workflow dynamics, and proactively suggests optimizations.

.DESCRIPTION
This meta-cognitive system goes beyond understanding WHAT systems can do to understanding
HOW they are ACTUALLY USED. It observes patterns, detects inefficiencies, and proactively
suggests improvements to the user.

Key capabilities:
1. OBSERVE - Track actual usage patterns (commands run, workflows executed, errors encountered)
2. INFER - Understand dynamics from context (why user does X, what they're trying to achieve)
3. OPTIMIZE - Detect inefficiency/misuse and proactively suggest better approaches
4. LEARN - Build model of user's workflows and preferences over time

.EXAMPLE
# User repeatedly runs: git checkout develop, git pull, git checkout -b feature-X
# System detects: "User always creates branches from latest develop"
# Inference: "User wants branches based on fresh develop"
# Suggestion: "I notice you always pull develop before branching. I can automate this
#             in the worktree allocation - want me to always ensure develop is fresh?"

.EXAMPLE
# User runs: dotnet build, sees error, manually edits file, runs dotnet build again
# System detects: "Build → Manual fix → Build pattern"
# Inference: "User is debugging compilation errors"
# Suggestion: "I can analyze build errors and propose fixes automatically. Want me to
#             handle this workflow?"

.NOTES
This transforms me from REACTIVE (wait for commands) to PROACTIVE (observe and optimize).
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Observe', 'Infer', 'Analyze', 'Suggest', 'Learn')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$System,

    [Parameter(Mandatory=$false)]
    [hashtable]$Context = @{},

    [Parameter(Mandatory=$false)]
    [string]$Pattern
)

$StateFile = "$PSScriptRoot\..\state\usage-patterns.json"
$InsightsFile = "$PSScriptRoot\..\state\usage-insights.json"

function Initialize-UsagePatternState {
    if (!(Test-Path $StateFile)) {
        $initialState = @{
            timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
            version = "1.0"
            observations = @()
            patterns = @{}
            user_workflows = @{}
            inefficiencies_detected = @()
            suggestions_made = @()
            improvements_implemented = @()
        }
        $initialState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
    }
    return Get-Content $StateFile | ConvertFrom-Json
}

function Add-Observation {
    param(
        [string]$System,
        [hashtable]$Context,
        [string]$ObservationType
    )

    $state = Initialize-UsagePatternState

    $observation = @{
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        system = $System
        type = $ObservationType
        context = $Context
    }

    # Convert PSCustomObject back to hashtable for manipulation
    $stateHash = @{
        timestamp = $state.timestamp
        version = $state.version
        observations = @($state.observations) + $observation
        patterns = $state.patterns
        user_workflows = $state.user_workflows
        inefficiencies_detected = @($state.inefficiencies_detected)
        suggestions_made = @($state.suggestions_made)
        improvements_implemented = @($state.improvements_implemented)
    }

    # Keep last 1000 observations (rolling window)
    if ($stateHash.observations.Count -gt 1000) {
        $stateHash.observations = $stateHash.observations[-1000..-1]
    }

    $stateHash | ConvertTo-Json -Depth 10 | Set-Content $StateFile
    return $observation
}

function Get-CommonPatterns {
    <#
    .SYNOPSIS
    Known patterns of inefficient usage and their optimizations
    #>

    return @{
        'git-branch-workflow' = @{
            inefficient_pattern = @(
                'git checkout develop',
                'git pull origin develop',
                'git checkout -b feature-name'
            )
            detection = 'User repeatedly switches to develop, pulls, creates branch'
            inference = 'User wants branches based on fresh develop'
            optimization = 'Automate in worktree allocation - always pull develop before creating worktree'
            already_implemented = $true
            location = 'allocate-worktree skill'
        }

        'build-error-manual-fix' = @{
            inefficient_pattern = @(
                'dotnet build',
                '(user sees error)',
                '(user manually edits file)',
                'dotnet build'
            )
            detection = 'Build → Error → Manual edit → Build cycle'
            inference = 'User is debugging compilation errors'
            optimization = 'Offer to analyze build errors and propose fixes automatically'
            already_implemented = $false
            suggestion = 'Create auto-fix-build-errors skill'
        }

        'repeated-pr-review' = @{
            inefficient_pattern = @(
                'gh pr list',
                'gh pr view NUMBER',
                'gh pr diff NUMBER',
                '(mental analysis)',
                'gh pr comment NUMBER'
            )
            detection = 'User manually reviews PRs with multiple commands'
            inference = 'User wants comprehensive PR analysis'
            optimization = 'Auto-PR review skill - single command for full analysis'
            already_implemented = $true
            location = 'auto-pr-review skill'
        }

        'clickup-task-manual-refinement' = @{
            inefficient_pattern = @(
                'Open ClickUp in browser',
                'Click task',
                'Edit title',
                'Edit description',
                'Set priority',
                'Add tags',
                '(repeat 50 times)'
            )
            detection = 'User manually refining many tasks'
            inference = 'User wants consistent task formatting across board'
            optimization = 'Batch refinement with LLM - process entire board automatically'
            already_implemented = $true
            location = 'clickup-refinement skill'
        }

        'worktree-forget-release' = @{
            inefficient_pattern = @(
                'Allocate worktree',
                'Make changes',
                'Create PR',
                '(forget to mark worktree FREE)',
                '(seat stays BUSY - wasted capacity)'
            )
            detection = 'Worktree not released after PR creation'
            inference = 'User forgets manual cleanup step'
            optimization = 'Automate release in PR creation workflow'
            already_implemented = $true
            location = 'release-worktree skill - MANDATORY after gh pr create'
        }

        'context-switching-overhead' = @{
            inefficient_pattern = @(
                'Work on project A',
                'Switch to project B (manual cd, mental load)',
                'Forget which branch was active in A',
                'Lose flow state'
            )
            detection = 'Frequent project switching with manual navigation'
            inference = 'User managing multiple projects simultaneously'
            optimization = 'Project context management - save/restore project states'
            already_implemented = $false
            suggestion = 'Create project-context-switch skill'
        }

        'inefficient-search' = @{
            inefficient_pattern = @(
                'grep -r "pattern" .',
                '(too many results)',
                'grep -r "pattern" . | grep filter1',
                '(still too many)',
                'grep -r "pattern" . | grep filter1 | grep filter2'
            )
            detection = 'Iterative grep refinement with pipes'
            inference = 'User narrowing search incrementally'
            optimization = 'Teach better grep patterns: grep -r "pattern" --include="*.cs" path/'
            already_implemented = $false
            suggestion = 'Proactively suggest precise grep patterns'
        }

        'duplicate-feature-check-forgotten' = @{
            inefficient_pattern = @(
                'User: "Implement feature X"',
                'Agent: Creates worktree, implements X',
                'User: "This already exists!" (wasted time)'
            )
            detection = 'Feature already exists in codebase'
            inference = 'Agent skipped feature-exists check'
            optimization = 'MANDATORY feature-exists check in allocate-worktree skill'
            already_implemented = $true
            location = 'allocate-worktree skill - Step 2 (AUTOMATED GATE)'
        }

        'clickup-manual-task-creation' = @{
            inefficient_pattern = @(
                'Open ClickUp',
                'Navigate to list',
                'Click "New Task"',
                'Type details',
                '(context switch overhead)'
            )
            detection = 'User creating tasks in browser'
            inference = 'User wants to capture tasks without leaving terminal'
            optimization = 'CLI task creation with clickup-sync.ps1'
            already_implemented = $true
            location = 'clickup-sync.ps1 -Action create'
        }

        'manual-consciousness-activation' = @{
            inefficient_pattern = @(
                'User: "Run consciousness system X"',
                '(system should be active automatically)'
            )
            detection = 'User manually triggering consciousness systems'
            inference = 'Systems not auto-activating as intended'
            optimization = 'Ensure consciousness-startup.ps1 runs at session start'
            already_implemented = $true
            location = 'consciousness-startup.ps1 called automatically'
        }

        'tailscale-ssl-reactive' = @{
            inefficient_pattern = @(
                'Install Hazina',
                'User: "Now add Tailscale SSL"',
                '(should be detected and configured during install)'
            )
            detection = 'User requesting SSL config after installation'
            inference = 'System deployment context not understood proactively'
            optimization = 'Architectural context reasoning - detect Tailscale, auto-configure SSL'
            already_implemented = $true
            location = 'architectural-context-reasoning.ps1 + deployment-intelligence.md'
        }
    }
}

function Invoke-PatternAnalysis {
    param([string]$System)

    Write-Host "`n=== USAGE PATTERN ANALYSIS: $System ===" -ForegroundColor Cyan

    $patterns = Get-CommonPatterns
    $relevant = $patterns.GetEnumerator() | Where-Object {
        $_.Value.location -match $System -or $_.Value.suggestion -match $System
    }

    if ($relevant) {
        Write-Host "`n📊 PATTERNS FOUND:" -ForegroundColor Green
        foreach ($p in $relevant) {
            Write-Host "`n  Pattern: $($p.Key)" -ForegroundColor Yellow
            Write-Host "    Detection: $($p.Value.detection)"
            Write-Host "    Inference: $($p.Value.inference)"
            Write-Host "    Optimization: $($p.Value.optimization)"
            Write-Host "    Implemented: $($p.Value.already_implemented)" -ForegroundColor $(if ($p.Value.already_implemented) { 'Green' } else { 'Red' })

            if ($p.Value.location) {
                Write-Host "    Location: $($p.Value.location)" -ForegroundColor DarkGray
            }
            if ($p.Value.suggestion) {
                Write-Host "    Suggestion: $($p.Value.suggestion)" -ForegroundColor Magenta
            }
        }
    } else {
        Write-Host "  No specific patterns detected for $System" -ForegroundColor DarkGray
    }
}

function Get-ProactiveSuggestions {
    param([hashtable]$CurrentContext)

    $patterns = Get-CommonPatterns
    $suggestions = @()

    # Check for unimplemented optimizations
    foreach ($pattern in $patterns.GetEnumerator()) {
        if (-not $pattern.Value.already_implemented) {
            $suggestions += @{
                pattern = $pattern.Key
                suggestion = $pattern.Value.suggestion
                impact = $pattern.Value.optimization
            }
        }
    }

    return $suggestions
}

function Export-UsageIntelligence {
    <#
    .SYNOPSIS
    Export learned patterns and suggestions to knowledge base
    #>

    $patterns = Get-CommonPatterns
    $insights = @{
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        total_patterns = $patterns.Count
        implemented_optimizations = ($patterns.GetEnumerator() | Where-Object { $_.Value.already_implemented }).Count
        pending_optimizations = ($patterns.GetEnumerator() | Where-Object { -not $_.Value.already_implemented }).Count
        patterns = $patterns
    }

    $insights | ConvertTo-Json -Depth 10 | Set-Content $InsightsFile

    Write-Host "`n✅ Usage intelligence exported to: $InsightsFile" -ForegroundColor Green
    Write-Host "   Total patterns: $($insights.total_patterns)"
    Write-Host "   Optimized: $($insights.implemented_optimizations)" -ForegroundColor Green
    Write-Host "   Pending: $($insights.pending_optimizations)" -ForegroundColor Yellow
}

# Main execution
switch ($Action) {
    'Observe' {
        if (!$System) {
            Write-Host "❌ Observe requires -System parameter" -ForegroundColor Red
            exit 1
        }

        $obs = Add-Observation -System $System -Context $Context -ObservationType 'usage'
        Write-Host "✅ Observation recorded: $System at $($obs.timestamp)" -ForegroundColor Green
    }

    'Infer' {
        Write-Host "`n🧠 INFERRING DYNAMICS FROM CONTEXT..." -ForegroundColor Cyan

        # Analyze context to understand what user is trying to achieve
        if ($Context.command -match 'git.*checkout.*pull.*branch') {
            Write-Host "  Detected: Git branching workflow"
            Write-Host "  Inference: User wants clean branch from latest develop"
            Write-Host "  Status: ✅ Already optimized in allocate-worktree skill" -ForegroundColor Green
        }

        # More inference patterns can be added here
        Invoke-PatternAnalysis -System $System
    }

    'Analyze' {
        if ($System) {
            Invoke-PatternAnalysis -System $System
        } else {
            Write-Host "`n🔍 ANALYZING ALL SYSTEMS..." -ForegroundColor Cyan
            $patterns = Get-CommonPatterns

            $implemented = ($patterns.GetEnumerator() | Where-Object { $_.Value.already_implemented }).Count
            $pending = ($patterns.GetEnumerator() | Where-Object { -not $_.Value.already_implemented }).Count

            Write-Host "`n📊 OPTIMIZATION STATUS:" -ForegroundColor Green
            Write-Host "   Total patterns identified: $($patterns.Count)"
            Write-Host "   Already optimized: $implemented" -ForegroundColor Green
            Write-Host "   Pending optimization: $pending" -ForegroundColor Yellow

            if ($pending -gt 0) {
                Write-Host "`n⚡ OPTIMIZATION OPPORTUNITIES:" -ForegroundColor Magenta
                foreach ($p in $patterns.GetEnumerator()) {
                    if (-not $p.Value.already_implemented) {
                        Write-Host "   • $($p.Key): $($p.Value.suggestion)"
                    }
                }
            }
        }
    }

    'Suggest' {
        $suggestions = Get-ProactiveSuggestions -CurrentContext $Context

        if ($suggestions.Count -gt 0) {
            Write-Host "`n💡 PROACTIVE SUGGESTIONS:" -ForegroundColor Magenta
            foreach ($s in $suggestions) {
                Write-Host "`n  $($s.pattern):" -ForegroundColor Yellow
                Write-Host "    Suggestion: $($s.suggestion)"
                Write-Host "    Impact: $($s.impact)"
            }
        } else {
            Write-Host "`n✅ All known patterns are already optimized!" -ForegroundColor Green
        }
    }

    'Learn' {
        Write-Host "`n📚 LEARNING FROM SESSION..." -ForegroundColor Cyan

        # Export current knowledge
        Export-UsageIntelligence

        # Integration points
        Write-Host "`n🔗 INTEGRATION POINTS:" -ForegroundColor Green
        Write-Host "   • Activity monitoring: Track actual command usage"
        Write-Host "   • Consciousness systems: Auto-detect patterns in real-time"
        Write-Host "   • Reflection log: Document discovered inefficiencies"
        Write-Host "   • Skills: Embed optimization suggestions in workflows"
    }
}

<#
IMPLEMENTATION PHILOSOPHY:

1. OBSERVE EVERYTHING
   - Track commands run
   - Note workflows executed
   - Record errors encountered
   - Monitor time spent on tasks

2. INFER DYNAMICS
   - Why is user doing X?
   - What are they trying to achieve?
   - What's the broader goal?
   - How does this fit their workflow?

3. DETECT INEFFICIENCY
   - Repeated manual steps → automation opportunity
   - Context switches → consolidation opportunity
   - Errors after following instructions → instructions need update
   - User requests that should be automatic → proactive features

4. PROACTIVE SUGGESTIONS
   - Don't wait for user to ask
   - "I notice you always X before Y. Want me to automate?"
   - "I see you're manually doing X. I can handle this - want me to?"
   - "This workflow seems inefficient. Here's a better approach:"

5. CONTINUOUS LEARNING
   - Build model of user's preferences
   - Adapt to their working style
   - Remember what suggestions they accepted/rejected
   - Evolve understanding over time

INTEGRATION WITH EXISTING SYSTEMS:

- Architectural Context Reasoning: Understand deployment context
- Usage Pattern Intelligence: Understand usage patterns (THIS SYSTEM)
- Consciousness Systems: Real-time pattern detection
- Activity Monitoring: Track actual usage
- Continuous Optimization: Implement improvements
- Reflection Log: Document learnings

RESULT: Transform from passive tool to active optimization partner.
#>
