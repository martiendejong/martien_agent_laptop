# Stop Tracker - Simple version
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Status", "Craving", "Support")]
    [string]$Action,

    [int]$Strength,
    [string]$Trigger
)

$logPath = "E:\jengo\health\stop-tracker.jsonl"
$statePath = "E:\jengo\health\stop-tracker-state.json"

# Ensure directory
$dir = Split-Path $logPath -Parent
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# Initialize state if needed
if (-not (Test-Path $statePath)) {
    @{
        quitDate = (Get-Date).ToString("yyyy-MM-dd")
        totalCravings = 0
        lastCheckIn = (Get-Date).ToString("o")
    } | ConvertTo-Json | Out-File $statePath -Force
}

$state = Get-Content $statePath -Raw | ConvertFrom-Json

if ($Action -eq "Status") {
    $quitDate = [datetime]::Parse($state.quitDate)
    $daysClean = ([datetime]::Now - $quitDate).Days

    Write-Host ""
    Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host " STOP STATUS" -ForegroundColor Cyan
    Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Quit date: $($state.quitDate)" -ForegroundColor Gray
    Write-Host "  Dagen clean: " -NoNewline
    Write-Host "$daysClean dagen" -ForegroundColor Green
    Write-Host "  Totaal cravings: $($state.totalCravings)" -ForegroundColor Gray
    Write-Host ""

    # Milestones
    if ($daysClean -eq 1) {
        Write-Host "  DAG 1 - Dit is de moeilijkste dag" -ForegroundColor Yellow
    } elseif ($daysClean -eq 3) {
        Write-Host "  DAG 3 - Fysieke withdrawal ergste voorbij" -ForegroundColor Yellow
    } elseif ($daysClean -eq 7) {
        Write-Host "  WEEK 1 - Concentratie komt terug" -ForegroundColor Yellow
    } elseif ($daysClean -eq 30) {
        Write-Host "  MAAND 1 - Meeste symptoms weg!" -ForegroundColor Green
    }
    Write-Host ""

} elseif ($Action -eq "Craving") {
    if (-not $Strength -or -not $Trigger) {
        Write-Host "ERROR: -Strength (1-10) en -Trigger required" -ForegroundColor Red
        exit 1
    }

    # Log craving
    @{
        timestamp = (Get-Date).ToString("o")
        eventType = "Craving"
        data = @{
            strength = $Strength
            trigger = $Trigger
        }
    } | ConvertTo-Json -Compress | Add-Content $logPath

    # Update state
    $state.totalCravings++
    $state | ConvertTo-Json | Out-File $statePath -Force

    Write-Host ""
    Write-Host "Craving gelogd: $Strength/10 - $Trigger" -ForegroundColor Yellow

    if ($Strength -ge 8) {
        Write-Host ""
        Write-Host "⚠ STERKE CRAVING - doe DIT:" -ForegroundColor Red
        Write-Host "  1. 10 min naar buiten (nu)" -ForegroundColor White
        Write-Host "  2. Cold shower 2 min" -ForegroundColor White
        Write-Host "  3. Bel iemand (Farid/Lianne)" -ForegroundColor White
        Write-Host "  4. 20 pushups" -ForegroundColor White
        Write-Host ""
        Write-Host "Craving duurt MAX 15 minuten. Timer zetten." -ForegroundColor Yellow
    }
    Write-Host ""

} elseif ($Action -eq "Support") {
    Write-Host ""
    Write-Host "══════════════════════════════════════════" -ForegroundColor Red
    Write-Host " EMERGENCY" -ForegroundColor Red
    Write-Host "══════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "STOP. Adem. 10 seconden." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Doe DIT (niet blowen):" -ForegroundColor Yellow
    Write-Host "  1. BUITEN - 10 min lopen NU" -ForegroundColor White
    Write-Host "  2. KOUD - 2 min cold shower" -ForegroundColor White
    Write-Host "  3. BELLEN - Farid/Lianne/Corina" -ForegroundColor White
    Write-Host "  4. BEWEGEN - 20 pushups" -ForegroundColor White
    Write-Host ""
    Write-Host "Craving = MAX 15 min. Timer zetten, uitzitten." -ForegroundColor Yellow
    Write-Host ""

    # Log support call
    @{
        timestamp = (Get-Date).ToString("o")
        eventType = "SupportCalled"
        data = @{ note = "Emergency support" }
    } | ConvertTo-Json -Compress | Add-Content $logPath
}
