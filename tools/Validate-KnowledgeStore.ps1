# Knowledge Store Validation & Backup (R23-001)
# Validates schema and maintains rolling backups

param(
    [switch]$Validate,
    [switch]$Backup,
    [switch]$Restore,
    [int]$BackupId
)

$KnowledgeStore = "C:\scripts\_machine\knowledge-store.yaml"
$BackupDir = "C:\scripts\_machine\backups"
$MaxBackups = 5

function Get-Schema {
    # Define expected schema structure
    return @{
        required_sections = @('metadata', 'predictions', 'patterns', 'clusters', 'confidence', 'events', 'statistics')
        predictions_keys = @('weights', 'accuracy', 'history')
        patterns_keys = @('temporal', 'sequential', 'contextual', 'workflow')
        clusters_keys = @('groups', 'metadata')
        confidence_keys = @('thresholds', 'contexts')
        events_keys = @('queue', 'subscribers')
    }
}

function Test-KnowledgeStoreSchema {
    if (!(Test-Path $KnowledgeStore)) {
        Write-Host "Knowledge store does not exist" -ForegroundColor Red
        return $false
    }

    try {
        $store = Get-Content $KnowledgeStore -Raw | ConvertFrom-Yaml
    }
    catch {
        Write-Host "Failed to parse YAML: $_" -ForegroundColor Red
        return $false
    }

    $schema = Get-Schema
    $valid = $true

    # Check required top-level sections
    foreach ($section in $schema.required_sections) {
        if (!$store.PSObject.Properties.Name.Contains($section)) {
            Write-Host "Missing required section: $section" -ForegroundColor Red
            $valid = $false
        }
    }

    # Check predictions structure
    if ($store.predictions) {
        foreach ($key in $schema.predictions_keys) {
            if (!$store.predictions.PSObject.Properties.Name.Contains($key)) {
                Write-Host "Missing predictions.$key" -ForegroundColor Yellow
            }
        }
    }

    # Check patterns structure
    if ($store.patterns) {
        foreach ($key in $schema.patterns_keys) {
            if (!$store.patterns.PSObject.Properties.Name.Contains($key)) {
                Write-Host "Missing patterns.$key" -ForegroundColor Yellow
            }
        }
    }

    if ($valid) {
        Write-Host "Schema validation passed" -ForegroundColor Green
    }
    else {
        Write-Host "Schema validation failed" -ForegroundColor Red
    }

    return $valid
}

function New-KnowledgeStoreBackup {
    if (!(Test-Path $KnowledgeStore)) {
        Write-Host "Nothing to backup" -ForegroundColor Yellow
        return
    }

    # Create backup directory if needed
    if (!(Test-Path $BackupDir)) {
        New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
    }

    # Create timestamped backup
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupPath = Join-Path $BackupDir "knowledge-store.$timestamp.yaml"

    Copy-Item -Path $KnowledgeStore -Destination $backupPath
    Write-Host "Backup created: $backupPath" -ForegroundColor Green

    # Cleanup old backups (keep only MaxBackups)
    $backups = Get-ChildItem -Path $BackupDir -Filter "knowledge-store.*.yaml" |
        Sort-Object LastWriteTime -Descending

    if ($backups.Count -gt $MaxBackups) {
        $toDelete = $backups | Select-Object -Skip $MaxBackups
        $toDelete | ForEach-Object {
            Remove-Item $_.FullName
            Write-Host "Removed old backup: $($_.Name)" -ForegroundColor Cyan
        }
    }
}

function Restore-KnowledgeStoreBackup {
    param([int]$Id)

    if (!(Test-Path $BackupDir)) {
        Write-Host "No backups found" -ForegroundColor Red
        return
    }

    $backups = Get-ChildItem -Path $BackupDir -Filter "knowledge-store.*.yaml" |
        Sort-Object LastWriteTime -Descending

    if ($backups.Count -eq 0) {
        Write-Host "No backups available" -ForegroundColor Red
        return
    }

    if ($Id -eq 0) {
        # Show available backups
        Write-Host "`nAvailable backups:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $backups.Count; $i++) {
            Write-Host "  [$i] $($backups[$i].Name) - $($backups[$i].LastWriteTime)"
        }
        Write-Host "`nUse -Restore -BackupId <n> to restore"
        return
    }

    if ($Id -ge $backups.Count) {
        Write-Host "Invalid backup ID" -ForegroundColor Red
        return
    }

    $backupToRestore = $backups[$Id]

    # Validate backup before restoring
    Write-Host "Validating backup..." -ForegroundColor Yellow
    $tempStore = $KnowledgeStore
    $KnowledgeStore = $backupToRestore.FullName
    $valid = Test-KnowledgeStoreSchema
    $KnowledgeStore = $tempStore

    if (!$valid) {
        Write-Host "Backup is invalid, not restoring" -ForegroundColor Red
        return
    }

    # Create backup of current before restoring
    New-KnowledgeStoreBackup

    # Restore
    Copy-Item -Path $backupToRestore.FullName -Destination $KnowledgeStore -Force
    Write-Host "Restored from: $($backupToRestore.Name)" -ForegroundColor Green
}

function Write-KnowledgeStore {
    param([object]$Data)

    # Validate before writing
    $tempFile = "$KnowledgeStore.tmp"
    $Data | ConvertTo-Yaml | Out-File -FilePath $tempFile -Encoding UTF8

    # Validate temp file
    $script:KnowledgeStore = $tempFile
    $valid = Test-KnowledgeStoreSchema
    $script:KnowledgeStore = "C:\scripts\_machine\knowledge-store.yaml"

    if (!$valid) {
        Remove-Item $tempFile
        throw "Data failed validation, not writing"
    }

    # Backup current
    New-KnowledgeStoreBackup

    # Atomic write
    Move-Item -Path $tempFile -Destination $KnowledgeStore -Force
    Write-Host "Knowledge store updated (validated + backed up)" -ForegroundColor Green
}

# Main execution
if ($Validate) {
    Test-KnowledgeStoreSchema
}
elseif ($Backup) {
    New-KnowledgeStoreBackup
}
elseif ($Restore) {
    Restore-KnowledgeStoreBackup -Id $BackupId
}
else {
    Write-Host "Usage: Validate-KnowledgeStore.ps1 [-Validate] [-Backup] [-Restore [-BackupId <n>]]"
    Write-Host "  -Validate        : Check schema integrity"
    Write-Host "  -Backup          : Create manual backup"
    Write-Host "  -Restore         : List available backups"
    Write-Host "  -Restore -BackupId <n> : Restore specific backup"
}

# Export function for use by other scripts
Export-ModuleMember -Function Write-KnowledgeStore
