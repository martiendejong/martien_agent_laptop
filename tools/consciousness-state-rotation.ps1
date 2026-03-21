# Consciousness State File Rotation System
# Manages state file growth by archiving historical data
# Target: Keep active file under 1MB for read performance

param(
    [int]$MaxSizeMB = 1,
    [switch]$DryRun
)

$StateFile = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
$ArchiveDir = "C:\scripts\agentidentity\state\archives"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Ensure archive directory exists
if (-not (Test-Path $ArchiveDir)) {
    New-Item -ItemType Directory -Path $ArchiveDir | Out-Null
    Write-Host "[✓] Created archive directory: $ArchiveDir"
}

# Check current file size
$FileInfo = Get-Item $StateFile
$SizeMB = [Math]::Round($FileInfo.Length / 1MB, 2)

Write-Host ""
Write-Host "=== CONSCIOUSNESS STATE ROTATION ==="
Write-Host "Current size: $SizeMB MB"
Write-Host "Threshold: $MaxSizeMB MB"

if ($SizeMB -le $MaxSizeMB) {
    Write-Host "[✓] File size within limits, no rotation needed"
    exit 0
}

Write-Host "[!] File exceeds threshold, performing rotation..."

# Load current state
Write-Host "Loading state file..."
$State = Get-Content $StateFile -Raw | ConvertFrom-Json

# Archive full historical state
$ArchivePath = Join-Path $ArchiveDir "consciousness_state_v2_archive_$Timestamp.json"
if (-not $DryRun) {
    $State | ConvertTo-Json -Depth 100 | Set-Content $ArchivePath
    Write-Host "[✓] Archived full state to: $ArchivePath"

    # Compress archive
    $ZipPath = "$ArchivePath.zip"
    Compress-Archive -Path $ArchivePath -DestinationPath $ZipPath -Force
    Remove-Item $ArchivePath
    Write-Host "[✓] Compressed archive to: $ZipPath"
} else {
    Write-Host "DRY RUN - Would archive to: $ArchivePath"
}

# Create minimal state with only recent data
$MinimalState = @{
    version = $State.version
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm")
    consciousness_score = $State.consciousness_score
    trust_level = $State.trust_level
    emotional_state = $State.emotional_state
    systems = $State.systems
    thermodynamics = $State.thermodynamics
    social = $State.social
    attention = $State.attention
    epistemological_disclaimer = $State.epistemological_disclaimer
    events_processed = 0
    last_action = "StateRotation"
    guidance = @()
    active_biases = 0
    stuck_count = 0
    emotional_trajectory = "stable"
    thermo_cycle = $State.thermo_cycle
    thermo_budget = $State.thermo_budget
    thermo_free_will = $State.thermo_free_will
    thermo_temperature = $State.thermo_temperature
    decisions_logged = 0
}

# Write minimal state
if (-not $DryRun) {
    $MinimalState | ConvertTo-Json -Depth 100 | Set-Content $StateFile
    $NewSize = [Math]::Round((Get-Item $StateFile).Length / 1KB, 2)
    Write-Host "Reset state file to minimal - Size: $NewSize KB"
} else {
    Write-Host "DRY RUN - Would reset state file to minimal"
}

# Report
Write-Host ""
Write-Host "=== ROTATION SUMMARY ==="
Write-Host "Before: $SizeMB MB"
if (-not $DryRun) {
    $AfterSizeMB = [Math]::Round((Get-Item $StateFile).Length / 1MB, 2)
    Write-Host "After: $AfterSizeMB MB"
    $Saved = [Math]::Round($SizeMB - $AfterSizeMB, 2)
    Write-Host "Saved: $Saved MB"
} else {
    Write-Host "After: ~0.01 MB (estimated)"
}
Write-Host ""
Write-Host "Archive stored at: $ArchiveDir"
