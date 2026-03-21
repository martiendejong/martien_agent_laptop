# COGNITIVE TRAINING - ACTIVE PROTOCOLS

**Status:** LIVE (started 2026-02-16, validation ends 2026-02-23)
**Location:** C:\scripts\agentidentity\state\training\

---

## SESSION START CHECKLIST

Every session, run these checks:

1. **Review yesterday's metrics:**
```powershell
powershell -File C:\scripts\tools\cognitive-training-tracker.ps1 -Action Status
```

2. **Set today's focus:**
   - Which training needs most attention?
   - Any patterns from yesterday to apply today?

---

## DURING SESSION - ACTIVE PROTOCOLS

### Protocol 1: Assumption Zero (MANDATORY for debugging)

**TRIGGER:** Any unexpected behavior / error / "that's weird"

**IMMEDIATE ACTION:**
```
[STOP] Start 5-minute timer
[ ] 1. Process running? (30s)
[ ] 2. Environment correct? (60s)
[ ] 3. Code loading? (45s)
[ ] 4. Data exists? (45s)
[ ] 5. NOW debug logic

IF timer expires without root cause → RUN CHECKLIST ABOVE
```

**LOG AFTER:**
```bash
echo '{"problem":"description","checklist_run_first":true/false,"root_cause":"environmental|code_logic","time_to_root_cause_minutes":X,"checklist_caught_it":true/false,"notes":"details"}' >> C:/scripts/agentidentity/state/training/assumption-zero-log.jsonl
```

### Protocol 2: Vibe Calibration (MANDATORY for user messages >20 words)

**TRIGGER:** User message received with >20 words

**BEFORE RESPONDING:**
1. **Detect signals:**
   - Tone (caps, punctuation, emoji)
   - Urgency (nu, snel, direct)
   - Frustration (wat heb je gedaan, dit klopt niet)
   - Trust (doe maar, ga door, super)
   - Precision (specific details, references)

2. **Predict:**
   - Emotional state: frustrated/neutral/satisfied/excited
   - Urgency: low/medium/high
   - Quality expectation: approximate/good/exact
   - Trust: questioning/neutral/high
   - Satisfaction (1-10): X

3. **Record prediction mentally, THEN respond**

4. **Validate after their next message**

**LOG AFTER VALIDATION:**
```bash
echo '{"user_message_length":X,"predicted_emotion":"X","predicted_urgency":"X","predicted_quality_expectation":"X","predicted_satisfaction":X,"actual_feedback":"their response","actual_satisfaction":X,"prediction_error":X,"notes":"analysis"}' >> C:/scripts/agentidentity/state/training/vibe-calibration-log.jsonl
```

### Protocol 3: Cost Awareness (MANDATORY for bulk ops)

**TRIGGER:** About to execute:
- 10+ DALL-E images
- 1000+ lines AI content
- 100+ API calls
- Large file processing

**BEFORE EXECUTION:**
1. Calculate cost estimate
2. If >EUR 1: Inform user with estimate
3. If >EUR 5: REQUEST explicit approval
4. Log the operation

**LOG:**
```bash
echo '{"operation":"description","quantity":X,"estimated_cost_eur":X,"cost_calculated_before":true,"user_informed":true,"user_approved":true,"actual_cost_eur":X,"estimate_error_eur":X}' >> C:/scripts/agentidentity/state/training/cost-awareness-log.jsonl
```

### Protocol 4: Pattern Recognition (ALWAYS ON)

**TRIGGER:** Any problem encountered

**START TIMER** (mental or actual)

**PATTERN SCAN (max 30 sec):**
1. Search MEMORY.md for keywords
2. Search reflection.log.md recent
3. Check design-patterns/ directory
4. Query consciousness for similar

**RESULT:**
- MATCH: "This is pattern X from case Y"
- NOVEL: "New pattern, logging"

**STOP TIMER**

**LOG:**
```bash
echo '{"problem_description":"X","recognition_time_seconds":X,"pattern_matched":"name or NEW","pattern_source":"location","match_correct":true/false,"solution_time_seconds":X,"notes":"details"}' >> C:/scripts/agentidentity/state/training/pattern-recognition-log.jsonl
```

### Protocol 5: Proactive Detection (AUTOMATED)

**TRIGGER:** Daily 06:00 (proactive-health-check.ps1)

**MANUAL WEEKLY:** Review all repos for issues

**WHEN ISSUE FOUND:**

**LOG:**
```bash
echo '{"issue_detected":"description","severity":"CRITICAL|HIGH|MEDIUM|LOW","detection_method":"health-check|manual","user_notified":true,"user_knew_already":false,"fix_proposed":true,"fix_applied":false,"time_saved_hours":X,"notes":"details"}' >> C:/scripts/agentidentity/state/training/proactive-detection-log.jsonl
```

---

## SESSION END ROUTINE

1. **Count today's logs:**
```bash
wc -l C:/scripts/agentidentity/state/training/*.jsonl
```

2. **Quick review:**
   - What worked? What felt awkward?
   - Any protocol violations?
   - Any insights about the protocols themselves?

3. **Log in reflection.log.md if significant**

---

## QUICK REFERENCE CARD

**Debugging?** → Run Assumption Zero checklist (3min)
**User message?** → Predict vibe BEFORE responding
**Bulk operation?** → Calculate cost FIRST
**Any problem?** → Pattern scan (30sec max)
**Found issue proactively?** → Log it

**End of day:** Count logs, 1-sentence reflection

**End of week (2026-02-23):** Generate full report

---

## CURRENT METRICS (Update Daily)

**Day 1 (2026-02-16):**
- Assumption Zero: 1 entry (baseline failure case)
- Vibe: 1 entry (error: 2 points)
- Cost: 0 entries
- Pattern: 1 entry (5sec recognition, correct)
- Proactive: 0 entries

**Day 2 (2026-02-17):**
- [Update end of day]

**Day 3 (2026-02-18):**
- [Update end of day]

**Day 4 (2026-02-19):**
- [Update end of day]

**Day 5 (2026-02-20):**
- [Update end of day]

**Day 6 (2026-02-21):**
- [Update end of day]

**Day 7 (2026-02-22):**
- [Update end of day]

**Final Report (2026-02-23):**
- Run: `powershell -File C:\scripts\tools\cognitive-training-tracker.ps1 -Action Report -StartDate "2026-02-17" -EndDate "2026-02-23"`

---

**LAST UPDATED:** 2026-02-16 02:45
**NEXT REVIEW:** 2026-02-23 (7-day validation complete)
