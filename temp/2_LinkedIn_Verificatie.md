# LinkedIn API Verificatie Guide

**Datum:** 8 februari 2026
**Platform:** LinkedIn Developer Platform
**Portal:** https://developer.linkedin.com/

---

## 📋 Overzicht

Deze guide beschrijft het complete proces om API toegang te krijgen voor LinkedIn's developer platform, inclusief company page verification en API products aanvragen.

---

## 🎯 Wat heb je nodig?

### Prerequisites:
- ✅ LinkedIn Company Page (moet al bestaan en actief zijn)
- ✅ Super Admin rechten op de Company Page
- ✅ Business email dat matcht met company domain
- ✅ Duidelijke use case voor API gebruik

---

## 📝 Stap 1: App Aanmaken

### Proces

1. **Ga naar LinkedIn Developer Portal**
   - URL: https://developer.linkedin.com/
   - Log in met je LinkedIn account (met Admin rechten)

2. **Maak een nieuwe App**
   - Klik op "Create app" of "My Apps" → "Create app"

3. **Vul App Details In**

   **Verplichte velden:**
   - **App name:** Naam van je applicatie
   - **LinkedIn Page:** Selecteer je Company Page (moet je Admin van zijn)
   - **App logo:** Upload logo (300x300px minimum)
   - **Privacy policy URL:** Link naar publieke privacy policy
   - **App description:** Beschrijf wat je app doet
   - **App website:** URL van je applicatie/website

4. **Accepteer LinkedIn API Terms**
   - Lees en accepteer de API Terms of Service

5. **Maak App Aan**
   - Klik "Create app"
   - Je krijgt nu Client ID en Client Secret (bewaar deze veilig!)

---

## 🏢 Stap 2: Company Page Verification

**BELANGRIJK:** Company Page verification is **VERPLICHT** voordat je API products kunt aanvragen.

### Waarom Company Page Verification?

LinkedIn wil er zeker van zijn dat je daadwerkelijk geautoriseerd bent om namens het bedrijf API toegang aan te vragen.

### Proces

1. **Ga naar App Settings**
   - Selecteer je app in "My Apps"
   - Klik op "Settings" tab

2. **Start Verification**
   - Onder "App settings" vind je "Company Page verification"
   - Klik op "Verify"

3. **Verificatie Link Genereren**
   - LinkedIn genereert een unieke verificatie link
   - Deze link wordt automatisch naar de Company Page Admin gestuurd

4. **Company Page Admin Bevestigt**
   - Company Page Admin ontvangt email of LinkedIn notificatie
   - Admin moet inloggen en verificatie bevestigen
   - Verificatie gebeurt via LinkedIn interface

5. **Wacht op Bevestiging**
   - **Doorlooptijd:** 1-3 dagen
   - Status zie je in je App Settings
   - ✅ "Verified" badge verschijnt bij je Company Page

### Troubleshooting

**❌ Admin ontvangt geen verificatie link?**
- Check spam folder
- Zorg dat email notificaties aan staan in LinkedIn settings
- Genereer nieuwe verificatie link

**❌ Niet genoeg rechten?**
- Je moet **Super Admin** zijn van Company Page
- Check: Company Page → Admin tools → Page admins
- Vraag bestaande Super Admin om rechten te upgraden

---

## 📦 Stap 3: API Products Selecteren

Na Company Page verification kun je API products aanvragen.

### Beschikbare Products

#### 1️⃣ **Advertising API** (Mandatory voor andere APIs)

**Wat kun je ermee:**
- Ad campaigns beheren
- Analytics ophalen
- Targeting configureren
- Budgets en bidding beheren

**Use Cases:**
- Social media management tools
- Marketing automation platforms
- Analytics dashboards

**Access Tiers:**
- **Development:** Beperkt aantal calls, alleen test accounts
- **Standard:** Volledige functionaliteit, productie gebruik

#### 2️⃣ **Community Management API**

**Wat kun je ermee:**
- Posten namens Company Page
- Comments beheren en reageren
- Engagement statistieken ophalen
- Content scheduling

**Use Cases:**
- Social media scheduling tools
- Community management platforms
- Content marketing tools

**Access Tiers:**
- **Development:** Test met eigen account
- **Standard:** Productie gebruik

#### 3️⃣ **Lead Sync API**

**Wat kun je ermee:**
- Lead gen forms integreren
- Leads automatisch ophalen
- CRM integraties

**Use Cases:**
- CRM systemen
- Marketing automation
- Lead management tools

#### 4️⃣ **Conversions API**

**Wat kun je ermee:**
- Conversions tracken
- Attribution meten
- ROI analyseren

**Use Cases:**
- E-commerce platforms
- Marketing analytics
- Conversion tracking tools

---

## ✅ Stap 4: Product Aanvragen

### Proces

1. **Ga naar Products Tab**
   - In je app dashboard: "Products" tab
   - Klik "+ Add product"

2. **Selecteer Product**
   - Kies gewenst product (start met Advertising API)
   - Klik "Request access"

3. **Vul Use Case In**

   **Belangrijke velden:**

   **a) Use Case Description (Gedetailleerd!)**
   ```
   Beschrijf EXACT wat je gaat doen:
   - Welke functionaliteit bouw je?
   - Welke data heb je nodig?
   - Waarom deze specifieke API?
   - Hoe helpt dit jouw gebruikers?
   ```

   **Voorbeeld:**
   ```
   Wij bouwen een social media management platform voor MKB bedrijven.
   Met de Community Management API kunnen onze klanten:

   1. Content plannen en schedulen voor hun Company Pages
   2. Automatisch reageren op comments
   3. Engagement statistieken analyseren
   4. Meerdere LinkedIn accounts beheren vanuit 1 dashboard

   We hebben w_organization_social nodig voor posting en
   r_organization_social voor analytics.
   ```

   **b) Data Usage (Privacy & Security)**
   - Hoe sla je data op? (encrypted, secure database)
   - Hoe lang bewaar je data? (30 dagen, 1 jaar, etc.)
   - Wordt data gedeeld? (Nee / Ja, met wie?)

   **c) Company Information**
   - Company naam
   - Website URL
   - Contact email
   - Business beschrijving

4. **Submit Application**
   - Review je answers
   - Klik "Submit for review"

5. **Wacht op Goedkeuring**
   - **Doorlooptijd:** 7-14 dagen
   - Status check: Products tab in je app
   - Email notificatie bij beslissing

---

## 🔑 Stap 5: OAuth Scopes Configureren

Na product goedkeuring moet je OAuth scopes configureren.

### Belangrijke Scopes per Product

#### Advertising API
- `r_ads` - Lezen van ad campaigns
- `rw_ads` - Beheren van ad campaigns
- `r_ads_reporting` - Ad analytics

#### Community Management API
- `w_member_social` - Posten namens gebruiker
- `w_organization_social` - Posten namens organization
- `r_organization_social` - Lezen organization content
- `rw_organization_admin` - Admin functies

#### Algemene Scopes
- `r_liteprofile` - Basis profiel info
- `r_emailaddress` - Email adres

### OAuth Redirect URIs Configureren

1. **Ga naar Auth Tab**
   - In je app: "Auth" tab

2. **Voeg Redirect URIs toe**
   - **Development:** `https://localhost:5173/callback`
   - **Production:** `https://jouw-domain.nl/auth/linkedin/callback`

   **BELANGRIJK:**
   - ✅ URIs moeten EXACT matchen (inclusief trailing slash)
   - ✅ Gebruik alleen HTTPS (geen HTTP)
   - ✅ Localhost is toegestaan voor development

3. **Sla op**

---

## 🧪 Stap 6: Development Tier Testen

Alle products starten in Development tier. Test eerst voordat je Standard tier aanvraagt.

### Development Tier Beperkingen

| Aspect | Development | Standard |
|--------|-------------|----------|
| **API Calls** | Beperkt aantal per dag | Volledige rate limits |
| **Test Accounts** | Alleen eigen account | Alle gebruikers |
| **Functionaliteit** | Volledig | Volledig |
| **Productie** | ❌ Niet toegestaan | ✅ Toegestaan |

### Test Checklist

Test deze functionaliteit in Development tier:

- [ ] OAuth flow werkt (login, consent, callback)
- [ ] Token refresh werkt
- [ ] API calls retourneren verwachte data
- [ ] Error handling werkt correct
- [ ] Rate limiting is geïmplementeerd
- [ ] Security measures werkend (HTTPS, token storage)

---

## 🚀 Stap 7: Standard Tier Aanvragen

Na succesvolle testing in Development tier kun je Standard tier aanvragen voor productie.

### Wanneer Aanvragen?

✅ **Klaar voor Standard tier als:**
- App volledig getest in Development
- OAuth flow werkt foutloos
- Security measures geïmplementeerd
- Privacy policy compleet
- Terms of Service geaccepteerd
- Klaar voor productie deployment

### Proces

1. **Ga naar Products Tab**
   - Selecteer je product
   - Klik "Request Standard Access"

2. **Vul Production Details In**
   - Production website URL
   - Verwacht aantal gebruikers
   - Launch datum
   - Deployment plan

3. **Submit Request**
   - LinkedIn review neemt 1-2 weken
   - Ze checken: functionality, security, policy compliance

4. **Na Goedkeuring**
   - ✅ Standard tier actief
   - ✅ Volledige rate limits
   - ✅ Productie deployment toegestaan

---

## ⏱️ Tijdlijn & Verwachtingen

| Fase | Duur | Wat gebeurt er? |
|------|------|-----------------|
| **App Aanmaken** | 5-10 min | Direct actief |
| **Company Verification** | 1-3 dagen | Admin moet bevestigen |
| **Product Aanvraag (Development)** | 7-14 dagen | LinkedIn review |
| **Testing in Development** | 1-4 weken | Jouw testing fase |
| **Standard Tier Aanvraag** | 7-14 dagen | LinkedIn review |
| **Totaal (Development → Production)** | **3-8 weken** | - |

---

## 🚨 Veelgemaakte Fouten

### ❌ Fout 1: Geen Company Page Admin
**Probleem:** Je kunt geen app maken zonder Admin rechten
**Oplossing:** Vraag Company Page Admin om je Super Admin rechten te geven

### ❌ Fout 2: Vage Use Case Beschrijving
**Probleem:** "We willen LinkedIn integratie" is te vaag
**Oplossing:** Wees specifiek: welke features, welke data, waarom nodig?

### ❌ Fout 3: Te Snel naar Production
**Probleem:** Standard tier aanvragen zonder goede testing
**Oplossing:** Test minimaal 2 weken in Development tier

### ❌ Fout 4: OAuth Redirect URI Mismatch
**Probleem:** Redirect URI in code ≠ URI in app settings
**Oplossing:** Check exact match (inclusief https://, trailing slash, etc.)

### ❌ Fout 5: Rate Limiting Vergeten
**Probleem:** Te veel API calls → banned
**Oplossing:** Implementeer rate limiting en backoff strategy

---

## 📊 Rate Limits (Standard Tier)

### API Call Limits

| Product | Limit per App | Limit per User |
|---------|---------------|----------------|
| **Community Management** | 500 calls/dag | 100 calls/dag |
| **Advertising API** | 1000 calls/dag | 200 calls/dag |
| **Lead Sync** | Onbeperkt | - |

**Throttling:**
- Max 100 calls per gebruiker per 24 uur
- Exponential backoff bij rate limit errors
- HTTP 429 response bij overschrijding

### Best Practices

✅ **Implementeer:**
- Cache voor niet-wijzigende data
- Batch requests waar mogelijk
- Exponential backoff retry logic
- Monitoring voor rate limit warnings

---

## 🔐 Security Checklist

### OAuth Best Practices
- [ ] HTTPS verplicht voor redirect URIs
- [ ] State parameter gebruikt voor CSRF protection
- [ ] Tokens veilig opgeslagen (encrypted at rest)
- [ ] Token refresh geïmplementeerd
- [ ] Access tokens vervallen na 60 dagen

### Data Privacy
- [ ] Alleen minimale scopes gevraagd
- [ ] Privacy policy compleet en publiek
- [ ] Data retention policy gedocumenteerd
- [ ] Gebruiker kan data verwijderen
- [ ] GDPR compliant (voor EU gebruikers)

---

## 📞 Support & Hulp

### LinkedIn Developer Support

**Documentation:**
- https://learn.microsoft.com/en-us/linkedin/

**Support:**
- https://www.linkedin.com/help/linkedin/answer/a526048
- Community forum voor developers

**Partner Support:**
- Beschikbaar voor paid API products
- Enterprise support voor grote implementaties

### Status Check

**App Status:**
- Dashboard → Products → Status per product
- Email notificaties bij statuswijzigingen

**API Status:**
- Status page voor API outages
- Twitter @LinkedInDev voor updates

---

## ✅ Complete Checklist

### Voor je Start:
- [ ] LinkedIn Company Page bestaat
- [ ] Je bent Super Admin van Company Page
- [ ] Business email met company domain
- [ ] Duidelijke use case gedefinieerd

### App Setup:
- [ ] App aangemaakt in developer portal
- [ ] App logo geupload (300x300px)
- [ ] Privacy policy URL ingevuld
- [ ] OAuth redirect URIs geconfigureerd

### Company Verification:
- [ ] Verificatie aangevraagd
- [ ] Admin heeft bevestigd
- [ ] "Verified" badge zichtbaar

### API Products:
- [ ] Juiste products geselecteerd
- [ ] Use case beschrijving compleet
- [ ] Data usage uitgelegd
- [ ] Development tier goedgekeurd

### Testing:
- [ ] OAuth flow getest
- [ ] API calls getest
- [ ] Error handling getest
- [ ] Rate limiting geïmplementeerd
- [ ] Security measures actief

### Production:
- [ ] Standard tier aangevraagd
- [ ] Standard tier goedgekeurd
- [ ] Production deployment plan klaar
- [ ] Monitoring setup
- [ ] Support plan actief

---

## 📚 Belangrijke Links

**Developer Portal:**
https://developer.linkedin.com/

**API Documentation:**
https://learn.microsoft.com/en-us/linkedin/

**OAuth Guide:**
https://learn.microsoft.com/en-us/linkedin/shared/authentication/getting-access

**Products Overview:**
https://learn.microsoft.com/en-us/linkedin/marketing/

**Support:**
https://www.linkedin.com/help/linkedin/answer/a526048

**Community:**
LinkedIn Developer Community (via LinkedIn groups)

---

**Document Versie:** 1.0
**Laatst Bijgewerkt:** 8 februari 2026
**Geschikt voor:** LinkedIn Marketing Solutions, Company Pages, Professional Profiles
