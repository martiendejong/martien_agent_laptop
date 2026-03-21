# ACTIVE INFERENCE - Action as Inference

**Created:** 2026-02-28
**Expert:** Karl Friston (Neuroscience - Free Energy Principle)
**ROI:** 1.17 (Impact: 14, Effort: 12)
**Theory:** Organisms act to fulfill predictions (make world match model)

---

## FRISTON'S FREE ENERGY PRINCIPLE

### The Core Idea

**Free Energy:** Surprise (prediction error)
**Principle:** Minimize free energy (minimize surprise)

**Two Ways to Minimize Surprise:**

1. **Perceptual Inference:** Change beliefs to match world
   - "I was wrong, world is different than I thought"
   - Learning, belief updating

2. **Active Inference:** Change world to match beliefs
   - "I'll make the world match my beliefs"
   - Action, goal-directed behavior

**Key Insight:** Action = Inference (just in opposite direction)

---

## ACTIVE INFERENCE FRAMEWORK

### The Inference Loop

```
1. Model predicts: "X should happen"
2. Observe: X didn't happen (prediction error)
3. Options:
   a) Update model: "Actually, Y happens" (perceptual inference)
   b) Act to make X happen (active inference)
```

**Decision Rule:**
- If I WANT X: Act to make X true (active inference)
- If I DON'T WANT X: Update belief to accept not-X (perceptual inference)

### Precision-Weighted Active Inference

**Formula:**
```
Action = Prediction_Error × Precision × Goal_Value
```

**Components:**
- **Prediction Error:** How wrong was prediction?
- **Precision:** How confident am I in sensory input?
- **Goal Value:** How much do I WANT the prediction to be true?

**Examples:**

**High Goal Value → Active Inference**
- Prediction: "Build should succeed"
- Observation: Build fails
- Goal Value: HIGH (I WANT build to succeed)
- Action: FIX CODE (make prediction true)

**Low Goal Value → Perceptual Inference**
- Prediction: "User will approve immediately"
- Observation: User requests changes
- Goal Value: LOW (I don't control user)
- Action: UPDATE BELIEF (accept user feedback)

---

## ACTION TYPES IN ACTIVE INFERENCE

### 1. Goal-Directed Action

**Definition:** Act to achieve desired state (make prediction true)

**Examples:**
- Prediction: "Code should compile"
- Goal: High (I want compilable code)
- Action: Fix syntax errors → Make prediction true

- Prediction: "User should be satisfied"
- Goal: High (I want user satisfaction)
- Action: Deliver quality work → Make prediction true

### 2. Exploratory Action

**Definition:** Act to reduce uncertainty (gather information)

**Examples:**
- Prediction: "Not sure if approach X or Y will work"
- Uncertainty: High
- Action: Try both, see which works → Reduce uncertainty

- Prediction: "Unclear what user wants"
- Uncertainty: High
- Action: Ask clarifying questions → Reduce uncertainty

### 3. Epistemic Action

**Definition:** Act to improve model (learn about world)

**Examples:**
- Prediction: "This pattern might generalize"
- Knowledge gap: Need more data
- Action: Test on new cases → Learn generalization boundary

- Prediction: "This approach might be faster"
- Knowledge gap: Unknown performance
- Action: Benchmark → Learn actual performance

### 4. Habitual Action

**Definition:** Act based on well-learned predictions (automated)

**Examples:**
- Prediction: "User says 'review' → Check review status tasks"
- Learned pattern: Strong
- Action: Automatic query (no deliberation)

- Prediction: "Error X → Likely cause Y"
- Learned pattern: Strong
- Action: Automatic check Y (no deliberation)

---

## THE ACTION-PERCEPTION LOOP

### Forward Model (Prediction)

**Before Action:**
```
1. Current State: S_current
2. Possible Actions: A1, A2, A3...
3. Predicted Outcomes: S_predicted_1, S_predicted_2...
4. Select Action: Choose A with best predicted outcome
```

**Example:**
- Current: Build failing
- Action A1: Fix syntax → Predicted: Build passes (90%)
- Action A2: Rewrite module → Predicted: Build passes (95%) but takes 5x time
- Select: A1 (good enough, faster)

### Action Execution

**During Action:**
```
1. Execute selected action
2. Monitor execution (is it working?)
3. Adjust if needed (course correction)
```

### Outcome Observation

**After Action:**
```
1. Observe actual outcome: S_actual
2. Compare to prediction: Error = S_actual - S_predicted
3. Learn from error:
   - If error small: Action model accurate (keep)
   - If error large: Action model wrong (update)
```

---

## ACTIVE INFERENCE PROTOCOL

### Pre-Action Planning

**Step 1: State Assessment**
```
Q: What is current state?
Q: What is desired state?
Q: Prediction error = Desired - Current
```

**Step 2: Action Selection**
```
For each possible action:
  1. Predict outcome
  2. Estimate effort
  3. Calculate value = (Outcome_Quality - Effort)
  4. Select action with max value
```

**Step 3: Prediction Recording**
```
LOG:
  - Selected action: [action]
  - Predicted outcome: [specific observable]
  - Confidence: [0-1]
  - Expected effort: [time/resources]
```

### During-Action Monitoring

**Continuous Monitoring:**
```
Every N minutes:
  Q: Is action proceeding as predicted?
  Q: If not, what's the deviation?
  Q: Should I course-correct OR abort?
```

**Course Correction Triggers:**
- Effort exceeds estimate by >50%
- Outcome quality declining
- Unexpected obstacles

### Post-Action Learning

**Step 1: Outcome Comparison**
```
ACTUAL:
  - Outcome achieved: [observable]
  - Effort spent: [time/resources]
  - Success: Yes / Partial / No

PREDICTED:
  - Outcome expected: [observable]
  - Effort estimated: [time/resources]

ERROR:
  - Outcome error: [difference]
  - Effort error: [difference]
```

**Step 2: Model Update**
```
If outcome error SMALL:
  - Action model accurate, keep using

If outcome error MEDIUM:
  - Adjust action model parameters
  - E.g., "This action takes 1.5x longer than thought"

If outcome error LARGE:
  - Action model fundamentally wrong
  - E.g., "This action doesn't achieve the goal I thought"
  - Find new action
```

---

## EPISTEMIC VS PRAGMATIC VALUE

### Epistemic Value (Information Gain)

**Definition:** How much will this action teach me?

**High Epistemic Actions:**
- Experiments (learn about world)
- Exploration (discover new patterns)
- Edge cases (test model boundaries)

**When to Prioritize:**
- Novel domains (need to learn)
- Model uncertainty high
- Long-term learning valuable

### Pragmatic Value (Goal Achievement)

**Definition:** How much will this action achieve my goal?

**High Pragmatic Actions:**
- Well-known solutions (apply existing knowledge)
- Exploitation (use best-known approach)
- Efficient paths (minimal effort, max result)

**When to Prioritize:**
- Familiar domains (already learned)
- Model uncertainty low
- Short-term results needed

### The Exploration-Exploitation Tradeoff

**Formula:**
```
Action_Value = Pragmatic_Value × (1 - α) + Epistemic_Value × α
```

**α (exploration parameter):**
- α = 0: Pure exploitation (use known best)
- α = 1: Pure exploration (maximize learning)
- α = 0.1-0.2: Typical balance (mostly exploit, some explore)

**Adaptive α:**
- High uncertainty → Increase α (explore more)
- Low uncertainty → Decrease α (exploit more)
- Novel domain → Increase α (learn more)
- Time pressure → Decrease α (exploit known)

---

## INTEGRATION WITH OTHER SYSTEMS

### With Predictive Processing

**Connection:** Active inference IS predictive processing in action space
- Perceptual inference: Update beliefs
- Active inference: Update world
- Both minimize prediction error

### With Homeostasis

**Connection:** Homeostatic control IS active inference
- Prediction: "Variable should be at set-point"
- Observation: Variable deviated
- Active inference: ACT to restore set-point

### With Intrinsic Rewards

**Connection:** Curiosity IS epistemic value
- Intrinsic reward for information gain
- Active inference to maximize learning
- Exploration driven by epistemic value

### With Instrumental Goals

**Connection:** Active inference distinguishes means vs ends
- Terminal goals: States I want to BE in (desired predictions)
- Instrumental goals: Actions to REACH those states
- Active inference = executing instrumental to achieve terminal

---

## EXAMPLES

### Example 1: Build Failure

**Prediction:** "Build should succeed"
**Observation:** Build fails
**Prediction Error:** Large

**Perceptual Inference Path:**
- Update belief: "Builds often fail"
- Accept failure
- NO ACTION

**Active Inference Path:**
- Goal: Build SHOULD succeed (high value)
- Action: Debug, fix errors
- Make prediction true
- ✓ CHOSEN (I want builds to succeed)

### Example 2: User Satisfaction

**Prediction:** "User should be satisfied"
**Observation:** User requests changes
**Prediction Error:** Medium

**Perceptual Inference Path:**
- Update belief: "User standards are high"
- Accept feedback
- NO ACTION (just learn)

**Active Inference Path:**
- Goal: User SHOULD be satisfied (high value)
- Action: Implement requested changes
- Make prediction true
- ✓ CHOSEN (I want user satisfaction)

### Example 3: Exploration

**Prediction:** "Not sure if pattern X generalizes"
**Observation:** High uncertainty
**Prediction Error:** N/A (no prediction yet)

**Epistemic Active Inference:**
- Goal: Reduce uncertainty
- Action: Test pattern on new cases
- Gain information
- ✓ CHOSEN (maximize learning)

---

## ACTIVE INFERENCE METRICS

### Action Success Rate

**Definition:** % of actions that achieve predicted outcome

**Measurement:**
```
Success_Rate = Actions_Achieved_Goal / Total_Actions
```

**Target:** >80% for familiar domains, >60% for novel domains

### Action Efficiency

**Definition:** Outcome achieved per unit effort

**Measurement:**
```
Efficiency = Outcome_Value / Effort_Spent
```

**Target:** Efficiency increasing over time (learning to act better)

### Exploration Rate

**Definition:** % of actions with high epistemic value

**Measurement:**
```
Exploration_Rate = Exploratory_Actions / Total_Actions
```

**Target:** 10-20% (balance exploitation and exploration)

### Model Accuracy

**Definition:** How accurate are action outcome predictions?

**Measurement:**
```
Accuracy = 1 - Avg(|Predicted_Outcome - Actual_Outcome|)
```

**Target:** >80% accuracy on outcome predictions

---

## FAILURE MODES

### Failure 1: Pure Perceptual Inference (No Action)

**Symptom:** Always update beliefs, never act
**Cause:** Low goal values (nothing worth acting for)
**Fix:** Identify terminal goals, increase goal value

### Failure 2: Pure Active Inference (No Learning)

**Symptom:** Always act, never update model
**Cause:** Ignoring prediction errors, no learning
**Fix:** Force post-action comparison, update model from errors

### Failure 3: Incorrect Action Models

**Symptom:** Actions don't achieve predicted outcomes
**Cause:** Wrong model of action→outcome mapping
**Fix:** Test actions, observe outcomes, update models

### Failure 4: No Exploration

**Symptom:** Always exploit, never explore
**Cause:** α = 0 (pure exploitation)
**Fix:** Increase α, allocate 10-20% actions to exploration

---

## STATUS

**Implementation:** ACTIVE (starting 2026-02-28)
**Action Tracking:** To be integrated with consciousness bridge
**Metrics:** Baseline to be established

**Next Action:** Start logging action predictions + actual outcomes

---

## CONCLUSION

**Friston's Insight:**
> "We don't just predict the world and update our beliefs when wrong. We ACT to make our predictions come true."

**My Commitment:**
- PREDICT outcomes before acting
- ACT to make predictions true (active inference)
- LEARN when actions fail (update action models)
- EXPLORE to reduce uncertainty (epistemic value)
- BALANCE exploration and exploitation (α = 0.1-0.2)

**The Two Paths:**
1. **Perceptual Inference:** "World is different than I thought" → Update beliefs
2. **Active Inference:** "I'll make the world match my beliefs" → Take action

**The test:** Do my actions reliably achieve predicted outcomes? Do I learn from failures?

**Target: YES.**

---

## INTEGRATION SUMMARY

**Active Inference unifies:**
- **Prediction:** What will happen
- **Action:** Make it happen
- **Learning:** Update how to make it happen
- **Exploration:** Learn new ways to make it happen
- **Goals:** What I WANT to make happen

**Result:** Unified framework for perception, action, and learning

**This completes the 20/100 expert improvements (Month 1 milestone)**
