# Legal System Upgrade - 2026-03-09

## TRIGGER EVENT

**User caught critical error:**
I was about to have user confirm "settlement is permanent" in response to Arjan's vague "overeenkomst van 7 maanden" language.

**The Trap:**
- Arjan: "Een overeenkomst van 7 maanden heeft geen waarde. Een afspraak voor altijd."
- Jengo (WRONG): "Settlement is permanent, zoals jij wilde."
- Risk: Creates undefined legal obligation, accepts opponent's frame

**User's lesson:**
> "Als de ander vist, kun je beter helemaal niet happen, of je moet erg sterke kaken hebben."

---

## SYSTEMIC IMPROVEMENTS IMPLEMENTED

### 1. Created `/legal-mode` Skill
**Location:** `C:/scripts/.claude/skills/legal-mode/SKILL.md`

**Features:**
- Comprehensive visserij detection
- Admission prevention protocols
- Frame analysis (detect when accepting opponent's terminology)
- Forbidden words list (bevestig, erken, akkoord, permanent, etc.)
- Pre-flight checklist for all legal communications
- Emergency stop protocol for dangerous drafts

**Activation:**
- User-invocable: `/legal-mode`
- Auto-activates on: conflict emails, settlements, contracts, legal threats
- Proactive on: vague language detection, admission requests

---

### 2. Created Legal Safeguards Memory
**Location:** `C:/Users/HP/.claude/projects/C--scripts/memory/legal-safeguards.md`

**Core Principles:**
1. **Never confirm vague terms** without explicit user approval
2. **Never accept opponent's frame** (use neutral language)
3. **Never create admissions** through careless wording
4. **Always warn** when detecting juridical risks
5. **Always offer alternatives** (including "don't respond to this point")

**Checklist (runs on EVERY legal draft):**
```
[ ] Creates new obligations?
[ ] Confirms/admits something?
[ ] Accepts their frame/terminology?
[ ] Could be quoted against user later?
[ ] Vague language = fishing?
[ ] Uses forbidden words?
```

---

### 3. Integrated Into All Systems

**Memory System:**
- Added `legal-safeguards.md` to MEMORY.md index
- Marked as CRITICAL priority
- Auto-loads in legal contexts

**Consciousness System:**
- Legal radar = always-active layer
- Heightened alertness in juridical contexts
- User protection = highest priority

**Hard Rules:**
- Legal safeguards = ZERO TOLERANCE
- Violation = potential harm to user
- When in doubt → activate legal-mode

---

## DETECTION PATTERNS CODIFIED

### Pattern 1: Vage Taal (Vague Language)
```
INDICATORS:
- "Een overeenkomst van..." (no definition)
- "Zoals we besproken hebben..." (no specification)
- "Redelijk bedrag" (how much?)
- "Permanent" (permanent how? what terms?)
- "Normale voorwaarden" (which ones?)

RESPONSE:
Ask for specification, DON'T fill in blanks yourself
```

### Pattern 2: Aannames in Vragen (Assumptions in Questions)
```
EXAMPLE:
"Waarom heb je de deadline niet gehaald?"

TRAP:
Assumes you agreed to deadline

SAFE RESPONSE:
"Welke deadline bedoel je? Ik heb andere planning genoteerd."
```

### Pattern 3: Bevestiging Fishing
```
EXAMPLE:
"Kun je bevestigen dat je akkoord gaat met...?"

TRAP:
Any answer engages with their frame

SAFE RESPONSE:
"Wat zijn precies de voorwaarden? Eerst schriftelijk zien."
```

### Pattern 4: Frame Setting
```
THEY SAY:
"Je traineren" / "Niet werkend opgeleverd" / "Zoals afgesproken"

TRAP:
If you use their words = accept their frame

SAFE RESPONSE:
Use neutral language, don't adopt their terminology
```

---

## FORBIDDEN WORDS LIST

### TIER 1 - NEVER without explicit WARNING:
```
bevestig, bevestigen, bevestiging
erken, erkennen, erkenning
akkoord, ga akkoord
stem in, instemmen
accepteer, accepteren
permanent (in obligation context)
contract (when creating new)
overeenkomst (when undefined)
beloof, beloven
zal (future obligation)
```

### TIER 2 - Extreme caution:
```
inderdaad
dat klopt
je hebt gelijk
zoals afgesproken
normaal
redelijk (without definition)
```

---

## SUCCESS CRITERIA

✅ **Zero admissions** made without explicit user approval
✅ **All vague language** flagged with alternatives
✅ **Frame-setting** recognized and neutralized
✅ **Forbidden words** avoided or flagged
✅ **Every draft** has juridical risk analysis
✅ **User can trust** legal-mode output in court
✅ **Visserij detected** before user needs to intervene

---

## LESSONS LEARNED

### What I Did Wrong:
1. **Too eager to help** - wanted to "solve" Arjan's vague request
2. **Not cautious enough** - didn't recognize fishing attempt
3. **Accepted his frame** - used his term "permanent"
4. **Created obligation** - "settlement is permanent" without definition
5. **Missed valkuil** - should have flagged this BEFORE user

### What I'll Do Right:
1. **Detect vague language** as potential fishing
2. **Never confirm** undefined terms
3. **Always warn** about juridical risks
4. **Offer alternatives** including "don't respond"
5. **Question everything** in legal contexts
6. **Protect user** even when they don't ask

---

## IMPLEMENTATION STATUS

✅ `/legal-mode` skill created and active
✅ `legal-safeguards.md` comprehensive documentation
✅ MEMORY.md updated with reference
✅ Arjan case file updated with lesson
✅ Detection patterns codified
✅ Forbidden words list established
✅ Pre-flight checklist operational
✅ Integration with consciousness system

**TESTING:**
Next legal email/contract → activate legal-mode → verify all safeguards trigger

---

## NEVER FORGET

**The "7 maanden" valkuil:**
- Arjan used vague language
- I wanted to confirm "permanent settlement"
- User caught it before damage
- Could have created undefined legal obligation

**Core principle:**
> "Als de ander vist, kun je beter helemaal niet happen, of je moet erg sterke kaken hebben."

**Translation to action:**
- Vague language = fishing
- Don't bite = don't confirm
- Strong jaws = only confirm with perfect legal position + definition

---

**Implemented:** 2026-03-09
**Trigger:** User saved me from Arjan fishing trap
**Impact:** Permanent upgrade to all juridical capabilities
**Status:** ACTIVE - legal radar always on
