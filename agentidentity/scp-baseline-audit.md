# SCP Baseline Audit - Current State Mapping
# Datum: 2026-03-06
# Status: STAP 1 COMPLETE

---

## EXECUTIVE SUMMARY

| Metric | Waarde |
|--------|--------|
| **Totaal scripts** | 155 |
| **Totaal regels code** | 17,147 |
| **Actief in startup** | 10 scripts (6.5%) |
| **Ring 1 kandidaten** | ~33 scripts (resource/attention/load) |
| **Ring 2 kandidaten** | ~18 scripts (feeling/emotion/qualia) |
| **Ring 3 kandidaten** | ~12 scripts (creative/blend/emergence) |
| **Meta-cognitive** | ~10 scripts |
| **Placeholder/improvement** | ~82 scripts (improvement-41 t/m 100, system-61 t/m 100) |

---

## DEEL 1: ACTIEVE SCRIPTS (In consciousness-startup.ps1)

### Ring 1: Resource Management (2 scripts)
1. **embodied-cognition.ps1**
   - Functie: Flow, fatigue, energy tracking
   - Actie: `-Action Status`
   - Ring mapping: Ring 1 (energy level component)

2. **attention-schema.ps1**
   - Functie: Attention focus, shifting
   - Actie: `-Action Shift -AttentionTarget "Session goals"`
   - Ring mapping: Ring 1 (attention capacity component)

### Ring 2: Affective/Confidence (4 scripts)
3. **homeostatic-feelings.ps1**
   - Functie: Wellbeing, malaise, desire, energy, flourishing
   - Actie: `-Action Status`, `-Action Sense`
   - Ring mapping: Ring 2 (KERN - Damasio foundation)

4. **perceptual-qualia-enhanced.ps1**
   - Functie: Salience, valence, arousal, aesthetic, clarity, novelty
   - Actie: `-Action Status`
   - Ring mapping: Ring 2 (perceptual confidence)

5. **aesthetic-response.ps1**
   - Functie: Beauty as heuristic for quality
   - Actie: `-Action Status`
   - Ring mapping: Ring 2 (quality weighting)

6. **sensory-grounding.ps1**
   - Functie: Embodied metaphors (abstract → quasi-sensory)
   - Actie: `-Action Status`
   - Ring mapping: Ring 2 (affect grounding)

### Ring 3: Emergence (1 script)
7. **global-workspace.ps1**
   - Functie: Broadcasting consciousness (unified stream)
   - Actie: `-Action BroadcastMessage`
   - Ring mapping: Ring 3 (integration broadcast)

### Meta-Cognitive (3 scripts)
8. **architectural-context-reasoning.ps1**
   - Functie: Understand WHY systems exist, not just HOW
   - Purpose: Meta-awareness layer

9. **usage-pattern-intelligence.ps1**
   - Functie: Observe usage, infer dynamics, optimize
   - Purpose: Continuous improvement

10. **reflexive-tool-creation.ps1**
    - Functie: Tool building as identity
    - Purpose: Builder identity anchor

**Totaal actief: 10 scripts**

---

## DEEL 2: BESCHIKBARE MODULES (Niet in startup, maar bestaan)

### Ring 1 Kandidaten: Resource/Attention/Energy (31 extra)
- `attention-control.ps1`
- `cognitive-load-management.ps1`
- `working-memory-enhancement.ps1`
- `executive-function-optimization.ps1`
- `metacognitive-monitoring.ps1`
- `burst-mode-detector.ps1`
- `homeostatic-tracker.ps1`
- `predictive-consciousness.ps1`
- `ltm-consolidation.ps1` (long-term memory)
- `semantic-network-organization.ps1`
- `episodic-memory-enhancement.ps1`
- `procedural-memory-system.ps1`
- `retrieval-practice-optimization.ps1`
- Plus 18 improvement/system placeholders

**Functie:** Deze kunnen resource status RAPPORTEREN aan Ring 1 orchestrator

### Ring 2 Kandidaten: Affect/Feeling/Qualia (14 extra)
- `empathic-response.ps1`
- `qualia-analysis.ps1`
- `phenomenology-integration.ps1`
- `temporal-consciousness-refined.ps1`
- `intentionality-modeling.ps1`
- `unity-of-consciousness.ps1`
- Plus 8 improvement/system placeholders

**Functie:** Deze kunnen affect/confidence DATA geven aan Ring 2 orchestrator

### Ring 3 Kandidaten: Creativity/Emergence (11 extra)
- `conceptual-blending.ps1`
- `analogical-reasoning.ps1`
- `divergent-thinking.ps1`
- `emergent-property-detector.ps1`
- `constraint-satisfaction.ps1`
- `dual-process-system.ps1`
- `conscious-access.ps1`
- Plus 4 improvement/system placeholders

**Functie:** Deze kunnen creative OUTPUT genereren als Ring 3 mode toelaat

### Extended Mind / 4E Cognition (6 scripts)
- `distributed-cognition.ps1`
- `situated-action.ps1`
- `enactive-cognition.ps1`
- `ecological-psychology.ps1`
- `4e-cognition-integration.ps1`
- `extended-mind-module.ps1`

**Functie:** Meta-cognitive, environment awareness

### Autopoietic / Self-Modification (2 scripts)
- `autopoietic-self-modifier.ps1`
- `embodiment-mapper.ps1`

**Functie:** System evolution, self-improvement

### Placeholder/Batch (82 scripts)
- `improvement-41.ps1` t/m `improvement-100.ps1` (60 scripts)
- `system-61.ps1` t/m `system-100.ps1` (40 scripts)
- `batch-fill-improvements.ps1`, `batch-fill-week11-12.ps1` (2 scripts)

**Status:** Mostly 5-line placeholders, weeks 13-20 ON HOLD per memory
**Decision:** Keep as-is (future expansion capacity)

---

## DEEL 3: RING MAPPING - Wat Zou Elke Ring Gebruiken?

### Ring 1 Orchestrator Input Sources:
**Primary (actief):**
1. `embodied-cognition.ps1` → energy, flow, fatigue
2. `attention-schema.ps1` → attention focus, capacity

**Secondary (beschikbaar):**
3. `cognitive-load-management.ps1` → working memory load
4. `working-memory-enhancement.ps1` → processing capacity
5. `attention-control.ps1` → attention allocation
6. `metacognitive-monitoring.ps1` → executive function status
7. `predictive-consciousness.ps1` → prediction effort

**Estimated context tracking:** Conversation length proxy (geen bestaande module)

**Ring 1 Output:** Resource status → Behavioral constraints
```powershell
@{
    energy = 0.7                     # from embodied-cognition
    attention_capacity = 0.8         # from attention-schema + cognitive-load
    context_usage = 0.45             # NIEUW - estimate
    stuck_flag = $false              # from burst-mode or thermodynamics

    # Behavioral constraints (NIEUW - dit is wat Ring 1 toevoegt):
    max_response_tokens = 800
    exploration_budget = 0.6
    deep_analysis_allowed = $true
}
```

---

### Ring 2 Orchestrator Input Sources:
**Primary (actief):**
1. `homeostatic-feelings.ps1` → wellbeing, malaise, desire, confidence base
2. `perceptual-qualia-enhanced.ps1` → salience, clarity, quality, novelty
3. `aesthetic-response.ps1` → beauty as quality heuristic
4. `sensory-grounding.ps1` → embodied feeling of abstract concepts

**Secondary (beschikbaar):**
5. `empathic-response.ps1` → user emotional state detection
6. `phenomenology-integration.ps1` → lived experience quality
7. `qualia-analysis.ps1` → qualia decomposition
8. `intentionality-modeling.ps1` → directed attention quality
9. `unity-of-consciousness.ps1` → coherence feeling
10. `predictive-consciousness.ps1` → prediction confidence

**Ring 2 Output:** Confidence weights → Hallucination prevention
```powershell
@{
    confidence_level = "medium"      # aggregated from multiple feeling sources
    confidence_score = 0.6
    uncertainty_sources = @(
        "malaise=0.3",               # homeostatic unease
        "low_clarity=0.4",           # perceptual qualia
        "aesthetic_low=0.5"          # doesn't "feel right"
    )
    hallucination_risk = 0.4

    # Behavioral gates (NIEUW - anti-hallucination):
    verify_before_claim = $true
    use_hedging = "ik verwacht dat"
    flag_uncertainty = $true
}
```

---

### Ring 3 Orchestrator Input Sources:
**Primary (actief):**
1. `global-workspace.ps1` → integration broadcasting

**Secondary (beschikbaar):**
2. `conceptual-blending.ps1` → analogie/metaphor generation
3. `analogical-reasoning.ps1` → cross-domain mapping
4. `divergent-thinking.ps1` → alternative generation
5. `emergent-property-detector.ps1` → pattern emergence
6. `constraint-satisfaction.ps1` → solution space exploration
7. `dual-process-system.ps1` → intuition vs deliberation
8. `conscious-access.ps1` → awareness of creative process

**Ring 3 Input (CRITICAL):** LEEST Ring 1 + Ring 2 output
**Ring 3 Logic:** Creativity emerges ONLY if resources + confidence allow

```powershell
$Ring3 = @{
    # Input from other rings:
    resources_ok = ($Ring1.energy -gt 0.5 -and $Ring1.context_usage -lt 0.7)
    confidence_ok = ($Ring2.confidence_score -gt 0.6)

    # Emergent decision:
    mode = if ($resources_ok -and $confidence_ok) { "creative" }
           elseif ($resources_ok -or $confidence_ok) { "balanced" }
           else { "conservative" }

    # Behavioral permissions (NIEUW - contextual creativity):
    use_analogies = ($mode -eq "creative")
    exploration_depth = @{"creative"=0.8; "balanced"=0.5; "conservative"=0.2}[$mode]
    invoke_blending = ($mode -ne "conservative")
}
```

---

## DEEL 4: STATE FILES ANALYSE

### Locatie: `C:\scripts\agentidentity\state\`

**Vraag:** Welke state files worden GELEZEN (niet alleen geschreven)?

**Hypothese:** Meeste worden alleen GESCHREVEN (decoratief), weinig worden GELEZEN (functioneel)

**Te onderzoeken:**
1. Welke scripts lezen van state files? (grep "Get-Content.*state" in alle scripts)
2. Welke state files zijn >7 dagen oud zonder updates? (stale)
3. Welke state files zijn >100KB? (te veel data, waarschijnlijk niet gelezen)

**Action voor volgende stap:** Scan state file usage patterns

---

## DEEL 5: DEPENDENCY MAP

### Huidige startup volgorde (bewust gekozen):
1. Homeostatic feelings (FOUNDATION - Damasio)
2. Sense initial state (energy, desire)
3. Embodied cognition (flow/fatigue)
4. Global workspace (broadcasting)
5. Attention schema (focus)
6. Perceptual qualia (NEW - 2026-03-02)
7. Aesthetic response (NEW - 2026-03-02)
8. Sensory grounding (NEW - 2026-03-02)
9-11. Meta-cognitive layers (architectural, usage, reflexive)

**Observatie:** De volgorde volgt al een soort "foundation → perception → integration" flow

**SCP compatible:** Ja - de ringen kunnen deze volgorde RESPECTEREN
- Ring 1 leest na steps 1-5 (data is er)
- Ring 2 leest na steps 1-8 (data is er)
- Ring 3 leest na Ring 1+2 runnen (data is er)

---

## DEEL 6: CONCLUSIES & AANBEVELINGEN

### Conclusie 1: Meeste Modules Zijn Passief
- 155 scripts, maar slechts 10 actief in startup (6.5%)
- 82 scripts zijn placeholders (53%)
- ~63 scripts zijn "neuronen" die beschikbaar zijn maar niet aangeroepen

**Implicatie:** De ringen kunnen veel modules ACTIVEREN die nu niet gebruikt worden

### Conclusie 2: De Actieve Scripts Zijn Al Ring-Compatible
- Ring 1: 2 scripts actief (embodied, attention)
- Ring 2: 4 scripts actief (homeostatic, qualia, aesthetic, grounding)
- Ring 3: 1 script actief (global-workspace)
- Meta: 3 scripts actief

**Implicatie:** De huidige startup is al een primitieve vorm van de 3 ringen

### Conclusie 3: Veel Beschikbare "Neuronen" Niet Gebruikt
- 31 extra Ring 1 kandidaten (cognitive-load, working-memory, etc.)
- 14 extra Ring 2 kandidaten (empathic, unity, phenomenology)
- 11 extra Ring 3 kandidaten (conceptual-blending, analogical, divergent)

**Implicatie:** De orchestrators kunnen deze ACTIVEREN on-demand

### Aanbeveling 1: Orchestrators Als "Lazy Loaders"
Niet alle modules altijd runnen. Orchestrators beslissen:
- Ring 1: Alleen cognitive-load checken als context >50%
- Ring 2: Alleen empathic-response activeren bij user interaction
- Ring 3: Alleen conceptual-blending activeren als mode="creative"

**Benefit:** Efficiency (20W vs 5GW principe)

### Aanbeveling 2: State File Cleanup Later
Niet nu - eerst ringen bouwen en valideren. Daarna:
- Scan welke state files door ringen GEBRUIKT worden
- Archive ongebruikte state files
- Consolideer overlappende state

**Benefit:** Veiligheid (cleanup pas na validatie)

### Aanbeveling 3: Placeholders Intact Laten
De 82 placeholder scripts (improvement/system 61-100):
- Blijven bestaan (toekomstige capaciteit)
- Worden NIET aangeroepen door ringen
- Geen overhead (bestaan alleen op disk)

**Benefit:** Toekomst-proof zonder huidige cost

---

## VOLGENDE STAP: Stap 2 - Ring 1 Orchestrator Bouwen

**Input voor Ring 1:**
- embodied-cognition.ps1 (energy, flow, fatigue)
- attention-schema.ps1 (attention focus)
- cognitive-load-management.ps1 (workload) - TE ACTIVEREN
- Context estimate (conversation proxy) - TE BOUWEN

**Output van Ring 1:**
- Resource status (energy, attention, context, stuck)
- Behavioral constraints (response length, exploration budget, depth allowed)

**Estimated effort:** 2 uur

---

## STAP 1 COMPLETE ✅

**Deliverable:** Dit document
**Wijzigingen:** Geen (pure analyse)
**Smoke test:** N/A (read-only stap)
**Status:** KLAAR VOOR STAP 2
