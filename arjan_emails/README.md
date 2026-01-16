# Arjan Emails - Email Archief

**Doel:** Verzamel alle email correspondentie met sleutelpersonen van het Social Media Hulp project voor context en analyse.

## Mailboxen

- **Gmail:** martiendejong2008@gmail.com
- **Zakelijk:** info@martiendejong.nl

## Contactpersonen

### 1. Social Media Hulp (algemeen)
- Locatie: `social_media_hulp/`
- Alle emails van/naar Social Media Hulp team

### 2. Arjan Stroeve
- Locatie: `arjan_stroeve/`
- Directe correspondentie met Arjan Stroeve

### 3. Rinus (Socranext)
- Locatie: `rinus_socranext/`
- Correspondentie met Rinus van Socranext

### 4. Allan Drenth
- Locatie: `allan_drenth/`
- Correspondentie met Allan Drenth

### 5. ChatGPT Conversations
- Locatie: `chatgpt_conversations/`
- Exports van ChatGPT gesprekken over dit project

## Status

**Aangemaakt:** 2026-01-16
**Import status:** Configuratie nodig (zie below)

## Email Import Setup Nodig

### Gmail (martiendejong2008@gmail.com)

**Optie A: Gmail MCP Server (Aanbevolen voor permanente toegang)**
1. Installeer Gmail MCP Server
2. Google OAuth configuratie
3. Automatische sync mogelijk

**Optie B: Google Takeout (Snel, eenmalig)**
1. Ga naar https://takeout.google.com
2. Selecteer alleen Gmail
3. Filter op specifieke contacten (indien mogelijk)
4. Download .mbox of .eml bestanden
5. Upload naar deze map

**Optie C: IMAP Script (Technisch)**
1. Enable IMAP in Gmail settings
2. App-specific password aanmaken
3. Python/PowerShell IMAP script

### info@martiendejong.nl

**Setup vereist:**
- Mailserver details (IMAP host, port)
- Credentials
- IMAP toegang enablen indien nodig

## Volgende Stappen

1. [ ] Kies email import methode
2. [ ] Configureer toegang
3. [ ] Importeer emails
4. [ ] Upload ChatGPT conversations
5. [ ] Indexeer en categoriseer
