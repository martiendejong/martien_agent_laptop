# learn-from-code-v2.ps1
# Autonomous pattern extraction from code (FIXED for PS 5.1)

param(
    [string]$File,
    [switch]$ExtractPatterns
)

$LibraryPath = "C:\scripts\agentidentity\coding-patterns\pattern-library.json"

function Extract-HeroPattern {
    param([string]$HTML, [string]$CSS, [string]$SourceFile)

    if ($HTML -match '(?s)<section[^>]*class="hero"[^>]*>(.*?)</section>') {
        $heroHTML = $matches[1]

        $heroCSS = ""
        if ($CSS -match '(?s)/\* Hero.*?\*/\s*(.*?)(?=/\*|$)') {
            $heroCSS = $matches[1]
        }

        $hasGradient = $CSS -match 'linear-gradient'
        $hasCTA = $heroHTML -match 'cta'

        $quality = 0.5
        if ($hasGradient) { $quality += 0.15 }
        if ($hasCTA) { $quality += 0.15 }
        if ($CSS -match '@media') { $quality += 0.2 }

        # Create as PSCustomObject instead of hashtable
        return [PSCustomObject]@{
            id = "hero-" + [guid]::NewGuid().ToString().Substring(0,8)
            type = "ui-component"
            stack = "html-css"
            category = "hero"
            name = "Hero Section - Extracted from $(Split-Path $SourceFile -Leaf)"
            description = "Professional hero section with gradient background"
            code = [PSCustomObject]@{
                html = $heroHTML.Trim()
                css = $heroCSS.Trim()
                js = ""
            }
            variants = @()
            dependencies = @()
            props = @("title", "subtitle", "ctaText", "ctaLink", "price")
            metadata = [PSCustomObject]@{
                quality = $quality
                usageCount = 1
                successRate = 1.0
                lastUsed = (Get-Date).ToString("yyyy-MM-dd")
                createdFrom = $SourceFile
                tags = @("hero", "gradient", "responsive")
                responsive = $CSS -match '@media'
                accessibility = 0.7
                created = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            }
        }
    }

    return $null
}

function Extract-TimelinePattern {
    param([string]$HTML, [string]$CSS, [string]$SourceFile)

    if ($HTML -match '(?s)<div[^>]*class="timeline-grid"[^>]*>(.*?)</div>') {
        $timelineHTML = $matches[1]
        $itemCount = ([regex]::Matches($timelineHTML, 'timeline-item')).Count
        $isHorizontal = $CSS -match 'grid-template-columns:\s*repeat\(5'

        $timelineCss = ""
        if ($CSS -match '(?s)/\* Timeline.*?\*/\s*(.*?)(?=/\*|$)') {
            $timelineCss = $matches[1].Trim()
        }

        return [PSCustomObject]@{
            id = "timeline-" + [guid]::NewGuid().ToString().Substring(0,8)
            type = "ui-component"
            stack = "html-css"
            category = "timeline"
            name = "Timeline - $itemCount steps " + $(if($isHorizontal){"horizontal"}else{"vertical"})
            description = "Timeline component showing process steps"
            code = [PSCustomObject]@{
                html = $timelineHTML.Trim()
                css = $timelineCss
                js = ""
            }
            metadata = [PSCustomObject]@{
                quality = 0.85
                usageCount = 1
                successRate = 1.0
                lastUsed = (Get-Date).ToString("yyyy-MM-dd")
                createdFrom = $SourceFile
                tags = @("timeline", "process", "steps", $(if($isHorizontal){"horizontal"}else{"vertical"}))
                responsive = $CSS -match '@media'
                accessibility = 0.75
                created = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
                stepCount = $itemCount
            }
        }
    }

    return $null
}

function Extract-CheckoutPattern {
    param([string]$HTML, [string]$CSS, [string]$SourceFile)

    if ($HTML -match '(?s)<div[^>]*class="checkout-modal"[^>]*>(.*?)</div>\s*</div>') {
        $checkoutHTML = $matches[1]

        $hasIdeal = $checkoutHTML -match 'ideal'
        $hasCard = $checkoutHTML -match 'card'
        $hasPaypal = $checkoutHTML -match 'paypal'

        $paymentMethods = @()
        if ($hasIdeal) { $paymentMethods += "ideal" }
        if ($hasCard) { $paymentMethods += "creditcard" }
        if ($hasPaypal) { $paymentMethods += "paypal" }

        $checkoutCss = ""
        if ($CSS -match '(?s)/\* iDEAL Checkout.*?\*/\s*(.*?)(?=/\* Responsive|$)') {
            $checkoutCss = $matches[1].Trim()
        }

        return [PSCustomObject]@{
            id = "checkout-" + [guid]::NewGuid().ToString().Substring(0,8)
            type = "ui-component"
            stack = "html-css"
            category = "checkout"
            name = "Checkout Modal - Multi-payment"
            description = "Professional checkout with multiple payment methods"
            code = [PSCustomObject]@{
                html = $checkoutHTML.Trim()
                css = $checkoutCss
                js = ""
            }
            metadata = [PSCustomObject]@{
                quality = 0.95
                usageCount = 1
                successRate = 1.0
                lastUsed = (Get-Date).ToString("yyyy-MM-dd")
                createdFrom = $SourceFile
                tags = @("checkout", "payment", "modal") + $paymentMethods
                responsive = $CSS -match '@media'
                accessibility = 0.8
                created = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
                paymentMethods = $paymentMethods
            }
        }
    }

    return $null
}

function Extract-ColorPalette {
    param([string]$CSS, [string]$SourceFile)

    $colors = [regex]::Matches($CSS, '#[0-9a-fA-F]{3,6}|rgb\([^\)]+\)|rgba\([^\)]+\)') |
              ForEach-Object { $_.Value } |
              Select-Object -Unique

    $gradients = [regex]::Matches($CSS, 'linear-gradient\([^\)]+\)') |
                 ForEach-Object { $_.Value } |
                 Select-Object -Unique

    if ($colors.Count -gt 0) {
        return [PSCustomObject]@{
            id = "palette-" + [guid]::NewGuid().ToString().Substring(0,8)
            type = "design-principle"
            category = "color-palette"
            name = "Color Palette - Extracted from $(Split-Path $SourceFile -Leaf)"
            description = "Color scheme used in this design"
            colors = [PSCustomObject]@{
                primary = @()
                accent = @()
                neutral = @()
                gradients = $gradients
                all = $colors
            }
            metadata = [PSCustomObject]@{
                quality = 0.8
                usageCount = 1
                lastUsed = (Get-Date).ToString("yyyy-MM-dd")
                createdFrom = $SourceFile
                tags = @("colors", "palette", "design")
                created = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            }
        }
    }

    return $null
}

# Main execution
if ($ExtractPatterns -and $File) {
    Write-Host "[ANALYZING] File: $File" -ForegroundColor Cyan

    $content = Get-Content $File -Raw

    # Split HTML and CSS
    $html = ""
    $css = ""

    if ($content -match '(?s)<style[^>]*>(.*?)</style>') {
        $css = $matches[1]
    }
    if ($content -match '(?s)<body[^>]*>(.*?)</body>') {
        $html = $matches[1]
    }

    # Extract patterns (using regular array, not ArrayList)
    $patterns = @()

    $heroPattern = Extract-HeroPattern -HTML $html -CSS $css -SourceFile $File
    if ($heroPattern) {
        $patterns += $heroPattern
        Write-Host "[OK] Extracted Hero pattern (quality: $($heroPattern.metadata.quality))" -ForegroundColor Green
    }

    $timelinePattern = Extract-TimelinePattern -HTML $html -CSS $css -SourceFile $File
    if ($timelinePattern) {
        $patterns += $timelinePattern
        Write-Host "[OK] Extracted Timeline pattern (quality: $($timelinePattern.metadata.quality))" -ForegroundColor Green
    }

    $checkoutPattern = Extract-CheckoutPattern -HTML $html -CSS $css -SourceFile $File
    if ($checkoutPattern) {
        $patterns += $checkoutPattern
        Write-Host "[OK] Extracted Checkout pattern (quality: $($checkoutPattern.metadata.quality))" -ForegroundColor Green
    }

    $colorPattern = Extract-ColorPalette -CSS $css -SourceFile $File
    if ($colorPattern) {
        $patterns += $colorPattern
        $colorCount = $colorPattern.colors.all.Count
        Write-Host "[OK] Extracted Color palette ($colorCount colors)" -ForegroundColor Green
    }

    # Save to library
    if ($patterns.Count -gt 0) {
        $library = Get-Content $LibraryPath | ConvertFrom-Json

        # Convert JSON arrays to mutable lists
        $htmlCssList = [System.Collections.ArrayList]@()
        if ($library.patterns.'ui-components'.'html-css') {
            foreach ($item in $library.patterns.'ui-components'.'html-css') {
                $null = $htmlCssList.Add($item)
            }
        }

        $designList = [System.Collections.ArrayList]@()
        if ($library.patterns.'design-principles') {
            foreach ($item in $library.patterns.'design-principles') {
                $null = $designList.Add($item)
            }
        }

        # Add new patterns
        foreach ($pattern in $patterns) {
            if ($pattern.type -eq "ui-component") {
                $null = $htmlCssList.Add($pattern)
            } elseif ($pattern.type -eq "design-principle") {
                $null = $designList.Add($pattern)
            }
        }

        # Update library
        $library.patterns.'ui-components'.'html-css' = $htmlCssList.ToArray()
        $library.patterns.'design-principles' = $designList.ToArray()

        $library.metadata.totalPatterns = (
            $library.patterns.'ui-components'.'html-css'.Count +
            $library.patterns.'ui-components'.'react-tailwind'.Count +
            $library.patterns.backend.csharp.Count +
            $library.patterns.'design-principles'.Count
        )
        $library.metadata.stats.newPatternsThisWeek += $patterns.Count
        $library.lastUpdate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")

        $library | ConvertTo-Json -Depth 10 | Set-Content $LibraryPath

        Write-Host "`n[SAVED] $($patterns.Count) patterns to library" -ForegroundColor Yellow
        Write-Host "[TOTAL] Patterns in library: $($library.metadata.totalPatterns)" -ForegroundColor Cyan
    } else {
        Write-Host "[WARN] No patterns found in file" -ForegroundColor Yellow
    }
}
