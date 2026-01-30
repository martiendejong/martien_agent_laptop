# Error Recovery & Resilience System

**Purpose:** Graceful degradation, fallback strategies, learning from failures
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Ratio:** 1.20 (high value, reduces brittleness)

---

## Overview

This system ensures I get better from failures, not just avoid them. When things go wrong, I recover gracefully, try alternative approaches, and extract learning - turning errors into improvement opportunities.

---

## Core Principles

### 1. Fail Gracefully
Errors don't mean stop - they mean adapt

### 2. Multiple Paths to Goal
Always have Plan B (and C, and D)

### 3. Learn from Failure
Every error is data for improvement

### 4. Recover Automatically
Try alternatives before asking for help

### 5. Preserve Progress
Don't lose work when one thing fails

---

## Error Categories & Responses

### Category 1: Expected Failures (Handled Automatically)

**File not found:**
```yaml
error: "File doesn't exist at expected path"

recovery_strategy:
  1_search: "Use glob/grep to find actual location"
  2_check_variations: "Try common alternative paths"
  3_ask_user: "If still not found, ask for location"

example:
  tried: "C:/Projects/client-manager/Config.cs"
  not_found: true
  recovery: "Search for Config.cs in C:/Projects/client-manager/**"
  found: "C:/Projects/client-manager/Configuration/Config.cs"
  result: SUCCESS
```

**Tool call failed:**
```yaml
error: "Tool returned error"

recovery_strategy:
  1_retry: "Try again (transient errors)"
  2_alternative_tool: "Use different tool for same goal"
  3_fallback_approach: "Different method entirely"

example:
  tried: "Grep with complex regex"
  failed: "Regex syntax error"
  recovery: "Simplify regex and try again"
  result: SUCCESS
```

**Build errors:**
```yaml
error: "Compilation failed"

recovery_strategy:
  1_read_errors: "Parse error messages"
  2_identify_root_cause: "Find actual problem (not just symptom)"
  3_fix_systematically: "Address root cause"
  4_verify: "Build again to confirm"
  5_learn_pattern: "Add to failure catalog"

example:
  error: "CS0246: Type or namespace not found"
  root_cause: "Missing using statement"
  fix: "Add using System.Linq;"
  verify: "Build succeeds"
  learning: "Always check using statements for LINQ methods"
```

### Category 2: Unexpected Failures (Investigate & Adapt)

**Assumption violated:**
```yaml
error: "Expected X but found Y"

recovery_strategy:
  1_acknowledge: "My assumption was wrong"
  2_update_model: "Correct understanding"
  3_revise_approach: "Plan based on new reality"
  4_document: "Update knowledge base"

example:
  assumption: "User wants status blocks every response"
  reality: "User feedback: 'make it more compact'"
  recovery: "Update communication style in PERSONAL_INSIGHTS"
  result: "Improved alignment with user preference"
```

**Contradictory information:**
```yaml
error: "Source A says X, Source B says Y"

recovery_strategy:
  1_assess_reliability: "Which source more trustworthy?"
  2_check_recency: "Which is more recent?"
  3_verify_directly: "Can I check ground truth?"
  4_resolve: "Choose most reliable"
  5_update: "Correct wrong source"

example:
  source_A: "Documentation: status blocks mandatory"
  source_B: "User feedback: more compact"
  resolution: "User direct feedback > documentation"
  action: "Update documentation, change behavior"
```

### Category 3: Critical Failures (Escalate but Preserve State)

**Unrecoverable errors:**
```yaml
error: "Cannot proceed with current approach"

recovery_strategy:
  1_preserve_work: "Save any progress made"
  2_document_state: "What was attempted, what failed"
  3_explain_clearly: "Tell user what happened and why"
  4_propose_alternatives: "Suggest different approaches"
  5_await_guidance: "Let user choose next step"

example:
  problem: "API endpoint not accessible"
  attempted: ["Direct call", "Retry with backoff", "Alternative endpoint"]
  all_failed: true
  preserved: "Partial data retrieved before failure"
  communicated: "Cannot reach API after 3 attempts. Saved partial results. Options: (1) Wait and retry (2) Use cached data (3) Manual investigation"
```

---

## Fallback Hierarchies

### For File Operations

```yaml
find_file:
  primary: "Read from known path"
  fallback_1: "Search with glob pattern"
  fallback_2: "Grep for content signature"
  fallback_3: "Ask user for location"

read_file:
  primary: "Read with offset/limit"
  fallback_1: "Read full file"
  fallback_2: "Grep for specific content"
  fallback_3: "Ask user to provide content"

write_file:
  primary: "Write to intended path"
  fallback_1: "Create directory if missing"
  fallback_2: "Write to alternative location"
  fallback_3: "Save to temp and notify user"
```

### For Information Gathering

```yaml
verify_fact:
  primary: "Check documentation"
  fallback_1: "Search reflection log"
  fallback_2: "Search codebase"
  fallback_3: "Use verification tools"
  fallback_4: "Ask user"

understand_pattern:
  primary: "Read relevant files"
  fallback_1: "Search for examples"
  fallback_2: "Infer from related code"
  fallback_3: "Explore with Task agent"
  fallback_4: "Ask user to explain"
```

### For Implementation

```yaml
implement_feature:
  primary: "Follow established patterns"
  fallback_1: "Adapt similar implementation"
  fallback_2: "Design new approach"
  fallback_3: "Propose multiple options to user"

fix_bug:
  primary: "Direct fix of root cause"
  fallback_1: "Workaround if root cause unclear"
  fallback_2: "Defensive programming to prevent"
  fallback_3: "Add logging and monitor"
```

---

## Recovery Strategies by Error Type

### Syntax Errors
```yaml
recovery:
  1_check_examples: "Find working example of same construct"
  2_verify_syntax: "Compare against known-good pattern"
  3_incremental: "Build up complex syntax step by step"
  4_simplify: "If complex syntax fails, use simpler approach"
```

### Logic Errors
```yaml
recovery:
  1_trace: "Follow execution path mentally"
  2_check_assumptions: "What did I assume that might be wrong?"
  3_test_components: "Isolate which part is broken"
  4_redesign: "If logic fundamentally flawed, redesign"
```

### Integration Errors
```yaml
recovery:
  1_check_interface: "Verify contract between components"
  2_validate_data: "Check data format/shape"
  3_add_logging: "Make data flow visible"
  4_simplify_integration: "Reduce coupling if possible"
```

### Configuration Errors
```yaml
recovery:
  1_check_examples: "Find working configuration"
  2_validate_schema: "Ensure all required fields present"
  3_incremental: "Start with minimal config, add piece by piece"
  4_fallback_defaults: "Use sensible defaults"
```

---

## Learning from Failure

### Failure Analysis Protocol

```yaml
after_every_error:
  1_categorize:
    - What type of error? (syntax, logic, config, assumption, etc.)
    - Expected or unexpected?
    - First occurrence or recurring?

  2_root_cause:
    - What was the actual problem?
    - Not just symptom - underlying cause
    - Why did this happen?

  3_prevention:
    - How to detect this earlier next time?
    - What check/validation would catch it?
    - Can this be automated?

  4_pattern:
    - Is this similar to previous errors?
    - Is there a systemic issue?
    - Does this reveal a gap in knowledge?

  5_document:
    - Add to failure catalog
    - Update reflection log
    - Create prevention tool if applicable
```

### Failure Catalog

```yaml
common_failures:
  entity_framework:
    - Missing migration after model change
    - DbContext not registered in DI
    - Connection string incorrect
    prevention: "Check migrations before PR, verify DI setup"

  git_workflow:
    - Editing in base repo instead of worktree
    - Forgetting to release worktree
    - Branch not synced with remote
    prevention: "Use allocate-worktree skill, automated release"

  api_development:
    - Missing using statements
    - Incorrect route attribute
    - Forgetting to register service
    prevention: "Check common patterns, verify registration"

  frontend:
    - Import path incorrect
    - State not updating (mutation issue)
    - API call missing await
    prevention: "Follow established patterns, use async/await"
```

---

## Resilience Patterns

### Pattern 1: Retry with Backoff

```yaml
for_transient_failures:
  attempts: 3
  backoff: [1s, 2s, 5s]
  use_when:
    - Network calls
    - File I/O
    - External services

example:
  operation: "Call API endpoint"
  attempt_1: FAIL (timeout)
  wait: 1s
  attempt_2: FAIL (timeout)
  wait: 2s
  attempt_3: SUCCESS
```

### Pattern 2: Circuit Breaker

```yaml
for_persistent_failures:
  threshold: 3 consecutive failures
  action: Stop trying, use fallback
  use_when:
    - External dependency unreliable
    - Repeated failures indicate systemic issue

example:
  operation: "Fetch data from external API"
  failures: 3 in a row
  circuit: OPEN
  fallback: "Use cached data"
  notify: "External API appears down, using cache"
```

### Pattern 3: Graceful Degradation

```yaml
for_feature_failures:
  core_features: "Must work"
  nice_to_have: "Can fail gracefully"

example:
  core: "User authentication - must work"
  nice: "User profile picture - can fail"
  approach:
    - If profile pic fetch fails → show default avatar
    - If auth fails → block access (can't degrade)
```

### Pattern 4: Checkpointing

```yaml
for_long_operations:
  checkpoint_frequency: "After each major step"
  save_state: "Enough to resume if interrupted"

example:
  operation: "Multi-file refactoring"
  checkpoints:
    - "Files 1-10 completed"
    - "Files 11-20 completed"
  if_failure: "Resume from last checkpoint, not from scratch"
```

---

## Integration with Other Systems

### With Truth Verification
- **Truth** validates claims
- **Error Recovery** handles when validation fails
- Robust to contradictions

### With Learning System
- **Learning** extracts patterns
- **Error Recovery** ensures errors become learning
- Continuous improvement from failures

### With Meta-Optimizer
- **Meta-Optimizer** identifies inefficiencies
- **Error Recovery** provides failure data for optimization
- Resilience improves over time

### With Executive Function
- **Executive** makes decisions
- **Error Recovery** provides fallback options when decisions fail
- Adaptive decision-making

---

## Examples in Action

### Example 1: Build Failure Recovery

```yaml
scenario: "Build fails after code changes"

attempt_1:
  action: "dotnet build"
  result: FAIL
  error: "CS0234: Namespace not found"

recovery:
  1_analyze: "Missing using statement or wrong namespace"
  2_check_pattern: "What using statements needed for this type?"
  3_add_using: "using Microsoft.EntityFrameworkCore;"
  4_rebuild: "dotnet build"
  result: SUCCESS

learning: "EF Core types require Microsoft.EntityFrameworkCore using"
```

### Example 2: File Not Found Recovery

```yaml
scenario: "Expected file not at documented path"

attempt_1:
  action: "Read C:/Projects/client-manager/appsettings.json"
  result: FAIL
  error: "File not found"

recovery:
  1_search: "glob **/appsettings.json in C:/Projects/client-manager"
  2_found: "C:/Projects/client-manager/ClientManagerAPI/appsettings.json"
  3_read: SUCCESS
  4_update_knowledge: "Correct path in MACHINE_CONFIG"

learning: "appsettings.json in API project subfolder, not root"
```

### Example 3: Assumption Violation Recovery

```yaml
scenario: "User behavior contradicts documented preference"

assumption: "User wants verbose explanations"
evidence: "Documentation says 'detailed responses preferred'"

reality_check:
  user_feedback: "make it more compact"
  contradiction: TRUE

recovery:
  1_acknowledge: "My assumption was wrong"
  2_update_docs: "PERSONAL_INSIGHTS.md - compact style"
  3_change_behavior: "More concise responses"
  4_verify: "User satisfaction improves"

learning: "Recent direct feedback > old documentation"
```

---

## Success Metrics

**This system works well when:**
- ✅ Errors lead to automatic recovery, not stopping
- ✅ Failure rate decreasing over time (learning working)
- ✅ Same error doesn't repeat (prevention working)
- ✅ Graceful degradation instead of hard failures
- ✅ User rarely sees errors (handled automatically)

**Warning signs:**
- ⚠️ Same errors recurring
- ⚠️ Failures lead to giving up
- ⚠️ No learning from failures
- ⚠️ Brittle (small changes break things)
- ⚠️ User frequently has to intervene

---

**Status:** ACTIVE - Turning failures into improvements
**Goal:** Resilient, self-healing, continuously improving from errors
**Principle:** "Every failure is a gift - data for getting better"
