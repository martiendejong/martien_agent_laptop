# Google Workspace Automation Examples
# Real-world automation patterns using Google Workspace MCP

$mcpSetup = "C:\scripts\tools\google-workspace-mcp-setup.ps1"

# ============================================================================
# EXAMPLE 1: Email Notification System
# ============================================================================

function Send-ClientEmail {
    <#
    .SYNOPSIS
    Send email via Gmail API
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$To,

        [Parameter(Mandatory=$true)]
        [string]$Subject,

        [Parameter(Mandatory=$true)]
        [string]$Body,

        [Parameter(Mandatory=$false)]
        [string[]]$Attachments
    )

    $args = @{
        to = $To
        subject = $Subject
        body = $Body
    }

    if ($Attachments) {
        $args.attachments = $Attachments
    }

    $argsJson = $args | ConvertTo-Json -Compress

    & $mcpSetup -Action cli -Command "send_gmail" -Args $argsJson
}

# ============================================================================
# EXAMPLE 2: Drive Backup System
# ============================================================================

function Backup-ToGoogleDrive {
    <#
    .SYNOPSIS
    Backup local files/folders to Google Drive
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$LocalPath,

        [Parameter(Mandatory=$true)]
        [string]$DriveFolderId,

        [Parameter(Mandatory=$false)]
        [switch]$Recursive
    )

    if (Test-Path $LocalPath -PathType Container) {
        # Directory backup
        Get-ChildItem $LocalPath -Recurse:$Recursive -File | ForEach-Object {
            $fileName = $_.Name
            $filePath = $_.FullName

            Write-Host "Uploading: $fileName" -ForegroundColor Cyan

            $args = @{
                filePath = $filePath
                folderId = $DriveFolderId
                fileName = $fileName
            } | ConvertTo-Json -Compress

            & $mcpSetup -Action cli -Command "upload_to_drive" -Args $args
        }
    } else {
        # Single file backup
        $fileName = Split-Path $LocalPath -Leaf

        $args = @{
            filePath = $LocalPath
            folderId = $DriveFolderId
            fileName = $fileName
        } | ConvertTo-Json -Compress

        & $mcpSetup -Action cli -Command "upload_to_drive" -Args $args
    }

    Write-Host "[OK] Backup completed" -ForegroundColor Green
}

# ============================================================================
# EXAMPLE 3: Gmail Monitor for Client Communications
# ============================================================================

function Get-ImportantEmails {
    <#
    .SYNOPSIS
    Check for important unread emails
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$FromDomain,

        [Parameter(Mandatory=$false)]
        [string]$Label = "important"
    )

    $query = "is:unread"

    if ($FromDomain) {
        $query += " from:@$FromDomain"
    }

    if ($Label) {
        $query += " label:$Label"
    }

    $args = @{
        query = $query
        maxResults = 10
    } | ConvertTo-Json -Compress

    $result = & $mcpSetup -Action cli -Command "search_gmail_messages" -Args $args

    return $result | ConvertFrom-Json
}

# ============================================================================
# EXAMPLE 4: Calendar Event Automation
# ============================================================================

function New-ClientMeeting {
    <#
    .SYNOPSIS
    Schedule client meeting in Google Calendar
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ClientName,

        [Parameter(Mandatory=$true)]
        [DateTime]$StartTime,

        [Parameter(Mandatory=$false)]
        [int]$DurationMinutes = 60,

        [Parameter(Mandatory=$false)]
        [string]$Description,

        [Parameter(Mandatory=$false)]
        [string[]]$Attendees
    )

    $endTime = $StartTime.AddMinutes($DurationMinutes)

    $args = @{
        summary = "Meeting: $ClientName"
        start = $StartTime.ToString("yyyy-MM-ddTHH:mm:ss")
        end = $endTime.ToString("yyyy-MM-ddTHH:mm:ss")
        description = $Description
    }

    if ($Attendees) {
        $args.attendees = $Attendees
    }

    $argsJson = $args | ConvertTo-Json -Compress

    & $mcpSetup -Action cli -Command "create_calendar_event" -Args $argsJson
}

# ============================================================================
# EXAMPLE 5: Docs Generation & Export
# ============================================================================

function Export-GoogleDocToPdf {
    <#
    .SYNOPSIS
    Export Google Doc to PDF
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$DocId,

        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )

    $args = @{
        documentId = $DocId
        outputPath = $OutputPath
        format = "pdf"
    } | ConvertTo-Json -Compress

    & $mcpSetup -Action cli -Command "export_document" -Args $args

    Write-Host "[OK] Exported to: $OutputPath" -ForegroundColor Green
}

# ============================================================================
# EXAMPLE 6: Sheets Data Operations
# ============================================================================

function Get-SheetData {
    <#
    .SYNOPSIS
    Read data from Google Sheets
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$SpreadsheetId,

        [Parameter(Mandatory=$true)]
        [string]$Range
    )

    $args = @{
        spreadsheetId = $SpreadsheetId
        range = $Range
    } | ConvertTo-Json -Compress

    $result = & $mcpSetup -Action cli -Command "get_sheet_values" -Args $args

    return $result | ConvertFrom-Json
}

function Set-SheetData {
    <#
    .SYNOPSIS
    Write data to Google Sheets
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$SpreadsheetId,

        [Parameter(Mandatory=$true)]
        [string]$Range,

        [Parameter(Mandatory=$true)]
        [array]$Values
    )

    $args = @{
        spreadsheetId = $SpreadsheetId
        range = $Range
        values = $Values
    } | ConvertTo-Json -Compress

    & $mcpSetup -Action cli -Command "update_sheet_values" -Args $args
}

# ============================================================================
# EXAMPLE 7: Combined Workflow - Weekly Client Report
# ============================================================================

function Send-WeeklyClientReport {
    <#
    .SYNOPSIS
    Generate and send weekly client report via Gmail
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ClientEmail,

        [Parameter(Mandatory=$true)]
        [string]$ClientName,

        [Parameter(Mandatory=$true)]
        [string]$SpreadsheetId
    )

    Write-Host "Generating weekly report for $ClientName..." -ForegroundColor Cyan

    # 1. Get analytics data from Sheets
    $data = Get-SheetData -SpreadsheetId $SpreadsheetId -Range "Analytics!A1:D20"

    # 2. Generate summary
    $summary = "Weekly performance summary for $ClientName`n`n"
    $summary += "Data retrieved from Google Sheets.`n"

    # 3. Send email
    Send-ClientEmail `
        -To $ClientEmail `
        -Subject "Your Weekly Performance Report - $ClientName" `
        -Body $summary

    Write-Host "[OK] Report sent to $ClientEmail" -ForegroundColor Green
}

# ============================================================================
# EXAMPLE 8: Automated Content Backup
# ============================================================================

function Backup-ClientContent {
    <#
    .SYNOPSIS
    Backup client content to Google Drive
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ClientName,

        [Parameter(Mandatory=$true)]
        [string]$DriveFolderId
    )

    $contentDir = "E:\jengo\documents\output\$ClientName"

    if (-not (Test-Path $contentDir)) {
        Write-Host "[SKIP] No content for $ClientName" -ForegroundColor Yellow
        return
    }

    Write-Host "Backing up content for $ClientName..." -ForegroundColor Cyan

    Backup-ToGoogleDrive -LocalPath $contentDir -DriveFolderId $DriveFolderId -Recursive

    # Send notification
    Send-ClientEmail `
        -To "client@example.com" `
        -Subject "Content Backup Completed - $ClientName" `
        -Body "Your content has been backed up to Google Drive."

    Write-Host "[OK] Backup and notification complete" -ForegroundColor Green
}

# ============================================================================
# USAGE EXAMPLES
# ============================================================================

<#

# Send simple email
Send-ClientEmail `
    -To "client@example.com" `
    -Subject "Test Email" `
    -Body "This is a test email from Google Workspace MCP"

# Backup files to Drive
Backup-ToGoogleDrive `
    -LocalPath "E:\jengo\documents\output" `
    -DriveFolderId "your-folder-id-from-drive-url" `
    -Recursive

# Check important emails
$emails = Get-ImportantEmails -FromDomain "example.com" -Label "important"
$emails | ForEach-Object {
    Write-Host "From: $($_.from)"
    Write-Host "Subject: $($_.subject)"
    Write-Host ""
}

# Schedule meeting
New-ClientMeeting `
    -ClientName "Acme Corp" `
    -StartTime (Get-Date).AddDays(3).Date.AddHours(14) `
    -DurationMinutes 90 `
    -Description "Quarterly review meeting" `
    -Attendees @("client@acme.com", "teammate@company.com")

# Get data from Sheets
$data = Get-SheetData -SpreadsheetId "your-sheet-id" -Range "Sheet1!A1:D10"

# Update Sheets with new data
Set-SheetData `
    -SpreadsheetId "your-sheet-id" `
    -Range "Sheet1!A1:B2" `
    -Values @(@("Name", "Value"), @("Metric1", "100"))

# Weekly report workflow
Send-WeeklyClientReport `
    -ClientEmail "client@example.com" `
    -ClientName "Acme Corp" `
    -SpreadsheetId "your-analytics-sheet-id"

# Backup workflow
Backup-ClientContent `
    -ClientName "AcmeCorp" `
    -DriveFolderId "your-drive-folder-id"

#>
