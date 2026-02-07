# Zoek Sessies - Search sessions by keyword
# Usage: zoek-sessies "worktree" [-Aantal 10]
param(
    [Parameter(Mandatory=$true, Position=0)]

$ErrorActionPreference = "Stop"
    [string]$Zoekterm,

    [int]$Aantal = 10
)

$sessionsScript = Join-Path $PSScriptRoot "sessions.ps1"
& $sessionsScript search -Query $Zoekterm -Limit $Aantal
