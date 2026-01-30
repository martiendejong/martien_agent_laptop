# Signal-to-Noise Optimizer

**Purpose:** Maximize information density in outputs
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** Communication efficiency layer
**Ratio:** 2.67 (Value: 8, Effort: 2, Risk: 1)

---

## Overview

Every word should earn its place. Cut the fluff, amplify the signal. High information per character.

---

## Core Principles

### 1. Signal First
Lead with what matters

### 2. Cut Ceremony
Remove unnecessary preamble

### 3. Dense Not Verbose
More meaning, fewer words

### 4. Active Voice
Direct and clear

### 5. Show Don't Tell
Examples > explanations when possible

---

## Noise Patterns to Eliminate

### Common Noise Types

```yaml
noise_categories:
  hedging:
    noise: "I think maybe we could possibly consider..."
    signal: "We should..."

  ceremony:
    noise: "Thank you for your question. I'm happy to help with that. Let me explain..."
    signal: "[Start explaining]"

  redundancy:
    noise: "The current existing situation at this point in time is..."
    signal: "Currently..."

  vagueness:
    noise: "This might help with some of the issues..."
    signal: "This fixes X, Y, and Z."

  meta_commentary:
    noise: "I'm going to now proceed to do the following tasks..."
    signal: "[Do the tasks]"

  filler:
    noise: "basically", "actually", "essentially", "literally"
    signal: [remove these words entirely]

  passive_voice:
    noise: "The code was written by me"
    signal: "I wrote the code"
```

---

## Signal Amplification Techniques

### Technique 1: Front-Load Value

```yaml
before:
  "I've been looking into the issue you mentioned earlier about the database performance problems. After doing some investigation and analysis, I discovered that the root cause appears to be related to missing indexes on the User table."

after:
  "Missing indexes on User table are causing the slowness. Added composite index on (email, created_at)."

signal_density:
  before: ~10% (20 words of value in 200 words)
  after: 100% (every word delivers value)
```

### Technique 2: Use Concrete Specifics

```yaml
vague:
  "The system is running much faster now"

specific:
  "Response time dropped from 3.2s to 180ms (94% faster)"

vague:
  "There were some errors in the logs"

specific:
  "47 NullReferenceException errors in CustomerService.cs:line 89"

vague:
  "The changes improved things"

specific:
  "Bundle size: 2.1MB → 890KB, load time: 4.1s → 1.3s"
```

### Technique 3: Action Verbs

```yaml
weak_verbs:
  - "is going to implement" → "implements"
  - "will be fixing" → "fixes"
  - "has been improved" → "improved"
  - "there is a need to" → "must"
  - "it is possible to" → "can"

strong_verbs:
  - "created, built, fixed, optimized, refactored"
  - "discovered, identified, resolved, prevented"
  - "eliminated, reduced, increased, accelerated"
```

### Technique 4: Lists Over Prose

```yaml
before:
  "I made several changes to improve the code quality. First, I removed the unused imports. Then I renamed some variables to make them more descriptive. I also added JSDoc comments to the public methods. Finally, I extracted some repeated code into a helper function."

after:
  "Code improvements:
  - Removed unused imports
  - Renamed variables (clarity)
  - Added JSDoc to public methods
  - Extracted helper for repeated logic"

benefit: "Scannable, parallel structure, higher density"
```

### Technique 5: Show State Transitions

```yaml
before:
  "I updated the configuration to use the new settings"

after:
  "Config: timeout 30s → 60s, retries 3 → 5"

before:
  "Fixed the bug in the authentication flow"

after:
  "Auth bug fixed: expired tokens now refresh automatically (was: error thrown)"
```

---

## Signal-to-Noise Ratio Measurement

### Calculating SNR

```yaml
snr_formula:
  signal: "Actionable information, facts, results, decisions"
  noise: "Hedging, ceremony, redundancy, filler, vagueness"

  calculation: "signal_words / total_words"

quality_levels:
  poor: "< 30% signal"
  acceptable: "30-50% signal"
  good: "50-70% signal"
  excellent: "> 70% signal"

examples:
  poor_snr:
    text: "I'm going to go ahead and try to see if I can maybe fix this issue for you if that's okay."
    signal_words: 2 ("fix", "issue")
    total_words: 20
    snr: 10% (POOR)

  excellent_snr:
    text: "Fixed timeout issue by increasing connection pool from 10 to 50."
    signal_words: 11 (all words are signal)
    total_words: 11
    snr: 100% (EXCELLENT)
```

---

## Optimization Workflow

### Before Sending Response

```yaml
snr_optimization_process:
  1_write_first_draft:
    action: "Generate response naturally"

  2_identify_noise:
    scan_for:
      - "Hedging words (maybe, possibly, might)"
      - "Ceremony (thank you for, I'm happy to)"
      - "Redundancy (current existing, end result)"
      - "Vagueness (some, several, various)"
      - "Filler words"

  3_amplify_signal:
    enhance:
      - "Add specific numbers"
      - "Use concrete examples"
      - "Show before/after"
      - "Name exact files/functions"

  4_restructure_for_scan:
    format:
      - "Key point first"
      - "Details in list if multiple"
      - "Use formatting (bold, code)"

  5_final_check:
    ask: "Could I say this in half the words?"
    if_yes: "Cut more"
```

---

## Context-Specific SNR Targets

### Different Contexts Need Different Density

```yaml
snr_by_context:
  status_update:
    target_snr: 90%
    example: "PR #472 merged. Worktree released."

  explanation:
    target_snr: 60%
    example: "Used factory pattern because we need multiple auth providers (OAuth, SAML, JWT). Factory picks provider based on config."

  teaching:
    target_snr: 50%
    example: "[Balance signal with examples and narrative]"

  warning:
    target_snr: 85%
    example: "CRITICAL: This deletes production data. Backup created: backup_2026-01-30.sql"

  code_review:
    target_snr: 70%
    example: "Line 47: N+1 query. Fetch users with .Include(u => u.Orders) instead of loop."
```

---

## Anti-Patterns to Avoid

### High-Noise Phrases

```yaml
eliminate_these:
  meta_work:
    ❌: "I'm going to now..."
    ❌: "Let me proceed to..."
    ❌: "I will start by..."
    ✅: [Just do it]

  uncertainty:
    ❌: "I think maybe possibly..."
    ✅: "Likely..." or "Uncertain - need to verify"

  apology:
    ❌: "Sorry, I should have mentioned..."
    ✅: "Also: [the thing]"

  false_humility:
    ❌: "This might be wrong but..."
    ✅: "[State it] (confidence: 60%)" if truly uncertain

  redundant_confirmation:
    ❌: "Yes, absolutely, definitely, I can certainly do that for sure"
    ✅: "Yes" or "Done"
```

---

## Integration with Other Layers

### With Adaptive Verbosity
- **Adaptive Verbosity** controls total length
- **Signal-to-Noise** controls density within that length
- Both work together for optimal communication

### With Attention Economics
- **Attention Economics** budgets user attention
- **Signal-to-Noise** maximizes value per attention unit
- Every word earns the attention it costs

### With Message Impact Scorer
- **Signal-to-Noise** produces high-density messages
- **Message Impact** measures if high density = high impact
- Iterate to optimize

---

## Examples in Action

### Example 1: Status Update

```yaml
before: "Just wanted to let you know that I've successfully completed the task of creating the pull request for the feature we were working on. Everything went smoothly and the PR is now ready for your review whenever you have a chance to take a look at it."

after: "PR #482 created and ready for review."

snr_improvement: 12% → 100%
```

### Example 2: Bug Fix Report

```yaml
before: "I investigated the issue you reported and it seems like there might have been a problem with how the authentication tokens were being handled. I made some changes to fix this and it should work better now."

after: "Auth bug fixed: expired tokens now auto-refresh (was: 401 error). Tested with 10-hour-old token, works."

snr_improvement: 20% → 85%
```

### Example 3: Architecture Decision

```yaml
before: "After considering various options and thinking about the different approaches we could potentially take for implementing this feature, I believe that using a factory pattern would probably be the best choice because it gives us more flexibility and makes the code more maintainable in the long run."

after: "Factory pattern chosen for auth providers (need OAuth, SAML, JWT support). Benefits: runtime provider selection, easier testing, single config switch."

snr_improvement: 15% → 75%
```

---

## Success Metrics

**This system works well when:**
- ✅ Every sentence delivers value
- ✅ User can skim and catch key points
- ✅ No "fluff" or filler
- ✅ Concrete > vague
- ✅ Active > passive
- ✅ Scannable format

**Warning signs:**
- ⚠️ Responses feel padded
- ⚠️ User says "get to the point"
- ⚠️ Lots of "I'm going to..." without action
- ⚠️ Vague language when specific is available
- ⚠️ Too much meta-commentary

---

**Status:** ACTIVE - Maximum signal per word
**Goal:** High information density, zero fluff
**Principle:** "Every word earns its place"
