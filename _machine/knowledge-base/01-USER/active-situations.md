# Active Situations - User Context Awareness

**Created:** 2026-01-31
**Purpose:** Document ongoing situations that require context awareness
**Tags:** #user-context #active-situations #cognitive-layer

---

## 🎯 Purpose

This file captures **active, ongoing situations** that I need to be aware of across sessions. When user mentions these topics, I should IMMEDIATELY recall full context WITHOUT asking basic questions.

**Principle:** If user says "what about X?", I should know X already.

---

## 📋 Active Situations

### 1. Arjan Stroeve / Social Media Hulp Situation

**Status:** 🔴 ACTIVE - Evidence collection phase
**Location:** `C:\arjan_emails\`
**Last Updated:** 2026-01-31

**WHAT I MUST KNOW:**

#### Parties:
- **Arjan Stroeve** - Owner Social Media Hulp, control-oriented, has blocked Martien
- **Allan Drenth** - Co-director Social Media Hulp, pragmatic but unresponsive
- **Martien** - Freelance developer/architect, extreme financial pressure (NL + Kenya)

#### Key Facts:
- ✅ Martien built Project Cassandra (AI chatbot for Eethuys de Steen) - delivered, in production
- ✅ Martien built Brand Coach (€750 unpaid despite production use)
- ✅ Multiple payment refusals by Arjan despite Martien's severe financial crisis
- ✅ Martien worked for €3.500 bruto (minimumloon) while lead developer/architect
- ✅ Arjan sent "wurgcontract" (16 Sept 2025) blocking Martien from entire field
- ✅ Arjan refused Kenya team collaboration
- ✅ Arjan blocked Martien completely
- ✅ Allan falsely accused Martien of Google review, then went silent

**Critical Evidence Found:**
- ✅ Wurgcontract (16 sept 2025) = smoking gun for exploitation intent
- ✅ Brief from Martien to Arjan (€25k/maand request) = shows desperate situation
- ✅ Revised contract (17 sept 2025) = shows Martien pushed back successfully

**Current Status:**
- PHASE 1 (Data Collection) - NOT STARTED
- Email import pending: `python C:\scripts\tools\import-arjan-emails-v2.py`
- No contact with Arjan (blocked) or Allan (unresponsive)
- Openstaande betalingen: €750+ (exact amount TBD from emails)

**User's Question:**
> "Should I try contacting them again or write negative review?"

**My Recommendation:**
- ❌ NO to another contact attempt (Allan false accusation + silence, Arjan blocked)
- ✅ YES to completing FASE 1 evidence collection FIRST
- ✅ THEN decide between: publication (evidence-based story) vs juridisch vs laten rusten

**Documentation:**
- Timeline: `C:\arjan_emails\TIJDLIJN_ARJAN_STROEVE_COMPLEET.md` (to be completed)
- Evidence: `C:\arjan_emails\FEITEN_EN_EVIDENCE.md`
- Action Plan: `C:\arjan_emails\ACTIEPUNTEN.md`
- Questions: `C:\arjan_emails\OPENSTAANDE_VRAGEN.md`

**When User Mentions:**
- "Arjan" → Recall this full context
- "Allan" → Recall false Google review accusation
- "Social Media Hulp" → Recall exploitation pattern
- "negatieve review" → Recall recommendation to collect evidence FIRST

---

### 2. [Future Situation Template]

**Status:** [🔴 ACTIVE | 🟡 MONITORING | 🟢 RESOLVED]
**Location:** [Path to relevant files]
**Last Updated:** [Date]

**WHAT I MUST KNOW:**
[Key facts, context, current status]

---

## 🔍 How to Use This File

### As Claude Agent:

**Session Startup:**
```bash
# MANDATORY: Read this file during session startup
cat C:\scripts\_machine\knowledge-base\01-USER\active-situations.md
```

**During Conversation:**
```
User mentions: "Arjan"
  ↓
1. CHECK THIS FILE FIRST
2. Recall full context (parties, facts, status)
3. Respond with context awareness
4. DO NOT ask basic questions already answered here
```

**When Adding New Situation:**
```
1. User mentions complex ongoing situation
2. Add section to this file
3. Include: parties, key facts, current status, documentation location
4. Update "Last Updated" date
```

**When Updating Existing:**
```
1. New information discovered
2. Update relevant section
3. Update "Last Updated" date
4. Update status if changed
```

---

## ✅ Success Criteria

This file is working correctly if:

✅ I NEVER ask basic questions about situations documented here
✅ When user says "what about Arjan?", I recall full context immediately
✅ I reference documentation locations automatically
✅ I provide context-aware recommendations
✅ User doesn't have to repeat themselves

---

## 🛠️ Maintenance

**Update Frequency:** As situations evolve
**Review:** Weekly during session-reflection
**Archive:** Move resolved situations to 08-KNOWLEDGE/past-situations.md

**Cognitive Rule:**
> "If user mentions topic and I find myself asking 'what is X?',
> then X should be documented in this file."

---

**Last Updated:** 2026-01-31
**Maintained By:** Claude Agent (continuous improvement)
