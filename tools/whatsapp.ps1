<#
.SYNOPSIS
    WhatsApp messaging bridge for autonomous communication

.DESCRIPTION
    Allows Jengo to send WhatsApp messages via WhatsApp Web automation

.PARAMETER Action
    init - Display QR code for linking WhatsApp
    send - Send a message
    status - Check connection status

.PARAMETER PhoneNumber
    Recipient phone number (with or without country code)
    Examples: +254712345678, 0712345678, +31612345678

.PARAMETER Message
    Message text to send

.EXAMPLE
    whatsapp init
    whatsapp send +254712345678 "Hi Diko, did you receive the CodeHub PDF?"
    whatsapp status

.NOTES
    Session persists at C:\scripts\_machine\whatsapp-session\
    Requires: Node.js, whatsapp-web.js, qrcode-terminal
#>

param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('init', 'send', 'status', 'install')]
    [string]$Action,

    [Parameter(Position=1)]
    [string]$PhoneNumber,

    [Parameter(Position=2, ValueFromRemainingArguments=$true)]
    [string[]]$MessageParts
)

$scriptPath = Join-Path $PSScriptRoot "whatsapp-bridge.js"
$Message = if ($MessageParts) { $MessageParts -join ' ' } else { '' }

# Check if Node.js is installed
$nodeVersion = & node --version 2>$null
if (-not $nodeVersion) {
    Write-Host "ERROR: Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Install Node.js from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

switch ($Action) {
    'install' {
        Write-Host "Installing WhatsApp dependencies..." -ForegroundColor Yellow
        Write-Host ""

        $toolsDir = Split-Path $scriptPath
        Push-Location $toolsDir

        try {
            # Check if package.json exists
            if (-not (Test-Path "package.json")) {
                Write-Host "Creating package.json..." -ForegroundColor Gray
                @{
                    name = "whatsapp-bridge"
                    version = "1.0.0"
                    description = "WhatsApp automation for Jengo"
                    dependencies = @{
                        "whatsapp-web.js" = "^1.23.0"
                        "qrcode-terminal" = "^0.12.0"
                    }
                } | ConvertTo-Json -Depth 3 | Out-File "package.json" -Encoding UTF8
            }

            Write-Host "Installing npm packages..." -ForegroundColor Gray
            & npm install

            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "SUCCESS! WhatsApp dependencies installed" -ForegroundColor Green
                Write-Host ""
                Write-Host "Next step: whatsapp init" -ForegroundColor Cyan
            } else {
                throw "npm install failed"
            }
        }
        catch {
            Write-Host ""
            Write-Host "ERROR: Installation failed" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            exit 1
        }
        finally {
            Pop-Location
        }
    }

    'init' {
        Write-Host "Initializing WhatsApp connection..." -ForegroundColor Cyan
        Write-Host "This will display a QR code for linking your phone" -ForegroundColor Gray
        Write-Host ""

        & node $scriptPath init
    }

    'send' {
        if (-not $PhoneNumber -or -not $Message) {
            Write-Host "Usage: whatsapp send <phone-number> <message>" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Examples:" -ForegroundColor Gray
            Write-Host "  whatsapp send +254712345678 'Hi Diko!'" -ForegroundColor Gray
            Write-Host "  whatsapp send 0712345678 'Message text here'" -ForegroundColor Gray
            exit 1
        }

        Write-Host "Sending WhatsApp message..." -ForegroundColor Yellow
        Write-Host "  To: $PhoneNumber" -ForegroundColor Gray
        Write-Host "  Message: $Message" -ForegroundColor Gray
        Write-Host ""

        & node $scriptPath send $PhoneNumber $Message

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Message sent successfully!" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "Message sending failed" -ForegroundColor Red
            exit 1
        }
    }

    'status' {
        Write-Host "Checking WhatsApp connection status..." -ForegroundColor Yellow
        Write-Host ""

        & node $scriptPath status
    }
}
