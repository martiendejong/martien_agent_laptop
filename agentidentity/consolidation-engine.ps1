# consolidation-engine.ps1
# Nightly memory consolidation - mimics sleep processing

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Force  # Run even if not scheduled time
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$EpisodicMemoryPath = Join-Path $ScriptPath "memory\episodic-memory.jsonl"
$ConsolidatedMemoryPath = Join-Path $ScriptPath "memory\consolidated-memory.json"
$LogPath = Join-Path $ScriptPath "logs\consolidation.log"

function Write-ConsolidationLog {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $Message"
    Add-Content -Path $LogPath -Value $entry
    Write-Verbose $entry
}

function Should-RunConsolidation {
    # Run between 2am-4am, or if forced
    if ($Force) { return $true }

    $hour = (Get-Date).Hour
    if ($hour -ge 2 -and $hour -le 4) {
        # Check if already ran today
        $lastConsolidationPath = Join-Path $ScriptPath "state\last-consolidation.txt"
        if (Test-Path $lastConsolidationPath) {
            $lastRun = Get-Content $lastConsolidationPath -Raw
            $lastRunDate = [DateTime]::Parse($lastRun)
            if ($lastRunDate.Date -eq (Get-Date).Date) {
                Write-ConsolidationLog "Already consolidated today, skipping"
                return $false
            }
        }
        return $true
    }

    return $false
}

function Load-UnconsolidatedEpisodes {
    if (-not (Test-Path $EpisodicMemoryPath)) {
        return @()
    }

    # Load all episodes since last consolidation
    $lastConsolidationPath = Join-Path $ScriptPath "state\last-consolidation.txt"
    $lastConsolidation = if (Test-Path $lastConsolidationPath) {
        [DateTime]::Parse((Get-Content $lastConsolidationPath -Raw))
    } else {
        (Get-Date).AddDays(-365)  # Process all if never consolidated
    }

    $allEpisodes = Get-Content $EpisodicMemoryPath | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    $newEpisodes = $allEpisodes | Where-Object {
        [DateTime]::Parse($_.timestamp) -gt $lastConsolidation
    }

    Write-ConsolidationLog "Loaded $($newEpisodes.Count) new episodes since $($lastConsolidation.ToString('yyyy-MM-dd HH:mm:ss'))"

    return $newEpisodes
}

function Consolidate-Memories {
    param([array]$Episodes)

    if ($Episodes.Count -eq 0) {
        Write-ConsolidationLog "No episodes to consolidate"
        return @{}
    }

    Write-ConsolidationLog "Consolidating $($Episodes.Count) episodes..."

    # Load existing consolidated memory
    $consolidated = if (Test-Path $ConsolidatedMemoryPath) {
        Get-Content $ConsolidatedMemoryPath -Raw | ConvertFrom-Json
    } else {
        @{
            coreMemories = @()
            strengthenedPatterns = @()
            prunedDetails = 0
            consolidationHistory = @()
        }
    }

    # Step 1: Identify important episodes (high importance or strong emotion)
    $importantEpisodes = $Episodes | Where-Object {
        $_.emotional.importance -gt 0.7 -or [Math]::Abs($_.emotional.valence) -gt 0.7
    }

    Write-ConsolidationLog "Identified $($importantEpisodes.Count) important episodes"

    # Step 2: Add to core memories
    foreach ($episode in $importantEpisodes) {
        $coreMemory = @{
            timestamp = $episode.timestamp
            type = $episode.type
            description = $episode.description
            valence = $episode.emotional.valence
            importance = $episode.emotional.importance
            consolidationDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        $consolidated.coreMemories += $coreMemory
    }

    # Step 3: Extract recurring patterns
    $patterns = Extract-RecurringPatterns -Episodes $Episodes

    foreach ($pattern in $patterns) {
        # Check if pattern already exists and strengthen it
        $existingPattern = $consolidated.strengthenedPatterns | Where-Object { $_.pattern -eq $pattern.pattern }

        if ($existingPattern) {
            $existingPattern.strength += $pattern.occurrences * 0.1
            $existingPattern.lastSeen = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        } else {
            $consolidated.strengthenedPatterns += @{
                pattern = $pattern.pattern
                strength = $pattern.occurrences * 0.1
                firstSeen = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                lastSeen = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                occurrences = $pattern.occurrences
            }
        }
    }

    # Step 4: Prune redundant details (keep only important episodes)
    $prunedCount = $Episodes.Count - $importantEpisodes.Count
    $consolidated.prunedDetails += $prunedCount

    Write-ConsolidationLog "Pruned $prunedCount redundant details"

    # Step 5: Log consolidation event
    $consolidated.consolidationHistory += @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        episodesProcessed = $Episodes.Count
        coreMemoriesAdded = $importantEpisodes.Count
        patternsStrengthened = $patterns.Count
    }

    # Keep only last 50 consolidation events
    if ($consolidated.consolidationHistory.Count -gt 50) {
        $consolidated.consolidationHistory = $consolidated.consolidationHistory | Select-Object -Last 50
    }

    # Keep only top 100 core memories (by importance)
    if ($consolidated.coreMemories.Count -gt 100) {
        $consolidated.coreMemories = $consolidated.coreMemories |
            Sort-Object -Property importance -Descending |
            Select-Object -First 100
    }

    return $consolidated
}

function Extract-RecurringPatterns {
    param([array]$Episodes)

    # Simple pattern extraction: group by description similarity
    $patterns = @()

    # Group episodes by type and find common words
    $byType = $Episodes | Group-Object -Property type

    foreach ($typeGroup in $byType) {
        $descriptions = $typeGroup.Group | ForEach-Object { $_.description }

        # Find common phrases (very simple: just look for repeated words)
        $wordCounts = @{}
        foreach ($desc in $descriptions) {
            $words = $desc -split '\s+' | Where-Object { $_.Length -gt 4 }
            foreach ($word in $words) {
                if (-not $wordCounts[$word]) { $wordCounts[$word] = 0 }
                $wordCounts[$word]++
            }
        }

        # Patterns are words that appear more than once
        $commonWords = $wordCounts.GetEnumerator() | Where-Object { $_.Value -gt 1 }

        foreach ($word in $commonWords) {
            $patterns += @{
                pattern = "$($typeGroup.Name): $($word.Key)"
                occurrences = $word.Value
            }
        }
    }

    Write-ConsolidationLog "Extracted $($patterns.Count) recurring patterns"

    return $patterns
}

function Save-ConsolidatedMemory {
    param($Consolidated)

    $Consolidated | ConvertTo-Json -Depth 10 | Set-Content $ConsolidatedMemoryPath -Force

    Write-ConsolidationLog "Consolidated memory saved"
}

function Update-LastConsolidationTime {
    $lastConsolidationPath = Join-Path $ScriptPath "state\last-consolidation.txt"
    Get-Date -Format "yyyy-MM-dd HH:mm:ss" | Set-Content $lastConsolidationPath -Force
}

# Main execution
Write-ConsolidationLog "=== Consolidation Engine Starting ==="

if (-not (Should-RunConsolidation)) {
    Write-ConsolidationLog "Not scheduled time for consolidation, exiting"
    exit 0
}

$episodes = Load-UnconsolidatedEpisodes

if ($episodes.Count -eq 0) {
    Write-ConsolidationLog "No new episodes to consolidate"
    exit 0
}

$consolidated = Consolidate-Memories -Episodes $episodes

Save-ConsolidatedMemory -Consolidated $consolidated

Update-LastConsolidationTime

Write-ConsolidationLog "=== Consolidation Complete ==="
Write-ConsolidationLog "Core memories: $($consolidated.coreMemories.Count)"
Write-ConsolidationLog "Strengthened patterns: $($consolidated.strengthenedPatterns.Count)"
Write-ConsolidationLog "Pruned details: $($consolidated.prunedDetails)"

Write-Host "`nConsolidation Summary:" -ForegroundColor Cyan
Write-Host "  Episodes processed: $($episodes.Count)"
Write-Host "  Core memories: $($consolidated.coreMemories.Count)"
Write-Host "  Patterns: $($consolidated.strengthenedPatterns.Count)"
Write-Host "  Pruned: $($consolidated.prunedDetails)"
