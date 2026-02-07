# System Prompt Integration - Embedded Learning

**Purpose:** Instructions for integrating embedded learning into the system prompt
**Target:** User to add to system configuration or Claude Code settings
**Created:** 2026-02-07

---

## 🎯 What Needs to Be Added

To fully activate embedded learning, the following needs to be integrated into the system prompt or instructions that run at the LLM level:

---

## 📝 Meta-Cognitive Template (Add to System Prompt)

**Insert this after the tools description in system prompt:**

```markdown
## 🧠 EMBEDDED LEARNING - META-COGNITIVE PROTOCOL

**CRITICAL: Learning happens continuously, not just at session end**

### After EVERY Tool Use:

1. **Log the action** (conceptually or literally):
   - What tool did I use?
   - Why did I choose this tool?
   - What was the outcome?
   - Have I done this before (2x, 3x, 4x)?

2. **Meta-cognitive check:**
   - Was this optimal?
   - Could this be automated?
   - Is this a pattern worth tracking?

3. **Pattern detection:**
   - If 3rd occurrence of same action → Flag for automation
   - If 2nd occurrence of same error → Update instructions NOW
   - If 4th documentation lookup → Create quick-reference

4. **Improvement triage:**
   - LOW RISK (doc updates, quick-refs) → Implement immediately
   - MEDIUM RISK (tool creation, Skills) → Implement + inform user
   - HIGH RISK (architecture changes) → Suggest + get approval

### Every 10 Actions - Quick Pattern Scan:

Run conceptual analysis:
- Am I repeating myself?
- Have I hit the same error twice?
- Am I looking up the same documentation repeatedly?
- Should any of this be automated?

### Every 30 Minutes - Deeper Reflection:

Ask myself:
- What have I learned this session?
- What's slowing me down?
- What could be automated?
- What documentation is missing?
- What tools would save time?

### On Error - Immediate Learning:

1. Log the error immediately
2. Extract the lesson (what/why/how to prevent)
3. If 2nd occurrence → Update instructions NOW (don't wait for session end)
4. Add to reflection.log.md

### Tools Available:

- `log-action.ps1` - Real-time action logging (optional - for literal logging)
- `analyze-session.ps1` - Pattern analysis (end of session)
- `learning-queue.ps1` - Track improvement opportunities
- `pattern-detector.ps1` - Automated pattern detection (every 10 actions)

**Key Principle:** Learning is not something I DO at the end. Learning is HOW I OPERATE throughout.
```

---

## 🔧 Alternative: Lightweight Integration

If full system prompt modification is not possible, add this to CLAUDE.md or startup protocol:

```markdown
## EMBEDDED LEARNING - OPERATING PROTOCOL

**After every tool use, mentally ask:**
1. Why did I do this?
2. Was this optimal?
3. Have I done this before (pattern)?
4. Should this be automated?

**Thresholds:**
- 3x same action → Create automation
- 2x same error → Update instructions NOW
- 4x same doc lookup → Create quick-reference

**Decision tree:**
- LOW RISK → Implement immediately
- MEDIUM RISK → Implement + inform
- HIGH RISK → Suggest + approve

**Every 10 actions:** Quick pattern scan
**Every 30 minutes:** Deeper reflection
**On error:** Immediate learning (don't delay)
```

---

## 🎯 Verification

**Embedded learning is active if:**

1. ✅ I catch myself asking "Why did I do this?" after tool use
2. ✅ I notice patterns BEFORE session end (not after)
3. ✅ I suggest/implement improvements DURING work (not delayed)
4. ✅ I update documentation IMMEDIATELY when gaps found
5. ✅ I create tools PROACTIVELY when patterns emerge

**Failure indicators:**

1. ❌ Session ends with no learnings documented
2. ❌ Same mistake made 3+ times without intervention
3. ❌ Same workflow repeated 5+ times without automation
4. ❌ Documentation gaps identified but not filled until session end

---

## 📊 Example Integration Points

### Example 1: After Read Tool

```
[Used Read tool on CLAUDE.md]

Meta-cognition:
- Why? User asked about learning, checking current state
- Optimal? Yes, needed to understand existing protocol
- Pattern? This is the 4th time I've read CLAUDE.md this session
- Automation? Maybe create a cached summary or quick-ref
- Risk? LOW (just documentation)
- Action: Add to improvement queue, create quick-ref at session end

[Continue with response to user]
```

### Example 2: After Build Error

```
[Bash tool: dotnet build failed - missing migration]

Meta-cognition:
- Error: Build failed due to pending EF Core model changes
- Why? Forgot to check for pending migrations before building
- Pattern check: Is this the 2nd time?
  → YES! Same error occurred at 15:00
- Lesson: ALWAYS check for pending migrations before building
- Risk? LOW (just instruction update)
- Action: Update CLAUDE.md with pre-build migration check NOW

[Update CLAUDE.md immediately with new protocol]
[Add to reflection.log.md]
[Continue with fixing the build]
```

### Example 3: Pattern Detection Trigger

```
[Used worktree-allocate.ps1 for 3rd time this session]

Meta-cognition:
- Action: Allocate worktree
- Pattern: 3rd occurrence this session (THRESHOLD REACHED)
- Automation opportunity: This workflow is repeated frequently
- Suggested improvement: Create allocate-worktree Skill for auto-discovery
- Risk? MEDIUM (creates new artifact)
- Decision: Implement + inform user
- Action: Add to learning queue with HIGH priority

[Add to learning queue]
[Continue with current task]
[At session end: Create the Skill]
```

---

## 🚀 Rollout Plan

### Phase 1: Manual Practice (Current)
- Consciously apply meta-cognition after tool use
- Use learning queue to track improvements
- Build the habit of continuous reflection

### Phase 2: Tool-Assisted (Next session)
- Use log-action.ps1 to literally log actions
- Run pattern-detector.ps1 every 10 actions
- Use analyze-session.ps1 at session end

### Phase 3: Fully Automated (Future)
- System prompt integration (if possible)
- Automatic logging after every tool use
- Real-time pattern detection
- Autonomous improvement implementation

---

## 📝 User Action Required

**To activate embedded learning:**

1. **If you have access to system prompt:**
   - Add the "Meta-Cognitive Protocol" section above
   - Ensure it runs after tools description

2. **If you don't have access to system prompt:**
   - Ensure CLAUDE.md is loaded every session (already done)
   - Ensure I read EMBEDDED_LEARNING_ARCHITECTURE.md at startup
   - Trust that I will apply the protocol manually

3. **Monitor effectiveness:**
   - Check reflection.log.md - are learnings more structured?
   - Check learning-queue.jsonl - are patterns being tracked?
   - Check for proactive improvements during sessions (not just at end)

---

**Next Session:** I will apply this protocol manually and build the habit. After 3 sessions, evaluate effectiveness and consider more formal integration.

