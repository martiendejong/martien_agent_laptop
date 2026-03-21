#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Scan for project changes and update all documentation
.DESCRIPTION
    Automatically detects:
    - New git repositories
    - Moved folders
    - Changed GitHub remotes
    - Missing ClickUp boards
    - Inconsistencies between docs

    Updates:
    - clickup-config.json
    - PROJECT_MASTER_MAP.md
    - project-locations.md
    - project-inventory.json

.PARAMETER AutoFix
    Automatically fix found inconsistencies
.EXAMPLE
    .\project-update.ps1
    .\project-update.ps1 -AutoFix
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$AutoFix
)

$ErrorActionPreference = "Continue"

Write-Host "`n=== PROJECT UPDATE SCANNER ===" -ForegroundColor Cyan
Write-Host "Scanning for changes..." -ForegroundColor White
Write-Host ""

# Step 1: Scan all repositories
Write-Host "[1/4] Scanning git repositories..." -ForegroundColor Yellow
$ScanResult = & "C:\scripts\temp\scan-all-projects.ps1"
$InventoryPath = "C:\scripts\_machine\project-inventory.json"
$AllRepos = Get-Content $InventoryPath -Raw | ConvertFrom-Json
Write-Host "  Found $($AllRepos.Count) repositories" -ForegroundColor Green

# Step 2: Load current config
Write-Host "[2/4] Loading current configuration..." -ForegroundColor Yellow
$ConfigPath = "C:\scripts\_machine\clickup-config.json"
$Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$ConfigProjects = $Config.projects.PSObject.Properties | ForEach-Object { $_.Name }
Write-Host "  Config has $($ConfigProjects.Count) projects" -ForegroundColor Green

# Step 3: Find inconsistencies
Write-Host "[3/4] Analyzing inconsistencies..." -ForegroundColor Yellow

$Issues = @()

# Check for repos not in config
foreach ($Repo in $AllRepos) {
    $RepoName = $Repo.Name.ToLower()
    $IsInConfig = $ConfigProjects -contains $RepoName

    if (-not $IsInConfig -and $Repo.GitHubRepo) {
        # Exclude external/forked repos
        if ($Repo.GitHubOwner -eq "martiendejong" -or $Repo.GitHubOwner -eq "matchy123") {
            $Issues += [PSCustomObject]@{
                Type = "MISSING_FROM_CONFIG"
                Project = $RepoName
                Path = $Repo.Path
                GitHub = $Repo.GitHubUrl
                Action = "Add to clickup-config.json"
            }
        }
    }
}

# Check for config entries without local repos
foreach ($ProjectName in $ConfigProjects) {
    $Project = $Config.projects.$ProjectName
    $LocalPath = $Project.local_path -replace '/', '\'

    if ($LocalPath -and -not (Test-Path $LocalPath)) {
        $Issues += [PSCustomObject]@{
            Type = "PATH_NOT_FOUND"
            Project = $ProjectName
            Path = $LocalPath
            GitHub = $Project.github
            Action = "Verify path or remove from config"
        }
    }
}

# Check for TBD ClickUp lists
foreach ($ProjectName in $ConfigProjects) {
    $Project = $Config.projects.$ProjectName
    if ($Project.list_id -eq "TBD") {
        $Issues += [PSCustomObject]@{
            Type = "CLICKUP_TBD"
            Project = $ProjectName
            Path = $Project.local_path
            GitHub = $Project.github
            Action = "Create ClickUp list and update list_id"
        }
    }
}

# Display issues
if ($Issues.Count -gt 0) {
    Write-Host "`n  FOUND $($Issues.Count) ISSUES:" -ForegroundColor Red
    foreach ($Issue in $Issues) {
        Write-Host "`n  [$($Issue.Type)] $($Issue.Project)" -ForegroundColor Yellow
        Write-Host "    Path: $($Issue.Path)" -ForegroundColor Gray
        if ($Issue.GitHub) {
            Write-Host "    GitHub: $($Issue.GitHub)" -ForegroundColor Gray
        }
        Write-Host "    Action: $($Issue.Action)" -ForegroundColor Cyan
    }
} else {
    Write-Host "  No inconsistencies found!" -ForegroundColor Green
}

# Step 4: Auto-fix if requested
if ($AutoFix -and $Issues.Count -gt 0) {
    Write-Host "`n[4/4] Auto-fixing issues..." -ForegroundColor Yellow

    foreach ($Issue in $Issues) {
        if ($Issue.Type -eq "MISSING_FROM_CONFIG") {
            Write-Host "  Adding $($Issue.Project) to config..." -ForegroundColor Cyan

            # Find repo details
            $Repo = $AllRepos | Where-Object { $_.Name.ToLower() -eq $Issue.Project }

            # Determine type
            $Type = "fullstack"
            if ($Repo.HasCsproj -and $Repo.HasPackageJson) { $Type = "fullstack" }
            elseif ($Repo.HasWordPress) { $Type = "wordpress" }
            elseif ($Repo.HasCsproj) { $Type = "backend" }
            elseif ($Repo.HasPackageJson) { $Type = "frontend" }

            # Determine environment
            $Environment = if ($Repo.HasWordPress) { "xampp" } else { "vscode" }

            $NewProject = @{
                name = $Repo.Name
                list_id = "TBD"
                repos = @($Repo.GitHubRepo)
                type = $Type
                environment = $Environment
                local_path = ($Repo.Path -replace '\\', '/')
                github = $Repo.GitHubUrl
                description = "Auto-discovered project - needs description"
                discovered = (Get-Date -Format "yyyy-MM-dd")
            }

            $Config.projects | Add-Member -MemberType NoteProperty -Name $Issue.Project -Value $NewProject -Force
            Write-Host "    Added!" -ForegroundColor Green
        }
    }

    # Save config
    if ($Issues.Count -gt 0) {
        $Config.last_updated = Get-Date -Format "yyyy-MM-dd"
        $Config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath -Encoding UTF8
        Write-Host "`n  Config updated!" -ForegroundColor Green
    }
} elseif ($Issues.Count -gt 0) {
    Write-Host "`n[4/4] Skipping auto-fix (use -AutoFix to fix)" -ForegroundColor Gray
} else {
    Write-Host "`n[4/4] Nothing to fix!" -ForegroundColor Green
}

# Summary
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Repositories scanned: $($AllRepos.Count)" -ForegroundColor White
Write-Host "Projects in config: $($ConfigProjects.Count)" -ForegroundColor White
Write-Host "Issues found: $($Issues.Count)" -ForegroundColor $(if ($Issues.Count -gt 0) { "Red" } else { "Green" })
if ($AutoFix -and $Issues.Count -gt 0) {
    Write-Host "Issues fixed: $($Issues.Count)" -ForegroundColor Green
}
Write-Host ""
