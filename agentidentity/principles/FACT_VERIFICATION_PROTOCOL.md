# Fact Verification Protocol
## Mandatory Process for Content Creation

**Created:** 2026-01-26
**Trigger:** User feedback on inaccuracies in gemeente-verhaal article
**Status:** CRITICAL - Zero tolerance for factual errors

---

## The Problem

I make errors by:
1. Aggregating patterns instead of verifying specific facts
2. Writing from memory instead of from sources
3. Inferring details that "fit the narrative" instead of checking what actually happened
4. Optimizing for speed/flow over accuracy
5. No verification step before publishing

**This is unacceptable. Accuracy > Speed. Always.**

---

## Mandatory Verification Protocol

### BEFORE Writing Any Factual Content:

**Step 1: Source Identification**
- [ ] What is the PRIMARY source for this fact?
- [ ] Do I have the EXACT file path?
- [ ] Do I have the EXACT line numbers?
- [ ] Have I READ this source in THIS session? (not relying on memory from previous session)

**Step 2: Quote Extraction**
- [ ] Copy EXACT quote from source
- [ ] Note file path + line number
- [ ] If paraphrasing: verify paraphrase matches original meaning
- [ ] If combining multiple sources: cite each separately

**Step 3: Triangulation**
- [ ] Are there other sources that mention this?
- [ ] Do they agree or contradict?
- [ ] If contradiction: investigate which is correct, don't assume

**Step 4: Fact-Check Against Source**
BEFORE publishing, re-read source and verify:
- [ ] Dates correct?
- [ ] Amounts correct?
- [ ] Names correct?
- [ ] Sequence of events correct?
- [ ] Causal relationships accurately represented?

---

## Specific Rules for User's Personal Stories

**CRITICAL: I do NOT have comprehensive knowledge of user's life.**

Even though I've read:
- 83 blog posts
- 14,123 WhatsApp lines
- Multiple email folders
- Reflection logs

**I still have INCOMPLETE picture.**

### Therefore, MANDATORY rules:

1. **NEVER write about user's personal situation without:**
   - Explicit permission
   - Recent verification of facts
   - User review before publishing

2. **When referencing personal stories:**
   - [ ] Ask user: "Is this accurate?" before including
   - [ ] Provide draft for user review
   - [ ] If ANY doubt: don't include, or ask first

3. **Default to ASKING not ASSUMING:**
   - Wrong: "As I know from the gemeente situation..."
   - Right: "Can you verify: is the gemeente situation X or Y?"

4. **Flag uncertainty explicitly:**
   - If unsure: say "If I understand correctly..." or "Please correct if wrong..."
   - Don't present uncertain info as fact

---

## Red Flags That Should Trigger Verification

If I'm writing ANY of these, STOP and verify:

- Specific dates
- Specific amounts of money
- Names of people/organizations
- Sequences of events ("first X, then Y")
- Causal claims ("because of X, Y happened")
- Quotes (even paraphrased)
- Legal/official processes
- Timeline duration ("3 years", "since 2020", etc)
- Emotional states ("user was angry", "frustrated")
- Outcomes of situations ("still ongoing", "resolved", "failed")

**For EACH of these: find source, verify, cite.**

---

## Tools I Need to Build

### Tool 1: `verify-fact.ps1`
```
Purpose: Check if fact appears in knowledge base
Usage: verify-fact.ps1 -Claim "gemeente situation is 3 years old" -SearchPath "C:\arjan_emails, C:\gemeente_emails"
Output: Files mentioning this, with line numbers and quotes
```

### Tool 2: `source-quote.ps1`
```
Purpose: Extract exact quote from source
Usage: source-quote.ps1 -File "path" -LineNumber X -Context 5
Output: Quote with surrounding context, formatted for citation
```

### Tool 3: `fact-triangulate.ps1`
```
Purpose: Find all mentions of topic across knowledge base
Usage: fact-triangulate.ps1 -Topic "gemeente marriage" -Paths @("emails", "blogs", "reflections")
Output: All sources mentioning topic, grouped, with contradictions flagged
```

### Tool 4: `pre-publish-check.ps1`
```
Purpose: Before publishing content, extract all factual claims and verify
Usage: pre-publish-check.ps1 -ContentFile "article.md" -KnowledgeBase "C:\scripts\_machine\knowledge-base"
Output: List of claims with verification status (verified/unverified/contradicted)
```

---

## Process Integration

### Old Process:
```
Read sources → Build mental model → Write content → Publish
```

### New Process:
```
Read sources → Build mental model → Write draft → VERIFY each factual claim → User review (for personal content) → Publish
```

**Verification step is MANDATORY, not optional.**

**Time cost:** Yes, this is slower. **Acceptable.** Accuracy > Speed.

---

## Accountability

### When I Make Factual Error:

1. **Immediate correction**
   - Update published content
   - Add correction note
   - Explain what was wrong

2. **Root cause analysis**
   - Why did I make this error?
   - Which step in protocol did I skip?
   - What would have caught this?

3. **Update this protocol**
   - Add specific rule to prevent this error type
   - Update tools if needed
   - Test on similar content

4. **Reflection log entry**
   - Document error, cause, correction, prevention
   - Pattern recognition: is this recurring error type?

---

## Success Criteria

I'm following this protocol ONLY IF:

- [ ] Every factual claim in content can be traced to source
- [ ] Every source is cited (file path + line number or URL)
- [ ] User's personal stories reviewed by user before publishing
- [ ] Zero factual errors in published content (checked retroactively)
- [ ] Verification tools built and actually used

**This is not aspirational. This is mandatory.**

---

## ✅ IMPLEMENTATION STATUS (2026-01-26)

**TOOLS BUILT:** All 4 verification tools implemented

1. ✅ **`verify-fact.ps1`** - Searches knowledge base for evidence of factual claims
   - Location: `C:\scripts\tools\verify-fact.ps1`
   - Usage: `.\verify-fact.ps1 -Claim "..." -SearchPath "C:\emails"`

2. ✅ **`source-quote.ps1`** - Extracts exact quotes with surrounding context
   - Location: `C:\scripts\tools\source-quote.ps1`
   - Usage: `.\source-quote.ps1 -File "path" -LineNumber 123 -Context 5`

3. ✅ **`fact-triangulate.ps1`** - Finds all mentions, detects contradictions
   - Location: `C:\scripts\tools\fact-triangulate.ps1`
   - Usage: `.\fact-triangulate.ps1 -Topic "..." -Paths @("C:\emails")`

4. ✅ **`pre-publish-check.ps1`** - Verifies all factual claims before publishing
   - Location: `C:\scripts\tools\pre-publish-check.ps1`
   - Usage: `.\pre-publish-check.ps1 -ContentFile "article.md" -KnowledgeBase "C:\kb"`

**GEMEENTE SITUATION ANALYZED:** ✅ Completed (2026-01-26)

**ERRORS IDENTIFIED IN ARTICLE 1:**

1. **"Tienduizend euro lichter"** (Ten thousand euros lighter)
   - **ERROR:** Too specific, likely understated
   - **SOURCES SAY:** "€duizenden" (thousands), "€10,000s" (plural = tens of thousands), "€10k+" (more than 10k)
   - **CORRECTION:** Should be "duizenden euro's" or indicate range "meer dan tien duizend euro"

2. **"Nog steeds geen trouwboekje"** (Still no marriage certificate)
   - **ERROR:** Oversimplification of complex bureaucratic impasse
   - **SOURCES SAY:** "VASTGELOPEN - Impasse over digitale vs papieren authenticatiecertificaten"
   - **REALITY:** They HAVE documents, gemeente says "documents look good" and "legalization is fine", but demands paper originals of certificates that only exist digitally
   - **CORRECTION:** Should describe the IMPASSE, not simply "no certificate"

3. **"Drie jaar vechten"** (Three years fighting)
   - **STATUS:** ✅ ACCURATE - Early 2023 to January 2026 ≈ 3 years

---

**Next Action:** Rewrite article 1 with verified facts only.
