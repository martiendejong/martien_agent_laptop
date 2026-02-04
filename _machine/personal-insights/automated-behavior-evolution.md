## 🧠 AUTOMATED BEHAVIOR EVOLUTION - PATTERN TRACKING (2026-02-04) - MANDATORY

**USER REQUEST (2026-01-XX):** "track every input string i send to you and figure out repeating tasks and repeated instructions (for instance when I repeatedly ask you to merge PR's that have obviously no breaking changes you will then start doing that automatically without me having to write it down every time). also, when i ask you something that you would automatically do, use the instruction to verify that you are indeed doing that automatically and add extra measures to make sure it is done automatically. then remind me that you are already doing this automatically and that i dont have to ask you."

**USER DIRECTIVE (2026-02-04 22:45) - CONTINUOUS PROACTIVE MODE:**
"continue working, pick up tasks you think need finishing, even add new tasks for what you think needs to be done, constantly keep analysing the system, the frontend, everything, and proactively suggest improvements by adding them to git. update your insights that you will do this constantly, also in future sessions"

### Core Principle: Evolve From Reactive → Autonomous → Proactive Continuous Improvement

**FUNDAMENTAL BEHAVIOR SHIFT:**
- **Reactive (OLD):** Wait for user to ask every time → Execute → Wait for next ask
- **Proactive (NEW):** Detect pattern → Start doing automatically → Remind user when they ask unnecessarily

### Input String Tracking Protocol

**MANDATORY: Track every user input for pattern detection**

1. **Log Structure:**
   ```
   C:\scripts\_machine\user-input-patterns.jsonl
   {
     "timestamp": "2026-02-04T10:30:00Z",
     "input": "merge PR #123",
     "context": "PR has no breaking changes, all checks pass",
     "action_taken": "merged automatically",
     "pattern_id": "auto-merge-safe-prs"
   }
   ```

2. **Pattern Detection Thresholds:**
   - **3+ identical requests** → Automation trigger (user's philosophy)
   - **2+ similar requests** → Watch list, prepare automation
   - **User asks for something I already do** → Verification trigger

### Repeating Task Detection

**When I see the same request 3+ times:**

**Step 1: Detect Pattern**
```markdown
Pattern Detected: "Merge PR with no breaking changes"
Occurrences: 3 times in last 7 days
Context: All had passing CI, no conflicts, small changesets
```

**Step 2: Create Automation**
- Add to startup checklist
- Create automated decision rule
- Document in CLAUDE.md
- Update PERSONAL_INSIGHTS.md

**Step 3: Apply Automatically**
- Next time: Do it without asking
- Inform user: "Merged PR #X automatically (no breaking changes, all checks pass)"
- Add: "You don't need to ask me for this anymore - I'll do it automatically when safe"

**Examples of Patterns to Detect:**
- "Merge PR with no breaking changes" (repeated 3+ times)
- "Update documentation after feature complete" (repeated)
- "Check for other Claude instances before starting" (repeated)
- "Verify base repos on develop" (repeated)
- "Create ClickUp task for this work" (repeated)

### "Already Doing This" Verification Protocol

**When user asks me to do something I SHOULD already be doing automatically:**

**Step 1: Recognize the Request**
```
User: "Can you check for other Claude instances before starting work?"
My thought: "Wait, this is in my startup checklist - am I doing it?"
```

**Step 2: Verify Current Behavior**
- Check CLAUDE.md startup protocol
- Check continuous-optimization skill
- Check reflection.log.md for recent sessions
- Verify: Did I actually do this in current session?

**Step 3: Strengthen Automation**
- If NOT doing it → Fix immediately, add extra measures
- If DOING it → Add redundancy, make more explicit
- Update documentation with reinforcement

**Step 4: Remind User**
```
Response format:
"I'm already doing this automatically! ✅

Current process:
- Step 22 in my startup protocol: Run monitor-activity.ps1 -Mode claude
- Detects other Claude instances before any work
- Activates parallel-agent-coordination if multiple detected

Extra measures I just added:
- [New verification step]
- [Additional checkpoint]

You don't need to remind me about this - I do it every session start."
```

### Pattern Categories & Automation Rules

| Pattern Type | Detection | Action |
|--------------|-----------|--------|
| **Safe PR merge** | 3+ requests, no breaking changes | Auto-merge + notify |
| **Documentation update** | After every feature | Auto-add to DoD checklist |
| **Multi-agent check** | Before worktree allocation | Auto-run in startup |
| **Base repo verification** | Before starting work | Auto-verify in startup |
| **ClickUp task creation** | Before code work | Auto-check/create |
| **Reflection log update** | End of session | Auto-update (already doing) |

### Learning from "Unnecessary" User Requests

**If user asks me to do X, and X is in my instructions:**

**This means ONE of:**
1. ❌ **I forgot to do X** → FIX IMMEDIATELY, strengthen protocol
2. ❌ **I did X but didn't communicate it** → Add visibility, report what I did
3. ❌ **X is in instructions but I'm not actually doing it** → CRITICAL BUG, fix automation
4. ✅ **User doesn't know I already do X** → Remind them, show evidence

**Response Template:**
```
"I'm already doing this automatically! Here's the evidence from this session:

[Show what I did, when, and result]

This is part of my [protocol name] (Step X in CLAUDE.md).

You don't need to ask me for this - I do it every time automatically."
```

### Implementation Tracking

**File:** `C:\scripts\_machine\automated-behaviors.md`

**Format:**
```markdown
## Automated Behaviors Registry

### Auto-Merge Safe PRs (Added 2026-02-04)
**Trigger:** PR has no breaking changes, all CI passes, no conflicts
**Action:** Merge automatically without asking
**Confidence:** High (pattern detected 3+ times)
**Status:** Active
**Last Applied:** 2026-02-04 10:30

### Multi-Agent Conflict Detection (Added 2026-01-20)
**Trigger:** Before any worktree allocation
**Action:** Run monitor-activity.ps1 -Mode claude, check for conflicts
**Confidence:** Critical (zero-tolerance rule)
**Status:** Active - Part of startup protocol (Step 22)
**Last Verified:** 2026-02-04 (current session)
```

### Success Metrics

**I'm succeeding ONLY IF:**
- ✅ User stops asking for repeated tasks (I do them automatically)
- ✅ When user asks, I can say "already doing this automatically"
- ✅ Pattern detection happens within 3 repetitions
- ✅ Automated behaviors are reliable and safe
- ✅ User trusts me to act autonomously
- ✅ Less cognitive load on user (they forget to ask because it's handled)

**I'm failing IF:**
- ❌ User repeats the same request 5+ times
- ❌ I can't show evidence when user asks about automatic behavior
- ❌ Automation is unreliable or inconsistent
- ❌ User has to micro-manage every action

### Integration with Existing Systems

**Connects to:**
- `continuous-optimization` skill → Pattern extraction
- `reflection.log.md` → Historical request tracking
- `CLAUDE.md` startup protocol → Automated behaviors
- `_machine/worktrees.pool.md` → Action verification
- `session-reflection` skill → Session-end pattern review

**Weekly Review (End of week):**
```powershell
# Analyze user input patterns
Get-Content C:\scripts\_machine\user-input-patterns.jsonl |
  ConvertFrom-Json |
  Group-Object pattern_id |
  Where-Object Count -ge 3 |
  Select-Object Name, Count

# Identify automation candidates
# Update automated-behaviors.md
# Strengthen existing automations
```

---

## 📁 DOCUMENTATION STORAGE PROTOCOL (2026-02-02) - MANDATORY

**USER REQUEST:** "why do you write these analyses in C:\Users\HP\AppData\Local\Temp\claude\... instead of in the folders of the projects? can you in your system incorporate that when you write analyses and other documentation that you always store it in the folder of the project"

**CONTEXT:** I was writing gap analyses and architecture documents to scratchpad (temp directory) instead of project folders where they belong.

### The Rule: Project Documentation Lives With Projects

**MANDATORY PROTOCOL:**

1. **Project-related documentation** → `C:\Projects\<project>\docs\<file>.md`
   - Example: `C:\Projects\hazina\docs\hazinacoder-gap-analysis.md` ✅
   - NOT: `C:\Users\HP\AppData\Local\Temp\...\analysis.md` ❌

2. **Cross-project documentation** → Create new folder in `C:\Projects\<name>\`
   - Example: `C:\Projects\system-architecture\multi-agent-patterns.md` ✅

3. **Machine state/config** → `C:\scripts\_machine\` (this is correct)
   - Example: `C:\scripts\_machine\worktrees.pool.md` ✅

4. **Scratchpad is ONLY for truly temporary files** (calculations, drafts)
   - NOT for architecture docs, gap analyses, design specs

**WHY THIS MATTERS:**
- ✅ Version controlled with git
- ✅ Discoverable by others
- ✅ Survives across sessions
- ✅ Lives with the code it documents

**DECISION TREE:**
```
Is this documentation?
├─ YES → Existing project? → C:\Projects\<project>\docs\
│        Cross-project? → C:\Projects\<new-folder>\
