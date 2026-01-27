<#
.SYNOPSIS
    Enable/disable sandbox mode for safe experimentation

.DESCRIPTION
    Sandbox mode provides isolated environment:
    - Database: agent-activity-sandbox.db (copy)
    - Worktrees: C:\Projects\sandbox\ (isolated)
    - Changes: Can be discarded or promoted

    All tool calls check $env:AGENT_MODE to route to sandbox resources.

.PARAMETER Action
    enable: Enter sandbox mode
    disable: Exit sandbox mode (discards changes)
    status: Show current mode
    promote: Move sandbox changes to production

.PARAMETER Force
    Force action without confirmation

.EXAMPLE
    .\sandbox-mode.ps1 -Action enable

.EXAMPLE
    .\sandbox-mode.ps1 -Action promote

.EXAMPLE
    .\sandbox-mode.ps1 -Action status
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('enable', 'disable', 'status', 'promote')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Sandbox Mode Control" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$ProductionDbPath = "C:\scripts\_machine\agent-activity.db"
$SandboxDbPath = "C:\scripts\_machine\agent-activity-sandbox.db"
$ModeFile = "C:\scripts\_machine\.agent_mode"
$SandboxDir = "C:\Projects\sandbox"

function Get-CurrentMode {
    if ($env:AGENT_MODE -eq "sandbox") {
        return "sandbox"
    }
    if (Test-Path $ModeFile) {
        return (Get-Content $ModeFile -Raw).Trim()
    }
    return "production"
}

function Set-Mode {
    param([string]$Mode)
    $Mode | Set-Content $ModeFile
    $env:AGENT_MODE = $Mode
}

switch ($Action) {
    'status' {
        $mode = Get-CurrentMode

        if ($mode -eq "sandbox") {
            Write-Host "🧪 Current Mode: SANDBOX" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Resources:" -ForegroundColor Cyan
            Write-Host "  Database: $SandboxDbPath" -ForegroundColor White
            Write-Host "  Worktrees: $SandboxDir" -ForegroundColor White
            Write-Host ""

            if (Test-Path $SandboxDbPath) {
                $size = (Get-Item $SandboxDbPath).Length / 1KB
                Write-Host "  Sandbox DB size: $([math]::Round($size, 1)) KB" -ForegroundColor Gray
            }

            Write-Host ""
            Write-Host "Actions:" -ForegroundColor Cyan
            Write-Host "  .\sandbox-mode.ps1 -Action disable  # Discard changes" -ForegroundColor Gray
            Write-Host "  .\sandbox-mode.ps1 -Action promote  # Keep changes" -ForegroundColor Gray
            Write-Host ""
        } else {
            Write-Host "🏭 Current Mode: PRODUCTION" -ForegroundColor Green
            Write-Host ""
            Write-Host "Resources:" -ForegroundColor Cyan
            Write-Host "  Database: $ProductionDbPath" -ForegroundColor White
            Write-Host "  Worktrees: C:\Projects\worker-agents\" -ForegroundColor White
            Write-Host ""
            Write-Host "To experiment safely:" -ForegroundColor Cyan
            Write-Host "  .\sandbox-mode.ps1 -Action enable" -ForegroundColor Gray
            Write-Host ""
        }
    }

    'enable' {
        $mode = Get-CurrentMode

        if ($mode -eq "sandbox") {
            Write-Host "⚠️ Already in sandbox mode" -ForegroundColor Yellow
            Write-Host ""
            exit 0
        }

        Write-Host "🧪 Enabling sandbox mode..." -ForegroundColor Cyan
        Write-Host ""

        # Create sandbox directory
        if (-not (Test-Path $SandboxDir)) {
            New-Item -ItemType Directory -Path $SandboxDir -Force | Out-Null
            Write-Host "  ✅ Created sandbox directory: $SandboxDir" -ForegroundColor Green
        }

        # Copy database to sandbox
        Write-Host "  📋 Copying database to sandbox..." -ForegroundColor Gray
        Copy-Item $ProductionDbPath $SandboxDbPath -Force
        Write-Host "  ✅ Sandbox database created" -ForegroundColor Green

        # Set mode
        Set-Mode -Mode "sandbox"
        Write-Host "  ✅ Mode set to SANDBOX" -ForegroundColor Green

        Write-Host ""
        Write-Host "═══════════════════════════════════════" -ForegroundColor Yellow
        Write-Host "  🧪 SANDBOX MODE ACTIVE" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "All changes will be isolated." -ForegroundColor White
        Write-Host "Production data is protected." -ForegroundColor White
        Write-Host ""
        Write-Host "When done:" -ForegroundColor Cyan
        Write-Host "  .\sandbox-mode.ps1 -Action disable  # Discard" -ForegroundColor Gray
        Write-Host "  .\sandbox-mode.ps1 -Action promote  # Keep" -ForegroundColor Gray
        Write-Host ""
    }

    'disable' {
        $mode = Get-CurrentMode

        if ($mode -ne "sandbox") {
            Write-Host "⚠️ Not in sandbox mode" -ForegroundColor Yellow
            Write-Host ""
            exit 0
        }

        if (-not $Force) {
            Write-Host "⚠️ This will DISCARD all sandbox changes!" -ForegroundColor Red
            Write-Host ""
            $confirm = Read-Host "Are you sure? (yes/no)"
            if ($confirm -ne "yes") {
                Write-Host "Cancelled" -ForegroundColor Gray
                exit 0
            }
            Write-Host ""
        }

        Write-Host "🗑️ Disabling sandbox mode..." -ForegroundColor Cyan
        Write-Host ""

        # Remove sandbox database
        if (Test-Path $SandboxDbPath) {
            Remove-Item $SandboxDbPath -Force
            Write-Host "  ✅ Sandbox database removed" -ForegroundColor Green
        }

        # Clean sandbox directory
        if (Test-Path $SandboxDir) {
            Get-ChildItem $SandboxDir -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-Host "  ✅ Sandbox directory cleaned" -ForegroundColor Green
        }

        # Reset mode
        Set-Mode -Mode "production"
        Write-Host "  ✅ Mode set to PRODUCTION" -ForegroundColor Green

        Write-Host ""
        Write-Host "═══════════════════════════════════════" -ForegroundColor Green
        Write-Host "  🏭 PRODUCTION MODE ACTIVE" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "All sandbox changes have been discarded." -ForegroundColor White
        Write-Host ""
    }

    'promote' {
        $mode = Get-CurrentMode

        if ($mode -ne "sandbox") {
            Write-Host "⚠️ Not in sandbox mode - nothing to promote" -ForegroundColor Yellow
            Write-Host ""
            exit 0
        }

        if (-not $Force) {
            Write-Host "⚠️ This will MERGE sandbox changes into production!" -ForegroundColor Yellow
            Write-Host ""
            $confirm = Read-Host "Are you sure? (yes/no)"
            if ($confirm -ne "yes") {
                Write-Host "Cancelled" -ForegroundColor Gray
                exit 0
            }
            Write-Host ""
        }

        Write-Host "📤 Promoting sandbox changes to production..." -ForegroundColor Cyan
        Write-Host ""

        # Backup production database
        $backupPath = "$ProductionDbPath.pre-promote-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $ProductionDbPath $backupPath
        Write-Host "  ✅ Production backup created: $backupPath" -ForegroundColor Green

        # Replace production with sandbox
        Copy-Item $SandboxDbPath $ProductionDbPath -Force
        Write-Host "  ✅ Sandbox database promoted to production" -ForegroundColor Green

        # Clean sandbox
        Remove-Item $SandboxDbPath -Force
        Write-Host "  ✅ Sandbox database removed" -ForegroundColor Green

        # Reset mode
        Set-Mode -Mode "production"
        Write-Host "  ✅ Mode set to PRODUCTION" -ForegroundColor Green

        Write-Host ""
        Write-Host "═══════════════════════════════════════" -ForegroundColor Green
        Write-Host "  ✅ PROMOTION COMPLETE" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "Sandbox changes are now in production." -ForegroundColor White
        Write-Host "Backup available at: $backupPath" -ForegroundColor Gray
        Write-Host ""
    }
}
