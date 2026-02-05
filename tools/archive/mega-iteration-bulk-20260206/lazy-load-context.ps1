# Lazy Loading Strategy for Context
# Part of Round 9 Improvements - Lazy Loading Strategy
# Load context files on-demand, not all at startup

param(
    [Parameter(Mandatory=$false)]
    [string]$ContextPath = "C:\scripts\_machine",

    [Parameter(Mandatory=$false)]
    [string]$IndexPath = "C:\scripts\_machine\lazy-load-index.json",

    [Parameter(Mandatory=$false)]
    [switch]$RebuildIndex = $false,

    [Parameter(Mandatory=$false)]
    [string]$LoadFile = $null
)

$ErrorActionPreference = "Stop"

Write-Host "Lazy Loading Context System - Round 9 Implementation" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Build lazy loading index
function Build-LazyLoadIndex {
    param([string]$Path)

    Write-Host "Building lazy load index..." -ForegroundColor Yellow

    $files = Get-ChildItem -Path $Path -Recurse -Include "*.md", "*.yaml", "*.yml" -File

    $index = @{
        generated = (Get-Date).ToString("o")
        total_files = $files.Count
        files = @{}
        tags = @{}
        priority = @{
            critical = @()
            high = @()
            normal = @()
            low = @()
        }
    }

    foreach ($file in $files) {
        $relativePath = $file.FullName.Replace($Path, "").TrimStart('\', '/')
        $size = $file.Length
        $lastModified = $file.LastWriteTime.ToString("o")

        # Determine priority based on filename patterns
        $priority = "normal"
        $tags = @()

        if ($file.Name -match "STARTUP|MACHINE_CONFIG|GENERAL") {
            $priority = "critical"
            $tags += "startup"
        }
        elseif ($file.Name -match "CAPABILITIES|PROTOCOL|WORKFLOW") {
            $priority = "high"
            $tags += "core"
        }
        elseif ($file.Name -match "archive|checkpoint|backup") {
            $priority = "low"
            $tags += "archive"
        }

        # Extract tags from content (first 1000 chars)
        try {
            $preview = Get-Content $file.FullName -TotalCount 20 -ErrorAction SilentlyContinue | Out-String

            if ($preview -match "worktree") { $tags += "worktree" }
            if ($preview -match "git|commit|pr|pull request") { $tags += "git" }
            if ($preview -match "improvement|reflection") { $tags += "learning" }
            if ($preview -match "client-manager|hazina|brand2boost") { $tags += "project" }
        }
        catch {
            # Skip if can't read file
        }

        $fileInfo = @{
            path = $file.FullName
            relativePath = $relativePath
            size = $size
            lastModified = $lastModified
            priority = $priority
            tags = $tags
            loaded = $false
        }

        $index.files[$relativePath] = $fileInfo
        $index.priority[$priority] += $relativePath

        # Index by tags
        foreach ($tag in $tags) {
            if (-not $index.tags.ContainsKey($tag)) {
                $index.tags[$tag] = @()
            }
            $index.tags[$tag] += $relativePath
        }
    }

    return $index
}

# Load specific file on-demand
function Load-ContextFile {
    param([hashtable]$Index, [string]$RelativePath)

    if (-not $Index.files.ContainsKey($RelativePath)) {
        Write-Host "  File not in index: $RelativePath" -ForegroundColor Red
        return $null
    }

    $fileInfo = $Index.files[$RelativePath]

    if ($fileInfo.loaded) {
        Write-Host "  Already loaded: $RelativePath" -ForegroundColor Gray
        return $fileInfo
    }

    $fullPath = $fileInfo.path

    if (-not (Test-Path $fullPath)) {
        Write-Host "  File not found: $fullPath" -ForegroundColor Red
        return $null
    }

    Write-Host "  Loading: $RelativePath" -ForegroundColor Green

    try {
        $content = Get-Content $fullPath -Raw
        $fileInfo.content = $content
        $fileInfo.loaded = $true
        $fileInfo.loadedAt = (Get-Date).ToString("o")

        return $fileInfo
    }
    catch {
        Write-Host "  Error loading file: $_" -ForegroundColor Red
        return $null
    }
}

# Load files by tag
function Load-ByTag {
    param([hashtable]$Index, [string]$Tag)

    if (-not $Index.tags.ContainsKey($Tag)) {
        Write-Host "  Tag not found: $Tag" -ForegroundColor Yellow
        return @()
    }

    $files = $Index.tags[$Tag]
    $loaded = @()

    Write-Host "  Loading $($files.Count) files tagged '$Tag'..." -ForegroundColor Yellow

    foreach ($file in $files) {
        $result = Load-ContextFile -Index $Index -RelativePath $file
        if ($result) {
            $loaded += $result
        }
    }

    return $loaded
}

# Load critical files
function Load-CriticalFiles {
    param([hashtable]$Index)

    Write-Host "  Loading critical files..." -ForegroundColor Yellow

    $critical = $Index.priority.critical
    $loaded = @()

    foreach ($file in $critical) {
        $result = Load-ContextFile -Index $Index -RelativePath $file
        if ($result) {
            $loaded += $result
        }
    }

    return $loaded
}

# Main execution
if ($RebuildIndex -or -not (Test-Path $IndexPath)) {
    $index = Build-LazyLoadIndex -Path $ContextPath
    $index | ConvertTo-Json -Depth 10 | Out-File -FilePath $IndexPath -Encoding UTF8
    Write-Host "Index built: $IndexPath" -ForegroundColor Green
    Write-Host "  Total files: $($index.total_files)" -ForegroundColor Green
    Write-Host "  Critical: $($index.priority.critical.Count)" -ForegroundColor Green
    Write-Host "  High: $($index.priority.high.Count)" -ForegroundColor Green
    Write-Host "  Normal: $($index.priority.normal.Count)" -ForegroundColor Green
    Write-Host "  Low: $($index.priority.low.Count)" -ForegroundColor Green
}
else {
    Write-Host "Loading existing index: $IndexPath" -ForegroundColor Gray
    $indexJson = Get-Content $IndexPath -Raw | ConvertFrom-Json

    # Convert JSON to hashtable
    $index = @{
        generated = $indexJson.generated
        total_files = $indexJson.total_files
        files = @{}
        tags = @{}
        priority = @{
            critical = @($indexJson.priority.critical)
            high = @($indexJson.priority.high)
            normal = @($indexJson.priority.normal)
            low = @($indexJson.priority.low)
        }
    }

    foreach ($prop in $indexJson.files.PSObject.Properties) {
        $index.files[$prop.Name] = @{
            path = $prop.Value.path
            relativePath = $prop.Value.relativePath
            size = $prop.Value.size
            lastModified = $prop.Value.lastModified
            priority = $prop.Value.priority
            tags = @($prop.Value.tags)
            loaded = $false
        }
    }

    foreach ($prop in $indexJson.tags.PSObject.Properties) {
        $index.tags[$prop.Name] = @($prop.Value)
    }
}

Write-Host ""

if ($LoadFile) {
    # Load specific file
    Write-Host "Loading specific file: $LoadFile" -ForegroundColor Cyan
    $result = Load-ContextFile -Index $index -RelativePath $LoadFile

    if ($result) {
        Write-Host ""
        Write-Host "File loaded successfully!" -ForegroundColor Green
        Write-Host "  Size: $($result.size) bytes" -ForegroundColor Gray
        Write-Host "  Priority: $($result.priority)" -ForegroundColor Gray
        Write-Host "  Tags: $($result.tags -join ', ')" -ForegroundColor Gray
    }

    return $result
}
else {
    # Interactive mode
    Write-Host "Lazy Load Context - Interactive Mode" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor Yellow
    Write-Host "  load critical       - Load all critical files" -ForegroundColor Gray
    Write-Host "  load tag <tag>      - Load files by tag" -ForegroundColor Gray
    Write-Host "  load file <path>    - Load specific file" -ForegroundColor Gray
    Write-Host "  list tags           - Show all tags" -ForegroundColor Gray
    Write-Host "  list critical       - Show critical files" -ForegroundColor Gray
    Write-Host "  stats               - Show loading statistics" -ForegroundColor Gray
    Write-Host "  exit                - Exit" -ForegroundColor Gray
    Write-Host ""

    $loadedCount = 0
    $loadedSize = 0

    while ($true) {
        Write-Host "lazy-load> " -NoNewline -ForegroundColor Cyan
        $command = Read-Host

        if ($command -eq "exit" -or $command -eq "quit") {
            break
        }
        elseif ($command -eq "load critical") {
            $loaded = Load-CriticalFiles -Index $index
            $loadedCount += $loaded.Count
            $loadedSize += ($loaded | Measure-Object -Property size -Sum).Sum
            Write-Host "  Loaded $($loaded.Count) critical files" -ForegroundColor Green
        }
        elseif ($command -match '^load tag (.+)$') {
            $tag = $matches[1]
            $loaded = Load-ByTag -Index $index -Tag $tag
            $loadedCount += $loaded.Count
            $loadedSize += ($loaded | Measure-Object -Property size -Sum).Sum
            Write-Host "  Loaded $($loaded.Count) files" -ForegroundColor Green
        }
        elseif ($command -match '^load file (.+)$') {
            $file = $matches[1]
            $result = Load-ContextFile -Index $index -RelativePath $file
            if ($result) {
                $loadedCount++
                $loadedSize += $result.size
            }
        }
        elseif ($command -eq "list tags") {
            Write-Host "  Available tags:" -ForegroundColor Yellow
            foreach ($tag in $index.tags.Keys | Sort-Object) {
                Write-Host "    $tag ($($index.tags[$tag].Count) files)" -ForegroundColor Gray
            }
        }
        elseif ($command -eq "list critical") {
            Write-Host "  Critical files:" -ForegroundColor Yellow
            foreach ($file in $index.priority.critical) {
                Write-Host "    $file" -ForegroundColor Gray
            }
        }
        elseif ($command -eq "stats") {
            $totalLoaded = ($index.files.Values | Where-Object { $_.loaded }).Count
            Write-Host "  Loading Statistics:" -ForegroundColor Yellow
            Write-Host "    Files loaded: $totalLoaded / $($index.total_files)" -ForegroundColor Gray
            Write-Host "    Size loaded: $([math]::Round($loadedSize / 1KB, 2)) KB" -ForegroundColor Gray
        }
        else {
            Write-Host "  Unknown command. Type 'exit' to quit." -ForegroundColor Red
        }

        Write-Host ""
    }

    Write-Host "Exiting lazy-load context system." -ForegroundColor Gray
}

return @{
    Success = $true
    IndexPath = $IndexPath
    TotalFiles = $index.total_files
}
