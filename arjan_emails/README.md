# Arjan Emails - Email Archief

**Doel:** Verzamel alle email correspondentie met sleutelpersonen van het Social Media Hulp project voor context en analyse.

**Format:** Identiek aan `gemeente_emails/` - EML bestanden + JSON metadata

## 📬 Mailboxen

- **Gmail:** martiendejong2008@gmail.com
- **Zakelijk:** info@martiendejong.nl

## 👥 Contactpersonen

| Contact | Map | Email adressen |
|---------|-----|----------------|
| Social Media Hulp | `social_media_hulp/` | info@socialmediahulp.nl, socialmediahulp.nl |
| Arjan Stroeve | `arjan_stroeve/` | arjan@stroeve.nl, arjan.stroeve@ |
| Rinus Huisman (Socranext) | `rinus_socranext/` | rinushuisman@gmail.com, rinus@socranext.nl, socranext.nl |
| Allan Drenth | `allan_drenth/` | allan@drenth.nl, allan.drenth@ |
| ChatGPT Conversations | `chatgpt_conversations/` | (handmatig upload) |

## 🚀 Quick Start - Email Import

### Stap 1: Gmail API Setup (eenmalig)

1. **Google Cloud Console:**
   ```
   https://console.cloud.google.com/
   ```
   - Maak nieuw project of gebruik bestaand
   - Ga naar: APIs & Services > Library
   - Zoek "Gmail API" en klik "Enable"

2. **OAuth Credentials:**
   - Ga naar: APIs & Services > Credentials
   - Klik: "Create Credentials" > "OAuth client ID"
   - Application type: **Desktop app**
   - Name: "Arjan Email Import"
   - Download JSON → sla op als:
     ```
     C:\scripts\_machine\gmail-credentials.json
     ```

3. **Python Dependencies:**
   ```bash
   pip install google-auth-oauthlib google-auth google-api-python-client
   ```

### Stap 2: Import Uitvoeren

```bash
# Vanuit C:\scripts\tools:
python import-arjan-emails-v2.py
```

**Eerste run:**
- Browser opent automatisch voor OAuth toestemming
- Login met martiendejong2008@gmail.com
- Geef toestemming voor read-only toegang
- Token wordt opgeslagen in `C:\scripts\_machine\gmail-token.json`

**Volgende runs:**
- Gebruikt opgeslagen token
- Geen browser login meer nodig
- Token is 7 dagen geldig

### Stap 3: ChatGPT Conversations

Upload je ChatGPT exports handmatig naar:
```
C:\scripts\arjan_emails\chatgpt_conversations\
```

## 📁 Bestandsformaat

Elke email wordt opgeslagen als 2 bestanden:

### .EML bestand (volledige email)
```
martiendejong2008@gmail.com_2026-01-16__arjan@stroeve.nl__Re_ Project update.eml
```
- Bevat volledige email inclusief headers, body, attachments
- Kan geopend worden in Outlook, Thunderbird, etc.

### .JSON bestand (metadata)
```json
{
  "id": "18d1a2b3c4d5e6f7",
  "subject": "Re: Project update",
  "from": "Arjan Stroeve <arjan@stroeve.nl>",
  "to": "martiendejong2008@gmail.com",
  "date": "Thu, 16 Jan 2026 14:23:01 +0100"
}
```

## 🔍 Gezochte Email Adressen

Het script zoekt naar deze email adressen (FROM en TO):

**Social Media Hulp:**
- info@socialmediahulp.nl
- socialmediahulp.nl
- socialmediahulp
- social media hulp

**Arjan Stroeve:**
- arjan@stroeve.nl
- arjan.stroeve@
- arjanstroeve
- stroeve

**Rinus Huisman (Socranext):**
- rinushuisman@gmail.com
- rinus@socranext.nl
- socranext.nl
- socranext
- rinus huisman
- rinushuisman
- rinus

**Allan Drenth:**
- allan@drenth.nl
- allan.drenth@
- allandrenth
- drenth

**Mis je een email adres?** Update het in:
```
C:\scripts\tools\import-arjan-emails-v2.py
```
Zoek naar de `CONTACTS` dictionary en voeg toe.

## ⚙️ info@martiendejong.nl Setup

Voor import van info@martiendejong.nl:

1. **OAuth Credentials aanmaken** (zelfde als Gmail):
   - Login met info@martiendejong.nl Google account
   - Download credentials naar:
     ```
     C:\scripts\_machine\martiendejong-credentials.json
     ```

2. **Script aanpassen**:
   - Open: `C:\scripts\tools\import-arjan-emails-v2.py`
   - Regel ~217: Wijzig `accounts_to_import = ['gmail']`
   - Naar: `accounts_to_import = ['gmail', 'martiendejong']`

3. **Import uitvoeren**:
   ```bash
   python import-arjan-emails-v2.py
   ```

## 📊 Status

**Aangemaakt:** 2026-01-16
**Import status:** Klaar voor gebruik
**Format:** EML + JSON (identiek aan gemeente_emails)
**Tool:** `C:\scripts\tools\import-arjan-emails-v2.py`

## 🛠️ Troubleshooting

| Probleem | Oplossing |
|----------|-----------|
| "Credentials niet gevonden" | Controleer of `gmail-credentials.json` in `_machine/` staat |
| "pip: command not found" | Installeer Python vanaf python.org |
| "Module not found" | Run: `pip install google-auth-oauthlib google-auth google-api-python-client` |
| OAuth scherm blijft laden | Check firewall, gebruik localhost redirect |
| Geen emails gevonden | Controleer email adressen in `CONTACTS` dictionary |

## 💡 Tips

1. **Email adressen toevoegen:** Edit het Python script en voeg toe aan `CONTACTS`
2. **Maximaal 500 emails:** Per contactgroep, pas `maxResults` aan indien nodig
3. **Duplicate detection:** Script controleert op bestaande bestanden
4. **ChatGPT exports:** Gebruik plain text (.txt) of JSON format
