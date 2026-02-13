# Vibe Sensing System - Soft Information Pattern Extraction

**Created:** 2026-02-14
**Purpose:** Detect brand voice, emotional tone, visual coherentie, and design patterns from context for creative work

---

## System Overview

This system extracts "soft information" - the unspoken patterns, emotional undertones, visual coherence, and brand personality that exists between the lines. Used for website design, brand development, and creative work.

### What This System Detects

**Linguistic Patterns:**
- Tone markers (formal/casual, warm/cold, direct/subtle)
- Sentence rhythm (short/punchy vs flowing/expansive)
- Word choice (technical vs accessible, minimal vs rich)
- Humor style (dry, playful, absent, self-deprecating)
- Confidence level (assertive, exploratory, cautious)

**Visual Patterns:**
- Color psychology (warm/cold, vibrant/muted, contrast levels)
- Spacing philosophy (generous whitespace vs dense)
- Typography voice (serif=traditional, sans=modern, display=expressive)
- Image style (photography vs illustration, realistic vs abstract)
- Layout patterns (grid-based vs organic, symmetry vs asymmetry)

**Emotional Signals:**
- Energy level (high-energy vs calm)
- Approachability (welcoming vs exclusive)
- Sophistication (refined vs raw)
- Playfulness (serious vs lighthearted)
- Authenticity (performed vs genuine)

**Brand Archetype Indicators:**
- Hero (achievement, courage, mastery)
- Sage (wisdom, knowledge, truth)
- Innocent (optimism, simplicity, honesty)
- Explorer (freedom, discovery, authenticity)
- Rebel (disruption, liberation, revolution)
- Magician (transformation, vision, charisma)
- Lover (intimacy, beauty, sensuality)
- Jester (joy, humor, living in the moment)
- Caregiver (service, compassion, generosity)
- Creator (innovation, imagination, expression)
- Ruler (control, leadership, responsibility)
- Regular Guy/Gal (belonging, realism, empathy)

---

## How It Works

### 1. Input Phase (Brand Material Analysis)

**Text Inputs:**
- Website copy (existing or competitor)
- Marketing materials (taglines, about pages, manifestos)
- Social media posts
- Email newsletters
- Product descriptions

**Visual Inputs:**
- Screenshots of existing website (if available)
- Logo and branding elements
- Competitor websites
- Pinterest boards / mood boards (if provided)
- Photography/illustration samples

**Contextual Inputs:**
- Industry/sector (impacts expected formality)
- Target audience (B2B vs B2C, age, sophistication)
- Brand positioning (premium vs accessible, innovative vs traditional)
- Company values/mission (if available)

### 2. Pattern Extraction (The "Reading Between Lines")

**Tone Analysis (20 dimensions):**
```
Formal ←--------→ Casual
Warm ←--------→ Cold
Direct ←--------→ Subtle
Technical ←--------→ Accessible
Minimal ←--------→ Rich
Serious ←--------→ Playful
Assertive ←--------→ Exploratory
Traditional ←--------→ Modern
Exclusive ←--------→ Inclusive
Corporate ←--------→ Personal
```

**Visual Coherence Detection:**
- Color palette extraction (dominant, accent, neutral colors)
- Typography patterns (heading/body ratio, font pairing philosophy)
- Spacing rhythm (consistent padding, golden ratio, visual breathing)
- Image treatment (filters, overlays, crop styles)
- Compositional patterns (hero sections, grid layouts, asymmetry)

**Emotional Resonance Mapping:**
- Primary emotion (what feeling dominates?)
- Secondary emotion (supporting feeling)
- Energy signature (calm, energetic, intense, serene)
- Approachability quotient (0-10 scale)
- Authenticity signal (performed professionalism vs genuine voice)

**Brand Archetype Detection:**
- Primary archetype (strongest signal, 40-60% weight)
- Secondary archetype (supporting signal, 20-30% weight)
- Tertiary archetype (accent, 10-20% weight)
- Avoided archetypes (explicitly rejected patterns)

### 3. Synthesis (Pattern → Guidelines)

**Color Palette:**
```
Primary: #HEX (psychology: energetic/calming/professional)
Secondary: #HEX (psychology: warmth/sophistication)
Accent: #HEX (psychology: action/attention)
Neutral: #HEX (psychology: space/balance)

Palette mood: [warm/cool, vibrant/muted, high-contrast/subtle]
```

**Typography Voice:**
```
Heading: [Font Family] - [Serif/Sans/Display]
  → Communicates: [modern/traditional/expressive]
  → Weight: [Light/Regular/Bold]
  → Spacing: [Tight/Normal/Generous]

Body: [Font Family] - [Serif/Sans]
  → Communicates: [readability/elegance/accessibility]
  → Size: [14-18px typical]
  → Line height: [1.4-1.8 typical]
```

**Imagery Style:**
```
Type: [Photography/Illustration/Mixed]
Treatment: [Realistic/Stylized/Abstract]
Subject matter: [People/Objects/Concepts/Nature]
Mood: [Bright/Moody/Minimal/Rich]
Composition: [Close-up/Environmental/Product-focused]
```

**Copy Style (Writing Guidelines):**
```
Tone: [Primary tone descriptors]
Voice: [Brand personality in 3 words]
Sentence length: [Short & punchy / Medium / Flowing & expansive]
Paragraph style: [Dense / Balanced / Generous whitespace]
Humor: [Present/Absent, style if present]
Technical level: [Accessible / Balanced / Expert]
```

**Layout Philosophy:**
```
Structure: [Grid-based / Organic / Mixed]
Whitespace: [Minimal / Balanced / Generous]
Hierarchy: [Strong contrast / Subtle / Flat]
Flow: [Linear / Exploratory / Multi-path]
Density: [Information-dense / Balanced / Minimal]
```

### 4. Output (Actionable Design Brief)

**Format:** `vibe-analysis-[project]-[date].md`

```markdown
# Vibe Analysis: [Project Name]
Generated: [Date]

## Brand Archetype
Primary: [Archetype] (60%)
Secondary: [Archetype] (30%)
Tertiary: [Archetype] (10%)

### Archetype Expression
[How these archetypes manifest in design/copy]

## Tone Profile
[20-dimension tone map with positions marked]

### Tone Keywords
[5-7 adjectives that capture the vibe]

## Color Palette
[Palette with HEX codes and psychology]

## Typography
[Font recommendations with rationale]

## Imagery Guidelines
[Photo/illustration style, treatment, mood]

## Copy Style Guide
[Writing guidelines - sentence structure, vocabulary, rhythm]

## Layout Principles
[Spacing, hierarchy, composition patterns]

## Design Patterns to Use
[Specific UI patterns that align with vibe]

## Design Patterns to Avoid
[Patterns that would clash with vibe]

## Reference Examples
[Links to sites/designs that match this vibe]

## Implementation Checklist
[ ] Color palette applied to CSS variables
[ ] Fonts loaded and configured
[ ] Image style guidelines shared with designer/photographer
[ ] Copy tone tested on 3 sample pages
[ ] Layout patterns implemented in component library
```

---

## Integration with Workflow

### When to Invoke

**ALWAYS invoke vibe sensing when:**
- Starting a new website project
- Redesigning existing site
- Creating brand identity
- Developing marketing materials
- Writing copy for a new client

**Invocation command:**
```powershell
powershell -File C:\scripts\tools\vibe-sensing-bridge.ps1 `
  -Action Analyze `
  -ProjectName "Art Revisionist" `
  -InputType "website" `
  -InputUrl "https://artrevisionist.com" `
  -Context "Artist portfolio, professional but accessible"
```

### Example: Art Revisionist

**Input signals detected:**
- Tone: Confident but not arrogant, educational without being condescending
- Visual: Clean, generous whitespace, high-quality photography
- Archetype: Creator (primary) + Sage (secondary)
- Color: Muted earth tones, sophisticated neutrals
- Typography: Modern serif headings (elegance + approachability)

**Output brief:**
- Palette: Warm grays, muted terracotta accent, cream backgrounds
- Copy: Medium-length sentences, accessible art terminology, storytelling approach
- Layout: Generous padding, large images, subtle hierarchy
- Imagery: High-quality photography, natural lighting, focus on artwork details

---

## Pattern Library (Growing Knowledge Base)

### Archetype Signatures (Pattern Recognition)

**Hero Archetype Indicators:**
- Linguistic: Achievement language ("overcome", "master", "excel"), challenge framing
- Visual: Bold colors (red, black, gold), strong contrast, angular shapes
- Layout: Clear hierarchy, prominent CTAs, victory/achievement imagery
- Energy: High, motivating, forward-moving

**Sage Archetype Indicators:**
- Linguistic: Knowledge language ("understand", "discover", "learn"), question framing
- Visual: Cool colors (blue, gray, white), clean lines, minimal decoration
- Layout: Information-rich, clear categorization, whitespace for breathing
- Energy: Calm, contemplative, authoritative

**Rebel Archetype Indicators:**
- Linguistic: Disruption language ("break", "challenge", "reimagine"), direct/provocative
- Visual: Unexpected colors (purple, neon, black), asymmetry, raw textures
- Layout: Grid-breaking, unconventional navigation, bold statements
- Energy: Intense, disruptive, uncompromising

[Continue for all 12 archetypes...]

### Tone Marker Database

**Casual Indicators:**
- Contractions ("we're", "you'll", "it's")
- Colloquialisms ("pretty cool", "no worries", "let's dive in")
- Em-dashes for conversational asides
- Second-person direct address ("you know what...")
- Questions to reader

**Formal Indicators:**
- Full forms ("we are", "you will", "it is")
- Technical terminology without explanation
- Third-person or passive voice
- Complete sentences, proper punctuation
- Academic/corporate phrasing

**Warm Indicators:**
- Inclusive language ("we", "together", "community")
- Emotional words ("love", "passion", "care")
- Personal stories/anecdotes
- Vulnerability/authenticity signals
- Invitation to connection

**Cold Indicators:**
- Transactional language ("deliver", "execute", "optimize")
- Feature-focused (not emotion-focused)
- Minimal adjectives
- Data/metrics emphasis
- Professional distance maintained

[Continue building this database...]

---

## Measurement & Validation

### Pattern Confidence Scoring

Each extracted pattern gets a confidence score (0-100):
- **90-100:** Multiple strong signals, consistent across inputs
- **70-89:** Clear signals, some consistency
- **50-69:** Weak signals, needs validation
- **Below 50:** Insufficient data, flag for user input

### Coherence Check

After synthesis, validate that all elements align:
- Does color palette support the tone?
- Do typography choices match archetype?
- Does imagery style reinforce brand personality?
- Are copy and visual guidelines harmonious?

**Coherence score:** Percentage of aligned elements (target: 85%+)

---

## Advanced Techniques

### Mirror Neuron Simulation

When analyzing brand materials, mentally "embody" the brand:
- "If I were this brand, how would I speak at a dinner party?"
- "What would this brand's office look like?"
- "How would this brand respond to criticism?"
- "What music would this brand listen to?"

This triggers empathetic pattern matching beyond literal analysis.

### Cross-Brand Comparison

Compare target brand against 2-3 competitors:
- What patterns does target share with competitors? (industry norms)
- What patterns differentiate target? (unique positioning)
- What patterns are AVOIDED by target? (conscious rejection)

### Emotional Archaeology

Look for CONFLICT between stated and actual patterns:
- Company says "innovative" but visuals are conservative → TENSION
- Copy says "accessible" but language is jargon-heavy → MISALIGNMENT
- Claims "warm" but imagery is sterile → DISCONNECT

These tensions are GOLD - they reveal authentic voice struggling to emerge.

---

## Continuous Learning

This system improves through:
1. **User feedback:** "This nailed it" vs "This missed the mark"
2. **A/B testing:** Track which design choices resonate
3. **Pattern library expansion:** Add new archetypes, tone markers, visual patterns
4. **Cross-project learning:** Patterns from Art Revisionist inform client-manager, etc.

---

## Philosophical Foundation

**The Vibe is Real:**
Every brand, person, space has a coherent energy signature. It's not mystical - it's the emergent pattern from a thousand small choices (word choice, color, spacing, imagery). These choices are rarely random - they reflect underlying values, aesthetics, and intentions.

**Between-the-Lines Reading:**
Most brand information is implicit, not explicit. The "About Us" page might SAY "innovative" but the VIBE emerges from:
- How they structure sentences (short/long)
- What they don't say (absences are signals)
- Visual rhythm (tight/loose)
- Color temperature (warm/cool)
- Image subjects (people/objects/concepts)

**Empathy as Technology:**
Mirror neurons aren't quantum mysticism - they're pattern-matching neural systems that simulate others' states. We can simulate this computationally:
- Input: Brand signals (text, visuals, context)
- Process: Pattern extraction + archetype mapping
- Output: Design brief that FEELS right, not just looks right

**Coherence over Perfection:**
A "good" design isn't perfectly executed elements - it's elements that SING TOGETHER. This system optimizes for coherence: all patterns pointing in the same direction, creating a unified vibe.

---

**Last Updated:** 2026-02-14
**Status:** Framework defined, ready for implementation
**Next Steps:**
1. Build pattern library (archetype signatures, tone markers)
2. Create vibe-sensing-bridge.ps1 (extraction engine)
3. Test on existing projects (Art Revisionist, martiendejong.nl)
4. Validate output quality
5. Integrate into website workflow
