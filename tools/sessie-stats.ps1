<#
.SYNOPSIS
    Sessie Stats - Show session statistics dashboard

.DESCRIPTION
    Sessie Stats - Show session statistics dashboard

.NOTES
    File: sessie-stats.ps1
    Auto-generated help documentation
#>

$ErrorActionPreference = "Stop"

# Sessie Stats - Show session statistics dashboard
# Usage: sessie-stats
$sessionsScript = Join-Path $PSScriptRoot "sessions.ps1"
& $sessionsScript stats
