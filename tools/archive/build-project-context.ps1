#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build detailed project context JSON files

.DESCRIPTION
    Creates detailed on-demand context files for each project.
    Includes git state, dependencies, file locations, recent commits, etc.

.PARAMETER ProjectName
    Project name (client-manager, hazina, art-revisionist, etc.)

.PARAMETER All
    Build context for all projects

.EXAMPLE
    .\build-project-context.ps1 -ProjectName "client-manager"

.EXAMPLE
    .\build-project-context.ps1 -All

.NOTES
    Author: Jengo
    Created: 2026-02-09
    ROI: 6.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectName = "",

    [Parameter(Mandatory = $false)]
    [switch]$All
)

$ErrorActionPreference = "Stop"

$projectsDir = "C:\scripts\_machine\projects"

# Ensure projects directory exists
if (-not (Test-Path $projectsDir)) {
    New-Item -ItemType Directory -Path $projectsDir | Out-Null
}

# Project definitions (extend as needed)
$projects = @(
    @{
        name = "client-manager"
        type = "SaaS Application"
        code_path = "C:\Projects\client-manager"
        framework_path = "C:\Projects\hazina"
        store_path = "C:\stores\brand2boost"
        main_branch = "develop"
        requires_paired_worktree = $true
        paired_repo = "hazina"
    }
    @{
        name = "hazina"
        type = "Framework"
        code_path = "C:\Projects\hazina"
        main_branch = "develop"
    }
    @{
        name = "art-revisionist"
        type = "WordPress + React Admin"
        wordpress_path = "C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme"
        admin_path = "C:\Projects\artrevisionist\artrevisionist"
        main_branch = "develop"
    }
    @{
        name = "hydro-vision-website"
        type = "Static Website"
        code_path = "C:\Projects\hydro-vision-website"
        main_branch = "main"
        worktree_exempt = $true
    }
)

function Build-ProjectContext {
    param($Project)

    Write-Host "🔨 Building context for: $($Project.name)" -ForegroundColor Cyan

    $context = @{
        name = $Project.name
        type = $Project.type
        generated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }

    # Copy basic info
    foreach ($key in $Project.Keys) {
        if ($key -ne "name" -and $key -ne "type") {
            $context[$key] = $Project[$key]
        }
    }

    # Git state (if code_path exists)
    if ($Project.code_path -and (Test-Path $Project.code_path)) {
        $repoPath = $Project.code_path

        try {
            # Current branch
            $currentBranch = git -C $repoPath branch --show-current 2>$null
            $context.git_current_branch = $currentBranch

            # Recent commits (last 10)
            $recentCommits = git -C $repoPath log --oneline -10 2>$null
            $context.git_recent_commits = @($recentCommits)

            # Branch list
            $branches = git -C $repoPath branch -a 2>$null
            $context.git_branches = @($branches)

            # Uncommitted changes
            $status = git -C $repoPath status --short 2>$null
            $context.git_status = @($status)
            $context.git_is_clean = ($status.Count -eq 0)

            # Remote URL
            $remoteUrl = git -C $repoPath remote get-url origin 2>$null
            $context.git_remote_url = $remoteUrl

        } catch {
            Write-Host "  ⚠️  Git commands failed: $_" -ForegroundColor Yellow
        }
    }

    # File counts (if code_path exists)
    if ($Project.code_path -and (Test-Path $Project.code_path)) {
        $repoPath = $Project.code_path

        $csFiles = (Get-ChildItem -Path $repoPath -Recurse -Filter "*.cs" -File -ErrorAction SilentlyContinue).Count
        $tsFiles = (Get-ChildItem -Path $repoPath -Recurse -Filter "*.ts" -File -ErrorAction SilentlyContinue).Count
        $tsxFiles = (Get-ChildItem -Path $repoPath -Recurse -Filter "*.tsx" -File -ErrorAction SilentlyContinue).Count
        $jsFiles = (Get-ChildItem -Path $repoPath -Recurse -Filter "*.js" -File -ErrorAction SilentlyContinue).Count

        $context.file_counts = @{
            cs = $csFiles
            ts = $tsFiles
            tsx = $tsxFiles
            js = $jsFiles
        }
    }

    # Dependencies (for paired worktree projects)
    if ($Project.requires_paired_worktree) {
        $context.dependencies = @{
            paired_repo = $Project.paired_repo
            note = "When allocating worktree for this project, MUST also allocate paired repo worktree"
        }
    }

    # Write to file
    $outputFile = "$projectsDir\$($Project.name).json"
    $context | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8

    $fileSize = (Get-Item $outputFile).Length
    $fileSizeKB = [math]::Round($fileSize / 1KB, 2)

    Write-Host "  ✅ Saved: $outputFile ($fileSizeKB KB)" -ForegroundColor Green
}

# Build requested project(s)
if ($All) {
    Write-Host "🏗️  Building all project contexts..." -ForegroundColor Cyan
    foreach ($project in $projects) {
        Build-ProjectContext -Project $project
    }
    Write-Host ""
    Write-Host "✅ Built $($projects.Count) project contexts" -ForegroundColor Green
} elseif ($ProjectName) {
    $project = $projects | Where-Object { $_.name -eq $ProjectName }

    if (-not $project) {
        Write-Host "❌ Unknown project: $ProjectName" -ForegroundColor Red
        Write-Host "   Available: $($projects.name -join ', ')" -ForegroundColor Gray
        exit 1
    }

    Build-ProjectContext -Project $project
} else {
    Write-Host "❌ Specify -ProjectName or -All" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📂 Project contexts: $projectsDir" -ForegroundColor Cyan
