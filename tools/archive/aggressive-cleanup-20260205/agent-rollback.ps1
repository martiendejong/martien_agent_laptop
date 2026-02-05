<#
.SYNOPSIS
    Rollback system to previous checkpoint

.DESCRIPTION
    Restores agent system state from checkpoint:
    - Database
    - Worktree pool    - Configuration files
    - Validates tool changes

    WARNING: This will overwrite current state!

.PARAMETER Tag
    Checkpoint tag with timestamp (from agent-checkpoint.ps1 output)

.PARAMETER Force
    Skip confirmation prompt

.PARAMETER ListCheckpoints
    List all available checkpoints

.EXAMPLE
    .\agent-rollback.ps1 -ListCheckpoints

.EXAMPLE
    .\agent-rollback.ps1 -Tag "before-phase4-20260127-001234"

.EXAMPLE
    .\agent-rollback.ps1 -Tag "before-phase4-20260127-001234" -Force
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Tag,

    [Parameter(Mandatory=$false)]
    [switch]$Force,

    [Parameter(Mandatory=$false)]
    [switch]$ListCheckpoints
)

$ErrorActionPreference = 'Stop'

$checkpointsRoot = "C:\scripts\_machine\checkpoints"

# List checkpoints
if ($ListCheckpoints) {
    Write-Host "`nAvailable Checkpoints:" -ForegroundColor Cyan
    Write-Host "=====================`n" -ForegroundColor Cyan

    $checkpoints = Get-ChildItem $checkpointsRoot -Directory | Sort-Object Name -Descending

    if ($checkpoints) {
        foreach ($cp in $checkpoints) {
            $manifestPath = "$($cp.FullName)\manifest.json"
            if (Test-Path $manifestPath) {
                $manifest = Get-Content $manifestPath | ConvertFrom-Json
                Write-Host "  $($cp.Name)" -ForegroundColor White
                Write-Host "    Created: $($manifest.created_at)" -ForegroundColor Gray
                if ($manifest.description) {
                    Write-Host "    Description: $($manifest.description)" -ForegroundColor Gray
                }
                Write-Host "    Tools: $($manifest.tool_count)" -ForegroundColor Gray
                Write-Host ""
            }
        }
    } else {
        Write-Host "  No checkpoints found.`n" -ForegroundColor Yellow
    }
    exit 0
}

# Validate Tag provided
if (-not $Tag) {
    Write-Host "Error: -Tag parameter required (or use -ListCheckpoints)" -ForegroundColor Red
    Write-Host "Run: .\agent-rollback.ps1 -ListCheckpoints" -ForegroundColor Yellow
    exit 1
}

$checkpointDir = "$checkpointsRoot\$Tag"
$manifestPath = "$checkpointDir\manifest.json"

# Validate checkpoint exists
if (-not (Test-Path $checkpointDir)) {
    Write-Host "Error: Checkpoint not found: $Tag" -ForegroundColor Red
    Write-Host "Run: .\agent-rollback.ps1 -ListCheckpoints" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $manifestPath)) {
    Write-Host "Error: Manifest missing for checkpoint: $Tag" -ForegroundColor Red
    exit 1
}

# Load manifest
$manifest = Get-Content $manifestPath | ConvertFrom-Json

Write-Host "`n=== Rollback System to Checkpoint ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Tag:         $($manifest.tag)" -ForegroundColor White
Write-Host "  Created:     $($manifest.created_at)" -ForegroundColor White
if ($manifest.description) {
    Write-Host "  Description: $($manifest.description)" -ForegroundColor White
}
Write-Host "  Machine:     $($manifest.machine)" -ForegroundColor Gray
Write-Host "  Tool count:  $($manifest.tool_count)" -ForegroundColor Gray
Write-Host ""

# Confirmation
if (-not $Force) {
    Write-Host "WARNING: This will overwrite current system state!" -ForegroundColor Red
    Write-Host ""
    $confirm = Read-Host "Continue? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "Rollback cancelled." -ForegroundColor Yellow
        exit 0
    }
    Write-Host ""
}

try {
    # Restore database
    Write-Host "[1/5] Restoring database..." -ForegroundColor Yellow
    $dbSource = "$checkpointDir\agent-activity.db"
    $dbDest = "C:\scripts\_machine\agent-activity.db"
    if (Test-Path $dbSource) {
        # Backup current database first
        if (Test-Path $dbDest) {
            Copy-Item $dbDest "$dbDest.pre-rollback.backup"
        }
        Copy-Item $dbSource $dbDest -Force
        Write-Host "  Database restored" -ForegroundColor Gray
    }

    # Restore worktree pool
    Write-Host "[2/5] Restoring worktree pool..." -ForegroundColor Yellow
    $poolSource = "$checkpointDir\worktrees.pool.md"
    $poolDest = "C:\scripts\_machine\worktrees.pool.md"
    if (Test-Path $poolSource) {
        if (Test-Path $poolDest) {
            Copy-Item $poolDest "$poolDest.pre-rollback.backup"
        }
        Copy-Item $poolSource $poolDest -Force
        Write-Host "  Worktree pool restored" -ForegroundColor Gray
    }

    # Restore config files
    Write-Host "[3/5] Restoring configuration..." -ForegroundColor Yellow
    $configMappings = @{
        "CLAUDE.md" = "C:\scripts\CLAUDE.md"
        "PERSONAL_INSIGHTS.md" = "C:\scripts\_machine\PERSONAL_INSIGHTS.md"
        "reflection.log.md" = "C:\scripts\_machine\reflection.log.md"
    }

    foreach ($pair in $configMappings.GetEnumerator()) {
        $source = "$checkpointDir\$($pair.Key)"
        $dest = $pair.Value
        if (Test-Path $source) {
            if (Test-Path $dest) {
                Copy-Item $dest "$dest.pre-rollback.backup"
            }
            Copy-Item $source $dest -Force
        }
    }
    Write-Host "  Config files restored" -ForegroundColor Gray

    # Check tool changes
    Write-Host "[4/5] Validating tools..." -ForegroundColor Yellow
    $currentHashes = @{}
    Get-ChildItem "C:\scripts\tools\*.ps1" | ForEach-Object {
        $hash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
        $currentHashes[$_.Name] = $hash
    }

    $changedTools = @()
    $newTools = @()
    $deletedTools = @()

    # Check for changes and deletions
    foreach ($pair in $manifest.tool_hashes.PSObject.Properties) {
        $toolName = $pair.Name
        $oldHash = $pair.Value
        if ($currentHashes.ContainsKey($toolName)) {
            if ($currentHashes[$toolName] -ne $oldHash) {
                $changedTools += $toolName
            }
        } else {
            $deletedTools += $toolName
        }
    }

    # Check for new tools
    foreach ($tool in $currentHashes.Keys) {
        if (-not ($manifest.tool_hashes.PSObject.Properties.Name -contains $tool)) {
            $newTools += $tool
        }
    }

    if ($changedTools.Count -gt 0) {
        Write-Host "  Changed tools: $($changedTools.Count)" -ForegroundColor Yellow
        $changedTools | ForEach-Object { Write-Host "    - $_" -ForegroundColor Yellow }
    }
    if ($newTools.Count -gt 0) {
        Write-Host "  New tools (since checkpoint): $($newTools.Count)" -ForegroundColor Cyan
        $newTools | ForEach-Object { Write-Host "    - $_" -ForegroundColor Cyan }
    }
    if ($deletedTools.Count -gt 0) {
        Write-Host "  Deleted tools (in checkpoint): $($deletedTools.Count)" -ForegroundColor Magenta
        $deletedTools | ForEach-Object { Write-Host "    - $_" -ForegroundColor Magenta }
    }

    if ($changedTools.Count -eq 0 -and $newTools.Count -eq 0 -and $deletedTools.Count -eq 0) {
        Write-Host "  Tools unchanged" -ForegroundColor Gray
    }

    # Log rollback
    Write-Host "[5/5] Logging rollback..." -ForegroundColor Yellow
    if (Test-Path $dbDest) {
        $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        $agentId = if (Test-Path "C:\scripts\_machine\.current_agent_id") {
            Get-Content "C:\scripts\_machine\.current_agent_id" -Raw | ForEach-Object { $_.Trim() }
        } else { "system" }

        $sql = @"
INSERT INTO activity_log (agent_id, timestamp, action_type, message, metadata)
VALUES ('$agentId', '$now', 'rollback_completed', 'Rolled back to: $Tag', '{\"tag\":\"$Tag\",\"timestamp\":\"$($manifest.timestamp)\"}');
"@

        $sql | & "C:\scripts\_machine\sqlite3.exe" $dbDest 2>&1 | Out-Null
    }

    Write-Host ""
    Write-Host "Rollback completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "System state restored to: $($manifest.created_at)" -ForegroundColor Cyan
    Write-Host "Backups created: *.pre-rollback.backup" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "Rollback failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Your system may be in an inconsistent state." -ForegroundColor Yellow
    Write-Host "Check *.pre-rollback.backup files for recovery." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
