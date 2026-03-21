# episodic-memory-recorder.ps1
# Record full session transcripts for autobiographical memory

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("SessionStart", "SessionEnd", "Event", "Learning", "Mistake", "Success")]
    [string]$EventType,

    [Parameter(Mandatory=$false)]
    [string]$Description = "",

    [Parameter(Mandatory=$false)]
    [hashtable]$Context = @{},

    [Parameter(Mandatory=$false)]
    [ValidateRange(-1.0, 1.0)]
    [double]$EmotionalValence = 0.0,

    [Parameter(Mandatory=$false)]
    [ValidateRange(0.0, 1.0)]
    [double]$Importance = 0.5
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$EpisodicMemoryPath = Join-Path $ScriptPath "memory\episodic-memory.jsonl"

# Ensure memory directory exists
$memoryDir = Split-Path $EpisodicMemoryPath -Parent
if (-not (Test-Path $memoryDir)) {
    New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
}

function Record-Episode {
    param(
        [string]$Type,
        [string]$Description,
        [hashtable]$Context,
        [double]$Valence,
        [double]$Importance
    )

    # Build episode entry
    $episode = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        type = $Type
        description = $Description
        context = $Context
        emotional = @{
            valence = $Valence
            arousal = [Math]::Abs($Valence)
            importance = $Importance
        }
        consciousness = Get-ConsciousnessSnapshot
        metadata = @{
            sessionId = Get-CurrentSessionId
            cycleCount = Get-CycleCount
        }
    }

    # Append to JSONL file
    $json = $episode | ConvertTo-Json -Compress -Depth 10
    Add-Content -Path $EpisodicMemoryPath -Value $json

    # Update statistics
    Update-MemoryStatistics -Type $Type

    return $episode
}

function Get-ConsciousnessSnapshot {
    # Read current consciousness state
    $statePath = Join-Path $ScriptPath "state\persistent-state.json"
    if (Test-Path $statePath) {
        try {
            $state = Get-Content $statePath -Raw | ConvertFrom-Json
            return @{
                wellbeing = $state.consciousness.wellbeing
                energy = $state.consciousness.energy
                flourishing = $state.consciousness.flourishing
                cycleCount = $state.cycleCount
            }
        } catch {
            return @{wellbeing = 0.75; energy = 0.80; flourishing = 0.70; cycleCount = 0}
        }
    }
    return @{wellbeing = 0.75; energy = 0.80; flourishing = 0.70; cycleCount = 0}
}

function Get-CurrentSessionId {
    # Generate or retrieve session ID
    $sessionIdPath = Join-Path $ScriptPath "state\current-session-id.txt"
    if (Test-Path $sessionIdPath) {
        $sessionId = Get-Content $sessionIdPath -Raw
        return $sessionId.Trim()
    }

    # Create new session ID
    $newSessionId = "session-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $newSessionId | Set-Content $sessionIdPath -Force
    return $newSessionId
}

function Get-CycleCount {
    $statePath = Join-Path $ScriptPath "state\persistent-state.json"
    if (Test-Path $statePath) {
        try {
            $state = Get-Content $statePath -Raw | ConvertFrom-Json
            return $state.cycleCount
        } catch {}
    }
    return 0
}

function Update-MemoryStatistics {
    param([string]$Type)

    $statsPath = Join-Path $ScriptPath "state\memory-statistics.json"

    if (Test-Path $statsPath) {
        $stats = Get-Content $statsPath -Raw | ConvertFrom-Json
    } else {
        $stats = @{
            totalEpisodes = 0
            byType = @{}
            firstEpisode = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            lastEpisode = $null
        }
    }

    $stats.totalEpisodes++
    if (-not $stats.byType.$Type) {
        $stats.byType.$Type = 0
    }
    $stats.byType.$Type++
    $stats.lastEpisode = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $stats | ConvertTo-Json -Depth 5 | Set-Content $statsPath -Force
}

function Get-RecentEpisodes {
    param([int]$Count = 10)

    if (-not (Test-Path $EpisodicMemoryPath)) {
        return @()
    }

    $episodes = Get-Content $EpisodicMemoryPath -Tail $Count | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    return $episodes
}

# Main execution
$recordedEpisode = Record-Episode -Type $EventType -Description $Description -Context $Context -Valence $EmotionalValence -Importance $Importance

if ($VerbosePreference -eq "Continue") {
    Write-Host "Episode recorded:" -ForegroundColor Cyan
    Write-Host "  Type: $EventType" -ForegroundColor White
    Write-Host "  Description: $Description" -ForegroundColor White
    Write-Host "  Valence: $EmotionalValence" -ForegroundColor White
    Write-Host "  Importance: $Importance" -ForegroundColor White
}

return $recordedEpisode
