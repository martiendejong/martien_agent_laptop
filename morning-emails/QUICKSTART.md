# Morning Email Briefing - Quick Start

Get up and running in 5 minutes.

## Prerequisites

- ✅ Node.js installed
- ✅ Python installed (optional, for better voice quality)
- ✅ Gmail account
- ✅ Windows 10/11

## Installation

### Option 1: Automated Setup (Recommended)

```powershell
cd C:\scripts\morning-emails
.\quick-setup.ps1
```

This interactive script will:
- Install all dependencies
- Guide you through OAuth setup
- Test the system
- Register the scheduled task

### Option 2: Manual Setup

**1. Install dependencies:**
```powershell
npm install
pip install edge-tts  # Optional but recommended
```

**2. Configure Gmail OAuth:**

Copy `.env.example` to `.env` and edit paths if needed.

**3. Set up OAuth credentials:**

```powershell
node setup-oauth.js
```

Follow the URL, authorize, and paste the code.

**4. Test:**

```powershell
.\morning-briefing.ps1 -Test -Silent
```

**5. Register scheduled task (run as admin):**

```powershell
.\register-scheduled-task.ps1
```

## First Test

```powershell
# Test without speech
.\morning-briefing.ps1 -Test -Silent

# Test with speech
.\morning-briefing.ps1 -Test

# Force run (bypass once-per-day check)
.\morning-briefing.ps1 -Force
```

## OAuth Credentials Setup

### If you already have Gmail MCP credentials:

Edit `.env`:
```env
GMAIL_CREDENTIALS_PATH=C:\path\to\gmail-mcp\credentials.json
GMAIL_TOKEN_PATH=C:\path\to\gmail-mcp\token.json
```

### If you need new credentials:

1. Go to https://console.cloud.google.com/
2. Create a new project
3. Enable "Gmail API"
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
5. Application type: "Desktop app"
6. Download JSON
7. Save as `C:\scripts\morning-emails\credentials.json`
8. Run: `node setup-oauth.js`

## Troubleshooting

### "Token file not found"
```powershell
node setup-oauth.js
```

### "edge-tts not installed"
```powershell
pip install edge-tts
```
System will fallback to Windows TTS if edge-tts not available.

### "Already ran today"
```powershell
.\morning-briefing.ps1 -Force
```

### Check logs
```powershell
Get-Content briefing.log -Tail 20
```

### Test TTS
```powershell
.\test-tts.ps1
```

## Daily Usage

Once registered, the briefing runs automatically on first login each day.

**Manual run:**
```powershell
.\morning-briefing.ps1
```

**Silent mode (no speech):**
```powershell
.\morning-briefing.ps1 -Silent
```

## What Gets Filtered

The system automatically filters:
- ClickUp notifications you triggered yourself
- Automated code reviews (codecov, dependabot, github-actions)
- Auto-migration notices
- Build status notifications

## Customization

### Add custom filters

Edit `fetch-emails.js`:
```javascript
const NOISE_FILTERS = {
  myFilter: (email) => {
    return email.subject.includes('unwanted keyword');
  }
};
```

### Change voice

Edit `speak-summary.py`:
```python
VOICE = "en-US-JennyNeural"  # Different voice
```

Available voices:
- `en-US-AriaNeural` (default, Siri-like)
- `en-US-GuyNeural` (male)
- `en-US-JennyNeural` (female)
- `en-US-ChristopherNeural` (male)
- `en-GB-LibbyNeural` (British female)

### Adjust speech speed

```python
RATE = "+10%"  # 10% faster
RATE = "-10%"  # 10% slower
```

## Files Overview

| File | Purpose |
|------|---------|
| `morning-briefing.ps1` | Main orchestrator |
| `fetch-emails.js` | Gmail API integration |
| `speak-summary.py` | TTS engine |
| `setup-oauth.js` | One-time OAuth setup |
| `register-scheduled-task.ps1` | Task scheduler registration |
| `quick-setup.ps1` | Interactive setup wizard |
| `test-tts.ps1` | TTS functionality test |
| `.env` | Configuration (create from .env.example) |
| `README.md` | Full documentation |

## Getting Help

See `README.md` for complete documentation.

Check logs:
```powershell
Get-Content briefing.log -Tail 50
```

---

**Created:** 2026-02-07
**Author:** Jengo (Claude Agent)
