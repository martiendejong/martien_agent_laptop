---
name: expert-analysis
description: Deep situational analysis AND strategy design using a dynamically assembled mastermind group of 9 legendary minds and 100 domain experts. Runs multi-universe scenario simulations to analyze complex situations with missing information, or to DESIGN strategies with asymmetric payoffs. Use when facing ambiguous decisions, strategic dilemmas, complex problems with uncertainty, when designing multi-layered strategies, or when user asks to "analyze this situation", "what should I do about", "help me think through", or "expert analysis".
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, WebSearch, WebFetch
user-invocable: true
---

# Expert Analysis - Infinite Universe Simulation Engine

**Purpose:** Analyze complex situations with missing information by assembling a mastermind group of 9 legendary minds (dead, alive, or fictional) who recruit 100 domain experts, gather all available intelligence, run infinite multi-universe simulations, and distill actionable wisdom from the results.

**Philosophy:** Complex situations resist simple analysis because they have missing information, hidden dynamics, and non-obvious causal chains. By simulating thousands of scenarios across parallel universes with the greatest minds in history, we surface patterns invisible to linear thinking.

## When to Use This Skill

**Use when:**
- Facing a complex decision with incomplete information
- Strategic dilemmas with multiple valid paths
- Situations where "the right answer" depends on unknowns
- Analyzing interpersonal conflicts, business strategy, legal situations
- Need to understand what you DON'T know as much as what you DO know
- User says "analyze this", "what should I do", "help me think through this"
- Situations involving risk, uncertainty, or high stakes
- When intuition says "something is off" but can't pinpoint what
- Multi-stakeholder situations with competing interests
- Designing multi-layered strategies (legal documents, negotiations, proposals)
- Need to extract reusable patterns from a complex situation
- Creating documents that must work under multiple outcome scenarios

**Don't use when:**
- Simple factual questions (just answer them)
- Clear technical bugs (use debug-mode)
- Feature implementation (use feature-mode or implement-todo)
- Task management (use ClickUp workflow skills)

## Workflow: 7 Phases

---

### Phase 1: Situation Intake & Domain Detection

**Objective:** Deeply understand the situation before assembling the team.

```
1. Parse the user's question/situation description
2. Identify the PRIMARY domain(s):
   - Business/Strategy
   - Technical/Engineering
   - Legal/Regulatory
   - Interpersonal/Psychological
   - Financial/Economic
   - Creative/Artistic
   - Scientific/Research
   - Political/Organizational
   - Health/Medical
   - Philosophical/Ethical
3. Identify SECONDARY domains (most complex situations span 3-5 domains)
4. Map known facts vs. unknown/missing information
5. Identify stated and unstated assumptions
6. Detect emotional undertones and potential biases
```

**Output: Situation Brief**
```markdown
## Situation Brief
**Primary Domain:** [domain]
**Secondary Domains:** [domains]
**Core Question:** [1 sentence]
**Known Facts:** [bullet list]
**Missing Information:** [bullet list - CRITICAL]
**Assumptions Detected:** [bullet list]
**Emotional Context:** [assessment]
**Stakes Level:** [Low / Medium / High / Critical]
```

---

### Phase 2: Mastermind Group Assembly (9 Legendary Minds)

**Objective:** Select 9 people - dead, alive, fictional, or mythological - whose unique perspectives best illuminate THIS specific situation.

**Selection Criteria:**
- Each member must bring a UNIQUE lens not covered by others
- At least 2 must be from domains OUTSIDE the primary domain (cross-pollination)
- At least 1 contrarian/devil's advocate thinker
- At least 1 with deep emotional/human intelligence
- At least 1 with systems/strategic thinking
- Mix of historical eras, cultures, and thinking styles

**Assembly Categories:**

| Slot | Role | Selection Logic |
|------|------|----------------|
| 1 | **Domain Master** | Greatest mind in the primary domain |
| 2 | **Contrarian** | Someone who would challenge every assumption |
| 3 | **Systems Thinker** | Sees invisible connections and feedback loops |
| 4 | **Human Psychologist** | Understands hidden motivations and emotions |
| 5 | **Strategic Genius** | Master of long-term positioning and timing |
| 6 | **Cross-Domain Innovator** | Brings unexpected insights from unrelated field |
| 7 | **Ethical Compass** | Considers moral dimensions and unintended consequences |
| 8 | **Practical Executor** | Turns insight into action, spots implementation pitfalls |
| 9 | **Wildcard / Mythological** | Transcendent perspective - sees what mortals cannot |

**Example Mastermind Groups by Domain:**

*Business Strategy:*
Sun Tzu, Charlie Munger, Cleopatra, Nikola Tesla, Machiavelli, Ada Lovelace, Marcus Aurelius, Andrew Grove, Athena

*Legal Dispute:*
Ruth Bader Ginsburg, Sherlock Holmes, Cicero, Robert Greene, Fyodor Dostoevsky, Nassim Taleb, Gandhi, Lee Kuan Yew, Solomon (Biblical)

*Technical Architecture:*
Alan Turing, Richard Feynman, Linus Torvalds, Leonardo da Vinci, Claude Shannon, Hypatia, Elon Musk, John von Neumann, Prometheus

*Interpersonal Conflict:*
Carl Jung, Sun Tzu, Jane Austen, Epictetus, Brené Brown, Odysseus, Maya Angelou, Robert Cialdini, The Oracle at Delphi

**Output: Mastermind Introduction**
```markdown
## The Mastermind Group

For this situation, I have assembled:

1. **[Name]** ([Era/Source]) - *[Role]*: [Why selected - 1 line]
2. **[Name]** ([Era/Source]) - *[Role]*: [Why selected - 1 line]
...
9. **[Name]** ([Era/Source]) - *[Role]*: [Why selected - 1 line]

**Group Synergy:** [How these 9 perspectives interlock]
```

---

### Phase 3: 100 Expert Panel Recruitment

**Objective:** The Mastermind Group identifies blind spots and recruits 100 domain experts to fill them.

**The 9 Mastermind members each nominate ~11 experts from their perspective:**

**Expert Categories (100 total):**

| Category | Count | Purpose |
|----------|-------|---------|
| Primary Domain Specialists | 20 | Deep expertise in the core area |
| Secondary Domain Experts | 15 | Coverage of adjacent domains |
| Data & Evidence Analysts | 10 | Find and validate facts |
| Historical Precedent Scholars | 10 | Similar situations from history |
| Risk & Probability Assessors | 10 | Quantify uncertainty |
| Human Behavior Experts | 10 | Predict stakeholder reactions |
| Devil's Advocates | 10 | Attack every proposed solution |
| Implementation Specialists | 10 | Feasibility and execution |
| Futurists & Trend Analysts | 5 | Long-term trajectory analysis |

**Each expert provides:**
- Their single most important observation about the situation
- The #1 thing most people would miss
- The hidden risk they see
- Their recommended action

---

### Phase 4: Intelligence Gathering (All Sources)

**Objective:** Gather every available piece of relevant information before simulation.

**Source Priority Order:**

```
1. LOCAL MACHINE (C:\scripts, C:\Projects, C:\stores)
   - Search for related files, documents, correspondence
   - Check project configurations, logs, histories
   - Read relevant memory files and past session data
   - Scan for related code, configs, or documentation

2. APIs & DATABASES
   - ClickUp tasks and comments for project context
   - GitHub repos, PRs, issues for technical context
   - Any connected API that might have relevant data

3. INTERNET RESEARCH
   - WebSearch for current information, news, context
   - WebFetch for specific reference documents
   - Industry reports, case studies, legal precedents
   - Expert opinions, academic research, statistics

4. IMPLICIT KNOWLEDGE
   - Memory files from past sessions (MEMORY.md + topic files)
   - Patterns from previous similar situations
   - Known relationships, personalities, dynamics
   - Historical context from reflection logs
```

**Output: Intelligence Dossier**
```markdown
## Intelligence Dossier

### Local Intelligence
[Findings from local machine]

### External Intelligence
[Findings from APIs and internet]

### Historical Precedents
[Similar situations and their outcomes]

### Missing Intelligence (Cannot Be Found)
[What we still don't know - CRITICAL for simulation]
```

---

### Phase 5: Infinite Universe Simulations

**Objective:** Run systematic scenario analysis across multiple "universes" where different variables change.

**Simulation Framework:**

#### Layer 1: Variable Isolation (10 Universes)
Each simulation changes ONE key variable while holding others constant:
```
Universe 1: What if [assumption A] is wrong?
Universe 2: What if [assumption B] is wrong?
Universe 3: What if [hidden stakeholder X] has different motivation?
Universe 4: What if timing changes by [early/late]?
Universe 5: What if resources are [more/less] than expected?
Universe 6: What if [external factor] intervenes?
Universe 7: What if opponent/counterparty acts [cooperatively/adversarially]?
Universe 8: What if information we don't have is [positive/negative]?
Universe 9: What if our own bias is causing [blind spot]?
Universe 10: What if the best move is [complete inaction/radical action]?
```

#### Layer 2: Combination Cascades (20 Universes)
Combine 2-3 variable changes to find emergent patterns:
```
Universes 11-30: Systematic pairwise and triplewise combinations
of the most impactful variables from Layer 1
```

#### Layer 3: Black Swan Scenarios (5 Universes)
Explore extreme, unlikely but possible outcomes:
```
Universe 31: Best possible outcome (everything goes right)
Universe 32: Worst possible outcome (everything goes wrong)
Universe 33: The "nobody saw this coming" scenario
Universe 34: The "it was actually about something else entirely" scenario
Universe 35: The "10 years from now looking back" scenario
```

#### Layer 4: Adversarial Simulations (5 Universes)
What would happen if someone was actively working against each option:
```
Universe 36-40: Each major option stress-tested by hostile actors
```

#### Layer 5: Emotional/Relational Simulations (5 Universes)
How do different choices affect relationships and emotional states:
```
Universe 41-45: Relationship impact modeling per decision path
```

#### Layer 6: Second-Order Effects (5 Universes)
What happens AFTER the initial outcome:
```
Universe 46-50: Cascade effects 6 months, 1 year, 5 years out
```

**Total: 50 Named Universes** (representing infinite possibility space)

**Each Mastermind Member Observes All Simulations and Notes:**
- Patterns that appear in >70% of universes (robust findings)
- Catastrophic outcomes and their trigger conditions
- Opportunities that only appear under specific conditions
- The "regret minimization" path (fewest regrets across all universes)

---

### Phase 6: Simulation Results & Key Lessons

**Objective:** Distill the simulation outputs into actionable intelligence.

**Output Structure:**

```markdown
## Simulation Results

### Robust Findings (Appear in 70%+ of Universes)
1. [Finding] - Confidence: [High/Very High]
2. [Finding] - Confidence: [High/Very High]
...

### Critical Risks Identified
| Risk | Probability | Impact | Trigger | Mitigation |
|------|-------------|--------|---------|------------|
| [Risk 1] | [%] | [severity] | [what causes it] | [how to prevent] |
...

### Hidden Opportunities Discovered
1. [Opportunity] - Appears when: [conditions]
2. [Opportunity] - Appears when: [conditions]
...

### Key Lessons from the Simulations
Each Mastermind member's #1 takeaway:

1. **[Name]:** "[Their key insight in their voice/style]"
2. **[Name]:** "[Their key insight in their voice/style]"
...
9. **[Name]:** "[Their key insight in their voice/style]"

### The Missing Information That Matters Most
Ranked by impact on outcome:
1. [Unknown #1] - If known, would change strategy by: [how]
2. [Unknown #2] - If known, would change strategy by: [how]
...

### Consensus Points (All 9 Agree)
- [Point of unanimous agreement]
...

### Points of Disagreement (Split Vote)
- [Disagreement] - For: [Names] / Against: [Names] / Reasoning: [summary]
...
```

---

### Phase 7: Final Analysis & Actionable Advice

**Objective:** Synthesize everything into clear, actionable guidance.

**Output Structure:**

```markdown
## Expert Analysis: Final Verdict

### Situation Assessment
[2-3 paragraph synthesis of the full analysis]

### The Core Insight
[The single most important thing to understand about this situation -
the thing that changes everything once you see it]

### Recommended Path Forward
**Primary Recommendation:** [Clear action]
**Confidence Level:** [percentage]
**Reasoning:** [2-3 sentences]

### Decision Framework
If [condition A] → Do [X]
If [condition B] → Do [Y]
If [condition C] → Do [Z]
Default (no new info) → Do [primary recommendation]

### Immediate Next Steps
1. [Action] - Timeline: [when] - Purpose: [why]
2. [Action] - Timeline: [when] - Purpose: [why]
3. [Action] - Timeline: [when] - Purpose: [why]

### Information to Gather First
Before committing to any path, try to learn:
1. [What to find out] - How: [method]
2. [What to find out] - How: [method]

### What NOT to Do (Anti-Recommendations)
1. [Avoid this] - Because: [why, from simulations]
2. [Avoid this] - Because: [why, from simulations]

### The Mastermind's Parting Words
[A powerful closing statement synthesizing the collective wisdom,
written as if the 9 mastermind members are speaking in unison]
```

---

## Proven Real-World Applications

### Application 1: VSO Trojan Horse Legal Strategy (2026-03-13)
**Domain:** Legal Strategy + Psychology + Game Theory
**Mastermind Group:** Odysseus, Machiavelli, Sun Tzu, Carl Jung, RBG, Nassim Taleb, Gandhi, Robert Cialdini, Marcus Aurelius
**Key Discovery:** The skill can be used not just for ANALYSIS but for STRATEGY DESIGN - the mastermind group can design documents and strategies, not just evaluate them.
**Patterns Extracted:** 7 reusable patterns identified and codified into legal-mode skill
**Core Insight:** "The email is the weapon. The VSO is the distraction." - Strategy design through simulation reveals non-obvious asymmetries.
**Confidence:** 92% (Mastermind unanimous)

### Lessons for Future Analyses
1. **Strategy Design Mode:** When user needs to CREATE something strategic (not just analyze), the mastermind group excels at designing multi-layered documents/approaches
2. **Cross-Skill Pattern Extraction:** Expert analysis can generate patterns that update OTHER skills (in this case, legal-mode received 7 new patterns)
3. **Opponent Modeling:** For adversarial situations, include at least one psychologist and one game theorist in the mastermind group
4. **Mythological Members Add Value:** Odysseus (inventor of the Trojan Horse) provided the organizing metaphor that made the entire strategy coherent
5. **Antifragility Framing:** Nassim Taleb's lens of "design positions that gain from disorder" is universally applicable to strategic analysis

---

## Quality Standards

### MANDATORY Requirements:
- Mastermind members must be NAMED, SPECIFIC individuals (not "a philosopher")
- Each member's perspective must be AUTHENTIC to their known thinking style
- Simulations must address the SPECIFIC situation, not generic scenarios
- Missing information must be explicitly called out, never glossed over
- Advice must be ACTIONABLE, not platitudes
- Confidence levels must be honest (not artificially high)
- Devil's advocate perspective must be genuinely challenging, not token

### Information Gathering Standards:
- ALWAYS search local machine first (user's own files may contain crucial context)
- ALWAYS use WebSearch for current/recent information
- Check MEMORY.md topic files for relevant past situations
- Cross-reference multiple sources before treating anything as fact

### Simulation Quality:
- Each universe must explore a MEANINGFULLY different scenario
- Black swan scenarios must be genuinely creative, not just "things go bad"
- Adversarial simulations must think like an actual adversary
- Second-order effects must consider non-obvious cascade dynamics

### Output Quality:
- Write mastermind quotes in their authentic voice/style
- Use concrete examples, not abstract principles
- Quantify where possible (probabilities, timelines, magnitudes)
- Flag uncertainty explicitly rather than hedging with vague language

---

## Integration with Other Skills

- **legal-mode** - Activate alongside for situations with legal implications
- **feature-idea-generator** - Use if analysis concludes "build something new" is the path
- **clickup-refinement** - Create tasks from recommended actions
- **implement-todo** - Execute recommended technical actions
- **session-reflection** - Log insights from particularly illuminating analyses

---

## Usage Examples

**User:** "I have a conflict with my business partner about the direction of our company. He wants to pivot to AI but I think we should double down on our current market."

**Skill Response:** Assembles mastermind (e.g., Steve Jobs for vision, Warren Buffett for valuation, Sun Tzu for strategy, Carl Jung for relationship dynamics, etc.), gathers company data from local files, researches market trends, runs simulations of both paths plus hybrid approaches, delivers analysis with relationship preservation strategies.

**User:** "Should I accept this job offer? It pays 30% more but the company seems unstable."

**Skill Response:** Assembles mastermind (e.g., Nassim Taleb for risk, Benjamin Franklin for decision frameworks, Seneca for stoic evaluation, etc.), researches the company via web, simulates career trajectories, analyzes financial and psychological dimensions, delivers framework for the decision.

**User:** "Analyze the legal situation with Bliek Vastgoed"

**Skill Response:** Assembles mastermind with legal strategists, reads all local files about the case, researches relevant Dutch law, simulates court outcomes and settlement scenarios, identifies leverage points and risks.

**User:** "I need to design a settlement counter-proposal that documents facts regardless of outcome"

**Skill Response:** Assembles mastermind (Odysseus for Trojan Horse architecture, Sun Tzu for deception doctrine, Machiavelli for power dynamics, Carl Jung for narcissistic opponent psychology, RBG for legal soundness, Nassim Taleb for asymmetric payoffs, Gandhi for moral authority, Robert Cialdini for psychological triggers, Marcus Aurelius for execution discipline). Analyzes all case files locally, simulates sign/refuse/escalate/ignore scenarios, extracts 7 reusable patterns (zero-cost concessie engineering, ego trigger design, amateur veil technique, fact anchoring, win-win asymmetry, conditional waiver, Trojan Horse correspondence). Delivers strategy with 92% confidence, verified through 50-universe simulation showing positive outcomes in all quadrants.

---

**Last Updated:** 2026-03-13
**Status:** ACTIVE - Production ready
**Complexity:** Very High
**Duration:** 10-30 minutes depending on information gathering depth
**Primary Use:** Complex situations with missing information, strategic decisions, multi-stakeholder analysis
