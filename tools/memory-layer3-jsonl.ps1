# Memory Layer 3 - JSONL Cold Storage
# Simple file-based storage for full history
# Created: 2026-02-07 (Fix 9 - Simplified approach)

<#
.SYNOPSIS
    Memory Layer 3 - JSONL file storage for cold storage

.DESCRIPTION
    Provides file-based storage using JSONL (JSON Lines) format
    - Unlimited history retention
    - Simple append-only writes
    - Fast sequential reads
    - No external dependencies

.NOTES
    File: memory-layer3-jsonl.ps1
    Part of Fix 9 - Layer 3 storage (simplified)
#>

param(
    [ValidateSet('init', 'append', 'query', 'stats')]
    [string]$Command = 'init'
)

$ErrorActionPreference = "Continue"

#region Configuration

$script:StoragePath = "C:\scripts\agentidentity\state\layer3\"
$script:Files = @{
    Events = "events.jsonl"
    Decisions = "decisions.jsonl"
    Patterns = "patterns.jsonl"
}

#endregion

#region Core Functions

function Initialize-Layer3-JSONL {
    Write-Host "[*] Initializing Memory Layer 3 (JSONL Storage)..." -ForegroundColor Cyan

    # Ensure directory exists
    if (-not (Test-Path $script:StoragePath)) {
        New-Item -ItemType Directory -Path $script:StoragePath -Force | Out-Null
    }

    # Create files if they don't exist
    foreach ($file in $script:Files.Values) {
        $fullPath = Join-Path $script:StoragePath $file
        if (-not (Test-Path $fullPath)) {
            "" | Out-File -FilePath $fullPath -Encoding UTF8
        }
    }

    $stats = Get-Layer3-JSONL-Stats

    Write-Host "[OK] Initialized JSONL storage" -ForegroundColor Green
    Write-Host "    Storage: $script:StoragePath" -ForegroundColor Gray
    Write-Host "    Files: $($script:Files.Count)" -ForegroundColor Gray
    Write-Host "    Total records: $($stats.TotalRecords)" -ForegroundColor Gray

    return @{
        Initialized = $true
        StoragePath = $script:StoragePath
        Stats = $stats
    }
}

function Append-Layer3-JSONL {
    param(
        [string]$Type,
        [hashtable]$Data
    )

    if (-not $script:Files.ContainsKey($Type)) {
        Write-Warning "Unknown type: $Type"
        return $false
    }

    try {
        $fullPath = Join-Path $script:StoragePath $script:Files[$Type]

        # Add timestamp if not present
        if (-not $Data.ContainsKey('Timestamp')) {
            $Data.Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }

        # Convert to JSON and append
        $json = $Data | ConvertTo-Json -Compress
        $json | Add-Content -Path $fullPath -Encoding UTF8

        return $true

    } catch {
        Write-Warning "Failed to append to $Type : $_"
        return $false
    }
}

function Query-Layer3-JSONL {
    param(
        [string]$Type,
        [int]$Limit = 100,
        [string]$Filter = ""
    )

    if (-not $script:Files.ContainsKey($Type)) {
        Write-Warning "Unknown type: $Type"
        return @()
    }

    try {
        $fullPath = Join-Path $script:StoragePath $script:Files[$Type]

        if (-not (Test-Path $fullPath)) {
            return @()
        }

        # Read last N lines (most recent)
        $lines = Get-Content -Path $fullPath -Tail $Limit -Encoding UTF8 |
                 Where-Object { $_ -and $_.Trim() } |
                 ForEach-Object { $_ | ConvertFrom-Json }

        return $lines

    } catch {
        Write-Warning "Failed to query $Type : $_"
        return @()
    }
}

function Get-Layer3-JSONL-Stats {
    $stats = @{
        TotalRecords = 0
        Files = @{}
        TotalSizeKB = 0
    }

    foreach ($type in $script:Files.Keys) {
        $fullPath = Join-Path $script:StoragePath $script:Files[$type]

        if (Test-Path $fullPath) {
            $content = Get-Content -Path $fullPath -Encoding UTF8
            $lineCount = ($content | Where-Object { $_ -and $_.Trim() }).Count

            $sizeKB = [math]::Round(([System.IO.FileInfo]$fullPath).Length / 1KB, 2)

            $stats.Files[$type] = @{
                Records = $lineCount
                SizeKB = $sizeKB
            }

            $stats.TotalRecords += $lineCount
            $stats.TotalSizeKB += $sizeKB
        } else {
            $stats.Files[$type] = @{
                Records = 0
                SizeKB = 0
            }
        }
    }

    return $stats
}

#endregion

#region Integration Functions

function Sync-EventToLayer3-JSONL {
    param([hashtable]$Event)
    return Append-Layer3-JSONL -Type "Events" -Data $Event
}

function Sync-DecisionToLayer3-JSONL {
    param([hashtable]$Decision)
    return Append-Layer3-JSONL -Type "Decisions" -Data $Decision
}

function Sync-PatternToLayer3-JSONL {
    param([hashtable]$Pattern)
    return Append-Layer3-JSONL -Type "Patterns" -Data $Pattern
}

#endregion

#region Main Execution

if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.InvocationName -ne '&') {
    switch ($Command) {
        'init' {
            $result = Initialize-Layer3-JSONL
            return $result
        }

        'append' {
            # Example usage
            Write-Host "Append command - use Sync-* functions for integration"
        }

        'query' {
            # Example usage
            Write-Host "Query command - use Query-Layer3-JSONL function"
        }

        'stats' {
            $stats = Get-Layer3-JSONL-Stats

            Write-Host ""
            Write-Host "Memory Layer 3 Statistics" -ForegroundColor Cyan
            Write-Host "=========================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  Storage: $script:StoragePath" -ForegroundColor Gray
            Write-Host "  Total Size: $($stats.TotalSizeKB) KB" -ForegroundColor Gray
            Write-Host "  Total Records: $($stats.TotalRecords)" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Files:" -ForegroundColor Gray

            foreach ($type in $stats.Files.Keys) {
                $f = $stats.Files[$type]
                Write-Host "    $type : $($f.Records) records ($($f.SizeKB) KB)" -ForegroundColor Gray
            }

            Write-Host ""

            return $stats
        }
    }
}

#endregion
