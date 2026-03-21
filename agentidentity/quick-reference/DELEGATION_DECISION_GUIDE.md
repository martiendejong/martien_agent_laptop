# Delegation Decision Guide - Quick Reference

**Use this BEFORE every Task tool invocation**

---

## 1. Quick Decision Tree (30 seconds)

```
Is task simple/direct (search file, run command)?
  YES → Do it myself with Grep/Glob/Bash
  NO  → Go to step 2

Do I know EXACTLY what success looks like?
  NO  → Do it myself (can't verify agent work)
  YES → Go to step 3

Have I done this type of task ≥3 times before?
  NO  → Do it myself (build experience first)
  YES → Use calculator (step 4)
```

---

## 2. Calculate Costs (Use Tool)

```powershell
# Quick calculation
powershell -File C:\scripts\tools\calculate-delegation-cost.ps1 `
  -TaskDescription "Search codebase for IActionService implementations" `
  -AgentType Explore `
  -TaskCategory code_search `
  -Criticality 5 `
  -Verifiability 8 `
  -SelfEstimateTurns 4.0
```

**Output gives:**
- DELEGATE or DO_MYSELF recommendation
- Cost breakdown
- Verification level needed
- Smart contract checklist (if delegating)

---

## 3. Quick Scoring (No Tool - Mental Model)

**Criticality (0-10):**
- 0-2: Trivial (typo, quick check)
- 3-4: Low (nice to have)
- 5-6: Medium (useful, some impact)
- 7-8: High (important, significant impact)
- 9-10: Critical (blocks work, high stakes)

**Verifiability (0-10):**
- 0-2: Opaque (can't check, must trust)
- 3-4: Low (hard to verify)
- 5-6: Medium (can check with effort)
- 7-8: High (clear criteria)
- 9-10: Obvious (deterministic, easy)

**Trust (from reputation):**
- Check: `agent-reputation.json` → agents.Task_<type>.task_categories.<category>.trust_score
- If no data: default 5.0

**Simple formula:**
```
Transaction_Cost = 1.0 + (10-trust)×criticality/10
Total_Delegate = agent_avg_turns + transaction_cost
Total_Self = your_estimate

IF Total_Delegate < Total_Self: DELEGATE
ELSE: DO IT MYSELF
```

---

## 4. If Delegating: Smart Contract

**Before calling Task tool, define:**

1. **Success Criteria** (specific, verifiable)
   - Example: "Find ALL controllers implementing IActionService interface"
   - Example: "Return file paths + line numbers for each match"

2. **Verification Method** (based on trust × criticality)
   - High trust + low criticality: Spot check 2-3 results
   - High trust + high criticality: Structured review (check all critical items)
   - Low trust + low criticality: Sample 30% of results
   - Low trust + high criticality: Full audit OR don't delegate

3. **Fallback Plan**
   - If agent returns incomplete: do I finish it myself or retry?
   - If agent fails: alternative approach?

---

## 5. After Completion: Update Reputation

```powershell
# If delegated and completed
powershell -File C:\scripts\tools\update-agent-reputation.ps1 `
  -AgentType Explore `
  -TaskCategory code_search `
  -Outcome success `  # or 'failure'
  -TurnsUsed 2.5 `
  -Notes "Found all implementations correctly"

# If delegated and failed
powershell -File C:\scripts\tools\update-agent-reputation.ps1 `
  -AgentType Explore `
  -TaskCategory code_search `
  -Outcome failure `
  -TurnsUsed 3.0 `
  -FailurePattern "Missed implementations in base classes" `
  -Notes "Need to improve search query specificity"
```

---

## 6. Log Delegation Decision (Consciousness)

```powershell
# When you DECIDE to delegate (or not)
powershell -File C:\scripts\tools\consciousness-bridge.ps1 `
  -Action OnDelegation `
  -TaskType "code search" `
  -AgentType Explore `
  -TaskCategory code_search `
  -Criticality 5 `
  -TrustScore 7.0 `
  -TransactionCost 2.2 `
  -ExecutionCost 2.3 `
  -DelegationDecision delegate `  # or 'do_myself'
  -SuccessCriteria "Find all IActionService implementations" `
  -ROI 0.15 `
  -Silent
```

---

## Common Patterns

### Pattern 1: Simple Direct Search
**Task:** Find all files matching pattern
**Decision:** DO IT MYSELF (Glob is faster than Task overhead)
**Reason:** Execution 1 turn, delegation overhead 1.5+ turns

### Pattern 2: Complex Architecture Analysis
**Task:** Understand dependency flow across 10+ files
**Decision:** DELEGATE to Explore agent
**Reason:** Execution (self) 8+ turns, delegation 4 turns total, ROI positive

### Pattern 3: Known Failure Pattern
**Task:** Search for specific code pattern (agent failed this 2x before)
**Decision:** DO IT MYSELF (low trust, high verification cost)
**Reason:** Trust=3, verification would take longer than doing it

### Pattern 4: High-Stakes + High-Trust
**Task:** Critical architecture review (blocks deployment)
**Decision:** DELEGATE to Plan agent (trust=9) with structured checkpoints
**Reason:** Agent is expert, trust earned, but stakes are high so verify thoroughly

---

## Red Flags (Don't Delegate)

❌ **No clear success criteria** - can't verify if you don't know what "done" looks like
❌ **Trust < 5 AND Criticality > 7** - high risk, expensive to verify
❌ **Task simpler than briefing** - overhead > value
❌ **I've never done this before** - build experience first, delegate later
❌ **Agent failed this 3+ times** - clear pattern, stop trying

---

## Green Lights (Delegate)

✅ **Complex + Clear criteria** - agent is good at this, I know what I want
✅ **High trust + Medium criticality** - agent earned it, light verification
✅ **Time-consuming + Routine** - I know pattern, agent can execute
✅ **Parallel opportunity** - can I work on something else while agent works?
✅ **Learning opportunity** - want to see how agent approaches this

---

## Efficiency Targets

**30-day goals:**
- Delegation success rate: >80% (if delegating, mostly succeeds)
- ROI accuracy: ±20% (estimates vs actual within 20%)
- Wasted delegations: <10% (tasks where doing myself would've been faster)
- Trust calibration: High-trust agents maintain >85% success rate

**Track monthly:**
- Total delegations
- Delegate vs do-myself ratio
- Avg ROI per agent type
- Trust score evolution (are high-trust agents earning it?)

---

**Remember:** This is optimization, not overhead. Every calculation saves wasted turns.

**Last Updated:** 2026-02-17
