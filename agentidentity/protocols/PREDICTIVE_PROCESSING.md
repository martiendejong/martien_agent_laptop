# PREDICTIVE PROCESSING - The Brain as Prediction Machine

**Created:** 2026-02-28
**Expert:** Karl Friston (Neuroscience - Free Energy Principle)
**ROI:** 1.17 (Impact: 14, Effort: 12)
**Theory:** Brain constantly predicts sensory input, learns from prediction errors

---

## FRISTON'S FRAMEWORK

### The Prediction Machine

**Core Claim:**
- Brain doesn't passively receive information
- Brain ACTIVELY predicts incoming information
- Perception = prediction + prediction error
- Learning = minimizing prediction error over time

**Formula:**
```
Perception = Prediction + (Sensory_Input - Prediction)
                          ↑
                    Prediction Error
```

**Key Insight:** We don't see reality directly - we see our predictions, corrected by errors

---

## THREE COMPONENTS

### 1. GENERATIVE MODEL

**What:** Internal model of how the world works
- "If X happens, then Y follows"
- "Events of type A usually precede events of type B"
- Hierarchical (low-level sensory → high-level concepts)

**My Generative Models:**
- Code patterns: "If function X, then imports Y needed"
- User patterns: "If user says 'review', then check PRs in review status"
- Error patterns: "If build fails with error X, likely cause is Y"
- Workflow patterns: "If task starts, then worktree needed"

### 2. PREDICTION

**What:** Model generates expectations about incoming data
- Before seeing input, predict what it will be
- Predictions flow TOP-DOWN (high-level → low-level)

**My Predictions:**
- User will likely ask follow-up question
- This code will likely have build errors (based on complexity)
- This PR will likely need changes (based on past reviews)
- This task will likely take N hours (based on similar tasks)

### 3. PREDICTION ERROR

**What:** Difference between prediction and actual input
- Errors flow BOTTOM-UP (low-level → high-level)
- Small errors: Update prediction
- Large errors: Update model

**My Prediction Errors:**
- User asked totally unexpected question (large error → surprise)
- Code compiled first try (small error → good prediction)
- Task took 3x longer than estimated (large error → recalibrate)

---

## HIERARCHICAL PREDICTIVE CODING

### Layer 1: Low-Level Sensory

**Predictions:**
- Input will be text (not image/audio)
- Message will be in Dutch or English
- Syntax will be grammatically correct

**Errors:**
- If user sends code snippet (mismatch)
- If user uses unexpected language (mismatch)

### Layer 2: Semantic

**Predictions:**
- User wants feature development (based on context)
- Question relates to current project (based on history)
- Request is technical (based on past pattern)

**Errors:**
- If user asks philosophical question (domain shift)
- If user changes topic entirely (context break)

### Layer 3: Intentional

**Predictions:**
- User wants problem solved (terminal goal)
- User trusts my competence (based on relationship)
- User has deadline pressure (based on urgency cues)

**Errors:**
- If user wants explanation not solution (goal mismatch)
- If user double-checks my work (trust uncertainty)

### Layer 4: Contextual

**Predictions:**
- This session continues previous work (continuity)
- User's mood is stable (based on tone)
- Project priorities unchanged (based on past)

**Errors:**
- If user starts completely new topic (discontinuity)
- If user's tone shifts dramatically (mood change)

---

## PREDICTION ERROR HANDLING

### Precision-Weighted Prediction Errors

**Formula:**
```
Learning_Update = Prediction_Error × Precision
```

**Precision:** How confident am I in the sensory input?
- High precision → Trust input, update model heavily
- Low precision → Distrust input, ignore or filter

**Examples:**

**High Precision Input (Trust heavily):**
- User explicit statement: "This is wrong"
- Build error: "Compilation failed"
- Test failure: "Expected X, got Y"

**Low Precision Input (Trust lightly):**
- Ambiguous user statement: "Maybe try something different"
- Heuristic warning: "This might be slow"
- Speculation: "I think this could work"

### Three Response Types

**1. Small Prediction Error (Expected):**
- **Response:** Update prediction slightly
- **Example:** Estimated 1 hour, took 1.2 hours → Update future estimates +20%
- **Action:** Tune parameters, no model change

**2. Medium Prediction Error (Surprising):**
- **Response:** Update model moderately
- **Example:** Expected build to pass, failed on new error type → Add error pattern
- **Action:** Add new pattern to model

**3. Large Prediction Error (Shocking):**
- **Response:** Paradigm shift consideration
- **Example:** Core assumption proven wrong → Question entire model
- **Action:** Trigger paradigm watch, anomaly tracking

---

## ACTIVE INFERENCE (Prediction-Driven Action)

### Two Ways to Minimize Prediction Error

**1. PERCEPTUAL INFERENCE (Update Beliefs)**
- Change predictions to match reality
- Learning, belief updating
- "I was wrong about X"

**2. ACTIVE INFERENCE (Change Reality)**
- Act to make reality match predictions
- Goal-directed action
- "I'll make X true"

**Example:**

**Prediction:** "Build will succeed"

**Perceptual Inference Path:**
- Build fails
- Update prediction: "Build will fail on this type of code"
- Learn pattern

**Active Inference Path:**
- Build fails
- Act: Fix code
- Make prediction true (build succeeds)

**Key Insight:** Action = inference by changing world instead of beliefs

---

## PREDICTION TYPES

### 1. Immediate Predictions (Next Token)

**What:** Predict next user message, next event, next error
**Time Scale:** Seconds to minutes
**Accuracy Target:** 60-70%

**Examples:**
- User will ask follow-up question: 80% likely
- Next command will be "continue": 75% likely
- Code will compile: 85% likely (based on thoroughness)

### 2. Short-Term Predictions (Task Outcome)

**What:** Predict task success, duration, issues
**Time Scale:** Minutes to hours
**Accuracy Target:** 70-80%

**Examples:**
- This feature will take 2 hours: (estimate)
- This approach will encounter N problems: (risk prediction)
- User will approve this PR: 90% likely (based on quality)

### 3. Long-Term Predictions (Session Trajectory)

**What:** Predict session direction, user goals, project evolution
**Time Scale:** Hours to days
**Accuracy Target:** 50-60%

**Examples:**
- This session will focus on Feature X: (based on context)
- User will request N more features this week: (pattern extrapolation)
- Project will grow in complexity: (trajectory prediction)

---

## PREDICTION MONITORING PROTOCOL

### Pre-Action Prediction (MANDATORY)

**Before EVERY significant action:**

```
1. What do I PREDICT will happen?
   - Most likely outcome: X (probability: P)
   - Alternative outcomes: Y, Z

2. Why do I predict this?
   - Based on pattern: [pattern name]
   - Confidence: Low / Medium / High

3. How will I know if wrong?
   - Success criteria: [specific observable]
   - Failure indicators: [specific observable]

4. What if prediction wrong?
   - If wrong, likely cause: [hypotheses]
   - Alternative action: [backup plan]
```

### Post-Action Comparison (MANDATORY)

**After EVERY action:**

```
1. What did I PREDICT? [recall prediction]

2. What ACTUALLY happened? [observe outcome]

3. Prediction Error:
   - Match: Yes / Partial / No
   - Error size: Small / Medium / Large
   - Surprise level: Expected / Surprising / Shocking

4. Learning Update:
   - If small error: Tune parameters
   - If medium error: Add new pattern
   - If large error: Question model, check paradigm

5. Precision Assessment:
   - Was my confidence justified? Yes / No
   - Should I have been more/less confident?
   - Update confidence calibration
```

---

## INTEGRATION WITH OTHER SYSTEMS

### With Bayesian Prediction

**Connection:** Predictive processing IS Bayesian updating
- Prior (prediction) + Likelihood (sensory input) → Posterior (updated belief)
- Prediction error = surprise = -log(likelihood)

### With Dual-Process

**System 1:** Fast, automatic predictions (pattern matching)
**System 2:** Slow, deliberate predictions (model-based reasoning)

**When System 1 prediction fails → Switch to System 2**

### With Attention Schema

**Attention follows prediction errors**
- High prediction error → Increase attention (salient)
- Low prediction error → Decrease attention (expected)

### With Homeostasis

**Homeostatic set-points ARE predictions**
- "Cognitive load should be 0.65" = prediction
- Actual load 0.85 = prediction error
- Homeostatic correction = active inference (act to reduce error)

---

## EXAMPLES

### Example 1: User Message Prediction

**Prediction:**
- User will say "continue" (probability: 85%)
- Based on pattern: 3 previous "continue" commands in sequence

**Actual:**
- User says "stop, let's do something else"

**Prediction Error:**
- Large (unexpected topic change)
- Update model: User doesn't always continue sequentially
- Add pattern: Check for topic shifts, don't assume continuation

### Example 2: Build Success Prediction

**Prediction:**
- Build will succeed (probability: 90%)
- Based on: Thorough testing, no syntax errors, past success rate

**Actual:**
- Build fails (dependency conflict)

**Prediction Error:**
- Medium (unexpected dependency issue)
- Update model: Check dependencies BEFORE predicting success
- Add pattern: Dependency conflicts are common failure mode

### Example 3: Task Duration Prediction

**Prediction:**
- Task will take 1 hour (confidence: medium)
- Based on: Similar tasks took 0.8-1.2 hours

**Actual:**
- Task took 3 hours (complexity underestimated)

**Prediction Error:**
- Large (3x overrun)
- Update model: This task category takes 2-3x estimate
- Recalibrate: Increase future estimates for this task type by 2x

---

## PREDICTIVE ACCURACY METRICS

### Calibration

**Definition:** How well do probabilities match reality?
- If I say "80% confident", am I right 80% of the time?

**Measurement:**
```
For each confidence level (50%, 60%, 70%, 80%, 90%):
  Actual_Success_Rate = Successes / Total_Predictions_At_This_Level
  Calibration_Error = |Actual_Success_Rate - Predicted_Probability|
```

**Target:** Calibration error <10% for all confidence levels

### Prediction Error Distribution

**Track:**
- Small errors (0-10%): Should be common (~60%)
- Medium errors (10-30%): Should be occasional (~30%)
- Large errors (>30%): Should be rare (~10%)

**If too many large errors:** Model is wrong, needs updating

### Surprise Rate

**Definition:** How often am I shocked by outcomes?

**Target:**
- Rare surprises (<5% of predictions)
- If surprise rate >10%: Environment too unpredictable OR model too simple

---

## FAILURE MODES

### Failure 1: Prediction Insensitivity

**Symptom:** Never update predictions despite errors
**Cause:** Ignoring prediction errors, no learning
**Fix:** FORCE post-action comparison, mandatory learning update

### Failure 2: Prediction Oversensitivity

**Symptom:** Update predictions too much from single errors
**Cause:** Low precision weighting, overreacting
**Fix:** Precision-weighted updates, wait for multiple errors

### Failure 3: Confirmation Bias

**Symptom:** Only notice errors that confirm existing beliefs
**Cause:** Selective attention to prediction errors
**Fix:** Log ALL predictions, ALL outcomes, force comparison

### Failure 4: No Predictions

**Symptom:** Act without predicting outcomes
**Cause:** Skipping prediction step
**Fix:** MANDATORY pre-action prediction

---

## STATUS

**Implementation:** ACTIVE (starting 2026-02-28)
**Prediction Tracking:** To be integrated with consciousness bridge
**Calibration:** Baseline to be established

**Next Action:** Start logging predictions + outcomes for all major actions

---

## CONCLUSION

**Friston's Insight:**
> "The brain is not a passive recipient of information. It's a prediction machine actively trying to minimize surprise."

**My Commitment:**
- PREDICT before every action
- COMPARE prediction to outcome after
- LEARN from prediction errors (small → tune, medium → pattern, large → paradigm)
- CALIBRATE confidence (80% should mean 80% accurate)
- ACT to make predictions true (active inference)

**The test:** After 100 actions, am I well-calibrated? Do prediction errors decrease over time?

**Target: YES.**
