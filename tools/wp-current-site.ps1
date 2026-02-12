#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Show current active WordPress site
.DESCRIPTION
    Displays which site is currently active based on wp-config.php and database
#>

$ErrorActionPreference = "Stop"

$wpRoot = "E:\xampp\htdocs"
$wpConfigPath = "$wpRoot\wp-config.php"
$mysqlPath = "E:\xampp\mysql\bin\mysql.exe"

Write-Host "=== Current WordPress Site ===" -ForegroundColor Cyan
Write-Host ""

# Read database name from wp-config.php
$content = Get-Content $wpConfigPath -Raw
if ($content -match "define\(\s*'DB_NAME',\s*'([^']+)'\s*\)") {
    $dbName = $matches[1]
} else {
    Write-Host "Could not read DB_NAME from wp-config.php" -ForegroundColor Red
    exit 1
}

# Get active theme from database
$themeQuery = "SELECT option_value FROM wp_options WHERE option_name='template' LIMIT 1;"
$themeName = $themeQuery | & $mysqlPath -u root -N $dbName 2>&1

# Map to site name
$siteMap = @{
    "artrevisionist" = @{
        Name = "Art Revisionist"
        Theme = "artrevisionist-wp-theme"
    }
    "martiendejong" = @{
        Name = "martiendejong.nl"
        Theme = "martiendejong-wp-theme"
    }
    "hydrovision" = @{
        Name = "Hydro Vision"
        Theme = "hydro-vision"
    }
}

$site = $siteMap[$dbName]
if ($site) {
    Write-Host "Site: $($site.Name)" -ForegroundColor Green
    Write-Host "Database: $dbName" -ForegroundColor White
    Write-Host "Theme: $themeName" -ForegroundColor White

    if ($themeName -ne $site.Theme) {
        Write-Host "`nWarning: Expected theme '$($site.Theme)' but found '$themeName'" -ForegroundColor Yellow
    }
} else {
    Write-Host "Database: $dbName (unknown site)" -ForegroundColor Yellow
    Write-Host "Theme: $themeName" -ForegroundColor White
}

Write-Host "`nSite URL: http://localhost/" -ForegroundColor Cyan
Write-Host "Admin URL: http://localhost/wp-admin/" -ForegroundColor Cyan
