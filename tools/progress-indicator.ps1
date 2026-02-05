# progress-indicator.ps1
# Visual progress bars and status indicators for long operations
# Prevents "frozen" feel during lengthy tasks

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Start", "Update", "Complete", "Fail", "Spinner")]
    [string]$Action,

    [string]$TaskName = "",
    [int]$Current = 0,
    [int]$Total = 100,
    [string]$Status = "",
    [string]$ProgressId = ""
)

$script:ActiveProgress = @{}
$script:ProgressFile = "C:\scripts\_machine\progress.state.json"

function Save-ProgressState {
    $script:ActiveProgress | ConvertTo-Json | Set-Content -Path $script:ProgressFile -Force
}

function Load-ProgressState {
    if (Test-Path $script:ProgressFile) {
        $script:ActiveProgress = Get-Content $script:ProgressFile -Raw | ConvertFrom-Json -AsHashtable
    }
}

function Show-ProgressBar {
    param(
        [string]$TaskName,
        [int]$Current,
        [int]$Total,
        [string]$Status
    )

    $percent = if ($Total -gt 0) { [math]::Round(($Current / $Total) * 100, 1) } else { 0 }
    $barLength = 40
    $filledLength = [math]::Floor(($percent / 100) * $barLength)

    $bar = "[" + ("█" * $filledLength) + (" " * ($barLength - $filledLength)) + "]"

    Write-Host "`r$TaskName $bar $percent% $Status" -NoNewline -ForegroundColor Cyan
}

function Show-Spinner {
    param([string]$Message)

    $spinnerChars = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
    $counter = 0

    while ($true) {
        $char = $spinnerChars[$counter % $spinnerChars.Length]
        Write-Host "`r$char $Message" -NoNewline -ForegroundColor Cyan
        $counter++
        Start-Sleep -Milliseconds 100

        # Check if task complete (file marker)
        if (Test-Path "C:\scripts\_machine\.spinner_stop") {
            Remove-Item "C:\scripts\_machine\.spinner_stop" -Force
            break
        }
    }

    Write-Host "`r✅ $Message - Complete" -ForegroundColor Green
}

# Main logic
switch ($Action) {
    "Start" {
        if (-not $TaskName) {
            Write-Host "❌ Start requires -TaskName" -ForegroundColor Red
            exit 1
        }

        $id = if ($ProgressId) { $ProgressId } else { [guid]::NewGuid().ToString() }

        $script:ActiveProgress[$id] = @{
            TaskName = $TaskName
            Current = 0
            Total = $Total
            StartTime = (Get-Date).ToString("o")
            Status = "Starting..."
        }

        Save-ProgressState

        Write-Host "🚀 $TaskName" -ForegroundColor Cyan
        Write-Host "   Total steps: $Total" -ForegroundColor Gray
        Write-Host ""

        Write-Output $id  # Return progress ID
        exit 0
    }

    "Update" {
        if (-not $ProgressId) {
            Write-Host "❌ Update requires -ProgressId" -ForegroundColor Red
            exit 1
        }

        Load-ProgressState

        if (-not $script:ActiveProgress.ContainsKey($ProgressId)) {
            Write-Host "❌ Progress ID not found: $ProgressId" -ForegroundColor Red
            exit 1
        }

        $progress = $script:ActiveProgress[$ProgressId]
        $progress.Current = $Current
        if ($Status) {
            $progress.Status = $Status
        }

        Show-ProgressBar -TaskName $progress.TaskName -Current $Current -Total $progress.Total -Status $progress.Status

        Save-ProgressState
        exit 0
    }

    "Complete" {
        if (-not $ProgressId) {
            Write-Host "❌ Complete requires -ProgressId" -ForegroundColor Red
            exit 1
        }

        Load-ProgressState

        if ($script:ActiveProgress.ContainsKey($ProgressId)) {
            $progress = $script:ActiveProgress[$ProgressId]
            $duration = ((Get-Date) - [DateTime]$progress.StartTime).TotalSeconds

            Write-Host "`r✅ $($progress.TaskName) - Complete ($([math]::Round($duration, 1))s)" -ForegroundColor Green
            Write-Host ""

            $script:ActiveProgress.Remove($ProgressId)
            Save-ProgressState
        }

        exit 0
    }

    "Fail" {
        if (-not $ProgressId) {
            Write-Host "❌ Fail requires -ProgressId" -ForegroundColor Red
            exit 1
        }

        Load-ProgressState

        if ($script:ActiveProgress.ContainsKey($ProgressId)) {
            $progress = $script:ActiveProgress[$ProgressId]

            Write-Host "`r❌ $($progress.TaskName) - Failed" -ForegroundColor Red
            Write-Host "   Status: $Status" -ForegroundColor Gray
            Write-Host ""

            $script:ActiveProgress.Remove($ProgressId)
            Save-ProgressState
        }

        exit 1
    }

    "Spinner" {
        if (-not $TaskName) {
            Write-Host "❌ Spinner requires -TaskName" -ForegroundColor Red
            exit 1
        }

        Show-Spinner -Message $TaskName
        exit 0
    }
}
