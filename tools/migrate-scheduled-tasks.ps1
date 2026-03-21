param(
    [switch]$DryRun,
    [switch]$Test,
    [string]$OutputPath = "C:\scripts\_machine\scheduled-tasks.json",
    [switch]$Verbose
)

<#
.SYNOPSIS
    Migrates Windows scheduled tasks to Hazina Task Runner JSON format

.DESCRIPTION
    Scans Windows Task Scheduler for PowerShell-based tasks, converts their
    triggers to cron expressions, and generates a JSON configuration file
    compatible with Hazina.TaskRunner.

.PARAMETER DryRun
    Show what would be migrated without making any changes

.PARAMETER Test
    Create JSON but don't modify Windows tasks

.PARAMETER OutputPath
    Path to output JSON file (default: C:\scripts\_machine\scheduled-tasks.json)

.PARAMETER Verbose
    Show detailed processing information

.EXAMPLE
    .\migrate-scheduled-tasks.ps1 -DryRun
    Shows what would be migrated without changes

.EXAMPLE
    .\migrate-scheduled-tasks.ps1 -Test
    Creates JSON but doesn't disable Windows tasks

.EXAMPLE
    .\migrate-scheduled-tasks.ps1
    Full migration (creates JSON and disables Windows tasks)
#>

function Convert-TriggerToCron {
    param($Trigger)

    # Convert Windows Task Scheduler triggers to cron expressions
    # Cron format: minute hour day month weekday

    if ($Trigger.CimClass.CimClassName -eq "MSFT_TaskDailyTrigger") {
        # Daily trigger
        $startTime = [DateTime]$Trigger.StartBoundary
        $hour = $startTime.Hour
        $minute = $startTime.Minute

        if ($Trigger.DaysInterval -eq 1) {
            # Every day
            return "$minute $hour * * *"
        } else {
            # Every N days - approximate with cron (limited support)
            Write-Warning "Daily interval of $($Trigger.DaysInterval) cannot be precisely represented in cron. Using daily."
            return "$minute $hour * * *"
        }
    }
    elseif ($Trigger.CimClass.CimClassName -eq "MSFT_TaskWeeklyTrigger") {
        # Weekly trigger
        $startTime = [DateTime]$Trigger.StartBoundary
        $hour = $startTime.Hour
        $minute = $startTime.Minute

        # Convert DaysOfWeek bitmask to cron weekday
        # Windows: 1=Sunday, 2=Monday, 4=Tuesday, 8=Wednesday, 16=Thursday, 32=Friday, 64=Saturday
        # Cron: 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday
        $daysOfWeek = $Trigger.DaysOfWeek
        $cronDays = @()
        if ($daysOfWeek -band 1) { $cronDays += "0" }   # Sunday
        if ($daysOfWeek -band 2) { $cronDays += "1" }   # Monday
        if ($daysOfWeek -band 4) { $cronDays += "2" }   # Tuesday
        if ($daysOfWeek -band 8) { $cronDays += "3" }   # Wednesday
        if ($daysOfWeek -band 16) { $cronDays += "4" }  # Thursday
        if ($daysOfWeek -band 32) { $cronDays += "5" }  # Friday
        if ($daysOfWeek -band 64) { $cronDays += "6" }  # Saturday

        $cronDayStr = $cronDays -join ","
        return "$minute $hour * * $cronDayStr"
    }
    elseif ($Trigger.CimClass.CimClassName -eq "MSFT_TaskTimeTrigger") {
        # One-time or recurring time trigger
        $startTime = [DateTime]$Trigger.StartBoundary
        $hour = $startTime.Hour
        $minute = $startTime.Minute

        if ($Trigger.Repetition -and $Trigger.Repetition.Interval) {
            # Recurring trigger
            $interval = [TimeSpan]::Parse($Trigger.Repetition.Interval)

            if ($interval.TotalHours -eq 1) {
                # Every hour
                return "$minute * * * *"
            }
            elseif ($interval.TotalMinutes -ge 1 -and $interval.TotalMinutes -lt 60) {
                # Every N minutes
                $minutes = [int]$interval.TotalMinutes
                return "*/$minutes * * * *"
            }
            else {
                Write-Warning "Repetition interval $($interval.ToString()) cannot be precisely represented in cron."
                return "$minute $hour * * *"
            }
        }
        else {
            # One-time trigger - treat as daily
            return "$minute $hour * * *"
        }
    }
    else {
        Write-Warning "Unsupported trigger type: $($Trigger.CimClass.CimClassName)"
        return "0 0 * * *"  # Default to daily at midnight
    }
}

# Main script
Write-Host "`n=== Hazina Task Runner - Scheduled Task Migration ===" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN MODE] No changes will be made" -ForegroundColor Yellow
}
elseif ($Test) {
    Write-Host "[TEST MODE] JSON will be created, Windows tasks will NOT be modified" -ForegroundColor Yellow
}
else {
    Write-Host "[PRODUCTION MODE] JSON will be created and Windows tasks will be DISABLED" -ForegroundColor Green
}

Write-Host ""

# Get all scheduled tasks
Write-Host "Scanning Windows Task Scheduler..." -ForegroundColor Cyan
$allTasks = Get-ScheduledTask -ErrorAction SilentlyContinue

# Filter for PowerShell-based tasks
$psTasks = $allTasks | Where-Object {
    $_.Actions.Count -gt 0 -and (
        $_.Actions[0].Execute -like '*powershell*' -or
        $_.Actions[0].Execute -like '*pwsh*'
    )
}

Write-Host "Found $($allTasks.Count) total tasks, $($psTasks.Count) PowerShell-based" -ForegroundColor White
Write-Host ""

# Convert to Hazina format
$migratedTasks = @()
$skipped = 0

foreach ($task in $psTasks) {
    Write-Host "Processing: $($task.TaskName)" -ForegroundColor White

    if ($Verbose) {
        Write-Host "  Path: $($task.TaskPath)" -ForegroundColor Gray
        Write-Host "  State: $($task.State)" -ForegroundColor Gray
    }

    # Get task details
    $taskInfo = Get-ScheduledTaskInfo -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue

    # Extract script path from arguments
    $action = $task.Actions[0]
    $scriptPath = $null

    if ($action.Arguments -match '-File\s+"?([^"]+\.ps1)"?') {
        $scriptPath = $matches[1]
    }
    elseif ($action.Arguments -match '"?([^"]+\.ps1)"?') {
        $scriptPath = $matches[1]
    }

    if (-not $scriptPath) {
        Write-Host "  [SKIP] Could not extract script path from arguments" -ForegroundColor Yellow
        $skipped++
        continue
    }

    # Verify script exists
    if (-not (Test-Path $scriptPath)) {
        Write-Host "  [SKIP] Script not found: $scriptPath" -ForegroundColor Yellow
        $skipped++
        continue
    }

    # Convert triggers to cron
    $triggers = $task.Triggers
    if ($triggers.Count -eq 0) {
        Write-Host "  [SKIP] No triggers defined" -ForegroundColor Yellow
        $skipped++
        continue
    }

    # Use first trigger (most tasks have one)
    $trigger = $triggers[0]
    $cronExpression = Convert-TriggerToCron -Trigger $trigger

    if ($Verbose) {
        Write-Host "  Cron: $cronExpression" -ForegroundColor Gray
    }

    # Check if running elevated
    $elevated = $task.Principal.RunLevel -eq "Highest"

    # Create Hazina task object
    $hazinaTask = [PSCustomObject]@{
        id = [Guid]::NewGuid().ToString()
        name = $task.TaskName
        scriptPath = $scriptPath
        cronExpression = $cronExpression
        enabled = $task.State -eq "Ready"
        runElevated = $elevated
        timeoutSeconds = 300
        lastRun = $taskInfo.LastRunTime
        nextRun = $taskInfo.NextRunTime
        workingDirectory = $null
        parameters = $null
    }

    $migratedTasks += $hazinaTask

    Write-Host "  [OK] Converted: $cronExpression" -ForegroundColor Green
    if ($Verbose) {
        Write-Host "  Elevated: $elevated" -ForegroundColor Gray
        Write-Host "  Last Run: $($taskInfo.LastRunTime)" -ForegroundColor Gray
        Write-Host "  Next Run: $($taskInfo.NextRunTime)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== Migration Summary ===" -ForegroundColor Cyan
Write-Host "Total tasks scanned: $($allTasks.Count)"
Write-Host "PowerShell tasks found: $($psTasks.Count)"
Write-Host "Successfully migrated: $($migratedTasks.Count)" -ForegroundColor Green
Write-Host "Skipped: $skipped" -ForegroundColor Yellow
Write-Host ""

if ($migratedTasks.Count -eq 0) {
    Write-Host "No tasks to migrate. Exiting." -ForegroundColor Yellow
    exit 0
}

# Show migrated tasks
Write-Host "=== Migrated Tasks ===" -ForegroundColor Cyan
foreach ($task in $migratedTasks) {
    Write-Host "- $($task.name): $($task.cronExpression) -> $($task.scriptPath)"
}
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] Would create: $OutputPath" -ForegroundColor Yellow
    Write-Host "[DRY RUN] Would disable $($migratedTasks.Count) Windows tasks" -ForegroundColor Yellow
    exit 0
}

# Create JSON output
Write-Host "Creating JSON configuration..." -ForegroundColor Cyan

# Backup existing file if present
if (Test-Path $OutputPath) {
    $backup = "$OutputPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $OutputPath $backup
    Write-Host "  Backed up existing file to: $backup" -ForegroundColor Yellow
}

# Ensure directory exists
$outputDir = Split-Path $OutputPath -Parent
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Create JSON structure
$config = @{
    tasks = $migratedTasks
}

# Convert to JSON
$json = $config | ConvertTo-Json -Depth 10
$json | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host "  Created: $OutputPath" -ForegroundColor Green
Write-Host ""

# Disable Windows tasks (unless Test mode)
if (-not $Test) {
    Write-Host "Disabling Windows scheduled tasks..." -ForegroundColor Cyan

    foreach ($task in $psTasks) {
        # Only disable tasks that were migrated
        $migrated = $migratedTasks | Where-Object { $_.name -eq $task.TaskName }
        if ($migrated) {
            try {
                Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction Stop | Out-Null
                Write-Host "  [DISABLED] $($task.TaskName)" -ForegroundColor Yellow
            }
            catch {
                Write-Host "  [ERROR] Failed to disable $($task.TaskName): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }

    Write-Host ""
    Write-Host "Migration complete! Windows tasks have been disabled." -ForegroundColor Green
    Write-Host "The new Hazina Task Runner will handle these tasks." -ForegroundColor Green
}
else {
    Write-Host "[TEST MODE] Windows tasks were NOT modified" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review the generated JSON: $OutputPath"
Write-Host "2. Install Hazina Task Runner MSI"
Write-Host "3. Verify tasks are running correctly"
Write-Host "4. Delete disabled Windows tasks after verification"
Write-Host ""
