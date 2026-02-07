# Zoek Sessies - Search sessions by keyword
# Usage: zoek-sessies "worktree" [-Aantal 10]
<#
.SYNOPSIS
    Zoek Sessies - Search sessions by keyword

.DESCRIPTION
    Zoek Sessies - Search sessions by keyword

.NOTES
    File: zoek-sessies.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$true, Position=0)]

$ErrorActionPreference = "Stop"
    [string]$Zoekterm,

    [int]$Aantal = 10
)

$sessionsScript = Join-Path $PSScriptRoot "sessions.ps1"
& $sessionsScript search -Query $Zoekterm -Limit $Aantal
