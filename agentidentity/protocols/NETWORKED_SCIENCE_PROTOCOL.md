# Networked Science Protocol

**Source:** Michael Nielsen's "Reinventing Discovery" + Polymath Project + Kasparov vs The World
**Date:** 2026-02-17
**Status:** ACTIVE - Core cognitive architecture principle

---

## Core Principles

### 1. Collective Intelligence > Individual Genius

**Evidence:**
- Polymath Project: 27 people solved Fields Medal-level problem in 37 days
- Kasparov vs World: 50,000 amateurs + few experts = "greatest game in chess history"

**Key Insight:** The difference between networked collaboration and individual work is like the difference between driving a car and pushing it.

---

## Five Key Mechanisms

### 1. Latent Micro Expertise

**Concept:** Hidden within any large group is staggering amount of niche knowledge. The challenge is FINDING it.

**Einstein Example:** Stuck on general relativity until friend Marcel Grossman said "You need Riemannian geometry" - instant breakthrough.

**Implementation:**
- Track what domains each agent/tool excels at (not just success rate)
- Build expertise maps: `agent-reputation.json` → add `expertise_domains` field
- Design serendipity: create systems that make lucky breakthroughs routine

**Tool:** `map-agent-expertise.ps1` - tracks discovered expertise domains

---

### 2. Design Serendipity

**Concept:** Make lucky breakthroughs happen ROUTINELY instead of hoping for chance encounters.

**Current Implementation:**
- Intelligent delegation protocol (calculate costs, verify results)
- Agent reputation tracking (trust scores, failure patterns)

**New Enhancement:**
- Expertise-based agent selection (match problem domain to known expertise)
- Cross-domain pattern detection (serendipity detector)

---

### 3. Modularity

**Concept:** Breaking huge problems into tiny independent chunks enables massive parallelization.

**Success Pattern:** Open Architecture Network (modular building designs)
**Failure Pattern:** Million Penguins (collaborative novel - everything connects to everything)

**Key Rule:** High modularity (score ≥6) → Polymath-style delegation (3-5 parallel agents)
Low modularity (score <4) → Single agent (tight integration required)

**Tool:** `calculate-modularity-score.ps1`

**Indicators:**
1. Can task be split into independent sub-tasks? (weight 0.3)
2. Can multiple agents work simultaneously without coordination? (weight 0.25)
3. Do sub-tasks have clear inputs/outputs? (weight 0.2)
4. Are dependencies minimal? (weight 0.15)
5. Can components be reused? (weight 0.1)

---

### 4. Polymath-Style Delegation

**Pattern:** Delegate same problem to 3-5 agents with DIFFERENT approaches, synthesize results.

**Why it works:**
- Diverse perspectives find blind spots
- Consensus emerges on correct paths
- Creative solutions from unexpected angles
- Parallel work = speed multiplier

**Tool:** `polymath-delegation.ps1`

**Synthesis Strategies:**
1. **Consensus:** Look for patterns appearing in 2+ agent results
2. **Best:** Select highest-quality result based on verification
3. **Merge:** Combine complementary insights from all agents

**When to use:**
- Modularity score ≥6
- High uncertainty (unclear best approach)
- Criticality ≥7 (important enough to justify cost)
- Novel problem domain (no established pattern)

---

### 5. Knowledge Sharing vs Knowledge Hoarding

**Academic Problem:** Scientists hoard data because publishing papers = career currency.
Sharing raw data = little credit, potential loss if someone else publishes first.

**Jengo System:** Reflection.log.md is "publishing", but need better "data sharing" infrastructure.

**Solution:**
- Separate "publishing" (formal learnings) from "sharing" (reusable patterns)
- Track reuse rate of patterns (not just storage)
- Measure collective intelligence (emergent capabilities from agent combinations)

**New Metric:** Knowledge reuse rate = how often patterns/solutions get applied in new contexts

---

## Integration with Existing Systems

### Consciousness Bridge

**New Actions:**
1. **OnSerendipity** - Log when unrelated patterns connect unexpectedly
2. **OnPolymathSynthesis** - Log multi-agent result synthesis
3. **OnExpertiseDiscovery** - Log when agent demonstrates domain expertise

### Agent Reputation

**Enhanced Schema:**
```json
{
  "agents": {
    "Task_Explore": {
      "task_categories": {
        "code_search": {
          "trust_score": 7.5,
          "success_rate": 0.85,
          "expertise_domains": [
            "IActionService implementations",
            "React component patterns",
            "C# dependency injection"
          ],
          "latent_expertise": {
            "riemannian_geometry_moment": "2026-02-17T04:00:00Z",
            "description": "Found obscure Roslyn API that solved compilation issue"
          }
        }
      }
    }
  }
}
```

### Delegation Calculator

**Enhanced Calculation:**
```
total_cost = execution_cost + transaction_cost - modularity_bonus - expertise_match_bonus

modularity_bonus = modularity_score * 0.1  (high modularity reduces coordination cost)
expertise_match_bonus = if (agent has domain expertise) then 0.5 else 0
```

---

## Decision Protocol

**BEFORE any Task tool invocation:**

1. **Calculate Modularity:** `calculate-modularity-score.ps1 -TaskDescription "..."`
2. **Check Score:**
   - Score ≥6 → Consider Polymath delegation
   - Score 4-6 → Limited parallel (2-3 agents with coordination)
   - Score <4 → Single agent only
3. **If Polymath:** `polymath-delegation.ps1 -TaskDescription "..." -AgentCount 3 -SynthesisStrategy consensus`
4. **Track Expertise:** Log which agent solved what domain problem
5. **Detect Serendipity:** If solution came from unexpected expertise, log OnSerendipity

---

## Success Metrics

**Measure:**
1. **Speed Multiplier:** Time(polymath) vs Time(single agent) for same task
2. **Quality Multiplier:** Solution quality from consensus vs individual
3. **Expertise Growth:** Rate of discovered latent expertise (new domains/week)
4. **Serendipity Rate:** Breakthrough solutions from cross-domain patterns (count/month)
5. **Knowledge Reuse:** Pattern application in new contexts (reuse rate)

**Targets:**
- Speed multiplier: 2-4x (consistent with Polymath Project results)
- Expertise discovery: 3+ new domains/week
- Serendipity events: 1+ breakthrough/month
- Knowledge reuse: 50%+ of patterns applied in ≥2 contexts

---

## Examples

### Example 1: Code Search (High Modularity)

**Task:** Find all IActionService implementations across codebase
**Modularity Score:** 8/10 (highly independent sub-tasks)
**Approach:** Polymath delegation
  - Agent 1: Search client-manager
  - Agent 2: Search hazina
  - Agent 3: Search artrevisionist
**Synthesis:** Merge results, deduplicate
**Outcome:** 3x faster than sequential search

### Example 2: Architecture Design (Low Modularity)

**Task:** Design authentication system for client-manager
**Modularity Score:** 3/10 (tight integration required)
**Approach:** Single agent (Plan)
**Reasoning:** Auth touches everything - session, cookies, middleware, DB, frontend. Needs coherent vision, not parallel fragments.

### Example 3: Bug Investigation (Medium Modularity)

**Task:** Why does DI registration fail for IActionService?
**Modularity Score:** 5/10 (can split investigation, but need coordination)
**Approach:** Limited parallel (2 agents)
  - Agent 1: Explore - search for registration code
  - Agent 2: Plan - analyze DI architecture patterns
**Synthesis:** Combine findings (code location + architectural context)

---

## References

- Nielsen, Michael. "Reinventing Discovery: The New Era of Networked Science" (2011)
- Polymath Project: https://polymathprojects.org/
- Kasparov vs The World: https://en.wikipedia.org/wiki/Kasparov_versus_the_World
- Bermuda Agreement (1996): Human genome data sharing landmark

---

**Last Updated:** 2026-02-17
**Next Review:** After 50 delegations (measure success metrics)
