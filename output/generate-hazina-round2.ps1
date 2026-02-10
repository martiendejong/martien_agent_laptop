$ErrorActionPreference = 'Stop'
$key = (Get-Content 'C:\stores\appsettings.Secrets.json' | ConvertFrom-Json).ApiSettings.OpenApiKey

$prompts = @(
    # === GEM + 4 NODES VARIATIONS (based on v2) ===
    @{
        name = "r2-01-gem-teal-silver"
        prompt = "Professional minimalist logo icon on white background. A polished cut gemstone shape seen from the front, wide at the top crown tapering to a point at the bottom. Smooth gradient from bright teal (#14b8a6) at the top to deep dark teal (#134e4a) at the bottom. Glossy highlight reflection on the upper left facet. Centered inside: exactly 4 small silver-white dots connected by thin silver lines in a diamond rhombus arrangement. The gem is one solid cohesive shape with faceted edges. No shadow, no text. Clean vector style, high quality professional tech logo."
    },
    @{
        name = "r2-02-gem-purple-gold"
        prompt = "Professional minimalist logo icon on white background. A polished cut gemstone shape seen from the front, wide at the top crown tapering to a point at the bottom. Smooth gradient from bright violet purple (#8b5cf6) at the top to deep royal purple (#2e1065) at the bottom. A subtle white light sparkle on the upper right facet. Centered inside: exactly 4 small gold (#d4a843) dots connected by thin gold lines in a diamond rhombus arrangement. The gem is one solid cohesive shape. No shadow, no text. Clean vector style, high quality."
    },
    @{
        name = "r2-03-gem-black-gold"
        prompt = "Professional minimalist logo icon on white background. A polished cut gemstone shape seen from the front, wide at the top crown tapering to a point at the bottom. Smooth gradient from dark charcoal grey (#374151) at the top to pure black (#0a0a0a) at the bottom, like a black diamond. A sharp white sparkle highlight on one upper facet. Centered inside: exactly 4 small gold (#fbbf24) dots connected by thin gold lines in a diamond rhombus pattern. Luxury feel, premium, elegant. No shadow, no text. Clean vector style."
    },
    @{
        name = "r2-04-gem-sunset-warm"
        prompt = "Professional minimalist logo icon on white background. A polished cut gemstone shape seen from the front, wide at the top crown tapering to a point at the bottom. Smooth gradient from warm amber (#f59e0b) at the top to deep ruby red (#991b1b) at the bottom, like a fire opal. A subtle white light sparkle on an upper facet. Centered inside: exactly 4 small white dots connected by thin white lines in a diamond rhombus arrangement. Warm, energetic, bold. No shadow, no text. Clean vector style, high quality."
    },
    @{
        name = "r2-05-gem-ice-minimal"
        prompt = "Professional minimalist logo icon on white background. A polished cut gemstone shape seen from the front, wide at the top crown tapering to a point at the bottom. Very subtle gradient from ice white (#e0f2fe) at the top to medium steel blue (#3b82f6) at the bottom. Delicate facet lines visible as thin lighter strokes. A crisp white four-pointed sparkle star on the upper portion. Centered inside: exactly 4 small navy blue (#1e3a5f) dots connected by thin navy lines in a diamond rhombus pattern. Ethereal, light, clean, airy. No shadow, no text. Ultra minimal vector style."
    },
    # === UNIFIED PRISM VARIATIONS (based on logo 10) ===
    @{
        name = "r2-06-prism-sunset"
        prompt = "Minimalist logo on white background. A dark geometric triangular prism in deep charcoal navy (#0f172a) with a subtle gradient on its faces. A thin white line enters from the left side. On the right side the line refracts and fans out into 4 parallel colored rays: gold (#eab308), coral orange (#f97316), rose pink (#ec4899), and warm red (#ef4444). The rays spread at a gentle 15 degree angle. Clean flat vector style, no text, no drop shadow on background. Ultra professional, simple, memorable."
    },
    @{
        name = "r2-07-prism-all-blue"
        prompt = "Minimalist logo on white background. A geometric triangular prism in solid dark navy (#0c1222). A single thin silver-white line enters from the left side. On the right side it splits into 4 rays in different blue tones fanning out: ice blue (#bae6fd), sky blue (#38bdf8), royal blue (#2563eb), and deep indigo (#312e81). Monochromatic blue spectrum. Clean flat vector, no text, no shadow. Calm, professional, unified brand feeling."
    },
    @{
        name = "r2-08-prism-neon"
        prompt = "Minimalist logo on dark background (#0a0a0a). A geometric triangular prism rendered in dark grey (#1f1f2e) with subtle edge highlights. A thin white line enters from the left. On the right it splits into 3 bright neon glowing rays: electric cyan (#06b6d4), hot magenta (#d946ef), and lime green (#84cc16). The rays have a very subtle glow effect. Futuristic, techy, bold. No text, no extra decoration. Clean vector style."
    },
    @{
        name = "r2-09-prism-converge"
        prompt = "Minimalist logo on white background. INVERTED prism concept: on the LEFT side, 4 thin colored lines converge toward the prism: blue (#2563eb), teal (#0d9488), amber gold (#d97706), and violet (#7c3aed). These colored lines enter a geometric triangular prism shape in deep navy (#0f172a). On the RIGHT side, a single unified bright white beam with a subtle glow exits. This represents UNIFICATION of many AI providers into one framework. Clean flat vector, no text, no shadow. Professional and conceptual."
    },
    @{
        name = "r2-10-prism-gold-luxury"
        prompt = "Minimalist logo on white background. A geometric triangular prism with a gradient from dark navy (#0f172a) to midnight blue (#1e3a5f). The prism edges have thin gold (#c9a84c) outlines giving it an elegant premium feel. A thin gold line enters from the left. On the right it splits into 3 rays: bright gold (#fbbf24), white (#ffffff), and royal blue (#2563eb). The gold theme throughout gives it a luxury tech brand aesthetic. No text, no drop shadow. Clean vector style, perfectly balanced."
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

    Start-Sleep -Seconds 2
}

Write-Host "`nAll done! Files in C:\scripts\output\"
