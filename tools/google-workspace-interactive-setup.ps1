# Google Workspace MCP - Interactive Setup Wizard
# Guides user through complete setup process

param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipChecks
)

$script:mcpDir = "C:\scripts\tools\google-workspace-mcp"
$script:envFile = "$mcpDir\.env"
$script:setupScript = "C:\scripts\tools\google-workspace-mcp-setup.ps1"

function Write-Step {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host $Message -ForegroundColor $Color
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor DarkGray
}

function Write-Success {
    param([string]$Message)
    Write-Host "[✓] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[i] $Message" -ForegroundColor Cyan
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[✗] $Message" -ForegroundColor Red
}

function Read-UserInput {
    param([string]$Prompt, [switch]$Secure)

    if ($Secure) {
        $secure = Read-Host -Prompt $Prompt -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    } else {
        return Read-Host -Prompt $Prompt
    }
}

function Test-VaultCredentials {
    try {
        $clientId = & "C:\scripts\tools\vault.ps1" -Action get -Service "google-oauth-client-id" 2>$null
        $clientSecret = & "C:\scripts\tools\vault.ps1" -Action get -Service "google-oauth-client-secret" 2>$null

        return ($clientId -and $clientSecret -and $clientId.Trim().Length -gt 0 -and $clientSecret.Trim().Length -gt 0)
    } catch {
        return $false
    }
}

function Test-EnvFile {
    if (-not (Test-Path $script:envFile)) {
        return $false
    }

    $content = Get-Content $script:envFile -Raw
    return ($content -match 'GOOGLE_OAUTH_CLIENT_ID="[^"]{20,}"')
}

function Test-GoogleCloudProject {
    Write-Info "Checking if you have access to Google Cloud Console..."

    $response = Read-UserInput "Have you created a Google Cloud project? (y/n)"
    return ($response -eq 'y' -or $response -eq 'Y')
}

function Test-OAuthConsent {
    $response = Read-UserInput "Have you configured OAuth Consent Screen? (y/n)"
    return ($response -eq 'y' -or $response -eq 'Y')
}

function Test-ClientCredentials {
    $response = Read-UserInput "Have you created OAuth Client ID credentials? (y/n)"
    return ($response -eq 'y' -or $response -eq 'Y')
}

function Test-APIsEnabled {
    $response = Read-UserInput "Have you enabled Gmail, Drive, and Calendar APIs? (y/n)"
    return ($response -eq 'y' -or $response -eq 'Y')
}

function Show-GoogleCloudInstructions {
    Write-Step "STEP 1: Create Google Cloud Project" "Yellow"

    Write-Host "1. Open browser and go to: " -NoNewline
    Write-Host "https://console.cloud.google.com/" -ForegroundColor Cyan

    Write-Host "`n2. Click the project dropdown (top navigation bar)"
    Write-Host "3. Click 'NEW PROJECT' (top right in popup)"
    Write-Host "4. Enter project name: " -NoNewline
    Write-Host "Google Workspace MCP" -ForegroundColor Yellow
    Write-Host "5. Leave Organization empty (or select if you have one)"
    Write-Host "6. Click 'CREATE' and wait for project to be created"

    Write-Host "`nOpening Google Cloud Console in browser..." -ForegroundColor Cyan
    Start-Process "https://console.cloud.google.com/"

    Write-Host "`nPress ENTER when you've created the project..." -ForegroundColor Yellow
    Read-Host
}

function Show-OAuthConsentInstructions {
    Write-Step "STEP 2: Configure OAuth Consent Screen" "Yellow"

    Write-Host "1. In Google Cloud Console, go to:"
    Write-Host "   Menu (≡) → APIs & Services → OAuth consent screen" -ForegroundColor Cyan

    Write-Host "`n2. Choose: " -NoNewline
    Write-Host "External" -ForegroundColor Yellow -NoNewline
    Write-Host " (unless you have Google Workspace, then Internal)"

    Write-Host "`n3. Click 'CREATE'"

    Write-Host "`n4. Fill in:"
    Write-Host "   - App name: " -NoNewline
    Write-Host "Google Workspace MCP" -ForegroundColor Yellow
    Write-Host "   - User support email: " -NoNewline
    Write-Host "Your email" -ForegroundColor Yellow
    Write-Host "   - Developer contact: " -NoNewline
    Write-Host "Your email" -ForegroundColor Yellow

    Write-Host "`n5. Click 'SAVE AND CONTINUE'"
    Write-Host "6. Scopes page: Click 'SAVE AND CONTINUE' (skip for now)"
    Write-Host "7. Test users: Click '+ ADD USERS', add your email, click 'ADD'"
    Write-Host "8. Click 'SAVE AND CONTINUE'"
    Write-Host "9. Summary page: Click 'BACK TO DASHBOARD'"

    Write-Host "`nOpening OAuth Consent Screen page..." -ForegroundColor Cyan
    Start-Process "https://console.cloud.google.com/apis/credentials/consent"

    Write-Host "`nPress ENTER when you've configured OAuth Consent Screen..." -ForegroundColor Yellow
    Read-Host
}

function Show-ClientIDInstructions {
    Write-Step "STEP 3: Create OAuth Client ID" "Yellow"

    Write-Host "1. Go to: Menu → APIs & Services → Credentials" -ForegroundColor Cyan

    Write-Host "`n2. Click '+ CREATE CREDENTIALS' (top) → 'OAuth client ID'"

    Write-Host "`n3. Application type: " -NoNewline
    Write-Host "Desktop app" -ForegroundColor Yellow -NoNewline
    Write-Host " (IMPORTANT - not 'Web application'!)"

    Write-Host "`n4. Name: " -NoNewline
    Write-Host "Google Workspace MCP Desktop" -ForegroundColor Yellow

    Write-Host "`n5. Click 'CREATE'"

    Write-Host "`n6. POPUP APPEARS - COPY THESE CREDENTIALS:" -ForegroundColor Yellow
    Write-Host "   - Client ID (long string ending in .apps.googleusercontent.com)"
    Write-Host "   - Client secret (shorter string)"

    Write-Host "`nOpening Credentials page..." -ForegroundColor Cyan
    Start-Process "https://console.cloud.google.com/apis/credentials"

    Write-Host "`nPress ENTER when you have your Client ID and Client Secret copied..." -ForegroundColor Yellow
    Read-Host
}

function Get-Credentials {
    Write-Step "STEP 4: Enter Your Credentials" "Yellow"

    Write-Host "Paste your credentials here (they will be stored securely in vault):`n"

    $clientId = Read-UserInput "Client ID (ends with .apps.googleusercontent.com)"
    $clientSecret = Read-UserInput "Client Secret" -Secure

    # Validate format
    if (-not $clientId.EndsWith(".apps.googleusercontent.com")) {
        Write-Warning "Client ID doesn't look right (should end with .apps.googleusercontent.com)"
        $continue = Read-UserInput "Continue anyway? (y/n)"
        if ($continue -ne 'y' -and $continue -ne 'Y') {
            return $null
        }
    }

    if ($clientSecret.Length -lt 10) {
        Write-Warning "Client Secret seems too short"
        $continue = Read-UserInput "Continue anyway? (y/n)"
        if ($continue -ne 'y' -and $continue -ne 'Y') {
            return $null
        }
    }

    return @{
        ClientId = $clientId
        ClientSecret = $clientSecret
    }
}

function Save-Credentials {
    param($Credentials)

    Write-Step "Saving Credentials to Vault" "Cyan"

    try {
        # Save to vault
        & "C:\scripts\tools\vault.ps1" -Action set -Service "google-oauth-client-id" -Token $Credentials.ClientId | Out-Null
        & "C:\scripts\tools\vault.ps1" -Action set -Service "google-oauth-client-secret" -Token $Credentials.ClientSecret | Out-Null

        Write-Success "Credentials saved to vault"

        # Configure MCP server
        Write-Info "Configuring MCP server..."
        & $script:setupScript -Action configure | Out-Null

        Write-Success "MCP server configured"
        return $true

    } catch {
        Write-Error "Failed to save credentials: $_"
        return $false
    }
}

function Show-APIInstructions {
    Write-Step "STEP 5: Enable Google APIs" "Yellow"

    Write-Host "You need to enable these APIs in Google Cloud Console:`n"

    Write-Host "ESSENTIAL (must enable):" -ForegroundColor Yellow
    Write-Host "  • Gmail API"
    Write-Host "  • Google Calendar API"
    Write-Host "  • Google Drive API"

    Write-Host "`nRECOMMENDED (enable if you'll use these):" -ForegroundColor Cyan
    Write-Host "  • Google Docs API"
    Write-Host "  • Google Sheets API"
    Write-Host "  • Google Slides API"
    Write-Host "  • Google Forms API"
    Write-Host "  • Google Tasks API"
    Write-Host "  • Google People API (Contacts)"

    Write-Host "`nHow to enable:"
    Write-Host "1. Go to: Menu (≡) → APIs & Services → Library" -ForegroundColor Cyan
    Write-Host "2. Search for 'Gmail API', click it, click 'ENABLE'"
    Write-Host "3. Click back arrow, repeat for other APIs"

    Write-Host "`nOpening API Library..." -ForegroundColor Cyan
    Start-Process "https://console.cloud.google.com/apis/library"

    Write-Host "`nPress ENTER when you've enabled the APIs..." -ForegroundColor Yellow
    Read-Host
}

function Test-Installation {
    Write-Step "STEP 6: Test Installation" "Yellow"

    Write-Info "Testing MCP server..."

    try {
        & $script:setupScript -Action test
        Write-Success "MCP server is working!"

        Write-Host "`nReady to test with a real command?"
        $test = Read-UserInput "Run 'search Gmail for unread messages'? (y/n)"

        if ($test -eq 'y' -or $test -eq 'Y') {
            Write-Info "This will open your browser for OAuth authorization..."
            Write-Info "Running command..."

            & $script:setupScript -Action cli -Command "search_gmail_messages" -Args '{"query":"is:unread","maxResults":5}'

            Write-Success "If you saw results (or OAuth browser opened), setup is complete!"
        }

        return $true

    } catch {
        Write-Error "Test failed: $_"
        return $false
    }
}

function Show-CompletionMessage {
    Write-Step "Setup Complete! 🎉" "Green"

    Write-Host "Your Google Workspace MCP server is ready to use!`n"

    Write-Host "Quick Start Commands:" -ForegroundColor Yellow

    Write-Host "`n1. Search Gmail:"
    Write-Host "   .\google-workspace-mcp-setup.ps1 -Action cli -Command 'search_gmail_messages' -Args '{""query"":""is:unread""}'" -ForegroundColor Cyan

    Write-Host "`n2. Upload to Drive:"
    Write-Host "   .\google-workspace-mcp-setup.ps1 -Action cli -Command 'upload_to_drive' -Args '{""filePath"":""E:\\output\\file.png"",""folderId"":""xxx""}'" -ForegroundColor Cyan

    Write-Host "`n3. Send email:"
    Write-Host "   .\google-workspace-mcp-setup.ps1 -Action cli -Command 'send_gmail' -Args '{""to"":""user@example.com"",""subject"":""Hello"",""body"":""Test""}'" -ForegroundColor Cyan

    Write-Host "`n4. Create calendar event:"
    Write-Host "   .\google-workspace-mcp-setup.ps1 -Action cli -Command 'create_calendar_event' -Args '{""summary"":""Meeting"",""start"":""2026-02-20T10:00:00"",""end"":""2026-02-20T11:00:00""}'" -ForegroundColor Cyan

    Write-Host "`n5. Load automation functions:"
    Write-Host "   . C:\scripts\tools\google-workspace-automation-examples.ps1" -ForegroundColor Cyan

    Write-Host "`nDocumentation:" -ForegroundColor Yellow
    Write-Host "  • Full guide: E:\jengo\documents\temp\google-workspace-mcp-setup-guide.md"
    Write-Host "  • Quick ref:  E:\jengo\documents\temp\google-workspace-mcp-quick-reference.md"
    Write-Host "  • Examples:   C:\scripts\tools\google-workspace-automation-examples.ps1"
}

# ============================================================================
# MAIN WIZARD FLOW
# ============================================================================

Clear-Host

Write-Host @"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║      Google Workspace MCP - Interactive Setup Wizard     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`nThis wizard will guide you through setting up Google Workspace MCP.`n"

# Check current state
if (-not $SkipChecks) {
    Write-Info "Checking current setup state..."

    $hasVaultCreds = Test-VaultCredentials
    $hasEnvFile = Test-EnvFile

    if ($hasVaultCreds -and $hasEnvFile) {
        Write-Success "Credentials already configured!"
        Write-Info "You can skip straight to testing."

        $skip = Read-UserInput "Skip to testing? (y/n)"
        if ($skip -eq 'y' -or $skip -eq 'Y') {
            Test-Installation
            Show-CompletionMessage
            exit
        }
    } elseif ($hasVaultCreds) {
        Write-Success "Found credentials in vault, but .env not configured"
        Write-Info "Configuring MCP server..."
        & $script:setupScript -Action configure
    } elseif ($hasEnvFile) {
        Write-Success ".env file exists, but credentials not in vault"
        Write-Info "You may need to reconfigure credentials"
    }
}

# Step-by-step setup
$hasProject = Test-GoogleCloudProject
if (-not $hasProject) {
    Show-GoogleCloudInstructions
}

$hasConsent = Test-OAuthConsent
if (-not $hasConsent) {
    Show-OAuthConsentInstructions
}

$hasClientID = Test-ClientCredentials
if (-not $hasClientID) {
    Show-ClientIDInstructions
}

# Get and save credentials
$credentials = Get-Credentials
if (-not $credentials) {
    Write-Error "Failed to get credentials. Exiting."
    exit 1
}

$saved = Save-Credentials -Credentials $credentials
if (-not $saved) {
    Write-Error "Failed to save credentials. Exiting."
    exit 1
}

$hasAPIs = Test-APIsEnabled
if (-not $hasAPIs) {
    Show-APIInstructions
}

# Test installation
Test-Installation

# Show completion
Show-CompletionMessage

Write-Host "`nPress ENTER to exit..."
Read-Host
