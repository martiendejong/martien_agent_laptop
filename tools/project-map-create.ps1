#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Create PROJECT_MAP.md for a specific project

.DESCRIPTION
    Generates a project map from template, auto-fills what can be detected,
    and creates the file in the project directory

.PARAMETER ProjectName
    Name of project (folder name in C:\Projects)

.PARAMETER ProjectPath
    Full path to project (if not in C:\Projects)

.EXAMPLE
    .\project-map-create.ps1 -ProjectName client-manager

.EXAMPLE
    .\project-map-create.ps1 -ProjectPath "C:\Projects\hazina"
#>

param(
    [string]$ProjectName,
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"

# ANSI colors
$RED = "`e[31m"
$GREEN = "`e[32m"
$YELLOW = "`e[33m"
$BLUE = "`e[34m"
$RESET = "`e[0m"

Write-Host "${BLUE}📋 Project Map Creator${RESET}"
Write-Host ""

# Determine project path
if ($ProjectPath) {
    if (-not (Test-Path $ProjectPath)) {
        Write-Host "${RED}❌ Project path not found: $ProjectPath${RESET}"
        exit 1
    }
    $ProjectName = Split-Path $ProjectPath -Leaf
} elseif ($ProjectName) {
    $ProjectPath = "C:\Projects\$ProjectName"
    if (-not (Test-Path $ProjectPath)) {
        Write-Host "${RED}❌ Project not found: $ProjectPath${RESET}"
        exit 1
    }
} else {
    Write-Host "${RED}❌ ProjectName or ProjectPath required${RESET}"
    exit 1
}

Write-Host "${YELLOW}📂 Project: $ProjectName${RESET}"
Write-Host "${YELLOW}📍 Path: $ProjectPath${RESET}"
Write-Host ""

# Load template
$templatePath = "C:\scripts\templates\PROJECT_MAP.template.md"
if (-not (Test-Path $templatePath)) {
    Write-Host "${RED}❌ Template not found: $templatePath${RESET}"
    exit 1
}

$template = Get-Content $templatePath -Raw

# Auto-detect project info
Write-Host "${YELLOW}🔍 Auto-detecting project info...${RESET}"

$projectType = "Unknown"
$techStack = @()
$gitBranch = "N/A"
$gitRemote = "N/A"

# Check project type
if (Test-Path "$ProjectPath\package.json") {
    $techStack += "Node.js"
    try {
        $packageJson = Get-Content "$ProjectPath\package.json" -Raw | ConvertFrom-Json
        if ($packageJson.dependencies.react) { $techStack += "React" }
        if ($packageJson.dependencies.typescript) { $techStack += "TypeScript" }
        if ($packageJson.dependencies.vue) { $techStack += "Vue" }
    } catch {}
}

if (Test-Path "$ProjectPath\*.csproj") {
    $techStack += "ASP.NET Core"
}

if (Test-Path "$ProjectPath\*.sln") {
    $projectType = ".NET Solution"
}

# Git info
Push-Location $ProjectPath
try {
    if (Test-Path ".git") {
        $gitBranch = git branch --show-current 2>$null
        $gitRemote = git remote get-url origin 2>$null
    }
} finally {
    Pop-Location
}

if ($techStack.Count -gt 0) {
    $projectType = $techStack -join " + "
}

# Fill template
$date = Get-Date -Format "yyyy-MM-dd"
$filled = $template `
    -replace '\[PROJECT_NAME\]', $ProjectName `
    -replace '\[PROJECT_PATH\]', $ProjectPath `
    -replace '\[DATE\]', $date `
    -replace '\[e\.g\., Full-stack SaaS, Static Website, Framework, etc\.\]', $projectType `
    -replace '\[e\.g\., React \+ TypeScript \+ ASP\.NET Core\]', $projectType `
    -replace '\[GitHub URL or "Local only"\]', ($gitRemote -ne "N/A" ? $gitRemote : "Local only") `
    -replace '\[e\.g\., develop, main\]', ($gitBranch -ne "N/A" ? $gitBranch : "main") `
    -replace '\[Active Development / Stable / Archived\]', "Active Development"

# Save to project directory
$outputPath = "$ProjectPath\PROJECT_MAP.md"

if (Test-Path $outputPath) {
    Write-Host "${YELLOW}⚠️  PROJECT_MAP.md already exists${RESET}"
    $response = Read-Host "Overwrite? (y/N)"
    if ($response -ne "y") {
        Write-Host "${YELLOW}❌ Cancelled${RESET}"
        exit 0
    }
}

Set-Content -Path $outputPath -Value $filled -NoNewline

Write-Host "${GREEN}✅ Project map created: $outputPath${RESET}"
Write-Host ""
Write-Host "${YELLOW}📝 Next Steps:${RESET}"
Write-Host "  1. Review and fill in [placeholders]"
Write-Host "  2. Document dependencies and workflows"
Write-Host "  3. Add to git: git add PROJECT_MAP.md && git commit"
Write-Host "  4. Update SYSTEM_MAP.md reference"
Write-Host ""
