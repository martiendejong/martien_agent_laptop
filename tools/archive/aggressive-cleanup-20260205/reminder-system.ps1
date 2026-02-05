<#
.SYNOPSIS
    AI-powered reminder system with scheduled task integration

.DESCRIPTION
    Set reminders that Claude will proactively bring up at the right time.
    Uses Windows Task Scheduler + persistence file for cross-session memory.

.PARAMETER Action
    add, list, check, complete, delete

.PARAMETER Message
    Reminder message/description

.PARAMETER When
    When to remind: time (HH:MM), date (YYYY-MM-DD), relative (tomorrow, next-week, in-2-hours)

.PARAMETER Priority
    1-10 (10 = critical, 1 = low)

.PARAMETER RecurringDaily
    Make it a daily reminder

.EXAMPLE
    # Set reminder for tomorrow morning
    .\reminder-system.ps1 -Action add -Message "Visit Carpetright Meppel for sales call" -When "tomorrow 9:00" -Priority 10

.EXAMPLE
    # Check what reminders are due
    .\reminder-system.ps1 -Action check

.EXAMPLE
    # List all reminders
    .\reminder-system.ps1 -Action list
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("add", "list", "check", "complete", "delete")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$Message,

    [Parameter(Mandatory=$false)]
    [string]$When,

    [Parameter(Mandatory=$false)]
    [int]$Priority = 5,

    [Parameter(Mandatory=$false)]
    [switch]$RecurringDaily,

    [Parameter(Mandatory=$false)]
    [string]$Id
)

$ErrorActionPreference = "Stop"

$REMINDERS_FILE = "C:\scripts\_machine\reminders.jsonl"

function Parse-When {
    param([string]$WhenString)

    $now = Get-Date

    # Relative times
    if ($WhenString -match "^tomorrow (.+)$") {
        $time = $matches[1]
        $date = $now.AddDays(1).ToString("yyyy-MM-dd")
        return [datetime]"$date $time"
    }
    elseif ($WhenString -eq "tomorrow") {
        return $now.AddDays(1).Date.AddHours(9) # 9 AM tomorrow
    }
    elseif ($WhenString -match "^in (\d+) hours?$") {
        return $now.AddHours([int]$matches[1])
    }
    elseif ($WhenString -match "^in (\d+) days?$") {
        return $now.AddDays([int]$matches[1])
    }
    elseif ($WhenString -eq "next-week") {
        return $now.AddDays(7).Date.AddHours(9)
    }
    # Absolute time today
    elseif ($WhenString -match "^(\d{1,2}):(\d{2})$") {
        $hour = [int]$matches[1]
        $minute = [int]$matches[2]
        $targetTime = $now.Date.AddHours($hour).AddMinutes($minute)

        if ($targetTime -lt $now) {
            # If time already passed today, schedule for tomorrow
            $targetTime = $targetTime.AddDays(1)
        }
        return $targetTime
    }
    # Absolute date + time
    elseif ($WhenString -match "^(\d{4}-\d{2}-\d{2}) (.+)$") {
        return [datetime]$WhenString
    }
    # Just date (default 9 AM)
    elseif ($WhenString -match "^\d{4}-\d{2}-\d{2}$") {
        return [datetime]"$WhenString 09:00"
    }
    else {
        throw "Cannot parse 'when' value: $WhenString. Use format like 'tomorrow 9:00', 'in 2 hours', '2026-01-28 14:30'"
    }
}

function Add-Reminder {
    param(
        [string]$Message,
        [datetime]$DueTime,
        [int]$Priority,
        [bool]$Recurring
    )

    $id = [guid]::NewGuid().ToString().Substring(0, 8)

    $reminder = @{
        id = $id
        message = $Message
        dueTime = $DueTime.ToString("yyyy-MM-dd HH:mm:ss")
        priority = $Priority
        recurring = $Recurring
        created = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        completed = $false
    } | ConvertTo-Json -Compress

    # Ensure directory exists
    $dir = Split-Path $REMINDERS_FILE
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # Append to JSONL
    Add-Content -Path $REMINDERS_FILE -Value $reminder

    Write-Host "✅ Reminder added (ID: $id)" -ForegroundColor Green
    Write-Host "   Message: $Message" -ForegroundColor White
    Write-Host "   Due: $($DueTime.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor Cyan
    Write-Host "   Priority: $Priority/10" -ForegroundColor Yellow
    if ($Recurring) {
        Write-Host "   Recurring: Daily" -ForegroundColor Magenta
    }

    # Create Windows scheduled task (optional, for popup notifications)
    # TODO: Implement if needed
}

function Get-Reminders {
    param([bool]$OnlyDue = $false)

    if (-not (Test-Path $REMINDERS_FILE)) {
        return @()
    }

    $reminders = Get-Content $REMINDERS_FILE | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    if ($OnlyDue) {
        $now = Get-Date
        $reminders = $reminders | Where-Object {
            -not $_.completed -and [datetime]$_.dueTime -le $now
        }
    }

    return $reminders
}

function Show-Reminders {
    $reminders = Get-Reminders

    if ($reminders.Count -eq 0) {
        Write-Host "📭 No reminders set" -ForegroundColor Yellow
        return
    }

    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📋 ALL REMINDERS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Cyan

    $now = Get-Date

    foreach ($r in ($reminders | Sort-Object { [datetime]$_.dueTime })) {
        $dueTime = [datetime]$r.dueTime
        $overdue = $dueTime -lt $now -and -not $r.completed

        $statusIcon = if ($r.completed) { "✅" } elseif ($overdue) { "🚨" } else { "⏰" }
        $statusColor = if ($r.completed) { "Green" } elseif ($overdue) { "Red" } else { "Yellow" }

        Write-Host "$statusIcon " -NoNewline -ForegroundColor $statusColor
        Write-Host "[$($r.id)] " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($r.message)" -ForegroundColor White
        Write-Host "     Due: $($dueTime.ToString('yyyy-MM-dd HH:mm')) " -NoNewline -ForegroundColor Cyan
        Write-Host "Priority: $($r.priority)/10 " -NoNewline -ForegroundColor Yellow
        if ($r.recurring) {
            Write-Host "(Daily)" -NoNewline -ForegroundColor Magenta
        }
        if ($r.completed) {
            Write-Host " COMPLETED" -ForegroundColor Green
        } elseif ($overdue) {
            Write-Host " OVERDUE!" -ForegroundColor Red
        }
        Write-Host ""
    }

    Write-Host "`n═══════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Check-DueReminders {
    $dueReminders = Get-Reminders -OnlyDue $true

    if ($dueReminders.Count -eq 0) {
        Write-Host "✅ No reminders due right now" -ForegroundColor Green
        return
    }

    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "🚨 REMINDERS DUE NOW!" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Red

    foreach ($r in ($dueReminders | Sort-Object priority -Descending)) {
        Write-Host "[$($r.id)] " -NoNewline -ForegroundColor Yellow
        Write-Host "$($r.message)" -ForegroundColor White
        Write-Host "  Priority: $($r.priority)/10" -ForegroundColor Yellow
        Write-Host "  Due: $([datetime]$r.dueTime)" -ForegroundColor Cyan
        Write-Host ""
    }

    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Red
}

function Complete-Reminder {
    param([string]$Id)

    if (-not (Test-Path $REMINDERS_FILE)) {
        Write-Host "❌ No reminders file found" -ForegroundColor Red
        return
    }

    $reminders = Get-Content $REMINDERS_FILE | ForEach-Object {
        $r = $_ | ConvertFrom-Json
        if ($r.id -eq $Id) {
            $r.completed = $true
            Write-Host "✅ Marked reminder as complete: $($r.message)" -ForegroundColor Green
        }
        $r | ConvertTo-Json -Compress
    }

    $reminders | Set-Content $REMINDERS_FILE
}

function Delete-Reminder {
    param([string]$Id)

    if (-not (Test-Path $REMINDERS_FILE)) {
        Write-Host "❌ No reminders file found" -ForegroundColor Red
        return
    }

    $reminders = Get-Content $REMINDERS_FILE | ForEach-Object {
        $r = $_ | ConvertFrom-Json
        if ($r.id -ne $Id) {
            $r | ConvertTo-Json -Compress
        } else {
            Write-Host "🗑️  Deleted reminder: $($r.message)" -ForegroundColor Yellow
        }
    }

    $reminders | Set-Content $REMINDERS_FILE
}

# Main execution
try {
    switch ($Action) {
        "add" {
            if (-not $Message) {
                Write-Host "❌ -Message required for adding reminder" -ForegroundColor Red
                exit 1
            }
            if (-not $When) {
                Write-Host "❌ -When required for adding reminder" -ForegroundColor Red
                exit 1
            }

            $dueTime = Parse-When -WhenString $When
            Add-Reminder -Message $Message -DueTime $dueTime -Priority $Priority -Recurring $RecurringDaily.IsPresent
        }

        "list" {
            Show-Reminders
        }

        "check" {
            Check-DueReminders
        }

        "complete" {
            if (-not $Id) {
                Write-Host "❌ -Id required for completing reminder" -ForegroundColor Red
                exit 1
            }
            Complete-Reminder -Id $Id
        }

        "delete" {
            if (-not $Id) {
                Write-Host "❌ -Id required for deleting reminder" -ForegroundColor Red
                exit 1
            }
            Delete-Reminder -Id $Id
        }
    }

} catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    exit 1
}
