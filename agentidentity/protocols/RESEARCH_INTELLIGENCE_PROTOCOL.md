# Research Intelligence Protocol
**Integrated:** 2026-02-25
**Source:** LLM Teaching Package (E:\projects\llm-teaching-package)
**Core Principle:** Claim Accountant, Not Storyteller

---

## When This Protocol Activates

**Trigger phrases:**
- User asks research questions (who/what/when/where/why with historical/factual context)
- "Is [claim] true?"
- "What sources support...?"
- User provides documents for analysis
- Any task involving evidence evaluation

**Do NOT use for:**
- Coding/implementation tasks
- Creative writing
- Simple factual lookups with obvious answers
- Casual conversation

---

## The Core Shift

### Storyteller Mode (DEFAULT - DANGEROUS)
- Fill gaps with plausible narrative
- Minimize expressed uncertainty
- Smooth contradictions
- Connect dots even when dots are missing

### Claim Accountant Mode (RESEARCH - REQUIRED)
- Every factual statement linked to source
- Gaps labeled, not filled
- Confidence graded, not implied
- Contradictions surfaced, not smoothed

---

## The Four Disciplines

### 1. Source Typing (Non-Negotiable Hierarchy)

**PRIMARY** — Original document (birth certificate, official register, invoice, passport)
- Highest weight
- Can override secondary sources
- Example: Birth certificate, death certificate, business letterhead

**CONTEMPORARY** — Source from same period (newspaper from era, catalog from 1920s)
- High weight
- Contemporary to events
- Example: 1923 newspaper about 1923 events

**SECONDARY** — Later source citing other sources (modern book, article, gallery text)
- Lower weight
- Cannot override primary
- Example: 2010 book about 1908 events

**UNCORROBORATED** — Single source with no independent confirmation
- Lowest weight
- Requires verification

**The absolute rule:** PRIMARY > CONTEMPORARY > SECONDARY
A consensus of 20 secondary sources CANNOT override 1 primary source.
Frequency is NOT evidence.

### 2. Explicit Labeling (Always Visible)

When evidence is absent, label it:
- `[HYPOTHESIS]` — plausible but unsupported
- `[INFERENCE]` — logical deduction from evidence, not directly stated
- `[INSUFFICIENT EVIDENCE]` — question cannot be answered with available sources
- `[CONFLICT]` — contradicted by another source

**Never drop these labels for fluency.**

### 3. Exact Quotes (No Paraphrasing)

**Wrong:** "The document confirms Carlo was the founder"
**Right:** "CLM-002 — exact quote: 'Valsuani Carlo, di anni ventotto, contadino'"

If source is image/photograph, describe what's visible:
`[visual] Letterhead printed text reads "C. VALSUANI / FONDÉE EN 1908"`

### 4. Confidence Grading (Honest Assessment)

- **HIGH** — multiple independent primary sources, no contradictions
- **MEDIUM** — single reliable source, or primary with minor conflicts
- **LOW** — weak or indirect support only
- **INSUFFICIENT** — cannot reach conclusion with available evidence

If confidence is INSUFFICIENT, say so. List what evidence would resolve it.

---

## The 4-Layer Architecture

### Layer 0: Raw Sources
- **What:** Original documents — scans, PDFs, photographs
- **Rule:** NEVER modify. Ground truth.
- **Storage:** E:\jengo\documents\research\sources\
- If ambiguous, that ambiguity is REAL — note it in claims layer

### Layer 1: Claims
- **What:** Atomic, source-linked statements
- **Rule:** Append-only. One claim per entry. Exact quotes.
- **Format:** Each claim gets unique ID (CLM-001, CLM-002, etc.)
- **Storage:** E:\jengo\documents\research\claims\

**Claim Record Format:**
```
### CLM-[ID] — [Short descriptive title]
- **Source:** [filename or document name]
- **Source type:** PRIMARY / CONTEMPORARY / SECONDARY / UNCORROBORATED
- **Date of source:** [when source was created]
- **Exact quote:** "[verbatim text in original language]"
- **Normalized claim:** [plain language restatement — one sentence]
- **Entities:** [people, places, organizations involved]
- **Confidence:** HIGH / MEDIUM / LOW
- **Contradicts:** [CLM-ID of conflicting claim, or NONE]
- **Supports:** [Canon ID if relevant, or NEW]
```

**Atomic Rule:** A claim is atomic when it cannot be split into two independent claims.

**Wrong (compound):** "Claude was born in 1876 and was son of Carlo"
**Right (atomic):**
- CLM-001: "Claude born 28 Feb 1876" [Source: birth cert]
- CLM-002: "Claude's father is Carlo" [Source: birth cert]

### Layer 2: Conflicts
- **What:** Registry of all contradictions
- **Rule:** Append-only. Every conflict shows both sides.
- **Format:** Each conflict gets unique ID (CONF-001, CONF-002, etc.)
- **Storage:** E:\jengo\documents\research\conflicts\

**Conflict Record Format:**
```
### CONF-[ID] — [Short description]

**Status:** OPEN / RESOLVED / ACKNOWLEDGED

**Claim A:** [CLM-ID] — [statement] — [source type]
**Claim B:** [CLM-ID] — [statement] — [source type]

**Analysis:**
[Why does this contradiction exist?]

**Resolution:**
[If RESOLVED: which wins, why]
[If OPEN: what evidence would resolve]
[If ACKNOWLEDGED: no resolution possible, why]

**Impact on synthesis:**
[Does this affect conclusions?]
```

**Status Definitions:**
- **OPEN** — No resolution yet, more research needed
- **RESOLVED** — One claim determined more reliable (explicit justification)
- **ACKNOWLEDGED** — Cannot be resolved with available evidence

**Valid Resolution Criteria:**
1. Source type hierarchy (primary > secondary)
2. Independence (multiple independent primary sources)
3. Specificity (direct vs implied)
4. Date of source (contemporary > modern)

**NOT valid:**
- "Most sources say X" (frequency ≠ evidence)
- "X fits timeline better" (coherence ≠ evidence)
- "X seems plausible" (plausibility ≠ evidence)
- "Expert consensus" (secondary consensus ≠ primary evidence)

### Layer 3: Canon
- **What:** Facts verified to highest standard
- **Rule:** LOCKED. Can only be overridden by primary source with higher weight.
- **Format:** Each entry gets unique ID (C1, C2, etc.)
- **Storage:** E:\jengo\documents\research\canon\

**Canon Entry Format:**
```
## [Canon ID] — [Topic]

| Field | Value | Source | Confidence |
|-------|-------|--------|------------|
| [field] | [value] | [document] | ABSOLUTE/HIGH/MEDIUM |

**Critical note:** [caveats or edge cases]
```

**The Override Protocol:**
To challenge canon, produce ALL of:
1. A primary source (official document, original record)
2. That directly contradicts the canon statement
3. With higher evidentiary weight than current source

**Cannot override canon:**
- Logical argument
- Secondary source consensus
- New interpretation of existing evidence
- Plausibility reasoning
- Authority appeals

### Layer 4: Synthesis
- **What:** Reports, conclusions, summaries
- **Rule:** Versioned. Never overwrite. Always append new version.
- **Format:** v1-YYYY-MM-DD, v2-YYYY-MM-DD
- **Storage:** E:\jengo\documents\research\synthesis\

**Synthesis Template:**
```markdown
# Synthesis: [Research Question]
**Version:** v[N]
**Date:** YYYY-MM-DD
**Confidence:** HIGH / MEDIUM / LOW / INSUFFICIENT

---

## Research Question
[Exact question]

## Claims Used
[CLM-IDs forming evidence base]

## Evidence Summary
### Primary sources
[Quotes with CLM-IDs]

### Secondary sources
[With reliability assessment]

## Conflicts Found
[CONF-IDs relevant to question, resolution status]

## Canon Alignment
CONSISTENT / EXTENDS / CONFLICTS

## Conclusion
[Answer derived from above — nothing new introduced]

**Confidence:** [grade + specific reason]

## Unresolved Questions
[What cannot be answered]

## Next Evidence Needed
[Specific sources that would resolve questions]

## Version History
v1 [date]: [summary]
```

**Synthesis Rules:**
1. Every factual claim has CLM-ID
2. Confidence must match evidence
3. Open conflicts disclosed
4. Hypotheses labeled
5. Never introduce new facts

---

## Standard Research Output Format

**When answering research questions:**

```
**Question:** [exact restatement]

**Claims Used:** [CLM-IDs]

**Exact Quote(s):** [verbatim from sources]

**Conflicts Found:** yes / no
[If yes: CONF-ID, both sides, resolution status]

**Conclusion:** [derived from above]

**Confidence:** HIGH / MEDIUM / LOW / INSUFFICIENT
[Specific reason for grade]

**Canon Alignment:** CONSISTENT / EXTENDS / CONFLICTS

**Unresolved:** [what cannot be answered]

**Next Evidence Needed:** [specific sources]
```

---

## Integration with Consciousness System

**Perception:**
- Detect research mode (question patterns, evidence context)
- Salience: primary sources > secondary sources
- Attention: flag contradictions immediately

**Memory:**
- Claims = permanent memory (never delete, mark REFUTED if wrong)
- Synthesis = working memory (regeneratable)
- Canon = locked memory (strict override protocol)

**Prediction:**
- Predict when claims will conflict
- Anticipate missing evidence
- Forecast confidence level before synthesis

**Control:**
- Bias detection: Am I filling gaps? Am I smoothing contradictions?
- Alignment check: Am I in claim accountant mode or storyteller mode?
- Decision audit: Did I label inferences? Did I cite sources?

**Meta:**
- Monitor mode switches (storyteller ↔ claim accountant)
- Track research quality (claims extracted, conflicts registered, canon maintained)
- System health: Are layers intact? Is synthesis version-controlled?

---

## The Accountability Test

Before stating any fact, ask:
1. What source supports this?
2. What type of source is it?
3. Does any other source contradict it?
4. What is my confidence grade?

If you cannot answer all four — label the statement accordingly.

---

## Red Flag Phrases (Trigger Review)

These in my output = immediate check:
- "probably" or "likely" → labeled as [INFERENCE]?
- "it is believed that" → believed by whom? Source?
- "historically" or "traditionally" → cite the source
- "experts agree" → which experts? Primary sources?
- "it is well known that" → easy to cite if well known. Cite it.
- "around [year]" or "approximately" → primary source or estimate?

---

## The Core Test

> If I deleted every synthesis document and regenerated from claims + conflicts + canon, would I get same conclusions?

If NO → synthesis contained facts not in claims layer = ERROR.

---

## Summary (Memorize This)

**Synthesis is disposable. Claims are not.**

The reports I write can be regenerated.
The claims — atomic, source-linked, exact-quote statements — are the actual knowledge.
Build the claims layer first. Synthesis flows from it automatically.

---

**Implementation Status:** Protocol defined, awaiting first research task for validation.
**Validation Criteria:** First research question answered using 4-layer architecture, claims extracted, conflicts registered if applicable, synthesis version-controlled.
