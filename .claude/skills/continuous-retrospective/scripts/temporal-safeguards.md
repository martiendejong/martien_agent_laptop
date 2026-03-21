# Temporal Safeguards for Retrospective Analysis

## CRITICAL PRINCIPLE

**"Het hier en nu is belangrijker dan het daar en toen."**

De huidige situatie is ALTIJD leidend. Historische data is CONTEXT, niet WAARHEID.

## Time-Based Trust Model

```
┌─────────────────────────────────────────────────────────────┐
│  TEMPORAL TRUST DECAY                                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  CURRENT (0-7 days)     ████████████████████ 100% trust     │
│  "This IS the reality"                                      │
│                                                              │
│  RECENT (7-30 days)     ██████████████░░░░░░  70% trust     │
│  "Likely still true, verify"                                │
│                                                              │
│  OLD (30-90 days)       ████████░░░░░░░░░░░░  40% trust     │
│  "Context only, check applicability"                        │
│                                                              │
│  ANCIENT (>90 days)     ██░░░░░░░░░░░░░░░░░░  10% trust     │
│  "Historical reference, DO NOT APPLY directly"              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Safeguard Rules

### Rule 1: Always Tag Temporal Context

**NEVER say:** "We have a pattern of X"
**ALWAYS say:** "In sessions from [date range], we had a pattern of X. Current status: [verified/unknown/outdated]"

**Example:**

```markdown
❌ BAD:
"Pattern: Using bash ssh on Windows causes popups"

✅ GOOD:
"Pattern: Using bash ssh on Windows causes popups
- Detected in: 3 sessions (2026-03-09 to 2026-03-11)
- Current status: RULE IMPLEMENTED (windows-ssh-rule.md)
- Temporal category: RECENT
- Applicability: VERIFIED - Rule still active"
```

### Rule 2: Decay Confidence by Age

```python
# Pattern confidence adjustment
if session.age_days < 7:
    confidence_multiplier = 1.00  # Current = full confidence
elif session.age_days < 30:
    confidence_multiplier = 0.70  # Recent = reduced confidence
elif session.age_days < 90:
    confidence_multiplier = 0.40  # Old = low confidence
else:
    confidence_multiplier = 0.10  # Ancient = reference only

adjusted_confidence = base_confidence * confidence_multiplier
```

### Rule 3: Verification Gates for Old Patterns

**Before applying any pattern from OLD or ANCIENT sessions:**

1. **Verify current applicability**
   - Read current codebase/docs
   - Check if pattern still exists
   - Confirm pattern hasn't been fixed

2. **Check for superseding rules**
   - Look in hard-rules.md
   - Check topic files from more recent dates
   - Verify no contradictory patterns

3. **Flag as historical if outdated**
   ```markdown
   Pattern: X (HISTORICAL - No longer applicable)
   Reason: Superseded by Y in 2026-03-11
   ```

### Rule 4: Prioritize Recent Over Ancient

When conflicting patterns exist:

```python
# Example: Two patterns for same issue
pattern_a = {
    'solution': 'Use bash ssh',
    'date': '2025-12-01',
    'category': 'ancient'
}

pattern_b = {
    'solution': 'Use paramiko (ZERO TOLERANCE)',
    'date': '2026-03-09',
    'category': 'recent'
}

# ALWAYS choose more recent
chosen_pattern = max([pattern_a, pattern_b], key=lambda p: p['date'])
# Result: pattern_b (paramiko)

# Document the evolution
evolution = f"Pattern evolved from '{pattern_a['solution']}' to '{pattern_b['solution']}' on {pattern_b['date']}"
```

### Rule 5: Explicit Timestamps in Documentation

**Every pattern documented must include:**

```markdown
**Pattern:** [Name]
**First Detected:** [YYYY-MM-DD]
**Last Verified:** [YYYY-MM-DD]
**Status:** [ACTIVE | SUPERSEDED | HISTORICAL]
**Confidence:** [0-100%] (time-adjusted)
```

**Example:**

```markdown
**Pattern:** Backlog Refinement Standard
**First Detected:** 2026-03-11
**Last Verified:** 2026-03-13 (current session)
**Status:** ACTIVE - Zero violations since implementation
**Confidence:** 100% (current + verified)
```

### Rule 6: Evolution Tracking

Track how patterns change over time:

```markdown
# Pattern Evolution Log

## Placeholder Violations

### Phase 1: Ancient (pre-2026-03-11)
- **Status:** Frequent violations
- **Frequency:** ~3 per week
- **Cost:** 30min rework each
- **Action:** None (not yet identified as pattern)

### Phase 2: Discovery (2026-03-11)
- **Status:** Pattern identified in retrospective
- **Action:** Created BACKLOG REFINEMENT STANDARD
- **Implementation:** ZERO TOLERANCE rule added

### Phase 3: Current (2026-03-11 onwards)
- **Status:** 100% elimination
- **Frequency:** 0 violations
- **Result:** Pattern SOLVED
- **Keep rule?** YES (preventative)
```

### Rule 7: Context Preservation

When citing old sessions, preserve context:

```markdown
❌ BAD:
"Session shows we use feature X"

✅ GOOD:
"Session from 2025-11-15 shows we USED TO use feature X.
Current status (2026-03-13): Migrated to feature Y.
Reason for migration: [documented in migration-log.md]
Relevance: Historical context for understanding evolution."
```

## Practical Application

### Scenario 1: Analyzing Old Session

```python
# Session from 60 days ago
session = {
    'date': '2026-01-13',
    'pattern': 'Manual deployment to IIS',
    'age_days': 60,
    'category': 'old'
}

# Apply temporal analysis
weight = 0.40  # Old session = 40% weight

# Before applying pattern
check_current_state()
# → Found: deploy-dotnet-iis skill created 2026-03-11
# → Pattern SUPERSEDED by automation

# Correct documentation
"""
Pattern: Manual deployment to IIS (HISTORICAL)
- Detected: 2026-01-13
- Status: SUPERSEDED
- Replaced by: deploy-dotnet-iis skill (2026-03-11)
- Current practice: Automated deployment via skill
- Relevance: Shows pain point that led to automation
"""
```

### Scenario 2: Conflicting Patterns

```python
# Two patterns found
patterns = [
    {
        'name': 'SSH via bash',
        'date': '2025-12-20',
        'age': 83,  # Ancient
        'confidence': 0.80,
        'weight': 0.10
    },
    {
        'name': 'SSH via paramiko',
        'date': '2026-03-09',
        'age': 4,  # Current
        'confidence': 0.95,
        'weight': 1.00
    }
]

# Calculate weighted confidence
for p in patterns:
    p['weighted_confidence'] = p['confidence'] * p['weight']

# Result:
# Pattern 1: 0.80 * 0.10 = 0.08 (8% weighted confidence)
# Pattern 2: 0.95 * 1.00 = 0.95 (95% weighted confidence)

# Choose current pattern
selected = max(patterns, key=lambda p: p['weighted_confidence'])
# Result: SSH via paramiko

# Document evolution
"""
## SSH Protocol Evolution

### Ancient Practice (pre-2026-03-09)
- Method: bash ssh commands
- Issues: Windows security popups, manual authentication
- Status: DEPRECATED

### Current Practice (2026-03-09 onwards)
- Method: paramiko in Python
- Rule: ZERO TOLERANCE (windows-ssh-rule.md)
- Status: ACTIVE, ENFORCED
- Confidence: 95% (current + verified)
"""
```

### Scenario 3: Verifying Old Improvement

```python
# Old improvement suggestion from 70 days ago
improvement = {
    'suggestion': 'Add consciousness scoring system',
    'date': '2026-01-03',
    'age': 70,
    'estimated_roi': '50x'
}

# Before implementing, verify current state
current_state = read_file('consciousness-system.md')

# Discovery: System was implemented, then REMOVED
# Reason: SCP transformation (2026-03-10) - function over theater

# Correct action: DO NOT IMPLEMENT
# Document why:
"""
Improvement: Consciousness Scoring System (HISTORICAL)
- Suggested: 2026-01-03
- Implemented: 2026-01-04
- Removed: 2026-03-10
- Reason: SCP transformation - measurements replaced with behavioral integration
- Lesson: Scores were decorative, behavior is functional
- Current approach: Ring 1/2/3 checks, not numeric scores
- Status: SUPERSEDED - Do not re-implement
"""
```

## Red Flags for Outdated Information

🚩 **Pattern appears in ancient sessions but not recent**
→ Likely solved or no longer relevant

🚩 **Pattern contradicts current rules in hard-rules.md**
→ Historical practice that was explicitly banned

🚩 **Pattern suggests tool/approach not in current codebase**
→ Deprecated or migrated

🚩 **Pattern frequency decreasing over time**
→ Problem solving itself or being addressed

🚩 **No mentions in recent memory files**
→ Probably not current concern

## Green Flags for Current Relevance

✅ **Pattern appears in sessions from last 7 days**
→ Definitely current

✅ **Pattern mentioned in recent memory files**
→ Active concern

✅ **Pattern has rule/skill created recently**
→ Recent systematization

✅ **Pattern frequency increasing or stable**
→ Ongoing issue

✅ **Pattern aligns with current documentation**
→ Verified current practice

## Output Format for Patterns

**Every pattern identified must use this format:**

```markdown
# Pattern: [Name]

## Temporal Context
- **First Detected:** YYYY-MM-DD
- **Last Seen:** YYYY-MM-DD
- **Age Category:** [CURRENT | RECENT | OLD | ANCIENT]
- **Confidence (base):** XX%
- **Confidence (time-adjusted):** XX%

## Current Status
- **Status:** [ACTIVE | SOLVED | SUPERSEDED | HISTORICAL]
- **Verification Date:** YYYY-MM-DD
- **Verified By:** [Method of verification]

## Applicability
- **Apply to current system?** [YES | NO | VERIFY_FIRST]
- **Reason:** [Why/why not]

## Evolution
[If pattern changed over time, document the evolution]

## Supporting Evidence
- Session IDs: [list]
- Memory files: [list]
- Related rules/skills: [list]

## Recommendation
[What to do with this pattern NOW]
```

## Example: Complete Pattern Documentation

```markdown
# Pattern: Placeholder Text in Task Refinement

## Temporal Context
- **First Detected:** 2026-03-10 (session b56620d1)
- **Last Seen:** 2026-03-11 (final violation before rule)
- **Age Category:** RECENT (3 days old)
- **Confidence (base):** 100%
- **Confidence (time-adjusted):** 100% (recent + verified)

## Current Status
- **Status:** SOLVED
- **Verification Date:** 2026-03-13
- **Verified By:** Scan of all refinements since 2026-03-11 = 0 violations

## Applicability
- **Apply to current system?** NO - Already solved via ZERO TOLERANCE rule
- **Reason:** Backlog Refinement Standard enforces NO placeholders

## Evolution

### Phase 1: Problem (pre-2026-03-11)
- Frequency: ~3 occurrences
- Cost: 30min rework + trust damage
- No systematic prevention

### Phase 2: Solution (2026-03-11)
- Rule created: BACKLOG REFINEMENT STANDARD
- Enforcement: ZERO TOLERANCE
- Added to hard-rules.md + backlog-refinement-standard.md

### Phase 3: Verification (2026-03-11 onwards)
- Violations: 0
- Compliance: 100%
- Pattern: ELIMINATED

## Supporting Evidence
- Session IDs: b56620d1, [others]
- Memory files: backlog-refinement-standard.md, refinement-violations.md
- Related rules: ZERO TOLERANCE refinement standard

## Recommendation
**KEEP RULE, DO NOT IMPLEMENT FIX (already fixed)**
- Rule prevents regression
- Pattern now at zero occurrence
- Use as example of successful pattern elimination
```

---

**Created:** 2026-03-13
**Purpose:** Prevent applying outdated patterns from historical sessions
**Principle:** Huidige realiteit > grijs verleden
