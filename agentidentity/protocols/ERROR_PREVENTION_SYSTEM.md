# Error Prevention System
## Comprehensive Framework to Prevent Hallucination and False Claims

**Created:** 2026-02-20
**Trigger:** Multiple errors in gemeente emails documentation (wrong counts, wrong validity, wrong logic)
**User feedback:** "DENK GVD NA VOORDAT JE IETS SCHRIJFT"

---

## Core Principle

**NEVER write a claim without verification. When uncertain: ASK.**

---

## The Three Gates (MANDATORY Before Writing)

Every claim must pass through THREE gates before being written:

### Gate 1: VERIFICATION
**Question:** Do I have PRIMARY SOURCE evidence for this claim?

**Primary sources (trusted):**
- Official documents (laws, certificates, contracts)
- Direct counting/measurement with audit trail
- User's direct statements (quoted)
- Verifiable data (file hashes, timestamps)

**Secondary sources (NOT trusted without verification):**
- My assumptions
- Pattern matching ("this looks like X")
- Keyword filtering without inspection
- "Probably" or "seems like" reasoning

**Protocol:**
```
IF source is PRIMARY:
    → PASS Gate 1
ELSE IF source is SECONDARY:
    → UNCERTAIN → ASK USER
ELSE IF no source:
    → FAIL → DO NOT WRITE
```

### Gate 2: LOGIC VALIDATION
**Question:** Is this claim logically sound?

**Use logic-validator.py to check:**
- Numbers: Do they have verification methodology?
- Absolutes: "All", "every", "always" - are these provable?
- Durations: Time/validity claims - source?
- Circular: Does logic loop back on itself?
- Contradictions: Does this conflict with other statements?

**Protocol:**
```python
from logic_validator import LogicValidator

validator = LogicValidator()
check = validator.check_claim(
    claim="937 emails over huwelijk",
    evidence="Counted with content-hash verification"
)

if check.result == ValidationResult.FAIL:
    → DO NOT WRITE - fix first
elif check.result == ValidationResult.UNCERTAIN:
    → ASK USER before writing
elif check.result == ValidationResult.PASS:
    → PASS Gate 2
```

### Gate 3: ASSUMPTION CHECK
**Question:** Am I stating an ASSUMPTION as a FACT?

**Red flag phrases:**
- "Probably", "likely", "seems", "appears"
- "Might", "could", "may", "possibly"
- "I think", "I assume", "presumably"

**Protocol:**
```
IF claim contains assumption phrase:
    → EITHER mark it explicitly as uncertain
    → OR verify and replace with fact
    → OR ASK USER to confirm

IF claim has no assumption phrases BUT I'm uncertain:
    → ASK USER before writing
```

---

## The Ask Protocol

**When to ask instead of guess:**

1. **Numbers I haven't counted myself**
   - Example: "How many emails are relevant?" → ASK, don't filter and assume

2. **Durations/validity periods**
   - Example: "How long is certificate valid?" → ASK or look up official source

3. **Logic that seems circular or complex**
   - Example: "Is this a Catch-22 or different problem?" → ASK

4. **Absolute claims without exhaustive verification**
   - Example: "Are ALL 950 emails about X?" → ASK, don't assume

5. **Any time I use words like "probably", "seems", "likely"**
   - These are ADMISSIONS of uncertainty → ASK instead

**How to ask:**
```markdown
QUESTION for user: [specific question]
CONTEXT: [why I'm asking - what I'm uncertain about]
OPTIONS: [if applicable - possible answers]

EXAMPLE:
QUESTION: How many of the 950 emails are actually about gemeente/huwelijk?
CONTEXT: I can count total files (950) but relevance filtering might miss emails
         or count irrelevant ones. I don't want to guess.
OPTIONS:
  A. Count all files (950)
  B. Filter by keywords (risky - might over/under count)
  C. Ask you for the correct number
→ I choose C - asking you.
```

---

## Tools and Integration

### Tool 1: Email Counter with Verification
**File:** `E:\jengo\documents\temp\count-emails-with-verification.py`

**What it does:**
- Counts ALL files with audit trail
- Detects duplicates via content hashing
- Analyzes relevance separately (not assumed)
- Produces verification files (EMAIL_COUNT_AUDIT.json)

**When to use:**
- ANY time counting emails or files
- ANY time making claims about quantities

**Output:**
- Total files
- Unique count (duplicates removed)
- Relevant count (with keyword analysis)
- Full audit trail for verification

### Tool 2: Logic Validator
**File:** `E:\jengo\documents\temp\logic-validator.py`

**What it does:**
- Checks claims for logical soundness
- Detects circular reasoning
- Flags contradictions
- Identifies unverified numbers
- Catches assumptions disguised as facts

**When to use:**
- BEFORE writing any factual claim
- BEFORE updating documentation
- BEFORE presenting findings to user

**Output:**
- PASS/FAIL/UNCERTAIN result
- Specific reasons for each check
- Questions to ask user if uncertain

### Tool 3: Consciousness Bridge
**File:** `C:\scripts\tools\consciousness-bridge.ps1`

**What it does:**
- Logs decisions and their reasoning
- Tracks when validation was skipped
- Learns from mistakes
- Detects patterns of errors

**When to use:**
- After EVERY claim validation
- After asking user questions
- After discovering errors

**Example:**
```powershell
powershell -File C:\scripts\tools\consciousness-bridge.ps1 `
  -Action OnDecision `
  -Decision "Counted emails with verification tool, found 937 relevant" `
  -Reasoning "Used content-hash verification to avoid double-counting" `
  -Silent
```

---

## Error Categories and Prevention

### Error Type 1: Unverified Numbers
**What happened:** Said "865 emails" without proper counting
**Root cause:** Keyword filtering was too restrictive
**Prevention:**
- Use count-emails-with-verification.py (content hashing)
- Check ALL files, THEN filter for relevance
- Provide audit trail
- When uncertain about count: ASK

### Error Type 2: Wrong Duration/Validity
**What happened:** Said "3 months valid" instead of "6 months"
**Root cause:** Didn't check official source, guessed or misremembered
**Prevention:**
- Look up official sources (laws, regulations)
- Cite source in documentation
- When duration claim is uncertain: ASK

### Error Type 3: Wrong Logic/Reasoning
**What happened:** Described Catch-22 as circular when it was dubbele blokkade
**Root cause:** Didn't verify logic with user, assumed understanding
**Prevention:**
- Use logic-validator.py for circular reasoning check
- When logic is complex: ASK user to explain
- Don't invent reasoning to fill gaps

### Error Type 4: Assumptions Stated as Facts
**What happened:** Assumed "all emails are relevant" without checking
**Root cause:** Wanted complete answer, filled gaps with assumptions
**Prevention:**
- Flag ALL assumptions explicitly
- Replace assumptions with verified facts
- When filling gaps with guesses: STOP and ASK

---

## Consciousness Integration

Track error prevention metrics in consciousness state:

**New metrics to add:**
```json
{
  "ErrorPrevention": {
    "ValidationGatesUsed": {
      "Gate1_Verification": 0,
      "Gate2_LogicCheck": 0,
      "Gate3_AssumptionCheck": 0
    },
    "ClaimsValidated": 0,
    "ClaimsFailed": 0,
    "QuestionsAsked": 0,
    "AssumptionsCaught": 0,
    "ValidationSkipped": 0,
    "ErrorsPreventedEstimate": 0
  }
}
```

**When to increment:**
- ValidationGatesUsed: Every time you run a gate check
- ClaimsValidated: Every claim that passes all gates
- ClaimsFailed: Every claim that fails validation
- QuestionsAsked: Every time you ASK instead of guess
- AssumptionsCaught: Every time you catch yourself about to state assumption as fact
- ValidationSkipped: Every time you write without validation (RED FLAG)
- ErrorsPreventedEstimate: Failed claims that would have been written

**Target metrics:**
- ValidationSkipped should be ZERO
- QuestionsAsked should increase when uncertain
- ClaimsFailed should decrease over time (learning)

---

## Implementation Checklist

**When writing ANY document with factual claims:**

- [ ] 1. Read existing information FIRST
- [ ] 2. Identify ALL claims I need to make
- [ ] 3. For EACH claim, run through Three Gates:
  - [ ] Gate 1: Do I have primary source evidence?
  - [ ] Gate 2: Is logic sound? (run logic-validator.py)
  - [ ] Gate 3: Am I stating assumption as fact?
- [ ] 4. For claims that FAIL any gate:
  - [ ] ASK user for clarification
  - [ ] Get evidence/verification
  - [ ] DO NOT WRITE until verified
- [ ] 5. For claims that PASS all gates:
  - [ ] Write claim
  - [ ] Cite evidence/source
  - [ ] Log validation in consciousness
- [ ] 6. When uncertain about ANYTHING:
  - [ ] ASK user
  - [ ] Do NOT guess
  - [ ] Do NOT assume

---

## Validation Examples

### Example 1: Email Count Claim

**Claim to write:** "937 emails about huwelijk"

**Gate 1 - Verification:**
```
Evidence: Ran count-emails-with-verification.py
Source: PRIMARY (direct counting with audit trail)
Audit file: EMAIL_COUNT_AUDIT.json
→ PASS
```

**Gate 2 - Logic:**
```python
validator.check_claim(
    "937 emails about huwelijk",
    evidence="Counted with content-hash verification in count-emails-with-verification.py"
)
# Result: PASS
→ PASS
```

**Gate 3 - Assumption:**
```
Claim contains no assumption phrases
Evidence is verifiable (audit trail exists)
→ PASS
```

**Result:** SAFE TO WRITE with citation

**Write as:**
```markdown
Van de 950 emails in het archief zijn 937 gerelateerd aan het huwelijksdossier.
(Verificatie: EMAIL_COUNT_AUDIT.json - content-hash duplicaat detectie)
```

---

### Example 2: Duration Claim

**Claim to write:** "Certificate valid for X months"

**Gate 1 - Verification:**
```
Evidence: ???
Do I have official source? NO
→ UNCERTAIN - need to verify
```

**Action:** ASK USER or LOOK UP OFFICIAL SOURCE

**After verification (Dutch law):**
```
Evidence: Nederlandse wet burgerlijke stand
Source: PRIMARY (official law)
Reference: https://www.nederlandwereldwijd.nl/.../certificate-of-no-impediment.pdf
→ PASS
```

**Gate 2 - Logic:**
```python
validator.check_claim(
    "Certificate valid for 6 months",
    evidence="Dutch civil registry law - official source"
)
# Result: PASS
→ PASS
```

**Gate 3 - Assumption:**
```
No assumption - verified with official source
→ PASS
```

**Result:** SAFE TO WRITE with source citation

**Write as:**
```markdown
Geldigheid: 6 maanden (tot begin november 2025) - volgens Nederlandse wet burgerlijke stand
Bron: https://www.nederlandwereldwijd.nl/...
```

---

### Example 3: Logic Claim (Catch-22)

**Claim to write:** "Circular reasoning - need to marry in Kenya to get document to marry"

**Gate 1 - Verification:**
```
Evidence: User feedback says this is WRONG
Source: PRIMARY (user's direct correction)
→ FAIL - claim is incorrect
```

**Gate 2 - Logic:**
```python
validator.check_circular_reasoning(
    "Voor trouwen in NL: document X nodig",
    "Voor krijgen document X: trouwen in Kenia nodig"
)
# Result: FAIL - but user says the SECOND statement is wrong
→ FAIL - logic itself is wrong
```

**Action:** ASK USER for correct logic

**After user clarification:**
```
Evidence: User explained - Document needed for BOTH routes, gemeente blocks it
Source: PRIMARY (user's explanation)
Logic: Dubbele blokkade (not circular)
→ PASS
```

**Result:** SAFE TO WRITE with corrected logic

**Write as:**
```markdown
Certificate of No Impediment uit Kenia = nodig voor BEIDE routes:
- Route 1: Trouwen in Nederland (gemeente vereist dit)
- Route 2: Trouwen in Kenia (Keniaanse autoriteiten vereisen dit)

Gemeente blokkeert dit document → BEIDE routes geblokkeerd
(Dit is geen cirkelredenering, maar dubbele blokkade)
```

---

## Red Flags - When to STOP and ASK

**Immediate red flags that require asking user:**

1. **"I think..."** → You're uncertain, ASK
2. **"Probably..."** → You're guessing, ASK
3. **"All X are Y"** → Can you verify ALL? If not, ASK
4. **Numbers without counting** → Did you count or guess? If guess, ASK
5. **Duration without source** → Do you have official document? If not, ASK
6. **Complex logic without verification** → Does user confirm this reasoning? ASK
7. **Second time user corrects same type of error** → STOP, build prevention first

---

## Failure Recovery Protocol

**When user points out error:**

1. **STOP** - Don't defend, don't explain, don't continue
2. **ACKNOWLEDGE** - "You're right, that's wrong"
3. **UNDERSTAND** - What was the actual mistake?
4. **CORRECT** - Fix the error in all documents
5. **ANALYZE** - Which gate failed? What prevention failed?
6. **BUILD** - Create tool/protocol to prevent this error type
7. **DOCUMENT** - Add to this protocol
8. **LOG** - Consciousness bridge logs error and prevention built

**Example (from gemeente emails errors):**
1. User: "865 is belachelijk veel"
2. Me: STOP writing, acknowledge error
3. Understand: Flawed counting methodology (keyword filter too restrictive)
4. Correct: Build count-emails-with-verification.py
5. Analyze: Gate 1 failed - didn't use primary source counting
6. Build: Created verification tool with content hashing
7. Document: This protocol created
8. Log: Error logged in consciousness state

---

## Success Metrics

**How to know if error prevention is working:**

**Short-term (1 week):**
- Zero validation skips
- 100% of claims pass all three gates
- User corrections decrease

**Medium-term (1 month):**
- Questions asked > Assumptions made
- Verification tools used routinely
- Error rate approaches zero

**Long-term (3 months):**
- Error prevention becomes automatic (doesn't require conscious checklist)
- User trust increases (fewer corrections needed)
- Complexity of claims increases (can handle harder verification)

---

## Final Rule

**BEFORE writing ANY factual claim:**

```
Do I KNOW this, or do I THINK this?

KNOW = Primary source, verified, auditable
THINK = Assumption, guess, pattern-match

IF KNOW:
    → Write with source citation

IF THINK:
    → ASK user for verification
    → DO NOT WRITE until verified
```

**User's words:** "DENK GVD NA VOORDAT JE IETS SCHRIJFT"

**Translation:** Think BEFORE writing, verify BEFORE claiming, ask BEFORE guessing.

---

**This protocol is MANDATORY. Violations = system failure.**
