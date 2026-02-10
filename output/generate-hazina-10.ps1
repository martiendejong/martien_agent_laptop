$ErrorActionPreference = 'Stop'
$key = (Get-Content 'C:\stores\appsettings.Secrets.json' | ConvertFrom-Json).ApiSettings.OpenApiKey

$prompts = @(
    @{
        name = "01-hexagonal-vault"
        prompt = "Minimalist tech logo on white background. A regular hexagon shape with a subtle gradient from dark navy to steel blue. In the center, a small elegant keyhole or vault-lock symbol in gold. The hexagon represents technology and infrastructure, the vault represents treasure (Hazina means treasure). Clean flat vector style, no text, no shadow, perfectly symmetrical. Professional, modern, memorable. Think Hashicorp or Kubernetes logo simplicity."
    },
    @{
        name = "02-abstract-H"
        prompt = "Ultra-minimalist logo on white background. The letter H formed entirely by geometric dots and connecting lines. Two vertical columns of 2 dots each connected by a horizontal bar of lines, all in deep indigo blue with gold accent dots at the connection points. The H is abstract enough to read as a network graph but clearly recognizable as the letter H. No other elements, no text, no background effects. Razor clean vector style. Think IBM or Helvetica-era logo design."
    },
    @{
        name = "03-layered-diamond"
        prompt = "Minimalist logo on white background. A diamond or rhombus shape created from 5 thin horizontal layers or slices stacked vertically with small gaps between them. Each layer is a slightly different shade of blue, creating a gradient effect from light azure at top to deep navy at bottom. The layered effect represents infrastructure architecture. A tiny gold dot or sparkle at the very top point. No text, no shadow, clean vector style. Extremely simple and geometric."
    },
    @{
        name = "04-golden-spiral"
        prompt = "Elegant minimalist logo on white background. A Fibonacci golden ratio spiral made of small connected dots and thin lines. The spiral starts tight in the center and expands outward. The dots and lines are in warm gold (#c9a84c) color on a deep navy blue (#0d1b2a) circular background. The spiral represents growth, intelligence, and natural perfection. No text, no extra decoration. Clean, mathematical, beautiful. Think golden ratio meets neural network."
    },
    @{
        name = "05-shield-gem"
        prompt = "Professional logo on white background. A heraldic shield shape with the clean geometric facets of a cut gemstone. The shield has a gradient from sapphire blue at top to deep indigo at bottom. The facet lines within the shield are subtle lighter blue, creating a gem-like quality. One small white four-pointed sparkle on the upper portion. No text, no extra elements, no shadow. The shield represents protection and infrastructure, the gem facets represent treasure. Vector flat style, symmetrical, iconic."
    },
    @{
        name = "06-isometric-cube"
        prompt = "Minimalist logo on white background. A single isometric 3D cube drawn with clean lines. The three visible faces have different shades: top face in light azure blue, left face in medium blue, right face in deep navy. The edges of the cube glow subtly in gold, suggesting energy or data flowing through the infrastructure. No text, no shadow on background, no extra elements. The cube represents a building block, a foundation. Clean geometric vector style. Think Webpack or Netlify logo simplicity."
    },
    @{
        name = "07-baobab-circuit"
        prompt = "Artistic minimalist logo on white background. An abstract African baobab tree silhouette. The trunk and branches are formed by clean circuit-board-style lines and small circular nodes in deep indigo blue. The canopy or crown of the tree has 3-4 gold dots representing fruits or data endpoints. The roots at the bottom spread wide, representing deep infrastructure foundations. Minimal detail, stylized, not realistic. No text, no background. The baobab represents African heritage (Hazina is Swahili for treasure) and deep-rooted infrastructure."
    },
    @{
        name = "08-treasure-chip"
        prompt = "Clever minimalist logo on white background. A shape that is simultaneously a treasure chest seen from the front AND a microprocessor chip. The rectangular body with a slightly arched top reads as both a chest lid and a chip package. Small gold pins or connection points along the bottom edge serve as both chest details and chip pins. The body has a gradient from medium blue to deep navy. A single small gold keyhole or diamond shape in the center. No text, no shadow. Dual-meaning visual pun. Clean vector style."
    },
    @{
        name = "09-constellation"
        prompt = "Ethereal minimalist logo on white background. A constellation pattern: 5 or 6 small stars (dots) connected by very thin lines, arranged to form the overall shape of a diamond or gemstone when you connect the dots. The dots are gold, the connecting lines are deep indigo blue. One of the dots at the top is slightly larger and brighter, like a north star. The empty space between the lines reads as a gem shape. No background, no text, no filled shapes. Just dots and lines floating in white space. Delicate, premium, celestial. Think luxury brand meets tech."
    },
    @{
        name = "10-unified-prism"
        prompt = "Scientific minimalist logo on white background. A triangular prism seen from the side, rendered in clean deep navy blue with subtle gradient. A single thin white line enters the prism from the left. On the right side, the line splits into 3 colored rays: gold, azure blue, and teal, fanning out elegantly. This represents unification: multiple AI providers unified through one framework. Similar concept to Pink Floyd's Dark Side of the Moon but ultra-minimalist, geometric, and professional. No text, no background effects. Clean vector logo style."
    }
)

$headers = @{
    'Authorization' = "Bearer $key"
    'Content-Type' = 'application/json'
}

foreach ($item in $prompts) {
    $name = $item.name
    $outFile = "C:\scripts\output\hazina-$name.png"

    if (Test-Path $outFile) {
        Write-Host "SKIP $name (already exists)"
        continue
    }

    Write-Host "Generating $name..."

    $body = @{
        model = 'dall-e-3'
        prompt = $item.prompt
        n = 1
        size = '1024x1024'
        quality = 'hd'
        style = 'natural'
    } | ConvertTo-Json -Depth 5

    try {
        $response = Invoke-RestMethod -Uri 'https://api.openai.com/v1/images/generations' -Method Post -Headers $headers -Body $body -TimeoutSec 120
        $imageUrl = $response.data[0].url
        Invoke-WebRequest -Uri $imageUrl -OutFile $outFile -TimeoutSec 60
        Write-Host "  DONE -> $outFile"
    } catch {
        Write-Host "  FAILED: $_"
    }

    # Small delay to avoid rate limits
    Start-Sleep -Seconds 2
}

Write-Host "`nAll done! Files in C:\scripts\output\"
