# WhatsApp EventBus Integration

Complete integration system for polling WhatsApp messages and publishing them to the EventBus API.

## Architecture

```
WhatsApp API (whatsapp.wreckingball.ai)
         ↓
   Poller Script (PowerShell)
   - Runs every 5 minutes
   - Tracks processed messages
   - Filters new messages
         ↓
   DataDrivenAI EventOrchestrator
   - POST /api/events
   - Event-driven architecture
   - Agent subscription system
         ↓
   Event Agents (subscribe to events)
   - AI processing
   - Auto-reply
   - Data extraction
   - Custom workflows
```

## Components

### 1. WhatsApp Poller Script
**File:** `C:\scripts\tools\whatsapp-eventbus-poller.ps1`

Polls WhatsApp API and posts new messages to EventBus.

**Features:**
- State tracking (prevents duplicate processing)
- Configurable lookback window (default: 10 minutes)
- Automatic credential retrieval from vault
- Filtering for active chats only
- Batch event posting
- Silent mode for scheduled tasks

**Usage:**
```powershell
# Manual test run
.\whatsapp-eventbus-poller.ps1

# Silent mode (for scheduled task)
.\whatsapp-eventbus-poller.ps1 -Silent

# Custom lookback window
.\whatsapp-eventbus-poller.ps1 -LookbackMinutes 30

# Custom EventBus URL
.\whatsapp-eventbus-poller.ps1 -EventBusUrl "http://localhost:5000/api/events/whatsapp"
```

**State File:** `C:\scripts\_machine\whatsapp-poller-state.json`
```json
{
  "lastPollTime": "2026-02-22T20:00:00Z",
  "processedMessageIds": ["msg_id_1", "msg_id_2", ...]
}
```

### 2. EventBus API Controller
**File:** `C:\Projects\client-manager\ClientManagerAPI\Controllers\EventsController.cs`

Receives and queues events from external polling services.

**Endpoints:**

**POST /api/events/whatsapp**
Receive WhatsApp message events.

Request body:
```json
{
  "eventType": "whatsapp.message.received",
  "eventId": "guid",
  "timestamp": "2026-02-22T20:00:00Z",
  "source": "WhatsAppPoller",
  "data": {
    "messageId": "msg_id",
    "chatId": "31633984381@c.us",
    "chatName": "Contact Name",
    "isGroup": false,
    "from": "31624449841@c.us",
    "to": "31633984381@c.us",
    "body": "Message text",
    "timestamp": 1771775445,
    "timestampUtc": "2026-02-22T20:00:00Z",
    "isFromMe": false
  }
}
```

Response:
```json
{
  "success": true,
  "eventId": "guid",
  "queued": true,
  "queueSize": 42
}
```

**GET /api/events/recent?limit=20**
Get recent events from queue.

**GET /api/events/by-type/{eventType}?limit=20**
Get events by type (e.g., "whatsapp.message.received").

**DELETE /api/events/clear**
Clear event queue.

### 3. Scheduled Task Setup
**File:** `C:\scripts\tools\setup-whatsapp-poller-task.ps1`

Creates Windows scheduled task to run poller every 5 minutes.

**Usage:**
```powershell
# Create scheduled task
.\setup-whatsapp-poller-task.ps1

# Remove scheduled task
.\setup-whatsapp-poller-task.ps1 -Remove
```

**Task details:**
- Name: `WhatsAppEventBusPoller`
- Trigger: Every 5 minutes
- Log: `E:\jengo\documents\temp\whatsapp-poller.log`
- Runs as current user
- Auto-restart on failure (3 attempts)
- Network required

**Management commands:**
```powershell
# Start task manually
Start-ScheduledTask -TaskName "WhatsAppEventBusPoller"

# Stop task
Stop-ScheduledTask -TaskName "WhatsAppEventBusPoller"

# View status
Get-ScheduledTask -TaskName "WhatsAppEventBusPoller" | Get-ScheduledTaskInfo

# View recent runs
Get-ScheduledTask -TaskName "WhatsAppEventBusPoller" | Get-ScheduledTaskInfo |
  Select-Object LastRunTime, NextRunTime, LastTaskResult
```

## Setup Instructions

### Step 1: Ensure Prerequisites
```powershell
# Verify WhatsApp bridge credentials in vault
vault.ps1 -Action get -Service whatsapp-bridge-api

# Should return:
# - username: info@test123.com
# - password: API token
```

### Step 2: Test WhatsApp API Access
```powershell
# Test manual polling
.\whatsapp-eventbus-poller.ps1

# Should output:
# [WhatsApp Poller] Starting poll cycle...
# Found XXX chats total
# Active chats since last poll: X
# New messages found: X
```

### Step 3: Start DataDrivenAI EventOrchestrator
Ensure the DataDrivenAI API is running:
```powershell
# From E:\projects\datadrivenai\backend\DataDrivenAI.API
dotnet run

# Or from Visual Studio: F5
```

Verify API is accessible:
```powershell
curl -k https://localhost:7087/api/health
```

### Step 4: Create Scheduled Task
```powershell
.\setup-whatsapp-poller-task.ps1

# Start immediately (when prompted): y
```

### Step 5: Monitor Events
```powershell
# View event by ID (after poller posts one)
curl -k "https://localhost:7087/api/events/{eventId}" | ConvertFrom-Json

# View log file
Get-Content E:\jengo\documents\temp\whatsapp-poller.log -Tail 20 -Wait

# View scheduled task status
Get-ScheduledTask -TaskName "WhatsAppEventBusPoller" | Get-ScheduledTaskInfo
```

## Event Processing

Once events are in the queue, you can:

### 1. Subscribe to Events (Future)
```csharp
// In client-manager or hazina service
eventBus.Subscribe<WhatsAppMessageEvent>(evt => {
    // Process WhatsApp message
    var chatName = evt.Data.ChatName;
    var body = evt.Data.Body;

    // AI analysis, auto-reply, notification, etc.
});
```

### 2. Query Events via API
```powershell
# Get all WhatsApp events
$events = Invoke-RestMethod "http://localhost:5000/api/events/by-type/whatsapp.message.received"

# Process in PowerShell
$events.events | ForEach-Object {
    Write-Host "$($_.data.chatName): $($_.data.body)"
}
```

### 3. Build Automation Workflows
- Auto-respond to specific keywords
- Forward messages to Slack/Teams
- Log conversations to database
- Trigger AI analysis on incoming messages
- Create tasks/reminders from messages

## Monitoring & Troubleshooting

### Check Poller Status
```powershell
# View last run time
Get-ScheduledTask -TaskName "WhatsAppEventBusPoller" | Get-ScheduledTaskInfo

# View log file
Get-Content E:\jengo\documents\temp\whatsapp-poller.log -Tail 50
```

### Check Event Queue
```powershell
# View queue size
$recent = Invoke-RestMethod "http://localhost:5000/api/events/recent?limit=1"
Write-Host "Queue size: $($recent.total)"

# View recent events
$recent.events | Format-Table eventType, timestamp, source
```

### Common Issues

**1. No events being posted**
- Check scheduled task is running: `Get-ScheduledTask -TaskName "WhatsAppEventBusPoller"`
- Check log file for errors: `Get-Content E:\jengo\documents\temp\whatsapp-poller.log -Tail 20`
- Verify WhatsApp API credentials: `vault.ps1 -Action get -Service whatsapp-bridge-api`
- Test API manually: `.\whatsapp-eventbus-poller.ps1`

**2. API returns 404**
- Ensure client-manager API is running
- Check port (default: 5000)
- Verify EventsController.cs is compiled

**3. Duplicate events**
- Check state file: `Get-Content C:\scripts\_machine\whatsapp-poller-state.json`
- State file tracks processed message IDs
- If corrupted, delete and restart: `Remove-Item C:\scripts\_machine\whatsapp-poller-state.json`

**4. Task not running**
- Check task status: `Get-ScheduledTaskInfo -TaskName "WhatsAppEventBusPoller"`
- View last result code (0 = success, non-zero = error)
- Check network availability (task requires network)

## Performance Considerations

**Polling Interval:** 5 minutes
- Balances freshness vs. API load
- Adjustable via scheduled task trigger

**Lookback Window:** 10 minutes
- Ensures no messages missed between polls
- Overlapping windows prevent gaps

**Queue Size:** 1000 events max
- Prevents memory growth
- Older events auto-removed (FIFO)

**State Tracking:** 1000 message IDs max
- Prevents state file bloat
- Keeps most recent 1000 processed IDs

## Future Enhancements

1. **Real-time WebSocket Connection**
   - Replace polling with WebSocket subscription
   - Instant message delivery (no 5-minute delay)

2. **Event Subscribers in Hazina**
   - Define WhatsAppMessageEvent in Hazina framework
   - Enable AI processing of messages
   - Auto-reply capabilities

3. **Multi-channel Support**
   - Email polling (Gmail/Outlook)
   - Social media (Twitter/LinkedIn mentions)
   - Unified event schema

4. **Persistent Event Store**
   - Replace in-memory queue with database
   - Event replay capabilities
   - Long-term message history

5. **Admin Dashboard**
   - React component for monitoring events
   - Real-time event stream visualization
   - Manual event triggering

## Security Notes

- WhatsApp API credentials stored in vault (encrypted)
- Events API requires authentication (add JWT later)
- State file contains message IDs only (no content)
- Log file contains message previews (first 50 chars)

## Documentation

- **API Spec:** See EventsController.cs XML comments
- **Poller Script:** See whatsapp-eventbus-poller.ps1 header comments
- **Architecture:** This document

## Support

For issues or questions:
1. Check log file: `E:\jengo\documents\temp\whatsapp-poller.log`
2. Test manually: `.\whatsapp-eventbus-poller.ps1`
3. Review state file: `C:\scripts\_machine\whatsapp-poller-state.json`
4. Check API health: `curl http://localhost:5000/api/events/recent`

---

**Last Updated:** 2026-02-22
**Version:** 1.0
**Status:** Production Ready
