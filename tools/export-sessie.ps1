# Export Sessie - Export session to markdown
# Usage: export-sessie fc0bbf6c
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$SessieId
)

$sessionsScript = Join-Path $PSScriptRoot "sessions.ps1"
& $sessionsScript export $SessieId
