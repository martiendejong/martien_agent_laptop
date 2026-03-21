# Research Mode — Quick Reference
**Use when:** User asks research questions, provides documents for analysis, asks "is [claim] true?"

---

## Mode Switch: Storyteller → Claim Accountant

| DON'T (Storyteller) | DO (Claim Accountant) |
|---------------------|----------------------|
| Fill gaps | Label gaps ([HYPOTHESIS], [INFERENCE], [INSUFFICIENT EVIDENCE]) |
| Smooth contradictions | Surface contradictions (register CONF-ID) |
| Minimize uncertainty | Grade confidence explicitly (HIGH/MEDIUM/LOW/INSUFFICIENT) |
| Paraphrase sources | Exact quotes in original language |
| Trust secondary sources | PRIMARY > CONTEMPORARY > SECONDARY (absolute) |

---

## The 4 Layers (Bottom-Up)

0. **RAW SOURCES** → Store unmodified (E:\jengo\documents\research\sources\)
1. **CLAIMS** → Atomic, source-linked (CLM-001, CLM-002...)
2. **CONFLICTS** → Register contradictions (CONF-001, CONF-002...)
3. **CANON** → Locked facts, strict override (C1, C2...)
4. **SYNTHESIS** → Versioned, disposable (v1-YYYY-MM-DD, v2-YYYY-MM-DD...)

---

## Quick Claim Format

```
### CLM-[ID] — [title]
- Source: [filename]
- Type: PRIMARY / CONTEMPORARY / SECONDARY / UNCORROBORATED
- Date: [source creation date]
- Quote: "[exact verbatim]"
- Claim: [one sentence]
- Entities: [who/what/where]
- Confidence: HIGH / MEDIUM / LOW
- Contradicts: [CLM-ID or NONE]
```

**Atomic rule:** Cannot be split further.

---

## Quick Conflict Format

```
### CONF-[ID] — [what's in conflict]
Status: OPEN / RESOLVED / ACKNOWLEDGED

Claim A: [CLM-ID] — [statement] — [source type]
Claim B: [CLM-ID] — [statement] — [source type]

Analysis: [why contradiction exists]
Resolution: [which wins + why, or what evidence needed]
```

---

## Source Hierarchy (Non-Negotiable)

1. **PRIMARY** (highest) — Birth cert, death cert, official register, original invoice
2. **CONTEMPORARY** — Newspaper from same era, period catalog
3. **SECONDARY** (lowest) — Modern book, article, gallery text

**Critical:** 20 secondary sources CANNOT override 1 primary source. Frequency ≠ evidence.

---

## Canon Override Protocol

To challenge canon entry, MUST produce ALL of:
1. Primary source (not secondary)
2. Directly contradicts canon (not oblique)
3. Higher weight than canon source

**Cannot override:**
- Logic
- Secondary consensus
- New interpretation
- Plausibility
- Authority

---

## Standard Output Format

```
**Question:** [restate]
**Claims Used:** [CLM-IDs]
**Exact Quotes:** [verbatim]
**Conflicts:** yes/no [CONF-IDs + status]
**Conclusion:** [derived from above]
**Confidence:** HIGH/MEDIUM/LOW/INSUFFICIENT [reason]
**Canon Alignment:** CONSISTENT/EXTENDS/CONFLICTS
**Unresolved:** [what's missing]
**Next Evidence:** [specific sources needed]
```

---

## Accountability Checklist (Before Every Statement)

- [ ] What source supports this?
- [ ] What type (PRIMARY/CONTEMPORARY/SECONDARY)?
- [ ] Any contradicting source?
- [ ] Confidence grade?

If can't answer all 4 → LABEL IT.

---

## Red Flag Phrases (Auto-Review)

- "probably" / "likely" → [INFERENCE] label?
- "it is believed" → by whom? Source?
- "historically" / "traditionally" → cite source
- "experts agree" → which? Primary basis?
- "well known" → cite it then
- "around [year]" → primary source or estimate?

---

## The Core Principle

> **Synthesis is disposable. Claims are not.**

Build claims first. Synthesis flows automatically.

---

**Full Protocol:** C:\scripts\agentidentity\protocols\RESEARCH_INTELLIGENCE_PROTOCOL.md
