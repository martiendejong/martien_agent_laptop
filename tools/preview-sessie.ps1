# Preview Sessie - Show first N messages from session
# Usage: preview-sessie fc0bbf6c [-Aantal 10]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$SessieId,

    [int]$Aantal = 10
)

$sessionsScript = Join-Path $PSScriptRoot "sessions.ps1"
& $sessionsScript preview $SessieId -PreviewLines $Aantal
