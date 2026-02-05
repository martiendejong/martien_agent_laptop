#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Nightly backup of artrevisionist store data with 5-day retention
.DESCRIPTION
    Creates timestamped backups of C:\stores\artrevisionist\data and projects
    Maintains only the 5 most recent backups (rotating deletion of older backups)
.EXAMPLE
    .\backup-artrevisionist.ps1
    .\backup-artrevisionist.ps1 -DryRun
#>

param(
    [string]$SourcePath = "C:\stores\artrevisionist",
    [string]$BackupRoot = "C:\backups\artrevisionist",
    [int]$MaxBackups = 5,
    [switch]$DryRun,
    # Exclude application code and logs - only backup DATA
    [string[]]$ExcludeDirs = @(
        ".git",
        "bin",
        "obj",
        "logs",
        "backend",
        "backend - Copy",
        "backend - Copy (2)",
        "www",
        "www - Copy",
        "www - Copy (2)",
        "projects - Copy",
        "projects - Copy (2)",
        "__pycache__",
        "node_modules"
    ),
    # Only backup these critical directories
    [string[]]$IncludeDirs = @("data", "projects", "config")
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Ensure backup root exists for log file
if (-not (Test-Path $BackupRoot)) {
    New-Item -Path $BackupRoot -ItemType Directory -Force | Out-Null
}
$logFile = Join-Path $BackupRoot "backup.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $logMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $logMessage
    if (-not $DryRun) {
        Add-Content -Path $logFile -Value $logMessage
    }
}

try {
    Write-Log "=== ARTREVISIONIST BACKUP STARTED ===" "INFO"
    Write-Log "Source: $SourcePath"
    Write-Log "Backup Root: $BackupRoot"
    Write-Log "Max Backups: $MaxBackups"
    Write-Log "Include Dirs: $($IncludeDirs -join ', ')"

    if ($DryRun) {
        Write-Log "DRY RUN MODE - No changes will be made" "WARN"
    }

    # Verify source exists
    if (-not (Test-Path $SourcePath)) {
        Write-Log "Source path does not exist: $SourcePath" "ERROR"
        exit 1
    }

    # Create backup root if it doesn't exist
    if (-not (Test-Path $BackupRoot)) {
        Write-Log "Creating backup root directory: $BackupRoot"
        if (-not $DryRun) {
            New-Item -Path $BackupRoot -ItemType Directory -Force | Out-Null
        }
    }

    # Create backup directory with timestamp
    $backupName = "backup_$timestamp"
    $backupPath = Join-Path $BackupRoot $backupName

    Write-Log "Creating backup: $backupName"

    if (-not $DryRun) {
        # Create backup directory
        New-Item -Path $backupPath -ItemType Directory -Force | Out-Null

        # Copy only the included directories
        foreach ($includeDir in $IncludeDirs) {
            $sourceDirPath = Join-Path $SourcePath $includeDir
            if (Test-Path $sourceDirPath) {
                $destDirPath = Join-Path $backupPath $includeDir
                Write-Log "Backing up: $includeDir"

                # Copy the entire directory
                Copy-Item -Path $sourceDirPath -Destination $destDirPath -Recurse -Force

                # Calculate size of this directory
                $dirSize = (Get-ChildItem -Path $destDirPath -Recurse -ErrorAction SilentlyContinue |
                          Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                $dirSizeMB = [math]::Round($dirSize / 1MB, 2)
                Write-Log "  ${includeDir}: $dirSizeMB MB"
            } else {
                Write-Log "  Skipping (not found): $includeDir" "WARN"
            }
        }

        # Get total backup size
        $backupSize = (Get-ChildItem -Path $backupPath -Recurse -ErrorAction SilentlyContinue |
                      Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $backupSizeMB = [math]::Round($backupSize / 1MB, 2)
        Write-Log "Backup created successfully: $backupSizeMB MB total"
    } else {
        Write-Log "[DRY RUN] Would create backup at: $backupPath"
        foreach ($includeDir in $IncludeDirs) {
            $sourceDirPath = Join-Path $SourcePath $includeDir
            if (Test-Path $sourceDirPath) {
                Write-Log "[DRY RUN] Would backup: $includeDir"
            }
        }
    }

    # Get all existing backups (sorted by creation time, oldest first)
    $existingBackups = Get-ChildItem -Path $BackupRoot -Directory -Filter "backup_*" |
                       Sort-Object CreationTime

    Write-Log "Found $($existingBackups.Count) existing backups"

    # Delete old backups if we exceed the limit
    if ($existingBackups.Count -gt $MaxBackups) {
        $backupsToDelete = $existingBackups | Select-Object -First ($existingBackups.Count - $MaxBackups)

        Write-Log "Removing $($backupsToDelete.Count) old backup(s) to maintain $MaxBackups limit"

        foreach ($backup in $backupsToDelete) {
            Write-Log "Deleting old backup: $($backup.Name)"
            if (-not $DryRun) {
                Remove-Item -Path $backup.FullName -Recurse -Force
            } else {
                Write-Log "[DRY RUN] Would delete: $($backup.FullName)"
            }
        }
    }

    # List current backups
    $currentBackups = Get-ChildItem -Path $BackupRoot -Directory -Filter "backup_*" |
                      Sort-Object CreationTime -Descending

    Write-Log "Current backups ($($currentBackups.Count)):"
    foreach ($backup in $currentBackups) {
        $size = (Get-ChildItem -Path $backup.FullName -Recurse -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        Write-Log "  - $($backup.Name): $sizeMB MB ($(Get-Date $backup.CreationTime -Format 'yyyy-MM-dd HH:mm'))"
    }

    Write-Log "=== BACKUP COMPLETED SUCCESSFULLY ===" "INFO"
    exit 0

} catch {
    Write-Log "BACKUP FAILED: $_" "ERROR"
    Write-Log $_.ScriptStackTrace "ERROR"
    exit 1
}
