# Morning Email Briefing System

Automated morning email briefing that fetches Gmail, filters noise, and speaks a summary using natural TTS.

## Features

- ✅ Fetches unread Gmail emails using Gmail API
- ✅ Filters automated noise (ClickUp self-notifications, auto-reviews, migrations)
- ✅ Generates natural language summary
- ✅ Speaks summary using edge-tts (en-US-AriaNeural voice)
- ✅ Fallback to Windows System.Speech TTS
- ✅ Runs once per day on Windows login (Task Scheduler)
- ✅ Comprehensive logging

## Setup

### 1. Install Dependencies

```powershell
# Install Node.js dependencies
cd C:\scripts\morning-emails
npm install

# Install Python edge-tts (optional but recommended)
pip install edge-tts
```

### 2. Configure Gmail OAuth

**Option A: Use existing Gmail MCP credentials**

If you have Gmail MCP configured, edit `.env`:

```env
GMAIL_CREDENTIALS_PATH=C:\path\to\gmail-mcp\credentials.json
GMAIL_TOKEN_PATH=C:\path\to\gmail-mcp\token.json
```

**Option B: Create new OAuth credentials**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project or select existing
3. Enable Gmail API
4. Create OAuth 2.0 credentials (Desktop app type)
5. Download JSON and save as `C:\scripts\morning-emails\credentials.json`

Then run setup:

```powershell
node setup-oauth.js
```

Follow the URL, authorize, and paste the code back.

### 3. Test the System

```powershell
# Test in silent mode (no speech)
.\morning-briefing.ps1 -Test -Silent

# Test with speech
.\morning-briefing.ps1 -Test
```

### 4. Register Scheduled Task

```powershell
# Run as administrator
.\register-scheduled-task.ps1
```

This creates a scheduled task `MorningEmailBriefing` that runs on login.

## Usage

### Manual Run

```powershell
# Normal run (once per day)
.\morning-briefing.ps1

# Force run (ignore once-per-day check)
.\morning-briefing.ps1 -Force

# Silent mode (no speech)
.\morning-briefing.ps1 -Silent
```

### Automatic Run

Once the scheduled task is registered, the briefing runs automatically on the first login of each day.

## Files

- `package.json` - Node.js dependencies
- `fetch-emails.js` - Gmail API integration and filtering
- `speak-summary.py` - edge-tts speech synthesis
- `morning-briefing.ps1` - Main orchestrator
- `setup-oauth.js` - One-time OAuth setup
- `register-scheduled-task.ps1` - Scheduled task registration
- `.env` - Configuration (create from .env.example)
- `briefing.log` - Execution log
- `last-run.txt` - Last run timestamp
- `summary.txt` - Generated summary (temporary)
- `token.json` - OAuth token (generated)

## Noise Filtering

The system filters:

- **ClickUp self-notifications** - Notifications triggered by your own actions
- **Automated code reviews** - codecov, dependabot, github-actions
- **Auto-migrations** - Database migration notices

## TTS Voices

- **Primary**: edge-tts with `en-US-AriaNeural` (Siri-like)
- **Fallback**: Windows System.Speech

## Troubleshooting

### "Token file not found"

Run OAuth setup:
```powershell
node setup-oauth.js
```

### "edge-tts not installed"

Install Python package:
```powershell
pip install edge-tts
```

System will fallback to Windows TTS if edge-tts unavailable.

### "Already ran today"

Use `-Force` to bypass once-per-day check:
```powershell
.\morning-briefing.ps1 -Force
```

### Check logs

```powershell
Get-Content briefing.log -Tail 50
```

## Architecture

```
morning-briefing.ps1 (orchestrator)
├── fetch-emails.js (Node.js)
│   ├── Load OAuth credentials
│   ├── Fetch unread Gmail messages
│   ├── Filter automated noise
│   ├── Generate natural language summary
│   └── Write summary.txt
└── speak-summary.py (Python)
    ├── Read summary.txt
    ├── Try edge-tts (en-US-AriaNeural)
    └── Fallback to Windows System.Speech
```

## Customization

### Modify noise filters

Edit `NOISE_FILTERS` in `fetch-emails.js`:

```javascript
const NOISE_FILTERS = {
  myCustomFilter: (email) => {
    return email.subject.includes('unwanted keyword');
  }
};
```

### Change TTS voice

Edit `VOICE` in `speak-summary.py`:

```python
VOICE = "en-US-JennyNeural"  # Different voice
```

### Adjust speech rate/volume

```python
RATE = "+10%"  # Faster
VOLUME = "+20%"  # Louder
```

## License

MIT

---

**Created by:** Jengo (Claude Agent)
**Last Updated:** 2026-02-07
