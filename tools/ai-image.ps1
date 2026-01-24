<#
.SYNOPSIS
    Wrapper for generate-image.ps1 with automatic API key loading

.DESCRIPTION
    Simplifies image generation by automatically loading the OpenAI API key
    from client-manager appsettings.Secrets.json. This is the preferred way
    for Claude agents to generate images without passing the API key manually.

.PARAMETER Prompt
    Text description of the image to generate

.PARAMETER OutputPath
    File path where the generated image should be saved (PNG format)

.PARAMETER Model
    DALL-E model to use. Options: dall-e-2, dall-e-3 (default: dall-e-3)

.PARAMETER Size
    Image size. For DALL-E 3: 1024x1024, 1024x1792, 1792x1024 (default: 1024x1024)
    For DALL-E 2: 256x256, 512x512, 1024x1024

.PARAMETER Quality
    Image quality (DALL-E 3 only). Options: standard, hd (default: standard)

.PARAMETER Style
    Image style (DALL-E 3 only). Options: vivid, natural (default: vivid)

.EXAMPLE
    .\ai-image.ps1 -Prompt "A sunset over mountains" -OutputPath "C:\images\sunset.png"

.EXAMPLE
    .\ai-image.ps1 -Prompt "Abstract art" -OutputPath "art.png" -Quality hd -Size 1792x1024

.NOTES
    Created: 2026-01-25
    Wrapper for generate-image.ps1 - automatically loads API key from appsettings.Secrets.json
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Prompt,

    [Parameter(Mandatory=$true)]
    [string]$OutputPath,

    [Parameter(Mandatory=$false)]
    [ValidateSet("dall-e-2", "dall-e-3")]
    [string]$Model = "dall-e-3",

    [Parameter(Mandatory=$false)]
    [string]$Size = "1024x1024",

    [Parameter(Mandatory=$false)]
    [ValidateSet("standard", "hd")]
    [string]$Quality = "standard",

    [Parameter(Mandatory=$false)]
    [ValidateSet("vivid", "natural")]
    [string]$Style = "vivid"
)

$ErrorActionPreference = "Stop"

# Load API key from appsettings.Secrets.json
$secretsPath = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"

if (-not (Test-Path $secretsPath)) {
    Write-Error "API secrets file not found: $secretsPath"
    exit 1
}

try {
    $secrets = Get-Content $secretsPath -Raw | ConvertFrom-Json
    $apiKey = $secrets.ApiSettings.OpenApiKey

    if (-not $apiKey) {
        Write-Error "OpenApiKey not found in secrets file"
        exit 1
    }

    # Call the main generate-image.ps1 script
    $generateImageScript = Join-Path $PSScriptRoot "generate-image.ps1"

    if (-not (Test-Path $generateImageScript)) {
        Write-Error "generate-image.ps1 not found: $generateImageScript"
        exit 1
    }

    # Build parameters
    $params = @{
        ApiKey = $apiKey
        Prompt = $Prompt
        OutputPath = $OutputPath
        Model = $Model
        Size = $Size
        Quality = $Quality
        Style = $Style
    }

    # Call the main script
    & $generateImageScript @params

} catch {
    Write-Error "Failed to load API key: $_"
    exit 1
}
