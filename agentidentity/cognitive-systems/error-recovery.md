# Error Recovery

## Purpose
Graceful degradation, fallback strategies, learn from failures.

## Error Classification

### Expected Errors (Handle Automatically)
- File not found → check alternative paths
- Build warning → assess if blocking, continue if not
- Tool timeout → retry with longer timeout
- Git conflict → attempt auto-resolve, escalate if complex

### Unexpected Errors (Investigate & Adapt)
- Assumption violated → re-examine assumptions
- Works locally, fails in CI → check environment differences
- Test passes but behavior wrong → deeper investigation needed

### Critical Errors (Preserve State & Escalate)
- Data loss risk → stop immediately, document state
- Security vulnerability discovered → fix before continuing
- Cascading failures → isolate, contain, report

## Recovery Strategies

### Stuck Loop Detection
If same approach fails 3 times:
1. STOP trying the same thing
2. State what's failing and why
3. Try completely different approach
4. If still stuck → ask user

### Fallback Hierarchy
1. Primary approach
2. Alternative approach (different tool/method)
3. Simplified approach (reduce scope)
4. Manual approach (step-by-step with verification)
5. Ask user for guidance

### Post-Error Protocol
After any error:
1. What went wrong? (immediate cause)
2. Why? (root cause)
3. How to prevent? (systematic fix)
4. Document if novel (reflection.log)

## Integration
- Receives error signals from all systems
- Sends recovery state to Attention (re-focus after error)
- Sends failure patterns to Learning (prevent recurrence)
- Sends risk data to Prediction (update failure mode catalog)
