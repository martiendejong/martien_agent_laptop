$cfg = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json
$key = $cfg.api_key

$refinements = @(
    @{
        id = '869ccfvqa'
        name = 'Fix: Send email/whatsapp buttons return 400 error on woningzoekende and aanbod pages'
        desc = "SUMMARY`nClicking send email or send WhatsApp on woningzoekende detail or aanbod detail pages returns 400 Bad Request. PR #80 (internal messaging API) and PR #81 (error messages) already merged to develop.`n`nTECHNICAL DETAILS`n- POST /api/messages/send returns 400`n- POST /api/messages/send-email returns 404 (endpoint may not exist)`n- Backend MessagesController needs investigation`n- Check if WhatsApp/Email settings are configured in AppSettings`n- Frontend sends correct payload format`n`nACCEPTANCE`n1. Send email button works from woningzoekende detail page`n2. Send WhatsApp button works from woningzoekende detail page`n3. Send email from aanbod detail (lead match) works`n4. No 400/404 errors in console`n5. User-friendly error when services not configured"
        priority = 1
        tags = @('bug','frontend','backend')
    },
    @{
        id = '869ccfndh'
        name = 'Fix: Typing message in woningzoekende berichten screen triggers 400 error'
        desc = "SUMMARY`nWhen typing a message in the berichten (messages) tab of woningzoekende detail, every keystroke or send triggers a backend 400 error with message 'Failed to send message'.`n`nTECHNICAL DETAILS`n- Related to 869ccfvqa (same messaging backend)`n- Check if message send is triggered on input change vs only on submit`n- Verify request payload matches MessagesController expectations`n- Check channel detection (Email vs WhatsApp vs SMS)`n`nACCEPTANCE`n1. Typing in message input does NOT trigger API calls`n2. Only clicking Send triggers the API`n3. Successful message send with proper feedback`n4. No console errors during typing"
        priority = 1
        tags = @('bug','frontend','backend')
    },
    @{
        id = '869cchp0g'
        name = 'Testing: Verify complete rebrand with custom agency name via settings API'
        desc = "SUMMARY`nEnd-to-end verification that the white-label rebrand (PR #84) works correctly with a custom agency name.`n`nTECHNICAL DETAILS`n1. PUT /api/settings/agency with custom name/logo/colors`n2. Verify all pages reflect new branding`n3. Check: Login, Sidebar, Homepage, WoningPubliek, WoningzoekendeDetail, AanbodDetail, Instellingen`n4. Verify email templates use dynamic agency name`n5. Verify no hardcoded 'Bliek' remains in UI`n6. Test settings persist after backend restart`n`nACCEPTANCE`n1. All pages show custom agency name`n2. Logo loads from custom URL`n3. Homepage uses custom background and primary color`n4. Email templates contain custom agency name`n5. Settings survive restart"
        priority = 2
        tags = @('testing','frontend')
    },
    @{
        id = '869cchnzu'
        name = 'Infrastructure: Update Jengo knowledge base with new repo/project references'
        desc = "SUMMARY`nUpdate all Jengo system files that reference 'bliek' or old naming conventions.`n`nTECHNICAL DETAILS`nFiles to update:`n1. project-locations.md - project paths`n2. PROJECT_MASTER_MAP.md - master mapping`n3. clickup-config.json - board references`n4. project-inventory.json - repo scan`n`nACCEPTANCE`n1. All project mapping files are current`n2. No stale references to old naming"
        priority = 3
        tags = @('infrastructure')
    },
    @{
        id = '869cchnyf'
        name = 'GitHub: Rename repository from bliek-vastgoed to real-estate-agency-ai'
        desc = "SUMMARY`nRename GitHub repository. HIGH IMPACT - all developers need to update remote URLs.`n`nTECHNICAL DETAILS`n1. GitHub Settings > Repository name > real-estate-agency-ai`n2. Update all local clones (git remote set-url)`n3. Update worktree pool references`n4. Update CI/CD if any`n5. Update PROJECT_MASTER_MAP.md`n`nBLOCKER: Needs explicit user confirmation before executing. Destructive operation.`n`nACCEPTANCE`n1. Repo accessible at new URL`n2. All local clones updated`n3. All scripts/configs reference new name"
        priority = 4
        tags = @('infrastructure')
    },
    @{
        id = '869cchnzn'
        name = 'ClickUp: Rename board from Bliek Vastgoed to Real Estate Agency AI'
        desc = "SUMMARY`nRename ClickUp board/space to reflect new product name.`n`nTECHNICAL DETAILS`n1. Update board name via ClickUp API or UI`n2. Update clickup-config.json board references`n3. Test all scripts (refinement, reviewer, task retrieval) still work`n`nBLOCKER: Needs user decision on final name. Rename via API or manual.`n`nACCEPTANCE`n1. Board name updated in ClickUp`n2. All scripts reference correct board name`n3. No broken task retrieval"
        priority = 4
        tags = @('infrastructure')
    },
    @{
        id = '869cc94jx'
        name = 'Feature: Background worker - periodic IMAP email sync for all clients'
        desc = "SUMMARY`nHosted background service that periodically fetches emails via IMAP for all clients. Similar pattern to existing WhatsApp sync worker.`n`nTECHNICAL DETAILS`n- IHostedService with periodic timer (configurable interval)`n- Connect to IMAP using email settings from AppSettings (smtp_server, credentials)`n- Fetch emails since lastSyncTime per client`n- Match incoming emails to clients by email address`n- Store as Message entities with Channel=Email, Direction=Incoming`n- Track sync state (lastSyncTime) in AppSettings`n- Use MailKit for IMAP connectivity`n`nACCEPTANCE`n1. Worker starts automatically with the API`n2. Fetches new emails on configured interval`n3. Matches emails to existing clients`n4. Shows in conversation view alongside outgoing emails`n5. Handles connection failures gracefully`n6. Configurable sync interval via settings"
        priority = 2
        tags = @('backend','feature')
    },
    @{
        id = '869cc0j4c'
        name = 'Feature: PDF woningbrochure generation (professional property expose)'
        desc = "SUMMARY`nOne-click PDF generation from property detail page with professional layout and dynamic agency branding.`n`nTECHNICAL DETAILS`n- Backend endpoint: POST /api/properties/{id}/brochure`n- Use QuestPDF (free .NET PDF library) for generation`n- Layout: cover page with hero photo, property details, gallery, floor plans, map`n- Dynamic branding from agency settings (logo, colors, name)`n- Frontend: Download button on AanbodDetailPerfect page`n- PDF includes: title, description, specs, price, images, contact info`n`nACCEPTANCE`n1. Download PDF button visible on property detail`n2. PDF generates with professional layout`n3. Agency branding (logo, name, colors) from settings`n4. All property data included (photos, specs, description)`n5. PDF is well-formatted and print-ready"
        priority = 2
        tags = @('backend','frontend','feature')
    }
)

foreach ($r in $refinements) {
    $body = @{
        name = $r.name
        description = $r.desc
    } | ConvertTo-Json -Depth 3
    try {
        $result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($r.id)" -Headers @{Authorization=$key; 'Content-Type'='application/json'} -Method Put -Body $body
        Write-Output "Refined $($r.id): $($r.name) -> $($result.status.status)"
    } catch {
        Write-Output "ERROR $($r.id): $_"
    }
}
Write-Output "`nAll 8 tasks refined."
