# Google Workspace MCP Setup Script
# Configures OAuth credentials and initializes the MCP server

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('configure', 'test', 'run', 'cli', 'help')]
    [string]$Action = 'help',

    [Parameter(Mandatory=$false)]
    [string]$ClientId,

    [Parameter(Mandatory=$false)]
    [string]$ClientSecret,

    [Parameter(Mandatory=$false)]
    [string]$Command,

    [Parameter(Mandatory=$false)]
    [string]$Args
)

$mcpDir = "C:\scripts\tools\google-workspace-mcp"
$envFile = "$mcpDir\.env"
$venvPython = "$mcpDir\.venv\Scripts\python.exe"

function Show-Help {
    Write-Host @"
Google Workspace MCP Setup & Usage
===================================

SETUP:
  .\google-workspace-mcp-setup.ps1 -Action configure -ClientId "xxx" -ClientSecret "yyy"

  First-time setup: Creates .env file with your Google OAuth credentials

  Get credentials from: https://console.cloud.google.com/
  1. Create OAuth 2.0 credentials (Desktop Application)
  2. Enable APIs: Gmail, Calendar, Drive, Docs, Sheets, Slides, Forms, Tasks, Chat
  3. Copy Client ID and Client Secret

USAGE:
  # Test the server
  .\google-workspace-mcp-setup.ps1 -Action test

  # Run the MCP server (for Claude Desktop integration)
  .\google-workspace-mcp-setup.ps1 -Action run

  # CLI mode (for scripts/automation)
  .\google-workspace-mcp-setup.ps1 -Action cli -Command "search_gmail_messages" -Args '{"query":"is:unread"}'

EXAMPLES:
  # List available tools
  .\google-workspace-mcp-setup.ps1 -Action cli -Command "list"

  # Search Gmail
  .\google-workspace-mcp-setup.ps1 -Action cli -Command "search_gmail_messages" -Args '{"query":"from:client@example.com"}'

  # Upload to Drive
  .\google-workspace-mcp-setup.ps1 -Action cli -Command "upload_to_drive" -Args '{"filePath":"E:\\output\\logo.png","folderId":"xxx"}'

CREDENTIALS STORAGE:
  You can also store credentials in vault:

  vault.ps1 -Action set -Service "google-oauth-client-id" -Token "your-client-id"
  vault.ps1 -Action set -Service "google-oauth-client-secret" -Token "your-client-secret"

  Then configure:
  .\google-workspace-mcp-setup.ps1 -Action configure

  (Script will auto-retrieve from vault if no -ClientId/-ClientSecret provided)

"@
}

function Set-Credentials {
    param([string]$ClientId, [string]$ClientSecret)

    # If no credentials provided, try vault
    if (-not $ClientId -or -not $ClientSecret) {
        Write-Host "No credentials provided, checking vault..." -ForegroundColor Yellow

        try {
            $vaultClientId = & "C:\scripts\tools\vault.ps1" -Action get -Service "google-oauth-client-id" 2>$null
            $vaultClientSecret = & "C:\scripts\tools\vault.ps1" -Action get -Service "google-oauth-client-secret" 2>$null

            if ($vaultClientId -and $vaultClientSecret) {
                $ClientId = $vaultClientId.Trim()
                $ClientSecret = $vaultClientSecret.Trim()
                Write-Host "[OK] Retrieved credentials from vault" -ForegroundColor Green
            } else {
                Write-Host "[FAIL] No credentials in vault. Please provide -ClientId and -ClientSecret" -ForegroundColor Red
                Write-Host ""
                Write-Host "Get credentials from: https://console.cloud.google.com/" -ForegroundColor Cyan
                return $false
            }
        } catch {
            Write-Host "[FAIL] Could not access vault: $_" -ForegroundColor Red
            return $false
        }
    }

    # Read template
    if (-not (Test-Path $envFile)) {
        Copy-Item "$mcpDir\.env.oauth21" $envFile
    }

    $content = Get-Content $envFile -Raw

    # Update credentials
    $content = $content -replace 'GOOGLE_OAUTH_CLIENT_ID=".*"', "GOOGLE_OAUTH_CLIENT_ID=`"$ClientId`""
    $content = $content -replace 'GOOGLE_OAUTH_CLIENT_SECRET=".*"', "GOOGLE_OAUTH_CLIENT_SECRET=`"$ClientSecret`""

    # Set insecure transport for localhost development
    $content = $content -replace 'OAUTH2_ALLOW_INSECURE_TRANSPORT=false', 'OAUTH2_ALLOW_INSECURE_TRANSPORT=true'

    # Write back
    Set-Content $envFile $content -NoNewline

    Write-Host "[OK] Credentials configured in $envFile" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Test the server: .\google-workspace-mcp-setup.ps1 -Action test"
    Write-Host "2. Run CLI command: .\google-workspace-mcp-setup.ps1 -Action cli -Command list"

    return $true
}

function Test-Server {
    Write-Host "Testing Google Workspace MCP server..." -ForegroundColor Cyan

    if (-not (Test-Path $envFile)) {
        Write-Host "[FAIL] .env file not found. Run -Action configure first" -ForegroundColor Red
        return
    }

    Push-Location $mcpDir
    try {
        Write-Host "Running health check..." -ForegroundColor Yellow
        & $venvPython main.py --help
        Write-Host ""
        Write-Host "[OK] Server is functional" -ForegroundColor Green
    } finally {
        Pop-Location
    }
}

function Start-Server {
    Write-Host "Starting Google Workspace MCP server..." -ForegroundColor Cyan
    Write-Host "Server will run on streamable-http transport" -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""

    Push-Location $mcpDir
    try {
        & $venvPython main.py --transport streamable-http
    } finally {
        Pop-Location
    }
}

function Invoke-CliCommand {
    param([string]$Command, [string]$Args)

    if (-not $Command) {
        Write-Host "[FAIL] No command specified. Use -Command parameter" -ForegroundColor Red
        Write-Host "Example: -Command list" -ForegroundColor Yellow
        return
    }

    Push-Location $mcpDir
    try {
        if ($Args) {
            & $venvPython -m workspace-mcp --cli $Command --args $Args
        } else {
            & $venvPython -m workspace-mcp --cli $Command
        }
    } finally {
        Pop-Location
    }
}

# Main execution
switch ($Action) {
    'configure' {
        Set-Credentials -ClientId $ClientId -ClientSecret $ClientSecret
    }
    'test' {
        Test-Server
    }
    'run' {
        Start-Server
    }
    'cli' {
        Invoke-CliCommand -Command $Command -Args $Args
    }
    'help' {
        Show-Help
    }
}
