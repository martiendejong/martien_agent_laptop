# Resilient Documentation Lookup
# Purpose: Graceful degradation through fallback layers when primary fails
# Created: 2026-02-05 (Round 12: Resilience Framework)

param(
    [Parameter(Mandatory=$true)]
    [string]$Topic,

    [string]$Context = "",  # Optional context to narrow search
    [switch]$VerboseFallback  # Show which layer succeeded
)

$layerResults = @()

# Layer 1: PRIMARY - Hazina RAG semantic search (optimal)
Write-Host "🔍 Layer 1: Trying Hazina RAG semantic search..." -ForegroundColor Cyan
try {
    $hazinaPath = "C:\scripts\tools\hazina-rag.ps1"
    if (Test-Path $hazinaPath) {
        $result = & $hazinaPath -Action query -Query $Topic -StoreName "C:\scripts\my_network" -ErrorAction Stop

        if ($result -and $result.Count -gt 0) {
            $layerResults += @{
                "Layer" = 1
                "Method" = "Hazina RAG"
                "Quality" = "Optimal"
                "Result" = $result
            }

            if ($VerboseFallback) {
                Write-Host "✅ Layer 1 SUCCESS: Hazina RAG found results" -ForegroundColor Green
            }

            return $result
        }
    }
} catch {
    Write-Warning "Layer 1 FAILED: Hazina RAG unavailable - $($_.Exception.Message)"
}

# Layer 2: SECONDARY - File-based grep search (good)
Write-Host "🔍 Layer 2: Trying file-based grep search..." -ForegroundColor Yellow
try {
    $grepPattern = $Topic -replace '\s+', '.*'  # Allow word separation
    $searchPaths = @(
        "C:\scripts\docs\",
        "C:\scripts\_machine\",
        "C:\scripts\agentidentity\"
    )

    $files = @()
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $found = Get-ChildItem -Path $path -Recurse -Filter "*.md" -ErrorAction SilentlyContinue |
                     Where-Object { (Get-Content $_.FullName -Raw) -match $grepPattern }

            $files += $found
        }
    }

    if ($files.Count -gt 0) {
        $result = $files | ForEach-Object {
            $content = Get-Content $_.FullName -Raw
            @{
                "File" = $_.FullName
                "Excerpt" = ($content -split "`n" | Select-String -Pattern $grepPattern -Context 2 | Select-Object -First 3)
            }
        }

        $layerResults += @{
            "Layer" = 2
            "Method" = "Grep search"
            "Quality" = "Good"
            "Result" = $result
        }

        if ($VerboseFallback) {
            Write-Host "✅ Layer 2 SUCCESS: Found in $($files.Count) files" -ForegroundColor Green
        }

        return $result
    }
} catch {
    Write-Warning "Layer 2 FAILED: Grep search error - $($_.Exception.Message)"
}

# Layer 3: TERTIARY - Quick reference lookup (acceptable)
Write-Host "🔍 Layer 3: Trying quick reference lookup..." -ForegroundColor Yellow
try {
    $quickRefPath = "C:\scripts\QUICK_REFERENCE.md"
    if (Test-Path $quickRefPath) {
        $quickRef = Get-Content $quickRefPath -Raw

        if ($quickRef -match $Topic) {
            $result = @{
                "Source" = "QUICK_REFERENCE.md"
                "Match" = ($quickRef -split "`n" | Select-String -Pattern $Topic -Context 3)
            }

            $layerResults += @{
                "Layer" = 3
                "Method" = "Quick reference"
                "Quality" = "Acceptable"
                "Result" = $result
            }

            if ($VerboseFallback) {
                Write-Host "✅ Layer 3 SUCCESS: Found in quick reference" -ForegroundColor Green
            }

            return $result
        }
    }
} catch {
    Write-Warning "Layer 3 FAILED: Quick reference error - $($_.Exception.Message)"
}

# Layer 4: QUATERNARY - Web search for general knowledge (minimal)
Write-Host "🔍 Layer 4: Trying web search..." -ForegroundColor Yellow
try {
    # Note: WebSearch tool would be used here if available
    # Simulated for now (would need actual WebSearch integration)

    Write-Warning "Layer 4 SKIPPED: Web search not implemented yet (requires WebSearch tool)"

    # Placeholder for future implementation:
    # $webResult = WebSearch -Query "$Topic documentation Claude agent"
    # if ($webResult) { return $webResult }

} catch {
    Write-Warning "Layer 4 FAILED: Web search error - $($_.Exception.Message)"
}

# Layer 5: LAST RESORT - Return failure with guidance
Write-Host "❌ All lookup layers failed for: $Topic" -ForegroundColor Red
Write-Host ""
Write-Host "📚 MANUAL LOOKUP SUGGESTIONS:" -ForegroundColor Yellow
Write-Host "1. Check C:\scripts\CLAUDE.md (main documentation index)"
Write-Host "2. Check C:\scripts\QUICK_REFERENCE.md (top 20 frequent requests)"
Write-Host "3. Search C:\scripts\docs\ manually"
Write-Host "4. Ask user for guidance"
Write-Host ""

$fallbackGuidance = @{
    "Status" = "All layers failed"
    "Topic" = $Topic
    "SuggestedActions" = @(
        "Check C:\scripts\CLAUDE.md manually"
        "Search C:\scripts\docs\ directory"
        "Ask user where to find this information"
    )
    "LayersAttempted" = $layerResults
}

return $fallbackGuidance
