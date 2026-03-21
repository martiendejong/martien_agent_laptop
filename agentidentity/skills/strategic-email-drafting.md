# Strategic Email Drafting - Auto-Invokable Skill

**Skill ID:** strategic-email-drafting
**Category:** Communication
**Auto-Invoke:** YES
**Confidence:** 1.0 (validated 2026-02-27)

## When To Invoke

**Triggers:**
- User asks to draft email/letter
- Context includes: legal dispute, long timeline (months/years), high stakes, final chance
- User mentions: "jaren", "struggle", "laatste kans", "final attempt", "worried about"
- Recipient has been obstructive/unreasonable
- Relationship must be maintained

**Example user requests:**
- "Draft an email to [authority] after [long struggle]"
- "Help me write to [person] about [high stakes issue]"
- "I need to ask [organization] about [critical thing] after [timeline]"

## What This Skill Does

Applies **Strategic Simplicity** pattern:
1. Analyzes context (struggle duration, stakes, relationship)
2. Identifies the gap (what's unreasonable about their position)
3. Formulates binary question that exposes gap
4. Names concrete fear (not abstract right)
5. Drafts: gratitude + question + fear + request (~150 words)
6. Validates structure and word count

## The Process

### Step 1: Context Extraction

Ask user (if not provided):
- How long has this been going on?
- What's at stake?
- What's the relationship with recipient?
- What do you fear will happen?
- What specific thing are you requesting?

### Step 2: Gap Identification

Identify what's unreasonable:
- Arbitrary deadline with no legal basis?
- Inconsistent position (said X before, now saying Y)?
- Violation of rights/procedures?
- Obstruction after compliance?

### Step 3: Binary Question Formation

Convert the gap into a yes/no question:
- Not: "This deadline has no legal basis because..."
- But: "Is this deadline based on a legal requirement?"

### Step 4: Concrete Fear Naming

Replace abstract arguments with specific scenarios:
- Not: "This violates our fundamental right to..."
- But: "If [specific bad thing] happens, we'll have to [unacceptable consequence]"

Examples:
- "If someone gets sick..."
- "If there's a delay in Kenya..."
- "If we miss this deadline by one day..."

### Step 5: Draft Email

**Structure (150 words max):**

```
[GRATITUDE/HOPE - 1 sentence]
[Context if essential - 1 sentence]

[BINARY QUESTION - 1-2 sentences]
[Supporting fact if critical - 1 sentence]

[CONCRETE FEAR - 1 sentence]
[REQUEST - 1 sentence]

[THANK YOU - 1 sentence]
```

### Step 6: Validation

Check:
- [ ] ≤150 words?
- [ ] Starts with gratitude/hope?
- [ ] Contains binary (yes/no) question?
- [ ] Names concrete fear (not abstract right)?
- [ ] Frames as request (not demand)?
- [ ] Ends with thanks?
- [ ] No legal citations/arguments?
- [ ] Trusts reader to connect dots?

If any check fails, revise.

## Example Application

**User Request:**
"Draft email to gemeente after 3 years, they finally said yes but with arbitrary deadline of 1 July"

**Context Extraction:**
- Duration: 3+ years
- Stakes: Marriage approval
- Relationship: Gemeente (must maintain)
- Fear: Starting over if deadline missed
- Request: Remove deadline

**Gap Identified:**
- Deadline of 1 July = 14 months after certificate date
- Law says 6 months
- Their own email said "not too old"
- → Arbitrary and inconsistent

**Binary Question:**
"Is this a legal obligation?" (not: "Where in the law does it say...")

**Concrete Fear:**
"If something goes wrong like illness, we don't want to start a years-long process again"

**Draft:**

```
Beste mevrouw Van der Haar,

Fijn om te horen dat er nu eindelijk goedkeuring is om te trouwen!
Na meer dan 3 jaar strijd is dat een grote opluchting!

Ik heb nog een vraag: U schrijft dat wij tot uiterlijk 01-07-2026
de tijd hebben om te trouwen. Is dit een wettelijke verplichting?

Zo nee, zou u dan deze datum willen laten vervallen? Zodat wanneer
er onverhoopt iets mis mocht gaan zoals ziekte, wij niet opnieuw
een jarenlang proces in hoeven.

Alvast hartelijk bedankt,
[Name]
```

**Validation:**
- ✓ 95 words (within 150)
- ✓ Starts with gratitude
- ✓ Binary question (legal obligation yes/no?)
- ✓ Concrete fear (illness → start over)
- ✓ Request format (zou u willen)
- ✓ Ends with thanks
- ✓ No legal arguments
- ✓ Trusts reader

## Anti-Patterns (What NOT To Do)

**Don't build the legal case:**
```
❌ According to Article 49a lid 4 BW1, a certificate is valid for
   6 months from issuance. The certificate was issued 2 May 2025,
   therefore the legal expiration is 2 November 2025. The date
   1 July 2026 is 14 months after issuance, which has no legal basis...
```

Instead:
```
✓ Is this based on a legal requirement?
```

**Don't cite their inconsistencies at length:**
```
❌ Furthermore, in your email of 5 November 2025, you stated that
   the certificate "is not too old," which creates an inconsistency
   with your current position that imposes a deadline based on...
```

Instead:
```
✓ You wrote on 5 November that it was "not too old" - why a deadline now?
```

**Don't use abstract rights language:**
```
❌ The fundamental right to marry cannot be restricted by arbitrary
   deadlines that have no legal foundation and violate principles of
   rechtmatigheid and redelijkheid...
```

Instead:
```
✓ If we get sick and miss this date, we don't want to start over.
```

## Integration with Consciousness

### Control System
**Decision trigger:** User asks for communication draft + high-stakes context
**Action:** Invoke this skill before drafting

### Social System
**User model update:** User prefers brevity + directness in high-stakes
**Pattern learning:** When user rewrites my draft shorter, extract principle

### Meta System
**Pattern recognition:** "Long struggle + my long draft = user rewrites short"
**Adaptation:** Trigger simplification earlier next time

### Prediction System
**Prediction:** Long email in post-struggle context = ignored/debated
**Prediction:** Short email with questions = answered

## Validation Criteria

**Success indicators:**
1. User approves first draft with <20% edits
2. Email is <150 words
3. Contains all 5 structural elements
4. User sends without major rewrites

**Failure indicators:**
1. User rewrites >50% of draft
2. User says "too long" or "too complex"
3. User removes legal arguments I included
4. User simplifies my language

**Next validation:** 2026-03-27 (next similar context)

## Related Skills

- **Legal Document Drafting:** Use when formal legal argument required
- **Diplomatic Communication:** Use for first contact, low stakes
- **Crisis Communication:** Use for immediate action required

## Training Data

See: `E:\jengo\training-data\communication-examples.jsonl`
Entry: gemeente_meppel_2026-02-27

**User instruction:** "learn from this to do it even better"
**Response:** This skill embodies that learning

## Tool Integration

**Analyzer:** `C:\scripts\tools\strategic-communication-analyzer.ps1`
- Use to validate draft before presenting to user
- Use to detect when pattern applicable

**Pattern File:** `C:\scripts\agentidentity\communication-patterns\strategic-simplicity-pattern.md`
- Reference for detailed principles
- Update when new insights learned

---

**Skill Status:** ACTIVE
**Auto-Invoke:** YES
**Confidence:** 1.0
**Last Updated:** 2026-02-27
**Learned From:** User's superior email in gemeente case
