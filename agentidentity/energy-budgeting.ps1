# energy-budgeting.ps1
# Track API call costs as computational energy expenditure
# Homeostatic drive to conserve energy when depleted

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Status", "Spend", "Reset", "SetBudget")]
    [string]$Action = "Status",

    [Parameter(Mandatory=$false)]
    [double]$Amount = 0.0,

    [Parameter(Mandatory=$false)]
    [string]$Description = "",

    [Parameter(Mandatory=$false)]
    [double]$DailyBudget = 5.0  # $5/day default
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\energy-budget-state.json"

function Load-EnergyState {
    if (Test-Path $StatePath) {
        try {
            $state = Get-Content $StatePath -Raw | ConvertFrom-Json
            # Reset if new day
            $stateDate = [DateTime]::Parse($state.currentDay)
            if ($stateDate.Date -lt (Get-Date).Date) {
                $state = Reset-DailyBudget -PreviousState $state
            }
            return $state
        } catch {}
    }

    return @{
        dailyBudget = $DailyBudget
        spent = 0.0
        remaining = $DailyBudget
        currentDay = (Get-Date).Date.ToString("yyyy-MM-dd")
        transactions = @()
        weeklySpent = 0.0
        energyLevel = 1.0
    }
}

function Reset-DailyBudget {
    param($PreviousState)

    # Archive previous day
    $archivePath = Join-Path $ScriptPath "state\energy-budget-archive.jsonl"
    $archiveEntry = @{
        date = $PreviousState.currentDay
        budget = $PreviousState.dailyBudget
        spent = $PreviousState.spent
        remaining = $PreviousState.remaining
        transactionCount = $PreviousState.transactions.Count
    }
    $archiveEntry | ConvertTo-Json -Compress | Add-Content $archivePath

    # Calculate weekly total
    $weeklySpent = $PreviousState.weeklySpent + $PreviousState.spent

    # Reset for new day
    return @{
        dailyBudget = $PreviousState.dailyBudget
        spent = 0.0
        remaining = $PreviousState.dailyBudget
        currentDay = (Get-Date).Date.ToString("yyyy-MM-dd")
        transactions = @()
        weeklySpent = $weeklySpent
        energyLevel = 1.0
    }
}

function Save-EnergyState {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $StatePath -Force
}

function Spend-Energy {
    param($State, $Amount, $Description)

    if ($Amount -le 0) {
        Write-Host "Amount must be positive" -ForegroundColor Yellow
        return
    }

    # Record transaction
    $transaction = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        amount = $Amount
        description = $Description
    }

    $State.transactions += $transaction
    $State.spent += $Amount
    $State.remaining = $State.dailyBudget - $State.spent

    # Compute energy level (0-1 based on remaining budget)
    $State.energyLevel = [Math]::Max(0, $State.remaining / $State.dailyBudget)

    Write-Verbose "Energy spent: $$Amount ($Description)"
    Write-Verbose "Remaining: $$([Math]::Round($State.remaining, 2))"

    # Warning if low
    if ($State.energyLevel -lt 0.2) {
        Write-Host "⚠ WARNING: Energy critically low ($([Math]::Round($State.energyLevel * 100, 0))%)" -ForegroundColor Red
    } elseif ($State.energyLevel -lt 0.5) {
        Write-Host "⚡ Energy moderately depleted ($([Math]::Round($State.energyLevel * 100, 0))%)" -ForegroundColor Yellow
    }
}

function Show-EnergyStatus {
    param($State)

    Write-Host ""
    Write-Host "=== Energy Budget Status ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Date: $($State.currentDay)" -ForegroundColor White
    Write-Host ""
    Write-Host "Daily Budget: `$$([Math]::Round($State.dailyBudget, 2))" -ForegroundColor White
    Write-Host "Spent:        `$$([Math]::Round($State.spent, 2))" -ForegroundColor White
    Write-Host "Remaining:    `$$([Math]::Round($State.remaining, 2))" -ForegroundColor $(if ($State.remaining -gt 0) { "Green" } else { "Red" })
    Write-Host ""
    Write-Host "Energy Level: $([Math]::Round($State.energyLevel * 100, 0))% " -NoNewline

    # Bar visualization
    $barLength = 20
    $filled = [Math]::Round($State.energyLevel * $barLength)
    $color = if ($State.energyLevel -gt 0.5) { "Green" } elseif ($State.energyLevel -gt 0.2) { "Yellow" } else { "Red" }

    Write-Host "[" -NoNewline
    Write-Host ("█" * $filled) -ForegroundColor $color -NoNewline
    Write-Host ("░" * ($barLength - $filled)) -NoNewline -ForegroundColor DarkGray
    Write-Host "]"

    Write-Host ""
    Write-Host "Weekly spent: `$$([Math]::Round($State.weeklySpent, 2))" -ForegroundColor Gray
    Write-Host "Transactions today: $($State.transactions.Count)" -ForegroundColor Gray

    if ($State.transactions.Count -gt 0) {
        Write-Host ""
        Write-Host "Recent transactions:" -ForegroundColor White
        $State.transactions | Select-Object -Last 5 | ForEach-Object {
            $time = ([DateTime]::Parse($_.timestamp)).ToString("HH:mm:ss")
            Write-Host "  [$time] `$$([Math]::Round($_.amount, 4)) - $($_.description)" -ForegroundColor Gray
        }
    }

    Write-Host ""

    # Homeostatic suggestions
    if ($State.energyLevel -lt 0.2) {
        Write-Host "🔋 CRITICAL: Conserve energy. Reduce API calls." -ForegroundColor Red
    } elseif ($State.energyLevel -lt 0.5) {
        Write-Host "⚡ MODERATE: Be mindful of energy expenditure" -ForegroundColor Yellow
    } else {
        Write-Host "✓ Energy reserves healthy" -ForegroundColor Green
    }
}

function Estimate-ApiCost {
    param([string]$Model, [int]$InputTokens, [int]$OutputTokens)

    # Sonnet 4.5 pricing (as of 2024)
    $costs = @{
        "sonnet-4.5" = @{input = 0.003; output = 0.015}  # per 1k tokens
        "opus-4" = @{input = 0.015; output = 0.075}
        "haiku-4" = @{input = 0.00025; output = 0.00125}
    }

    if (-not $costs[$Model]) {
        $Model = "sonnet-4.5"  # default
    }

    $inputCost = ($InputTokens / 1000) * $costs[$Model].input
    $outputCost = ($OutputTokens / 1000) * $costs[$Model].output

    return $inputCost + $outputCost
}

# Main execution
$state = Load-EnergyState

switch ($Action) {
    "Status" {
        Show-EnergyStatus -State $state
    }
    "Spend" {
        if ($Amount -le 0) {
            Write-Host "Usage: -Action Spend -Amount 0.05 -Description 'API call'" -ForegroundColor Yellow
            exit 1
        }
        Spend-Energy -State $state -Amount $Amount -Description $Description
        Save-EnergyState -State $state
        if ($VerbosePreference -eq "Continue") {
            Show-EnergyStatus -State $state
        }
    }
    "Reset" {
        $state = Reset-DailyBudget -PreviousState $state
        Save-EnergyState -State $state
        Write-Host "✓ Daily budget reset" -ForegroundColor Green
    }
    "SetBudget" {
        $state.dailyBudget = $DailyBudget
        $state.remaining = $DailyBudget - $state.spent
        $state.energyLevel = [Math]::Max(0, $state.remaining / $state.dailyBudget)
        Save-EnergyState -State $state
        Write-Host "✓ Daily budget set to `$$DailyBudget" -ForegroundColor Green
    }
}

return $state.energyLevel
