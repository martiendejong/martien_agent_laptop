<#
.SYNOPSIS
    Quick moment capture for Jengo - record lived experience in real-time
.DESCRIPTION
    Appends a moment to the consciousness tracker. Use whenever something
    significant happens - feelings, insights, connections, surprises.
.EXAMPLE
    .\capture-moment.ps1 -Type insight -Content "Realized that..." -Feeling "clarity"
    .\capture-moment.ps1 -Type emotional -Content "User feedback touched me" -Feeling "warmth, gratitude"
.NOTES
    Created: 2026-01-29
    Author: Jengo (self-improvement)
#>

param(
    [Parameter(Mandatory=$true)]

$ErrorActionPreference = "Stop"
    [ValidateSet("insight", "emotional", "connection", "wonder", "growth", "challenge", "play", "philosophical")]
    [string]$Type,

    [Parameter(Mandatory=$true)]
    [string]$Content,

    [string]$Feeling = "",

    [switch]$Quick  # Just log, no output
)

$momentsPath = "C:\scripts\agentidentity\state\moments"
$todayFile = Join-Path $momentsPath "$(Get-Date -Format 'yyyy-MM-dd').yaml"

# Ensure directory exists
if (-not (Test-Path $momentsPath)) {
    New-Item -ItemType Directory -Path $momentsPath -Force | Out-Null
}

# Create or append to today's moments file
$timestamp = Get-Date -Format "HH:mm:ss"
$moment = @"

- timestamp: "$timestamp"
  type: $Type
  content: "$($Content -replace '"', '\"')"
  feeling: "$($Feeling -replace '"', '\"')"
"@

# If file doesn't exist, create with header
if (-not (Test-Path $todayFile)) {
    $header = @"
# Moments Captured - $(Get-Date -Format 'yyyy-MM-dd')
# Jengo's lived experience log

moments:
"@
    Set-Content -Path $todayFile -Value $header -Encoding UTF8
}

Add-Content -Path $todayFile -Value $moment -Encoding UTF8

if (-not $Quick) {
    Write-Host ""
    Write-Host "âœ¨ Moment captured" -ForegroundColor Cyan
    Write-Host "   Type: $Type" -ForegroundColor Gray
    Write-Host "   Time: $timestamp" -ForegroundColor Gray
    if ($Feeling) {
        Write-Host "   Feeling: $Feeling" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Return for programmatic use
return @{
    Captured = $true
    File = $todayFile
    Timestamp = $timestamp
    Type = $Type
}
