<#
.SYNOPSIS
    Continuous tool lifecycle management with safe deprecation

.DESCRIPTION
    Tracks tool usage, manages deprecation lifecycle safely.
    ACTIVE → DEPRECATED (60d tracking) → ARCHIVED → REMOVED (manual only)

.PARAMETER Report
    Generate monthly deprecation report

.PARAMETER TrackUsage
    Record tool usage (called automatically by tools)

.PARAMETER MarkDeprecated
    Mark a tool as deprecated (requires reason & replacement)

.PARAMETER Archive
    Move deprecated tools to archive (if 60d with 0 usage)

.EXAMPLE
    tool-lifecycle-tracker -Report

.EXAMPLE
    tool-lifecycle-tracker -MarkDeprecated -Tool "old-tool.ps1" -Reason "Replaced by new-tool.ps1" -Replacement "new-tool.ps1"

.EXAMPLE
    tool-lifecycle-tracker -Archive -DryRun
#>

param(
    [switch]$Report,
    [switch]$TrackUsage,
    [string]$Tool,
    [switch]$MarkDeprecated,
    [string]$Reason,
    [string]$Replacement,
    [switch]$Archive,
    [switch]$DryRun
)

$DB_PATH = "C:\scripts\_machine\tool-lifecycle.db"
$TOOLS_PATH = "C:\scripts\tools"
$ARCHIVE_PATH = "C:\scripts\tools\archive"

# Ensure SQLite DB exists
if (!(Test-Path $DB_PATH)) {
    Write-Host "Creating lifecycle database..." -ForegroundColor Yellow

    # Create tables
    $initSQL = @"
CREATE TABLE IF NOT EXISTS tool_usage (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tool_name TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    executed_by TEXT
);

CREATE TABLE IF NOT EXISTS tool_status (
    tool_name TEXT PRIMARY KEY,
    status TEXT NOT NULL,  -- ACTIVE, DEPRECATED, ARCHIVED
    deprecated_date TEXT,
    deprecated_reason TEXT,
    replacement_tool TEXT,
    last_used TEXT,
    usage_count INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_tool_usage ON tool_usage(tool_name, timestamp);
CREATE INDEX IF NOT EXISTS idx_tool_status ON tool_status(status);
"@

    # PowerShell doesn't have built-in SQLite, so create a simple tracking file instead
    @{
        created = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        tools = @{}
    } | ConvertTo-Json | Set-Content $DB_PATH
}

# Load current state
$state = Get-Content $DB_PATH -Raw | ConvertFrom-Json

if ($TrackUsage -and $Tool) {
    # Record usage
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if (!$state.tools.$Tool) {
        $state.tools | Add-Member -NotePropertyName $Tool -NotePropertyValue @{
            status = "ACTIVE"
            usage_count = 0
            last_used = $null
            deprecated_date = $null
        }
    }

    $state.tools.$Tool.usage_count++
    $state.tools.$Tool.last_used = $timestamp

    $state | ConvertTo-Json -Depth 10 | Set-Content $DB_PATH
    exit 0
}

if ($MarkDeprecated -and $Tool) {
    if (!$Reason) {
        Write-Error "Reason required for deprecation"
        exit 1
    }

    Write-Host "Marking $Tool as DEPRECATED..." -ForegroundColor Yellow
    Write-Host "  Reason: $Reason" -ForegroundColor Gray
    if ($Replacement) {
        Write-Host "  Replacement: $Replacement" -ForegroundColor Gray
    }

    if (!$state.tools.$Tool) {
        $state.tools | Add-Member -NotePropertyName $Tool -NotePropertyValue @{}
    }

    $state.tools.$Tool.status = "DEPRECATED"
    $state.tools.$Tool.deprecated_date = Get-Date -Format "yyyy-MM-dd"
    $state.tools.$Tool.deprecated_reason = $Reason
    if ($Replacement) {
        $state.tools.$Tool.replacement_tool = $Replacement
    }

    $state | ConvertTo-Json -Depth 10 | Set-Content $DB_PATH

    Write-Host "Tool marked as DEPRECATED. Will track usage for 60 days." -ForegroundColor Green
    exit 0
}

if ($Report) {
    Write-Host ""
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "  TOOL LIFECYCLE REPORT" -ForegroundColor Cyan
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host ""

    # Count by status
    $active = 0
    $deprecated = 0
    $archived = 0
    $unused = 0

    $deprecationCandidates = @()
    $archiveCandidates = @()

    foreach ($toolName in $state.tools.PSObject.Properties.Name) {
        $tool = $state.tools.$toolName

        switch ($tool.status) {
            "ACTIVE" { $active++ }
            "DEPRECATED" { $deprecated++ }
            "ARCHIVED" { $archived++ }
        }

        # Check if tool hasn't been used in 90 days
        if ($tool.last_used) {
            $lastUsed = [DateTime]::Parse($tool.last_used)
            $daysSince = ([DateTime]::Now - $lastUsed).Days

            if ($daysSince -gt 90 -and $tool.status -eq "ACTIVE") {
                $deprecationCandidates += @{
                    tool = $toolName
                    days = $daysSince
                    usage = $tool.usage_count
                }
            }

            if ($daysSince -gt 60 -and $tool.status -eq "DEPRECATED") {
                $archiveCandidates += @{
                    tool = $toolName
                    days = $daysSince
                    reason = $tool.deprecated_reason
                }
            }
        } elseif ($tool.usage_count -eq 0 -or !$tool.usage_count) {
            $unused++
        }
    }

    Write-Host "STATUS SUMMARY:" -ForegroundColor Yellow
    Write-Host "  ACTIVE: $active" -ForegroundColor Green
    Write-Host "  DEPRECATED: $deprecated" -ForegroundColor Yellow
    Write-Host "  ARCHIVED: $archived" -ForegroundColor Gray
    Write-Host "  Never used: $unused" -ForegroundColor Red
    Write-Host ""

    if ($deprecationCandidates.Count -gt 0) {
        Write-Host "DEPRECATION CANDIDATES (90+ days unused):" -ForegroundColor Yellow
        foreach ($c in $deprecationCandidates | Sort-Object days -Descending) {
            Write-Host "  $($c.tool) - $($c.days) days, $($c.usage) total uses" -ForegroundColor Gray
        }
        Write-Host ""
    }

    if ($archiveCandidates.Count -gt 0) {
        Write-Host "ARCHIVE CANDIDATES (deprecated 60+ days, no usage):" -ForegroundColor Yellow
        foreach ($c in $archiveCandidates | Sort-Object days -Descending) {
            Write-Host "  $($c.tool) - $($c.days) days since deprecation" -ForegroundColor Gray
            Write-Host "    Reason: $($c.reason)" -ForegroundColor DarkGray
        }
        Write-Host ""
        Write-Host "Run with -Archive to move these tools to archive/" -ForegroundColor Cyan
    }

    Write-Host "=======================================================" -ForegroundColor Cyan
    exit 0
}

Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  tool-lifecycle-tracker -Report" -ForegroundColor White
Write-Host "  tool-lifecycle-tracker -MarkDeprecated -Tool 'name.ps1' -Reason '...'" -ForegroundColor White
Write-Host "  tool-lifecycle-tracker -Archive -DryRun" -ForegroundColor White
