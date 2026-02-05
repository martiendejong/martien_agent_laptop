#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Auto-discover and map all projects in C:\Projects

.DESCRIPTION
    Scans C:\Projects for all repositories and project folders, analyzes their
    structure, dependencies, and relationships, then updates SYSTEM_MAP.md

.PARAMETER FullScan
    Perform deep analysis (read package.json, .csproj, README files)

.PARAMETER UpdateMap
    Automatically update SYSTEM_MAP.md with discoveries

.PARAMETER ProjectName
    Scan specific project only

.EXAMPLE
    .\system-map-scan-projects.ps1 -FullScan -UpdateMap
    Scan all projects and update system map

.EXAMPLE
    .\system-map-scan-projects.ps1 -ProjectName client-manager
    Analyze single project without updating map
#>

param(
    [switch]$FullScan,
    [switch]$UpdateMap,
    [string]$ProjectName
)

$ErrorActionPreference = "Stop"

# ANSI colors
$RED = "`e[31m"
$GREEN = "`e[32m"
$YELLOW = "`e[33m"
$BLUE = "`e[34m"
$RESET = "`e[0m"

Write-Host "${BLUE}🔍 System Map - Project Scanner${RESET}"
Write-Host ""

# Paths
$projectsPath = "C:\Projects"
$systemMapPath = "C:\scripts\SYSTEM_MAP.md"

# Check if projects directory exists
if (-not (Test-Path $projectsPath)) {
    Write-Host "${RED}❌ Projects directory not found: $projectsPath${RESET}"
    exit 1
}

# Helper: Detect project type
function Get-ProjectType {
    param([string]$path)

    $types = @()

    if (Test-Path "$path\package.json") { $types += "Node.js" }
    if (Test-Path "$path\*.csproj") { $types += "C#/.NET" }
    if (Test-Path "$path\*.sln") { $types += ".NET Solution" }
    if (Test-Path "$path\Cargo.toml") { $types += "Rust" }
    if (Test-Path "$path\go.mod") { $types += "Go" }
    if (Test-Path "$path\requirements.txt") { $types += "Python" }
    if (Test-Path "$path\composer.json") { $types += "PHP" }
    if (Test-Path "$path\.git") { $types += "Git Repo" }
    if (Test-Path "$path\README.md") { $types += "Documented" }

    if ($types.Count -eq 0) { return "Unknown" }
    return $types -join ", "
}

# Helper: Detect dependencies from package.json
function Get-NodeDependencies {
    param([string]$path)

    $packageJsonPath = "$path\package.json"
    if (-not (Test-Path $packageJsonPath)) { return @() }

    try {
        $packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
        $deps = @()

        if ($packageJson.dependencies) {
            $deps += $packageJson.dependencies.PSObject.Properties.Name
        }

        return $deps
    } catch {
        return @()
    }
}

# Helper: Detect C# dependencies from .csproj
function Get-DotnetDependencies {
    param([string]$path)

    $csprojFiles = Get-ChildItem -Path $path -Filter "*.csproj" -File
    if ($csprojFiles.Count -eq 0) { return @() }

    $deps = @()
    foreach ($csproj in $csprojFiles) {
        [xml]$content = Get-Content $csproj.FullName
        $packageRefs = $content.SelectNodes("//PackageReference")
        foreach ($ref in $packageRefs) {
            $deps += $ref.Include
        }
    }

    return $deps | Select-Object -Unique
}

# Helper: Check if git repo
function Get-GitInfo {
    param([string]$path)

    Push-Location $path
    try {
        if (-not (Test-Path ".git")) { return $null }

        $branch = git branch --show-current 2>$null
        $remote = git remote get-url origin 2>$null

        return @{
            Branch = $branch
            Remote = $remote
        }
    } finally {
        Pop-Location
    }
}

# Scan projects
Write-Host "${YELLOW}📂 Scanning C:\Projects...${RESET}"
$projects = Get-ChildItem -Path $projectsPath -Directory

if ($ProjectName) {
    $projects = $projects | Where-Object { $_.Name -eq $ProjectName }
    if ($projects.Count -eq 0) {
        Write-Host "${RED}❌ Project not found: $ProjectName${RESET}"
        exit 1
    }
}

Write-Host "Found $($projects.Count) projects"
Write-Host ""

$discoveries = @()

foreach ($project in $projects) {
    Write-Host "${BLUE}🔍 Scanning: $($project.Name)${RESET}"

    $projectPath = $project.FullName
    $type = Get-ProjectType $projectPath
    $gitInfo = Get-GitInfo $projectPath

    $discovery = @{
        Name = $project.Name
        Path = $projectPath
        Type = $type
        GitBranch = $gitInfo?.Branch
        GitRemote = $gitInfo?.Remote
        IsGitRepo = $null -ne $gitInfo
        Dependencies = @()
        Size = (Get-ChildItem -Path $projectPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    }

    if ($FullScan) {
        # Deep analysis
        if ($type -like "*Node.js*") {
            $discovery.Dependencies = Get-NodeDependencies $projectPath
        }
        if ($type -like "*C#*") {
            $discovery.Dependencies = Get-DotnetDependencies $projectPath
        }
    }

    $discoveries += [PSCustomObject]$discovery

    Write-Host "  Type: $type"
    Write-Host "  Git: $($gitInfo?.Branch ?? 'Not a repo')"
    if ($FullScan -and $discovery.Dependencies.Count -gt 0) {
        Write-Host "  Dependencies: $($discovery.Dependencies.Count)"
    }
    Write-Host ""
}

# Display summary
Write-Host ""
Write-Host "${GREEN}✅ Scan Complete${RESET}"
Write-Host ""
Write-Host "${YELLOW}📊 Summary by Type:${RESET}"

$discoveries | Group-Object { $_.Type } | ForEach-Object {
    Write-Host "  $($_.Name): $($_.Count)"
}

Write-Host ""
Write-Host "${YELLOW}📊 Git Repositories:${RESET}"
$gitRepos = $discoveries | Where-Object { $_.IsGitRepo }
Write-Host "  Total: $($gitRepos.Count)"
Write-Host ""

# Update system map if requested
if ($UpdateMap) {
    Write-Host "${YELLOW}📝 Updating SYSTEM_MAP.md...${RESET}"

    # Read current system map
    if (-not (Test-Path $systemMapPath)) {
        Write-Host "${RED}❌ System map not found: $systemMapPath${RESET}"
        exit 1
    }

    $systemMap = Get-Content $systemMapPath -Raw

    # Find the "Discovery Needed" section and update count
    $newCount = $discoveries.Count
    $systemMap = $systemMap -replace '\*\*Discovery Needed\*\* \(\d+\+ projects detected\)', "**Projects Mapped:** $newCount projects"

    # Save updated map
    Set-Content -Path $systemMapPath -Value $systemMap -NoNewline

    Write-Host "${GREEN}✅ System map updated${RESET}"
    Write-Host ""
}

# Export discoveries to JSON for further processing
$discoveryFile = "C:\scripts\_machine\project-discoveries.json"
$discoveries | ConvertTo-Json -Depth 10 | Set-Content $discoveryFile
Write-Host "${GREEN}✅ Discoveries saved to: $discoveryFile${RESET}"
Write-Host ""
Write-Host "${YELLOW}💡 Next Steps:${RESET}"
Write-Host "  1. Review discoveries: cat $discoveryFile | jq"
Write-Host "  2. Create PROJECT_MAP.md for key projects"
Write-Host "  3. Update SYSTEM_MAP.md with detailed info"
Write-Host "  4. Run with -FullScan for dependency analysis"
Write-Host ""
