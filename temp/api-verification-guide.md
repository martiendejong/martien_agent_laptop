# API Verification Guide - Facebook, LinkedIn, TikTok, Instagram

**Datum:** 8 februari 2026
**Doel:** Complete guide voor het doorlopen van API verificatie processen bij developer portals

---

## 🎯 Overzicht

Dit document beschrijft het volledige verificatieproces voor:
- ✅ **Facebook/Meta** - Business/Individual verification + App Review
- ✅ **LinkedIn** - Company verification + API Products
- ✅ **TikTok** - App submission + Audit
- ✅ **Instagram** - Via Meta platform + Business account
- ⚠️ **Medium** - API niet meer ondersteund (alleen beperkte Publishing API)

---

## 📱 1. FACEBOOK / META VERIFICATION

### Portal
🔗 **https://developers.facebook.com/**

### Verificatie Vereisten

#### Stap 1: Business Verification (Verplicht voor Advanced Access)
**Wat je nodig hebt:**
- Bedrijfsdocumentatie (KvK uittreksel, business license)
- Business email adres
- Website van het bedrijf
- Business phone number

**Proces:**
1. Ga naar [Meta Business Verification](https://developers.facebook.com/)
2. Selecteer je app in "My Apps"
3. Navigate naar "Business Verification" in linker menu
4. Upload business documentatie
5. Wacht op goedkeuring (kan enkele dagen duren)

**Alternative: Individual Verification**
- Alleen als je geen business bent
- Vereist ID upload
- **Let op:** Bepaalde permissions zijn beperkt of niet beschikbaar
- Niet geschikt voor productie apps met veel gebruikers

#### Stap 2: App Review - Permissions Request
**Wat je nodig hebt:**
- **Video walkthrough** voor elke permission die je aanvraagt
- Gedetailleerde uitleg waarom je elke permission nodig hebt
- Werkende prototype van je app
- Test credentials voor reviewers

**Belangrijke Permissions:**
- `pages_manage_posts` - Voor posting naar Facebook Pages
- `pages_read_engagement` - Voor analytics
- `instagram_basic` - Voor Instagram toegang
- `instagram_content_publish` - Voor Instagram posting
- `public_profile` - Basis gebruiker info
- `email` - Gebruiker email

**Proces:**
1. Ga naar "App Review" → "Permissions and Features"
2. Selecteer gewenste permissions
3. Voor elke permission:
   - Upload screen recording (max 10min)
   - Beschrijf use case in detail
   - Leg uit hoe data wordt gebruikt en opgeslagen
4. Submit voor review
5. Wacht op goedkeuring (2-14 dagen)

**⚠️ Let op: Standard Access vs Advanced Access**
- **Standard Access:** Zeer beperkt, alleen eigen ad accounts, strikte rate limits
- **Advanced Access:** Volledige functionaliteit, vereist Business Verification + App Review
- Je hebt ALTIJD Advanced Access nodig voor productie

**Bronnen:**
- [Facebook App Review Process](https://dancerscode.com/posts/navigating-the-facebook-app-review-process/)
- [Facebook Business Verification](https://www.loginradius.com/docs/authentication/identity-providers/social-login/app-reviews/facebook-app-review/)
- [Advanced Access Requirements](https://medium.com/@bilal.105.ahmed/facebook-marketing-api-the-advanced-access-trap-that-nearly-killed-my-project-7227ea2ee2c2)

---

## 💼 2. LINKEDIN VERIFICATION

### Portal
🔗 **https://developer.linkedin.com/**

### Verificatie Vereisten

#### Stap 1: Company Page Verification
**Wat je nodig hebt:**
- LinkedIn Company Page (moet bestaan en actief zijn)
- Super Admin rechten op de Company Page
- Business email die matcht met company domain

**Proces:**
1. Ga naar [LinkedIn Developer Portal](https://developer.linkedin.com/)
2. Selecteer "My Apps"
3. Create app of selecteer bestaande app
4. Ga naar "Settings" tab
5. Klik "Verify" bij Company Page
6. Stuur verificatie link naar Company Page administrator
7. Wacht op bevestiging

#### Stap 2: API Products Selecteren
**Available Products:**
- **Advertising API** (Mandatory voor andere APIs)
  - Development tier (start)
  - Standard tier (na review)
- **Community Management API**
  - Voor posting en engagement
  - Development/Standard tiers
- **Lead Sync API**
  - Voor lead generation
- **Conversions API**
  - Voor conversion tracking

**Proces:**
1. Ga naar "Products" tab in je app
2. Klik "+ Add product"
3. Selecteer gewenste products
4. Voor elk product:
   - Vul use case description in
   - Beschrijf waarom je toegang nodig hebt
   - Submit voor review
5. Wacht op goedkeuring (1-2 weken)

#### Stap 3: OAuth Scopes Configureren
**Belangrijke Scopes:**
- `r_emailaddress` - Gebruiker email
- `r_liteprofile` - Basis profiel info
- `w_member_social` - Posting namens gebruiker
- `w_organization_social` - Posting namens organization
- `r_organization_social` - Lezen organization content
- `rw_organization_admin` - Admin functies

**Proces:**
1. Ga naar "Auth" tab
2. Configureer OAuth 2.0 redirect URLs
3. Selecteer gewenste scopes
4. Test OAuth flow in Development tier

**⚠️ Access Tiers:**
- **Development:** Beperkt aantal API calls, alleen test accounts
- **Standard:** Volledige rate limits, productie gebruik

**Bronnen:**
- [LinkedIn API Access Guide](https://learn.microsoft.com/en-us/linkedin/shared/authentication/getting-access)
- [LinkedIn Products Overview](https://developer.linkedin.com/)
- [Increasing Access Tiers](https://learn.microsoft.com/en-us/linkedin/marketing/increasing-access?view=li-lms-2026-01)

---

## 🎵 3. TIKTOK VERIFICATION

### Portal
🔗 **https://developers.tiktok.com/**

### Verificatie Vereisten

#### Stap 1: Developer Account Aanmaken
**Wat je nodig hebt:**
- TikTok account (persoonlijk of business)
- Valid email address
- Business details (als je Business API wilt)

**Proces:**
1. Ga naar [TikTok for Developers](https://developers.tiktok.com/)
2. Click "Register" → "Get Started"
3. Vul business information in
4. Bevestig email

#### Stap 2: App Registratie
**Wat je nodig hebt:**
- **Voor mobile apps:** Link naar App Store / Google Play
- **Voor web apps:** Valid redirect URI
- Werkende prototype
- Clear use case beschrijving

**Proces:**
1. Ga naar "Manage apps" → "Create an app"
2. Vul app details in:
   - App name
   - App description
   - App type (Web/Android/iOS)
   - App store links (voor mobile)
3. Submit app information

#### Stap 3: API Permissions Aanvragen
**⚠️ Principe van Minimale Permissions:**
- Request ALLEEN permissions die je echt nodig hebt
- Voorbeeld: Als je alleen video's schedule, vraag geen analytics permissions

**Belangrijke Scopes:**
- `user.info.basic` - Basis gebruiker info
- `video.publish` - Video's posten
- `video.list` - Video's lijst ophalen
- `video.insights` - Video analytics

**Proces:**
1. Ga naar "Manage apps" → Select app → "Add products"
2. Select gewenste API products:
   - Login Kit
   - Share Kit
   - Content Posting API
3. Voor elke permission:
   - Schrijf gedetailleerde use case
   - Leg uit hoe je data gebruikt
   - Beschrijf data retention policy
4. Submit voor review
5. **Wachttijd: 5-14 dagen**

#### Stap 4: Testing & Audit
**⚠️ Belangrijk:**
- Alle content van unaudited apps is PRIVÉ
- Je moet audit doorlopen voor publieke zichtbaarheid

**Audit Proces:**
1. Test je integratie volledig in Development mode
2. Documenteer alle functies met screenshots/video's
3. Submit audit request via developer portal
4. TikTok controleert compliance met Terms of Service
5. Na goedkeuring: content wordt publiek zichtbaar

**Bronnen:**
- [TikTok API Getting Started](https://developers.tiktok.com/doc/getting-started-faq)
- [TikTok Developer Guide](https://getlate.dev/blog/tiktok-developer-api)
- [TikTok API Permissions](https://www.getphyllo.com/post/introduction-to-tiktok-api)

---

## 📸 4. INSTAGRAM VERIFICATION

### Portal
🔗 **https://developers.facebook.com/** (Instagram API via Meta platform)

### ⚠️ Belangrijk: Instagram = Meta Platform
Instagram API is onderdeel van Meta/Facebook. Je hebt GEEN apart Instagram developer account.

### Verificatie Vereisten

#### Stap 1: Prerequisites
**Wat je nodig hebt:**
- ✅ Meta Developer Account (zie Facebook sectie)
- ✅ **Instagram Business Account** (VERPLICHT)
- ✅ Instagram account linked aan een Facebook Page
- ✅ Business verification (zie Facebook sectie)

**Instagram Business Account Setup:**
1. Ga naar Instagram app → Settings → Account
2. Switch to "Professional Account"
3. Select "Business"
4. Link aan Facebook Page (Settings → Linked accounts → Facebook)

#### Stap 2: App Configuratie
**Proces:**
1. Ga naar je app op developers.facebook.com
2. Add "Instagram" product:
   - Dashboard → Products → Instagram → Set Up
3. Configureer OAuth redirect URIs
4. Voeg Instagram test users toe

#### Stap 3: Permissions Request (via Meta App Review)
**Belangrijke Permissions:**
- `instagram_basic` - Profiel info + media
- `instagram_content_publish` - Posten van content
- `instagram_manage_comments` - Comments beheren
- `instagram_manage_insights` - Analytics
- `pages_show_list` - Linked Pages
- `pages_read_engagement` - Page engagement data

**Proces:**
1. Ga naar "App Review" in Meta dashboard
2. Request Instagram permissions (zie Facebook sectie voor details)
3. Voor ELKE permission:
   - Upload video walkthrough
   - Toon exact hoe Instagram data gebruikt wordt
   - Leg privacy/security measures uit
4. Submit voor review
5. Wacht op goedkeuring (2-14 dagen)

#### Stap 4: API Keuze
**Instagram Graph API (Recommended):**
- Volledige functionaliteit
- Business accounts only
- Via Facebook integration

**Instagram Basic Display API (Legacy):**
- Beperkt tot media display
- Personal accounts
- Wordt uitgefaseerd

**⚠️ Rate Limits:**
- 200 API calls per uur per Instagram account
- Schaalt lineair met aantal connected accounts

**Bronnen:**
- [Instagram Graph API Guide](https://elfsight.com/blog/instagram-graph-api-complete-developer-guide-for-2026/)
- [Instagram Developer Guide](https://getlate.dev/blog/instagram-api)
- [Instagram Business Requirements](https://www.getphyllo.com/post/instagram-graph-apis-what-are-they-and-how-do-developers-access-them)

---

## ✍️ 5. MEDIUM (⚠️ NIET ONDERSTEUND)

### Status
🔴 **Medium API is officieel niet meer ondersteund sinds maart 2023**

### Wat er nog beschikbaar is
**Publishing API (Beperkt):**
- URL: `https://api.medium.com/v1/`
- Functionaliteit: Alleen artikelen posten
- Geen read/analytics functionaliteit
- Hidden in settings, maar wel beschikbaar

**Integration Token verkrijgen:**
1. Log in op medium.com
2. Ga naar Settings → Security and apps → Integration tokens
3. Generate new token
4. Token heeft write-only access

**API Documentation:**
- GitHub repo: https://github.com/Medium/medium-api-docs (archived)
- Basic endpoints nog steeds werkzaam maar UNSUPPORTED
- Geen garantie op uptime of functionaliteit

### Alternatieven
**Unofficial APIs:**
- MediumAPI.com (unofficial, paid service)
- Web scraping (niet aangeraden, tegen ToS)

**⚠️ Aanbeveling:**
Gebruik Medium NIET voor productie integrations. De API is deprecated en kan elk moment volledig verdwijnen.

**Bronnen:**
- [Medium API Status](https://www.marktinderholt.com/social%20media/2024/12/13/medium-rare-api.html)
- [Medium API Documentation (Archived)](https://github.com/Medium/medium-api-docs)

---

## 📋 SAMENVATTING - VERIFICATIE CHECKLIST

### Facebook/Meta
- [ ] Business verification aanvragen (of Individual als fallback)
- [ ] App aanmaken in developers.facebook.com
- [ ] Voor elke permission: video walkthrough maken
- [ ] App Review submission met gedetailleerde use cases
- [ ] Wachten op goedkeuring (2-14 dagen)
- [ ] Advanced Access verkrijgen voor productie

### LinkedIn
- [ ] LinkedIn Company Page hebben en Admin rechten
- [ ] App aanmaken in developer.linkedin.com
- [ ] Company Page verification doorlopen
- [ ] API Products selecteren (start met Advertising API)
- [ ] OAuth redirect URIs configureren
- [ ] Development tier testen
- [ ] Standard tier aanvragen voor productie

### TikTok
- [ ] Developer account aanmaken
- [ ] App registreren (met store links voor mobile)
- [ ] Werkende prototype bouwen
- [ ] Minimale permissions selecteren
- [ ] Gedetailleerde use case per permission schrijven
- [ ] App submission (wacht 5-14 dagen)
- [ ] Integratie testen in Development mode
- [ ] Audit aanvragen voor publieke content

### Instagram
- [ ] Instagram Business Account aanmaken
- [ ] Instagram linken aan Facebook Page
- [ ] Meta Business Verification (zie Facebook)
- [ ] Instagram product toevoegen in Meta app
- [ ] Test users configureren
- [ ] Permissions aanvragen via Meta App Review
- [ ] Video walkthroughs maken per permission
- [ ] Goedkeuring afwachten (2-14 dagen)

### Medium
- [ ] ⚠️ Overweeg NIET te gebruiken (API deprecated)
- [ ] Als toch nodig: Integration token genereren in settings
- [ ] Let op: alleen Publishing API, geen read/analytics
- [ ] Geen verificatie proces (unsupported)

---

## ⏱️ VERWACHTE DOORLOOPTIJDEN

| Platform | Verificatie | App Review | Totaal |
|----------|-------------|------------|---------|
| **Facebook** | 3-7 dagen | 2-14 dagen | **5-21 dagen** |
| **LinkedIn** | 1-3 dagen | 7-14 dagen | **8-17 dagen** |
| **TikTok** | N/A | 5-14 dagen + audit | **10-21 dagen** |
| **Instagram** | Via Facebook | Via Facebook | **5-21 dagen** |
| **Medium** | N/A | N/A | **Instant (maar limited)** |

---

## 🚨 BELANGRIJKE AANDACHTSPUNTEN

### 1. Privacy & Data Handling
**Alle platforms vragen:**
- Hoe worden user data opgeslagen?
- Wordt data gedeeld met derden?
- Hoe lang bewaar je data?
- Wat zijn je security measures?

**Best Practice:**
- Vraag minimale permissions
- Document data retention policy
- Implement proper security (HTTPS, encryption, etc.)
- Wees transparant in je use case beschrijvingen

### 2. Video Walkthroughs (Facebook/Instagram)
**Tips voor goede walkthroughs:**
- ✅ Laat complete user flow zien (login → permission grant → gebruik)
- ✅ Toon exact waar data verschijnt in je app
- ✅ Demonstreer security measures
- ✅ Gebruik test accounts (niet productie data)
- ✅ Max 10 minuten per permission
- ❌ Geen muziek of voice-over nodig
- ❌ Geen hoge productiewaarde vereist (screen recording is genoeg)

### 3. Business Verification Documents
**Acceptabele documenten:**
- KvK uittreksel (Nederland)
- Business license
- Tax registration documents
- Articles of incorporation

**Tips:**
- ✅ Documenten moeten recent zijn (<6 maanden)
- ✅ Business naam moet exact matchen in alle documenten
- ✅ Upload duidelijke scans/foto's (geen smartphone foto's met slechte belichting)
- ✅ Heb business email met eigen domein (@bedrijfsnaam.nl, niet @gmail.com)

### 4. Test Accounts & Credentials
**Alle platforms vragen:**
- Test credentials voor reviewers
- Werkende demo environment
- Gedetailleerde testing instructies

**Best Practice:**
- Maak dedicated test accounts
- Document login proces helder
- Geef reviewers volledige toegang (niet expired tokens)
- Test zelf eerst volledig voordat je submit

---

## 📞 SUPPORT & RESOURCES

### Facebook/Meta
- Developer Support: https://developers.facebook.com/support/
- Community Forum: https://developers.facebook.com/community/
- App Review Status: Check in App Dashboard

### LinkedIn
- Developer Support: https://www.linkedin.com/help/linkedin/answer/a526048
- Microsoft Learn Docs: https://learn.microsoft.com/en-us/linkedin/
- Partner Support (voor paid products)

### TikTok
- Developer Support: https://developers.tiktok.com/support
- FAQ: https://developers.tiktok.com/doc/getting-started-faq
- Community: Developer forum in portal

### Instagram
- Zie Facebook/Meta (zelfde platform)
- Instagram-specific docs: https://developers.facebook.com/docs/instagram

---

## ✅ VOLGENDE STAPPEN

Na verificatie:
1. ✅ Sla alle credentials veilig op (API keys, secrets, tokens)
2. ✅ Configureer OAuth flows in je applicatie
3. ✅ Implementeer rate limit handling
4. ✅ Setup monitoring voor API errors
5. ✅ Test uitgebreid in development/staging
6. ✅ Plan deployment naar productie

**Let op:** Na goedkeuring moet je binnen bepaalde tijd (meestal 90 dagen) de integratie live hebben, anders vervalt de toegang.

---

**Document versie:** 1.0
**Laatst bijgewerkt:** 8 februari 2026
**Auteur:** Jengo (Claude Agent)

**Bronnen:**
- [Facebook App Review](https://dancerscode.com/posts/navigating-the-facebook-app-review-process/)
- [LinkedIn API Access](https://learn.microsoft.com/en-us/linkedin/shared/authentication/getting-access)
- [TikTok Developer Guide](https://getlate.dev/blog/tiktok-developer-api)
- [Instagram Graph API](https://elfsight.com/blog/instagram-graph-api-complete-developer-guide-for-2026/)
- [Medium API Status](https://www.marktinderholt.com/social%20media/2024/12/13/medium-rare-api.html)
