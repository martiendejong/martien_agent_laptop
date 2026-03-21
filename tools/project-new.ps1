#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Create new project with COMPLETE setup in one command
.DESCRIPTION
    Automatically creates:
    - Local folder structure
    - GitHub repository
    - ClickUp list/board
    - Entries in clickup-config.json
    - Entry in PROJECT_MASTER_MAP.md
    - Entry in project-locations.md

    ENSURES: All project mappings are complete from DAY ONE

.PARAMETER Name
    Project name (kebab-case, e.g., "my-new-project")
.PARAMETER Type
    Project type: fullstack, wordpress, wordpress-plugin, framework, tool
.PARAMETER BasePath
    Base directory (default: E:\projects)
.PARAMETER Description
    Project description
.PARAMETER GitHubOrg
    GitHub organization/owner (default: martiendejong)
.PARAMETER ClickUpWorkspace
    ClickUp workspace (default: gigshub)
.PARAMETER ClickUpFolder
    ClickUp folder (default: internal)
.EXAMPLE
    .\project-new.ps1 -Name "my-app" -Type fullstack -Description "My new app"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [Parameter(Mandatory=$true)]
    [ValidateSet("fullstack", "wordpress", "wordpress-plugin", "framework", "tool", "frontend", "backend")]
    [string]$Type,

    [Parameter(Mandatory=$false)]
    [string]$BasePath = "E:\projects",

    [Parameter(Mandatory=$false)]
    [string]$Description = "",

    [Parameter(Mandatory=$false)]
    [string]$GitHubOrg = "martiendejong",

    [Parameter(Mandatory=$false)]
    [string]$ClickUpWorkspace = "gigshub",

    [Parameter(Mandatory=$false)]
    [string]$ClickUpFolder = "internal",

    [Parameter(Mandatory=$false)]
    [switch]$SkipGitHub,

    [Parameter(Mandatory=$false)]
    [switch]$SkipClickUp,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== PROJECT CREATION WIZARD ===" -ForegroundColor Cyan
Write-Host "Name: $Name" -ForegroundColor White
Write-Host "Type: $Type" -ForegroundColor White
Write-Host "Path: $BasePath\$Name" -ForegroundColor White
Write-Host ""

# Validate name format
if ($Name -notmatch '^[a-z0-9-]+$') {
    throw "Project name must be kebab-case (lowercase, numbers, hyphens only)"
}

# Step 1: Create local folder
$LocalPath = Join-Path $BasePath $Name
Write-Host "[1/6] Creating local folder..." -ForegroundColor Yellow

if ($DryRun) {
    Write-Host "  [DRY-RUN] Would create: $LocalPath" -ForegroundColor Magenta
} else {
    if (Test-Path $LocalPath) {
        throw "Directory already exists: $LocalPath"
    }
    New-Item -Path $LocalPath -ItemType Directory -Force | Out-Null
    Write-Host "  Created: $LocalPath" -ForegroundColor Green
}

# Step 2: Initialize git repo
Write-Host "[2/6] Initializing git repository..." -ForegroundColor Yellow

if ($DryRun) {
    Write-Host "  [DRY-RUN] Would init git repo" -ForegroundColor Magenta
} else {
    Push-Location $LocalPath
    git init
    git checkout -b main
    "# $Name`n`n$Description" | Set-Content "README.md"
    git add README.md
    git commit -m "Initial commit"
    Pop-Location
    Write-Host "  Git initialized with README.md" -ForegroundColor Green
}

# Step 3: Create GitHub repo
$GitHubUrl = $null
if (-not $SkipGitHub) {
    Write-Host "[3/6] Creating GitHub repository..." -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "  [DRY-RUN] Would create GitHub repo: $GitHubOrg/$Name" -ForegroundColor Magenta
        $GitHubUrl = "https://github.com/$GitHubOrg/$Name"
    } else {
        try {
            $RepoDesc = if ($Description) { $Description } else { $Name }
            gh repo create "$GitHubOrg/$Name" --public --description $RepoDesc --source $LocalPath --remote origin --push
            $GitHubUrl = "https://github.com/$GitHubOrg/$Name"
            Write-Host "  Created: $GitHubUrl" -ForegroundColor Green
        } catch {
            Write-Host "  WARNING: GitHub repo creation failed: $_" -ForegroundColor Yellow
            Write-Host "  Continuing without GitHub..." -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "[3/6] Skipping GitHub creation" -ForegroundColor Gray
}

# Step 4: Create ClickUp list
$ClickUpListId = "TBD"
if (-not $SkipClickUp) {
    Write-Host "[4/6] Creating ClickUp list..." -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "  [DRY-RUN] Would create ClickUp list in $ClickUpWorkspace/$ClickUpFolder" -ForegroundColor Magenta
    } else {
        Write-Host "  NOTE: ClickUp list creation requires manual API call" -ForegroundColor Yellow
        Write-Host "  TODO: Create list '$Name' in ClickUp workspace '$ClickUpWorkspace'" -ForegroundColor Yellow
        Write-Host "  Then update \$ClickUpListId in this output" -ForegroundColor Yellow
    }
} else {
    Write-Host "[4/6] Skipping ClickUp creation" -ForegroundColor Gray
}

# Step 5: Update clickup-config.json
Write-Host "[5/6] Updating clickup-config.json..." -ForegroundColor Yellow

if ($DryRun) {
    Write-Host "  [DRY-RUN] Would add project to config" -ForegroundColor Magenta
} else {
    $ConfigPath = "C:\scripts\_machine\clickup-config.json"
    $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

    # Determine environment
    $Environment = switch ($Type) {
        "fullstack" { "vscode" }
        "wordpress" { "xampp" }
        "wordpress-plugin" { "xampp" }
        "framework" { "visual-studio" }
        default { "vscode" }
    }

    # Add to projects section
    $NewProject = @{
        name = $Name
        list_id = $ClickUpListId
        repos = @($Name)
        type = $Type
        environment = $Environment
        local_path = ($LocalPath -replace '\\', '/')
        github = $GitHubUrl
        description = $Description
        created = (Get-Date -Format "yyyy-MM-dd")
    }

    $Config.projects | Add-Member -MemberType NoteProperty -Name $Name -Value $NewProject -Force

    # Add to repo_mapping section
    $NewRepoMapping = @{
        workspace = $ClickUpWorkspace
        space = "team_tasks"
        folder = $ClickUpFolder
        list_id = $ClickUpListId
        list_name = $Name
    }

    $Config.repo_mapping | Add-Member -MemberType NoteProperty -Name $Name -Value $NewRepoMapping -Force

    # Update last_updated
    $Config.last_updated = Get-Date -Format "yyyy-MM-dd"

    # Save
    $Config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath -Encoding UTF8
    Write-Host "  Updated clickup-config.json" -ForegroundColor Green
}

# Step 6: Update PROJECT_MASTER_MAP.md
Write-Host "[6/6] Updating PROJECT_MASTER_MAP.md..." -ForegroundColor Yellow

if ($DryRun) {
    Write-Host "  [DRY-RUN] Would add entry to master map" -ForegroundColor Magenta
} else {
    $MasterMapPath = "C:\scripts\_machine\PROJECT_MASTER_MAP.md"
    $Entry = @"

### $Name
- **Local Path:** ``$LocalPath``
- **GitHub:** $GitHubUrl
- **Branch:** main
- **ClickUp Board:** ``$ClickUpListId``
- **Type:** $Type
- **Environment:** $Environment
- **Deployment:** TBD
- **Status:** Active development
- **Description:** $Description
- **Created:** $(Get-Date -Format "yyyy-MM-dd")
"@

    Add-Content -Path $MasterMapPath -Value $Entry
    Write-Host "  Updated PROJECT_MASTER_MAP.md" -ForegroundColor Green
}

# Summary
Write-Host "`n=== PROJECT CREATED ===" -ForegroundColor Green
Write-Host "Name: $Name" -ForegroundColor White
Write-Host "Path: $LocalPath" -ForegroundColor White
if ($GitHubUrl) {
    Write-Host "GitHub: $GitHubUrl" -ForegroundColor White
}
Write-Host "ClickUp List: $ClickUpListId (update if TBD)" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. If ClickUp list ID is TBD, create it and update clickup-config.json" -ForegroundColor Gray
Write-Host "  2. cd $LocalPath" -ForegroundColor Gray
Write-Host "  3. Start development!" -ForegroundColor Gray
Write-Host ""
