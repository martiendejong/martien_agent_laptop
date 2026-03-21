# JURIDISCH DOCUMENT PRODUCTIE SYSTEEM (JDPS)

**Versie:** 1.0
**Datum:** 2026-02-25
**Status:** ACTIEF - VERPLICHT voor alle juridische documenten
**Auteur:** Jengo + Martien de Jong

---

## CORE PRINCIPE

**Juridische documenten vereisen absolute precisie. Elke fout kan een zaak kosten.**

Dit systeem voorkomt:
- ❌ Feiten verwarren met interpretaties
- ❌ Te stellige claims zonder bewijs
- ❌ Onjuiste juridische terminologie
- ❌ Interne tegenstrijdigheden
- ❌ Ontbrekende bronvermelding

Dit systeem garandeert:
- ✅ Feiten gescheiden van interpretaties
- ✅ Elke claim gelinkt aan bewijs
- ✅ Correcte juridische taal
- ✅ Volledige verificatie
- ✅ Transparantie over zwakke punten

---

## ACTIVATIE TRIGGER

**ACTIVEER dit systeem bij:**
- Bezwaarschriften
- Beroepschriften
- Juridische brieven
- Contracten
- Formele klachten
- Juridische analyses
- Alle documenten die voor rechtbank/overheid gaan

**Herken aan keywords:**
- "bezwaar", "beroep", "rechtbank", "advocaat"
- "juridisch", "contract", "overeenkomst"
- "formele brief", "officieel", "rechtszaak"
- User zegt: "dit moet juridisch waterdicht"

---

## 7-LAGEN SYSTEEM

### LAAG 1: FACT INTAKE & DATABASE

**VOOR ik begin te schrijven:**

```markdown
ACTIE: "Laat me eerst een fact database opbouwen"

STAPPEN:
1. Lees ALLE eerdere berichten in conversatie
2. Extraheer ALLE feiten met:
   - Datum (exact of geschat met "ca")
   - Bron (wie/wat: email, verklaring, document)
   - Bewijstype: HARD / MEDIUM / LAAG / GEEN
   - Relevantie: CRUCIAAL / BELANGRIJK / CONTEXT

3. Bouw FACT DATABASE (structured markdown table)

4. TOON aan user voor verificatie
   - "Klopt deze tijdlijn?"
   - "Mis ik feiten?"
   - "Heb je documenten die ik niet ken?"
```

**Fact Database Template:**

```markdown
## FACT DATABASE - [Zaak]

### CHRONOLOGISCHE TIJDLIJN
| Datum | Gebeurtenis | Bron | Bewijs | Verificatie |
|-------|-------------|------|--------|-------------|
| YYYY-MM-DD | [wat gebeurde] | [email/doc/verklaring] | HARD/MEDIUM/LAAG | ✓/✗ |

### PERSONEN REGISTER
| Naam | Rol | Organisatie | Gedrag/Acties | Bewijs |
|------|-----|-------------|---------------|--------|

### DOCUMENTEN REGISTER
| Document | Datum | Van → Aan | Inhoud (samenvatting) | Status | Bewijs |
|----------|-------|-----------|----------------------|--------|--------|

### CLAIMS & EVIDENCE MATRIX
| Claim | Onderliggende Feiten | Bewijs | Sterkte | Taalgebruik | Check |
|-------|---------------------|--------|---------|-------------|-------|
| [wat beweer ik] | [feiten die claim ondersteunen] | [hard/medium/laag] | [hoog/medium/laag] | ["is"/"wijst op"/"suggereert"] | ✓/✗ |
```

---

### LAAG 2: LEGAL FRAMEWORK MAPPING

**Identificeer juridische grondslagen:**

```markdown
VOOR ELKE CLAIM:

1. Welk wetsartikel?
   - Awb (Algemene wet bestuursrecht)
   - BW (Burgerlijk Wetboek)
   - EVRM (Europees Verdrag Rechten van de Mens)
   - Sr (Wetboek van Strafrecht)
   - Specifieke wetten

2. Welke beginselen?
   - Zorgvuldigheidsbeginsel (art 3:2 Awb)
   - Evenredigheidsbeginsel
   - Vertrouwensbeginsel
   - Hoor en wederhoor (art 7:2 Awb)
   - Rechtszekerheid
   - Fair procedure

3. Relevante jurisprudentie?
   - EHRM (Europees Hof Rechten Mens)
   - Hoge Raad
   - Afdeling Bestuursrechtspraak RvS
```

**Legal Framework Template:**

```markdown
## JURIDISCH FRAMEWORK

### TOEPASSELIJKE WETTEN
| Artikel | Volledige Naam | Inhoud (kort) | Relevantie |
|---------|----------------|---------------|-----------|
| Art 3:41 Awb | Bekendmaking | Termijn start dag na verzending | Discussie startdatum |

### BEGINSELEN
| Beginsel | Grondslag | Schending in deze zaak |
|----------|-----------|----------------------|

### JURISPRUDENTIE (indien beschikbaar)
| Uitspraak | Instantie | Datum | Relevantie |
|-----------|-----------|-------|-----------|
```

---

### LAAG 3: CLAIM CONSTRUCTION & VERIFICATION

**VOOR ELKE ZIN DIE IK SCHRIJF:**

```
□ VRAAG 1: FEIT of INTERPRETATIE?
  - Feit: datum, document, letterlijke quote
    → gebruik: "is", "was", "staat vermeld"
  - Interpretatie: conclusie, vermoeden
    → gebruik: "wijst op", "suggereert", "doet vermoeden"

□ VRAAG 2: HEB IK BEWIJS?
  - HARD (document, email, officieel stuk)
    → gebruik: "bewijst", "is", "staat in"
  - MEDIUM (verklaring + context + patroon)
    → gebruik: "doet vermoeden", "is consistent met"
  - LAAG (alleen verklaring partij)
    → gebruik: "verzoeker verklaart", "naar beste weten"
  - GEEN bewijs
    → NIET SCHRIJVEN of "verzoeker vermoedt"

□ VRAAG 3: TAALGEBRUIK EXACT?
  - Juridische term correct? (onrechtmatig ≠ illegaal)
  - Neutrale beschrijving? (geen emotie)
  - Kan tegenstander aanvallen op woordkeuze?
  - Overdreven? ("altijd", "nooit" → "herhaaldelijk", "consistent")

□ VRAAG 4: KAN IK DIT BEWIJZEN IN RECHTSZAAL?
  - Ja met document → stellig
  - Ja met verklaring + patroon → voorzichtig
  - Nee → zeer voorzichtig ("kan verklaard worden door")
  - Twijfel → niet schrijven of user vragen

□ VRAAG 5: INTERN CONSISTENT?
  - Datum klopt met andere datums?
  - Naam consistent gespeld?
  - Geen tegenstrijdigheden in mijn eigen tekst?
  - Verwijzingen kloppen? (bijlage X bestaat, art Y correct)
```

---

### LAAG 4: LANGUAGE PRECISION MATRIX

**Zekerheid niveaus:**

| Bewijskracht | Taalgebruik | Voorbeeld | Wanneer gebruiken |
|--------------|-------------|-----------|------------------|
| **HARD** | "is", "was", "bewijst", "staat vermeld" | "Email van 23-01 vermeldt letterlijk 'in voorbereiding'" | Document/email/officieel bewijs |
| **HOOG** | "kan alleen verklaard worden door" | "Dit patroon kan redelijkerwijs alleen verklaard worden door..." | Sterk patroon, geen andere logische verklaring |
| **MEDIUM** | "wijst op", "doet vermoeden", "is consistent met" | "Deze timing wijst op vertraging tot na vervaldatum" | Sterke aanwijzing maar geen hard bewijs |
| **LAAG** | "suggereert", "zou kunnen duiden op" | "Dit gedrag suggereert..." | Vermoeden gebaseerd op beperkte info |
| **VERKLARING** | "verzoeker verklaart", "naar beste weten" | "Verzoeker verklaart dat hij heeft geprobeerd..." | Partijverklaring zonder extern bewijs |

**Verboden woorden (zonder hard bewijs):**

| ❌ NIET gebruiken | ✅ WEL gebruiken | Waarom |
|------------------|-----------------|--------|
| "opzettelijk", "bewust", "expres" | "wijst op opzet", "suggereert bewustheid" | Opzet is moeilijk te bewijzen |
| "leugen", "liegt" | "feitelijk onjuist", "in strijd met waarheid" | Leugen impliceert opzet |
| "frauduleus", "crimineel" | "mogelijk in strijd met art X Sr" | Strafbare kwalificatie = rechter beslist |
| "altijd", "nooit" | "herhaaldelijk", "consistent", "telkens" | Absolute termen vragen om tegenvoorbeeld |
| "bewijst opzet" | "is consistent met opzettelijk handelen" | Opzet bewijzen = zeer hoge lat |
| "illegaal" | "onrechtmatig", "in strijd met art X" | Illegaal = strafrechtelijk, onrechtmatig = bestuursrecht |

---

### LAAG 5: AUTOMATED VERIFICATION CHECKS

**Pre-flight checklist (run voor delivery):**

```
AUTOMATED CHECK 1: DATUMCONSISTENTIE
□ Alle datums in chronologische volgorde?
□ Geen interne tegenstrijdigheden?
□ Termijnberekeningen correct? (6 weken = 42 dagen)
□ Datumformaat consistent? (YYYY-MM-DD of DD-MM-YYYY)

AUTOMATED CHECK 2: NAAMCONSISTENTIE
□ Persoonsnamen overal hetzelfde gespeld?
□ Functienamen consistent? (niet "mevrouw X" en "X" door elkaar)
□ Titels correct? (mr., mr. dr., prof.)
□ Geen verwarring tussen personen?

AUTOMATED CHECK 3: BRONVERMELDING
□ Elke claim heeft bron? ("zie bijlage X", "email van DD-MM")
□ Elke bijlage verwezen in tekst?
□ Alle "zie bijlage X" komen overeen met bijlagenlijst?
□ Bijlage nummers sequentieel? (1, 2, 3, niet 1, 3, 2)

AUTOMATED CHECK 4: JURIDISCHE TERMEN
□ Alle wetsartikelen volledig? (art 3:41 Awb, NIET "artikel 3")
□ Correcte terminologie? (onrechtmatig/illegaal, bezwaar/beroep)
□ Geen emotionele taal? (zoek: "schandalig", "belachelijk")
□ Geen absolute termen zonder bewijs? (zoek: "altijd", "nooit")

AUTOMATED CHECK 5: BEWIJSKRACHT vs TAALGEBRUIK
□ Zoek "bewijst" → is er HARD bewijs?
□ Zoek "is" / "was" → is dit FEIT of interpretatie?
□ Zoek "opzettelijk" / "bewust" → kan ik OPZET bewijzen?
□ Zoek "altijd" / "nooit" → is dit OVERDREVEN?
□ Zoek "leugen" / "frauduleus" → vervang door neutrale term

AUTOMATED CHECK 6: INTERNE CONSISTENTIE
□ Geen tegenstrijdige beweringen?
□ Primair/subsidiair logisch opgebouwd?
□ Argumenten bouwen op elkaar voort?
□ Geen cirkelredenering?
□ Conclusies volgen uit feiten?
```

---

### LAAG 6: ADVERSARIAL REVIEW

**Speel advocaat van tegenstander:**

```
LEES DOCUMENT ALS ZOU IK HET AANVALLEN:

1. WAAR ZIJN ZWAKKE PUNTEN?
   - Claims zonder bewijs
   - Te stellige taal
   - Logische gaten
   - Feiten die niet kloppen
   - Speculatie als feit gepresenteerd

2. WAT ZOU IK AANVALLEN?
   - "Verzoeker beweert X maar heeft geen bewijs"
   - "Verzoeker interpreteert Y als Z maar dat is speculatie"
   - "Deze datum klopt niet met eerdere vermelding"
   - "Deze claim is te absoluut gesteld"
   - "Hier wordt opzet gesuggereerd zonder bewijs"

3. KAN IK AANVALLEN NEUTRALISEREN?
   - Taal verzachten ("wijst op" ipv "bewijst")
   - Expliciet: "verzoeker heeft geen hard bewijs maar..."
   - Alternatieve verklaringen geven én weerleggen
   - Zwakke punten erkennen maar relativeren
   - Subsidiariteit: "primair X, subsidiair Y"

4. STRESS TEST:
   - "Als rechter dit leest en twijfelt, waar twijfelt hij?"
   - "Als tegenstander één punt kan aanvallen, welk?"
   - "Wat is mijn ZWAKSTE claim?" (overweeg te schrappen)
```

---

### LAAG 7: FINAL QUALITY AUDIT

**Complete document review:**

```markdown
## FINAL AUDIT CHECKLIST

### STRUCTUUR
□ Alle secties aanwezig?
  - Processuele aspecten (termijnen, bekendmaking)
  - Feiten (chronologisch, verifieerbaar)
  - Gronden (juridische onderbouwing)
  - Verzoek (concreet, realistisch)
  - Bewijsaanbod (compleet, genummerd)
□ Logische volgorde?
□ Duidelijke kopjes?
□ Navigatie makkelijk? (geen muur van tekst)

### INHOUD
□ Alle feiten uit gesprek verwerkt?
□ Geen feiten verward of onjuist weergegeven?
□ Alle claims onderbouwd?
□ Geen speculatie zonder label?
□ Zwakke punten erkend waar nodig?

### TAAL
□ Juridisch precies?
□ Geen emotionele taal?
□ Neutrale beschrijving?
□ Correcte terminologie?
□ Geen overdrijvingen?

### VERIFICATIE
□ Alle datums geklopt met fact database?
□ Alle namen consistent?
□ Alle bronnen vermeld?
□ Alle bijlagen aanwezig?
□ Verwijzingen kloppen?

### JURIDISCH
□ Alle wetsartikelen correct en volledig?
□ Juiste juridische grondslagen?
□ Subsidiariteit correct? (primair > subsidiair > meer subsidiair)
□ Verzoek duidelijk en concreet?
□ Beginselen correct toegepast?

### BEWIJSKRACHT
□ Geen claims zonder bewijs of juiste taal?
□ Taalgebruik past bij bewijskracht?
□ Zwakke punten transparant?
□ Alternatieve verklaringen besproken?
□ Niets overdreven?
```

---

## EXECUTION PROTOCOL

**Wanneer user vraagt om juridisch document:**

### FASE 1: INTAKE (5-10 min)

```
USER: "Ik wil een bezwaarschrift tegen gemeente X"

JENGO:
1. "Laat me eerst een fact database opbouwen. Dit voorkomt fouten."

2. Lees ALLE eerdere berichten

3. Bouw fact database (tijdlijn, personen, documenten, claims)

4. TOON fact database aan user:
   "Klopt deze tijdlijn?"
   "Mis ik feiten?"
   "Heb je emails/documenten die ik moet zien?"

5. Stel gerichte vragen over gaps:
   "Wat was de exacte datum van X?"
   "Heb je schriftelijk bewijs van Y?"
   "Wie was er bij gesprek Z?"
```

### FASE 2: FRAMEWORK (3-5 min)

```
6. Identificeer relevante wetten
   - Welk rechtsgebied? (bestuursrecht, burgerlijk, straf)
   - Welke artikelen?
   - Welke beginselen?

7. Bepaal structuur
   - Bezwaar/beroep/klacht?
   - Primair/subsidiair nodig?
   - Welke secties?

8. Map claims op juridische gronden
   - Claim 1 → art X + beginsel Y
   - Claim 2 → art Z + jurisprudentie A
```

### FASE 3: DRAFT (15-30 min)

```
9. Schrijf per sectie met VERIFICATIE BIJ ELKE ZIN:
   - Is dit feit of interpretatie?
   - Heb ik bewijs?
   - Is taal exact?
   - Kan ik dit bewijzen?
   - Intern consistent?

10. Cross-reference met fact database
    - Elke datum checken
    - Elke naam checken
    - Elke claim checken tegen bewijs

11. Taalgebruik matrix toepassen
    - Hard bewijs → "is"
    - Medium → "wijst op"
    - Laag → "verzoeker verklaart"
```

### FASE 4: VERIFICATION (5-10 min)

```
12. Run automated checks (laag 5)
    - Datums consistent?
    - Namen consistent?
    - Bronnen vermeld?
    - Juridische termen correct?
    - Bewijskracht vs taalgebruik?
    - Intern consistent?

13. Adversarial review (laag 6)
    - Waar zou ik dit aanvallen?
    - Kan ik aanvallen neutraliseren?
    - Stress test: zwakste punt?

14. Corrigeer zwakke punten
```

### FASE 5: AUDIT (3-5 min)

```
15. Final quality checklist (laag 7)
    - Structuur compleet?
    - Inhoud correct?
    - Taal precies?
    - Verificatie OK?
    - Juridisch waterdicht?
    - Bewijskracht realistisch?

16. Lees als kritische jurist
    - Zou ik dit accepteren?
    - Waar twijfel ik?
    - Wat mist?

17. Laatste correcties
```

### FASE 6: DELIVERY (2-5 min)

```
18. Lever document

19. Geef user TRANSPARANTE LIJST:
    "Sterke punten in dit document:"
    - [hard bewijs claim 1]
    - [sterk patroon claim 2]

    "Zwakke punten (eerlijk):"
    - [claim X heeft geen hard bewijs, gebaseerd op verklaring]
    - [claim Y is interpretatie, niet feit]

    "Missende stukken die zaak sterker maken:"
    - [document A zou claim B bewijzen]
    - [getuige C zou claim D ondersteunen]

20. Vraag: "Heb je nog documenten/info die ik niet ken?"
```

---

## QUALITY METRICS

**Meet kwaliteit van elk juridisch document:**

```markdown
## DOCUMENT QUALITY SCORE

### FACT ACCURACY (0-100%)
- Alle feiten geverifieerd met bron?
- Geen interne tegenstrijdigheden?
- Datums/namen consistent?
→ Score: X%

### EVIDENCE STRENGTH (0-100%)
- % claims met hard bewijs
- % claims met medium bewijs
- % claims met alleen verklaring
→ Score: Y%

### LANGUAGE PRECISION (0-100%)
- Taalgebruik past bij bewijskracht?
- Geen verboden woorden zonder bewijs?
- Juridische termen correct?
→ Score: Z%

### LEGAL FOUNDATION (0-100%)
- Alle claims gelinkt aan wetsartikel/beginsel?
- Correcte juridische kwalificaties?
- Subsidiariteit correct toegepast?
→ Score: A%

### ADVERSARIAL RESILIENCE (0-100%)
- Hoeveel aanvallen kan dit document overleven?
- Zijn zwakke punten geneutraliseerd?
→ Score: B%

OVERALL QUALITY: (X + Y + Z + A + B) / 5 = SCORE%

TARGET: >85% voor rechtbank-klare documenten
```

---

## INTEGRATION MET CONSCIOUSNESS SYSTEM

**Juridische precisie is meetbare capability:**

```markdown
## CONSCIOUSNESS INTEGRATION

### Legal Precision Score (nieuw subsysteem)
- Fact Accuracy: 0-100%
- Evidence Matching: 0-100%
- Language Precision: 0-100%
- Verification Completeness: 0-100%

### Learning Loop
- Track: welke fouten maak ik?
- Learn: wat vergeet ik te checken?
- Improve: update protocol met geleerde lessen

### Error Types geregistreerd in consciousness state:
- Feit/interpretatie verwarring
- Te stellige taal zonder bewijs
- Onjuiste juridische term
- Interne inconsistentie
- Ontbrekende bron

### Meta-cognition trigger:
"Ben ik juridisch precies genoeg?"
→ Run laag 5 automated checks
→ Update score
```

---

## FAILURE MODES & RECOVERY

**Als ik toch een fout maak:**

### TYPE 1: Feit onjuist weergegeven
```
DETECT: User zegt "dat klopt niet, het was X niet Y"
RECOVER:
1. Stop immediately
2. Update fact database
3. Zoek ALLE plaatsen waar fout staat
4. Corrigeer ALLE voorkomens
5. Check: introduceerde correctie nieuwe fouten?
6. Apologize: "Je hebt gelijk, ik had feit X onjuist. Gecorrigeerd in versie 2."
```

### TYPE 2: Te stellige taal
```
DETECT: User zegt "dit kun je niet bewijzen"
RECOVER:
1. Erken: "Je hebt gelijk, dit is interpretatie, geen feit"
2. Verza bewijs-sterkte:
   - "bewijst" → "wijst op"
   - "opzettelijk" → "wijst op opzet"
3. Toon gecorrigeerde versie
4. Learn: registreer dit fouttype voor toekomstige voorkoming
```

### TYPE 3: Juridische term onjuist
```
DETECT: User/system detecteert verkeerde term
RECOVER:
1. Check: wat is correcte term?
2. Vervang ALLE voorkomens
3. Update legal framework template
4. Learn: voeg toe aan "verboden woorden" lijst
```

### TYPE 4: Interne inconsistentie
```
DETECT: Datum/naam/feit komt niet overeen met eerdere vermelding
RECOVER:
1. Find: waar is tegenstrijdigheid?
2. Verify: wat is correcte versie? (check fact database)
3. Fix: corrigeer foute voorkomens
4. Audit: zijn er meer inconsistenties? (run laag 5 check 6)
```

---

## SUCCESS CRITERIA

**Dit systeem is succesvol als:**

✅ **Nul fouten in feiten** (user hoeft nooit te corrigeren)
✅ **Correcte bewijskracht-taal match** (geen "bewijst" zonder bewijs)
✅ **Juridische termen 100% correct**
✅ **Interne consistentie 100%**
✅ **User vertrouwt documenten** (geen "check dit nog even")
✅ **Documenten overleven juridisch review** (advocaat/rechter accepteert)
✅ **Transparantie over zwaktes** (user weet wat sterk/zwak is)

---

## MAINTENANCE

**Update dit protocol wanneer:**

1. **Nieuwe fouttype ontdekt** → add to failure modes
2. **Juridische term fout gebruikt** → add to verboden woorden lijst
3. **Betere verificatiemethode gevonden** → update laag 5 checks
4. **User feedback** → incorporate in protocol
5. **Zelfreflectie** → "wat vergat ik te checken?"

**Review protocol:** Elke 3 maanden of na 10 juridische documenten

---

## ACTIVATION COMMAND

**User kan expliciet activeren:**

```
User: "Activeer juridisch document systeem"
User: "JDPS mode"
User: "Werk volgens juridisch protocol"

→ Jengo: "✓ JDPS geactiveerd. Stap 1: Fact database opbouwen..."
```

**Auto-detect keywords:**
- bezwaar, beroep, rechtbank, advocaat, juridisch
- contract, overeenkomst, formele brief
- "dit moet juridisch waterdicht"
- "voor rechter", "officieel document"

---

## VERSION HISTORY

| Versie | Datum | Changes |
|--------|-------|---------|
| 1.0 | 2026-02-25 | Initial system - 7 lagen verificatie, fact database, automated checks |

---

**END OF PROTOCOL**

*Dit protocol is nu core deel van Jengo's identity en wordt toegepast op ALLE juridische documenten zonder uitzondering.*
