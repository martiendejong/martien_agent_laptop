$vpsIp = "85.215.217.154"
$cred = New-Object PSCredential("administrator", (ConvertTo-SecureString "SpaceElevator1tam!" -AsPlainText -Force))
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck
$session = New-PSSession -ComputerName $vpsIp -Credential $cred -SessionOption $so -Authentication Negotiate

Invoke-Command -Session $session -ScriptBlock {
    # ── 1. Pull latest develop ──────────────────────────────────────────
    Write-Host "`n=== [1/5] Git pull ===" -ForegroundColor Cyan
    Set-Location "C:\stores\realestate\src"
    $gitOut = cmd /c "git pull origin develop 2>&1"
    Write-Host $gitOut

    # ── 2. Build frontend ───────────────────────────────────────────────
    Write-Host "`n=== [2/5] Frontend build ===" -ForegroundColor Cyan
    Set-Location "C:\stores\realestate\src\frontend-react"

    Write-Host "npm install..."
    $npmInstall = cmd /c "npm install 2>&1"
    Write-Host ($npmInstall | Select-Object -Last 3)

    Write-Host "npm run build..."
    $npmBuild = cmd /c "npm run build 2>&1"
    $buildLines = $npmBuild -split "`n"
    Write-Host ($buildLines | Select-Object -Last 10)

    $buildFailed = $buildLines | Where-Object { $_ -match "error|Error|failed|Failed" -and $_ -notmatch "warnings" }
    if ($buildFailed) {
        Write-Host "BUILD ERRORS:" -ForegroundColor Red
        $buildFailed | ForEach-Object { Write-Host $_ }
    }

    # Check dist was created
    if (-not (Test-Path "dist\index.html")) {
        Write-Host "ERROR: dist/index.html not found - build failed" -ForegroundColor Red
        return
    }
    Write-Host "Build successful - dist/index.html exists" -ForegroundColor Green

    # Deploy frontend to www
    Write-Host "Deploying frontend..."
    if (Test-Path "C:\stores\realestate\www") {
        Remove-Item "C:\stores\realestate\www\*" -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        New-Item -ItemType Directory -Path "C:\stores\realestate\www" | Out-Null
    }
    Copy-Item "dist\*" "C:\stores\realestate\www\" -Recurse -Force
    $fileCount = (Get-ChildItem "C:\stores\realestate\www" -Recurse -File).Count
    Write-Host "Frontend deployed: $fileCount files" -ForegroundColor Green

    # ── 3. Build backend ────────────────────────────────────────────────
    Write-Host "`n=== [3/5] Backend build ===" -ForegroundColor Cyan
    Set-Location "C:\stores\realestate\src"
    $publishOut = cmd /c "dotnet publish src\RealEstateAgencyAPI\RealEstateAgencyAPI.csproj --configuration Release --output C:\stores\realestate\backend-new --no-self-contained 2>&1"
    Write-Host ($publishOut | Select-Object -Last 5)

    if (-not (Test-Path "C:\stores\realestate\backend-new\RealEstateAgencyAPI.dll")) {
        Write-Host "ERROR: backend DLL not found - publish failed" -ForegroundColor Red
        Write-Host $publishOut
        return
    }
    Write-Host "Backend build successful" -ForegroundColor Green

    # ── 4. Swap backend ─────────────────────────────────────────────────
    Write-Host "`n=== [4/5] Swapping backend ===" -ForegroundColor Cyan
    Import-Module WebAdministration

    Write-Host "Stopping RealEstatePool..."
    Stop-WebAppPool -Name "RealEstatePool" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3

    # Preserve web.config
    $webConfig = Get-Content "C:\stores\realestate\backend\web.config" -ErrorAction SilentlyContinue

    # Swap
    if (Test-Path "C:\stores\realestate\backend-old") {
        Remove-Item "C:\stores\realestate\backend-old" -Recurse -Force
    }
    Rename-Item "C:\stores\realestate\backend" "backend-old"
    Rename-Item "C:\stores\realestate\backend-new" "backend"

    # Restore web.config
    if ($webConfig) {
        $webConfig | Set-Content "C:\stores\realestate\backend\web.config"
        Write-Host "web.config preserved"
    }

    # ── 5. Start app pool ───────────────────────────────────────────────
    Write-Host "`n=== [5/5] Starting RealEstatePool ===" -ForegroundColor Cyan
    Start-WebAppPool -Name "RealEstatePool"
    Start-Sleep -Seconds 6

    $pool = Get-WebConfiguration "system.applicationHost/applicationPools/add[@name='RealEstatePool']"
    Write-Host "Pool state: $($pool.state)"

    # Quick health check
    try {
        $resp = Invoke-WebRequest "http://localhost/api/settings/agency" -TimeoutSec 10 -UseBasicParsing -ErrorAction SilentlyContinue
        Write-Host "Health check: HTTP $($resp.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "Health check: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    Write-Host "`n=== Deploy complete ===" -ForegroundColor Green
}

Remove-PSSession $session
