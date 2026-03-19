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
```

**Orchestration Roles:**
- `continuous-optimization` = SENSE (detect learning signals)
- `self-improvement` = EXECUTE (make the improvements)
- `session-reflection` = CONSOLIDATE (log and verify)
- `expert-analysis` = ANALYZE (deep insight for DEEP mode)
- `feature-idea-generator` = IDEATE (improvement ideas for self-evolution)

---

## 3 Operating Modes

| Mode | When | Duration | Output |
|------|------|----------|--------|
| **MICRO** | After every significant interaction (silent) | ~10 sec | None visible |
| **STANDARD** | Error, success, feedback, pattern detected | 1-3 min | Inline learning summary |
| **DEEP** | User invokes `/kaizen`, milestones, periodic | 10-30 min | Full analysis report |

### MICRO Mode (Silent, Every Interaction)

**Trigger:** Automatically after any significant interaction
**Actions:**
1. Classify signal (ERROR/SUCCESS/FEEDBACK/PATTERN/MILESTONE)
2. Log to kaizen-evolution.yaml `micro_signals` array
3. Increment relevant counters
4. Check if 3-instance threshold reached
5. If threshold met → escalate to STANDARD mode

### STANDARD Mode (Inline Learning)

**Trigger:** Error corrected, user feedback, success pattern, 3-instance threshold

**Output:**
```markdown
**Kaizen:** Learned [brief description]. Updated [file]. Confidence: [%].
```

### DEEP Mode (Full Analysis + Self-Evolution)

**Trigger:** User invokes `/kaizen`, milestone reached, or periodic (every 10 sessions)
**Actions:**
1. Run complete 7-phase workflow
2. Use expert-analysis mastermind for meta-learning analysis
3. Execute self-evolution (Phase 6)
4. Generate comprehensive report

---

## 7 Workflow Phases

### Phase 1: Context Sensing

**Signal Classification:**
```
ERROR     → Mistake made, user corrected, approach failed
SUCCESS   → Solution worked, user approved, pattern validated
FEEDBACK  → User expressed preference, frustration, or appreciation
PATTERN   → Same situation encountered 3+ times
MILESTONE → Project completed, major feature shipped, session ended
DECAY     → Knowledge outdated, tool broken, skill stale
```

### Phase 2: Reflection

**Key Questions:**
- Have I seen this before? (check candidate_learnings in YAML)
- Does this confirm or contradict existing knowledge?
- What is the blast radius of this learning?
- Is this a single observation or part of a pattern?

### Phase 3: Decision Engine

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

### Phase 4: Safety Gate

**Safety Checks (ALL must pass):**

```
CHECK 1 - FROZEN LAYER PROTECTION
  Layer 1 files (hard-rules.md, ZERO_TOLERANCE_RULES.md, etc.)
  → Never modify without explicit user approval

CHECK 2 - CONTRADICTION DETECTION
  Does this learning contradict existing documented knowledge?

CHECK 3 - INSTANCE THRESHOLD
  Has this been observed 3+ times?
  Exception: Safety improvements are immediate

CHECK 4 - BLAST RADIUS
  1-2 files → AUTO-PROCEED
  3-5 files → PROCEED WITH EXTRA LOGGING
  6+ files → User confirmation recommended

CHECK 5 - ANTI-HALLUCINATION
  Confidence >= 0.7?

CHECK 6 - SELF-MODIFICATION GUARD
  Kaizen can ONLY strengthen its Safety Gate, NEVER weaken
```

**Gate Results:**
```
GREEN  → All checks pass → Execute immediately
YELLOW → Some checks flag → Execute with extra logging
RED    → Critical check fails → Block, log reason, notify user
```

### Phase 5: Execution

**After ALL executions:**
- Append evolution entry to kaizen-evolution.yaml
- Increment version counter (patch for small changes)
- Update velocity metrics

### Phase 6: Self-Evolution (DEEP Mode Only)

**Meta-Learning Mastermind:**
- Richard Feynman - First principles: Is kaizen learning the right things?
- W. Edwards Deming - Quality systems: Are the feedback loops working?
- Norbert Wiener - Cybernetics: Is the control system stable?
- Nassim Taleb - Antifragility: Does kaizen gain from disorder?
- Daniel Kahneman - Cognitive bias: Is kaizen falling into thinking traps?
- Karl Popper - Falsifiability: Can kaizen's learnings be disproven?
- Donella Meadows - Systems thinking: Are the leverage points correct?
- John Boyd - OODA loop: Is kaizen's cycle tight?
- Alan Turing - Computation: Is the process efficient?

**Versioning Rules:**
```
PATCH (1.0.x): Typo fix, metric tweak, logging improvement
MINOR (1.x.0): New signal type, new category, new safety check
MAJOR (x.0.0): Architecture change → REQUIRES USER APPROVAL
```

### Phase 7: User Report

**DEEP Mode Output:**

```markdown
# Kaizen Evolution Report v[X.Y.Z]

## Session Analysis
**Signals Processed:** [N]
**Signal Breakdown:** Errors/Successes/Feedback/Patterns/Milestones/Decay

## Evolutions Applied
| # | Category | Action | Target | Confidence | Gate |

## Candidate Learnings (< 3 instances)
| Candidate | Instances | First Seen | Category |

## Metrics Dashboard
| Metric | Value | Target | Trend |
```

---

## What Kaizen CAN Modify

| Target | Condition |
|--------|-----------|
| Memory topic files (Layer 3) | Within domain boundaries |
| MEMORY.md index (Layer 2) | Routing updates only |
| Skill files (.claude/skills/) | Refinements within domain |
| Tool scripts (tools/*.ps1) | Enhancements, new tools |
| Agent definitions | Behavioral calibration |
| Reflection log | Append-only |
| ClickUp tasks | Create/update via API |

## What Kaizen CANNOT Modify (Absolute)

| Target | Reason |
|--------|--------|
| Layer 1 frozen files | hard-rules.md, ZERO_TOLERANCE_RULES.md - NEVER without user approval |
| User credentials, .env files | Security boundary |
| Production deployments | Requires deploy-dotnet-iis skill |
| Kaizen's own Safety Gate | Can ONLY strengthen, NEVER weaken |

---

## Safety Protocol (Absolute Invariants)

1. **Safety Gate can only be strengthened, never weakened**
2. **Layer 1 files are NEVER modified without explicit user approval**
3. **All modifications are logged with full before/after**
4. **3-instance minimum before codifying a learning**
5. **Archive, never delete** - deprecated knowledge moves to archive
6. **Anti-hallucination gate applies** - if confidence < 0.7, flag it, don't act
7. **Major version self-changes require user approval**

---

## State File

**Location:** `C:\scripts\agentidentity\state\kaizen-evolution.yaml`

**Key sections:**
- `version` - Semantic version of kaizen itself
- `evolutions` - Log of all improvements made
- `candidates` - Observations below 3-instance threshold
- `metrics` - Running totals and trends
- `anti_patterns` - Known failure modes
- `self_evolution_log` - Phase 6 execution history

---

**Last Updated:** 2026-03-13
**Status:** ACTIVE - Production ready
**Complexity:** Very High (Meta-learning orchestrator)
**Dependencies:** continuous-optimization, self-improvement, session-reflection, expert-analysis, feature-idea-generator
