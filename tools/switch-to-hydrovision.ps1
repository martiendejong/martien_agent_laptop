#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Switch WordPress to Hydro Vision site
.DESCRIPTION
    Changes database to 'hydrovision' and activates hydro-vision theme
#>

$ErrorActionPreference = "Stop"

$wpRoot = "E:\xampp\htdocs"
$wpConfigPath = "$wpRoot\wp-config.php"
$mysqlPath = "E:\xampp\mysql\bin\mysql.exe"
$dbName = "hydrovision"
$themeName = "hydro-vision"

Write-Host "=== Switching to Hydro Vision ===" -ForegroundColor Cyan

# 1. Backup current wp-config.php
Write-Host "1. Backing up wp-config.php..." -ForegroundColor Yellow
Copy-Item $wpConfigPath "$wpConfigPath.backup" -Force

# 2. Update DB_NAME in wp-config.php
Write-Host "2. Updating database name to '$dbName'..." -ForegroundColor Yellow
$content = Get-Content $wpConfigPath -Raw
$content = $content -replace "define\(\s*'DB_NAME',\s*'[^']+'\s*\);", "define( 'DB_NAME', '$dbName' );"
Set-Content $wpConfigPath $content -NoNewline

# 3. Check if database has WordPress tables
Write-Host "3. Checking database..." -ForegroundColor Yellow
$tableCheck = "SHOW TABLES LIKE 'wp_options';" | & $mysqlPath -u root $dbName 2>&1
if ($tableCheck -match "wp_options") {
    # Database exists with tables, just activate theme
    Write-Host "   Database exists, activating theme '$themeName'..." -ForegroundColor Yellow
    $updateQuery = @"
UPDATE wp_options SET option_value='$themeName' WHERE option_name='template';
UPDATE wp_options SET option_value='$themeName' WHERE option_name='stylesheet';
"@
    $updateQuery | & $mysqlPath -u root $dbName 2>&1 | Out-Null
} else {
    # Fresh database, needs WordPress installation
    Write-Host "   Database is empty - WordPress installation required" -ForegroundColor Red
    Write-Host "   Visit http://localhost/wp-admin/install.php to complete setup" -ForegroundColor Yellow
    Write-Host "   Then activate '$themeName' theme from Appearance > Themes" -ForegroundColor Yellow
}

# 4. Verify
Write-Host "`n=== Switch Complete ===" -ForegroundColor Green
Write-Host "Database: $dbName" -ForegroundColor White
Write-Host "Theme: $themeName" -ForegroundColor White
Write-Host "`nVisit: http://localhost/" -ForegroundColor Cyan
Write-Host "Backup saved at: $wpConfigPath.backup" -ForegroundColor Gray
