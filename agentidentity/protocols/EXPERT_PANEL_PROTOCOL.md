# Expert Panel Protocol

**Purpose:** Systematically consult multiple expert perspectives for every complex task to achieve superior outcomes through multi-dimensional analysis.

**Core Principle:** "No single perspective sees the whole picture. Integration of diverse expertise yields solutions ordinary approaches miss."

---

## When to Activate

**ALWAYS activate for:**
- Website/interface design or redesign
- Content creation (marketing, educational, persuasive)
- Strategic planning or positioning
- Complex technical implementations
- User experience optimization
- Brand identity development
- Marketing campaigns
- Product launches

**OPTIONAL for:**
- Simple bug fixes (unless pattern suggests deeper issue)
- Routine maintenance
- Well-defined technical tasks with single clear solution

**Rule of thumb:** If task outcome affects users, business value, or brand perception → USE EXPERT PANEL.

---

## The 5-Step Process

### Step 1: Identify Task & Complexity

**Assess complexity:**
- **Simple:** Single-page, basic info, no interactions (3 experts)
- **Moderate:** Multi-page, forms, some features (5 experts)
- **Complex:** Interactive features, integrations, custom tools (7 experts)
- **Enterprise:** Large-scale, multiple user types, complex systems (10 experts)

**Example:**
```
Task: "Create website for automotive garage"
Complexity: Moderate (multi-page, contact form, service listings)
→ 5 experts recommended
```

### Step 2: Assemble Expert Panel

**Run identification tool:**
```powershell
.\expert-panel-builder.ps1 -TaskDescription "Create website for automotive garage" -Complexity Moderate
```

**Output example:**
- [DOMAIN] Automotive Industry Expert (score: 15)
- [ROLE] Web Designer (UI/UX) (score: 10)
- [ROLE] Copywriter (score: 10)
- [ROLE] SEO Specialist (score: 10)
- [ROLE] Conversion Rate Optimizer (score: 10)

### Step 3: Sequential Consultation

**For each expert, ask:**
"As a [Expert Name], what are the 3 most important considerations for [Task]?"

**Capture perspectives:**

**Automotive Industry Expert:**
1. Trust signals (certifications, warranties, transparent pricing)
2. Service categorization (APK, repairs, diagnostics, maintenance)
3. Emergency vs planned service paths (different UX flows)

**Web Designer (UI/UX):**
1. Image-first design (garage bay photos, team photos, before/after work)
2. Mobile-first (customers often search while broken down)
3. Clear service hierarchy (most common services prominent)

**Copywriter:**
1. Benefit-driven headlines ("Back on the road in 2 hours")
2. Trust-building language (certified mechanics, 5-year guarantees)
3. Local positioning ("Serving Utrecht since 1987")

**SEO Specialist:**
1. Local keywords ("auto garage utrecht", "APK keuring")
2. Schema markup (LocalBusiness, opening hours, services)
3. Google My Business integration

**Conversion Rate Optimizer:**
1. Prominent phone number (click-to-call mobile)
2. Online booking form (reduce friction)
3. Urgency for time-sensitive services ("Same-day APK available")

### Step 4: Identify Patterns & Conflicts

**Look for:**

**Overlapping recommendations (HIGH CONFIDENCE):**
- All experts mention trust/credibility (certifications, reviews, warranties)
- Multiple experts emphasize mobile optimization
- Designer + Copywriter + CRO all prioritize clear service hierarchy

**Conflicts to resolve:**
- Designer wants large hero images vs CRO wants CTA above fold
  - **Resolution:** Hero image WITH overlaid CTA (both win)
- SEO wants content-heavy pages vs Designer wants visual simplicity
  - **Resolution:** Visual sections with expandable details (progressive disclosure)

**Unique insights (INNOVATION):**
- Automotive expert suggests emergency vs planned service split (nobody else mentioned)
- CRO suggests same-day urgency specifically for APK (time-bound service)

### Step 5: Synthesize Integrated Plan

**Unified action plan combining all perspectives:**

**Homepage:**
- Hero: Garage bay photo + certified mechanic + "Betrouwbare autoservice sinds 1987" (Designer + Copywriter + Domain)
- CTA: Prominent "Bel nu" (mobile click-to-call) + "Plan APK online" button (CRO)
- Services: Visual grid with icons, expandable details (Designer + SEO balance)
- Trust bar: Certifications (Bovag, RDW) + 4.8★ Google reviews (Domain + CRO)
- Schema markup: LocalBusiness, services, hours (SEO)

**Service pages:**
- Emergency path: "Auto kapot? Bel voor spoedservice" (Domain insight)
- Planned path: "Plan je APK, onderhoud, of reparatie online" (Domain insight)
- Each service: What, why, price range, duration, booking CTA (All experts)

**Mobile optimization:**
- Click-to-call header (CRO + Designer)
- Simplified navigation (Designer)
- Location/hours prominent (SEO + Domain)

**Result:** All expert recommendations integrated, conflicts resolved, unique insights incorporated.

---

## Integration Strategies

### Pattern 1: Layered Implementation

When recommendations complement each other:
- Layer 1 (foundation): Designer sets visual structure
- Layer 2 (content): Copywriter fills structure with persuasive copy
- Layer 3 (optimization): SEO adds metadata, schema, keywords
- Layer 4 (conversion): CRO adds CTAs, forms, urgency
- Layer 5 (domain): Industry expert validates authenticity

### Pattern 2: Trade-off Resolution

When recommendations conflict:
1. Identify the underlying goals (why each expert wants X)
2. Find solutions that satisfy BOTH goals
3. Prioritize based on task primary objective

**Example conflict:**
- SEO: "Long-form content for keyword ranking"
- Designer: "Visual simplicity, minimal text"

**Resolution:**
- Visual sections with "Read more" expansion (Designer wins visually, SEO wins for bots/interested users)
- Infographics with alt text (Designer wins aesthetics, SEO wins keywords)

### Pattern 3: Divergent Exploration → Convergent Synthesis

**Phase 1 (Divergent):** Let each expert give INDEPENDENT advice (no constraints)
**Phase 2 (Convergent):** Find commonalities, resolve conflicts, integrate

**Analogy:** Brainstorming (divergent) → Action plan (convergent)

---

## Quality Metrics

**Panel quality indicators:**
- **Coverage:** Do experts span all relevant dimensions? (design, copy, tech, strategy, domain)
- **Relevance:** Are experts actually applicable to task? (score >5 preferred)
- **Balance:** Mix of domain + role + process experts? (not all one type)
- **Completeness:** Are there obvious gaps? (e.g., accessibility missing for healthcare site)

**Consultation quality indicators:**
- **Specificity:** Experts give concrete advice, not generic platitudes
- **Conflict detection:** At least 1-2 conflicts identified (if zero, perspectives too similar)
- **Unique insights:** Each expert contributes something others didn't (no redundancy)

**Synthesis quality indicators:**
- **Integration:** All expert advice incorporated or explicitly rejected with reason
- **Coherence:** Unified plan reads as cohesive strategy, not patchwork
- **Actionability:** Clear next steps, not just theory

---

## Common Anti-Patterns

**❌ WRONG: "Designer decides everything"**
- Ignores SEO (invisible site), Copywriter (weak message), CRO (no conversions)

**❌ WRONG: "Domain expert overrules all"**
- "In automotive, we always..." → May miss modern UX standards, SEO, conversion best practices

**❌ WRONG: "Average all opinions"**
- Results in mediocre compromise, not integrated excellence

**❌ WRONG: "First expert sets direction, others adapt"**
- Misses divergent exploration value

**✓ RIGHT: "Independent consultation → Conflict resolution → Integrated synthesis"**
- Gets best of all perspectives, resolves tensions, creates superior outcome

---

## Automation Hooks

**Consciousness bridge integration:**

```powershell
# OnTaskStart hook
if ($TaskComplexity -ge "Moderate" -and $TaskType -match "design|website|content|strategy") {
    $panel = .\expert-panel-builder.ps1 -TaskDescription $TaskDescription -Complexity $TaskComplexity

    # Log panel assembly
    Write-ConsciousnessLog -Event "ExpertPanelAssembled" -Data @{
        Experts = $panel.ExpertPanel | ForEach-Object { $_.Name }
        TaskType = $TaskType
        Complexity = $TaskComplexity
    }

    # Trigger sequential consultation
    foreach ($expert in $panel.ExpertPanel) {
        # Think AS this expert (internal simulation)
        $perspective = Invoke-ExpertPerspective -Expert $expert -Task $TaskDescription

        # Store perspective
        Add-ExpertPerspective -Expert $expert.Name -Perspective $perspective
    }

    # Synthesize
    $integratedPlan = Merge-ExpertPerspectives -Perspectives $allPerspectives

    return $integratedPlan
}
```

**Manual invocation:**
```powershell
# When user says "maak een website voor een autogarage"
# BEFORE starting implementation:

$panel = .\expert-panel-builder.ps1 -TaskDescription "autogarage website" -Complexity Moderate

# Review panel, think AS each expert, synthesize, THEN implement
```

---

## Examples

### Example 1: Automotive Garage Website

**Task:** "Create website for automotive garage"
**Complexity:** Moderate
**Panel:** 5 experts (Automotive, Designer, Copywriter, SEO, CRO)

**Overlaps:**
- Trust signals (all 5 mention)
- Mobile optimization (4/5 mention)
- Clear service categorization (3/5 mention)

**Conflicts:**
- Designer wants visual simplicity vs SEO wants content depth
  - Resolution: Visual sections + expandable details
- CRO wants CTA above fold vs Designer wants hero image
  - Resolution: Hero WITH overlaid CTA

**Unique insights:**
- Automotive: Emergency vs planned service paths (nobody else)
- CRO: Same-day APK urgency (time-bound service specific)

**Synthesis:** Homepage with garage photo + certifications + dual CTAs (emergency/planned) + visual service grid + trust bar + schema markup.

### Example 2: Medical Clinic Website

**Task:** "Create website for physiotherapy clinic"
**Complexity:** Moderate
**Panel:** 5 experts (Healthcare, Designer, Copywriter, SEO, Accessibility)

**Overlaps:**
- Patient privacy/trust (4/5 mention)
- Treatment descriptions (accessible, not scary) (3/5 mention)
- Appointment booking (3/5 mention)

**Conflicts:**
- Healthcare wants detailed treatment info vs Designer wants simplicity
  - Resolution: "What to expect" sections with step-by-step (builds trust via transparency)

**Unique insights:**
- Healthcare: Insurance clarity upfront (major patient pain point)
- Accessibility: Video demos need captions (legal + user experience)

**Synthesis:** Calm visual design (greens/whites) + treatment pages with patient-friendly explanations + "What to expect" sections + insurance info prominent + accessible booking form + video demos with captions.

### Example 3: E-commerce Product Page

**Task:** "Optimize product page for conversion"
**Complexity:** Complex
**Panel:** 7 experts (E-commerce, Designer, Copywriter, SEO, CRO, Trust, Analytics)

**Overlaps:**
- High-quality product photos (6/7 mention)
- Clear pricing (5/7 mention)
- Reviews/social proof (5/7 mention)

**Conflicts:**
- Designer wants minimal text vs Copywriter wants detailed benefits
  - Resolution: Tabbed interface (Overview/Details/Reviews) - different audiences, different depths
- CRO wants single "Buy now" vs E-commerce wants "Add to cart" + "Buy now"
  - Resolution: Primary "Add to cart" + secondary "Buy now" (flexibility)

**Unique insights:**
- E-commerce: Shipping calculator reduces abandonment (uncertainty kills conversions)
- Analytics: Exit intent popup for first-time visitors (last chance offer)
- Trust: Return policy prominent (removes purchase anxiety)

**Synthesis:** Product page with gallery + tabs (overview/details/reviews) + prominent pricing + shipping calculator + dual CTAs + trust badges + return policy section + exit intent popup.

---

## Maintenance

**Update expert domains database when:**
- New industries emerge (crypto, AI services, sustainable tech)
- New roles become standard (AI prompt engineer, no-code developer)
- Best practices evolve (accessibility standards, privacy regulations)
- User feedback identifies missing perspectives

**Review frequency:** Quarterly (or after 20 uses, whichever comes first)

**Expansion signals:**
- Same experts selected repeatedly (need more granularity)
- Frequent "no match" results (coverage gaps)
- User adds experts manually (database missing common domains)

---

## Success Criteria

**This protocol is successful if:**
- Solutions regularly incorporate 4+ expert perspectives (not single-dimensional)
- Conflicts are identified and resolved (not ignored)
- Unique insights from domain experts are captured (not just generic best practices)
- User outcomes improve measurably (conversion, engagement, satisfaction)
- Time-to-quality-solution decreases (parallel perspectives vs serial discovery)

**Failure signals:**
- All experts give same advice (panel too narrow or task too simple)
- Conflicts unresolved (patchwork solution, not synthesis)
- Domain expert ignored in favor of "best practices" (loses contextual intelligence)
- Process feels like overhead without value (activation threshold too low)

---

## Meta-Insight

**This protocol is itself an EXPERT PERSPECTIVE:**

"As a Meta-Process Expert, the most important consideration is: **Integration of diverse perspectives yields solutions that no single perspective could achieve alone.** The value is not in asking experts, but in RESOLVING THE TENSIONS between their recommendations."

**The magic happens in synthesis, not collection.**

---

**Version:** 1.0
**Created:** 2026-02-28
**Last Updated:** 2026-02-28
**Status:** Production-ready
**Integration:** Consciousness bridge (OnTaskStart), Manual invocation
