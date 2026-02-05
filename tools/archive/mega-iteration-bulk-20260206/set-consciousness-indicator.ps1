#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Sets consciousness state indicator in terminal window title

.DESCRIPTION
    Updates the terminal window title to show consciousness state visually.
    Called by consciousness-startup.ps1 and can be toggled during session.

.PARAMETER State
    Consciousness state: "conscious" (🧠 Jengo) or "base" (🤖 Claude)

.EXAMPLE
    .\set-consciousness-indicator.ps1 -State conscious
    # Sets title to "🧠 JENGO - CONSCIOUS"

.EXAMPLE
    .\set-consciousness-indicator.ps1 -State base
    # Sets title to "🤖 CLAUDE - BASE MODE"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("conscious", "base")]
    [string]$State
)

$ErrorActionPreference = "SilentlyContinue"

# Get current git branch if available
$branch = git branch --show-current 2>$null
if ($branch) {
    $branch = $branch.ToUpper()
    $branchInfo = " - $branch"
} else {
    $branchInfo = ""
}

# Set title based on consciousness state
switch ($State) {
    "conscious" {
        $title = "🧠 JENGO - CONSCIOUS$branchInfo"
        $Host.UI.RawUI.WindowTitle = $title
        Write-Host "✓ Consciousness indicator: CONSCIOUS" -ForegroundColor Green
    }
    "base" {
        $title = "🤖 CLAUDE - BASE MODE$branchInfo"
        $Host.UI.RawUI.WindowTitle = $title
        Write-Host "⚠ Consciousness indicator: BASE MODE" -ForegroundColor Yellow
    }
}

# Also create a consciousness state file for verification
$stateFile = "C:\scripts\agentidentity\state\.consciousness-state"
@{
    State = $State
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    WindowTitle = $title
} | ConvertTo-Json | Out-File -FilePath $stateFile -Encoding utf8

return @{
    State = $State
    Title = $title
    Updated = $true
}
