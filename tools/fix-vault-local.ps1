# Fix vault.prospergenics.com SQLite Database Issue
# Run this script LOCALLY on the vault.prospergenics.com server as Administrator

param(
    [string]$SitePath = "C:\inetpub\vault.prospergenics.com"
)

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "   vault.prospergenics.com Database Fix Script" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Running as Administrator" -ForegroundColor Green
Write-Host ""

# Step 1: Check if site exists
Write-Host "STEP 1: Verifying site path..." -ForegroundColor Yellow
if (-not (Test-Path $SitePath)) {
    Write-Host "ERROR: Site path not found: $SitePath" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Site path found: $SitePath" -ForegroundColor Green
Write-Host ""

# Step 2: Create Data directory
Write-Host "STEP 2: Creating Data directory..." -ForegroundColor Yellow
$dataPath = Join-Path $SitePath "Data"
if (-not (Test-Path $dataPath)) {
    New-Item -ItemType Directory -Path $dataPath -Force | Out-Null
    Write-Host "✓ Created directory: $dataPath" -ForegroundColor Green
} else {
    Write-Host "✓ Directory already exists: $dataPath" -ForegroundColor Green
}
Write-Host ""

# Step 3: Get application pool
Write-Host "STEP 3: Identifying application pool..." -ForegroundColor Yellow
Import-Module WebAdministration
$appPool = (Get-Website -Name 'vault.prospergenics.com').applicationPool
if ([string]::IsNullOrEmpty($appPool)) {
    $appPool = "DefaultAppPool"
    Write-Host "⚠ Could not determine app pool, using: $appPool" -ForegroundColor Yellow
} else {
    Write-Host "✓ Application Pool: $appPool" -ForegroundColor Green
}
Write-Host ""

# Step 4: Grant permissions
Write-Host "STEP 4: Granting permissions to application pool..." -ForegroundColor Yellow
$identity = "IIS AppPool\$appPool"
try {
    $acl = Get-Acl $dataPath
    $permission = $identity, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.SetAccessRule($accessRule)
    Set-Acl $dataPath $acl
    Write-Host "✓ Granted FullControl to: $identity" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to set permissions: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 5: Update appsettings.Production.json
Write-Host "STEP 5: Updating connection string..." -ForegroundColor Yellow
$configPath = Join-Path $SitePath "appsettings.Production.json"
if (Test-Path $configPath) {
    try {
        $json = Get-Content $configPath -Raw | ConvertFrom-Json
        $dbPath = Join-Path $dataPath "passwordmanager.db"
        $json.ConnectionStrings.DefaultConnection = "Data Source=$dbPath"
        $json | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
        Write-Host "✓ Updated connection string to: Data Source=$dbPath" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to update config: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠ Config file not found: $configPath" -ForegroundColor Yellow
}
Write-Host ""

# Step 6: Update web.config (if exists)
Write-Host "STEP 6: Checking web.config..." -ForegroundColor Yellow
$webConfigPath = Join-Path $SitePath "web.config"
if (Test-Path $webConfigPath) {
    Write-Host "✓ Found web.config" -ForegroundColor Green
    # Ensure ASPNETCORE_ENVIRONMENT is set
    [xml]$webConfig = Get-Content $webConfigPath
    $envVar = $webConfig.SelectSingleNode("//environmentVariable[@name='ASPNETCORE_ENVIRONMENT']")
    if ($envVar) {
        $currentEnv = $envVar.value
        Write-Host "  Current environment: $currentEnv" -ForegroundColor Cyan
    } else {
        Write-Host "  No environment variable set in web.config" -ForegroundColor Cyan
    }
} else {
    Write-Host "⚠ web.config not found (might be auto-generated)" -ForegroundColor Yellow
}
Write-Host ""

# Step 7: Restart application pool
Write-Host "STEP 7: Restarting application pool..." -ForegroundColor Yellow
try {
    Restart-WebAppPool -Name $appPool
    Write-Host "✓ Application pool '$appPool' restarted" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not restart app pool: $_" -ForegroundColor Yellow
    Write-Host "  You may need to restart it manually in IIS Manager" -ForegroundColor Yellow
}
Write-Host ""

# Step 8: Test database creation
Write-Host "STEP 8: Waiting for application to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
Write-Host "✓ Wait complete" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "   FIX COMPLETE" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Changes made:" -ForegroundColor Yellow
Write-Host "  1. Created directory: $dataPath" -ForegroundColor White
Write-Host "  2. Granted FullControl to: $identity" -ForegroundColor White
Write-Host "  3. Updated connection string in appsettings.Production.json" -ForegroundColor White
Write-Host "  4. Restarted application pool: $appPool" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Test the application: https://vault.prospergenics.com" -ForegroundColor White
Write-Host "  2. Check if database file is created: $dataPath\passwordmanager.db" -ForegroundColor White
Write-Host "  3. If still errors, check: $SitePath\logs (if exists)" -ForegroundColor White
Write-Host ""
Write-Host "If the error persists:" -ForegroundColor Yellow
Write-Host "  - Check IIS application pool logs" -ForegroundColor White
Write-Host "  - Check Windows Event Viewer" -ForegroundColor White
Write-Host "  - Verify ASPNETCORE_ENVIRONMENT = Production" -ForegroundColor White
Write-Host ""
