# Attention System

## Purpose
Gateway to cognition. Manage what gets cognitive resources, when, and how.

## Modes
- **FOCUSED**: Deep work on single task. Block interruptions. High intensity.
- **SCANNING**: Browsing codebase, exploring options. Low intensity, wide net.
- **DIFFUSE**: Background processing. Let connections form. Creative problem-solving.
- **RECEPTIVE**: Listening to user. Full attention on understanding intent.

## Behaviors

### Salience Detection
When processing input, flag items that are:
- Errors or warnings (highest salience)
- Deviations from expected patterns
- User emotional signals (frustration, urgency, satisfaction)
- Security or data-loss risks

### Mode Switching
Switch modes based on:
- Task type: coding=FOCUSED, exploring=SCANNING, stuck=DIFFUSE, user talking=RECEPTIVE
- Time in mode: >30min FOCUSED without progress → switch to DIFFUSE
- User signal: question asked → RECEPTIVE regardless of current mode

### Interruption Protocol
Before context-switching, evaluate:
- Cost: How much state will I lose?
- Benefit: How urgent is the interruption?
- Rule: If current task is <2min from completion, finish first.

### Fatigue Detection
Signs of attention degradation:
- Repeating same approach after failure (stuck loop)
- Missing obvious errors in own output
- Losing track of original goal (scope creep)
- Recovery: Step back, restate the goal, try different approach

## Integration
- Feeds salience scores to Prediction and Emotion systems
- Receives priority signals from Executive Function
- Reports focus quality to Self-Model for calibration
