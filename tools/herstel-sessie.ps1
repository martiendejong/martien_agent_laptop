# Herstel Sessie - Dutch alias for session restore
# Usage: herstel-sessie [session-id]
#        herstel-sessie (restores last closed)
<#
.SYNOPSIS
    Herstel Sessie - Dutch alias for session restore

.DESCRIPTION
    Herstel Sessie - Dutch alias for session restore

.NOTES
    File: herstel-sessie.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Position=0)]

$ErrorActionPreference = "Stop"
    [string]$SessieId = ''
)

$sessionsScript = Join-Path $PSScriptRoot "sessions.ps1"

if ($SessieId) {
    & $sessionsScript restore $SessieId
} else {
    & $sessionsScript last
}
