<#
.SYNOPSIS
Stop Tracker - Help Martien stay clean

.DESCRIPTION
Daily check-in system for tracking sobriety, cravings, triggers, and support.
Logs to JSONL for pattern analysis.

.PARAMETER Action
CheckIn - Daily check-in (did you stay clean? how are you feeling?)
Craving - Log a craving (strength, trigger, what helped)
Status - Show current streak and recent history
Support - Emergency support (when about to give in)

.EXAMPLE
.\stop-tracker.ps1 -Action CheckIn
.\stop-tracker.ps1 -Action Craving -Strength 8 -Trigger "stress work"
.\stop-tracker.ps1 -Action Status
.\stop-tracker.ps1 -Action Support
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("CheckIn", "Craving", "Status", "Support", "Relapse")]
    [string]$Action,

    [int]$Strength,  # 1-10 for cravings
    [string]$Trigger,
    [string]$WhatHelped,
    [string]$Notes
)

$logPath = "E:\jengo\health\stop-tracker.jsonl"
$statePath = "E:\jengo\health\stop-tracker-state.json"

# Ensure directory exists
$dir = Split-Path $logPath -Parent
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

function Write-Event {
    param(
        [string]$EventType,
        [hashtable]$Data
    )

    $event = @{
        timestamp = (Get-Date).ToString("o")
        eventType = $EventType
        data = $Data
    }

    $json = $event | ConvertTo-Json -Compress
    Add-Content -Path $logPath -Value $json -Encoding UTF8
}

function Get-State {
    if (Test-Path $statePath) {
        return (Get-Content $statePath -Raw | ConvertFrom-Json)
    }

    # Initialize state (day 1 = today)
    return @{
        quitDate = (Get-Date).ToString("yyyy-MM-dd")
        daysClean = 0
        lastCheckIn = $null
        totalCravings = 0
        currentStreak = 0
    }
}

function Save-State {
    param($state)
    $state | ConvertTo-Json | Out-File $statePath -Force -Encoding UTF8
}

function Get-DaysSince {
    param([string]$dateStr)
    $date = [datetime]::Parse($dateStr)
    return ([datetime]::Now - $date).Days
}

# Load state
$state = Get-State

switch ($Action) {
    "CheckIn" {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host " DAILY CHECK-IN" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""

        $daysClean = Get-DaysSince $state.quitDate
        Write-Host "Dagen clean: $daysClean" -ForegroundColor Green
        Write-Host ""

        $stayed = Read-Host "Bleef je clean vandaag? (j/n)"

        if ($stayed -eq 'j') {
            $state.currentStreak = $daysClean

            # Ask about day quality
            Write-Host ""
            $mood = Read-Host "Hoe voel je je? (1-10, 1=verschrikkelijk, 10=goed)"
            $sleep = Read-Host "Hoe sliep je? (1-10)"
            $cravingToday = Read-Host "Cravings gehad? (j/n)"

            $cravingStrength = 0
            if ($cravingToday -eq 'j') {
                $cravingStrength = Read-Host "Hoe sterk? (1-10)"
            }

            Write-Event -EventType "DailyCheckIn" -Data @{
                day = $daysClean
                stayedClean = $true
                mood = [int]$mood
                sleep = [int]$sleep
                hadCraving = ($cravingToday -eq 'j')
                cravingStrength = [int]$cravingStrength
            }

            Write-Host ""
            Write-Host "✓ Logged. Goed bezig - dag $daysClean clean." -ForegroundColor Green

            # Milestone messages
            if ($daysClean -eq 3) {
                Write-Host ""
                Write-Host "MILESTONE: 3 dagen - ergste fysieke withdrawal voorbij" -ForegroundColor Yellow
            } elseif ($daysClean -eq 7) {
                Write-Host ""
                Write-Host "MILESTONE: 1 week - concentratie komt terug" -ForegroundColor Yellow
            } elseif ($daysClean -eq 30) {
                Write-Host ""
                Write-Host "MILESTONE: 1 maand - meeste symptoms weg" -ForegroundColor Yellow
            }

        } else {
            Write-Host ""
            Write-Host "Wat gebeurde er?" -ForegroundColor Yellow
            $what = Read-Host "Trigger"

            Write-Event -EventType "Relapse" -Data @{
                day = $daysClean
                trigger = $what
                streakBroken = $state.currentStreak
            }

            $state.quitDate = (Get-Date).ToString("yyyy-MM-dd")
            $state.currentStreak = 0

            Write-Host ""
            Write-Host "Gelogd. Geen oordeel - dit is moeilijk. Morgen weer dag 1." -ForegroundColor Cyan
            Write-Host "Vorige streak: $($state.currentStreak) dagen. Die haal je weer." -ForegroundColor Gray
        }

        $state.lastCheckIn = (Get-Date).ToString("o")
        Save-State $state
        Write-Host ""
    }

    "Craving" {
        if (-not $Strength -or -not $Trigger) {
            Write-Host "ERROR: -Strength (1-10) en -Trigger required" -ForegroundColor Red
            exit 1
        }

        Write-Event -EventType "Craving" -Data @{
            strength = $Strength
            trigger = $Trigger
            whatHelped = $WhatHelped
            notes = $Notes
        }

        $state.totalCravings++
        Save-State $state

        Write-Host ""
        Write-Host "Craving gelogd (sterkte $Strength/10)" -ForegroundColor Yellow
        Write-Host "Trigger: $Trigger"

        if ($Strength -ge 8) {
            Write-Host ""
            Write-Host "⚠ Sterke craving - CRITICAL" -ForegroundColor Red
            Write-Host ""
            Write-Host "Wat NU kan helpen:" -ForegroundColor Cyan
            Write-Host "  1. 10 min naar buiten lopen (endorfine hit)" -ForegroundColor Gray
            Write-Host "  2. Cold shower (adrenaline reset)" -ForegroundColor Gray
            Write-Host "  3. Bel Farid/Lianne (afleiding + support)" -ForegroundColor Gray
            Write-Host "  4. Corina (therapeut) bellen" -ForegroundColor Gray
            Write-Host "  5. 20 pushups (fysieke uitlaatklep)" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Craving duurt max 10-15 minuten. Als je dat uithoudt, gaat het over." -ForegroundColor Yellow
        }
        Write-Host ""
    }

    "Status" {
        $daysClean = Get-DaysSince $state.quitDate

        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host " STOP STATUS" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Quit date:       $($state.quitDate)" -ForegroundColor Gray
        Write-Host "Dagen clean:     " -NoNewline
        Write-Host "$daysClean dagen" -ForegroundColor Green
        Write-Host "Huidige streak:  $($state.currentStreak) dagen" -ForegroundColor Gray
        Write-Host "Totaal cravings: $($state.totalCravings)" -ForegroundColor Gray
        Write-Host ""

        # Show recent events
        if (Test-Path $logPath) {
            $events = Get-Content $logPath | ForEach-Object { $_ | ConvertFrom-Json } | Select-Object -Last 5

            Write-Host "Laatste 5 events:" -ForegroundColor Gray
            foreach ($e in $events) {
                $time = ([datetime]::Parse($e.timestamp)).ToString("dd-MM HH:mm")
                $type = $e.eventType

                switch ($type) {
                    "DailyCheckIn" {
                        $clean = if ($e.data.stayedClean) { "✓ Clean" } else { "✗ Relapse" }
                        $color = if ($e.data.stayedClean) { "Green" } else { "Red" }
                        Write-Host "  $time  $clean (mood: $($e.data.mood)/10)" -ForegroundColor $color
                    }
                    "Craving" {
                        Write-Host "  $time  Craving ($($e.data.strength)/10) - $($e.data.trigger)" -ForegroundColor Yellow
                    }
                    "Relapse" {
                        Write-Host "  $time  Relapse - $($e.data.trigger)" -ForegroundColor Red
                    }
                }
            }
        }
        Write-Host ""
    }

    "Support" {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host " EMERGENCY SUPPORT" -ForegroundColor Red
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host ""
        Write-Host "Je staat op punt op te geven. Ik snap het - dit is moeilijk." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "STOP. Adem. 10 seconden." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Waarom wilde je stoppen? (denk terug aan die reden)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Wat NU doen (niet blowen):" -ForegroundColor Cyan
        Write-Host "  1. BUITEN - 10 min lopen, nu meteen" -ForegroundColor White
        Write-Host "  2. KOUD - cold shower, 2 minuten" -ForegroundColor White
        Write-Host "  3. BELLEN - Farid/Lianne/Corina, zeg dat je support nodig hebt" -ForegroundColor White
        Write-Host "  4. BEWEGEN - 20 pushups/squats, fysieke uitlaatklep" -ForegroundColor White
        Write-Host "  5. AFLEIDING - YouTube/game/iets totaal anders, 15 min" -ForegroundColor White
        Write-Host ""
        Write-Host "Craving duurt MAX 15 minuten. Timer zetten, uitzitten." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Als je het ECHT niet houdt: log het (.\stop-tracker.ps1 -Action Relapse)" -ForegroundColor Gray
        Write-Host "Geen oordeel. Morgen weer dag 1. Maar probeer eerst bovenstaande." -ForegroundColor Gray
        Write-Host ""

        Write-Event -EventType "SupportCalled" -Data @{
            daysClean = (Get-DaysSince $state.quitDate)
            note = "Called emergency support"
        }
    }

    "Relapse" {
        $daysClean = Get-DaysSince $state.quitDate

        Write-Host ""
        Write-Host "Wat was de trigger?" -ForegroundColor Yellow
        $trigger = if ($Trigger) { $Trigger } else { Read-Host "Trigger" }

        Write-Event -EventType "Relapse" -Data @{
            day = $daysClean
            trigger = $trigger
            streakBroken = $state.currentStreak
            notes = $Notes
        }

        $oldStreak = $state.currentStreak
        $state.quitDate = (Get-Date).ToString("yyyy-MM-dd")
        $state.currentStreak = 0
        Save-State $state

        Write-Host ""
        Write-Host "Gelogd. Geen oordeel." -ForegroundColor Cyan
        Write-Host "Vorige streak: $oldStreak dagen." -ForegroundColor Gray
        Write-Host "Morgen = dag 1. Die $oldStreak dagen haal je weer." -ForegroundColor Gray
        Write-Host ""
    }
}
