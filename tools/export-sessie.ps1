# Export Sessie - Export session to markdown
# Usage: export-sessie fc0bbf6c
<#
.SYNOPSIS
    Export Sessie - Export session to markdown

.DESCRIPTION
    Export Sessie - Export session to markdown

.NOTES
    File: export-sessie.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$true, Position=0)]

$ErrorActionPreference = "Stop"
    [string]$SessieId
)

$sessionsScript = Join-Path $PSScriptRoot "sessions.ps1"
& $sessionsScript export $SessieId
