# Toon Sessies - Dutch alias for session manager
# Usage: toon-sessies [actief|gearchiveerd|alles]
<#
.SYNOPSIS
    Toon Sessies - Dutch alias for session manager

.DESCRIPTION
    Toon Sessies - Dutch alias for session manager

.NOTES
    File: toon-sessies.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Position=0)]

$ErrorActionPreference = "Stop"
    [string]$Filter = 'alles',

    [int]$Aantal = 15
)

$sessionsScript = Join-Path $PSScriptRoot "sessions.ps1"

switch ($Filter.ToLower()) {
    'actief' { & $sessionsScript list -Active -Limit $Aantal }
    'gearchiveerd' { & $sessionsScript list -Archived -Limit $Aantal }
    'alles' { & $sessionsScript list -Limit $Aantal }
    default { & $sessionsScript list -Limit $Aantal }
}
