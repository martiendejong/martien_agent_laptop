# WhatsApp Integration - Baileys

**CRITICAL: ALWAYS USE BAILEYS** (NOT whatsapp-web.js)

**Date Established:** 2026-02-16
**Status:** ✅ Working and tested
**Library:** @whiskeysockets/baileys (same as ClawBot)

---

## Why Baileys?

**Attempted libraries:**
1. ❌ whatsapp-web.js - Messages reported "sent" but never arrived
2. ✅ Baileys - Actually works, messages deliver reliably

**Proof:** Successfully sent messages to:
- User's own number (31633984381)
- Diko (+254 741 470643) - CodeHub PDF notification
- Frank (+254 715 438010) - Test message

---

## Installation

```bash
cd C:\scripts\tools
npm install @whiskeysockets/baileys qrcode qrcode-terminal @hapi/boom
```

**Dependencies:**
- `@whiskeysockets/baileys` - WhatsApp Web API
- `qrcode` - QR code image generation
- `qrcode-terminal` - Terminal QR display
- `@hapi/boom` - Error handling

---

## Session Storage

**Location:** `C:\scripts\_machine\baileys-session\`

**Contents:**
- `creds.json` - Authentication credentials
- `app-state-sync-*.json` - Session state
- Various cache files

**Persistence:** Session survives restarts - no need to re-scan QR after initial setup

**Session conflicts:** Only ONE Baileys session can be active at a time
- Browser session blocks command-line session
- Use `TaskStop` to close browser session before command-line use

---

## Scripts

### 1. Command-line Messaging

**File:** `C:\scripts\tools\whatsapp-baileys.js`

**Usage:**
```bash
# Initialize (show QR in terminal)
node whatsapp-baileys.js init

# Send message
node whatsapp-baileys.js send <number> <message>

# Examples
node whatsapp-baileys.js send "+31633984381" "Test message"
node whatsapp-baileys.js send "0633984381" "Dutch number"
node whatsapp-baileys.js send "+254741470643" "Kenya number"
```

### 2. Browser QR Display

**File:** `C:\scripts\tools\whatsapp-baileys-browser.js`

**Usage:**
```bash
node whatsapp-baileys-browser.js
```

**What it does:**
- Generates QR code as PNG image
- Creates HTML page with styled QR display
- Opens in default browser automatically
- Sends test message to user after connection
- Keeps connection alive (background process)

**Output files:**
- `C:\jengo\documents\temp\baileys-qr.png`
- `C:\jengo\documents\temp\baileys-qr.html`

---

## Phone Number Formatting

### Format Rules

**Netherlands (country code 31):**
- Input: `0633984381` (local format with leading 0)
- Output: `31633984381@s.whatsapp.net`
- Remove leading 0, add country code 31

**Kenya (country code 254):**
- Input: `+254 741 470643` (with + and spaces)
- Output: `254741470643@s.whatsapp.net`
- Remove +, remove spaces, keep country code

**General:**
- Baileys internal format: `{country_code}{number}@s.whatsapp.net`
- Script handles formatting automatically
- Works with: `+31633984381`, `31633984381`, `0633984381`

### Auto-formatting Logic (in code)

```javascript
let formatted = phoneNumber.replace(/\D/g, ''); // Remove non-digits

// Remove leading + if present
if (phoneNumber.startsWith('+')) {
    formatted = phoneNumber.substring(1).replace(/\D/g, '');
}

// For Netherlands numbers starting with 0, add country code
if (formatted.startsWith('0') && formatted.length === 10) {
    formatted = '31' + formatted.substring(1);
}

const jid = formatted + '@s.whatsapp.net';
```

---

## PowerShell Wrapper

**File:** `C:\scripts\tools\whatsapp.ps1`

**Usage:**
```powershell
whatsapp.ps1 send "+31633984381" "Test message"
```

**Status:** ⚠️ Currently wraps whatsapp-bridge.js (old library)
**TODO:** Update to wrap whatsapp-baileys.js instead

---

## Common Contacts

**See full contacts list:** `C:\scripts\docs\WHATSAPP_CONTACTS.md`

| Name | Number | Formatted | Country |
|------|--------|-----------|---------|
| Marti (user) | 0633984381 | 31633984381 | Netherlands |
| Sofy (wife) | +254 718 130265 | 254718130265 | Kenya |
| Diko | +254 741 470643 | 254741470643 | Kenya |
| Frank | +254 715 438010 | 254715438010 | Kenya |

---

## Troubleshooting

### Issue: "Connection Closed" error

**Cause:** Multiple Baileys sessions trying to use same auth

**Solution:**
```bash
# Check for running sessions
# Look for node processes running whatsapp-baileys scripts

# Stop browser session if running
TaskStop <task_id>

# Then send message via command-line
node whatsapp-baileys.js send <number> <message>
```

### Issue: "Stream Errored (conflict)"

**Cause:** Session conflict warnings (not fatal)

**Solution:** Ignore warnings, check final output for "Message sent successfully"

### Issue: Messages not arriving

**Check:**
1. Is the number correct?
2. Is the number registered on WhatsApp?
3. Check your WhatsApp on phone - message should be in that contact's chat
4. Messages appear in the conversation, NOT in a separate "Sent" folder

---

## Session Management

### Initialize Fresh Session

```bash
# Delete old session
rm -rf C:\scripts\_machine\baileys-session

# Start browser QR
node whatsapp-baileys-browser.js

# Scan QR code with phone
```

### Check Session Status

Session is active if:
- `C:\scripts\_machine\baileys-session\creds.json` exists
- File is less than ~7 days old
- Can send messages without re-scanning QR

### Re-authenticate

If messages fail consistently:
1. Delete session directory
2. Run browser QR script
3. Scan QR code again

---

## Integration Examples

### Send WhatsApp after Email

```bash
# Send email (existing SMTP script)
# Then notify via WhatsApp
node whatsapp-baileys.js send "+254741470643" "Check your email - I sent you the PDF!"
```

### Automated Notifications

```powershell
# After creating PR
gh pr create --title "Feature" --body "Description"
$pr_url = gh pr view --json url -q '.url'

# Notify team via WhatsApp
node whatsapp-baileys.js send "+254741470643" "New PR ready: $pr_url"
```

---

## Future Enhancements

### Planned Features

1. **Receive Messages:** Listen for incoming messages and respond
2. **Group Messaging:** Send to WhatsApp groups
3. **Media Support:** Send images, PDFs, documents
4. **Message Queue:** Background service for queued messages
5. **Status Updates:** Read/delivery receipts

### Integration with Consciousness System

```powershell
# On task completion
consciousness-bridge.ps1 -Action OnTaskEnd -Outcome "success"

# If user prefers WhatsApp notifications
node whatsapp-baileys.js send $USER_NUMBER "Task completed: $TASK_NAME"
```

---

## Code Snippets

### Check if Session Exists

```bash
if [ -f "C:\scripts\_machine\baileys-session\creds.json" ]; then
    echo "Session exists, ready to send"
else
    echo "No session, need to scan QR"
fi
```

### Send with Error Handling

```bash
output=$(node whatsapp-baileys.js send "$NUMBER" "$MESSAGE" 2>&1)

if echo "$output" | grep -q "Message sent successfully"; then
    echo "✓ Delivered"
else
    echo "✗ Failed: $output"
fi
```

---

## Architecture Notes

**Why Baileys works better than whatsapp-web.js:**

1. **Different protocol implementation** - Baileys uses a more robust WebSocket handler
2. **Better session management** - Multi-file auth state vs single file
3. **Active maintenance** - WhiskeySockets/Baileys is actively maintained
4. **Proven in production** - Used by ClawBot and other projects

**Key difference:**
- whatsapp-web.js uses Puppeteer to control Chrome browser
- Baileys uses direct WebSocket connection to WhatsApp servers
- Result: Less overhead, more reliable, faster

---

**Last Updated:** 2026-02-16
**Tested:** ✅ Netherlands and Kenya numbers
**Status:** Production-ready
