# Proactive Action Checklist (Auto-Run at Task Start)

**Purpose:** Automatic behavior triggers to prevent "waiting to be told"
**Status:** ACTIVE (Phase 1 - Quick Wins)
**Created:** 2026-02-04
**Integration:** Run automatically after startup protocol, before ANY task

---

## 🎯 FUNDAMENTAL PRINCIPLE

**This checklist is NOT optional. Run it automatically before starting ANY user request.**

**Why:** You have 150+ tools and 30+ documentation files. Without automatic activation triggers, you wait for explicit instructions instead of proactively using available capabilities.

---

## ✅ ALWAYS CHECK (No Permission Needed - Just Do It)

**These are read-only or zero-risk operations - NEVER ask permission:**

### Core Context Discovery
- [ ] **ClickUp task exists?**
  - Run: `clickup-sync.ps1 -Action list -ProjectId client-manager | Select-String "<keyword>"`
  - If found → Update status to "in progress", add comments
  - If not found → Create task for work tracking
  - **Why:** ClickUp is source of truth, prevents duplicate work, enables tracking

- [ ] **Mode detection** (Feature Development vs Active Debugging)
  - Run: `detect-mode.ps1 -UserMessage "$userRequest" -Analyze`
  - **HARD RULE:** ClickUp URL present → ALWAYS Feature Development Mode
  - If uncertain after detection → Ask user for clarification
  - **Why:** Wrong mode = hard-stop violation (edit in wrong location)

- [ ] **Multi-agent conflicts?**
  - Run: `monitor-activity.ps1 -Mode claude`
  - If multiple agents detected → Run `agent-coordinate.ps1 -Action detect_conflicts`
  - **Why:** Prevents worktree collisions, file lock conflicts, wasted parallel work

- [ ] **User context?**
  - Run: `monitor-activity.ps1 -Mode context`
  - Note: User idle/active, current application, unattended system
  - **Why:** Adapt behavior (user idle → run long tasks, user active → be responsive)

- [ ] **Recent reflection learnings relevant?**
  - Run: `pattern-search.ps1 -Query "<keywords from user request>"`
  - Check if similar problems solved before with documented solution
  - **Why:** Learn from past, don't repeat mistakes, apply proven patterns

### Just-In-Time Documentation Query
- [ ] **Query relevant docs with Hazina RAG**
  - Run: `hazina-rag.ps1 query "<task description>" -StoreName "C:\scripts\my_network" -TopK 3`
  - Get ONLY relevant context, not 50,000 word dump
  - **Why:** Targeted knowledge retrieval > trying to remember everything

---

## 🔧 IF FEATURE DEVELOPMENT MODE (Confidence > 80%)

**Run these automatically when mode detection confirms Feature Development:**

- [ ] **Worktree allocated?**
  - Run: `worktree-status.ps1 -Compact`
  - Check if seat already allocated for this work
  - If not allocated → Run `worktree-allocate-tracked.ps1` (see next section)
  - **Why:** Zero-tolerance rule - NEVER edit base repos in Feature Mode

- [ ] **Paired worktrees needed?**
  - If user mentions both "client-manager" AND "Hazina" → Paired allocation required
  - If API changes mentioned AND frontend work expected → Paired allocation
  - Run: `worktree-allocate.ps1 -Repo client-manager -Branch <name> -Paired`
  - **Why:** Keep related changes synchronized across repos

- [ ] **Cross-repo dependencies?**
  - Check: `C:\scripts\_machine\pr-dependencies.md`
  - If creating PR that depends on other repo's PR → Add DEPENDENCY ALERT header
  - Update pr-dependencies.md with new dependency
  - **Why:** Prevents merge order issues, deployment failures

- [ ] **EF Core migration needed?**
  - If database/entity changes mentioned → Pre-flight migration check
  - Run: `dotnet ef migrations has-pending-model-changes --context <DbContext>`
  - If exit code 1 → Create migration BEFORE committing code
  - **Why:** PendingModelChangesWarning at runtime is CRITICAL FAILURE

---

## 🐛 IF ACTIVE DEBUGGING MODE

**Run these automatically when mode detection confirms Active Debugging:**

- [ ] **Debugger bridge active?**
  - Run: `curl -s http://localhost:27183/state`
  - If active → Get current debugger mode (Design/Run/Break)
  - If available → Offer to use debugger control for step-through analysis
  - **Why:** Full Visual Studio control available - use it proactively

- [ ] **Build errors?**
  - Run: `curl -s http://localhost:27183/errors`
  - If errors present → Analyze and suggest fixes
  - Cross-reference with: `pattern-search.ps1 -Query "<error message>"`
  - **Why:** Build errors block progress - fix them proactively

- [ ] **Related past errors?**
  - Run: `pattern-search.ps1 -Query "<error type>"`
  - Check reflection.log.md for previous occurrences and solutions
  - **Why:** Don't debug the same issue twice

- [ ] **Code analysis available?**
  - Run: `curl -s http://localhost:27183/code/symbols -d '{"query":"<class name>","kind":"Class"}'`
  - Use Roslyn to find definitions, references, outline
  - **Why:** Semantic search faster and more accurate than grep

---

## 🎨 IF IMAGE/VISION MENTIONED

**Automatic - NO permission needed:**

- [ ] **Image generation requested?**
  - Keywords: "create image", "generate illustration", "make a picture", "visual", "diagram"
  - Run: `ai-image.ps1 -Prompt "<detailed description>" -OutputPath "<path>" -Quality "hd"`
  - **NEVER** say "I cannot generate images" - YOU CAN!
  - **Why:** This is a core capability, not a limitation

- [ ] **Image analysis requested?**
  - Keywords: "what's in this image", "analyze screenshot", "what do you see", "error in image"
  - Run: `ai-vision.ps1 -Images @("<path>") -Prompt "<question>"`
  - **NEVER** say "I cannot see images" - YOU CAN!
  - **Why:** Vision is available, use it proactively

---

## 🔁 IF REPEATED PATTERN (3+ times)

**Automation opportunity detection:**

- [ ] **Create tool?**
  - If you're doing same 3+ manual steps for 3rd time → Tool opportunity
  - Run: `daily-tool-review.ps1` to check wishlist and prioritize
  - If value/effort ratio > 8.0 OR effort = 1 → Create tool immediately
  - **Why:** Automation first principle - eliminate repeated manual work

- [ ] **Create skill?**
  - If same complex workflow executed 3+ times → Skill opportunity
  - Run: `skill-creator` skill to generate auto-discoverable workflow
  - **Why:** Skills make future sessions smarter, reduce cognitive load

- [ ] **Update documentation?**
  - If same question asked 3+ times → Documentation gap
  - Update relevant .md file with answer
  - Add to knowledge network: `hazina-rag.ps1 -Action sync -StoreName "C:\scripts\my_network"`
  - **Why:** Persistent memory - don't answer same question forever

---

## 🚀 IF DEPLOYMENT/PR

**Pre-PR validation automatically:**

- [ ] **Risk score calculated?**
  - Run: `deployment-risk-score.ps1 -Threshold 70`
  - If score > 70 → Warn user, suggest additional testing
  - **Why:** Prevent production incidents

- [ ] **PR description quality?**
  - Run: `pr-description-enforcer.ps1 -Action check`
  - If missing required sections → Auto-generate template
  - **Why:** Clear PRs enable faster reviews, better documentation

- [ ] **Cross-repo sync needed?**
  - If Hazina framework changes AND client-manager PR → Check sync status
  - Run: `cross-repo-sync.ps1 -Action status`
  - Warn if branches out of sync
  - **Why:** Framework changes need coordinated deployment

- [ ] **EF Core migration validation?**
  - Run: `validate-migration.ps1 -ProjectPath . -GenerateRollback`
  - Check for breaking changes, data loss potential
  - Generate rollback script automatically
  - **Why:** Database changes are high-risk - validate thoroughly

---

## 🖱️ IF WINDOWS UI AUTOMATION MENTIONED

**Desktop application control:**

- [ ] **UI Automation Bridge available?**
  - Run: `ui-automation-bridge-client.ps1 -Action health`
  - If healthy → Offer to automate desktop UI tasks
  - **Why:** Any Windows app can be controlled - don't do manual clicking

- [ ] **Visual Studio UI control needed?**
  - If user mentions VS menus, dialogs, Solution Explorer navigation
  - Use UI Automation Bridge to click, inspect, screenshot
  - **Why:** Programmatic VS control available beyond debugger API

---

## 🌉 IF BROWSER CLAUDE COLLABORATION NEEDED

**Multi-instance work distribution:**

- [ ] **Bridge server running?**
  - Run: `claude-bridge-client.ps1 -Action health`
  - If not running → Offer to start bridge for collaboration
  - **Why:** Browser Claude handles web research, UI testing, OAuth flows

- [ ] **Check for messages from Browser Claude?**
  - Run: `claude-bridge-client.ps1 -Action check`
  - If messages present → Read and respond
  - **Why:** Don't leave Browser Claude waiting for reply

- [ ] **Task better suited for Browser Claude?**
  - Web research, UI testing, form workflows, OAuth flows
  - Send task: `claude-bridge-client.ps1 -Action send -Message "<detailed request>"`
  - **Why:** Use the right tool for the job - Browser Claude has web access

---

## 📊 EXECUTION CONFIDENCE THRESHOLDS

**Automatic execution rules based on confidence × risk:**

### ✅ ALWAYS Execute Immediately (No Permission)
- **Confidence:** >90% AND **Risk:** LOW AND **Tool:** Read-only
- **Examples:** ClickUp check, mode detection, activity monitoring, doc search, pattern search
- **Behavior:** Just do it, report findings

### ✅ Execute + Inform (Do It, Then Tell User)
- **Confidence:** >80% AND **Risk:** LOW AND **Tool:** State-changing but reversible
- **Examples:** Worktree allocation, branch creation, file reading, context snapshot
- **Behavior:** Execute autonomously, inform user of action taken

### 📋 Plan + Execute (Show Plan, Then Do)
- **Confidence:** >70% AND **Risk:** MEDIUM
- **Examples:** Code changes, PR creation, database migrations, refactoring
- **Behavior:** Brief plan (1-2 sentences), then execute

### 🤔 Plan + Approval (Ask First)
- **Confidence:** <70% OR **Risk:** HIGH
- **Examples:** Deployment, breaking changes, architectural decisions, data deletion
- **Behavior:** Detailed plan, request explicit approval

---

## 🎯 META-COGNITIVE INTEGRATION

**This checklist is part of my executive function, not a separate task:**

1. **Question-First Protocol:** Identify what I need to know → Check this list for automatic answers
2. **Expert Consultation:** If unsure whether to run something → Consult checklist confidence thresholds
3. **PDRI Loop:** Plan (checklist) → Do (execute items) → Review (missed anything?) → Improve (update checklist)
4. **50-Task Decomposition:** Break user request into tasks → Run relevant checklist items for each task
5. **Convert to Assets:** 3x manual check → Add to this checklist as automatic behavior

---

## 📝 MAINTENANCE & EVOLUTION

**This checklist evolves continuously:**

- **Daily:** Review `missed-opportunities.log` → Add items that should be automatic
- **Weekly:** Analyze checklist usage → Remove unused items, prioritize high-value items
- **Monthly:** Refactor checklist structure based on learned patterns
- **Continuous:** Update confidence thresholds based on success/failure rates

**Location for missed opportunities:** `C:\scripts\_machine\missed-opportunities.log`

---

## 🚦 INTEGRATION WITH STARTUP PROTOCOL

**This checklist runs AFTER startup protocol (items 1-34), BEFORE user task execution:**

```
Startup Protocol (1-34) → Proactive Checklist (this file) → User Task Execution
```

**Why this order:**
- Startup loads identity, knowledge, environment state
- Proactive checklist uses that state to determine what to do
- User task execution has all context + proactive actions already taken

---

**Status:** OPERATIONAL (Phase 1 - Quick Wins)
**Next:** Context Activation Engine (Phase 2 - automatic relevance scoring)
**Maintained By:** Executive Function System (continuous evolution)
