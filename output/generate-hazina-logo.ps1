$ErrorActionPreference = 'Stop'
$key = (Get-Content 'C:\stores\appsettings.Secrets.json' | ConvertFrom-Json).ApiSettings.OpenApiKey

$prompt = @"
A polished gemstone logo icon centered on white background. The shape is a classic cut gem seen from the front: wide at the top (crown) tapering to a point at the bottom (pavilion), like a brilliant-cut sapphire. The gem has a smooth gradient from bright cerulean blue at the top crown facets to deep navy indigo at the bottom point. A single small four-pointed white sparkle star sits on the upper right of the crown, suggesting brilliance. Centered inside the gem are exactly 4 small gold dots connected by thin gold lines in a diamond or rhombus arrangement, representing a minimal neural network. The gold lines and dots are simple and elegant, not thick. No drop shadow, no floating elements, no background effects. No text. The gem shape is one solid cohesive form. Clean vector style, high quality, professional tech company logo.
"@

$body = @{
    model = 'dall-e-3'
    prompt = $prompt
    n = 1
    size = '1024x1024'
    quality = 'hd'
    style = 'natural'
} | ConvertTo-Json -Depth 5

$headers = @{
    'Authorization' = "Bearer $key"
    'Content-Type' = 'application/json'
}

Write-Host 'Calling DALL-E 3...'
$response = Invoke-RestMethod -Uri 'https://api.openai.com/v1/images/generations' -Method Post -Headers $headers -Body $body -TimeoutSec 120
$imageUrl = $response.data[0].url
$revised = $response.data[0].revised_prompt
Write-Host "Revised prompt: $revised"

Write-Host 'Downloading image...'
Invoke-WebRequest -Uri $imageUrl -OutFile 'C:\scripts\output\hazina-logo-v4.png' -TimeoutSec 60
Write-Host 'Saved to C:\scripts\output\hazina-logo-v4.png'
Write-Host 'Done!'
