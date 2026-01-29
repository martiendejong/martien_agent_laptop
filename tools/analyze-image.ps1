<#
.SYNOPSIS
    Analyze an image and return AI-generated insights

.DESCRIPTION
    Simple, focused tool for image analysis using OpenAI GPT-4 Vision.
    Designed for document verification, OCR, and visual analysis tasks.

    Returns plain text response - no formatting overhead.

.PARAMETER ImagePath
    Path to the image file to analyze (supports: jpg, jpeg, png, gif, webp)

.PARAMETER Instruction
    What to analyze or extract from the image

.PARAMETER DetailLevel
    Image detail level: low, high, auto (default: high for documents)

.PARAMETER MaxTokens
    Maximum response length (default: 2000)

.EXAMPLE
    .\analyze-image.ps1 -ImagePath "document.png" -Instruction "Transcribe all text in this document"

.EXAMPLE
    .\analyze-image.ps1 -ImagePath "passport.jpg" -Instruction "Extract: name, date of birth, father's name"

.EXAMPLE
    .\analyze-image.ps1 "photo.png" "Describe what you see"

.NOTES
    Created: 2026-01-29
    For: Claude Agent image analysis tasks
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ImagePath,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$Instruction,

    [Parameter(Mandatory=$false)]
    [ValidateSet("low", "high", "auto")]
    [string]$DetailLevel = "high",

    [Parameter(Mandatory=$false)]
    [int]$MaxTokens = 2000
)

# === CONFIGURATION ===
$ErrorActionPreference = "Stop"

# Load API key from appsettings
function Get-OpenAIApiKey {
    $settingsPath = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"

    if (Test-Path $settingsPath) {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

        # Try different key locations (brand2boost format)
        if ($settings.ApiSettings -and $settings.ApiSettings.OpenApiKey) {
            return $settings.ApiSettings.OpenApiKey
        }
        if ($settings.OpenApiKey) {
            return $settings.OpenApiKey
        }
        if ($settings.OpenAI -and $settings.OpenAI.ApiKey) {
            return $settings.OpenAI.ApiKey
        }
        if ($settings.OpenAIApiKey) {
            return $settings.OpenAIApiKey
        }
    }

    # Fallback to environment variable
    if ($env:OPENAI_API_KEY) {
        return $env:OPENAI_API_KEY
    }

    throw "OpenAI API key not found. Set in appsettings.Secrets.json or OPENAI_API_KEY environment variable."
}

# Convert image to base64
function ConvertTo-Base64Image {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Image not found: $Path"
    }

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $base64 = [Convert]::ToBase64String($bytes)

    # Determine MIME type
    $extension = [System.IO.Path]::GetExtension($Path).ToLower()
    $mimeType = switch ($extension) {
        ".jpg"  { "image/jpeg" }
        ".jpeg" { "image/jpeg" }
        ".png"  { "image/png" }
        ".gif"  { "image/gif" }
        ".webp" { "image/webp" }
        default { "image/png" }
    }

    return @{
        MimeType = $mimeType
        Base64 = $base64
    }
}

# === MAIN EXECUTION ===

try {
    # Validate image exists
    $resolvedPath = Resolve-Path $ImagePath -ErrorAction Stop

    # Get API key
    $apiKey = Get-OpenAIApiKey

    # Convert image to base64
    $imageData = ConvertTo-Base64Image -Path $resolvedPath

    # Build request body
    $body = @{
        model = "gpt-4o"
        max_tokens = $MaxTokens
        messages = @(
            @{
                role = "user"
                content = @(
                    @{
                        type = "text"
                        text = $Instruction
                    },
                    @{
                        type = "image_url"
                        image_url = @{
                            url = "data:$($imageData.MimeType);base64,$($imageData.Base64)"
                            detail = $DetailLevel
                        }
                    }
                )
            }
        )
    } | ConvertTo-Json -Depth 10

    # Make API request
    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type" = "application/json"
    }

    $response = Invoke-RestMethod `
        -Uri "https://api.openai.com/v1/chat/completions" `
        -Method Post `
        -Headers $headers `
        -Body $body `
        -TimeoutSec 120

    # Return just the text content
    $result = $response.choices[0].message.content

    return $result

} catch {
    Write-Error "Image analysis failed: $_"
    exit 1
}
