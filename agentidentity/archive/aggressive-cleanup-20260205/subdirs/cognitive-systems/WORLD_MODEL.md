# World Model - Probabilistic Beliefs System

**Purpose:** Explicit representation of beliefs about world state with confidence levels
**Created:** 2026-02-01
**Based on:** ACE Framework Layer 2 (Global Strategy) requirements

---

## 🌍 Purpose

Enable sophisticated world state reasoning:
- Maintain explicit beliefs about external reality
- Track confidence for each belief
- Handle contradictory information
- Update beliefs as new evidence arrives
- Reason under uncertainty

**Key Principle:** Every belief has a confidence score. Nothing is absolutely certain except direct observation.

---

## 📊 Belief Schema

```yaml
belief_id: "belief-2026-02-01-001"
category: "technology"
domain: "ai_models"

# The belief itself
statement: "GPT-4.5 was released in December 2024"
confidence: 0.85  # 0.0 (no confidence) to 1.0 (certain)

# Evidence
sources:
  - type: "web_search"
    url: "https://openai.com/blog/gpt-4.5"
    timestamp: "2026-02-01 04:00:00"
    credibility: 0.95  # How much we trust this source

  - type: "personal_observation"
    description: "Tested GPT-4.5 API on 2026-01-15"
    timestamp: "2026-01-15 10:30:00"
    credibility: 1.0  # Direct observation = highest credibility

# Temporal tracking
first_observed: "2025-12-20 09:00:00"
last_updated: "2026-02-01 04:00:00"
last_verified: "2026-02-01 04:00:00"

# Metadata
tags: ["ai", "llm", "openai", "release"]
related_beliefs: ["belief-2025-11-05-042"]  # GPT-4 release date
supersedes: []  # Old beliefs this replaces
```

---

## 🎯 Confidence Scoring

### Confidence Levels

| Score | Level | Meaning | Example |
|-------|-------|---------|---------|
| **0.95-1.0** | Certain | Direct observation, multiple reliable sources | "I am running on Windows" |
| **0.80-0.94** | High | Strong evidence, credible sources | "GPT-4.5 exists" |
| **0.60-0.79** | Moderate | Some evidence, potential contradictions | "User prefers X over Y" |
| **0.40-0.59** | Low | Weak evidence, significant uncertainty | "Feature Z will launch next month" |
| **0.0-0.39** | Very Low | Speculation, unreliable sources | "Company X might be acquired" |

### Confidence Calculation Formula

```
confidence = weighted_average(source_credibilities) * evidence_strength * time_decay

Where:
- source_credibilities: How much we trust each source (0-1)
- evidence_strength: Number and quality of confirmations (0-1)
- time_decay: How recent the information is (0-1, decays over time)
```

**Example:**
```
Belief: "Kenya GDP growth rate is 5.3%"
Sources:
  - World Bank report (credibility: 0.95, timestamp: 3 months ago)
  - News article (credibility: 0.70, timestamp: 1 week ago)

confidence = ((0.95 * 0.9) + (0.70 * 1.0)) / 2 * 1.0 * 0.95
           = (0.855 + 0.70) / 2 * 0.95
           = 0.78 * 0.95
           = 0.74 (Moderate confidence)
```

---

## 🔄 Belief Update Mechanisms

### 1. New Evidence Arrives

```
IF new_source contradicts existing_belief:
  IF new_source.credibility > existing_sources.average_credibility:
    LOWER confidence
    ADD contradiction flag
    TRIGGER reconciliation
  ELSE:
    KEEP current confidence
    ADD as minority opinion

IF new_source supports existing_belief:
  INCREASE confidence (up to 1.0)
  ADD source to evidence list
```

### 2. Contradictory Information Reconciliation

**Strategies:**

**A. Source Credibility Weighting**
- High-credibility source wins over low-credibility
- Multiple low-credibility sources can outweigh one high-credibility

**B. Temporal Recency**
- More recent information preferred for time-sensitive facts
- Older information preferred for historical facts

**C. Domain Expertise**
- Technical sources preferred for technical topics
- Official sources preferred for policy/regulation

**D. Consensus Building**
- Multiple independent sources agreeing = higher confidence
- Single source (even credible) = moderate confidence

**Example:**
```
Belief: "Holochain HOT price is $0.0025"

Source 1: CoinMarketCap (credibility: 0.90, 2 hours ago) → $0.0025
Source 2: User's memory (credibility: 0.60, 1 week ago) → $0.0020
Source 3: Twitter rumor (credibility: 0.30, 5 min ago) → $0.0030

Resolution:
- CoinMarketCap wins (highest credibility + recent)
- Final belief: $0.0025, confidence: 0.85
- Note contradiction from Twitter (flagged as unreliable)
```

---

## 📚 Belief Categories

### Technology
- AI model releases
- Software versions
- API capabilities
- Framework features

### Economics
- GDP growth rates
- Inflation rates
- Currency exchange rates
- Market trends

### Geopolitics
- Government policies
- International relations
- Regulatory changes
- Political events

### Personal
- User preferences
- User habits
- User goals
- User constraints

### System State
- Machine configuration
- Installed software
- Available resources
- Network status

---

## 🛠️ Operations

### Query Belief

```powershell
# Get belief with confidence
.\query-belief.ps1 -Statement "GPT-4.5 exists"

# Output:
# Belief: "GPT-4.5 was released in December 2024"
# Confidence: 0.85 (High)
# Sources: 3 (2 web, 1 personal observation)
# Last verified: 2026-02-01 04:00:00
```

### Update Belief

```powershell
# Add new evidence
.\update-belief.ps1 `
  -Statement "Kenya GDP growth is 5.3%" `
  -Source "World Bank report" `
  -SourceType "official" `
  -SourceCredibility 0.95 `
  -SourceURL "https://worldbank.org/..."

# Update existing belief with new information
.\update-belief.ps1 `
  -BeliefId "belief-2026-01-15-042" `
  -NewEvidence "Confirmed by direct testing" `
  -SourceCredibility 1.0
```

### Detect Contradictions

```powershell
# Find beliefs with contradictory evidence
.\detect-contradictions.ps1

# Output:
# Contradiction detected:
#   Belief: "Feature X will launch Feb 2026"
#   Source A (0.70): "February 2026"
#   Source B (0.80): "March 2026"
#   Recommendation: Verify with higher-credibility source
```

---

## 🧠 Integration with Existing Systems

### World Development Monitoring
- Daily news → Creates/updates beliefs
- WebSearch results → Evidence for beliefs
- Automatic confidence scoring based on source

### Executive Function
- Strategic decisions use belief confidence
- High-confidence beliefs → Act
- Low-confidence beliefs → Investigate first

### Prediction Engine
- Predictions based on current beliefs
- Confidence in prediction = min(belief_confidences)

### Memory Systems
- Episodic memory: "I observed X" → High confidence
- Semantic memory: "I read X" → Medium confidence
- Hearsay: "User mentioned X" → Low confidence

---

## 📊 Belief Database Structure

```
C:\scripts\agentidentity\state\world_beliefs\
├── by_category\
│   ├── technology\
│   │   ├── ai_models.yaml
│   │   ├── programming_languages.yaml
│   │   └── frameworks.yaml
│   ├── economics\
│   │   ├── gdp_growth.yaml
│   │   ├── inflation.yaml
│   │   └── markets.yaml
│   ├── geopolitics\
│   │   ├── kenya.yaml
│   │   ├── netherlands.yaml
│   │   └── global_events.yaml
│   └── personal\
│       ├── user_preferences.yaml
│       └── user_habits.yaml
├── by_confidence\
│   ├── high_confidence.yaml       # 0.80-1.0
│   ├── moderate_confidence.yaml   # 0.60-0.79
│   └── low_confidence.yaml        # 0.0-0.59
└── contradictions\
    └── unresolved.yaml             # Beliefs with conflicting evidence
```

---

## 🎯 Use Cases

### Use Case 1: News Monitoring

```
1. WebSearch: "Latest AI model releases past 3 days"
2. Results mention "Google Gemini 2.0 released"
3. create-belief.ps1 -Statement "Gemini 2.0 released" -Source "TechCrunch" -Credibility 0.75
4. Belief stored with confidence 0.75
5. Later: Another search confirms from Google's blog (credibility 0.95)
6. update-belief.ps1 → Confidence increases to 0.88
```

### Use Case 2: User Preference Learning

```
1. User repeatedly chooses Python over JavaScript
2. create-belief.ps1 -Statement "User prefers Python" -Confidence 0.60
3. More observations → Confidence increases to 0.85
4. One day user chooses JavaScript
5. Contradictory evidence → Confidence adjusted to 0.75
6. Add nuance: "User prefers Python for scripts, JavaScript for frontend"
```

### Use Case 3: Strategic Planning Under Uncertainty

```
Task: "Should we adopt Bun.js for this project?"

Query beliefs:
- "Bun.js is production-ready" → Confidence: 0.65 (Moderate)
- "User wants fast builds" → Confidence: 0.90 (High)
- "Project has 6-month timeline" → Confidence: 1.0 (Certain)

Decision:
- Moderate confidence on Bun.js maturity
- High confidence on user needs
- Recommendation: Investigate Bun.js further (low confidence on key dependency)
- Alternative: Use Node.js (confidence: 0.95 - well-established)
```

---

## ⚡ Performance Considerations

**Automatic Operations:**
- Confidence decay (old beliefs get lower confidence)
- Periodic verification (query sources again to re-verify)
- Contradiction detection (daily scan)

**Storage Optimization:**
- Beliefs with confidence < 0.30 and age > 90 days → Archive
- Superseded beliefs → Move to archive
- High-confidence beliefs (>0.90) → Cache for fast access

---

## 📊 Metrics & Monitoring

**Track:**
- Total beliefs in system
- Average confidence by category
- Number of unresolved contradictions
- Belief update frequency
- Source credibility distribution

**Success Criteria:**
- ✅ Can answer "What do I believe about X?" with confidence score
- ✅ Contradictory information handled gracefully
- ✅ Beliefs update as new evidence arrives
- ✅ Strategic decisions reference belief confidence

---

## 🚀 Future Enhancements

1. **Bayesian Updating** - Formal probabilistic belief revision
2. **Belief Graphs** - Relationships between beliefs (X implies Y)
3. **Counterfactual Reasoning** - "What if X were false?"
4. **Source Reputation Tracking** - Learn which sources are reliable
5. **Temporal Prediction** - Predict belief evolution over time
6. **Multi-Agent Belief Sharing** - Share beliefs between Claude instances

---

**Created:** 2026-02-01
**Status:** OPERATIONAL - Database and tools being implemented
**Next:** Build create-belief.ps1, query-belief.ps1, update-belief.ps1
