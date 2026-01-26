# YouTube Data API v3 Setup Guide

## Quick Setup (5 minuten)

### Stap 1: Google Cloud Console

1. Ga naar: https://console.cloud.google.com/
2. Log in met je Google account
3. Klik **"Select a project"** (bovenaan) → **"New Project"**
4. Project naam: `world-dashboard-youtube`
5. Klik **Create**

### Stap 2: Enable YouTube Data API v3

1. In Google Cloud Console, ga naar: **APIs & Services** → **Library**
2. Zoek: `YouTube Data API v3`
3. Klik op het resultaat
4. Klik **ENABLE**

### Stap 3: Create API Key

1. Ga naar: **APIs & Services** → **Credentials**
2. Klik **+ CREATE CREDENTIALS** (bovenaan)
3. Selecteer **API key**
4. API key wordt gegenereerd (bijvoorbeeld: `AIzaSyC-abcd1234efgh5678ijkl...`)
5. **KOPIEER DE KEY** (je hebt hem zo nodig)

### Stap 4: Restrict API Key (Beveiliging)

1. Klik op de potlood icon naast je nieuwe API key
2. **Application restrictions:**
   - Selecteer: **IP addresses**
   - Add: `127.0.0.1` (localhost)
   - Add: Je eigen IP adres (optioneel)
3. **API restrictions:**
   - Selecteer: **Restrict key**
   - Vink aan: **YouTube Data API v3**
4. Klik **SAVE**

### Stap 5: Add to Secrets File

Open: `C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json`

Voeg toe onder `ApiSettings`:

```json
{
  "ApiSettings": {
    "OpenApiKey": "sk-svcacct-...",
    "YouTubeApiKey": "AIzaSyC-YOUR-KEY-HERE",
    ...
  }
}
```

### Stap 6: Test het Script

```powershell
# Test met 1 query
$apiKey = (Get-Content "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json" | ConvertFrom-Json).ApiSettings.YouTubeApiKey

.\youtube-video-finder.ps1 -ApiKey $apiKey -Queries @("AI tutorial 2026") -MaxResults 3

# Als het werkt, zie je video URLs en titels!
```

---

## Quota Limits

**Gratis tier:** 10,000 units per dag

**Costs per query:**
- Search: 100 units
- Je kunt dus **100 searches per dag gratis doen**

**Dashboard gebruikt:** ~10 queries per dag = 1,000 units = **ruim binnen gratis tier!**

---

## Troubleshooting

### Error: "API key not valid"
→ Check of je YouTube Data API v3 hebt enabled (Stap 2)

### Error: "Daily quota exceeded"
→ Je hebt 10,000 units gebruikt. Reset morgen.
→ Reduce MaxResults in script (van 5 naar 3)

### Error: "API key restrictions"
→ Check of je IP adres is toegestaan (Stap 4)

---

## Volgende Stap

Als API key werkt, run:
```powershell
.\world-dashboard-with-youtube.ps1
```

Dit integreert automatisch YouTube videos in je dashboard!
