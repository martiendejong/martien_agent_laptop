#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick WordPress installation for empty database
.DESCRIPTION
    Installs WordPress in current database using WP-CLI
.PARAMETER SiteTitle
    Title of the WordPress site
.PARAMETER AdminUser
    Admin username (default: admin)
.PARAMETER AdminPassword
    Admin password (default: admin)
.PARAMETER AdminEmail
    Admin email (default: admin@localhost.local)
.EXAMPLE
    .\wp-quick-install.ps1 -SiteTitle "My Site"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$SiteTitle,

    [string]$AdminUser = "admin",
    [string]$AdminPassword = "admin",
    [string]$AdminEmail = "admin@localhost.local"
)

$ErrorActionPreference = "Stop"

$wpRoot = "E:\xampp\htdocs"
$wpCliPath = "C:\scripts\wp.bat"

Write-Host "=== Quick WordPress Installation ===" -ForegroundColor Cyan
Write-Host "Site: $SiteTitle" -ForegroundColor White
Write-Host "URL: http://localhost/" -ForegroundColor White
Write-Host ""

# Check if WP is already installed
Write-Host "Checking current installation..." -ForegroundColor Yellow
Push-Location $wpRoot
try {
    $isInstalled = & $wpCliPath core is-installed 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "WordPress is already installed!" -ForegroundColor Red
        Write-Host "Database contains existing WordPress installation." -ForegroundColor Yellow
        Pop-Location
        exit 1
    }
} catch {
    # Not installed, continue
}

# Install WordPress
Write-Host "Installing WordPress..." -ForegroundColor Yellow
& $wpCliPath core install `
    --url="http://localhost" `
    --title="$SiteTitle" `
    --admin_user="$AdminUser" `
    --admin_password="$AdminPassword" `
    --admin_email="$AdminEmail" `
    --skip-email

if ($LASTEXITCODE -ne 0) {
    Write-Host "Installation failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "`n=== Installation Complete ===" -ForegroundColor Green
Write-Host "Site Title: $SiteTitle" -ForegroundColor White
Write-Host "Admin User: $AdminUser" -ForegroundColor White
Write-Host "Admin Password: $AdminPassword" -ForegroundColor White
Write-Host "Admin Email: $AdminEmail" -ForegroundColor White
Write-Host "`nAdmin URL: http://localhost/wp-admin/" -ForegroundColor Cyan
Write-Host "Site URL: http://localhost/" -ForegroundColor Cyan

Pop-Location
