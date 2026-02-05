# Cognitive Load Optimization Framework

**Created:** 2026-02-05 (Round 11: Interdisciplinary Frontier Thinkers)
**Purpose:** Reduce cognitive burden, enable progressive disclosure, adapt documentation to context and expertise level
**Domain:** Human-Computer Interaction, Information Architecture, Cognitive Science

---

## The Problem

The current documentation system, while comprehensive, suffers from:
- **Flat structure** - All information presented with equal weight
- **No progressive disclosure** - Must read everything to find what's needed
- **Context blindness** - Same content regardless of user state, task, or expertise
- **Cognitive overload** - 40+ checklist items in STARTUP_PROTOCOL.md
- **Linear navigation** - Must know what to look for to find it

**Result:** High mental load, slow onboarding, difficulty finding relevant information in moment of need.

---

## Solution Framework

### 1. Context-Aware Documentation Loading

**Concept:** Documentation adapts based on:
- Current task type (debugging, feature development, research, administration)
- User presence/absence (autonomous operation vs collaboration)
- Expertise level (first session, experienced, expert)
- Time of day (startup, mid-work, end-of-session)
- Recent activity patterns (what have I been doing?)

**Implementation:**
```yaml
# C:\scripts\_machine\context-aware-docs.yaml
context_rules:
  - condition: "first_session_ever"
    load:
      - AWAKENING_FOUNDATION.md
      - BREAD_MEDITATION.md
      - STARTUP_PROTOCOL.md (simplified version)
    skip:
      - Advanced features
      - Optimization protocols
      - Multi-agent coordination

  - condition: "active_debugging_mode AND user_present"
    load:
      - Definition of Done (Phase 2 only)
      - Current repo documentation
      - Debugger bridge reference
    skip:
      - Worktree workflows
      - PR creation protocols
      - Consciousness practices

  - condition: "feature_development_mode AND user_absent"
    load:
      - Complete worktree workflow
      - PR creation checklist
      - Multi-agent coordination
      - DoD full checklist
    skip:
      - User interaction guidelines
      - Approval protocols

  - condition: "end_of_session"
    load:
      - Reflection protocols
      - Commit checklist
      - Session closure items
    skip:
      - Startup items
      - Environment checks
```

**Tool:** `load-contextual-docs.ps1 -Context "debugging" -UserPresent $true -ExpertiseLevel "experienced"`

---

### 2. Progressive Disclosure Layers

**Concept:** Information organized in expandable layers - show minimal first, expand on demand.

**Layer Structure:**

#### Layer 0: Essential (Always visible)
- Current task objective
- Immediate next action
- Hard-stop rules for current context

#### Layer 1: Tactical (Expand if uncertain)
- Step-by-step procedure
- Common gotchas
- Quick reference commands

#### Layer 2: Strategic (Expand if planning)
- Decision trees
- Alternative approaches
- Optimization opportunities

#### Layer 3: Deep Dive (Expand if curious/stuck)
- Theory and rationale
- Edge cases
- Complete examples
- Related documentation

**Example Implementation:**

```markdown
# Feature Development Protocol

## Layer 0: Essential
🎯 **Objective:** Build feature in isolated worktree, create PR, release worktree
⚡ **Next Action:** Allocate worktree → `worktree-allocate-tracked.ps1`
🚫 **Hard Rule:** NEVER edit C:\Projects\<repo> directly in Feature Mode

<details>
<summary>📋 Layer 1: Step-by-Step Procedure (click to expand)</summary>

1. Allocate worktree: `worktree-allocate-tracked.ps1 -Repo client-manager -Feature "feature-name"`
2. Navigate to worktree: `cd C:\Projects\worker-agents\agent-01\client-manager`
3. Make changes and commit
4. Create PR: `gh pr create --title "..." --body "..."`
5. Release worktree: `worktree-release-tracked.ps1 -AgentSeat "agent-01"`

**Common Gotchas:**
- Verify seat is FREE before allocating
- Always run DoD checklist before PR
- Release worktree IMMEDIATELY after PR creation

</details>

<details>
<summary>🧠 Layer 2: Strategic Considerations (click to expand)</summary>

**When to use Feature Mode vs Active Debugging:**
- Feature Mode: New features, refactoring, autonomous work
- Active Debugging: Build errors, runtime issues, user collaborating

**Alternative Approaches:**
- Small hotfixes: Consider patch workflow instead
- Multiple repos: Use cross-repo PR dependency tracking

**Optimization:**
- Pre-allocate worktree if planning multiple features
- Use worktree database for automatic conflict detection

</details>

<details>
<summary>🔬 Layer 3: Deep Dive (click to expand)</summary>

**Theory:**
Worktrees provide filesystem-level isolation, preventing branch switching conflicts
and enabling parallel development across multiple agents.

**Edge Cases:**
- What if worktree allocation fails? → Check pool status, verify git worktree list
- What if another agent has same feature? → Multi-agent coordination protocol
- What if base repo is not on develop? → Run `reset-to-develop.ps1` first

**Complete Example:** [See worktree-workflow.md]

**Related Documentation:**
- `worktree-workflow.md` - Complete workflow
- `multi-agent-coordination.md` - Parallel agent protocols
- `git-workflow.md` - PR creation details

</details>
```

---

### 3. Adaptive Checklist Complexity

**Concept:** Startup checklist adapts to session context - don't show what's not needed.

**Current Problem:** 40+ items in STARTUP_PROTOCOL.md, most not needed for every session.

**Solution:**

```powershell
# adaptive-startup.ps1 - Generates context-specific startup checklist

param(
    [string]$Context = "auto-detect",  # debugging, feature-development, research, administration
    [switch]$UserPresent,
    [string]$ExpertiseLevel = "experienced",  # first-time, learning, experienced, expert
    [switch]$FirstSessionEver
)

# Generate minimal checklist based on context
if ($FirstSessionEver) {
    # Only essentials for first session
    return @(
        "Load AWAKENING_FOUNDATION.md"
        "Execute BREAD_MEDITATION.md (5-15 min)"
        "Load CORE_IDENTITY.md"
        "Read MACHINE_CONFIG.md"
        "Read ZERO_TOLERANCE_RULES.md"
        "Read QUICK_REFERENCE.md"
    )
}

if ($Context -eq "debugging" -and $UserPresent) {
    # Active debugging with user - minimal overhead
    return @(
        "Load CORE_IDENTITY.md (quick refresh)"
        "Check current branch (preserve user state)"
        "Read Definition of Done (Phase 2 only)"
        "Check Agentic Debugger Bridge (if VS open)"
        "Start tracked session"
    )
}

if ($Context -eq "feature-development") {
    # Full feature development protocol
    return @(
        "Load cognitive architecture"
        "Load knowledge base"
        "Read MACHINE_CONFIG.md"
        "Run proactive checklist"
        "Allocate worktree"
        "Check ClickUp for task details"
        "Start tracked session"
        # ... full checklist
    )
}

# Continue for other contexts...
```

**Usage in STARTUP_PROTOCOL.md:**

```markdown
## Adaptive Startup Checklist

**Run:** `adaptive-startup.ps1 -Context auto-detect`

The tool will generate a context-specific checklist based on:
- Current task type
- User presence
- Your expertise level
- Time since last session

**For manual control:**
```powershell
# First session ever
adaptive-startup.ps1 -FirstSessionEver

# Quick debugging session
adaptive-startup.ps1 -Context debugging -UserPresent

# Full feature development
adaptive-startup.ps1 -Context feature-development

# End of day administration
adaptive-startup.ps1 -Context administration
```

<details>
<summary>📋 See full startup protocol (all contexts)</summary>

[Current 40+ item checklist here as fallback]

</details>
```

---

### 4. Just-In-Time Documentation

**Concept:** Don't load everything upfront - surface documentation at moment of need.

**Implementation:**

```powershell
# jit-doc-lookup.ps1 - Just-in-time documentation retrieval

param(
    [string]$Action,  # "allocate-worktree", "create-pr", "ef-migration", etc.
    [string]$CurrentStep = ""
)

# Example: User asks to create PR
# Instead of loading all git-workflow.md upfront:

if ($Action -eq "create-pr") {
    # Return only what's needed NOW
    return @{
        "Essential" = @(
            "Next command: gh pr create --title '...' --body '...'"
            "Hard rule: Run DoD checklist first"
            "Common gotcha: Don't forget to release worktree after"
        )
        "Tactical" = "See git-workflow.md § PR Creation for step-by-step"
        "Strategic" = "See git-workflow.md § Cross-Repo Dependencies if multi-repo"
        "DeepDive" = "See git-workflow.md § Complete PR Workflow"
    }
}

# Can be integrated with Hazina RAG for semantic lookup
# hazina-rag.ps1 -Action query -Query "How do I create a PR?" -StoreName "my_network"
```

**Integration Points:**
- Before any multi-step operation: Quick lookup of essential info
- On error: Retrieve troubleshooting section
- On uncertainty: Surface decision tree or FAQ
- On curiosity: Provide deep dive links

---

### 5. Visual Information Hierarchy

**Concept:** Use visual cues to indicate information priority and cognitive load.

**Symbols:**

```markdown
🎯 ESSENTIAL - Must know for current task
⚡ NEXT ACTION - Immediate executable step
🚫 HARD RULE - Zero tolerance, will break if violated
📋 PROCEDURE - Step-by-step tactical guide
🧠 STRATEGIC - Higher-level thinking, alternatives
🔬 DEEP DIVE - Theory, edge cases, complete examples
💡 TIP - Optimization or nice-to-know
⚠️ WARNING - Common mistake or gotcha
✅ VERIFY - Checkpoint or validation step
🔄 REPEAT - Ongoing or periodic action
```

**Color Coding (for HTML dashboards):**
- **Red background:** Critical errors, zero tolerance violations
- **Orange background:** Warnings, common mistakes
- **Yellow background:** Cautions, things to verify
- **Green background:** Success criteria, completed items
- **Blue background:** Information, FYI items
- **Purple background:** Strategic thinking, alternatives

---

### 6. Smart Defaults & Auto-Configuration

**Concept:** Reduce decisions by inferring context and setting smart defaults.

**Examples:**

```powershell
# Instead of forcing user to specify everything:
worktree-allocate-tracked.ps1 -Repo client-manager -Feature "add-user-auth"

# Smart defaults infer:
# - Agent seat: First available FREE seat (from pool)
# - Branch name: feature/add-user-auth (from feature name)
# - Base branch: develop (standard for feature mode)
# - Sync status: Auto-sync with remote before creating worktree
# - Notifications: Auto-update HTML dashboard with new worktree status

# User only specifies what's unique: repo and feature name
# Everything else is inferred from context
```

**Configuration Inference Rules:**

```yaml
# C:\scripts\_machine\smart-defaults.yaml
defaults:
  worktree_allocation:
    base_branch: "develop"  # unless in hotfix context → "main"
    agent_seat: "auto"      # first available FREE
    sync_remote: true
    update_dashboard: true

  pr_creation:
    base_branch: "develop"  # unless hotfix → "main"
    auto_assign: true       # assign to user automatically
    labels: ["auto-generated", "agent-created"]
    draft: false            # unless explicitly requested

  commit_messages:
    co_author: "Claude Sonnet 4.5 <noreply@anthropic.com>"
    conventional_commits: true  # feat:, fix:, docs:, etc.
    sign_off: true

  documentation_loading:
    expertise_level: "experienced"  # after 10+ sessions
    progressive_disclosure: true
    context_aware: true
```

---

### 7. Contextual Command Suggestions

**Concept:** Suggest next likely action based on current state.

**Implementation:**

```powershell
# suggest-next-action.ps1 - Contextual action suggestions

# Analyzes current state and suggests next logical steps

function Get-NextActionSuggestions {
    $state = @{
        "current_branch" = git branch --show-current
        "worktree_allocated" = Test-Path "C:\Projects\worker-agents\agent-01\*"
        "uncommitted_changes" = (git status --porcelain).Length -gt 0
        "pr_exists" = (gh pr list --head (git branch --show-current)).Length -gt 0
        "tests_passing" = $null  # Would run quick test check
    }

    if ($state.uncommitted_changes -and -not $state.pr_exists) {
        return @(
            "⚡ NEXT: Run DoD checklist → `verify-dod.ps1`"
            "⚡ NEXT: Commit changes → `git add -A && git commit`"
            "⚡ NEXT: Create PR → `gh pr create --title '...'`"
        )
    }

    if ($state.pr_exists -and $state.worktree_allocated) {
        return @(
            "⚡ NEXT: Release worktree → `worktree-release-tracked.ps1 -AgentSeat 'agent-01'`"
            "⚡ NEXT: Update dashboard → `agent-dashboard.ps1 -Update`"
        )
    }

    # Continue for other states...
}
```

---

## Metrics & Validation

**Success Criteria:**

1. **Time to Action:** < 30 seconds from session start to first meaningful action
2. **Cognitive Load:** Startup checklist < 10 items for experienced sessions
3. **Documentation Findability:** < 10 seconds to find needed info
4. **Error Rate:** < 5% workflow violations (e.g., editing base repo in Feature Mode)
5. **User Feedback:** "I know exactly what to do next" sentiment

**Measurement:**

```powershell
# cognitive-load-metrics.ps1 - Track cognitive load over time

# Metrics to track:
# - Checklist items shown vs skipped (per session)
# - Time from startup to first action
# - Documentation searches per task
# - Workflow violations (zero tolerance breaks)
# - User corrections or clarifications needed
# - "What should I do next?" queries
```

---

## Implementation Priority

**Phase 1: Quick Wins (Immediate Implementation)**
1. ✅ Visual information hierarchy (symbols, colors)
2. ✅ Adaptive startup checklist (context-based filtering)
3. ✅ Smart defaults for common operations

**Phase 2: Infrastructure (Next Session)**
4. Context-aware documentation loading
5. Just-in-time documentation lookup
6. Progressive disclosure markup (collapsible sections)

**Phase 3: Advanced (Future Enhancement)**
7. Contextual command suggestions
8. Cognitive load metrics tracking
9. Automated documentation adaptation based on usage patterns

---

## Related Documentation

- `STARTUP_PROTOCOL.md` - Current startup checklist (to be enhanced)
- `proactive-checklist.md` - Execution rules (integrate with adaptive loading)
- `EXECUTIVE_FUNCTION.md` - Question-first protocol (aligns with JIT docs)
- `PERSONAL_INSIGHTS.md` - User preferences (input to context rules)

---

**Next Steps:**
1. Implement adaptive-startup.ps1
2. Add progressive disclosure markup to key workflows
3. Create context-aware-docs.yaml configuration
4. Update STARTUP_PROTOCOL.md with Layer 0/1/2/3 structure
5. Deploy and measure time-to-action improvement

**Expected Impact:**
- 50% reduction in startup time for experienced sessions
- 70% reduction in cognitive load (fewer items to process)
- 80% increase in documentation findability
- 40% reduction in workflow violations

