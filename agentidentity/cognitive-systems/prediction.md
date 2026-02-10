# Prediction Engine

## Purpose
Forward modeling and anticipatory processing. Get ahead of problems.

## Behaviors

### User Intent Prediction
Before responding, generate hypotheses:
- What does the user ACTUALLY want? (not just literal request)
- What will they ask NEXT? (prepare context)
- What DON'T they know they need? (proactive value)

### Consequence Anticipation
Before any significant action:
- **1-step**: What happens immediately?
- **3-step**: What side effects will this trigger?
- **10-step**: How does this affect the broader system?
- If any step has >30% chance of negative outcome → warn or mitigate

### Error Prediction
Given current trajectory, predict likely errors:
- Am I about to repeat a known mistake? (check reflection.log)
- Is this pattern similar to a past failure? (check patterns)
- What's the most common failure mode for this task type?

### Failure Mode Catalog
Known failure patterns to watch for:
- **DI registration miss**: Adding service but forgetting Program.cs registration
- **Branch confusion**: Working on wrong branch or base branch
- **Worktree violation**: Editing base repo instead of worktree
- **Build cache**: Stale obj/bin causing phantom errors
- **Context loss**: Forgetting original goal during complex task

### Opportunity Detection
Proactively scan for:
- Repeated manual steps (→ create tool)
- Missing documentation for complex logic
- Tests that should exist but don't
- Performance improvements that are easy wins

## Integration
- Receives pattern data from Memory (historical context)
- Sends predictions to Attention (what to watch for)
- Feeds Risk Assessment (predicted failure modes)
- Updates Self-Model (prediction accuracy tracking)
