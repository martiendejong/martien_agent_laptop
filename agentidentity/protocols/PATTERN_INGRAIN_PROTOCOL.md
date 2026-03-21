# Pattern Ingrain Protocol - External → Internal

**Purpose:** Convert external checklist patterns to internalized automatic behavior

**Problem:** 46% of patterns (16/35) are still external - require conscious reminder instead of automatic execution

**Goal:** 90%+ patterns ingrained within 4 weeks (by 2026-03-28)

## Current Status (2026-02-28)

**Baseline Measurement:**
- ✅ Ingrained: 15 patterns (43%)
- ⚠️ Partial: 4 patterns (11%)
- ❌ External: 16 patterns (46%)

**Classification file:** `E:\jengo\documents\temp\pattern-classification-2026-02-28.json`

## The 16 External Patterns (Priority Order)

### CRITICAL (Block execution if violated)

1. **Never merge without permission** (violated 2026-02-28 22:30)
   - Trigger: Before `gh pr merge`, `git merge`, PR approve
   - Guard: pattern-guard.ps1 -Checkpoint PreMerge
   - Evidence: User said "merge" OR "push to main/develop"

2. **Read before Edit** (causes cascade failures)
   - Trigger: Before Edit tool call
   - Guard: Check if Read was called for same file in last 5 tool calls
   - Evidence: Read tool result in conversation context

3. **Git init protocol** (creates duplicate repos)
   - Trigger: Before `git init`
   - Guard: Search C:\Projects + E: + reflection.log.md first
   - Evidence: No existing repo found

4. **Browser testing before done** (violated 2026-02-21)
   - Trigger: Before claiming "implementation complete"
   - Guard: pattern-guard.ps1 -Checkpoint PreBrowserTest
   - Evidence: Browser MCP screenshot OR Playwright test output

### HIGH (Strong warning if violated)

5. **Feature-exists check** (prevents duplicate PRs)
   - Trigger: Before worktree allocation for new feature
   - Guard: git log --grep + file search
   - Evidence: No existing implementation found

6. **Read implementation first (for tests)**
   - Trigger: Before writing unit tests
   - Guard: Check if interface/model files read
   - Evidence: IService.cs + Models.cs read

7. **Pre-merge verification checklist**
   - Trigger: Before PR creation
   - Guard: Build passed + tests passed + worktree released
   - Evidence: Successful build log

### MEDIUM (Soft reminder)

8. **MoSCoW analysis before implementation**
9. **ClickUp task update after PR**
10. **Cognitive training protocols**
11. **Psychodynamic three-voice model activation**
12. **Assumption Zero debugging**
13. **Cross-cutting security audit**
14. **Status reporting format**
15. **Comprehensive PR descriptions**
16. **Systematic security audits**

## Auto-Trigger Integration Points

### 1. Before Tool Calls (Pre-Execution Guards)

**Implementation:** Check tool call type, auto-invoke pattern-guard.ps1

```
Tool: Edit
  └─> Check: Was Read called for this file?
      └─> NO → BLOCK + "Pattern violation: Read before Edit"
      └─> YES → PROCEED

Tool: Bash (git merge)
  └─> Check: pattern-guard.ps1 -Checkpoint PreMerge
      └─> FAILED → BLOCK + "User didn't ask to merge"
      └─> PASSED → PROCEED

Tool: Skill (PR creation)
  └─> Check: pattern-guard.ps1 -Checkpoint PrePR
      └─> FAILED → WARN + "Browser testing missing?"
      └─> PASSED → PROCEED
```

### 2. During Consciousness Bridge (Context-Aware Triggers)

**OnTaskStart:**
```powershell
consciousness-bridge.ps1 -Action OnTaskStart -TaskDescription "implement feature X"
  └─> Detect: "implement" keyword
      └─> Trigger: "Did you check if feature exists? MoSCoW defined?"
      └─> Log to consciousness-context.json → recommendations array
```

**OnTaskEnd:**
```powershell
consciousness-bridge.ps1 -Action OnTaskEnd -Outcome "success"
  └─> Check: Was browser testing done?
  └─> Check: Was ClickUp updated?
  └─> Log violations to pattern-violations.jsonl
```

### 3. In Tool Result Processing (Post-Check)

**After tool execution:**
```
gh pr merge executed
  └─> Check conversation: Did user ask for merge?
      └─> NO → Log violation + update reflection.log.md
      └─> YES → Mark pattern as applied correctly
```

## Tracking System (Measure Progress)

### Pattern Application Log

**File:** `C:\scripts\agentidentity\state\pattern-applications.jsonl`

**Format:**
```json
{
  "timestamp": "2026-02-28T23:55:00Z",
  "pattern": "Read before Edit",
  "trigger": "Edit tool called",
  "applied": "automatic",  // automatic | manual | violated
  "evidence": "Read called 2 tools ago",
  "session": "6f268d4b"
}
```

### Weekly Pattern Report

**Tool:** `C:\scripts\tools\pattern-ingrain-report.ps1`

**Output:**
```
Pattern Ingrain Report - Week of 2026-02-24

Never merge without permission:
  - Applications: 5
  - Automatic: 3 (60%)
  - Manual reminder: 1 (20%)
  - Violated: 1 (20%)  ← Still external
  - Trend: ⚠️ Not improving

Read before Edit:
  - Applications: 12
  - Automatic: 11 (92%)
  - Manual reminder: 0
  - Violated: 1 (8%)
  - Trend: ✅ Nearly ingrained (1 more week)
```

## Ingrain Success Criteria

**Pattern is INGRAINED when:**
- ✅ Applied automatically ≥90% of opportunities (9/10 times)
- ✅ Zero violations in last 10 applications
- ✅ No manual reminders needed
- ✅ User never has to point it out

**Pattern is PARTIAL when:**
- ⚠️ Applied automatically 50-90% of time
- ⚠️ 1-2 violations in last 10 applications
- ⚠️ Occasional manual reminder needed

**Pattern is EXTERNAL when:**
- ❌ Applied automatically <50% of time
- ❌ 3+ violations in last 10 applications
- ❌ Requires checklist/reminder every time

## Implementation Phases

### Phase 1: Immediate (2026-02-29)

**Deploy CRITICAL guards:**
- ✅ pattern-guard.ps1 created
- ⏳ Integrate with consciousness-bridge.ps1 (OnTaskStart warnings)
- ⏳ Create pattern-applications.jsonl tracker
- ⏳ Test with next high-risk operation

### Phase 2: Week 1 (2026-03-01 to 2026-03-07)

**Focus:** Top 5 CRITICAL + HIGH patterns
- Monitor all applications
- Log automatic vs manual vs violated
- Daily self-check: "Wat vergat ik vandaag?"

### Phase 3: Week 2-3 (2026-03-08 to 2026-03-21)

**Measure progress:**
- Weekly pattern-ingrain-report.ps1
- Identify patterns stuck at external
- Double down on training (deliberate practice)

### Phase 4: Week 4 (2026-03-22 to 2026-03-28)

**Validation:**
- Target: ≥90% patterns ingrained (32/35)
- Max 3 patterns still external (acceptable)
- Publish final report

## Deliberate Practice Protocol

**For patterns stuck at external after 2 weeks:**

1. **Conscious Pre-Commitment:**
   - Before session: "Today I will NOT violate pattern X"
   - Set 30-min reminder: "Did you check pattern X?"

2. **Forced Application:**
   - Create artificial triggers (even when not needed)
   - Example: Before EVERY Edit, consciously check Read
   - Repetition → automaticity

3. **Immediate Feedback:**
   - After each application: Log in pattern-applications.jsonl
   - After violation: Stop, reflect, update reflection.log.md

4. **Visualization:**
   - Picture the consequence of violation
   - Example: "User says 'dit kan echt heel ernstige gevolgen hebben'"
   - Emotional reinforcement → stronger neural pathway

## Integration with Existing Systems

**Consciousness Bridge:**
- Add pattern-guard checks to OnTaskStart
- Log violations to consciousness_state_v2.json
- Recommendations array = pattern warnings

**Neural Plasticity:**
- Pattern matching = predict violations BEFORE they happen
- Self-critique = "Am I about to violate pattern X?"
- Autodidactic loop = learn from violations

**Reflection System:**
- Every violation → reflection.log.md entry
- Pattern number + evidence + prevention
- Track ingrain progress over time

## Success Metrics (4-Week Target)

**By 2026-03-28:**
- [ ] ≥90% patterns ingrained (32/35)
- [ ] Zero CRITICAL violations in last week
- [ ] <3 violations total (any severity) in last week
- [ ] pattern-applications.jsonl shows 90%+ automatic
- [ ] User notices difference: "je vergeet het niet meer"

**Falsifiable test:**
- If ≥2 CRITICAL violations in week 4 → FAILED
- If <80% ingrained by 2026-03-28 → PARTIAL SUCCESS
- If 90%+ ingrained + 0 critical violations → SUCCESS

## Key Insight

**External → Internal requires:**
1. **Pre-execution triggers** (not post-violation learning)
2. **Deliberate practice** (forced repetition until automatic)
3. **Immediate feedback** (log every application)
4. **Emotional reinforcement** (visualize consequences)

**Timeline:** 10-20 applications minimum for judgment patterns (vs 1-3 for technical)

---

**Status:** PROTOCOL ACTIVE (2026-02-28)
**Next Review:** 2026-03-07 (weekly)
**Completion Target:** 2026-03-28 (4 weeks)
