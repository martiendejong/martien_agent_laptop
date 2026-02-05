# rag-auto-updater.ps1
# Automatic RAG index updates when documentation changes
# Watches for markdown file changes and triggers re-indexing

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Watch", "Sync", "Status", "Force")]
    [string]$Action,

    [string]$Path = "C:\scripts",          # Path to watch
    [string]$RAGStorePath = "C:\scripts\my_network",
    [int]$DebounceSeconds = 30             # Wait N seconds after last change before syncing
)

$script:LastChangeTime = Get-Date
$script:PendingChanges = @()
$script:WatcherRunning = $false

function Invoke-RAGSync {
    param([string[]]$ChangedFiles)

    Write-Host "🔄 Syncing RAG index..." -ForegroundColor Cyan

    if ($ChangedFiles.Count -gt 0) {
        Write-Host "   Changed files: $($ChangedFiles.Count)" -ForegroundColor Gray
        foreach ($file in $ChangedFiles | Select-Object -First 5) {
            Write-Host "   - $file" -ForegroundColor DarkGray
        }
        if ($ChangedFiles.Count -gt 5) {
            Write-Host "   ... and $($ChangedFiles.Count - 5) more" -ForegroundColor DarkGray
        }
    }

    try {
        # Run knowledge network update script
        $updateScript = "C:\scripts\tools\update-knowledge-network.ps1"

        if (Test-Path $updateScript) {
            & $updateScript -Action FullUpdate
            Write-Host "✅ RAG index updated successfully" -ForegroundColor Green

            # Log update
            $logFile = Join-Path $RAGStorePath "sync.log"
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "[$timestamp] AUTO_SYNC: $($ChangedFiles.Count) files changed`n"
            Add-Content -Path $logFile -Value $logEntry

            return $true
        } else {
            Write-Host "⚠️ Update script not found: $updateScript" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "❌ Failed to sync RAG index: $_" -ForegroundColor Red

        # Log error
        & "C:\scripts\tools\error-handler.ps1" -Action Catch `
            -ErrorMessage "RAG sync failed: $_" `
            -Context "Auto-update after file changes" `
            -Component "RAG-Auto-Updater" `
            -Severity "Medium"

        return $false
    }
}

function Start-FileWatcher {
    param([string]$WatchPath, [int]$DebounceSeconds)

    Write-Host "👀 Starting file watcher..." -ForegroundColor Cyan
    Write-Host "   Path: $WatchPath" -ForegroundColor Gray
    Write-Host "   Debounce: ${DebounceSeconds}s" -ForegroundColor Gray
    Write-Host "   Press Ctrl+C to stop`n" -ForegroundColor Gray

    # Create file system watcher
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $WatchPath
    $watcher.Filter = "*.md"
    $watcher.IncludeSubdirectories = $true
    $watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName

    # Event handler
    $onChange = {
        param($sender, $e)

        $script:LastChangeTime = Get-Date
        $changedFile = $e.FullPath

        if ($script:PendingChanges -notcontains $changedFile) {
            $script:PendingChanges += $changedFile
            Write-Host "📝 Change detected: $($e.Name)" -ForegroundColor Yellow
        }
    }

    # Register event handlers
    Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $onChange | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName Created -Action $onChange | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $onChange | Out-Null

    # Start watching
    $watcher.EnableRaisingEvents = $true
    $script:WatcherRunning = $true

    # Debounce loop
    try {
        while ($script:WatcherRunning) {
            Start-Sleep -Seconds 1

            # Check if debounce period elapsed
            $timeSinceLastChange = ((Get-Date) - $script:LastChangeTime).TotalSeconds

            if ($script:PendingChanges.Count -gt 0 -and $timeSinceLastChange -ge $DebounceSeconds) {
                Write-Host "`n⏱️ Debounce period elapsed, syncing..." -ForegroundColor Cyan

                $success = Invoke-RAGSync -ChangedFiles $script:PendingChanges

                if ($success) {
                    $script:PendingChanges = @()
                } else {
                    Write-Host "⚠️ Sync failed, will retry on next change" -ForegroundColor Yellow
                }

                Write-Host "`n👀 Watching for changes...`n" -ForegroundColor Cyan
            }
        }
    }
    finally {
        # Cleanup
        $watcher.EnableRaisingEvents = $false
        $watcher.Dispose()
        Get-EventSubscriber | Where-Object { $_.SourceObject -eq $watcher } | Unregister-Event
        Write-Host "`n✅ File watcher stopped" -ForegroundColor Green
    }
}

function Get-RAGStatus {
    $statusFile = Join-Path $RAGStorePath "status.json"

    if (Test-Path $statusFile) {
        $status = Get-Content $statusFile -Raw | ConvertFrom-Json

        Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "📊 RAG INDEX STATUS" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "Store Path: $RAGStorePath" -ForegroundColor Gray
        Write-Host "Last Sync: $($status.LastSync)" -ForegroundColor White
        Write-Host "Document Count: $($status.DocumentCount)" -ForegroundColor White
        Write-Host "Chunk Count: $($status.ChunkCount)" -ForegroundColor White
        Write-Host "Index Size: $($status.IndexSize)" -ForegroundColor White
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️ RAG status file not found" -ForegroundColor Yellow
        Write-Host "   Run: rag-auto-updater.ps1 -Action Sync" -ForegroundColor Gray
    }
}

# Main logic
switch ($Action) {
    "Watch" {
        if (-not (Test-Path $Path)) {
            Write-Host "❌ Path not found: $Path" -ForegroundColor Red
            exit 1
        }

        Start-FileWatcher -WatchPath $Path -DebounceSeconds $DebounceSeconds
        exit 0
    }

    "Sync" {
        Write-Host "🔄 Manual RAG sync triggered..." -ForegroundColor Cyan
        $success = Invoke-RAGSync -ChangedFiles @()

        if ($success) {
            exit 0
        } else {
            exit 1
        }
    }

    "Status" {
        Get-RAGStatus
        exit 0
    }

    "Force" {
        Write-Host "🔧 Force rebuilding RAG index..." -ForegroundColor Cyan

        try {
            # Delete existing index
            $indexPath = Join-Path $RAGStorePath "index"
            if (Test-Path $indexPath) {
                Remove-Item -Path $indexPath -Recurse -Force
                Write-Host "✅ Old index deleted" -ForegroundColor Green
            }

            # Rebuild
            $success = Invoke-RAGSync -ChangedFiles @()

            if ($success) {
                Write-Host "✅ RAG index rebuilt from scratch" -ForegroundColor Green
                exit 0
            } else {
                Write-Host "❌ Failed to rebuild index" -ForegroundColor Red
                exit 1
            }
        }
        catch {
            Write-Host "❌ Error during force rebuild: $_" -ForegroundColor Red
            exit 1
        }
    }
}

# If no valid action, show help
Write-Host @"
RAG Auto-Updater
================

Automatically updates RAG index when documentation changes.

Usage:
  rag-auto-updater.ps1 -Action Watch                   # Start file watcher (auto-sync)
  rag-auto-updater.ps1 -Action Sync                    # Manual sync now
  rag-auto-updater.ps1 -Action Status                  # Show index status
  rag-auto-updater.ps1 -Action Force                   # Rebuild index from scratch

Options:
  -Path <path>               # Path to watch (default: C:\scripts)
  -RAGStorePath <path>       # RAG store location (default: C:\scripts\my_network)
  -DebounceSeconds <n>       # Wait N seconds after last change (default: 30)

Background Mode:
  Start-Job -ScriptBlock { C:\scripts\tools\rag-auto-updater.ps1 -Action Watch }

Integration:
  Add to session startup: rag-auto-updater.ps1 -Action Sync (ensure index current)
  Add background watcher: Task Scheduler or startup script

"@
