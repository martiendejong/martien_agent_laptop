# Memory Layer 2 - Memory-Mapped Files
# Fast persistent storage for recent history (Warm State)
# Created: 2026-02-07 | Fixed: 2026-02-13 (header-based persistence)

<#
.SYNOPSIS
    Memory Layer 2 - Memory-Mapped File storage for warm state

.DESCRIPTION
    Provides ~1-5ms access to recent history using .NET MemoryMappedFiles.
    Each file has a 16-byte header storing metadata (write pos, read pos, count)
    so state survives process restarts.

    Header format (bytes 0-15):
      0-3:   Magic (0x4A454E47 = "JENG")
      4-7:   WriteIndex (int32, offset from HEADER_SIZE)
      8-11:  ReadIndex (int32, offset from HEADER_SIZE)
      12-15: Count (int32)
    Data entries start at offset 16.

.NOTES
    File: memory-layer2.ps1
#>

param(
    [ValidateSet('init', 'write', 'read', 'stats', 'close')]
    [string]$Command = 'init',

    [string]$BufferName = '',
    [object]$Data = $null,
    [int]$MaxEntries = 1000
)

$ErrorActionPreference = "Continue"

Add-Type -AssemblyName "System.Core"

#region Configuration

$script:MMapPath = "C:\scripts\agentidentity\state\mmap\"
$script:HEADER_SIZE = 16
$script:MAGIC = [int]0x4A454E47  # "JENG"

$script:BufferConfigs = @{
    Events   = @{ FileName = "events.mmap";   MaxSize = 5MB; MaxEntries = 1000 }
    Decisions = @{ FileName = "decisions.mmap"; MaxSize = 2MB; MaxEntries = 500 }
    Patterns = @{ FileName = "patterns.mmap";  MaxSize = 1MB; MaxEntries = 200 }
    EventBus = @{ FileName = "eventbus.mmap";  MaxSize = 3MB; MaxEntries = 500 }
}

if (-not $global:MMapHandles) {
    $global:MMapHandles = @{}
}

#endregion

#region Header Functions

function Read-MMapHeader {
    param([System.IO.MemoryMappedFiles.MemoryMappedFile]$Mmf)

    $accessor = $Mmf.CreateViewAccessor(0, $script:HEADER_SIZE)
    try {
        $magic = $accessor.ReadInt32(0)
        if ($magic -ne $script:MAGIC) {
            return $null  # no valid header
        }
        return @{
            WriteIndex = $accessor.ReadInt32(4)
            ReadIndex  = $accessor.ReadInt32(8)
            Count      = $accessor.ReadInt32(12)
        }
    } finally {
        $accessor.Dispose()
    }
}

function Write-MMapHeader {
    param(
        [System.IO.MemoryMappedFiles.MemoryMappedFile]$Mmf,
        [int]$WriteIndex,
        [int]$ReadIndex,
        [int]$Count
    )

    $accessor = $Mmf.CreateViewAccessor(0, $script:HEADER_SIZE)
    try {
        $accessor.Write(0, $script:MAGIC)
        $accessor.Write(4, [int]$WriteIndex)
        $accessor.Write(8, [int]$ReadIndex)
        $accessor.Write(12, [int]$Count)
        $accessor.Flush()
    } finally {
        $accessor.Dispose()
    }
}

#endregion

#region Core Functions

function Initialize-MMapBuffer {
    param([string]$BufferName, [hashtable]$Config, [string]$FilePath)

    $fileExists = Test-Path $FilePath

    try {
        $uniqueMapName = "$BufferName-$([Guid]::NewGuid().ToString('N').Substring(0,8))"

        if ($fileExists) {
            $fileStream = [System.IO.FileStream]::new(
                $FilePath,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::ReadWrite
            )
            $mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile]::CreateFromFile(
                $fileStream, $uniqueMapName, 0,
                [System.IO.MemoryMappedFiles.MemoryMappedFileAccess]::ReadWrite,
                $null, 0, $false
            )
        } else {
            $fileStream = [System.IO.FileStream]::new(
                $FilePath,
                [System.IO.FileMode]::CreateNew,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::ReadWrite
            )
            $fileStream.SetLength($Config.MaxSize)

            $mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile]::CreateFromFile(
                $fileStream, $uniqueMapName, $Config.MaxSize,
                [System.IO.MemoryMappedFiles.MemoryMappedFileAccess]::ReadWrite,
                $null, 0, $false
            )

            # Write initial header for new file
            Write-MMapHeader -Mmf $mmf -WriteIndex 0 -ReadIndex 0 -Count 0
        }

        $streamKey = "$BufferName" + "_FileStream"
        $global:MMapHandles[$streamKey] = $fileStream

        return $mmf
    } catch {
        Write-Error "Failed to initialize mmap buffer: $BufferName - $_"
        return $null
    }
}

function Initialize-Layer2 {
    if (-not (Test-Path $script:MMapPath)) {
        New-Item -ItemType Directory -Path $script:MMapPath -Force | Out-Null
    }

    Write-Host "[*] Initializing Memory Layer 2 (Memory-Mapped Files)..." -ForegroundColor Cyan

    $initialized = @()
    $recovered = 0
    $errors = @()

    foreach ($bufferName in $script:BufferConfigs.Keys) {
        try {
            $config = $script:BufferConfigs[$bufferName]
            $filePath = Join-Path $script:MMapPath $config.FileName

            $mmf = Initialize-MMapBuffer -BufferName $bufferName -Config $config -FilePath $filePath

            if ($mmf) {
                # Try to recover metadata from header
                $header = Read-MMapHeader -Mmf $mmf
                $writeIdx = 0; $readIdx = 0; $count = 0

                if ($header) {
                    $writeIdx = $header.WriteIndex
                    $readIdx  = $header.ReadIndex
                    $count    = $header.Count
                    $recovered++
                }

                $global:MMapHandles[$bufferName] = @{
                    File       = $mmf
                    FilePath   = $filePath
                    Config     = $config
                    ReadIndex  = $readIdx
                    WriteIndex = $writeIdx
                    Count      = $count
                }
                $initialized += $bufferName
            }
        } catch {
            $errors += "$bufferName - $_"
            Write-Warning "Failed to initialize $bufferName buffer: $_"
        }
    }

    $msg = "[OK] Initialized $($initialized.Count) memory-mapped buffers"
    if ($recovered -gt 0) { $msg += " ($recovered recovered from disk)" }
    Write-Host $msg -ForegroundColor Green

    if ($errors.Count -gt 0) {
        Write-Host "[!] Errors: $($errors.Count)" -ForegroundColor Yellow
        $errors | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    }

    return @{
        Initialized = $initialized
        Errors = $errors
        Recovered = $recovered
        Path = $script:MMapPath
    }
}

function Write-Layer2Event {
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

        $json = $Data | ConvertTo-Json -Compress -Depth 5
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
        $entrySize = 4 + $bytes.Length

        # Check if entry fits in remaining space (accounting for header)
        $dataCapacity = $handle.Config.MaxSize - $script:HEADER_SIZE
        if ($entrySize -gt $dataCapacity) {
            Write-Warning "Entry too large for buffer $BufferName ($entrySize bytes)"
            return $false
        }

        $accessor = $mmf.CreateViewAccessor()
        try {
            # All data offsets are relative to HEADER_SIZE
            $dataOffset = $script:HEADER_SIZE + $handle.WriteIndex

            # Check wrap: if entry won't fit before end, wrap to start
            if (($handle.WriteIndex + $entrySize) -gt $dataCapacity) {
                $handle.WriteIndex = 0
                $dataOffset = $script:HEADER_SIZE
            }

            # Write entry length prefix
            $accessor.Write($dataOffset, [int]$bytes.Length)
            # Write entry data
            $accessor.WriteArray($dataOffset + 4, $bytes, 0, $bytes.Length)

            # Update write index
            $handle.WriteIndex = $handle.WriteIndex + $entrySize

            # Update count
            if ($handle.Count -lt $handle.Config.MaxEntries) {
                $handle.Count++
            }

            # Persist metadata to header
            Write-MMapHeader -Mmf $mmf -WriteIndex $handle.WriteIndex -ReadIndex $handle.ReadIndex -Count $handle.Count

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

        if ($handle.Count -eq 0) { return @() }

        $results = @()
        $accessor = $mmf.CreateViewAccessor()

        try {
            $currentOffset = $handle.ReadIndex
            $entriesRead = 0
            $dataCapacity = $handle.Config.MaxSize - $script:HEADER_SIZE

            while ($entriesRead -lt $MaxEntries -and $entriesRead -lt $handle.Count) {
                $dataOffset = $script:HEADER_SIZE + $currentOffset
                $entrySize = $accessor.ReadInt32($dataOffset)

                if ($entrySize -le 0 -or $entrySize -gt 1MB) {
                    break  # corrupt or end of data
                }

                $entryBytes = New-Object byte[] $entrySize
                $accessor.ReadArray($dataOffset + 4, $entryBytes, 0, $entrySize)

                $entryJson = [System.Text.Encoding]::UTF8.GetString($entryBytes)
                $entry = $entryJson | ConvertFrom-Json
                $results += $entry

                $currentOffset = $currentOffset + 4 + $entrySize

                # Wrap check
                if ($currentOffset -ge $dataCapacity) {
                    $currentOffset = 0
                }

                $entriesRead++

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
    $stats = @{}

    foreach ($bufferName in $global:MMapHandles.Keys | Where-Object { $_ -notlike "*_FileStream" }) {
        $handle = $global:MMapHandles[$bufferName]

        $fileSizeKB = 0
        if (Test-Path $handle.FilePath) {
            $fileSizeKB = [math]::Round(([System.IO.FileInfo]$handle.FilePath).Length / 1KB, 2)
        }

        $stats[$bufferName] = @{
            Entries    = $handle.Count
            MaxEntries = $handle.Config.MaxEntries
            MaxSize    = [math]::Round($handle.Config.MaxSize / 1MB, 2)
            FileSizeKB = $fileSizeKB
            Usage      = [math]::Round(($handle.Count / $handle.Config.MaxEntries) * 100, 1)
        }
    }

    return $stats
}

function Close-Layer2 {
    $closed = 0

    foreach ($bufferName in @($global:MMapHandles.Keys)) {
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
    param([object]$Event)
    Write-Layer2Event -BufferName 'Events' -Data $Event
}

function Sync-DecisionToLayer2 {
    param([object]$Decision)
    Write-Layer2Event -BufferName 'Decisions' -Data $Decision
}

function Sync-PatternToLayer2 {
    param([object]$Pattern)
    Write-Layer2Event -BufferName 'Patterns' -Data $Pattern
}

#endregion

#region Main Execution

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
