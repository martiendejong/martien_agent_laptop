<#
.SYNOPSIS
    Create MSI installer for Hazina Orchestration using Windows Installer COM API

.DESCRIPTION
    Creates a basic MSI package without requiring WiX toolset.
    Uses Windows Installer COM API directly.
#>

param(
    [string]$SourcePath = "C:\stores\orchestration",
    [string]$OutputPath = "C:\Users\Public\Documents",
    [string]$ProductName = "Hazina Orchestration",
    [string]$Version = "1.0.0",
    [string]$Manufacturer = "Hazina Framework"
)

$ErrorActionPreference = 'Stop'

Write-Host "Creating MSI installer using Windows Installer API..." -ForegroundColor Cyan

# Create MSI file path
$msiPath = Join-Path $OutputPath "HazinaOrchestration-v$Version.msi"

if (Test-Path $msiPath) {
    Remove-Item $msiPath -Force
}

try {
    # Create Windows Installer object
    $installer = New-Object -ComObject WindowsInstaller.Installer
    $database = $installer.OpenDatabase($msiPath, 1) # 1 = create new MSI

    Write-Host "MSI database created: $msiPath" -ForegroundColor Green

    # Define installation properties
    $properties = @{
        'ProductName' = $ProductName
        'ProductVersion' = $Version
        'Manufacturer' = $Manufacturer
        'ProductCode' = [System.Guid]::NewGuid().ToString('B').ToUpper()
        'UpgradeCode' = '{12345678-1234-1234-1234-123456789ABC}'
        'ARPHELPLINK' = 'https://github.com/hazina-framework'
        'ARPURLINFOABOUT' = 'https://github.com/hazina-framework'
    }

    # Create Property table SQL
    $sql = "CREATE TABLE Property (Property CHAR(72) NOT NULL, Value CHAR(0) NOT NULL LOCALIZABLE PRIMARY KEY Property)"
    $view = $database.OpenView($sql)
    $view.Execute()
    $view.Close()

    # Insert properties
    foreach ($prop in $properties.GetEnumerator()) {
        $sql = "INSERT INTO Property (Property, Value) VALUES ('$($prop.Key)', '$($prop.Value)')"
        $view = $database.OpenView($sql)
        $view.Execute()
        $view.Close()
    }

    Write-Host "Properties added to MSI" -ForegroundColor Green

    # Commit database
    $database.Commit()

    Write-Host ""
    Write-Host "Basic MSI created: $msiPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "NOTE: This is a minimal MSI shell." -ForegroundColor Yellow
    Write-Host "For a complete installer, use WiX toolset or the PowerShell installer scripts." -ForegroundColor Yellow
    Write-Host ""
}
catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "MSI creation via COM API has limitations." -ForegroundColor Yellow
    Write-Host "Recommended approach: Use install.ps1 script instead" -ForegroundColor Yellow
}
finally {
    if ($database) {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($database) | Out-Null
    }
    if ($installer) {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($installer) | Out-Null
    }
    [System.GC]::Collect()
}

Write-Host ""
Write-Host "RECOMMENDED APPROACH:" -ForegroundColor Cyan
Write-Host "1. Use the PowerShell installer: install.ps1" -ForegroundColor White
Write-Host "2. Package with install.ps1 in a ZIP file" -ForegroundColor White
Write-Host "3. Users extract and run install.ps1" -ForegroundColor White
Write-Host ""
