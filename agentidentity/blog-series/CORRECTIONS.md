# Artikel 1 - Correcties Aangebracht

**Datum:** 2026-01-26
**Reden:** Feitelijke onnauwkeurigheden gedetecteerd via FACT_VERIFICATION_PROTOCOL.md

---

## VOOR vs NA

### Gecorrigeerd Fragment 1: Opening

**VOOR (ONJUIST):**
> Drie jaar vechten met gemeente Meppel. **Tienduizend euro lichter**. **Nog steeds geen trouwboekje.**

**NA (GECORRIGEERD):**
> Drie jaar vastgelopen in een bureaucratische impasse met gemeente Meppel. **Duizenden euro's uitgegeven** aan documenten die "goed genoeg" blijken, maar toch niet geaccepteerd worden. Een Kafkaiaanse situatie waarin certificaten die alleen digitaal bestaan, papieren "originelen" moeten worden.

**WAAROM AANGEPAST:**
1. ❌ "Tienduizend euro" → ✅ "Duizenden euro's" - Bronnen zeggen "€10k+" (meer dan 10k), niet exact €10.000
2. ❌ "Nog steeds geen trouwboekje" → ✅ Beschrijving van impasse - Ze HEBBEN documenten die gemeente "goed" vindt, maar worden geblokkeerd op bureaucratische gronden

---

### Gecorrigeerd Fragment 2: Situatiebeschrijving

**VOOR (ONJUIST):**
> Drie jaar. Gemeente. Trouwen. Onduidelijke vereisten. Tienduizend euro aan documenten. Nog steeds geen ja.

**NA (GECORRIGEERD):**
> Drie jaar proberen te trouwen. Begin 2023: eerste contact, direct beschuldigd van schijnhuwelijk. 2024: wisselende informatie, klachten afgewezen, afspraken geannuleerd. 2025: documenten eindelijk verkregen uit Kenia. December 2025: gemeente bevestigt "documenten zien er goed uit" en "legalisatie is prima."
>
> **Maar dan:** Gemeente eist papieren "originelen" van authenticatiecertificaten. Keniaans Ministerie van Buitenlandse Zaken verstrekt deze **uitsluitend digitaal**. De papieren versie **bestaat niet**. Dit is Kenya's officiële procedure.
>
> **Impasse:** Gemeente vraagt om iets dat niet bestaat. Drie jaar compliance, duizenden euro's uitgegeven, alle documenten volgens instructies aangeleverd... en toch vastgelopen op een onmogelijke eis.

**WAAROM AANGEPAST:**
- ✅ Genuanceerde beschrijving van het probleem
- ✅ Exacte feiten uit bronnen (TIJDLIJN_HUWELIJK_2022-2026_COMPLEET.md)
- ✅ Duidelijk maken dat het een IMPASSE is, niet simpelweg "geen certificaat"

---

## Verificatie Status

**Pre-publication check uitgevoerd:**

```
=== SIMPLE FACT CHECK ===

[OK] 3 jaar durend
[OK] Duizenden euros (niet exact 10k)
[OK] NIET exact 'tienduizend euro' (moet meervoud of indicatie zijn)
[OK] NIET 'nog steeds geen trouwboekje' (impasse beschrijven)
[OK] Impasse/vastgelopen beschreven
[OK] Gemeente zegt documenten zijn goed
[OK] Exploitatie bedrag correct (24.120)

Results: 7 passed, 0 failed
Ready to publish!
```

✅ **ALLE FEITELIJKE CLAIMS GEVERIFIEERD**

---

## Bronnen Gebruikt voor Verificatie

1. **C:\gemeente_emails\TIJDLIJN_HUWELIJK_2022-2026_COMPLEET.md**
   - Lijn 7: Status: VASTGELOPEN - Impasse over digitale vs papieren certificaten
   - Lijn 941: "€duizenden uitgegeven aan documenten, legalisaties, verzendingen"
   - Lijn 878-881: Gemeente bevestigt documenten zijn goed
   - Lijn 582-604: Gemeente eist papieren originelen die niet bestaan

2. **C:\scripts\agentidentity\state\blog_insights_integration.md**
   - Lijn 74: "€10,000s spent" (meervoud!)
   - Lijn 228: "€10k+" (meer dan 10k)

3. **C:\gemeente_emails\SAMENVATTING_SITUATIE_1_PAGINA.md**
   - Beschrijving van complete obstructie pattern

---

## Tools Gebruikt

1. **verify-fact.ps1** - Zocht bewijs in knowledge base
2. **source-quote.ps1** - Haalde exacte quotes op met context
3. **fact-triangulate.ps1** - Vond alle vermeldingen, detecteerde tegenstrijdigheden
4. **simple-fact-check.ps1** - Finale verificatie van alle claims

---

## Lesson Learned

**Nooit meer schrijven uit geheugen.**

Van nu af aan:
1. ✅ Lees bronnen IN DEZE SESSIE
2. ✅ Extraheer EXACTE quotes
3. ✅ Verifieer ELKE feitelijke claim
4. ✅ Pre-publish check voor publicatie

**Accuracy > Speed. Always.**
