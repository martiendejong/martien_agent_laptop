# Build Context Index for Fast Lookup
# Part of Round 9 Improvements - Context Index for Fast Lookup
# Pre-built index for O(1) context file lookup

param(
    [Parameter(Mandatory=$false)]
    [string]$ContextPath = "C:\scripts",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\context-index.db.json",

    [Parameter(Mandatory=$false)]
    [switch]$Rebuild = $false,

    [Parameter(Mandatory=$false)]
    [string]$Query = $null
)

$ErrorActionPreference = "Stop"

Write-Host "Context Index Builder - Round 9 Implementation" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Build full-text search index
function Build-ContextIndex {
    param([string]$Path)

    Write-Host "Building context index..." -ForegroundColor Yellow
    Write-Host "  Scanning: $Path" -ForegroundColor Gray

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    $files = Get-ChildItem -Path $Path -Recurse -Include "*.md", "*.yaml", "*.yml" -File

    $index = @{
        metadata = @{
            generated = (Get-Date).ToString("o")
            version = "1.0"
            total_files = $files.Count
            index_path = $Path
        }
        files = @{}
        keywords = @{}
        aliases = @{}
        sections = @{}
        links = @{}
    }

    $fileCount = 0

    foreach ($file in $files) {
        $fileCount++

        if ($fileCount % 50 -eq 0) {
            Write-Host "  Progress: $fileCount / $($files.Count)" -ForegroundColor Gray
        }

        $relativePath = $file.FullName.Replace($Path, "").TrimStart('\', '/')

        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue

            if (-not $content) { continue }

            # Extract metadata
            $wordCount = ($content -split '\s+').Count
            $lineCount = ($content -split "`n").Count
            $size = $file.Length

            # Extract title (first # heading)
            $title = if ($content -match '^#\s+(.+)$') { $matches[1] } else { $file.BaseName }

            # Extract keywords (all words > 4 chars, excluding common words)
            $commonWords = @('with', 'from', 'that', 'this', 'have', 'been', 'were', 'will', 'what', 'when', 'where', 'which', 'their', 'there', 'these', 'those', 'would', 'could', 'should')
            $words = ($content -split '\W+' | Where-Object { $_.Length -gt 4 -and $_ -notin $commonWords } | Group-Object | Sort-Object -Property Count -Descending | Select-Object -First 20).Name

            # Extract links
            $linkMatches = [regex]::Matches($content, '\[([^\]]+)\]\(([^)]+)\)')
            $links = @()
            foreach ($match in $linkMatches) {
                $links += @{
                    text = $match.Groups[1].Value
                    url = $match.Groups[2].Value
                }
            }

            # Extract sections (headings)
            $sectionMatches = [regex]::Matches($content, '^(#{1,6})\s+(.+)$', 'Multiline')
            $sections = @()
            foreach ($match in $sectionMatches) {
                $level = $match.Groups[1].Value.Length
                $text = $match.Groups[2].Value

                $sections += @{
                    level = $level
                    text = $text
                    id = ($text -replace '[^\w\s-]', '' -replace '\s+', '-').ToLower()
                }
            }

            # File entry
            $fileEntry = @{
                path = $file.FullName
                relativePath = $relativePath
                name = $file.Name
                title = $title
                size = $size
                wordCount = $wordCount
                lineCount = $lineCount
                lastModified = $file.LastWriteTime.ToString("o")
                keywords = $words
                sections = $sections
                links = $links
                hash = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash
            }

            $index.files[$relativePath] = $fileEntry

            # Build keyword index (inverted index)
            foreach ($word in $words) {
                $wordLower = $word.ToLower()

                if (-not $index.keywords.ContainsKey($wordLower)) {
                    $index.keywords[$wordLower] = @()
                }

                $index.keywords[$wordLower] += $relativePath
            }

            # Build section index
            foreach ($section in $sections) {
                $sectionId = $section.id

                if (-not $index.sections.ContainsKey($sectionId)) {
                    $index.sections[$sectionId] = @()
                }

                $index.sections[$sectionId] += @{
                    file = $relativePath
                    text = $section.text
                    level = $section.level
                }
            }

            # Build alias index (filename variations)
            $baseName = $file.BaseName.ToLower()
            $index.aliases[$baseName] = $relativePath

            # Common variations
            $kebab = $baseName -replace '_', '-'
            $snake = $baseName -replace '-', '_'

            if ($kebab -ne $baseName) {
                $index.aliases[$kebab] = $relativePath
            }

            if ($snake -ne $baseName) {
                $index.aliases[$snake] = $relativePath
            }
        }
        catch {
            Write-Host "  Error indexing $($file.Name): $_" -ForegroundColor Red
        }
    }

    $sw.Stop()

    $index.metadata.build_time_ms = $sw.ElapsedMilliseconds

    Write-Host ""
    Write-Host "Index built successfully!" -ForegroundColor Green
    Write-Host "  Files indexed: $($index.files.Count)" -ForegroundColor Green
    Write-Host "  Keywords: $($index.keywords.Count)" -ForegroundColor Green
    Write-Host "  Sections: $($index.sections.Count)" -ForegroundColor Green
    Write-Host "  Build time: $($sw.ElapsedMilliseconds) ms" -ForegroundColor Green

    return $index
}

# Search index
function Search-ContextIndex {
    param([hashtable]$Index, [string]$Query)

    $results = @()

    # Try exact file match
    $queryLower = $Query.ToLower()

    if ($Index.aliases.ContainsKey($queryLower)) {
        $relativePath = $Index.aliases[$queryLower]
        $fileInfo = $Index.files[$relativePath]

        $results += @{
            type = "exact_match"
            score = 100
            file = $fileInfo
        }
    }

    # Try keyword match
    if ($Index.keywords.ContainsKey($queryLower)) {
        $matchingFiles = $Index.keywords[$queryLower]

        foreach ($file in $matchingFiles) {
            if (-not ($results | Where-Object { $_.file.relativePath -eq $file })) {
                $fileInfo = $Index.files[$file]

                $results += @{
                    type = "keyword_match"
                    score = 75
                    file = $fileInfo
                    keyword = $queryLower
                }
            }
        }
    }

    # Try section match
    if ($Index.sections.ContainsKey($queryLower)) {
        $matchingSections = $Index.sections[$queryLower]

        foreach ($section in $matchingSections) {
            $fileInfo = $Index.files[$section.file]

            if (-not ($results | Where-Object { $_.file.relativePath -eq $section.file })) {
                $results += @{
                    type = "section_match"
                    score = 60
                    file = $fileInfo
                    section = $section.text
                }
            }
        }
    }

    # Try partial keyword match
    $partialKeywords = $Index.keywords.Keys | Where-Object { $_ -like "*$queryLower*" }

    foreach ($keyword in $partialKeywords) {
        $matchingFiles = $Index.keywords[$keyword]

        foreach ($file in $matchingFiles) {
            if (-not ($results | Where-Object { $_.file.relativePath -eq $file })) {
                $fileInfo = $Index.files[$file]

                $results += @{
                    type = "partial_match"
                    score = 40
                    file = $fileInfo
                    keyword = $keyword
                }
            }
        }
    }

    # Sort by score
    $results = $results | Sort-Object -Property score -Descending

    return $results
}

# Main execution
if ($Rebuild -or -not (Test-Path $OutputPath)) {
    $index = Build-ContextIndex -Path $ContextPath

    # Save index
    Write-Host ""
    Write-Host "Saving index to $OutputPath..." -ForegroundColor Yellow

    $index | ConvertTo-Json -Depth 10 -Compress | Out-File -FilePath $OutputPath -Encoding UTF8

    $indexSize = (Get-Item $OutputPath).Length
    Write-Host "Index saved: $([math]::Round($indexSize / 1KB, 2)) KB" -ForegroundColor Green
}
else {
    Write-Host "Loading existing index: $OutputPath" -ForegroundColor Gray

    $indexJson = Get-Content $OutputPath -Raw | ConvertFrom-Json

    # Convert to hashtable
    $index = @{
        metadata = @{
            generated = $indexJson.metadata.generated
            version = $indexJson.metadata.version
            total_files = $indexJson.metadata.total_files
            index_path = $indexJson.metadata.index_path
            build_time_ms = $indexJson.metadata.build_time_ms
        }
        files = @{}
        keywords = @{}
        aliases = @{}
        sections = @{}
    }

    foreach ($prop in $indexJson.files.PSObject.Properties) {
        $index.files[$prop.Name] = $prop.Value
    }

    foreach ($prop in $indexJson.keywords.PSObject.Properties) {
        $index.keywords[$prop.Name] = @($prop.Value)
    }

    foreach ($prop in $indexJson.aliases.PSObject.Properties) {
        $index.aliases[$prop.Name] = $prop.Value
    }

    foreach ($prop in $indexJson.sections.PSObject.Properties) {
        $index.sections[$prop.Name] = @($prop.Value)
    }

    Write-Host "Index loaded: $($index.files.Count) files, $($index.keywords.Count) keywords" -ForegroundColor Green
}

Write-Host ""

# Query mode
if ($Query) {
    Write-Host "Searching for: $Query" -ForegroundColor Cyan
    Write-Host ""

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $results = Search-ContextIndex -Index $index -Query $Query
    $sw.Stop()

    if ($results.Count -eq 0) {
        Write-Host "No results found." -ForegroundColor Yellow
    }
    else {
        Write-Host "Found $($results.Count) results in $($sw.ElapsedMilliseconds) ms:" -ForegroundColor Green
        Write-Host ""

        foreach ($result in ($results | Select-Object -First 10)) {
            Write-Host "  [$($result.score)] $($result.file.title)" -ForegroundColor Cyan
            Write-Host "    Type: $($result.type)" -ForegroundColor Gray
            Write-Host "    Path: $($result.file.relativePath)" -ForegroundColor Gray

            if ($result.keyword) {
                Write-Host "    Keyword: $($result.keyword)" -ForegroundColor Gray
            }

            if ($result.section) {
                Write-Host "    Section: $($result.section)" -ForegroundColor Gray
            }

            Write-Host ""
        }
    }

    return @{
        Success = $true
        ResultCount = $results.Count
        QueryTime = $sw.ElapsedMilliseconds
        Results = $results
    }
}
else {
    Write-Host "Index ready for queries." -ForegroundColor Green
    Write-Host "  Use -Query parameter to search" -ForegroundColor Gray
    Write-Host "  Example: .\build-context-index.ps1 -Query 'worktree'" -ForegroundColor Gray
    Write-Host ""

    return @{
        Success = $true
        IndexPath = $OutputPath
        TotalFiles = $index.files.Count
        TotalKeywords = $index.keywords.Count
    }
}
