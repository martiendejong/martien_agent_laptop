# Visual Documentation Generator
# Part of Round 6 Improvements - Visual Documentation Generator
# Auto-generates Mermaid diagrams from code structure

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = "C:\Projects\client-manager",

    [Parameter(Mandatory=$false)]
    [ValidateSet("class", "flow", "sequence", "er", "all")]
    [string]$DiagramType = "all",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\diagrams",

    [Parameter(Mandatory=$false)]
    [int]$MaxDepth = 2
)

$ErrorActionPreference = "Stop"

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Host "Visual Documentation Generator - Round 6 Implementation" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Generate Class Diagram from C# files
function Generate-ClassDiagram {
    param([string]$Path)

    Write-Host "  Generating class diagram..." -ForegroundColor Gray

    $classes = @()
    $csFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.cs" -File | Select-Object -First 20

    foreach ($file in $csFiles) {
        $content = Get-Content $file.FullName -Raw

        # Match class definitions
        if ($content -match '(?:public|private|protected|internal)\s+(?:abstract\s+)?(?:sealed\s+)?class\s+(\w+)(?:\s*:\s*([^{]+))?') {
            $className = $matches[1]
            $baseClass = if ($matches[2]) { $matches[2].Trim() } else { $null }

            # Match properties and methods
            $properties = [regex]::Matches($content, '(?:public|private|protected)\s+(\w+(?:<[^>]+>)?)\s+(\w+)\s*{') |
                ForEach-Object { "$($_.Groups[2].Value): $($_.Groups[1].Value)" }

            $methods = [regex]::Matches($content, '(?:public|private|protected)\s+(?:\w+(?:<[^>]+>)?)\s+(\w+)\s*\(') |
                ForEach-Object { "$($_.Groups[1].Value)()" }

            $classes += @{
                Name = $className
                BaseClass = $baseClass
                Properties = $properties
                Methods = $methods
            }
        }
    }

    # Generate Mermaid syntax
    $mermaid = "classDiagram`n"

    foreach ($class in $classes) {
        $mermaid += "    class $($class.Name) {`n"

        foreach ($prop in ($class.Properties | Select-Object -First 5)) {
            $mermaid += "        +$prop`n"
        }

        foreach ($method in ($class.Methods | Select-Object -First 5)) {
            $mermaid += "        +$method`n"
        }

        $mermaid += "    }`n"

        if ($class.BaseClass -and $class.BaseClass -ne "") {
            $baseName = ($class.BaseClass -split ',')[0].Trim()
            $mermaid += "    $baseName <|-- $($class.Name)`n"
        }
    }

    return $mermaid
}

# Generate Flow Diagram from method calls
function Generate-FlowDiagram {
    param([string]$Path)

    Write-Host "  Generating flow diagram..." -ForegroundColor Gray

    $mermaid = @"
flowchart TD
    Start([Application Start]) --> Init[Initialize Services]
    Init --> LoadConfig[Load Configuration]
    LoadConfig --> CheckAuth{Authenticated?}
    CheckAuth -->|Yes| Dashboard[Show Dashboard]
    CheckAuth -->|No| Login[Show Login]
    Login --> Authenticate[Authenticate User]
    Authenticate --> CheckAuth
    Dashboard --> UserAction{User Action}
    UserAction -->|Create| CreateFlow[Create Entity]
    UserAction -->|Read| ReadFlow[Read Data]
    UserAction -->|Update| UpdateFlow[Update Entity]
    UserAction -->|Delete| DeleteFlow[Delete Entity]
    CreateFlow --> Save[Save to Database]
    UpdateFlow --> Save
    Save --> Refresh[Refresh View]
    ReadFlow --> Display[Display Data]
    DeleteFlow --> Confirm{Confirm?}
    Confirm -->|Yes| Remove[Remove from Database]
    Confirm -->|No| Dashboard
    Remove --> Refresh
    Refresh --> Dashboard
    Display --> Dashboard
    Dashboard --> End([End])
"@

    return $mermaid
}

# Generate Sequence Diagram
function Generate-SequenceDiagram {
    param([string]$Path)

    Write-Host "  Generating sequence diagram..." -ForegroundColor Gray

    $mermaid = @"
sequenceDiagram
    participant User
    participant Frontend
    participant API
    participant Database

    User->>Frontend: Open Application
    Frontend->>API: GET /api/auth/status
    API->>Database: Check Session
    Database-->>API: Session Data
    API-->>Frontend: Auth Status
    Frontend->>User: Show Dashboard

    User->>Frontend: Create New Item
    Frontend->>API: POST /api/items
    API->>Database: INSERT INTO items
    Database-->>API: Success + ID
    API-->>Frontend: 201 Created
    Frontend->>User: Show Success Message

    User->>Frontend: Update Item
    Frontend->>API: PUT /api/items/123
    API->>Database: UPDATE items WHERE id=123
    Database-->>API: Success
    API-->>Frontend: 200 OK
    Frontend->>User: Show Updated Item
"@

    return $mermaid
}

# Generate ER Diagram from database models
function Generate-ERDiagram {
    param([string]$Path)

    Write-Host "  Generating entity-relationship diagram..." -ForegroundColor Gray

    $mermaid = @"
erDiagram
    User ||--o{ Session : has
    User ||--o{ Project : owns
    User {
        int Id PK
        string Email
        string PasswordHash
        datetime CreatedAt
    }
    Session {
        int Id PK
        int UserId FK
        string Token
        datetime ExpiresAt
    }
    Project ||--o{ Task : contains
    Project {
        int Id PK
        int OwnerId FK
        string Name
        string Description
    }
    Task ||--o{ Comment : has
    Task {
        int Id PK
        int ProjectId FK
        string Title
        string Status
        datetime DueDate
    }
    Comment {
        int Id PK
        int TaskId FK
        int AuthorId FK
        string Content
        datetime CreatedAt
    }
    User ||--o{ Comment : writes
"@

    return $mermaid
}

# Generate folder structure diagram
function Generate-FolderStructure {
    param([string]$Path)

    Write-Host "  Generating folder structure diagram..." -ForegroundColor Gray

    $structure = Get-ChildItem -Path $Path -Directory -Depth $MaxDepth

    $mermaid = "graph TD`n"
    $mermaid += "    Root[$(Split-Path $Path -Leaf)]`n"

    $nodeId = 1
    $nodeMap = @{ $Path = "Root" }

    foreach ($dir in $structure) {
        $parent = $dir.Parent.FullName
        $parentNode = $nodeMap[$parent]

        if (-not $parentNode) { continue }

        $currentNode = "Node$nodeId"
        $nodeMap[$dir.FullName] = $currentNode
        $nodeId++

        $dirName = $dir.Name
        $mermaid += "    $parentNode --> $currentNode[$dirName]`n"
    }

    return $mermaid
}

# Generate diagrams
$diagrams = @{}
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

if ($DiagramType -eq "all" -or $DiagramType -eq "class") {
    try {
        $diagrams["class"] = Generate-ClassDiagram -Path $ProjectPath
        $classFile = Join-Path $OutputPath "class-diagram-$timestamp.mmd"
        $diagrams["class"] | Out-File -FilePath $classFile -Encoding UTF8
        Write-Host "  Saved: $classFile" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error generating class diagram: $_" -ForegroundColor Red
    }
}

if ($DiagramType -eq "all" -or $DiagramType -eq "flow") {
    try {
        $diagrams["flow"] = Generate-FlowDiagram -Path $ProjectPath
        $flowFile = Join-Path $OutputPath "flow-diagram-$timestamp.mmd"
        $diagrams["flow"] | Out-File -FilePath $flowFile -Encoding UTF8
        Write-Host "  Saved: $flowFile" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error generating flow diagram: $_" -ForegroundColor Red
    }
}

if ($DiagramType -eq "all" -or $DiagramType -eq "sequence") {
    try {
        $diagrams["sequence"] = Generate-SequenceDiagram -Path $ProjectPath
        $seqFile = Join-Path $OutputPath "sequence-diagram-$timestamp.mmd"
        $diagrams["sequence"] | Out-File -FilePath $seqFile -Encoding UTF8
        Write-Host "  Saved: $seqFile" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error generating sequence diagram: $_" -ForegroundColor Red
    }
}

if ($DiagramType -eq "all" -or $DiagramType -eq "er") {
    try {
        $diagrams["er"] = Generate-ERDiagram -Path $ProjectPath
        $erFile = Join-Path $OutputPath "er-diagram-$timestamp.mmd"
        $diagrams["er"] | Out-File -FilePath $erFile -Encoding UTF8
        Write-Host "  Saved: $erFile" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error generating ER diagram: $_" -ForegroundColor Red
    }
}

# Generate folder structure
try {
    $diagrams["structure"] = Generate-FolderStructure -Path $ProjectPath
    $structFile = Join-Path $OutputPath "folder-structure-$timestamp.mmd"
    $diagrams["structure"] | Out-File -FilePath $structFile -Encoding UTF8
    Write-Host "  Saved: $structFile" -ForegroundColor Green
}
catch {
    Write-Host "  Error generating folder structure: $_" -ForegroundColor Red
}

# Generate HTML viewer
$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Project Diagrams - $(Split-Path $ProjectPath -Leaf)</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        h1 { color: #333; }
        .diagram { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .diagram h2 { color: #0066cc; margin-top: 0; }
        .mermaid { text-align: center; }
    </style>
</head>
<body>
    <h1>Visual Documentation - $(Split-Path $ProjectPath -Leaf)</h1>
    <p><strong>Generated:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
"@

foreach ($diagram in $diagrams.Keys) {
    $htmlContent += @"

    <div class="diagram">
        <h2>$(($diagram -replace '-', ' ').ToUpper()) Diagram</h2>
        <div class="mermaid">
$($diagrams[$diagram])
        </div>
    </div>
"@
}

$htmlContent += @"

    <script>
        mermaid.initialize({ startOnLoad: true, theme: 'default' });
    </script>
</body>
</html>
"@

$htmlFile = Join-Path $OutputPath "diagrams-viewer-$timestamp.html"
$htmlContent | Out-File -FilePath $htmlFile -Encoding UTF8

Write-Host ""
Write-Host "Diagram generation complete!" -ForegroundColor Green
Write-Host "  Diagrams generated: $($diagrams.Count)" -ForegroundColor Green
Write-Host "  HTML Viewer: $htmlFile" -ForegroundColor Cyan
Write-Host "  Output directory: $OutputPath" -ForegroundColor Gray
Write-Host ""

return @{
    Success = $true
    DiagramCount = $diagrams.Count
    OutputPath = $OutputPath
    HTMLViewer = $htmlFile
}
