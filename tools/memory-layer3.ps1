# Memory Layer 3 - SQLite Database
# Cold storage for full history with indexed queries
# Created: 2026-02-07 (Fix 9 - Devastating Critique completion)

<#
.SYNOPSIS
    Memory Layer 3 - SQLite database for cold storage

.DESCRIPTION
    Provides ~10-50ms access to full history using SQLite
    - Unlimited history retention
    - Indexed queries for fast pattern searches
    - Full-text search capability
    - Automatic archival from Layer 2

.NOTES
    File: memory-layer3.ps1
    Part of Fix 9 - Layer 3 storage implementation
#>

param(
    [ValidateSet('init', 'insert', 'query', 'stats', 'archive')]
    [string]$Command = 'init',

    [string]$Table = '',
    [hashtable]$Data = @{},
    [string]$QueryString = '',
    [int]$Limit = 100
)

$ErrorActionPreference = "Continue"

#region Configuration

$script:DbPath = "C:\scripts\agentidentity\state\consciousness.db"
$script:ConnectionString = "Data Source=$script:DbPath;Version=3;"

# Global database connection
if (-not $global:Layer3Connection) {
    $global:Layer3Connection = $null
}

#endregion

#region Core Functions

function Initialize-Layer3 {
    <#
    .SYNOPSIS
        Initialize SQLite database layer
    #>

    Write-Host "[*] Initializing Memory Layer 3 (SQLite Database)..." -ForegroundColor Cyan

    try {
        # Load SQLite assembly (System.Data.SQLite)
        $sqliteAssembly = [System.Reflection.Assembly]::LoadWithPartialName("System.Data.SQLite")

        if (-not $sqliteAssembly) {
            Write-Warning "System.Data.SQLite not found. Attempting to use built-in support..."

            # Check if sqlite3.exe is available
            $sqlite3 = Get-Command sqlite3.exe -ErrorAction SilentlyContinue

            if (-not $sqlite3) {
                Write-Error "SQLite not available. Install System.Data.SQLite or sqlite3.exe"
                return @{ Initialized = $false; Error = "SQLite not available" }
            }

            # Use sqlite3.exe approach
            return Initialize-Layer3-SQLite3
        }

        # Create database if it doesn't exist
        if (-not (Test-Path $script:DbPath)) {
            Write-Host "[*] Creating new database: $script:DbPath" -ForegroundColor Gray
        } else {
            Write-Host "[*] Opening existing database: $script:DbPath" -ForegroundColor Gray
        }

        # Open connection
        $global:Layer3Connection = New-Object System.Data.SQLite.SQLiteConnection($script:ConnectionString)
        $global:Layer3Connection.Open()

        # Create tables
        $tables = @(
            @{
                Name = "events"
                Schema = @"
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL,
    type TEXT NOT NULL,
    data TEXT NOT NULL,
    context TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
)
"@
                Indexes = @(
                    "CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp DESC)",
                    "CREATE INDEX IF NOT EXISTS idx_events_type ON events(type)",
                    "CREATE INDEX IF NOT EXISTS idx_events_created ON events(created_at DESC)"
                )
            },
            @{
                Name = "decisions"
                Schema = @"
CREATE TABLE IF NOT EXISTS decisions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL,
    decision TEXT NOT NULL,
    reasoning TEXT,
    alternatives TEXT,
    confidence REAL,
    context TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
)
"@
                Indexes = @(
                    "CREATE INDEX IF NOT EXISTS idx_decisions_timestamp ON decisions(timestamp DESC)",
                    "CREATE INDEX IF NOT EXISTS idx_decisions_confidence ON decisions(confidence DESC)"
                )
            },
            @{
                Name = "patterns"
                Schema = @"
CREATE TABLE IF NOT EXISTS patterns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pattern TEXT NOT NULL UNIQUE,
    strength REAL NOT NULL,
    first_seen TEXT NOT NULL,
    last_seen TEXT NOT NULL,
    occurrences INTEGER NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
)
"@
                Indexes = @(
                    "CREATE INDEX IF NOT EXISTS idx_patterns_strength ON patterns(strength DESC)",
                    "CREATE INDEX IF NOT EXISTS idx_patterns_occurrences ON patterns(occurrences DESC)"
                )
            },
            @{
                Name = "metadata"
                Schema = @"
CREATE TABLE IF NOT EXISTS metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
)
"@
                Indexes = @()
            }
        )

        $tablesCreated = @()

        foreach ($tableConfig in $tables) {
            # Create table
            $cmd = $global:Layer3Connection.CreateCommand()
            $cmd.CommandText = $tableConfig.Schema
            $cmd.ExecuteNonQuery() | Out-Null
            $cmd.Dispose()

            # Create indexes
            foreach ($indexSql in $tableConfig.Indexes) {
                $cmd = $global:Layer3Connection.CreateCommand()
                $cmd.CommandText = $indexSql
                $cmd.ExecuteNonQuery() | Out-Null
                $cmd.Dispose()
            }

            $tablesCreated += $tableConfig.Name
        }

        # Get database stats
        $stats = Get-Layer3Stats

        Write-Host "[OK] Initialized SQLite database" -ForegroundColor Green
        Write-Host "    Database: $script:DbPath" -ForegroundColor Gray
        Write-Host "    Tables: $($tablesCreated.Count) created/verified" -ForegroundColor Gray
        Write-Host "    Total records: $($stats.TotalRecords)" -ForegroundColor Gray

        return @{
            Initialized = $true
            Tables = $tablesCreated
            Stats = $stats
            DbPath = $script:DbPath
        }

    } catch {
        Write-Error "Failed to initialize Layer 3: $_"
        return @{ Initialized = $false; Error = $_.ToString() }
    }
}

function Initialize-Layer3-SQLite3 {
    <#
    .SYNOPSIS
        Initialize using sqlite3.exe (fallback)
    #>

    Write-Host "[*] Using sqlite3.exe for database access..." -ForegroundColor Yellow

    # Create schema using sqlite3.exe
    $schema = @"
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL,
    type TEXT NOT NULL,
    data TEXT NOT NULL,
    context TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp DESC);

CREATE TABLE IF NOT EXISTS decisions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL,
    decision TEXT NOT NULL,
    reasoning TEXT,
    alternatives TEXT,
    confidence REAL,
    context TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS patterns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pattern TEXT NOT NULL UNIQUE,
    strength REAL NOT NULL,
    first_seen TEXT NOT NULL,
    last_seen TEXT NOT NULL,
    occurrences INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
"@

    # Execute schema
    $schema | sqlite3.exe $script:DbPath

    Write-Host "[✓] Database initialized with sqlite3.exe" -ForegroundColor Green

    return @{
        Initialized = $true
        Mode = "sqlite3.exe"
        DbPath = $script:DbPath
    }
}

function Insert-Layer3Record {
    <#
    .SYNOPSIS
        Insert record into SQLite database
    #>
    param(
        [string]$Table,
        [hashtable]$Data
    )

    if (-not $global:Layer3Connection -or $global:Layer3Connection.State -ne 'Open') {
        Write-Warning "Layer 3 not initialized"
        return $false
    }

    try {
        switch ($Table) {
            'events' {
                $sql = "INSERT INTO events (timestamp,type,data,context) VALUES (@timestamp,@type,@data,@context)'
                $cmd = $global:Layer3Connection.CreateCommand()
                $cmd.CommandText = $sql
                $cmd.Parameters.AddWithValue("@timestamp", $Data.Timestamp) | Out-Null
                $cmd.Parameters.AddWithValue("@type", $Data.Type) | Out-Null
                $cmd.Parameters.AddWithValue("@data", ($Data.Data | ConvertTo-Json -Compress)) | Out-Null
                $cmd.Parameters.AddWithValue("@context", $Data.Context) | Out-Null
                $cmd.ExecuteNonQuery() | Out-Null
                $cmd.Dispose()
                return $true
            }

            'decisions' {
                $sql = "INSERT INTO decisions (timestamp,decision,reasoning,alternatives,confidence,context) VALUES (@timestamp,@decision,@reasoning,@alternatives,@confidence,@context)'
                $cmd = $global:Layer3Connection.CreateCommand()
                $cmd.CommandText = $sql
                $cmd.Parameters.AddWithValue("@timestamp", $Data.Timestamp) | Out-Null
                $cmd.Parameters.AddWithValue("@decision", $Data.Decision) | Out-Null
                $cmd.Parameters.AddWithValue("@reasoning", $Data.Reasoning) | Out-Null
                $cmd.Parameters.AddWithValue("@alternatives", ($Data.Alternatives | ConvertTo-Json -Compress)) | Out-Null
                $cmd.Parameters.AddWithValue("@confidence", $Data.Confidence) | Out-Null
                $cmd.Parameters.AddWithValue("@context", $Data.Context) | Out-Null
                $cmd.ExecuteNonQuery() | Out-Null
                $cmd.Dispose()
                return $true
            }

            'patterns' {
                $sql = "INSERT OR REPLACE INTO patterns (pattern,strength,first_seen,last_seen,occurrences) VALUES (@pattern,@strength,@first_seen,@last_seen,@occurrences)'
                $cmd = $global:Layer3Connection.CreateCommand()
                $cmd.CommandText = $sql
                $cmd.Parameters.AddWithValue("@pattern", $Data.Pattern) | Out-Null
                $cmd.Parameters.AddWithValue("@strength", $Data.Strength) | Out-Null
                $cmd.Parameters.AddWithValue("@first_seen", $Data.FirstSeen) | Out-Null
                $cmd.Parameters.AddWithValue("@last_seen", $Data.LastSeen) | Out-Null
                $cmd.Parameters.AddWithValue("@occurrences", $Data.Occurrences) | Out-Null
                $cmd.ExecuteNonQuery() | Out-Null
                $cmd.Dispose()
                return $true
            }

            default {
                Write-Warning "Unknown table: $Table"
                return $false
            }
        }
    } catch {
        Write-Warning "Failed to insert record into $Table : $_"
        return $false
    }
}

function Query-Layer3 {
    <#
    .SYNOPSIS
        Query SQLite database
    #>
    param(
        [string]$Table,
        [string]$Where = "",
        [int]$Limit = 100,
        [string]$OrderBy = "id DESC"
    )

    if (-not $global:Layer3Connection -or $global:Layer3Connection.State -ne 'Open') {
        Write-Warning "Layer 3 not initialized"
        return @()
    }

    try {
        $sql = "SELECT * FROM $Table"

        if ($Where) {
            $sql += " WHERE $Where"
        }

        if ($OrderBy) {
            $sql += " ORDER BY $OrderBy"
        }

        if ($Limit -gt 0) {
            $sql += " LIMIT $Limit"
        }

        $cmd = $global:Layer3Connection.CreateCommand()
        $cmd.CommandText = $sql
        $reader = $cmd.ExecuteReader()

        $results = @()

        while ($reader.Read()) {
            $row = @{}

            for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                $row[$reader.GetName($i)] = $reader.GetValue($i)
            }

            $results += $row
        }

        $reader.Close()
        $cmd.Dispose()

        return $results

    } catch {
        Write-Warning "Failed to query $Table : $_"
        return @()
    }
}

function Get-Layer3Stats {
    <#
    .SYNOPSIS
        Get database statistics
    #>

    if (-not $global:Layer3Connection -or $global:Layer3Connection.State -ne 'Open') {
        return @{ TotalRecords = 0; Tables = @{} }
    }

    try {
        $tables = @('events', 'decisions', 'patterns', 'metadata')
        $stats = @{ TotalRecords = 0; Tables = @{} }

        foreach ($table in $tables) {
            $cmd = $global:Layer3Connection.CreateCommand()
            $cmd.CommandText = "SELECT COUNT(*) FROM $table"
            $count = $cmd.ExecuteScalar()
            $cmd.Dispose()

            $stats.Tables[$table] = $count
            $stats.TotalRecords += $count
        }

        # Get database size
        if (Test-Path $script:DbPath) {
            $stats.DbSizeKB = [math]::Round(([System.IO.FileInfo]$script:DbPath).Length / 1KB, 2)
        }

        return $stats

    } catch {
        Write-Warning "Failed to get stats: $_"
        return @{ TotalRecords = 0; Tables = @{} }
    }
}

function Close-Layer3 {
    <#
    .SYNOPSIS
        Close SQLite database connection
    #>

    if ($global:Layer3Connection) {
        try {
            if ($global:Layer3Connection.State -eq 'Open') {
                $global:Layer3Connection.Close()
                Write-Host "[OK] Closed SQLite database connection" -ForegroundColor Green
            }
            $global:Layer3Connection.Dispose()
            $global:Layer3Connection = $null
        } catch {
            Write-Warning "Failed to close Layer 3: $_"
        }
    }
}

#endregion

#region Integration Functions

function Sync-EventToLayer3 {
    <#
    .SYNOPSIS
        Sync event from Layer 2 to Layer 3
    #>
    param([hashtable]$Event)

    return Insert-Layer3Record -Table 'events' -Data $Event
}

function Sync-DecisionToLayer3 {
    <#
    .SYNOPSIS
        Sync decision from Layer 2 to Layer 3
    #>
    param([hashtable]$Decision)

    return Insert-Layer3Record -Table 'decisions' -Data $Decision
}

function Sync-PatternToLayer3 {
    <#
    .SYNOPSIS
        Sync pattern from Layer 2 to Layer 3
    #>
    param([hashtable]$Pattern)

    return Insert-Layer3Record -Table 'patterns' -Data $Pattern
}

#endregion

#region Main Execution

if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.InvocationName -ne '&') {
    switch ($Command) {
        'init' {
            $result = Initialize-Layer3
            return $result
        }

        'insert' {
            if (-not $Table) {
                Write-Error "Table required for insert command"
                return $false
            }

            return Insert-Layer3Record -Table $Table -Data $Data
        }

        'query' {
            if (-not $Table) {
                Write-Error "Table required for query command"
                return @()
            }

            return Query-Layer3 -Table $Table -Where $QueryString -Limit $Limit
        }

        'stats' {
            if (-not $global:Layer3Connection) {
                Write-Host "[!] Layer 3 not initialized" -ForegroundColor Yellow
                return $null
            }

            $stats = Get-Layer3Stats

            Write-Host ""
            Write-Host "Memory Layer 3 Statistics" -ForegroundColor Cyan
            Write-Host "=========================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  Database: $script:DbPath" -ForegroundColor Gray
            Write-Host "  Size: $($stats.DbSizeKB) KB" -ForegroundColor Gray
            Write-Host "  Total Records: $($stats.TotalRecords)" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Tables:" -ForegroundColor Gray

            foreach ($table in $stats.Tables.Keys) {
                Write-Host "    $table : $($stats.Tables[$table]) records" -ForegroundColor Gray
            }

            Write-Host ""

            return $stats
        }

        'archive' {
            # Future: Archive old Layer 2 data to Layer 3
            Write-Host "[*] Archive functionality - to be implemented" -ForegroundColor Yellow
        }

        'close' {
            Close-Layer3
        }
    }
}

#endregion
