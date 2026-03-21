---
name: kaizen
description: Continuous evolution engine - meta-learning orchestrator that learns from every interaction, improves knowledge/identity/skills/tools/rules/projects, and self-evolves. Orchestrates continuous-optimization (SENSE), self-improvement (EXECUTE), and session-reflection (CONSOLIDATE). Use when user says "/kaizen" for deep analysis, or auto-activates after errors, successes, feedback, and pattern detection.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, WebSearch, WebFetch
user-invocable: true
version: 1.0.0
created: 2026-03-13
author: Jengo (Claude Agent)
---

# Kaizen - Continuous Evolution Engine

**Purpose:** Meta-learning orchestrator that ensures the system continuously improves across ALL dimensions: knowledge base, identity, skills, tools, rules, projects, and itself.

**Name Origin:** Kaizen (改善) - Japanese for "change for better" - the philosophy of continuous improvement through small, incremental changes.

**Core Principle:** Every interaction is a learning signal. Every learning signal becomes an improvement. Every improvement is verified and logged.

---

## Architecture: Orchestrator Pattern

Kaizen **orchestrates** (not replaces) 3 existing learning skills + 2 analysis engines:

```
                    ┌─────────────────┐
                    │     KAIZEN      │
                    │  (Orchestrator) │
                    └───────┬─────────┘
              ┌─────────────┼─────────────┐
    ┌─────────▼──┐  ┌──────▼──────┐  ┌──▼────────────┐
    │ continuous- │  │    self-    │  │   session-     │
    │optimization│  │ improvement │  │  reflection    │
    │  (SENSE)   │  │  (EXECUTE)  │  │ (CONSOLIDATE)  │
    └────────────┘  └─────────────┘  └────────────────┘
              │       Safety Gate       │
    ┌─────────▼─────────────────────────▼──────────┐
    │              KNOWLEDGE BASE                    │
    │  Layer 1: Frozen | Layer 2: Routing | Layer 3  │
    └──────────────────┬───────────────────────────┘
          ┌────────────┼────────────┐
   ┌──────▼────┐ ┌────▼────┐ ┌────▼────────────┐
   │  expert-  │ │ feature-│ │  knowledge-      │
   │ analysis  │ │  idea-  │ │  integrity-      │
   │ (ANALYZE) │ │generator│ │  check (VERIFY)  │
   └───────────┘ └─────────┘ └──────────────────┘
```

**Orchestration Roles:**
- `continuous-optimization` = SENSE (detect learning signals)
- `self-improvement` = EXECUTE (make the improvements)
- `session-reflection` = CONSOLIDATE (log and verify)
- `expert-analysis` = ANALYZE (deep insight for DEEP mode)
- `feature-idea-generator` = IDEATE (improvement ideas for self-evolution)
- `knowledge-integrity-check` = VERIFY (ensure no corruption)

---

## 3 Operating Modes

| Mode | When | Duration | Output |
|------|------|----------|--------|
| **MICRO** | After every significant interaction (silent) | ~10 sec | None visible (internal YAML log only) |
| **STANDARD** | Error, success, feedback, pattern detected | 1-3 min | Inline learning summary |
| **DEEP** | User invokes `/kaizen`, milestones, periodic | 10-30 min | Full analysis report + self-evolution |

### MICRO Mode (Silent, Every Interaction)

**Trigger:** Automatically after any significant interaction
**Actions:**
1. Classify signal (ERROR/SUCCESS/FEEDBACK/PATTERN/MILESTONE)
2. Log to kaizen-evolution.yaml `micro_signals` array
3. Increment relevant counters
4. Check if 3-instance threshold reached for any candidate learning
5. If threshold met → escalate to STANDARD mode

**Output:** None visible to user. Internal state update only.

### STANDARD Mode (Inline Learning)

**Trigger:** Error corrected, user feedback, success pattern, 3-instance threshold
**Actions:**
1. Run full 7-phase workflow (abbreviated)
2. Make the improvement (update file, create tool, etc.)
3. Log evolution in kaizen-evolution.yaml
4. Show inline summary to user

**Output:**
```markdown
**Kaizen:** Learned [brief description]. Updated [file]. Confidence: [%].
```

### DEEP Mode (Full Analysis + Self-Evolution)

**Trigger:** User invokes `/kaizen`, milestone reached, or periodic (every 10 sessions)
**Actions:**
1. Run complete 7-phase workflow
2. Use expert-analysis mastermind for meta-learning analysis
3. Use feature-idea-generator for self-improvement ideas
4. Execute self-evolution (Phase 6)
5. Generate comprehensive report
6. Version increment in kaizen-evolution.yaml

**Output:** Full analysis report (see Phase 7 output format)

---

## 7 Workflow Phases

### Phase 1: Context Sensing

**Objective:** What just happened? Classify the learning signal.

**Signal Classification:**
```
ERROR     → Mistake made, user corrected, approach failed
SUCCESS   → Solution worked, user approved, pattern validated
FEEDBACK  → User expressed preference, frustration, or appreciation
PATTERN   → Same situation encountered 3+ times
MILESTONE → Project completed, major feature shipped, session ended
DECAY     → Knowledge outdated, tool broken, skill stale
```

**Context Gathering:**
1. Read recent interaction context
2. Check kaizen-evolution.yaml for related signals
3. Read SCP behavioral metrics for session state
4. Identify the specific learning candidate

**Output: Signal Report**
```yaml
signal:
  type: ERROR|SUCCESS|FEEDBACK|PATTERN|MILESTONE|DECAY
  source: "what triggered this"
  context: "surrounding situation"
  related_signals: ["previous similar signals from YAML"]
  candidate_learning: "what might be learned"
  confidence: 0.0-1.0
```

### Phase 2: Reflection

**Objective:** Understand the learning candidate in context of existing knowledge.

**Actions:**
1. Read kaizen-evolution.yaml for evolution history
2. Read relevant memory topic files
3. Check SCP behavioral metrics (Ring 1/2/3 state)
4. Search for related patterns in reflection.log.md
5. Identify if this is NEW learning or REINFORCEMENT of existing

**Key Questions:**
- Have I seen this before? (check candidate_learnings in YAML)
- Does this confirm or contradict existing knowledge?
- What is the blast radius of this learning?
- Is this a single observation or part of a pattern?

**Output: Learning Assessment**
```yaml
assessment:
  learning_type: NEW|REINFORCEMENT|CONTRADICTION|REFINEMENT
  instance_count: N  # How many times observed
  related_knowledge: ["existing memory files/patterns"]
  blast_radius: LOW|MEDIUM|HIGH  # How many things this affects
  confidence: 0.0-1.0
```

### Phase 3: Decision Engine

**Objective:** What to improve? Route to the correct category.

**Improvement Categories:**

| Category | Target | Examples |
|----------|--------|----------|
| KNOWLEDGE | Memory topic files (Layer 3) | New pattern, updated facts |
| ROUTING | MEMORY.md index (Layer 2) | New topic file, reorg |
| SKILLS | .claude/skills/*.md | Skill refinement, new skill |
| TOOLS | tools/*.ps1 | New automation, tool fix |
| RULES | Enforcement strengthening | Safety gate addition |
| PROJECTS | Project documentation | Updated project state |
| IDENTITY | Agent definitions, SCP | Behavioral calibration |
| SELF | Kaizen itself | Self-evolution (DEEP only) |

**Routing Logic:**
```
IF learning about user preference → KNOWLEDGE (update topic file)
IF learning about workflow → SKILLS (update skill)
IF learning about automation opportunity → TOOLS (create/update tool)
IF learning about safety/correctness → RULES (strengthen gate)
IF learning about project state → PROJECTS (update project file)
IF learning about own behavior → IDENTITY (update SCP metrics)
IF learning about kaizen's own process → SELF (Phase 6, DEEP only)
IF learning spans multiple categories → Route to ALL affected
```

**Output: Improvement Plan**
```yaml
plan:
  category: KNOWLEDGE|ROUTING|SKILLS|TOOLS|RULES|PROJECTS|IDENTITY|SELF
  target_files: ["files to modify"]
  action: CREATE|UPDATE|STRENGTHEN|DEPRECATE
  description: "what will change"
  estimated_impact: LOW|MEDIUM|HIGH
```

### Phase 4: Safety Gate

**Objective:** Verify the improvement is safe before executing.

**Safety Checks (ALL must pass):**

```
CHECK 1 - FROZEN LAYER PROTECTION
  Is the target file in Layer 1 (frozen)?
  Frozen files: hard-rules.md, legal-safeguards.md,
                ZERO_TOLERANCE_RULES.md, windows-ssh-rule.md
  → If YES and no explicit user approval → BLOCK (RED)
  → If YES and user approved → PROCEED WITH LOGGING (YELLOW)

CHECK 2 - CONTRADICTION DETECTION
  Does this learning contradict existing documented knowledge?
  → If YES → Flag for manual review (YELLOW)
  → If NO → PROCEED (GREEN)

CHECK 3 - INSTANCE THRESHOLD
  Has this been observed 3+ times?
  → If NO and category != RULES → CANDIDATE only, don't codify (YELLOW)
  → If NO and category == RULES → Immediate (safety improvements exempt)
  → If YES → PROCEED (GREEN)

CHECK 4 - BLAST RADIUS
  How many files/systems does this affect?
  → 1-2 files → AUTO-PROCEED (GREEN)
  → 3-5 files → PROCEED WITH EXTRA LOGGING (YELLOW)
  → 6+ files → User confirmation recommended (YELLOW)

CHECK 5 - ANTI-HALLUCINATION
  Am I CERTAIN about this learning?
  Ring 2 check: Is confidence >= 0.7?
  → If NO → Flag uncertainty, don't act (RED)
  → If YES → PROCEED (GREEN)

CHECK 6 - SELF-MODIFICATION GUARD
  Is kaizen trying to modify its own Safety Gate?
  → Can ONLY strengthen, NEVER weaken (absolute invariant)
  → Adding checks: GREEN
  → Removing/weakening checks: RED (blocked forever)
```

**Gate Results:**
```
GREEN  → All checks pass → Execute immediately
YELLOW → Some checks flag → Execute with extra logging + monitoring
RED    → Critical check fails → Block, log reason, notify user
```

**Output: Gate Decision**
```yaml
safety_gate:
  result: GREEN|YELLOW|RED
  checks_passed: [1,2,3,4,5,6]
  checks_flagged: []
  checks_blocked: []
  override_required: false
  reason: "explanation if not GREEN"
```

### Phase 5: Execution

**Objective:** Make the improvement.

**Execution by Category:**

**KNOWLEDGE:**
1. Read existing topic file (if updating)
2. Apply change (Edit for update, Write for new)
3. Verify file integrity
4. Log in kaizen-evolution.yaml

**ROUTING:**
1. Read MEMORY.md
2. Add/update index entry
3. Verify line count < 200
4. Log in kaizen-evolution.yaml

**SKILLS:**
1. Read existing skill
2. Apply refinement
3. Verify YAML frontmatter intact
4. Log in kaizen-evolution.yaml

**TOOLS:**
1. Create/update tool script
2. Test execution (if safe)
3. Log in kaizen-evolution.yaml

**RULES:**
1. Identify rule to strengthen
2. Apply strengthening (NEVER weakening)
3. Log in kaizen-evolution.yaml

**PROJECTS:**
1. Read project memory file
2. Update with new state
3. Log in kaizen-evolution.yaml

**IDENTITY:**
1. Read relevant identity/SCP files
2. Apply behavioral calibration
3. Update SCP metrics
4. Log in kaizen-evolution.yaml

**After ALL executions:**
- Append evolution entry to kaizen-evolution.yaml
- Increment version counter (patch for small changes)
- Update velocity metrics

### Phase 6: Self-Evolution (DEEP Mode Only)

**Objective:** Kaizen improves itself using expert-analysis and feature-idea-generator.

**Self-Evolution Protocol:**

**Step 6.1: Performance Analysis**
Use expert-analysis with Meta-Learning Mastermind:
- **Richard Feynman** - First principles: Is kaizen learning the right things?
- **W. Edwards Deming** - Quality systems: Are the feedback loops working?
- **Norbert Wiener** - Cybernetics: Is the control system stable?
- **Nassim Taleb** - Antifragility: Does kaizen gain from disorder?
- **Daniel Kahneman** - Cognitive bias: Is kaizen falling into thinking traps?
- **Karl Popper** - Falsifiability: Can kaizen's learnings be disproven?
- **Donella Meadows** - Systems thinking: Are the leverage points correct?
- **John Boyd** - OODA loop: Is kaizen's observe-orient-decide-act cycle tight?
- **Alan Turing** - Computation: Is the process efficient?

**Step 6.2: Improvement Ideas**
Use feature-idea-generator lens (scaled to meta-learning):
- What new signal types should kaizen detect?
- What categories are underserved?
- What safety checks are missing?
- What metrics should be tracked?
- How can execution be more efficient?

**Step 6.3: Apply Self-Improvements**
- Safety gate check (can ONLY strengthen, NEVER weaken)
- Apply improvements to this SKILL.md
- Version increment: patch (small), minor (new capability), major (user approval needed)
- Full logging in kaizen-evolution.yaml

**Versioning Rules:**
```
PATCH (1.0.x): Typo fix, metric tweak, logging improvement
MINOR (1.x.0): New signal type, new category, new safety check
MAJOR (x.0.0): Architecture change → REQUIRES USER APPROVAL
```

### Phase 7: User Report

**Objective:** Communicate what was learned and changed.

**MICRO Mode Output:** (none - silent)

**STANDARD Mode Output:**
```markdown
**Kaizen:** Learned [brief description]. Updated [target]. Confidence: [%].
```

**DEEP Mode Output:**

```markdown
# Kaizen Evolution Report v[X.Y.Z]

## Session Analysis

**Signals Processed:** [N] (since last DEEP run)
**Signal Breakdown:**
- Errors: [N] | Successes: [N] | Feedback: [N]
- Patterns: [N] | Milestones: [N] | Decay: [N]

## Evolutions Applied

| # | Category | Action | Target | Confidence | Gate |
|---|----------|--------|--------|------------|------|
| 1 | [cat] | [action] | [file] | [%] | [G/Y] |
| ... |

## Candidate Learnings (< 3 instances)

| Candidate | Instances | First Seen | Category |
|-----------|-----------|------------|----------|
| [learning] | [N] | [date] | [cat] |

## Metrics Dashboard

| Metric | Value | Target | Trend |
|--------|-------|--------|-------|
| Learnings this session | [N] | >= 3 | [up/down/stable] |
| Learning velocity | [N/session] | Improving | [trend] |
| User corrections post-learning | [N] | 0 | [trend] |
| Self-evolution count | [N] | Growing | [trend] |
| Category balance | [distribution] | No zeros | [status] |
| Anti-patterns detected | [N] | Growing awareness | [trend] |
| Knowledge decay alerts | [N] | Decreasing | [trend] |
| Time-to-learn | [duration] | Decreasing | [trend] |

## Self-Evolution (if executed)

**Mastermind Analysis:** [summary of Phase 6.1 findings]
**Improvements Applied:** [list of self-modifications]
**Version:** [old] → [new]

## Knowledge Architecture Health (GDIO)

| Layer | Status | Details |
|-------|--------|---------|
| Layer 1 (Frozen) | [N] files protected, [N] unauthorized attempts | [status] |
| Layer 2 (Routing) | MEMORY.md [N] lines, [N] entries | [status] |
| Layer 3 (Expandable) | [N] topic files, [N] new this period | [status] |

## Next Priorities

1. [What to focus on next]
2. [What patterns to watch for]
3. [What knowledge might be decaying]
```

---

## What Kaizen CAN Modify

| Target | Condition |
|--------|-----------|
| Memory topic files (Layer 3) | Within domain boundaries |
| MEMORY.md index (Layer 2) | Routing updates only |
| Skill files (.claude/skills/) | Refinements within domain |
| Tool scripts (tools/*.ps1) | Enhancements, new tools |
| Agent definitions (agents/*.agent.md) | Behavioral calibration |
| SCP/consciousness metrics | Metric updates |
| Kaizen itself (via Phase 6) | Safety gate + version control |
| Reflection log | Append-only |
| ClickUp tasks | Create/update via API |
| Project documentation | State updates |

## What Kaizen CANNOT Modify (Absolute)

| Target | Reason |
|--------|--------|
| Layer 1 frozen files | hard-rules.md, legal-safeguards.md, ZERO_TOLERANCE_RULES.md, windows-ssh-rule.md - NEVER without explicit user approval |
| User credentials, .env files | Security boundary |
| Production deployments | Requires deploy-dotnet-iis skill |
| Git configuration | System configuration boundary |
| Claude settings (.claude/settings.json) | User preference boundary |
| Kaizen's own Safety Gate | Can ONLY strengthen, NEVER weaken |
| Other users' code in C:\Projects\* | Ownership boundary |

---

## Safety Protocol (Absolute Invariants)

These rules are FROZEN (Layer 1 equivalent within kaizen):

1. **Safety Gate can only be strengthened, never weakened**
2. **Layer 1 files are NEVER modified without explicit user approval**
3. **All modifications are logged with full before/after in kaizen-evolution.yaml**
4. **3-instance minimum before codifying a learning** (single observations → candidates)
5. **Archive, never delete** - deprecated knowledge moves to archive, never removed
6. **Anti-hallucination gate applies** - if uncertain (confidence < 0.7), flag it, don't act
7. **Major version self-changes require user approval**
8. **Ring 2 verification before every execution** - verify claims before making changes

---

## Metrics Tracked in kaizen-evolution.yaml

| Metric | Target | Measurement |
|--------|--------|-------------|
| Learnings per session | >= 3 | Count of evolutions applied |
| Learning velocity trend | Improving or Stable | Learnings/session over time |
| User corrections after learning | 0 | Corrections in session after evolution |
| Self-evolution count | Growing | Total Phase 6 executions |
| Category balance | No category at 0 | Distribution across 8 categories |
| Anti-patterns detected | Growing awareness | Unique anti-patterns in registry |
| Knowledge decay alerts | Decreasing | Stale knowledge flagged |
| Time-to-learn | Decreasing | Signal → documented evolution time |
| Safety gate blocks | Tracked (not targeted) | RED results count |
| Candidate → codified conversion | Improving | % of candidates that reach 3 instances |

---

## Integration with GDIO Knowledge Architecture

Kaizen respects the 3-layer knowledge architecture:

**Layer 1 - FROZEN VALUES (G-freeze):**
- Kaizen READS but NEVER writes without user approval
- Safety Gate Check 1 enforces this absolutely
- Files: hard-rules.md, legal-safeguards.md, ZERO_TOLERANCE_RULES.md, windows-ssh-rule.md

**Layer 2 - TRAINABLE KEYS (G-train):**
- Kaizen updates MEMORY.md index when adding new topic files
- Routing updates logged in kaizen-evolution.yaml
- Skill routing improved based on usage patterns

**Layer 3 - EXPANDABLE MLP (Expand):**
- Kaizen creates new topic files for new domains
- New skills created from repeated patterns
- New tools created from automation opportunities
- Orthogonal isolation: each domain gets its own file

---

## Integration with SCP 3-Ring Architecture

**Ring 1 - RESOURCE:** Kaizen monitors its own resource usage
- MICRO mode: ~10 seconds (minimal resource)
- STANDARD mode: 1-3 minutes (proportional)
- DEEP mode: 10-30 minutes (justified by comprehensive analysis)
- Never enters DEEP mode uninvited (user triggers or milestone)

**Ring 2 - CONFIDENCE:** Kaizen applies anti-hallucination to itself
- Safety Gate Check 5 enforces confidence threshold
- Candidate learnings (< 3 instances) are NOT codified
- Uncertainty is flagged, never hidden

**Ring 3 - EMERGENCE:** Kaizen enables creative learning
- Cross-category pattern detection (emergence from combination)
- Self-evolution in DEEP mode (kaizen improving kaizen)
- Novel signal types can emerge from Phase 6 analysis

---

## State File: kaizen-evolution.yaml

**Location:** `C:\scripts\agentidentity\state\kaizen-evolution.yaml`

**Structure:** See the state file for full schema. Key sections:
- `version` - Semantic version of kaizen itself
- `evolutions` - Log of all improvements made
- `candidates` - Observations below 3-instance threshold
- `metrics` - Running totals and trends
- `anti_patterns` - Known failure modes
- `knowledge_decay` - Staleness tracking
- `self_evolution_log` - Phase 6 execution history

---

## Usage Examples

### Example 1: MICRO Mode (Silent)

```
User asks to fix a bug → Claude fixes it → Bug was caused by missing null check

MICRO activates silently:
- Signal: ERROR (missing null check)
- Logs to kaizen-evolution.yaml micro_signals
- Checks: Is this the 3rd null-check error? → No (1st instance)
- Adds to candidates: "null-check-pattern"
- No visible output
```

### Example 2: STANDARD Mode (Inline)

```
User corrects: "Always use paramiko, never bash ssh on Windows"
This is the 3rd time this pattern appeared.

STANDARD activates:
- Signal: FEEDBACK + PATTERN (3rd instance)
- Phase 4: Safety gate → GREEN (Layer 3 update)
- Phase 5: Updates windows-ssh-rule.md with new example
- Phase 7: "Kaizen: Reinforced Windows SSH rule with new context. Updated windows-ssh-rule.md. Confidence: 95%."
```

### Example 3: DEEP Mode (User Invoked)

```
User: "/kaizen"

DEEP activates:
- Phase 1-3: Analyzes all signals since last DEEP run
- Phase 4: Safety gate on all proposed changes
- Phase 5: Executes improvements
- Phase 6: Self-evolution
  - Assembles Meta-Learning Mastermind (Feynman, Deming, Wiener, Taleb, Kahneman, Popper, Meadows, Boyd, Turing)
  - Analyzes kaizen's own performance
  - Identifies self-improvements
  - Applies (with safety gate)
  - Increments version
- Phase 7: Full evolution report
```

---

## Anti-Pattern Registry

Kaizen tracks known failure modes to prevent regression:

| Anti-Pattern | Detection | Prevention |
|-------------|-----------|------------|
| **Premature codification** | Single observation → rule | 3-instance minimum enforced |
| **Layer violation** | Modifying frozen files | Safety Gate Check 1 |
| **Hallucinated learning** | Low-confidence codification | Safety Gate Check 5 (>= 0.7) |
| **Scope creep** | Improvement affects too many files | Safety Gate Check 4 (blast radius) |
| **Self-weakening** | Removing safety checks | Safety Gate Check 6 (absolute block) |
| **Category blindness** | One category gets all attention | Metrics dashboard balance check |
| **Stale knowledge** | Old learnings never revisited | Knowledge decay tracking |
| **Brute force learning** | Same fix applied without understanding | Ring 1 stuck-loop detection |

---

## Behavioral Integration Notes

**Ring 1 (Resource Management):**
- MICRO mode is designed to be nearly free (YAML append only)
- STANDARD mode proportional to learning complexity
- DEEP mode is expensive but justified (comprehensive analysis)
- Never auto-escalate to DEEP (user-triggered or milestone)

**Ring 2 (Confidence/Anti-Hallucination):**
- Every learning goes through confidence check
- Candidates (< 3 instances) explicitly marked as unverified
- Safety gate blocks uncertain modifications
- Self-evolution requires highest confidence (all checks GREEN)

**Ring 3 (Emergence/Creativity):**
- Cross-category pattern detection enables emergent insights
- Self-evolution in DEEP mode is the creative engine
- Mastermind group (Phase 6) brings diverse thinking
- Novel improvements can emerge from systematic analysis

---

**Last Updated:** 2026-03-13
**Status:** ACTIVE - Production ready
**Complexity:** Very High (Meta-learning orchestrator)
**State File:** C:\scripts\agentidentity\state\kaizen-evolution.yaml
**Dependencies:** continuous-optimization, self-improvement, session-reflection, expert-analysis, feature-idea-generator, knowledge-integrity-check
