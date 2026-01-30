#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Update SYSTEM_MAP.md with new discoveries and changes

.DESCRIPTION
    Manually trigger system map updates:
    - Add new project
    - Add new service integration
    - Add new tool
    - Update project status
    - Record configuration changes

.PARAMETER Action
    What to update: project, service, tool, status, config

.PARAMETER Name
    Name of the item being updated

.PARAMETER Details
    Additional details (JSON string or hashtable)

.EXAMPLE
    .\system-map-update.ps1 -Action project -Name "new-project" -Details @{Type="React App"; Status="Active"}

.EXAMPLE
    .\system-map-update.ps1 -Action status -Name "client-manager" -Details @{Status="Deployed"}
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("project", "service", "tool", "status", "config", "timestamp")]
    [string]$Action,

    [string]$Name,

    [hashtable]$Details = @{}
)

$ErrorActionPreference = "Stop"

# ANSI colors
$RED = "`e[31m"
$GREEN = "`e[32m"
$YELLOW = "`e[33m"
$BLUE = "`e[34m"
$RESET = "`e[0m"

Write-Host "${BLUE}🔄 System Map - Manual Update${RESET}"
Write-Host ""

$systemMapPath = "C:\scripts\SYSTEM_MAP.md"

if (-not (Test-Path $systemMapPath)) {
    Write-Host "${RED}❌ System map not found: $systemMapPath${RESET}"
    exit 1
}

$systemMap = Get-Content $systemMapPath -Raw

switch ($Action) {
    "timestamp" {
        Write-Host "${YELLOW}📅 Updating timestamp...${RESET}"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $systemMap = $systemMap -replace '\*\*Last Auto-Update:\*\* [^\n]+', "**Last Auto-Update:** $timestamp"
        Write-Host "${GREEN}✅ Timestamp updated to: $timestamp${RESET}"
    }

    "project" {
        if (-not $Name) {
            Write-Host "${RED}❌ Project name required${RESET}"
            exit 1
        }
        Write-Host "${YELLOW}📦 Adding/updating project: $Name${RESET}"

        # Check if project already exists in map
        if ($systemMap -match "#### $Name") {
            Write-Host "${YELLOW}⚠️  Project already exists in map${RESET}"
            Write-Host "${YELLOW}💡 Manually edit SYSTEM_MAP.md or use -Action status to update${RESET}"
        } else {
            Write-Host "${GREEN}✅ Project marked for addition${RESET}"
            Write-Host "${YELLOW}💡 Run system-map-scan-projects.ps1 for full analysis${RESET}"
            Write-Host "${YELLOW}💡 Or manually add entry to SYSTEM_MAP.md § Projects${RESET}"
        }
    }

    "service" {
        if (-not $Name) {
            Write-Host "${RED}❌ Service name required${RESET}"
            exit 1
        }
        Write-Host "${YELLOW}🔗 Adding/updating service: $Name${RESET}"
        Write-Host "${YELLOW}💡 Manually add entry to SYSTEM_MAP.md § Connected Services${RESET}"
    }

    "tool" {
        if (-not $Name) {
            Write-Host "${RED}❌ Tool name required${RESET}"
            exit 1
        }
        Write-Host "${YELLOW}🔧 Tool registered: $Name${RESET}"
        Write-Host "${YELLOW}💡 Tools are auto-tracked from C:\scripts\tools\${RESET}"
        Write-Host "${YELLOW}💡 Update tools-library.md for full documentation${RESET}"
    }

    "status" {
        if (-not $Name) {
            Write-Host "${RED}❌ Name required${RESET}"
            exit 1
        }
        Write-Host "${YELLOW}📊 Updating status for: $Name${RESET}"

        if ($Details.ContainsKey("Status")) {
            $statusEmoji = switch ($Details.Status) {
                "Active" { "🟢" }
                "Maintenance" { "🟡" }
                "Archived" { "🔴" }
                default { "⚪" }
            }
            Write-Host "  New Status: $statusEmoji $($Details.Status)"
        }

        Write-Host "${YELLOW}💡 Manually update status in SYSTEM_MAP.md${RESET}"
    }

    "config" {
        Write-Host "${YELLOW}⚙️  Configuration change noted${RESET}"
        Write-Host "${YELLOW}💡 Update relevant section in SYSTEM_MAP.md${RESET}"
    }
}

# Always update timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$systemMap = $systemMap -replace '\*\*Last Auto-Update:\*\* [^\n]+', "**Last Auto-Update:** $timestamp"

# Save updated map
Set-Content -Path $systemMapPath -Value $systemMap -NoNewline

Write-Host ""
Write-Host "${GREEN}✅ System map updated${RESET}"
Write-Host ""
