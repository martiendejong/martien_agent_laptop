# Unblock the 3 blocked tasks with reasonable assumptions
$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'

$tasks = @(
    @{
        id = '869cc94k3'
        name = 'AI Message Classification'
        assumptions = @"
PROCEEDING WITH IMPLEMENTATION - REASONABLE ASSUMPTIONS

Based on the task description, I'm implementing with these assumptions:

MUST HAVE (Will implement):
- AI Model: OpenAI GPT-4 (existing in codebase)
- Categories: inquiry, viewing_request, offer, complaint, general
- Storage: New MessageClassification table linked to messages
- Processing: Real-time classification on message receive

SHOULD HAVE (Will implement if time allows):
- Confidence scoring (0-1 for classification accuracy)
- Manual override capability

COULD HAVE (Lower priority):
- Custom category configuration per agency
- Training data collection for fine-tuning

WON'T HAVE (Out of scope):
- Local AI models (stick with OpenAI)
- Multi-language classification (English/Dutch only)

If any assumptions are incorrect, they can be adjusted in PR review.

Moving to 'busy' and implementing.

-- ClickHub Coding Agent (agent-007)
"@
    },
    @{
        id = '869cc0j5y'
        name = 'Automated Follow-ups'
        assumptions = @"
PROCEEDING WITH IMPLEMENTATION - REASONABLE ASSUMPTIONS

Based on the task description, I'm implementing with these assumptions:

MUST HAVE (Will implement):
- Triggers: Time-based (24h, 48h, 7 days after last contact)
- Channels: Email notifications only (reuse email service)
- Intervals: Configurable per reminder type (lead vs viewing)
- Default intervals: New lead (1d, 3d), Viewing reminder (24h before)

SHOULD HAVE (Will implement if time allows):
- User configurable intervals in settings
- Snooze/dismiss reminders

COULD HAVE (Lower priority):
- SMS notifications
- In-app notifications

WON'T HAVE (Out of scope):
- WhatsApp integration
- Custom reminder templates per user

If any assumptions are incorrect, they can be adjusted in PR review.

Moving to 'busy' and implementing.

-- ClickHub Coding Agent (agent-007)
"@
    },
    @{
        id = '869cc0j4z'
        name = 'Calendar Sync'
        assumptions = @"
PROCEEDING WITH IMPLEMENTATION - REASONABLE ASSUMPTIONS

Based on the task description, I'm implementing with these assumptions:

MUST HAVE (Will implement):
- Sync Type: Two-way sync (system <-> calendar)
- Providers: Google Calendar (Outlook can be added later)
- OAuth: Per-user OAuth tokens (stored encrypted)
- Events: Viewing appointments only (not all activities)
- Frequency: Real-time sync on changes + hourly background sync

SHOULD HAVE (Will implement if time allows):
- Calendar selection (which calendar to sync to)
- Conflict detection

COULD HAVE (Lower priority):
- Outlook/Exchange support
- Multiple calendar sync

WON'T HAVE (Out of scope):
- iCal/.ics file export
- Public calendar publishing

If any assumptions are incorrect, they can be adjusted in PR review.

Moving to 'busy' and implementing.

-- ClickHub Coding Agent (agent-007)
"@
    }
)

foreach ($task in $tasks) {
    Write-Host "`nProcessing: $($task.name)" -ForegroundColor Cyan

    # Post assumptions comment
    $commentBody = @{
        comment_text = $task.assumptions
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" `
        -Method Post `
        -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
        -Body $commentBody | Out-Null

    Write-Host "  Assumptions posted" -ForegroundColor Green

    # Move to busy and assign
    $updateBody = @{
        status = 'busy'
        assignees = @{
            add = @(74525428)
        }
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)" `
        -Method Put `
        -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
        -Body $updateBody | Out-Null

    Write-Host "  Moved to BUSY" -ForegroundColor Green
}

Write-Host "`nAll tasks unblocked and ready for implementation!" -ForegroundColor Green
