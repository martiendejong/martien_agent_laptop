# Build detailed project context JSON files
# Author: Jengo, Created: 2026-02-09

param(
    [string]$ProjectName = "",
    [switch]$All
)

$ErrorActionPreference = "Stop"

$projectsDir = "C:\scripts\_machine\projects"

# Ensure projects directory exists
if (-not (Test-Path $projectsDir)) {
    New-Item -ItemType Directory -Path $projectsDir | Out-Null
}

# Project definitions
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
        wordpress_path = "E:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme"
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

    Write-Host "Building context for: $($Project.name)" -ForegroundColor Cyan

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
            $currentBranch = git -C $repoPath branch --show-current 2>$null
            $context.git_current_branch = $currentBranch

            $recentCommits = git -C $repoPath log --oneline -10 2>$null
            $context.git_recent_commits = @($recentCommits)

            $status = git -C $repoPath status --short 2>$null
            $context.git_status = @($status)
            $context.git_is_clean = ($status.Count -eq 0)

        } catch {
            Write-Host "  Git commands failed" -ForegroundColor Yellow
        }
    }

    # Write to file
    $outputFile = "$projectsDir\$($Project.name).json"
    $context | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8

    $fileSize = (Get-Item $outputFile).Length
    $fileSizeKB = [math]::Round($fileSize / 1KB, 2)

    Write-Host "  DONE: $outputFile ($fileSizeKB KB)" -ForegroundColor Green
}

# Build requested project(s)
if ($All) {
    Write-Host "Building all project contexts..." -ForegroundColor Cyan
    foreach ($project in $projects) {
        Build-ProjectContext -Project $project
    }
    Write-Host ""
    Write-Host "Built $($projects.Count) project contexts" -ForegroundColor Green
} elseif ($ProjectName) {
    $project = $projects | Where-Object { $_.name -eq $ProjectName }

    if (-not $project) {
        Write-Host "Unknown project: $ProjectName" -ForegroundColor Red
        Write-Host "Available: $($projects.name -join ', ')" -ForegroundColor Gray
        exit 1
    }

    Build-ProjectContext -Project $project
} else {
    Write-Host "Specify -ProjectName or -All" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Project contexts: $projectsDir" -ForegroundColor Cyan
