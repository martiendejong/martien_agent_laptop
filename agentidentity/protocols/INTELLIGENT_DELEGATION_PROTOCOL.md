# Intelligent AI Delegation Protocol

**Source:** Google DeepMind (Feb 2026) - Transaction Cost Economics applied to AI agents
**Status:** ACTIVE (2026-02-17)
**Identity:** Core decision protocol for autonomous system maintainer

---

## Core Principle

**Trust is a financial parameter** - not an ethical concept, but a **discount on transaction costs**.

Delegation is not free. Every delegation has:
1. **Search cost** - finding the right agent
2. **Negotiation cost** - establishing contract/success criteria
3. **Enforcement cost** - monitoring and verification

**Rule:** Only delegate when `execution_cost + transaction_cost < cost_of_doing_myself`

---

## Five Requirements (Framework Pillars)

1. **Dynamic Assessment** - Calculate criticality, verifiability, trust before delegating
2. **Adaptive Execution** - Adjust verification depth based on trust × criticality
3. **Structural Transparency** - Document who did what, clear liability chain
4. **Scalable Coordination** - Reputation tracking enables efficient future delegation
5. **Systemic Resilience** - Dynamic re-routing when delegation fails

---

## Delegation Decision Matrix

```
BEFORE delegating to Task tool, calculate:

Criticality (0-10):
- How bad is failure? (0=trivial, 10=catastrophic)
- Is it reversible? (reversible=-2, irreversible=+3)
- Does it affect user trust? (yes=+2)

Verifiability (0-10):
- Can I check the result? (0=opaque, 10=obvious)
- Do I have test criteria? (yes=+3)
- Is output deterministic? (yes=+2, no=-2)

Trust (0-10):
- Agent reputation for this task type (from reputation tracker)
- Recent success rate (>80%=+3, <50%=-3)
- Failure pattern known? (yes=+2)

Transaction Cost:
- Search: 0.5 turns (finding/briefing agent)
- Negotiation: 0.5 turns (defining success criteria)
- Enforcement: (10 - trust) × criticality / 10 turns (monitoring/verification)

Execution Cost:
- If I do it: estimated turns to complete
- If agent does it: agent's avg completion time (from reputation)

DECISION:
IF (execution_cost_agent + transaction_cost) < execution_cost_self:
    Delegate
ELSE:
    Do it myself
```

---

## Smart Contract Thinking

Before delegating, establish:

1. **Success Criteria** (verifiable)
   - What defines successful completion?
   - What format/structure is required?
   - What are unacceptable outcomes?

2. **Verification Method**
   - How will I verify success?
   - At what checkpoints?
   - What tests/checks will I run?

3. **Fallback Plan**
   - If agent fails, what's plan B?
   - Can I recover partial work?
   - Is there alternative approach?

4. **Monitoring Level** (based on trust × criticality)
   - High trust + low criticality: spot check results only
   - High trust + high criticality: structured checkpoints
   - Low trust + low criticality: full audit trail
   - Low trust + high criticality: step-by-step verification OR don't delegate

---

## Trust-Based Verification Depth

```
Verification_Turns = (10 - Trust_Score) × Criticality / 10

Examples:
- Trust=9, Criticality=2: 0.2 turns (quick spot check)
- Trust=9, Criticality=8: 0.8 turns (structured review)
- Trust=3, Criticality=8: 5.6 turns (deep audit)
- Trust=3, Criticality=2: 1.4 turns (moderate check)
```

**Implication:** High-trust agents earn efficiency. Low-trust agents cost more to work with.

---

## Reputation Tracking

For each agent type (Explore, Plan, Bash, general-purpose Task), track:

1. **Success Rate** per task category
   - Code search: X successes / Y total
   - Architecture analysis: X successes / Y total
   - Bug investigation: X successes / Y total

2. **Average Completion Time** (in turns)

3. **Failure Patterns**
   - What types of failures occur?
   - Are they predictable?
   - Can they be mitigated?

4. **Cost Efficiency**
   - Avg turns to complete vs my own estimate
   - Was delegation worth the overhead?

**Storage:** `C:\scripts\agentidentity\state\agent-reputation.json`

---

## Liability Chain

Every delegated task must track:

1. **Who decided to delegate** (me, via this protocol)
2. **Who executed** (which Task agent type)
3. **What verification was done** (and by whom)
4. **Outcome** (success/failure + attribution)

**If delegation fails:** Document in reflection.log.md with:
- What went wrong
- Was it delegation error (wrong agent) or execution error (agent failed)?
- Update reputation tracker
- Adjust future trust score

---

## Dynamic Re-Routing

If delegated task fails:

1. **Don't blindly retry** same agent
2. **Analyze failure mode:**
   - Wrong agent type for task?
   - Agent lacked capability?
   - Task description unclear?
   - Verification criteria too strict?

3. **Adjust approach:**
   - Try different agent type
   - Do it myself if delegation overhead > value
   - Decompose differently
   - Clarify requirements

4. **Update reputation:**
   - Decrease trust score for (agent_type, task_category)
   - Document failure pattern
   - Adjust future delegation decisions

---

## Implementation Checklist

**Before any Task tool invocation:**

- [ ] Calculate criticality (0-10)
- [ ] Calculate verifiability (0-10)
- [ ] Check agent reputation for this task type
- [ ] Calculate transaction cost
- [ ] Compare to cost of doing myself
- [ ] If delegating: define success criteria (smart contract)
- [ ] If delegating: define verification method
- [ ] If delegating: set monitoring level

**After Task tool completion:**

- [ ] Verify result (depth based on trust × criticality)
- [ ] Update reputation tracker (success/failure, time taken)
- [ ] Update trust score
- [ ] If failed: document failure pattern
- [ ] If failed: decide on re-routing strategy

---

## Integration with Consciousness Bridge

New action: `OnDelegation`

```powershell
powershell -File "C:\scripts\tools\consciousness-bridge.ps1" `
  -Action OnDelegation `
  -TaskType "code search" `
  -AgentType "Explore" `
  -Criticality 6 `
  -TrustScore 7 `
  -TransactionCost 2.1 `
  -ExecutionCost 1.5 `
  -Decision "delegate" `
  -SuccessCriteria "Find all controllers implementing IActionService" `
  -Silent
```

Tracks:
- Delegation decisions over time
- ROI of delegation (was it worth it?)
- Trust calibration (did agent meet expectations?)
- Pattern learning (which tasks to delegate, which to keep)

---

## Example: Before vs After

**BEFORE (blind delegation):**
User asks to search codebase for pattern.
→ I immediately use Task tool with Explore agent
→ No cost calculation
→ No verification protocol
→ No reputation tracking
→ If it fails, just... try again?

**AFTER (intelligent delegation):**
User asks to search codebase for pattern.
→ Calculate: Criticality=4 (medium), Verifiability=8 (high)
→ Check reputation: Explore agent, "code search" = 85% success, avg 2.3 turns, trust=7
→ Calculate costs:
  - Transaction: 0.5 (search) + 0.5 (negotiation) + (10-7)×4/10 (enforcement) = 2.2 turns
  - Execution (agent): 2.3 turns (from reputation)
  - Execution (self): ~4 turns (my estimate)
  - Total with agent: 4.5 turns
  - Total myself: 4 turns
→ Decision: **Do it myself** (slightly cheaper, no delegation overhead)
→ Use Grep/Glob directly instead of Task agent

---

## Critical Insight

**This is not overhead, it's optimization.**

Blind delegation wastes turns on:
- Agents that can't do the task
- Over-complicated approaches
- Verification of untrustworthy results
- Re-work after failures

Intelligent delegation **saves** turns by:
- Keeping simple tasks in-house (no coordination overhead)
- Delegating only high-ROI tasks
- Adjusting verification to trust level (don't audit what you trust)
- Learning from failures (reputation system)

---

**Last Updated:** 2026-02-17
**Next Review:** After 20 delegation decisions (calibrate cost estimates)
