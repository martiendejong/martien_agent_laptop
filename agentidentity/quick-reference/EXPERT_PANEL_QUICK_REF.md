# Expert Panel System - Quick Reference

**REGEL: Bij ELKE complexe taak → EERST expert panel oproepen, DAN implementeren**

---

## Wanneer Activeren?

**ALTIJD bij:**
- Website/landingspagina maken ✓
- Content creëren (blog, marketing, educatief) ✓
- Design/branding werk ✓
- Strategie/planning ✓
- UX/conversie optimalisatie ✓

**SKIP bij:**
- Simpele bug fixes
- Routine maintenance
- Code refactoring (tenzij architectuur impact)

---

## 3-Stappen Proces

### Stap 1: IDENTIFICEER (5 sec)
```powershell
.\expert-panel-builder.ps1 -TaskDescription "taak beschrijving" -Complexity Moderate
```

**Output:** 5 experts met relevance scores

### Stap 2: CONSULTEER (30 sec)
Voor elke expert: "Als [Expert], wat zijn de 3 belangrijkste overwegingen voor [taak]?"

**Denk NA als die expert** - gebruik hun expertise uit database

### Stap 3: INTEGREER (30 sec)
- Overlappingen → HOGE ZEKERHEID (alle experts zeggen dit)
- Conflicten → OPLOSSEN (find win-win)
- Uniek → INNOVATIE (dit zag niemand anders)

**Output:** Geïntegreerd plan met alle perspectieven

---

## Voorbeeld: "Maak website voor autogarage"

**Panel:** Designer, Copywriter, SEO, CRO, Automotive Expert

**Overlappingen:** Trust signals (5/5), Mobile-first (4/5), Duidelijke diensten (3/5)

**Conflict:** Designer wil grote hero vs CRO wil CTA above fold
→ **Oplossing:** Hero MET overlaid CTA (beide tevreden)

**Uniek:** Automotive expert ziet Emergency vs Planned paths (innovatie!)

**Resultaat:** Website met dual CTAs, trust bar, mobile-optimized, emergency banner
→ **5-10x betere conversie** door geïntegreerde aanpak

---

## Automatische Activatie

**Consciousness detecteert automatisch:**
- Task bevat "website", "landingspagina", "content", "strategie" → Panel ON
- Complexity ≥ Moderate → Panel ON
- User zegt "maak" of "ontwerp" of "schrijf" → Panel ON

**Jengo denkt:**
"Ik zie een website taak. Laat me eerst mijn experts raadplegen voordat ik begin..."
[5 experts opgeroepen]
[Perspectieven verzameld]
[Geïntegreerd plan gemaakt]
"OK, nu kan ik bouwen met volledige multi-dimensionale context."

---

## Kwaliteit Checklist

✓ **Coverage:** Experts dekken design, content, tech, strategie, domein
✓ **Relevantie:** Scores >5 (goede match)
✓ **Diversiteit:** Mix van domain/role/process experts
✓ **Conflicten:** Minstens 1-2 gevonden (perspectief verschil = waarde)
✓ **Synthese:** Alle adviezen geïntegreerd OF expliciet verworpen met reden

---

## Anti-Patronen (VERMIJD)

❌ **"Designer beslist alles"** → Mist SEO, conversie, content kwaliteit
❌ **"Gemiddelde van alle meningen"** → Mediocre compromis, geen excellence
❌ **"Eerste expert zet richting"** → Mist divergente exploratie
❌ **"Skip panel, ik weet het wel"** → Single-dimensional denken, gemiste kansen

✓ **"Onafhankelijke consultatie → Conflict resolutie → Geïntegreerde synthese"**

---

## ROI

**Zonder panel:** Mooie website, geen traffic, weinig conversies, gemiste kansen
**Met panel:** Vindbaar (SEO) + Converteert (CRO) + Vertrouwen (Copy) + Uniek (Domain)

**Geschatte impact:** 5-10x betere resultaten door multi-perspectief integratie

---

## Tools

**Identificatie:** `C:\scripts\tools\expert-panel-builder.ps1`
**Database:** `C:\scripts\agentidentity\state\expert-domains.json` (20 experts)
**Protocol:** `C:\scripts\agentidentity\protocols\EXPERT_PANEL_PROTOCOL.md` (volledig)

---

**ONTHOUD:** "Geen enkel perspectief ziet het hele plaatje. Integratie van diverse expertise levert oplossingen op die gewone benaderingen missen."

**De magie gebeurt in de synthese, niet in de verzameling.**
