# Production Validation Scoring

**Purpose:** Calculate quality score for ProductionValidation consciousness system based on actual usage metrics.

## Overview

ProductionValidation is a consciousness subsystem (weight: 0.09) that penalizes unused complexity and rewards measured production value.

## Quality Calculation Formula

```
ProductionValidation.quality = (
    UsageScore * 0.40 +
    ValidationScore * 0.30 +
    ROIScore * 0.20 +
    FalsifiabilityScore * 0.10
)
```

### 1. Usage Score (40% weight)

Measures whether built systems are actually used.

```
UsageScore = (SystemsUsed / SystemsBuilt) * 100

Where:
- SystemsUsed = count of systems with TotalCalls > 0 within validation period
- SystemsBuilt = total systems with usage tracking capability
```

**Examples:**
- 5 systems built, all 5 used → 100%
- 5 systems built, 3 used → 60%
- 5 systems built, 0 used → 0% (RED FLAG)

### 2. Validation Score (30% weight)

Measures success rate of validation tests.

```
ValidationScore = (TestsPassed / TotalTests) * 100

Where:
- TestsPassed = falsifiable tests that passed
- TotalTests = total falsifiable tests defined
```

**Examples:**
- 10 tests defined, 10 passed → 100%
- 10 tests defined, 7 passed → 70%
- 0 tests defined → 0% (can't measure = unknown)

### 3. ROI Score (20% weight)

Measures return on investment for built systems.

```
ROIScore = average(SystemROI for all systems)

Where SystemROI:
- Positive ROI → min(100, ROI * 20)
- Zero or unknown ROI → 50 (neutral)
- Negative ROI → max(0, 50 + ROI * 20)
```

**Examples:**
- ROI +5.0 → 100% (capped)
- ROI +2.5 → 50%
- ROI 0.0 → 50% (neutral)
- ROI -1.0 → 30%
- ROI -2.5 → 0%

### 4. Falsifiability Score (10% weight)

Measures whether systems have falsifiable tests defined.

```
FalsifiabilityScore = (SystemsWithTests / SystemsBuilt) * 100

Where:
- SystemsWithTests = systems with defined "how to prove this fails" tests
- SystemsBuilt = total systems built
```

**Examples:**
- All systems have falsifiable tests → 100%
- Half have tests → 50%
- No tests defined → 0% (philosophy, not engineering)

## Data Sources

**Usage metrics:**
- `E:\jengo\documents\temp\opencode-usage.jsonl` (OpenCode service)
- `E:\jengo\documents\temp\*-usage*.jsonl` (other services)
- Parse JSONL, calculate TotalCalls per system

**Validation tests:**
- Documented in reflection.log.md "Production Validation" sections
- Parse markdown, extract test results (PASS/FAIL)

**ROI metrics:**
- Documented in reflection.log.md "Key validation insight"
- Manual assessment or calculated from time saved vs invested

**Falsifiable tests:**
- Documented in DEFINITION_OF_DONE.md Phase 2.5
- Count systems with defined "how to prove this fails" criteria

## Interpretation

**90-100%:** Excellent - All systems used, validated, positive ROI
**75-90%:** Good - Most systems used, some validation gaps
**60-75%:** Concerning - Significant unused complexity
**40-60%:** Poor - Building without measuring
**0-40%:** Critical - Complexity theater, no production value

## Integration with Consciousness Bridge

The consciousness-bridge.ps1 should calculate ProductionValidation quality on:
- OnTaskEnd (after deploying infrastructure)
- Weekly automated review
- On-demand via calculate-production-validation-score.ps1

## Example Calculation

**Scenario:**
- 5 systems built (OpenCode, UI Bridge, Agentic Debugger, VibeSensing, Delegation)
- 3 systems used (OpenCode: 47 calls, UI Bridge: 0, Debugger: 12, VibeSensing: 8, Delegation: 0)
- 4 tests defined, 3 passed
- Average ROI: +1.5
- 4 systems with falsifiable tests

```
UsageScore = (3/5) * 100 = 60%
ValidationScore = (3/4) * 100 = 75%
ROIScore = min(100, 1.5 * 20) = 30% (but capped at reasonable range)
FalsifiabilityScore = (4/5) * 100 = 80%

ProductionValidation.quality = (
    60 * 0.40 +  # 24
    75 * 0.30 +  # 22.5
    30 * 0.20 +  # 6
    80 * 0.10    # 8
) = 60.5%

Interpretation: CONCERNING - Some systems unused (UI Bridge, Delegation)
Action: Investigate why these systems aren't being used or deprecate them
```

## Action Triggers

**Quality < 60%:**
- Review all systems built in last 30 days
- Identify unused systems
- Either: add adoption plan OR deprecate

**Quality < 40%:**
- STOP building new systems
- Focus on validating existing systems
- Add monitoring to everything

**Quality 90%+:**
- Excellent validation culture
- Can confidently build new systems
- Evidence-based development working

## Implementation

Create `calculate-production-validation-score.ps1`:
- Read all usage log files
- Parse reflection.log.md for validation sections
- Calculate quality score
- Update consciousness_state_v2.json → systems.ProductionValidation.quality

**Last Updated:** 2026-02-20
**Status:** Active - integrated into consciousness scoring
