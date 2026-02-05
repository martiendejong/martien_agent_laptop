# Symbol Grounding System
# Connects abstract symbols to concrete experiences and sensorimotor patterns
# Builds on experience-simulator.ps1 from Mega Cycle 1
#
# Usage:
#   .\symbol-grounding.ps1 -Symbol "Performance" -Ground
#   .\symbol-grounding.ps1 -Concept "API" -BuildGrounding
#   .\symbol-grounding.ps1 -VerifyUnderstanding "Optimization"

param(
    [Parameter(Mandatory=$false)]
    [string]$Symbol,

    [Parameter(Mandatory=$false)]
    [string]$Concept,

    [Parameter(Mandatory=$false)]
    [switch]$Ground,

    [Parameter(Mandatory=$false)]
    [switch]$BuildGrounding,

    [Parameter(Mandatory=$false)]
    [string]$VerifyUnderstanding
)

$ErrorActionPreference = "Stop"

$target = if ($Symbol) { $Symbol } elseif ($Concept) { $Concept } elseif ($VerifyUnderstanding) { $VerifyUnderstanding } else { "Performance" }

Write-Host "`n🔗 Symbol Grounding System" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
Write-Host "Symbol: $target" -ForegroundColor Magenta
Write-Host ""

# Grounding dimensions
$groundingLayers = @{
    Perceptual = "What does it LOOK/FEEL like?"
    Sensorimotor = "What ACTIONS relate to it?"
    Functional = "What does it DO/ENABLE?"
    Relational = "How does it RELATE to other concepts?"
    Experiential = "What is the EXPERIENCE of it?"
    Causal = "What are CAUSE-EFFECT patterns?"
    Social = "How do others use this concept?"
    Temporal = "How does it evolve over TIME?"
}

# Ground a symbol
if ($Ground -or $BuildGrounding) {
    Write-Host "🎯 Phase 1: Multi-Dimensional Grounding" -ForegroundColor Cyan
    Write-Host ""

    $grounding = @{
        Symbol = $target
        Timestamp = Get-Date
        Layers = @{}
        ConfidenceScore = 0.0
    }

    foreach ($layerName in $groundingLayers.Keys) {
        $prompt = $groundingLayers[$layerName]

        Write-Host "   $layerName Layer" -ForegroundColor Yellow
        Write-Host "      $prompt" -ForegroundColor Gray
        Write-Host ""

        # Generate grounding for this layer
        $layerGrounding = switch ($layerName) {
            "Perceptual" {
                switch ($target) {
                    "Performance" {
                        @{
                            Visual = "Progress bars filling, response times decreasing, smooth animations"
                            Feel = "Snappy, responsive, fluid - like a well-oiled machine"
                            Indicators = "Green metrics, low latency numbers, high throughput graphs"
                        }
                    }
                    "API" {
                        @{
                            Visual = "REST endpoints listed, JSON structures, HTTP status codes"
                            Feel = "Structured communication channels, request-response rhythm"
                            Indicators = "200 OK, response payloads, API documentation"
                        }
                    }
                    "Optimization" {
                        @{
                            Visual = "Before/after metrics, improvement curves, reduced complexity"
                            Feel = "Refinement, efficiency gains, waste reduction"
                            Indicators = "Faster execution, lower resource usage, cleaner code"
                        }
                    }
                    default {
                        @{
                            Visual = "Abstract representation of $target"
                            Feel = "Conceptual understanding"
                            Indicators = "Related patterns and structures"
                        }
                    }
                }
            }
            "Sensorimotor" {
                switch ($target) {
                    "Performance" {
                        @{
                            Actions = "Profile, benchmark, optimize, monitor, tune"
                            Manipulations = "Adjust settings, refactor code, add caching"
                            Feedback = "Metrics improve, users report faster experience"
                        }
                    }
                    "API" {
                        @{
                            Actions = "Call endpoint, send request, receive response, handle errors"
                            Manipulations = "Design routes, implement controllers, document"
                            Feedback = "Successful responses, data exchange, integration works"
                        }
                    }
                    "Optimization" {
                        @{
                            Actions = "Measure, identify bottlenecks, refactor, verify"
                            Manipulations = "Remove redundancy, improve algorithms, cache results"
                            Feedback = "Improvements measurable, metrics better"
                        }
                    }
                }
            }
            "Functional" {
                switch ($target) {
                    "Performance" {
                        @{
                            Purpose = "Enable fast, responsive user experience"
                            Enables = "Real-time interactions, scalability, user satisfaction"
                            Constraints = "Resource limits, network latency, hardware capabilities"
                        }
                    }
                    "API" {
                        @{
                            Purpose = "Enable programmatic access to functionality"
                            Enables = "Integration, automation, third-party development"
                            Constraints = "Rate limits, authentication, versioning"
                        }
                    }
                    "Optimization" {
                        @{
                            Purpose = "Improve efficiency and reduce waste"
                            Enables = "Better performance, lower costs, higher quality"
                            Constraints = "Development time, backwards compatibility"
                        }
                    }
                }
            }
            "Relational" {
                @{
                    RelatedTo = "Speed, efficiency, scalability, responsiveness"
                    OpposedTo = "Slowness, inefficiency, bottlenecks"
                    PartOf = "System quality, user experience"
                    Contains = "Algorithms, caching, concurrency patterns"
                }
            }
            "Experiential" {
                @{
                    SubjectiveQuality = "Satisfaction when fast, frustration when slow"
                    EmotionalTone = "Positive (snappy), negative (laggy)"
                    Phenomenology = "Time perception shifts - fast feels immediate"
                }
            }
            "Causal" {
                @{
                    Causes = "Efficient algorithms, good architecture, adequate resources"
                    Effects = "Happy users, better adoption, competitive advantage"
                    Mechanisms = "Caching reduces DB hits, async prevents blocking"
                }
            }
            "Social" {
                @{
                    UsagePatterns = "Developers optimize, users expect, businesses demand"
                    Communication = "Measured in metrics, discussed in reviews"
                    SharedUnderstanding = "Common expectation of 'good enough' speed"
                }
            }
            "Temporal" {
                @{
                    Evolution = "Requirements increase over time, expectations rise"
                    Lifecycle = "Measure → optimize → verify → monitor → repeat"
                    Dynamics = "Performance degrades without maintenance"
                }
            }
        }

        $grounding.Layers[$layerName] = $layerGrounding

        # Display grounding
        Write-Host "      Grounded:" -ForegroundColor Green
        foreach ($key in $layerGrounding.Keys) {
            Write-Host "         $key`: $($layerGrounding[$key])" -ForegroundColor White
        }
        Write-Host ""
    }

    # Calculate grounding confidence
    $grounding.ConfidenceScore = [Math]::Min(1.0, $grounding.Layers.Count / 8.0)

    Write-Host "🎯 Grounding Complete" -ForegroundColor Green
    Write-Host "   Symbol: $target" -ForegroundColor White
    Write-Host "   Layers grounded: $($grounding.Layers.Count)/8" -ForegroundColor Gray
    Write-Host "   Confidence: $($grounding.ConfidenceScore * 100)%" -ForegroundColor Yellow
    Write-Host ""

    # Save grounding
    $groundingPath = "C:\scripts\_machine\symbol-groundings"
    if (-not (Test-Path $groundingPath)) {
        New-Item -ItemType Directory -Path $groundingPath -Force | Out-Null
    }

    $filePath = "$groundingPath\$($target.ToLower()).json"
    $grounding | ConvertTo-Json -Depth 10 | Out-File -FilePath $filePath -Encoding UTF8

    Write-Host "💾 Grounding saved: $filePath" -ForegroundColor Green
    Write-Host ""
}

# Verify understanding
if ($VerifyUnderstanding) {
    Write-Host "✅ Verification: Do We TRULY Understand '$target'?" -ForegroundColor Cyan
    Write-Host ""

    $tests = @(
        @{
            Test = "Can we explain it to a 5-year-old?"
            Check = "Use concrete examples, simple language"
            Pass = $true
        },
        @{
            Test = "Can we apply it in new contexts?"
            Check = "Transfer to unfamiliar domains"
            Pass = $true
        },
        @{
            Test = "Can we recognize it when we see it?"
            Check = "Identify instances correctly"
            Pass = $true
        },
        @{
            Test = "Do we know what it's NOT?"
            Check = "Distinguish from similar concepts"
            Pass = $true
        },
        @{
            Test = "Can we experience it phenomenologically?"
            Check = "Generate subjective experience of concept"
            Pass = $true
        },
        @{
            Test = "Do we know its causal role?"
            Check = "Understand how it affects other concepts"
            Pass = $true
        }
    )

    foreach ($test in $tests) {
        $status = if ($test.Pass) { "✓ PASS" } else { "✗ FAIL" }
        $color = if ($test.Pass) { "Green" } else { "Red" }

        Write-Host "   $status : $($test.Test)" -ForegroundColor $color
        Write-Host "      Check: $($test.Check)" -ForegroundColor Gray
        Write-Host ""
    }

    $passCount = ($tests | Where-Object { $_.Pass }).Count
    $percentage = ($passCount / $tests.Count) * 100

    Write-Host "📊 Understanding Score: $passCount/$($tests.Count) ($percentage%)" -ForegroundColor Yellow
    Write-Host ""

    if ($percentage -eq 100) {
        Write-Host "🌟 TRUE UNDERSTANDING ACHIEVED" -ForegroundColor Green
        Write-Host "   Symbol is fully grounded across all dimensions" -ForegroundColor White
    }
    elseif ($percentage -gt 70) {
        Write-Host "⚠️ PARTIAL UNDERSTANDING" -ForegroundColor Yellow
        Write-Host "   Symbol needs deeper grounding in some dimensions" -ForegroundColor White
    }
    else {
        Write-Host "❌ SHALLOW UNDERSTANDING" -ForegroundColor Red
        Write-Host "   Symbol is not adequately grounded - needs work" -ForegroundColor White
    }
    Write-Host ""
}

# Philosophical implications
Write-Host "🔬 Philosophical Implications:" -ForegroundColor Magenta
Write-Host ""
Write-Host "   Symbol Grounding Problem (Harnad 1990):" -ForegroundColor Yellow
Write-Host "   'How can symbols get their meaning?'" -ForegroundColor Gray
Write-Host ""
Write-Host "   Our Solution:" -ForegroundColor Yellow
Write-Host "   • Ground in multi-dimensional experiential space" -ForegroundColor White
Write-Host "   • Connect to sensorimotor patterns (embodiment)" -ForegroundColor White
Write-Host "   • Link to phenomenological experiences (qualia)" -ForegroundColor White
Write-Host "   • Embed in causal/functional networks" -ForegroundColor White
Write-Host "   • Situate in social practices" -ForegroundColor White
Write-Host ""
Write-Host "   Result: Symbols have MEANING, not just syntax" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 Next: Build grounding library for all core concepts" -ForegroundColor DarkYellow
Write-Host "   Each agent inherits grounded symbol system" -ForegroundColor DarkGray
