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

- Access to session files in `C:\Users\HP\AppData\Roaming\Claude\`
- Memory files in `C:\Users\HP\.claude\projects\C--scripts\memory\`
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
find "C:\Users\HP\AppData\Roaming\Claude" -name "*session*" -type d

# Inventory session files
ls -R "C:\Users\HP\AppData\Roaming\Claude\claude-code-sessions"
ls -R "C:\Users\HP\AppData\Roaming\Claude\local-agent-mode-sessions"

# List memory files
ls "C:\Users\HP\.claude\projects\C--scripts\memory"

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

**Example memory update:**

```markdown
# In MEMORY.md
- `session-retrospective-2026-03-13.md` - **NEW: Batch N analysis - 15 patterns identified, 8 improvements implemented, 3 new rules added**

# New file: anti-patterns-from-retrospective.md
**Pattern 1: Hallucination Without Verification**
- Frequency: 12 occurrences across 8 sessions
- Cost: ~2hrs rework per occurrence = 24hrs total
- Fix: Ring 2 CONFIDENCE gate (already implemented)
- ROI: 95% reduction (post-implementation data)

**Pattern 2: Placeholder Violations in Refinement**
- Frequency: 3 occurrences
- Cost: ~30min rework + trust damage
- Fix: BACKLOG REFINEMENT STANDARD (implemented 2026-03-11)
- ROI: 100% elimination (zero violations post-implementation)
```

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

**Examples:**

```yaml
# High-ROI pattern → Zero Tolerance Rule
Pattern: "SSH on Windows causes popups"
ROI: 100x (5min saved per occurrence × 20 occurrences = 100min)
Action: Create windows-ssh-rule.md with ZERO TOLERANCE

# Complex workflow → Skill
Pattern: "ClickUp refinement requires 4 sections + codebase analysis"
Complexity: 8 steps
Action: Create clickup-refinement skill
```

### Step 7: Kaizen Implementation

**Goal:** Execute improvements using kaizen skill

**Invoke kaizen for each improvement:**

```bash
# For each top-10 improvement
for improvement in top_improvements:
    kaizen --mode STANDARD --target improvement.description
```

**Kaizen orchestrates:**
1. **SENSE:** Validate improvement applies to current system
2. **EXECUTE:** Implement via self-improvement skill
3. **CONSOLIDATE:** Document in session-reflection

**Tracks:**
- Implementation status
- Verification tests
- Rollback if needed

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

# Calculate improvement
improvement = {
    'error_reduction': (baseline.error_rate - after.error_rate) / baseline.error_rate,
    'time_saved': baseline.time_cost - after.time_cost,
    'violation_reduction': (baseline.violation_rate - after.violation_rate) / baseline.violation_rate
}
```

**Creates:**
- `improvement-impact-report.md` - Quantified results
- `roi-validation.json` - Predicted vs actual ROI

### Step 9: Continuous Loop

**Goal:** Run retrospective continuously as new sessions accumulate

**Schedule:**

```yaml
Frequency: Weekly (or after every 10 sessions)
Trigger:
  - User manual trigger: "/retrospective"
  - Automatic: Every 7 days
  - After milestones: Project completion, major refactor

Loop:
  1. Check for new sessions since last retrospective
  2. If new_sessions >= 10: Run Steps 1-8
  3. Update last_retrospective_timestamp
  4. Sleep until next trigger
```

**State file:**

```json
{
  "last_retrospective": "2026-03-13T10:00:00Z",
  "sessions_analyzed": 47,
  "patterns_identified": 156,
  "improvements_implemented": 23,
  "total_roi": "88x",
  "next_scheduled": "2026-03-20T10:00:00Z"
}
```

## Integration with Existing Skills

### Expert-Analysis Integration

```markdown
# This skill USES expert-analysis
- Deep pattern analysis
- Multi-perspective insights
- ROI calculation
- Strategy design

# Call expert-analysis for each batch
Skill: expert-analysis
Args: "Analyze session patterns: [batch_summary]"
```

### Kaizen Integration

```markdown
# This skill USES kaizen for implementation
- Self-improvement orchestration
- Knowledge layer updates
- Skill generation
- Rule enforcement

# Call kaizen for top improvements
Skill: kaizen
Args: "--mode STANDARD --target [improvement]"
```

### Session-Reflection Integration

```markdown
# This skill UPDATES session-reflection
- Documents meta-learnings
- Cross-session patterns
- System evolution tracking

# Call at end of retrospective cycle
Skill: session-reflection
Content: "Retrospective cycle complete: [summary]"
```

### Self-Improvement Integration

```markdown
# This skill USES self-improvement
- Update CLAUDE.md
- Update memory files
- Create new documentation

# Call for each knowledge update
Skill: self-improvement
Content: "New pattern discovered: [pattern]"
```

## Output Artifacts

### Per-Batch Outputs

- `batch-NNN-inventory.json` - Sessions in batch
- `batch-NNN-findings.md` - Extracted patterns
- `batch-NNN-expert-analysis.md` - Expert insights

### Aggregated Outputs

- `pattern-frequency.json` - Pattern occurrence counts
- `improvement-opportunities-ranked.md` - ROI-sorted improvements
- `meta-patterns.md` - Higher-order patterns
- `retrospective-summary.md` - Executive summary

### Memory Updates

- `MEMORY.md` - New topic file entries
- `[new-pattern-domain].md` - New topic files
- `hard-rules.md` - New zero-tolerance rules
- Updated existing topic files

### Tracking Files

- `retrospective-state.json` - Cycle status
- `improvement-impact.md` - Measured results
- `roi-validation.json` - Predicted vs actual

## Examples

### Example 1: Weekly Retrospective

**User says:** "/retrospective"

**Skill activates and:**

1. Discovers 15 new sessions since last run
2. Processes in 2 batches (10min each)
3. Identifies 8 new patterns:
   - 3 anti-patterns (cost: 5hrs total)
   - 5 successful patterns (amplification opportunity)
4. Invokes expert-analysis for deep analysis
5. Generates 4 improvement recommendations (total ROI: 15x)
6. Invokes kaizen to implement top 2 improvements
7. Updates memory with new learnings
8. Generates summary report

**Result:**
- 2 new rules added to hard-rules.md
- 1 new skill created (workflow automation)
- 5hrs of future time saved
- Retrospective complete in 20min

### Example 2: Post-Milestone Analysis

**User says:** "We just finished the Personality Test project. Analyze what we learned."

**Skill activates and:**

1. Filters sessions by project tag "personalitytest"
2. Finds 47 sessions spanning 2 weeks
3. Processes in 5 batches
4. Expert analysis identifies:
   - 4-agent parallel pattern (massive ROI)
   - Task review post-merge backlog pattern
   - File existence verification pattern
5. Creates new memory files:
   - `parallel-implementation-patterns.md`
   - `task-review-patterns.md`
   - `file-existence-verification-pattern.md`
6. Updates personalitytest-project.md with lessons learned
7. ROI: 35 tasks → TESTING in 4hrs (vs 16hrs single-agent)

**Result:**
- 3 new pattern libraries created
- Parallel pattern now available for future projects
- 75% time savings documented and repeatable

### Example 3: Continuous Improvement Loop

**Scenario:** Automatic weekly retrospective

**Week 1:**
- Analyzes 12 sessions
- Identifies "hallucination without verification" pattern
- Cost: 6hrs rework
- Creates Ring 2 CONFIDENCE gate
- Implements via kaizen

**Week 2:**
- Analyzes 14 sessions
- Measures hallucination rate: 95% reduction ✅
- Identifies new pattern: "placeholder violations"
- Creates BACKLOG REFINEMENT STANDARD
- Implements via kaizen

**Week 3:**
- Analyzes 11 sessions
- Measures placeholder violations: 100% elimination ✅
- Identifies new pattern: "parallel agent coordination"
- Creates parallel-agent-coordination skill
- Implements via kaizen

**Week 4:**
- Analyzes 13 sessions
- All previous anti-patterns at near-zero
- Identifies optimization: "batch status sync pattern"
- Documents in task-review-patterns.md

**Cumulative ROI:** 88x (documented in improvement-impact.md)

## Success Criteria

✅ All session files discovered and inventoried
✅ Batches processed systematically (10min windows)
✅ Expert-analysis invoked for deep pattern mining
✅ Patterns aggregated with frequency counts
✅ ROI calculated for each improvement opportunity
✅ Top improvements ranked and prioritized
✅ Memory files updated with new learnings
✅ Zero-tolerance rules created for critical patterns (ROI > 10x)
✅ Skills created for complex workflows (steps > 5)
✅ Kaizen invoked for implementation
✅ Impact measured before/after
✅ Summary report generated
✅ Retrospective state saved for next cycle

## Common Issues

### Issue: Session Files Not Found

**Symptom:** Cannot locate session transcripts

**Cause:** Sessions stored in different location or format

**Solution:**
1. Check multiple locations:
   - `C:\Users\HP\AppData\Roaming\Claude\claude-code-sessions`
   - `C:\Users\HP\AppData\Roaming\Claude\local-agent-mode-sessions`
   - `C:\Users\HP\.claude\sessions`
2. Use memory files as alternative source (reflection.log.md, topic files)
3. Document actual location in retrospective-config.json

### Issue: Expert Analysis Timeout

**Symptom:** Expert-analysis takes too long for large batches

**Cause:** Batch size too large, too much context

**Solution:**
1. Reduce batch size from 10min to 5min windows
2. Pre-filter sessions (exclude trivial ones)
3. Use incremental analysis (analyze diff from previous)

### Issue: Too Many Low-ROI Patterns

**Symptom:** Hundreds of patterns identified, most trivial

**Cause:** Pattern detection too sensitive

**Solution:**
1. Set minimum frequency threshold (>= 3 occurrences)
2. Set minimum cost threshold (>= 30min impact)
3. Focus on top 10 by ROI
4. Archive low-ROI patterns for future reference

### Issue: Memory File Bloat

**Symptom:** Memory files growing too large

**Cause:** Accumulating too many retrospective summaries

**Solution:**
1. Create dated retrospective files (retrospective-2026-03-13.md)
2. Keep only summary in MEMORY.md
3. Archive old retrospectives after 3 months
4. Maintain compact index in MEMORY.md (150 line limit)

## Performance Metrics

### Cycle Time
- **Target:** Complete retrospective in < 30min
- **Measurement:** Start to summary report
- **Optimization:** Parallel batch processing

### Pattern Discovery
- **Target:** >= 5 actionable patterns per retrospective
- **Measurement:** Count patterns with ROI > 5x
- **Quality gate:** Expert confidence >= 80%

### Implementation Rate
- **Target:** >= 50% of top-10 improvements implemented
- **Measurement:** Kaizen execution success rate
- **Tracking:** improvement-impact.md

### ROI Validation
- **Target:** Predicted ROI within 20% of actual
- **Measurement:** Compare predicted vs measured impact
- **Refinement:** Improve ROI estimation model

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
      "C:\\Users\\HP\\AppData\\Roaming\\Claude\\claude-code-sessions",
      "C:\\Users\\HP\\AppData\\Roaming\\Claude\\local-agent-mode-sessions"
    ],
    "memory_dir": "C:\\Users\\HP\\.claude\\projects\\C--scripts\\memory",
    "reflection_log": "C:\\scripts\\_machine\\reflection.log.md"
  }
}
```

## Advanced Features

### Multi-Agent Session Analysis

When multiple agents worked in parallel:

```python
# Detect multi-agent patterns
parallel_sessions = find_parallel_sessions()
coordination_patterns = analyze_coordination(parallel_sessions)

# Example: 4-agent Personality Test pattern
# 35 tasks → TESTING in 4hrs
# ROI: 4x speedup vs single agent
```

### Cross-Project Pattern Transfer

```python
# Identify successful patterns in Project A
project_a_patterns = analyze_project('personalitytest')

# Apply to Project B
apply_patterns_to('codehub', project_a_patterns)

# Measure transfer effectiveness
```

### Predictive Improvement Modeling

```python
# Build model from historical retrospectives
model = train_improvement_model(all_retrospectives)

# Predict ROI of new improvements
predicted_roi = model.predict(new_pattern)

# Prioritize by predicted impact
```

---

**Created:** 2026-03-13
**Author:** Jengo (Continuous Evolution Engine)
**Integration:** expert-analysis + kaizen + session-reflection + self-improvement
**Status:** PRODUCTION READY
