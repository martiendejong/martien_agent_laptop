# Memory Layer 4 - Semantic Search
# Simple vector-based semantic search with upgrade path to full vector DB
# Created: 2026-02-07 (Fix 14 - Final fix to 100%)

<#
.SYNOPSIS
    Memory Layer 4 - Semantic search using simple embeddings

.DESCRIPTION
    Provides semantic search using:
    - Simple TF-IDF vectorization (current implementation)
    - Cosine similarity for matching
    - Upgrade path to full vector DB (ChromaDB, FAISS, Qdrant)

.NOTES
    File: memory-layer4-semantic.ps1
    Status: Working implementation with upgrade path
    Part of Fix 14 - Layer 4 semantic search
#>

param(
    [ValidateSet('init', 'embed', 'search', 'stats')]
    [string]$Command = 'init'
)

$ErrorActionPreference = "Continue"

#region Configuration

$script:EmbeddingsPath = "C:\scripts\agentidentity\state\embeddings\"
$script:VectorStorePath = Join-Path $script:EmbeddingsPath "vectors.jsonl"
$script:VocabularyPath = Join-Path $script:EmbeddingsPath "vocabulary.json"

# Global in-memory vector store
if (-not $global:VectorStore) {
    $global:VectorStore = @{
        Vectors = @()
        Vocabulary = @{}
        Initialized = $false
    }
}

#endregion

#region Simple TF-IDF Embeddings

function Build-Vocabulary {
    <#
    .SYNOPSIS
        Build vocabulary from corpus for TF-IDF
    #>
    param([array]$Documents)

    $vocabulary = @{}
    $vocabIndex = 0

    foreach ($doc in $Documents) {
        $words = Tokenize-Text -Text $doc

        foreach ($word in $words) {
            if (-not $vocabulary.ContainsKey($word)) {
                $vocabulary[$word] = $vocabIndex
                $vocabIndex++
            }
        }
    }

    return $vocabulary
}

function Tokenize-Text {
    <#
    .SYNOPSIS
        Simple tokenization (lowercase, remove punctuation, split on whitespace)
    #>
    param([string]$Text)

    if (-not $Text) { return @() }

    # Lowercase and remove punctuation
    $cleaned = $Text.ToLower() -replace '[^\w\s]', ' '

    # Split on whitespace and filter empty
    $words = $cleaned -split '\s+' | Where-Object { $_ -and $_.Length -gt 2 }

    return $words
}

function Calculate-TFIDF {
    <#
    .SYNOPSIS
        Calculate TF-IDF vector for document
    #>
    param(
        [string]$Document,
        [hashtable]$Vocabulary,
        [int]$TotalDocuments,
        [hashtable]$DocumentFrequency
    )

    $words = Tokenize-Text -Text $Document
    $wordCount = $words.Count

    if ($wordCount -eq 0) {
        return @()
    }

    # Initialize vector with zeros
    $vector = New-Object double[] $Vocabulary.Count

    # Count term frequency in this document
    $termFreq = @{}
    foreach ($word in $words) {
        if (-not $termFreq.ContainsKey($word)) {
            $termFreq[$word] = 0
        }
        $termFreq[$word]++
    }

    # Calculate TF-IDF for each term
    foreach ($word in $termFreq.Keys) {
        if ($Vocabulary.ContainsKey($word)) {
            $tf = $termFreq[$word] / $wordCount

            # IDF calculation
            $df = if ($DocumentFrequency.ContainsKey($word)) { $DocumentFrequency[$word] } else { 1 }
            $idf = [Math]::Log($TotalDocuments / $df)

            $tfidf = $tf * $idf

            $index = $Vocabulary[$word]
            $vector[$index] = $tfidf
        }
    }

    return $vector
}

function Calculate-CosineSimilarity {
    <#
    .SYNOPSIS
        Calculate cosine similarity between two vectors
    #>
    param(
        [double[]]$Vector1,
        [double[]]$Vector2
    )

    if ($Vector1.Count -ne $Vector2.Count) {
        return 0.0
    }

    $dotProduct = 0.0
    $magnitude1 = 0.0
    $magnitude2 = 0.0

    for ($i = 0; $i -lt $Vector1.Count; $i++) {
        $dotProduct += $Vector1[$i] * $Vector2[$i]
        $magnitude1 += $Vector1[$i] * $Vector1[$i]
        $magnitude2 += $Vector2[$i] * $Vector2[$i]
    }

    $magnitude1 = [Math]::Sqrt($magnitude1)
    $magnitude2 = [Math]::Sqrt($magnitude2)

    if ($magnitude1 -eq 0 -or $magnitude2 -eq 0) {
        return 0.0
    }

    return $dotProduct / ($magnitude1 * $magnitude2)
}

#endregion

#region Vector Store Operations

function Initialize-Layer4 {
    <#
    .SYNOPSIS
        Initialize semantic search layer
    #>

    Write-Host "[*] Initializing Memory Layer 4 (Semantic Search)..." -ForegroundColor Cyan

    # Ensure directory exists
    if (-not (Test-Path $script:EmbeddingsPath)) {
        New-Item -ItemType Directory -Path $script:EmbeddingsPath -Force | Out-Null
    }

    # Load existing vectors if available
    if (Test-Path $script:VectorStorePath) {
        Write-Host "[*] Loading existing vector store..." -ForegroundColor Gray

        $lines = Get-Content -Path $script:VectorStorePath -Encoding UTF8 |
                 Where-Object { $_ -and $_.Trim() }

        $global:VectorStore.Vectors = $lines | ForEach-Object {
            $_ | ConvertFrom-Json
        }

        Write-Host "    Loaded $($global:VectorStore.Vectors.Count) vectors" -ForegroundColor Gray
    }

    # Build vocabulary from existing vectors and rebuild vectors
    if ($global:VectorStore.Vectors.Count -gt 0) {
        $documents = $global:VectorStore.Vectors | ForEach-Object { $_.Text }
        $global:VectorStore.Vocabulary = Build-Vocabulary -Documents $documents

        Write-Host "    Built vocabulary: $($global:VectorStore.Vocabulary.Count) terms" -ForegroundColor Gray
        Write-Host "    Rebuilding vectors with new vocabulary..." -ForegroundColor Gray

        # Calculate document frequency
        $docFreq = @{}
        foreach ($doc in $documents) {
            $words = Tokenize-Text -Text $doc
            $uniqueWords = $words | Select-Object -Unique
            foreach ($word in $uniqueWords) {
                if (-not $docFreq.ContainsKey($word)) {
                    $docFreq[$word] = 0
                }
                $docFreq[$word]++
            }
        }

        # Rebuild all vectors with consistent vocabulary
        for ($i = 0; $i -lt $global:VectorStore.Vectors.Count; $i++) {
            $entry = $global:VectorStore.Vectors[$i]
            $newVector = Calculate-TFIDF -Document $entry.Text `
                                          -Vocabulary $global:VectorStore.Vocabulary `
                                          -TotalDocuments $documents.Count `
                                          -DocumentFrequency $docFreq

            $global:VectorStore.Vectors[$i].Vector = $newVector
        }

        # Save updated vocabulary
        $global:VectorStore.Vocabulary | ConvertTo-Json | Out-File -FilePath $script:VocabularyPath -Encoding UTF8
    }

    $global:VectorStore.Initialized = $true

    Write-Host "[OK] Initialized semantic search" -ForegroundColor Green
    Write-Host "    Storage: $script:EmbeddingsPath" -ForegroundColor Gray
    Write-Host "    Vectors: $($global:VectorStore.Vectors.Count)" -ForegroundColor Gray
    Write-Host "    Vocabulary: $($global:VectorStore.Vocabulary.Count) terms" -ForegroundColor Gray
    Write-Host "    Method: TF-IDF + Cosine Similarity" -ForegroundColor Gray
    Write-Host ""

    return @{
        Initialized = $true
        VectorCount = $global:VectorStore.Vectors.Count
        VocabularySize = $global:VectorStore.Vocabulary.Count
        StoragePath = $script:EmbeddingsPath
    }
}

function Add-SemanticVector {
    <#
    .SYNOPSIS
        Add document to semantic index
    #>
    param(
        [string]$Text,
        [hashtable]$Metadata = @{}
    )

    if (-not $global:VectorStore.Initialized) {
        Write-Warning "Layer 4 not initialized"
        return $false
    }

    try {
        # Update vocabulary if needed
        $words = Tokenize-Text -Text $Text
        $vocabUpdated = $false

        foreach ($word in $words) {
            if (-not $global:VectorStore.Vocabulary.ContainsKey($word)) {
                $global:VectorStore.Vocabulary[$word] = $global:VectorStore.Vocabulary.Count
                $vocabUpdated = $true
            }
        }

        if ($vocabUpdated) {
            # Save updated vocabulary
            $global:VectorStore.Vocabulary | ConvertTo-Json | Out-File -FilePath $script:VocabularyPath -Encoding UTF8
        }

        # Calculate document frequency for IDF
        $docFreq = @{}
        foreach ($vec in $global:VectorStore.Vectors) {
            $docWords = Tokenize-Text -Text $vec.Text
            $uniqueWords = $docWords | Select-Object -Unique

            foreach ($word in $uniqueWords) {
                if (-not $docFreq.ContainsKey($word)) {
                    $docFreq[$word] = 0
                }
                $docFreq[$word]++
            }
        }

        # Calculate TF-IDF vector
        $vector = Calculate-TFIDF -Document $Text `
                                   -Vocabulary $global:VectorStore.Vocabulary `
                                   -TotalDocuments ($global:VectorStore.Vectors.Count + 1) `
                                   -DocumentFrequency $docFreq

        # Create entry
        $entry = @{
            Text = $Text
            Vector = $vector
            Metadata = $Metadata
            Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }

        # Add to in-memory store
        $global:VectorStore.Vectors += $entry

        # Append to file
        $entry | ConvertTo-Json -Compress | Add-Content -Path $script:VectorStorePath -Encoding UTF8

        return $true

    } catch {
        Write-Warning "Failed to add semantic vector: $_"
        return $false
    }
}

function Search-Semantic {
    <#
    .SYNOPSIS
        Search for semantically similar documents
    #>
    param(
        [string]$Query,
        [int]$TopK = 5,
        [double]$MinSimilarity = 0.1
    )

    if (-not $global:VectorStore.Initialized) {
        Write-Warning "Layer 4 not initialized"
        return @()
    }

    if ($global:VectorStore.Vectors.Count -eq 0) {
        return @()
    }

    try {
        # Calculate document frequency for IDF
        $docFreq = @{}
        foreach ($vec in $global:VectorStore.Vectors) {
            $docWords = Tokenize-Text -Text $vec.Text
            $uniqueWords = $docWords | Select-Object -Unique

            foreach ($word in $uniqueWords) {
                if (-not $docFreq.ContainsKey($word)) {
                    $docFreq[$word] = 0
                }
                $docFreq[$word]++
            }
        }

        # Calculate query vector
        $queryVector = Calculate-TFIDF -Document $Query `
                                        -Vocabulary $global:VectorStore.Vocabulary `
                                        -TotalDocuments $global:VectorStore.Vectors.Count `
                                        -DocumentFrequency $docFreq

        # Calculate similarities
        $results = @()

        foreach ($entry in $global:VectorStore.Vectors) {
            $similarity = Calculate-CosineSimilarity -Vector1 $queryVector -Vector2 $entry.Vector

            if ($similarity -ge $MinSimilarity) {
                $results += @{
                    Text = $entry.Text
                    Similarity = $similarity
                    Metadata = $entry.Metadata
                    Timestamp = $entry.Timestamp
                }
            }
        }

        # Sort by similarity and take top K
        $results = $results | Sort-Object -Property Similarity -Descending | Select-Object -First $TopK

        return $results

    } catch {
        Write-Warning "Semantic search failed: $_"
        return @()
    }
}

function Get-Layer4Stats {
    <#
    .SYNOPSIS
        Get semantic search statistics
    #>

    if (-not $global:VectorStore.Initialized) {
        return @{
            Initialized = $false
            VectorCount = 0
            VocabularySize = 0
        }
    }

    $stats = @{
        Initialized = $true
        VectorCount = $global:VectorStore.Vectors.Count
        VocabularySize = $global:VectorStore.Vocabulary.Count
        StoragePath = $script:EmbeddingsPath
        Method = "TF-IDF + Cosine Similarity"
    }

    if (Test-Path $script:VectorStorePath) {
        $stats.StorageSizeKB = [math]::Round(([System.IO.FileInfo]$script:VectorStorePath).Length / 1KB, 2)
    }

    return $stats
}

#endregion

#region Integration Functions

function Index-EventSemantic {
    <#
    .SYNOPSIS
        Add event to semantic index
    #>
    param([hashtable]$Event)

    $text = "$($Event.Type) $($Event.Data)"
    return Add-SemanticVector -Text $text -Metadata @{
        Type = "event"
        EventType = $Event.Type
        Timestamp = $Event.Timestamp
    }
}

function Index-DecisionSemantic {
    <#
    .SYNOPSIS
        Add decision to semantic index
    #>
    param([hashtable]$Decision)

    $text = "$($Decision.Decision) $($Decision.Reasoning)"
    return Add-SemanticVector -Text $text -Metadata @{
        Type = "decision"
        Confidence = $Decision.Confidence
        Timestamp = $Decision.Timestamp
    }
}

function Index-PatternSemantic {
    <#
    .SYNOPSIS
        Add pattern to semantic index
    #>
    param([hashtable]$Pattern)

    $text = $Pattern.Pattern
    return Add-SemanticVector -Text $text -Metadata @{
        Type = "pattern"
        Strength = $Pattern.Strength
        Occurrences = $Pattern.Occurrences
    }
}

#endregion

#region Main Execution

if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.InvocationName -ne '&') {
    switch ($Command) {
        'init' {
            $result = Initialize-Layer4
            return $result
        }

        'embed' {
            # Example embedding
            Write-Host "Use Add-SemanticVector or Index-* functions for integration"
        }

        'search' {
            # Example search
            Write-Host "Use Search-Semantic function for semantic queries"
        }

        'stats' {
            $stats = Get-Layer4Stats

            Write-Host ""
            Write-Host "Memory Layer 4 Statistics" -ForegroundColor Cyan
            Write-Host "=========================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  Storage: $($stats.StoragePath)" -ForegroundColor Gray
            Write-Host "  Method: $($stats.Method)" -ForegroundColor Gray
            Write-Host "  Vectors: $($stats.VectorCount)" -ForegroundColor Green
            Write-Host "  Vocabulary: $($stats.VocabularySize) terms" -ForegroundColor Green

            if ($stats.ContainsKey('StorageSizeKB')) {
                Write-Host "  Storage Size: $($stats.StorageSizeKB) KB" -ForegroundColor Gray
            }

            Write-Host ""
            Write-Host "  Upgrade Path: ChromaDB / FAISS / Qdrant" -ForegroundColor Yellow
            Write-Host ""

            return $stats
        }
    }
}

#endregion
