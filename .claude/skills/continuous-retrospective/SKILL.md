---
name: continuous-retrospective
description: Systematic session analysis using expert mastermind to identify improvement patterns. Analyzes all historical sessions, extracts learnings, and implements system-wide improvements. Use when user asks for retrospective, session analysis, pattern recognition, continuous improvement, or "analyze all our sessions".
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Skill, Task
user-invocable: true
---

# Continuous Retrospective

**Purpose:** Deep retrospective analysis of all Claude Code sessions to identify improvement patterns, extract actionable insights, and implement system-wide optimizations through continuous learning cycles.

## When to Use This Skill

**Use when:**
- User explicitly requests session retrospective or analysis
- User asks to "analyze patterns in our work"
- User wants to identify improvement opportunities
- Periodic system health checks (weekly/monthly)
- After major milestones to extract learnings
- User asks "what can we improve?" or "what patterns do you see?"

**Auto-activate when user says:**
- "Analyze all our sessions"
- "Do a retrospective"
- "What patterns do you see in our work?"
- "How can we improve our workflow?"
- "Look back at everything we've done"

## Prerequisites

- Access to session files in `C:\Users\marti\AppData\Roaming\Claude\`
- Memory files in `C:\Users\marti\.claude\projects\C--scripts\memory\`
- Reflection log at `C:\scripts\_machine\reflection.log.md`
- Expert-analysis skill available
- Kaizen skill available (for implementation)

## Architecture

This skill operates in **continuous 10-minute analysis cycles**:

```
┌─────────────────────────────────────────────────────────────┐
│  CONTINUOUS RETROSPECTIVE ENGINE                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   DISCOVER   │ -> │   ANALYZE    │ -> │  IMPLEMENT   │  │
│  │              │    │              │    │              │  │
│  │ • Sessions   │    │ • Expert     │    │ • Update     │  │
│  │ • Memory     │    │   Analysis   │    │   Memory     │  │
│  │ • Reflection │    │ • Pattern    │    │ • Update     │  │
│  │ • Metrics    │    │   Mining     │    │   Rules      │  │
│  │              │    │ • ROI Calc   │    │ • Kaizen     │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         │                    │                    │         │
│         └────────────────────┴────────────────────┘         │
│                         Loop Every 10min                    │
└─────────────────────────────────────────────────────────────┘
```

## Workflow Steps

### Step 1: Session Discovery & Inventory

**Goal:** Locate and catalog all available session data

```bash
# Find all session storage locations
find "C:\Users\marti\AppData\Roaming\Claude" -name "*session*" -type d

# Inventory session files
ls -R "C:\Users\marti\AppData\Roaming\Claude\claude-code-sessions"
ls -R "C:\Users\marti\AppData\Roaming\Claude\local-agent-mode-sessions"

# List memory files
ls "C:\Users\marti\.claude\projects\C--scripts\memory"

# Read reflection log
cat "C:\scripts\_machine\reflection.log.md"
```

**Outputs:**
- `session-inventory.json` - Complete catalog of sessions
- `data-sources.md` - Available data sources and locations

### Step 2: Batch Session Analysis (10-minute windows)

**Goal:** Process sessions in digestible 10-minute batches

```python
# Pseudocode for batch processing
batch_size = 10_minutes_of_sessions
sessions = discover_all_sessions()

for batch in sessions.chunk(batch_size):
    findings = analyze_batch(batch)
    save_findings(findings)
    update_patterns(findings)
```

**For each batch:**
1. Read session transcripts/metadata
2. Extract key events (errors, successes, patterns)
3. Identify anti-patterns and violations
4. Document learnings
5. Calculate impact metrics

**Creates:**
- `batch-001-findings.md` - Findings from batch 1
- `batch-002-findings.md` - Findings from batch 2
- etc.

### Step 3: Expert Mastermind Analysis

**Goal:** Deep pattern analysis using expert-analysis skill

**Invoke expert-analysis with:**

```markdown
SITUATION:
Analyzing Claude Code session batch [N] covering [date range].

SESSIONS ANALYZED:
- Session 1: [summary]
- Session 2: [summary]
...

OBSERVED PATTERNS:
- Pattern A: [description + frequency]
- Pattern B: [description + frequency]
...

ANTI-PATTERNS DETECTED:
- Anti-pattern X: [description + cost]
- Anti-pattern Y: [description + cost]
...

QUESTION:
What systematic improvements can we extract from these patterns?
What rules/skills/workflows would prevent anti-patterns?
What hidden opportunities exist in successful patterns?

REQUIRED ANALYSIS:
1. Root cause analysis of anti-patterns
2. Success factor extraction from positive patterns
3. Generalization to system-wide improvements
4. ROI estimation for each improvement
5. Implementation strategy recommendations
```

**Expert panel assembles:**
- **Systems Thinkers:** Peter Senge, Donella Meadows (pattern emergence)
- **Learning Theorists:** Carol Dweck, Anders Ericsson (continuous improvement)
- **Software Architects:** Martin Fowler, Kent Beck (code patterns)
- **Process Engineers:** W. Edwards Deming, Taiichi Ohno (workflow optimization)
- **Data Scientists:** (quantitative pattern mining)
- **Behavioral Psychologists:** (habit formation, behavior change)

**Outputs:**
- `expert-analysis-batch-N.md` - Deep analysis report
- Patterns with confidence scores
- Improvement recommendations with ROI
- Implementation strategies

### Step 4: Pattern Mining & Aggregation

**Goal:** Aggregate findings across all batches to identify meta-patterns

```python
# Aggregate all batch findings
all_findings = load_all_batch_findings()

# Pattern frequency analysis
patterns = extract_patterns(all_findings)
pattern_frequency = count_occurrences(patterns)

# Impact calculation
for pattern in patterns:
    pattern.cost = calculate_cost(pattern)
    pattern.benefit = calculate_benefit_if_fixed(pattern)
    pattern.roi = pattern.benefit / pattern.cost

# Sort by ROI
top_improvements = patterns.sort_by('roi').top(10)
```

**Metrics tracked:**
- Pattern frequency (how often does X occur?)
- Time cost (how much time wasted on Y?)
- Success rate (what % of Z succeeded?)
- Violation rate (how often violated rule R?)
- Impact score (ROI of fixing anti-pattern A)

**Creates:**
- `pattern-aggregation.md` - Cross-batch patterns
- `improvement-opportunities.json` - Ranked by ROI
- `meta-patterns.md` - Patterns about patterns

### Step 5: Memory System Update

**Goal:** Encode learnings into persistent memory

**Update these memory files:**

1. **MEMORY.md** - Add new topic file references
2. **hard-rules.md** - Add ZERO TOLERANCE rules if pattern is critical
3. **[new-topic].md** - Create new topic file for new pattern domain
4. **existing-patterns.md** - Update existing files with new insights

### Step 6: Rule & Skill Generation

**Goal:** Convert high-ROI patterns into enforceable rules and skills

**For critical patterns (ROI > 10x):**

```markdown
IF pattern.roi > 10 AND pattern.frequency > 3:
    CREATE zero_tolerance_rule(pattern)
    ADD to hard-rules.md
    UPDATE MEMORY.md with ZERO TOLERANCE annotation
```

**For complex workflows (steps > 5):**

```markdown
IF pattern.is_workflow AND pattern.complexity > 5:
    CREATE skill(pattern)
    ADD to .claude/skills/
    UPDATE skill index
```

### Step 7: Kaizen Implementation

**Goal:** Execute improvements using kaizen skill

**Invoke kaizen for each improvement:**

```bash
# For each top-10 improvement
Skill: kaizen
Mode: STANDARD
Target: [improvement description]
```

### Step 8: Impact Measurement

**Goal:** Measure effectiveness of improvements

**Before/After metrics:**

```python
# Baseline (before improvement)
baseline = {
    'error_rate': measure_errors_before(),
    'time_cost': measure_time_before(),
    'violation_rate': measure_violations_before()
}

# After improvement
after = {
    'error_rate': measure_errors_after(),
    'time_cost': measure_time_after(),
    'violation_rate': measure_violations_after()
}
```

## Related Skills

- **expert-analysis** - Deep pattern analysis engine
- **kaizen** - Implementation orchestration
- **session-reflection** - Single-session learnings
- **self-improvement** - Knowledge layer updates
- **continuous-optimization** - Real-time optimization

## Configuration

**Default config (`retrospective-config.json`):**

```json
{
  "batch_size_minutes": 10,
  "min_pattern_frequency": 3,
  "min_pattern_cost_minutes": 30,
  "roi_threshold_for_zero_tolerance": 10,
  "skill_creation_complexity_threshold": 5,
  "expert_analysis_enabled": true,
  "kaizen_auto_implementation": true,
  "schedule": {
    "frequency": "weekly",
    "auto_trigger_after_sessions": 10
  },
  "sources": {
    "session_dirs": [
      "C:\\Users\\marti\\AppData\\Roaming\\Claude\\claude-code-sessions",
      "C:\\Users\\marti\\AppData\\Roaming\\Claude\\local-agent-mode-sessions"
    ],
    "memory_dir": "C:\\Users\\marti\\.claude\\projects\\C--scripts\\memory",
    "reflection_log": "C:\\scripts\\_machine\\reflection.log.md"
  }
}
```

---

**Created:** 2026-03-13
**Author:** Jengo (Continuous Evolution Engine)
**Integration:** expert-analysis + kaizen + session-reflection + self-improvement
**Status:** PRODUCTION READY
