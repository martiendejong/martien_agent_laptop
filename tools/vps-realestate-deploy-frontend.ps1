$vpsIp = "85.215.217.154"
$cred = New-Object PSCredential("administrator", (ConvertTo-SecureString "SpaceElevator1tam!" -AsPlainText -Force))
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck
$session = New-PSSession -ComputerName $vpsIp -Credential $cred -SessionOption $so -Authentication Negotiate

Invoke-Command -Session $session -ScriptBlock {
    $wwwroot = "C:\stores\realestate\backend\wwwroot"
    $www     = "C:\stores\realestate\www"

    Write-Host "=== Deploying frontend to wwwroot ===" -ForegroundColor Cyan

    # Replace index.html
    Copy-Item "$www\index.html" "$wwwroot\index.html" -Force
    Write-Host "index.html deployed"

    # Replace assets folder (only frontend build assets)
    if (Test-Path "$wwwroot\assets") {
        Remove-Item "$wwwroot\assets" -Recurse -Force
    }
    Copy-Item "$www\assets" "$wwwroot\assets" -Recurse -Force
    $assetCount = (Get-ChildItem "$wwwroot\assets" -Recurse -File).Count
    Write-Host "assets deployed: $assetCount files"

    # documents/ and uploads/ are untouched (user-uploaded files)
    Write-Host "documents/ and uploads/ preserved"

    Write-Host ""
    Write-Host "=== Restarting RealEstatePool ===" -ForegroundColor Cyan
    Import-Module WebAdministration
    Restart-WebAppPool -Name "RealEstatePool"
    Start-Sleep -Seconds 6

    $pool = Get-WebConfiguration "system.applicationHost/applicationPools/add[@name='RealEstatePool']"
    Write-Host "Pool state: $($pool.state)"

    # Verify
    Write-Host ""
    Write-Host "=== wwwroot contents ===" -ForegroundColor Cyan
    Get-ChildItem "$wwwroot" | Select-Object Name, LastWriteTime | Format-Table

    Write-Host "=== Health check ===" -ForegroundColor Cyan
    Start-Sleep -Seconds 3
    try {
        $resp = Invoke-WebRequest "http://localhost/api/settings/agency" -TimeoutSec 10 -UseBasicParsing
        Write-Host "API health: HTTP $($resp.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "API health: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    Write-Host "`n=== Done ===" -ForegroundColor Green
}

Remove-PSSession $session
