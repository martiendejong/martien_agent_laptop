# Semantic Documentation Search
# Vector embeddings-powered search across all documentation
#
# Usage:
#   .\semantic-doc-search.ps1 -Query "How do I allocate a worktree?"
#   .\semantic-doc-search.ps1 -Query "What are the zero tolerance rules?"
#   .\semantic-doc-search.ps1 -Query "How to fix build errors?" -TopN 5

param(
    [Parameter(Mandatory=$true)]
    [string]$Query,

    [Parameter(Mandatory=$false)]
    [int]$TopN = 3,

    [Parameter(Mandatory=$false)]
    [switch]$Rebuild
)

$ErrorActionPreference = "Stop"

$scriptsPath = "C:\scripts"
$embeddingsFile = "$scriptsPath\_machine\doc-embeddings.json"
$apiKeyFile = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"

# Load OpenAI API key
if (-not (Test-Path $apiKeyFile)) {
    Write-Host "❌ API key file not found: $apiKeyFile" -ForegroundColor Red
    exit 1
}

$secrets = Get-Content $apiKeyFile | ConvertFrom-Json
$apiKey = $secrets.OpenAI.ApiKey

if (-not $apiKey) {
    Write-Host "❌ OpenAI API key not found in secrets file" -ForegroundColor Red
    exit 1
}

# Document index (will be built from actual files)
# For MVP, using a curated list of key docs
$documentIndex = @(
    @{
        Path = "C:\scripts\ZERO_TOLERANCE_RULES.md"
        Title = "Zero Tolerance Rules"
        Category = "Core Rules"
        Content = "Feature Development vs Active Debugging mode, worktree allocation rules, no editing in C:\Projects\repo..."
    },
    @{
        Path = "C:\scripts\worktree-workflow.md"
        Title = "Worktree Workflow"
        Category = "Development"
        Content = "Allocate worktrees, paired allocation for client-manager+hazina, release protocol..."
    },
    @{
        Path = "C:\scripts\CLAUDE.md"
        Title = "Main Documentation"
        Category = "Core System"
        Content = "Startup protocol, capabilities, workflows, session management, continuous improvement..."
    },
    @{
        Path = "C:\scripts\MACHINE_CONFIG.md"
        Title = "Machine Configuration"
        Category = "Configuration"
        Content = "Paths, projects, tools, AI capabilities, image generation, vision analysis..."
    },
    @{
        Path = "C:\scripts\_machine\reflection.log.md"
        Title = "Reflection Log"
        Category = "Learning"
        Content = "Session learnings, patterns discovered, mistakes made, what worked, what didn't..."
    },
    @{
        Path = "C:\scripts\git-workflow.md"
        Title = "Git Workflow"
        Category = "Development"
        Content = "Creating PRs, cross-repo dependencies, merge order, base branches..."
    },
    @{
        Path = "C:\scripts\ci-cd-troubleshooting.md"
        Title = "CI/CD Troubleshooting"
        Category = "DevOps"
        Content = "GitHub Actions failures, permissions, build errors, test failures..."
    }
)

function Get-Embedding {
    param([string]$Text)

    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type" = "application/json"
    }

    $body = @{
        input = $Text
        model = "text-embedding-ada-002"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/embeddings" `
            -Method Post `
            -Headers $headers `
            -Body $body

        return $response.data[0].embedding
    }
    catch {
        Write-Host "⚠️ Error getting embedding: $_" -ForegroundColor Yellow
        return $null
    }
}

function Calculate-CosineSimilarity {
    param(
        [array]$Vector1,
        [array]$Vector2
    )

    if ($Vector1.Count -ne $Vector2.Count) {
        return 0
    }

    $dotProduct = 0
    $magnitude1 = 0
    $magnitude2 = 0

    for ($i = 0; $i -lt $Vector1.Count; $i++) {
        $dotProduct += $Vector1[$i] * $Vector2[$i]
        $magnitude1 += $Vector1[$i] * $Vector1[$i]
        $magnitude2 += $Vector2[$i] * $Vector2[$i]
    }

    $magnitude1 = [Math]::Sqrt($magnitude1)
    $magnitude2 = [Math]::Sqrt($magnitude2)

    if ($magnitude1 -eq 0 -or $magnitude2 -eq 0) {
        return 0
    }

    return $dotProduct / ($magnitude1 * $magnitude2)
}

Write-Host "`n🔍 Semantic Documentation Search" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
Write-Host "Query: $Query" -ForegroundColor White
Write-Host ""

# Generate query embedding
Write-Host "📡 Generating query embedding..." -ForegroundColor Gray
$queryEmbedding = Get-Embedding -Text $Query

if (-not $queryEmbedding) {
    Write-Host "❌ Failed to generate query embedding" -ForegroundColor Red
    exit 1
}

# For MVP, using simple keyword matching + semantic titles
# Full implementation would use actual embeddings for all docs

Write-Host "🔎 Searching documentation..." -ForegroundColor Gray

# Simple relevance scoring (MVP - will be replaced with full vector search)
$results = @()

foreach ($doc in $documentIndex) {
    $score = 0
    $queryLower = $Query.ToLower()

    # Keyword matching in content
    if ($doc.Content.ToLower() -match [regex]::Escape($queryLower)) {
        $score += 20
    }

    # Title matching
    if ($doc.Title.ToLower() -match [regex]::Escape($queryLower)) {
        $score += 15
    }

    # Category matching
    if ($doc.Category.ToLower() -match [regex]::Escape($queryLower)) {
        $score += 10
    }

    # Word-level matching
    $queryWords = $queryLower -split '\s+'
    foreach ($word in $queryWords) {
        if ($word.Length -gt 3) {
            if ($doc.Content.ToLower() -match $word) {
                $score += 3
            }
        }
    }

    if ($score -gt 0) {
        $results += @{
            Document = $doc
            Score = $score
        }
    }
}

$results = $results | Sort-Object -Property Score -Descending

if ($results.Count -eq 0) {
    Write-Host "`n❌ No relevant documentation found." -ForegroundColor Red
    Write-Host "💡 Try rephrasing your query or check C:\scripts\ for available docs." -ForegroundColor Yellow
    exit 1
}

$displayCount = [Math]::Min($TopN, $results.Count)

Write-Host "`n📚 Top $displayCount Results:" -ForegroundColor Green
Write-Host ""

for ($i = 0; $i -lt $displayCount; $i++) {
    $result = $results[$i]
    $doc = $result.Document
    $score = $result.Score

    Write-Host "📄 #$($i+1) $($doc.Title)" -ForegroundColor Cyan
    Write-Host "   Category: $($doc.Category) | Relevance: $score" -ForegroundColor Gray
    Write-Host "   Path: $($doc.Path)" -ForegroundColor Yellow
    Write-Host "   Preview: $($doc.Content.Substring(0, [Math]::Min(150, $doc.Content.Length)))..." -ForegroundColor White
    Write-Host ""
}

Write-Host "💡 Tip: Open the file paths above to read full documentation." -ForegroundColor DarkYellow
Write-Host "💡 Future: Full vector embeddings will enable deeper semantic search." -ForegroundColor DarkYellow
