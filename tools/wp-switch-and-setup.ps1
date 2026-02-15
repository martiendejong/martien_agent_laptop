#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Switch WordPress site and auto-setup if needed
.DESCRIPTION
    Switches to specified site and automatically installs WordPress if database is empty
.PARAMETER Site
    Site name: artrevisionist, martiendejong, or hydrovision
.EXAMPLE
    .\wp-switch-and-setup.ps1 -Site martiendejong
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("artrevisionist", "martiendejong", "hydrovision", "maasaiinvestments")]
    [string]$Site
)

$ErrorActionPreference = "Stop"

$wpRoot = "E:\xampp\htdocs"
$mysqlPath = "E:\xampp\mysql\bin\mysql.exe"
$wpCliPath = "C:\scripts\wp.bat"

# Site configurations
$siteConfig = @{
    "artrevisionist" = @{
        DBName = "artrevisionist"
        Theme = "artrevisionist-wp-theme"
        Title = "Art Revisionist"
    }
    "martiendejong" = @{
        DBName = "martiendejong"
        Theme = "martiendejong-wp-theme"
        Title = "Martien de Jong"
    }
    "hydrovision" = @{
        DBName = "hydrovision"
        Theme = "hydro-vision"
        Title = "Hydro Vision"
    }
    "maasaiinvestments" = @{
        DBName = "maasaiinvestments"
        Theme = "maasai-investments-theme"
        Title = "Maasai Investments"
    }
}

$config = $siteConfig[$Site]
$dbName = $config.DBName
$themeName = $config.Theme
$siteTitle = $config.Title

Write-Host "=== Switching to $siteTitle ===" -ForegroundColor Cyan
Write-Host ""

# 1. Update wp-config.php
Write-Host "[1/4] Updating wp-config.php..." -ForegroundColor Yellow
$wpConfigPath = "$wpRoot\wp-config.php"
Copy-Item $wpConfigPath "$wpConfigPath.backup" -Force

$content = Get-Content $wpConfigPath -Raw
$content = $content -replace "define\(\s*'DB_NAME',\s*'[^']+'\s*\);", "define( 'DB_NAME', '$dbName' );"
Set-Content $wpConfigPath $content -NoNewline

Write-Host "      Database: $dbName" -ForegroundColor Gray

# 2. Check if database has WordPress
Write-Host "[2/4] Checking database..." -ForegroundColor Yellow
$tableCheck = "SHOW TABLES LIKE 'wp_options';" | & $mysqlPath -u root $dbName 2>&1
$hasWordPress = $tableCheck -match "wp_options"

if (-not $hasWordPress) {
    Write-Host "      Database is empty, installing WordPress..." -ForegroundColor Gray

    # Install WordPress
    Push-Location $wpRoot
    & $wpCliPath core install `
        --url="http://localhost" `
        --title="$siteTitle" `
        --admin_user="admin" `
        --admin_password="admin" `
        --admin_email="admin@localhost.local" `
        --skip-email 2>&1 | Out-Null

    if ($LASTEXITCODE -ne 0) {
        Write-Host "      WordPress installation failed!" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
    Write-Host "      WordPress installed successfully" -ForegroundColor Green
} else {
    Write-Host "      WordPress already installed" -ForegroundColor Gray
}

# 3. Activate theme
Write-Host "[3/4] Activating theme..." -ForegroundColor Yellow
$updateQuery = @"
UPDATE wp_options SET option_value='$themeName' WHERE option_name='template';
UPDATE wp_options SET option_value='$themeName' WHERE option_name='stylesheet';
"@
$updateQuery | & $mysqlPath -u root $dbName 2>&1 | Out-Null
Write-Host "      Theme: $themeName" -ForegroundColor Gray

# 4. Flush rewrite rules
Write-Host "[4/4] Flushing rewrite rules..." -ForegroundColor Yellow
Push-Location $wpRoot
& $wpCliPath rewrite flush 2>&1 | Out-Null
Pop-Location

# Done
Write-Host "`n=== Switch Complete ===" -ForegroundColor Green
Write-Host "Site: $siteTitle" -ForegroundColor White
Write-Host "Database: $dbName" -ForegroundColor White
Write-Host "Theme: $themeName" -ForegroundColor White
if (-not $hasWordPress) {
    Write-Host "`nAdmin credentials:" -ForegroundColor Yellow
    Write-Host "  Username: admin" -ForegroundColor White
    Write-Host "  Password: admin" -ForegroundColor White
}
Write-Host "`nSite URL: http://localhost/" -ForegroundColor Cyan
Write-Host "Admin URL: http://localhost/wp-admin/" -ForegroundColor Cyan
Write-Host "Backup: $wpConfigPath.backup" -ForegroundColor Gray
