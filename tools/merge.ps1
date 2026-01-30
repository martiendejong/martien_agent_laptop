#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick wrapper for merge-to-main.ps1
.EXAMPLE
    merge
    merge -Push
    merge -Repo client-manager
#>

param(
    [string]$Repo,
    [switch]$Push,
    [switch]$DryRun
)

$repoPath = if ($Repo) {
    # Map common repo names to paths
    $repoMap = @{
        "client-manager" = "C:\Projects\client-manager"
        "hazina" = "C:\Projects\hazina"
        "scripts" = "C:\scripts"
    }

    if ($repoMap.ContainsKey($Repo)) {
        $repoMap[$Repo]
    } else {
        $Repo
    }
} else {
    "."
}

$params = @{
    RepoPath = $repoPath
}

if ($Push) { $params.AutoPush = $true }
if ($DryRun) { $params.DryRun = $true }

& "$PSScriptRoot\merge-to-main.ps1" @params
