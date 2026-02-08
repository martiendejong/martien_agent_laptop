# Facebook / Meta API Verificatie Guide

**Datum:** 8 februari 2026
**Platform:** Facebook & Meta Developer Platform
**Portal:** https://developers.facebook.com/

---

## 📋 Overzicht

Deze guide beschrijft het complete verificatieproces om API toegang te krijgen voor Facebook en Meta's developer platform. Dit proces is ook vereist voor Instagram API toegang.

---

## 🎯 Wat heb je nodig?

### Voor Business Verification:
- ✅ Bedrijfsdocumentatie (KvK uittreksel of business license)
- ✅ Business email adres (bij voorkeur met eigen domein)
- ✅ Website van het bedrijf
- ✅ Business telefoonnummer

### Voor App Review:
- ✅ Werkende prototype van je applicatie
- ✅ Test credentials voor reviewers
- ✅ Video walkthroughs (screen recordings)
- ✅ Gedetailleerde use case beschrijvingen

---

## 📝 Stap 1: Business Verification

### Waarom Business Verification?

**LET OP:** Voor Advanced Access (volledige API functionaliteit) is Business Verification **VERPLICHT**.

- **Standard Access:** Zeer beperkt, alleen eigen accounts, strikte rate limits → **ONBRUIKBAAR voor productie**
- **Advanced Access:** Volledige functionaliteit → **Vereist Business Verification + App Review**

### Proces

1. **Ga naar Facebook Developer Portal**
   - URL: https://developers.facebook.com/
   - Log in met je Facebook account

2. **Selecteer je app**
   - Ga naar "My Apps"
   - Selecteer bestaande app of maak nieuwe app aan

3. **Start Business Verification**
   - Klik in het linker menu op "Business Verification"
   - Of ga via App Settings → Basic → Business Verification

4. **Upload documentatie**

   **Acceptabele documenten:**
   - KvK uittreksel (Nederland)
   - Business license
   - Tax registration documents
   - Articles of incorporation

   **Belangrijke tips:**
   - ✅ Documenten moeten recent zijn (< 6 maanden oud)
   - ✅ Business naam moet **exact** overeenkomen in alle documenten
   - ✅ Upload heldere scans (geen slechte smartphone foto's)
   - ✅ Gebruik business email met eigen domein (@bedrijf.nl, NIET @gmail.com)

5. **Wacht op goedkeuring**
   - **Doorlooptijd:** 3-7 dagen
   - Je ontvangt email bij goedkeuring/afwijzing
   - Bij afwijzing: verbeter documentatie en submit opnieuw

---

## ⚠️ Alternative: Individual Verification

Als je geen business hebt, kun je Individual Verification aanvragen:

**Proces:**
1. Selecteer "Individual Verification"
2. Voer email adres in voor contract ontvangst
3. Upload ID (paspoort, rijbewijs, identiteitskaart)
4. Onderteken contract

**WAARSCHUWING:**
- ❌ Bepaalde permissions zijn beperkt of niet beschikbaar
- ❌ Niet geschikt voor apps met veel gebruikers
- ❌ Niet geschikt voor productie-omgevingen
- ✅ Alleen voor persoonlijke/hobby projecten

---

## 🎬 Stap 2: App Review - Permissions Aanvragen

Na Business Verification kun je permissions (API toegangsrechten) aanvragen.

### Belangrijke Facebook Permissions

| Permission | Omschrijving | Use Case |
|------------|--------------|----------|
| `pages_manage_posts` | Posten naar Facebook Pages | Content scheduling, social media management |
| `pages_read_engagement` | Analytics van Pages | Statistieken ophalen, engagement meten |
| `pages_show_list` | Lijst van beheerde Pages | Selecteer Pages voor posting |
| `public_profile` | Basis gebruiker info | Login, identificatie |
| `email` | Email adres gebruiker | Account koppeling |

### Belangrijke Instagram Permissions (via Meta)

| Permission | Omschrijving | Use Case |
|------------|--------------|----------|
| `instagram_basic` | Profiel info + media | Basis toegang tot Instagram account |
| `instagram_content_publish` | Content posten | Posts en stories plaatsen |
| `instagram_manage_comments` | Comments beheren | Reageren op comments |
| `instagram_manage_insights` | Analytics | Statistieken en insights ophalen |

---

## 🎥 Video Walkthroughs Maken (VERPLICHT)

Voor **ELKE** permission die je aanvraagt, moet je een video walkthrough maken.

### Wat moet erin?

1. **Complete User Flow**
   - Gebruiker logt in met Facebook/Instagram
   - Gebruiker geeft permission (OAuth consent screen)
   - App gebruikt de toegang (toon exact waar data verschijnt)

2. **Data Usage**
   - Toon precies welke data je ophaalt
   - Laat zien waar data wordt opgeslagen
   - Demonstreer hoe gebruiker data kan verwijderen

3. **Security & Privacy**
   - Toon HTTPS verbinding
   - Laat privacy policy zien
   - Demonstreer data encryptie (als van toepassing)

### Technische Vereisten

- ✅ **Max lengte:** 10 minuten per permission
- ✅ **Formaat:** MP4, MOV, of AVI
- ✅ **Kwaliteit:** Screen recording is voldoende (geen hoge productiewaarde nodig)
- ✅ **Geluid:** Geen voice-over of muziek nodig
- ❌ **Test data:** Gebruik test accounts, GEEN echte gebruiker data

### Tips voor Goede Walkthroughs

✅ **DO:**
- Gebruik test accounts met test data
- Toon volledige flow van begin tot eind
- Demonstreer alle features die de permission gebruiken
- Wees duidelijk en systematisch

❌ **DON'T:**
- Gebruik geen echte gebruiker credentials
- Geen muziek of elaborate video editing
- Geen vage/onduidelijke opnames
- Skip geen stappen in de flow

---

## 📤 App Review Submission

### Proces

1. **Ga naar App Review**
   - In je app dashboard: "App Review" → "Permissions and Features"

2. **Selecteer Permissions**
   - Klik op "+ Request Advanced Access"
   - Selecteer gewenste permissions

3. **Voor elke Permission:**

   **a) Upload Video Walkthrough**
   - Upload je screen recording
   - Max 10 minuten per permission

   **b) Beschrijf Use Case**
   - Waarom heb je deze permission nodig?
   - Hoe wordt de data gebruikt?
   - Hoe lang bewaar je data?
   - Wordt data gedeeld met derden?

   **c) Geef Test Credentials**
   - Username + wachtwoord voor test account
   - Stap-voor-stap instructies voor reviewers
   - Zorg dat test account volledige toegang heeft

4. **Submit voor Review**
   - Check alles nog eens
   - Klik "Submit"
   - Wacht op goedkeuring

### Wat Reviewers Checken

✅ **Policy Compliance:**
- Voldoe je aan Facebook Platform Policy?
- Vraag je alleen minimale permissions?
- Is data handling transparant?

✅ **Functionality:**
- Werkt de app zoals beschreven?
- Zijn alle features duidelijk gedemonstreerd?
- Gebruiken alle features de gevraagde permissions?

✅ **Security:**
- Is data veilig opgeslagen?
- HTTPS verbinding?
- Juiste error handling?

---

## ⏱️ Doorlooptijd & Verwachtingen

| Fase | Duur | Status Tracking |
|------|------|-----------------|
| **Business Verification** | 3-7 dagen | Email notificaties |
| **App Review** | 2-14 dagen | Dashboard → App Review → Status |
| **Totaal** | **5-21 dagen** | - |

### Tijdens Review

- ✅ Je kunt status checken in App Dashboard
- ✅ Je ontvangt email bij statuswijzigingen
- ✅ Bij vragen: Facebook neemt contact op via email
- ⚠️ Antwoord snel op vragen (anders vertraagt review)

### Na Goedkeuring

✅ **Permissions zijn actief:**
- Je hebt nu Advanced Access voor goedgekeurde permissions
- Implementeer binnen 90 dagen (anders vervalt toegang)
- Test uitgebreid voor productie deployment

❌ **Bij Afwijzing:**
- Lees feedback zorgvuldig
- Verbeter volgens opmerkingen
- Submit opnieuw (met verbeteringen)

---

## 🔐 Security & Privacy Checklist

Zorg dat je app voldoet aan deze requirements:

### Data Handling
- [ ] Data wordt veilig opgeslagen (encrypted at rest)
- [ ] HTTPS voor alle API calls
- [ ] Data wordt niet gedeeld met derden zonder toestemming
- [ ] Gebruikers kunnen data verwijderen
- [ ] Clear data retention policy

### Privacy Policy
- [ ] Publieke privacy policy URL
- [ ] Beschrijft welke data je verzamelt
- [ ] Beschrijft hoe data gebruikt wordt
- [ ] Beschrijft hoe lang data bewaard wordt
- [ ] Beschrijft gebruiker rechten (inzage, verwijdering)

### User Experience
- [ ] Duidelijke OAuth consent screens
- [ ] Gebruiker kan permissions intrekken
- [ ] Error messages zijn gebruiksvriendelijk
- [ ] App werkt zonder crashes

---

## 🚨 Veelgemaakte Fouten

### ❌ Fout 1: Standard Access Gebruiken
**Probleem:** Standard Access is te beperkt voor productie
**Oplossing:** Altijd Advanced Access aanvragen via App Review

### ❌ Fout 2: Te Veel Permissions Vragen
**Probleem:** Meer permissions = langzamere review + hogere kans op afwijzing
**Oplossing:** Vraag ALLEEN permissions die je écht nodig hebt

### ❌ Fout 3: Slechte Video Walkthroughs
**Probleem:** Onduidelijke video's leiden tot afwijzing
**Oplossing:** Test je video voordat je submit (laat aan collega zien)

### ❌ Fout 4: Geen Test Credentials
**Probleem:** Reviewers kunnen app niet testen
**Oplossing:** Maak dedicated test account met volledige toegang

### ❌ Fout 5: Verouderde Business Documenten
**Probleem:** Documenten ouder dan 6 maanden worden afgewezen
**Oplossing:** Download recente KvK uittreksel/business docs

---

## 📞 Support & Hulp

### Als je vastloopt:

**Facebook Developer Support:**
- URL: https://developers.facebook.com/support/
- Community Forum: https://developers.facebook.com/community/
- Live Chat: Beschikbaar voor geverifieerde developers

**App Review Status:**
- Check in je App Dashboard → App Review
- Email notificaties bij statuswijzigingen

**Veelgestelde Vragen:**
- Developer Docs: https://developers.facebook.com/docs/
- Platform Policy: https://developers.facebook.com/policy/

---

## ✅ Checklist: Ben je klaar?

### Voor Business Verification:
- [ ] Recent KvK uittreksel of business license (< 6 maanden)
- [ ] Business email met eigen domein
- [ ] Business website online en functioneel
- [ ] Business telefoonnummer

### Voor App Review:
- [ ] Werkende prototype van je app
- [ ] Voor elke permission: video walkthrough (< 10 min)
- [ ] Test account met volledige toegang
- [ ] Gedetailleerde use case beschrijvingen
- [ ] Privacy policy publiek beschikbaar
- [ ] Security measures geïmplementeerd (HTTPS, encryption)

### Na Goedkeuring:
- [ ] API credentials veilig opgeslagen
- [ ] Rate limiting geïmplementeerd
- [ ] Error handling robuust
- [ ] Monitoring voor API errors
- [ ] Plan voor productie deployment binnen 90 dagen

---

## 📚 Belangrijke Links

**Developer Portal:**
https://developers.facebook.com/

**Business Verification:**
https://developers.facebook.com/docs/development/release/business-verification

**App Review Process:**
https://developers.facebook.com/docs/app-review

**Platform Policy:**
https://developers.facebook.com/policy/

**API Documentation:**
https://developers.facebook.com/docs/graph-api

**Support:**
https://developers.facebook.com/support/

---

**Document Versie:** 1.0
**Laatst Bijgewerkt:** 8 februari 2026
**Geschikt voor:** Facebook, Instagram, WhatsApp (via Meta Platform)
