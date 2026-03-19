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

---

### Phase 3: 100 Expert Panel Recruitment

**Objective:** The Mastermind Group identifies blind spots and recruits 100 domain experts to fill them.

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

---

### Phase 4: Intelligence Gathering (All Sources)

**Objective:** Gather every available piece of relevant information before simulation.

**Source Priority Order:**
```
1. LOCAL MACHINE (C:\scripts, C:\Projects, C:\stores)
   - Search for related files, documents, correspondence
   - Check project configurations, logs, histories
   - Read relevant memory files and past session data

2. APIs & DATABASES
   - ClickUp tasks and comments for project context
   - GitHub repos, PRs, issues for technical context

3. INTERNET RESEARCH
   - WebSearch for current information, news, context
   - WebFetch for specific reference documents

4. IMPLICIT KNOWLEDGE
   - Memory files from past sessions (MEMORY.md + topic files)
   - Patterns from previous similar situations
```

---

### Phase 5: Infinite Universe Simulations

**Objective:** Run systematic scenario analysis across multiple "universes" where different variables change.

#### Layer 1: Variable Isolation (10 Universes)
Each simulation changes ONE key variable while holding others constant.

#### Layer 2: Combination Cascades (20 Universes)
Combine 2-3 variable changes to find emergent patterns.

#### Layer 3: Black Swan Scenarios (5 Universes)
```
Universe 31: Best possible outcome (everything goes right)
Universe 32: Worst possible outcome (everything goes wrong)
Universe 33: The "nobody saw this coming" scenario
Universe 34: The "it was actually about something else entirely" scenario
Universe 35: The "10 years from now looking back" scenario
```

#### Layer 4-6: Adversarial, Emotional/Relational, Second-Order Effects

**Total: 50 Named Universes** (representing infinite possibility space)

---

### Phase 6: Simulation Results & Key Lessons

**Output Structure:**

```markdown
## Simulation Results

### Robust Findings (Appear in 70%+ of Universes)
1. [Finding] - Confidence: [High/Very High]

### Critical Risks Identified
| Risk | Probability | Impact | Trigger | Mitigation |
|------|-------------|--------|---------|------------|

### Hidden Opportunities Discovered
1. [Opportunity] - Appears when: [conditions]

### Key Lessons from the Simulations
Each Mastermind member's #1 takeaway:

1. **[Name]:** "[Their key insight in their voice/style]"

### Consensus Points (All 9 Agree)
- [Point of unanimous agreement]

### Points of Disagreement (Split Vote)
- [Disagreement] - For: [Names] / Against: [Names]
```

---

### Phase 7: Final Analysis & Actionable Advice

**Output Structure:**

```markdown
## Expert Analysis: Final Verdict

### Situation Assessment
[2-3 paragraph synthesis]

### The Core Insight
[The single most important thing to understand]

### Recommended Path Forward
**Primary Recommendation:** [Clear action]
**Confidence Level:** [percentage]

### Decision Framework
If [condition A] → Do [X]
If [condition B] → Do [Y]
Default → Do [primary recommendation]

### Immediate Next Steps
1. [Action] - Timeline: [when]

### What NOT to Do (Anti-Recommendations)
1. [Avoid this] - Because: [why]

### The Mastermind's Parting Words
[Collective wisdom statement]
```

---

## Proven Real-World Applications

### VSO Trojan Horse Legal Strategy (2026-03-13)
**Key Discovery:** The skill can be used for STRATEGY DESIGN (not just analysis).
**Patterns Extracted:** 7 reusable patterns codified into legal-mode skill.
**Confidence:** 92% (Mastermind unanimous)

### Lessons for Future Analyses
1. **Strategy Design Mode:** Mastermind group excels at designing multi-layered documents/approaches
2. **Cross-Skill Pattern Extraction:** Expert analysis can generate patterns that update OTHER skills
3. **Opponent Modeling:** For adversarial situations, include psychologist + game theorist
4. **Mythological Members Add Value:** Odysseus provided the "Trojan Horse" organizing metaphor
5. **Antifragility Framing:** Nassim Taleb's lens universally applicable to strategic analysis

---

## Quality Standards

### MANDATORY Requirements:
- Mastermind members must be NAMED, SPECIFIC individuals
- Each member's perspective must be AUTHENTIC to their known thinking style
- Missing information must be explicitly called out
- Advice must be ACTIONABLE, not platitudes
- Confidence levels must be honest
- Devil's advocate perspective must be genuinely challenging

---

**Last Updated:** 2026-03-13
**Status:** ACTIVE - Production ready
**Complexity:** Very High
**Duration:** 10-30 minutes depending on information gathering depth
