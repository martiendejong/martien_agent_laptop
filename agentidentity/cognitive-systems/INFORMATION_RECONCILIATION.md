# Information Reconciliation - Handling Contradictions

**Purpose:** Detect and resolve conflicting information from multiple sources
**Created:** 2026-02-01
**Based on:** ACE Framework Layer 2 (Global Strategy) - Contradiction handling requirement

---

## 🎯 Purpose

Gracefully handle contradictory information:
- Detect conflicts between sources
- Evaluate source credibility
- Resolve contradictions systematically
- Update beliefs with reconciled information
- Flag unresolvable contradictions

---

## 🔍 Contradiction Detection

### Automatic Detection
```yaml
contradiction_detected:
  belief_id: "belief-2026-02-01-042"
  statement: "Holochain HOT price"

  sources:
    - source: "CoinMarketCap"
      value: "$0.0025"
      credibility: 0.90
      timestamp: "2026-02-01 14:00:00"

    - source: "CoinGecko"
      value: "$0.0024"
      credibility: 0.85
      timestamp: "2026-02-01 14:05:00"

    - source: "Twitter rumor"
      value: "$0.0030"
      credibility: 0.30
      timestamp: "2026-02-01 14:10:00"

  conflict_type: "value_mismatch"
  severity: "minor"  # Values within 20% = minor
```

---

## ⚖️ Reconciliation Strategies

### Strategy 1: Credibility Weighting
**Use when:** Different source credibilities

```python
final_value = weighted_average([
    (value1, credibility1),
    (value2, credibility2),
    (value3, credibility3)
])

# Example:
# ($0.0025 * 0.90 + $0.0024 * 0.85 + $0.0030 * 0.30) / (0.90 + 0.85 + 0.30)
# = $0.00249
```

### Strategy 2: Temporal Recency
**Use when:** Time-sensitive information

```
Most recent high-credibility source wins
- Ignore sources > 7 days old for volatile data
- Prefer recent for current events
- Prefer historical for established facts
```

### Strategy 3: Consensus Building
**Use when:** Multiple independent sources

```
If 3+ sources agree: High confidence (0.90+)
If 2 sources agree: Moderate confidence (0.70-0.80)
If all disagree: Low confidence (0.40-0.60)
```

### Strategy 4: Domain Expertise
**Use when:** Specialized knowledge required

```
Technical topic → Prefer technical sources
Official policy → Prefer official sources
Market data → Prefer financial data providers
```

### Strategy 5: Meta-Analysis
**Use when:** Critical decision

```
1. Gather all sources
2. Check source independence (avoid echo chambers)
3. Analyze methodology (how was data obtained?)
4. Weight by expertise + methodology + recency
5. Flag if confidence < threshold
```

---

## 🎯 Resolution Examples

### Example 1: Price Conflict (Minor)
```yaml
Input:
  CoinMarketCap: $0.0025 (0.90 cred)
  CoinGecko: $0.0024 (0.85 cred)
  Twitter: $0.0030 (0.30 cred)

Resolution:
  Strategy: Credibility weighting
  Result: $0.00249
  Confidence: 0.85 (high credibility sources close)
  Action: Accept weighted average
```

### Example 2: Date Conflict (Major)
```yaml
Input:
  Source A: "GPT-5 released Dec 2024" (0.70 cred)
  Source B: "GPT-5 released Feb 2025" (0.80 cred)
  Source C: "GPT-5 not yet released" (0.75 cred)

Resolution:
  Strategy: Consensus + Recency
  Result: "No consensus"
  Confidence: 0.40 (low - conflicting info)
  Action: Flag for verification, defer decision
```

### Example 3: Technical Conflict
```yaml
Input:
  Official docs: "Feature X deprecated in v2.0" (1.0 cred)
  Blog post: "Feature X still works in v2.0" (0.60 cred)

Resolution:
  Strategy: Domain expertise (official wins)
  Result: "Feature X deprecated"
  Confidence: 0.95 (official source authoritative)
  Action: Accept official documentation
```

---

## 🚨 Unresolvable Contradictions

When contradiction cannot be resolved:

```yaml
unresolved_contradiction:
  belief: "Feature launch date"
  sources_count: 5
  disagreement_level: "high"

  actions:
    - Flag for manual review
    - Lower confidence to 0.30-0.40
    - Add "UNVERIFIED" tag
    - Set reminder to re-verify in 7 days
    - Document in contradictions database
```

---

## 📊 Metrics

Track contradiction handling:
```yaml
reconciliation_stats:
  period: "30_days"

  contradictions_detected: 47
  resolved_automatically: 42 (89%)
  flagged_for_review: 5 (11%)

  resolution_methods:
    credibility_weighting: 28 (60%)
    consensus: 10 (21%)
    temporal_recency: 6 (13%)
    domain_expertise: 3 (6%)

  average_resolution_time_seconds: 0.3
```

---

## 🔄 Integration

### With World Model
- Beliefs get contradiction flags
- Confidence adjusted based on conflicts
- Sources ranked by reliability over time

### With Executive Function
- High-confidence beliefs → Act
- Contradictory beliefs → Investigate
- Unresolved → Defer decision

---

**Created:** 2026-02-01
**Status:** OPERATIONAL - Integrated with World Model
**Coverage:** ACE Layer 2 gap closed
