# learn-from-code.ps1
# Autonomous pattern extraction from code
# Learns from existing projects and adds patterns to library

param(
    [string]$File,
    [switch]$ExtractPatterns,
    [switch]$Analyze,
    [string]$Pattern = "all" # all, hero, timeline, checkout, navigation, etc.
)

$LibraryPath = "C:\scripts\agentidentity\coding-patterns\pattern-library.json"

function Extract-HeroPattern {
    param([string]$HTML, [string]$CSS, [string]$SourceFile)

    # Detect hero section
    if ($HTML -match '(?s)<section[^>]*class="hero"[^>]*>(.*?)</section>') {
        $heroHTML = $matches[1]

        # Extract hero CSS
        $heroCSS = ""
        if ($CSS -match '(?s)/\* Hero.*?\*/\s*(.*?)(?=/\*|$)') {
            $heroCSS = $matches[1]
        }

        # Extract key features
        $hasGradient = $CSS -match 'linear-gradient'
        $hasCTA = $heroHTML -match 'cta'
        $hasCountdown = $heroHTML -match 'countdown'

        # Calculate quality score
        $quality = 0.5
        if ($hasGradient) { $quality += 0.15 }
        if ($hasCTA) { $quality += 0.15 }
        if ($CSS -match '@media') { $quality += 0.2 } # Responsive

        $pattern = @{
            id = "hero-" + [guid]::NewGuid().ToString().Substring(0,8)
            type = "ui-component"
            stack = "html-css"
            category = "hero"
            name = "Hero Section - Extracted from $(Split-Path $SourceFile -Leaf)"
            description = "Professional hero section with gradient background"
            code = @{
                html = $heroHTML.Trim()
                css = $heroCSS.Trim()
                js = ""
            }
            variants = @()
            dependencies = @()
            props = @("title", "subtitle", "ctaText", "ctaLink", "price")
            metadata = @{
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

        return $pattern
    }

    return $null
}

function Extract-TimelinePattern {
    param([string]$HTML, [string]$CSS, [string]$SourceFile)

    if ($HTML -match '(?s)<div[^>]*class="timeline-grid"[^>]*>(.*?)</div>') {
        $timelineHTML = $matches[1]

        # Count timeline items
        $itemCount = ([regex]::Matches($timelineHTML, 'timeline-item')).Count

        # Detect orientation
        $isHorizontal = $CSS -match 'grid-template-columns:\s*repeat\(5'

        $timelineCss = ""
        if ($CSS -match '(?s)/\* Timeline.*?\*/\s*(.*?)(?=/\*|$)') {
            $timelineCss = $matches[1].Trim()
        }

        $pattern = @{
            id = "timeline-" + [guid]::NewGuid().ToString().Substring(0,8)
            type = "ui-component"
            stack = "html-css"
            category = "timeline"
            name = "Timeline - $itemCount steps " + $(if($isHorizontal){"horizontal"}else{"vertical"})
            description = "Timeline component showing process steps"
            code = @{
                html = $timelineHTML.Trim()
                css = $timelineCss
                js = ""
            }
            metadata = @{
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

        return $pattern
    }

    return $null
}

function Extract-CheckoutPattern {
    param([string]$HTML, [string]$CSS, [string]$SourceFile)

    if ($HTML -match '(?s)<div[^>]*class="checkout-modal"[^>]*>(.*?)</div>\s*</div>') {
        $checkoutHTML = $matches[1]

        # Detect payment methods
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

        $pattern = @{
            id = "checkout-" + [guid]::NewGuid().ToString().Substring(0,8)
            type = "ui-component"
            stack = "html-css"
            category = "checkout"
            name = "Checkout Modal - Multi-payment"
            description = "Professional checkout with multiple payment methods"
            code = @{
                html = $checkoutHTML.Trim()
                css = $checkoutCss
                js = ""
            }
            metadata = @{
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

        return $pattern
    }

    return $null
}

function Extract-ColorPalette {
    param([string]$CSS, [string]$SourceFile)

    # Extract all color codes
    $colors = [regex]::Matches($CSS, '#[0-9a-fA-F]{3,6}|rgb\([^\)]+\)|rgba\([^\)]+\)') |
              ForEach-Object { $_.Value } |
              Select-Object -Unique

    # Find gradient patterns
    $gradients = [regex]::Matches($CSS, 'linear-gradient\([^\)]+\)') |
                 ForEach-Object { $_.Value } |
                 Select-Object -Unique

    if ($colors.Count -gt 0) {
        $pattern = @{
            id = "palette-" + [guid]::NewGuid().ToString().Substring(0,8)
            type = "design-principle"
            category = "color-palette"
            name = "Color Palette - Extracted from $(Split-Path $SourceFile -Leaf)"
            description = "Color scheme used in this design"
            colors = @{
                primary = @()
                accent = @()
                neutral = @()
                gradients = $gradients
                all = $colors
            }
            metadata = @{
                quality = 0.8
                usageCount = 1
                lastUsed = (Get-Date).ToString("yyyy-MM-dd")
                createdFrom = $SourceFile
                tags = @("colors", "palette", "design")
                created = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            }
        }

        return $pattern
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

    # Extract patterns
    $patterns = [System.Collections.ArrayList]@()

    if ($Pattern -eq "all" -or $Pattern -eq "hero") {
        $heroPattern = Extract-HeroPattern -HTML $html -CSS $css -SourceFile $File
        if ($heroPattern) {
            $null = $patterns.Add(($heroPattern))
            Write-Host "[OK] Extracted Hero pattern (quality: $($heroPattern.metadata.quality))" -ForegroundColor Green
        }
    }

    if ($Pattern -eq "all" -or $Pattern -eq "timeline") {
        $timelinePattern = Extract-TimelinePattern -HTML $html -CSS $css -SourceFile $File
        if ($timelinePattern) {
            $null = $patterns.Add($timelinePattern)
            Write-Host "[OK] Extracted Timeline pattern (quality: $($timelinePattern.metadata.quality))" -ForegroundColor Green
        }
    }

    if ($Pattern -eq "all" -or $Pattern -eq "checkout") {
        $checkoutPattern = Extract-CheckoutPattern -HTML $html -CSS $css -SourceFile $File
        if ($checkoutPattern) {
            $null = $patterns.Add($checkoutPattern)
            Write-Host "[OK] Extracted Checkout pattern (quality: $($checkoutPattern.metadata.quality))" -ForegroundColor Green
        }
    }

    if ($Pattern -eq "all" -or $Pattern -eq "colors") {
        $colorPattern = Extract-ColorPalette -CSS $css -SourceFile $File
        if ($colorPattern) {
            $null = $patterns.Add($colorPattern)
            $colorCount = $colorPattern.colors.all.Count
            Write-Host "[OK] Extracted Color palette ($colorCount colors)" -ForegroundColor Green
        }
    }

    # Save to library
    if ($patterns.Count -gt 0) {
        Write-Host "[DEBUG] Extracted $($patterns.Count) patterns:" -ForegroundColor Magenta
        foreach ($p in $patterns) {
            Write-Host "  - $($p.name) (type: $($p.type))" -ForegroundColor Magenta
        }

        $library = Get-Content $LibraryPath | ConvertFrom-Json

        # Convert arrays to ArrayList for mutation
        $htmlCssList = [System.Collections.ArrayList]@($library.patterns.'ui-components'.'html-css')
        $designList = [System.Collections.ArrayList]@($library.patterns.'design-principles')

        Write-Host "[DEBUG] Before adding - HTML/CSS: $($htmlCssList.Count), Design: $($designList.Count)" -ForegroundColor Magenta
        Write-Host "[DEBUG] Patterns is type: $($patterns.GetType().Name)" -ForegroundColor Magenta

        $i = 0
        foreach ($pattern in $patterns) {
            $i++
            Write-Host "[DEBUG] Loop iteration $i" -ForegroundColor Magenta
            Write-Host "[DEBUG] Pattern is type: $($pattern.GetType().Name)" -ForegroundColor Magenta
            Write-Host "[DEBUG] Pattern keys: $($pattern.Keys -join ', ')" -ForegroundColor Magenta
            Write-Host "[DEBUG] Pattern.type value: '$($pattern.type)'" -ForegroundColor Magenta
            Write-Host "[DEBUG] Pattern.type is null: $($null -eq $pattern.type)" -ForegroundColor Magenta

            if ($pattern.type -eq "ui-component") {
                Write-Host "[DEBUG] Matched ui-component condition" -ForegroundColor Magenta
                $result = $htmlCssList.Add($pattern)
                Write-Host "[DEBUG] Added ui-component: $($pattern.name), result: $result" -ForegroundColor Magenta
            } elseif ($pattern.type -eq "design-principle") {
                Write-Host "[DEBUG] Matched design-principle condition" -ForegroundColor Magenta
                $result = $designList.Add($pattern)
                Write-Host "[DEBUG] Added design-principle: $($pattern.name), result: $result" -ForegroundColor Magenta
            } else {
                Write-Host "[DEBUG] No match for pattern type: '$($pattern.type)'" -ForegroundColor Magenta
            }
        }

        Write-Host "[DEBUG] After adding - HTML/CSS: $($htmlCssList.Count), Design: $($designList.Count)" -ForegroundColor Magenta

        # Update library with new arrays
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

if ($Analyze) {
    Write-Host "[STATS] Pattern Library Statistics" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan

    $library = Get-Content $LibraryPath | ConvertFrom-Json

    Write-Host "Total Patterns: $($library.metadata.totalPatterns)"
    Write-Host "  - UI Components (HTML/CSS): $($library.patterns.'ui-components'.'html-css'.Count)"
    Write-Host "  - UI Components (React): $($library.patterns.'ui-components'.'react-tailwind'.Count)"
    Write-Host "  - Backend (C#): $($library.patterns.backend.csharp.Count)"
    Write-Host "  - Design Principles: $($library.patterns.'design-principles'.Count)"
    Write-Host ""
    Write-Host "New patterns this week: $($library.metadata.stats.newPatternsThisWeek)"
    Write-Host "Total scaffolds: $($library.metadata.stats.totalScaffolds)"
}
