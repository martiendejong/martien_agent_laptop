# Quick check for Google OAuth credentials

Write-Host "Checking Google OAuth credentials status..." -ForegroundColor Cyan
Write-Host ""

# Check vault
try {
    $vaultClientId = & "C:\scripts\tools\vault.ps1" -Action get -Service "google-oauth-client-id" 2>$null
    $vaultClientSecret = & "C:\scripts\tools\vault.ps1" -Action get -Service "google-oauth-client-secret" 2>$null

    if ($vaultClientId -and $vaultClientId.Trim().Length -gt 20) {
        Write-Host "[OK] Client ID found in vault" -ForegroundColor Green
        Write-Host "     Preview: $($vaultClientId.Substring(0, 30))..." -ForegroundColor Gray
    } else {
        Write-Host "[X] Client ID NOT in vault" -ForegroundColor Red
    }

    if ($vaultClientSecret -and $vaultClientSecret.Trim().Length -gt 10) {
        Write-Host "[OK] Client Secret found in vault" -ForegroundColor Green
        Write-Host "     Preview: $($vaultClientSecret.Substring(0, 10))..." -ForegroundColor Gray
    } else {
        Write-Host "[X] Client Secret NOT in vault" -ForegroundColor Red
    }
} catch {
    Write-Host "[X] Could not access vault: $_" -ForegroundColor Red
}

Write-Host ""

# Check .env file
$envFile = "C:\scripts\tools\google-workspace-mcp\.env"
if (Test-Path $envFile) {
    $content = Get-Content $envFile -Raw

    if ($content -match 'GOOGLE_OAUTH_CLIENT_ID="([^"]+)"') {
        $clientId = $matches[1]
        if ($clientId -ne "your-google-client-id" -and $clientId.Length -gt 20) {
            Write-Host "[OK] Client ID configured in .env" -ForegroundColor Green
            Write-Host "     Preview: $($clientId.Substring(0, 30))..." -ForegroundColor Gray
        } else {
            Write-Host "[X] Client ID in .env is placeholder" -ForegroundColor Red
        }
    }

    if ($content -match 'GOOGLE_OAUTH_CLIENT_SECRET="([^"]+)"') {
        $clientSecret = $matches[1]
        if ($clientSecret -ne "your-google-client-secret" -and $clientSecret.Length -gt 10) {
            Write-Host "[OK] Client Secret configured in .env" -ForegroundColor Green
            Write-Host "     Preview: $($clientSecret.Substring(0, 10))..." -ForegroundColor Gray
        } else {
            Write-Host "[X] Client Secret in .env is placeholder" -ForegroundColor Red
        }
    }
} else {
    Write-Host "[X] .env file not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "If you don't have credentials yet:" -ForegroundColor Cyan
Write-Host "1. Go to: https://console.cloud.google.com/"
Write-Host "2. Follow the setup guide at:"
Write-Host "   E:\jengo\documents\temp\google-workspace-mcp-setup-guide.md"
Write-Host ""
Write-Host "If you have credentials:" -ForegroundColor Cyan
Write-Host "1. Save to vault:"
Write-Host "   vault.ps1 -Action set -Service 'google-oauth-client-id' -Token 'YOUR_CLIENT_ID'"
Write-Host "   vault.ps1 -Action set -Service 'google-oauth-client-secret' -Token 'YOUR_SECRET'"
Write-Host ""
Write-Host "2. Configure MCP:"
Write-Host "   cd C:\scripts\tools"
Write-Host "   .\google-workspace-mcp-setup.ps1 -Action configure"
