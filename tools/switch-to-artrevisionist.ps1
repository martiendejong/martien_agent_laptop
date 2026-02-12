#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Switch WordPress to ArtRevisionist site
.DESCRIPTION
    Changes database to 'artrevisionist' and activates artrevisionist-wp-theme
#>

$ErrorActionPreference = "Stop"

$wpRoot = "E:\xampp\htdocs"
$wpConfigPath = "$wpRoot\wp-config.php"
$mysqlPath = "E:\xampp\mysql\bin\mysql.exe"
$dbName = "artrevisionist"
$themeName = "artrevisionist-wp-theme"

Write-Host "=== Switching to ArtRevisionist ===" -ForegroundColor Cyan

# 1. Backup current wp-config.php
Write-Host "1. Backing up wp-config.php..." -ForegroundColor Yellow
Copy-Item $wpConfigPath "$wpConfigPath.backup" -Force

# 2. Update DB_NAME in wp-config.php
Write-Host "2. Updating database name to '$dbName'..." -ForegroundColor Yellow
$content = Get-Content $wpConfigPath -Raw
$content = $content -replace "define\(\s*'DB_NAME',\s*'[^']+'\s*\);", "define( 'DB_NAME', '$dbName' );"
Set-Content $wpConfigPath $content -NoNewline

# 3. Activate theme via MySQL
Write-Host "3. Activating theme '$themeName'..." -ForegroundColor Yellow
$updateQuery = @"
UPDATE wp_options SET option_value='$themeName' WHERE option_name='template';
UPDATE wp_options SET option_value='$themeName' WHERE option_name='stylesheet';
"@

$updateQuery | & $mysqlPath -u root $dbName 2>&1 | Out-Null

# 4. Verify
Write-Host "`n=== Switch Complete ===" -ForegroundColor Green
Write-Host "Database: $dbName" -ForegroundColor White
Write-Host "Theme: $themeName" -ForegroundColor White
Write-Host "`nVisit: http://localhost/" -ForegroundColor Cyan
Write-Host "Backup saved at: $wpConfigPath.backup" -ForegroundColor Gray
