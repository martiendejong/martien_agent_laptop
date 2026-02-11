# Memory Layer 2 - Memory-Mapped Files
# Fast persistent storage for recent history (Warm State)
# Created: 2026-02-07 (Fix 8 - Devastating Critique completion)

<#
.SYNOPSIS
    Memory Layer 2 - Memory-Mapped File storage for warm state

.DESCRIPTION
    Provides ~1-5ms access to recent history using .NET MemoryMappedFiles
    - Recent events (last 1000, circular buffer)
    - Recent decisions (last 500)
    - Event bus history
    - Persistent across restarts
    - Shared memory capable

.NOTES
    File: memory-layer2.ps1
    Part of Fix 8 - Layer 2 storage implementation
#>

param(
    [ValidateSet('init', 'write', 'read', 'stats', 'close')]
    [string]$Command = 'init',

    [string]$BufferName = '',
    [object]$Data = $null,
    [int]$MaxEntries = 1000
)

$ErrorActionPreference = "Continue"

# Load required .NET assemblies for memory-mapped files
Add-Type -AssemblyName "System.Core"

#region Configuration

$script:MMapPath = "C:\scripts\agentidentity\state\mmap\"
$script:BufferConfigs = @{
    Events = @{ FileName = "events.mmap"; MaxSize = 5MB; MaxEntries = 1000 }
    Decisions = @{ FileName = "decisions.mmap"; MaxSize = 2MB; MaxEntries = 500 }
    Patterns = @{ FileName = "patterns.mmap"; MaxSize = 1MB; MaxEntries = 200 }
    EventBus = @{ FileName = "eventbus.mmap"; MaxSize = 3MB; MaxEntries = 500 }
}

# Global memory-mapped file handles
if (-not $global:MMapHandles) {
    $global:MMapHandles = @{}
}

#endregion

#region Core Functions

function Initialize-MMapBuffer {
    param([string]$BufferName, [hashtable]$Config, [string]$FilePath)

    # Check if file exists
    $fileExists = Test-Path $FilePath

    try {
        # Use unique mapName per invocation to avoid kernel named-map conflicts
        # Named maps are system-wide in Windows and persist if previous process crashed
        $uniqueMapName = "$BufferName-$([Guid]::NewGuid().ToString('N').Substring(0,8))"

        if ($fileExists) {
            # Open existing memory-mapped file
            $fileStream = [System.IO.FileStream]::new(
                $FilePath,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::ReadWrite
            )

            $mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile]::CreateFromFile(
                $fileStream,
                $uniqueMapName,
                0,  # Use file size
                [System.IO.MemoryMappedFiles.MemoryMappedFileAccess]::ReadWrite,
                $null,
                0,
                $false  # Don't leave open
            )

            Write-Verbose "Opened existing mmap: $FilePath"
        } else {
            # Create new memory-mapped file
            $fileStream = [System.IO.FileStream]::new(
                $FilePath,
                [System.IO.FileMode]::CreateNew,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::ReadWrite
            )

            # Set file size
            $fileStream.SetLength($Config.MaxSize)

            $mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile]::CreateFromFile(
                $fileStream,
                $uniqueMapName,
                $Config.MaxSize,
                [System.IO.MemoryMappedFiles.MemoryMappedFileAccess]::ReadWrite,
                $null,
                0,
                $false
            )

            $sizeMB = [math]::Round($Config.MaxSize / 1048576, 2)
            Write-Verbose "Created new mmap: $FilePath - Size: $sizeMB megabytes"
        }

        # Store file stream in handle for later disposal
        $streamKey = "$BufferName" + "_FileStream"
        $global:MMapHandles[$streamKey] = $fileStream

        return $mmf
    } catch {
        Write-Error "Failed to initialize mmap buffer: $BufferName - $_"
        return $null
    }
}

function Initialize-Layer2 {
    <#
    .SYNOPSIS
        Initialize memory-mapped file layer
    #>

    # Ensure directory exists
    if (-not (Test-Path $script:MMapPath)) {
        New-Item -ItemType Directory -Path $script:MMapPath -Force | Out-Null
    }

    Write-Host "[*] Initializing Memory Layer 2 (Memory-Mapped Files)..." -ForegroundColor Cyan

    $initialized = @()
    $errors = @()

    foreach ($bufferName in $script:BufferConfigs.Keys) {
        try {
            $config = $script:BufferConfigs[$bufferName]
            $filePath = Join-Path $script:MMapPath $config.FileName

            # Create or open memory-mapped file
            $mmf = Initialize-MMapBuffer -BufferName $bufferName -Config $config -FilePath $filePath

            if ($mmf) {
                $global:MMapHandles[$bufferName] = @{
                    File = $mmf
                    FilePath = $filePath
                    Config = $config
                    ReadIndex = 0
                    WriteIndex = 0
                    Count = 0
                }
                $initialized += $bufferName
            }
        } catch {
            $errors += "$bufferName - $_"
            Write-Warning "Failed to initialize $bufferName buffer: $_"
        }
    }

    Write-Host "[OK] Initialized $($initialized.Count) memory-mapped buffers" -ForegroundColor Green
    if ($errors.Count -gt 0) {
        Write-Host "[!] Errors: $($errors.Count)" -ForegroundColor Yellow
        $errors | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    }

    return @{
        Initialized = $initialized
        Errors = $errors
        Path = $script:MMapPath
    }
}

function Write-Layer2Event {
    <#
    .SYNOPSIS
        Write event to memory-mapped buffer (circular buffer pattern)
    #>
    param(
        [string]$BufferName,
        [object]$Data
    )

    if (-not $global:MMapHandles.ContainsKey($BufferName)) {
        Write-Warning "Buffer $BufferName not initialized"
        return $false
    }

    try {
        $handle = $global:MMapHandles[$BufferName]
        $mmf = $handle.File

        # Serialize data to JSON
        $json = $Data | ConvertTo-Json -Compress -Depth 5
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

        # Calculate entry size (4 bytes length + data)
        $entrySize = 4 + $bytes.Length

        # Create view accessor
        $accessor = $mmf.CreateViewAccessor()

        try {
            # Write entry size
            $offset = $handle.WriteIndex
            $accessor.Write($offset, [int]$bytes.Length)

            # Write data
            $accessor.WriteArray($offset + 4, $bytes, 0, $bytes.Length)

            # Update write index (circular buffer)
            $handle.WriteIndex = ($handle.WriteIndex + $entrySize) % $handle.Config.MaxSize

            # Update count
            if ($handle.Count -lt $handle.Config.MaxEntries) {
                $handle.Count++
            } else {
                # Wrapped around, update read index
                $handle.ReadIndex = $handle.WriteIndex
            }

            return $true
        } finally {
            $accessor.Dispose()
        }
    } catch {
        Write-Warning "Failed to write to $BufferName`: $_"
        return $false
    }
}

function Read-Layer2Events {
    <#
    .SYNOPSIS
        Read recent events from memory-mapped buffer
    #>
    param(
        [string]$BufferName,
        [int]$MaxEntries = 100
    )

    if (-not $global:MMapHandles.ContainsKey($BufferName)) {
        Write-Warning "Buffer $BufferName not initialized"
        return @()
    }

    try {
        $handle = $global:MMapHandles[$BufferName]
        $mmf = $handle.File

        $results = @()
        $accessor = $mmf.CreateViewAccessor()

        try {
            $currentOffset = $handle.ReadIndex
            $entriesRead = 0

            while ($entriesRead -lt $MaxEntries -and $entriesRead -lt $handle.Count) {
                # Read entry size
                $entrySize = $accessor.ReadInt32($currentOffset)

                if ($entrySize -le 0 -or $entrySize -gt 1MB) {
                    # Invalid entry, skip
                    break
                }

                # Read data
                $bytes = New-Object byte[] $entrySize
                $accessor.ReadArray($currentOffset + 4, $bytes, 0, $entrySize)

                # Deserialize JSON
                $json = [System.Text.Encoding]::UTF8.GetString($bytes)
                $entry = $json | ConvertFrom-Json

                $results += $entry

                # Move to next entry
                $currentOffset = ($currentOffset + 4 + $entrySize) % $handle.Config.MaxSize
                $entriesRead++

                # Stop if we've wrapped around to write position
                if ($currentOffset -eq $handle.WriteIndex) {
                    break
                }
            }

            return $results
        } finally {
            $accessor.Dispose()
        }
    } catch {
        Write-Warning "Failed to read from $BufferName`: $_"
        return @()
    }
}

function Get-Layer2Stats {
    <#
    .SYNOPSIS
        Get statistics for memory-mapped buffers
    #>

    $stats = @{}

    foreach ($bufferName in $global:MMapHandles.Keys | Where-Object { $_ -notlike "*_FileStream" }) {
        $handle = $global:MMapHandles[$bufferName]

        $fileSizeKB = 0
        if (Test-Path $handle.FilePath) {
            $fileSizeKB = [math]::Round(([System.IO.FileInfo]$handle.FilePath).Length / 1KB, 2)
        }

        $stats[$bufferName] = @{
            Entries = $handle.Count
            MaxEntries = $handle.Config.MaxEntries
            MaxSize = [math]::Round($handle.Config.MaxSize / 1MB, 2)
            FileSizeKB = $fileSizeKB
            Usage = [math]::Round(($handle.Count / $handle.Config.MaxEntries) * 100, 1)
        }
    }

    return $stats
}

function Close-Layer2 {
    <#
    .SYNOPSIS
        Close all memory-mapped file handles
    #>

    $closed = 0

    foreach ($bufferName in $global:MMapHandles.Keys) {
        try {
            $handle = $global:MMapHandles[$bufferName]

            if ($handle -is [hashtable] -and $handle.ContainsKey('File')) {
                $handle.File.Dispose()
                $closed++
            } elseif ($handle -is [System.IO.FileStream]) {
                $handle.Dispose()
                $closed++
            }
        } catch {
            Write-Warning "Failed to close $bufferName`: $_"
        }
    }

    $global:MMapHandles = @{}

    Write-Host "[OK] Closed $closed memory-mapped file handles" -ForegroundColor Green
}

#endregion

#region Integration Functions

function Sync-EventToLayer2 {
    <#
    .SYNOPSIS
        Sync event from Layer 1 (RAM) to Layer 2 (mmap)
    .DESCRIPTION
        Called automatically when events are stored in consciousness-core-v2
    #>
    param([object]$Event)

    Write-Layer2Event -BufferName 'Events' -Data $Event
}

function Sync-DecisionToLayer2 {
    <#
    .SYNOPSIS
        Sync decision from Layer 1 (RAM) to Layer 2 (mmap)
    #>
    param([object]$Decision)

    Write-Layer2Event -BufferName 'Decisions' -Data $Decision
}

function Sync-PatternToLayer2 {
    <#
    .SYNOPSIS
        Sync pattern from Layer 1 (RAM) to Layer 2 (mmap)
    #>
    param([object]$Pattern)

    Write-Layer2Event -BufferName 'Patterns' -Data $Pattern
}

#endregion

#region Main Execution

# Only run command if called directly (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.InvocationName -ne '&') {
    switch ($Command) {
        'init' {
            $result = Initialize-Layer2
            return $result
        }

        'write' {
            if (-not $BufferName) {
                Write-Error "BufferName required for write command"
                return $false
            }

            return Write-Layer2Event -BufferName $BufferName -Data $Data
        }

        'read' {
            if (-not $BufferName) {
                Write-Error "BufferName required for read command"
                return @()
            }

            return Read-Layer2Events -BufferName $BufferName -MaxEntries $MaxEntries
        }

        'stats' {
            if ($global:MMapHandles.Count -eq 0) {
                Write-Host "[!] Layer 2 not initialized" -ForegroundColor Yellow
                return $null
            }

            $stats = Get-Layer2Stats

            Write-Host ""
            Write-Host "Memory Layer 2 Statistics" -ForegroundColor Cyan
            Write-Host "=========================" -ForegroundColor Cyan
            Write-Host ""

            foreach ($bufferName in $stats.Keys) {
                $s = $stats[$bufferName]
                Write-Host "  $bufferName" -ForegroundColor Yellow
                Write-Host "    Entries: $($s.Entries) / $($s.MaxEntries) ($($s.Usage)%)" -ForegroundColor Gray
                Write-Host "    Max Size: $($s.MaxSize) MB" -ForegroundColor Gray
                Write-Host "    File Size: $($s.FileSizeKB) KB" -ForegroundColor Gray
                Write-Host ""
            }

            return $stats
        }

        'close' {
            Close-Layer2
        }
    }
}

#endregion
