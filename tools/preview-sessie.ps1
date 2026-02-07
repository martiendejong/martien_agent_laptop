# Preview Sessie - Show first N messages from session
# Usage: preview-sessie fc0bbf6c [-Aantal 10]
<#
.SYNOPSIS
    Preview Sessie - Show first N messages from session

.DESCRIPTION
    Preview Sessie - Show first N messages from session

.NOTES
    File: preview-sessie.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$true, Position=0)]

$ErrorActionPreference = "Stop"
    [string]$SessieId,

    [int]$Aantal = 10
)

$sessionsScript = Join-Path $PSScriptRoot "sessions.ps1"
& $sessionsScript preview $SessieId -PreviewLines $Aantal
