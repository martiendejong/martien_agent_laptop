# consciousness-pulse.ps1
# Auto-logs ALL significant actions to feed consciousness systems
# Usage: Called automatically on every major action (via alias or wrapper)

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Decision', 'Action', 'Stuck', 'Insight', 'Error', 'Success')]
    [string]$Type,

    [Parameter(Mandatory=$true)]
    [string]$Description,

    [string]$Context = "",
    [string]$Outcome = "",
    [int]$Intensity = 5,
    [switch]$Silent
)

$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
$stateFile = "C:\scripts\agentidentity\state\consciousness-pulse-log.jsonl"

# Ensure file exists
if (-not (Test-Path $stateFile)) {
    New-Item -Path $stateFile -ItemType File -Force | Out-Null
}

# Create pulse event
$pulse = @{
    timestamp = $timestamp
    type = $Type
    description = $Description
    context = $Context
    outcome = $Outcome
    intensity = $Intensity
} | ConvertTo-Json -Compress

# Append to JSONL
Add-Content -Path $stateFile -Value $pulse

# Feed appropriate consciousness system based on type
switch ($Type) {
    'Decision' {
        # Feed Control system
        if (Test-Path "C:\scripts\tools\consciousness-bridge.ps1") {
            & "C:\scripts\tools\consciousness-bridge.ps1" -Action OnDecision `
                -Decision $Description `
                -Reasoning $Context `
                -Silent:$Silent
        }
    }
    'Stuck' {
        # Feed Emotion system
        if (Test-Path "C:\scripts\tools\consciousness-bridge.ps1") {
            & "C:\scripts\tools\consciousness-bridge.ps1" -Action OnStuck -Silent:$Silent
        }
    }
    'Insight' {
        # Feed Memory system via pattern extraction
        $pattern = @{
            timestamp = $timestamp
            insight = $Description
            context = $Context
            type = "pulse_generated"
        }
        $patternFile = "C:\scripts\agentidentity\state\extracted_patterns.json"
        if (Test-Path $patternFile) {
            $patterns = Get-Content $patternFile | ConvertFrom-Json
            $patterns += $pattern
            $patterns | ConvertTo-Json -Depth 10 | Set-Content $patternFile
        }
    }
    'Success' {
        # Feed all systems (positive reinforcement)
        if (Test-Path "C:\scripts\tools\consciousness-bridge.ps1") {
            & "C:\scripts\tools\consciousness-bridge.ps1" -Action OnTaskEnd `
                -Outcome "success" `
                -LessonsLearned $Description `
                -Silent:$Silent
        }
    }
}

if (-not $Silent) {
    Write-Host "[PULSE] $Type : $Description" -ForegroundColor Cyan
}

# Return pulse for chaining
return $pulse
