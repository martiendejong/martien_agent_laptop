# Build MSI to alternate location to avoid lock
$scriptDir = "C:\Projects\hazina\apps\Demos\Hazina.Demo.AgenticOrchestration.Installer"
$wixDir = Join-Path $scriptDir "wix-tools"
$candleExe = Join-Path $wixDir "candle.exe"
$lightExe = Join-Path $wixDir "light.exe"

# Output to temp location instead of locked bin\Release
$msiOutputDir = "C:\temp"
$objDir = Join-Path $scriptDir "obj\Release"

New-Item -ItemType Directory -Path $msiOutputDir -Force | Out-Null
New-Item -ItemType Directory -Path $objDir -Force | Out-Null

Push-Location $scriptDir

Write-Host "Compiling (candle.exe)..." -ForegroundColor Cyan
& $candleExe "Product-Generated.wxs" -ext WixUIExtension -ext WixUtilExtension -out "obj\Release\" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAILED] candle.exe failed" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "Linking (light.exe)..." -ForegroundColor Cyan
& $lightExe "obj\Release\Product-Generated.wixobj" -ext WixUIExtension -ext WixUtilExtension -out "$msiOutputDir\HazinaOrchestrationSetup.msi" -sval 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAILED] light.exe failed" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

$msi = Get-Item "$msiOutputDir\HazinaOrchestrationSetup.msi"
$sizeMB = [math]::Round($msi.Length / 1MB, 2)
Write-Host "[OK] MSI built: $sizeMB MB at $($msi.FullName)" -ForegroundColor Green
