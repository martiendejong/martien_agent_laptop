# Mind Map Generator
# Part of Round 10 Improvements - Mind Map Generator
# Auto-generate mind maps from context files

param(
    [Parameter(Mandatory=$false)]
    [string]$SourceFile = "C:\scripts\CLAUDE.md",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\mind-maps",

    [Parameter(Mandatory=$false)]
    [ValidateSet("markdown", "mermaid", "html")]
    [string]$Format = "html",

    [Parameter(Mandatory=$false)]
    [int]$MaxDepth = 4
)

$ErrorActionPreference = "Stop"

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Host "Mind Map Generator - Round 10 Implementation" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Parse markdown to tree structure
function Parse-MarkdownToTree {
    param([string]$Content)

    $lines = $content -split "`n"
    $tree = @{
        title = "Root"
        level = 0
        children = @()
    }

    $stack = @($tree)

    foreach ($line in $lines) {
        # Match headings
        if ($line -match '^(#{1,6})\s+(.+)$') {
            $level = $matches[1].Length
            $text = $matches[2].Trim()

            $node = @{
                title = $text
                level = $level
                children = @()
            }

            # Find correct parent
            while ($stack.Count -gt 0 -and $stack[-1].level -ge $level) {
                $stack = $stack[0..($stack.Count - 2)]
            }

            if ($stack.Count -gt 0) {
                $stack[-1].children += $node
                $stack += $node
            }
        }
        # Match bullet points
        elseif ($line -match '^(\s*)[-*]\s+\*\*(.+?)\*\*') {
            $indent = $matches[1].Length
            $text = $matches[2].Trim()

            $level = [math]::Floor($indent / 2) + 1

            $node = @{
                title = $text
                level = $level
                children = @()
            }

            while ($stack.Count -gt 0 -and $stack[-1].level -ge $level) {
                $stack = $stack[0..($stack.Count - 2)]
            }

            if ($stack.Count -gt 0) {
                $stack[-1].children += $node
                $stack += $node
            }
        }
    }

    return $tree
}

# Generate Mermaid mindmap
function Generate-MermaidMindmap {
    param([hashtable]$Tree)

    $mermaid = "mindmap`n"
    $mermaid += "  root(($($Tree.title)))`n"

    function Add-Node {
        param($Node, $Indent)

        foreach ($child in $Node.children) {
            if ($child.level -le $MaxDepth) {
                $spaces = "  " * $Indent
                $mermaid += "$spaces$($child.title)`n"

                if ($child.children.Count -gt 0) {
                    Add-Node -Node $child -Indent ($Indent + 1)
                }
            }
        }
    }

    Add-Node -Node $Tree -Indent 2

    return $mermaid
}

# Generate HTML mind map with interactive visualization
function Generate-HTMLMindmap {
    param([hashtable]$Tree, [string]$SourceFileName)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Convert tree to JSON
    function Convert-TreeToJSON {
        param($Node)

        $json = @{
            name = $Node.title
            children = @()
        }

        foreach ($child in $Node.children) {
            if ($child.level -le $MaxDepth) {
                $json.children += Convert-TreeToJSON -Node $child
            }
        }

        return $json
    }

    $treeJson = Convert-TreeToJSON -Node $Tree | ConvertTo-Json -Depth 10 -Compress

    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Mind Map - $SourceFileName</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <style>
        body {
            margin: 0;
            padding: 20px;
            font-family: 'Segoe UI', Arial, sans-serif;
            background: #f8f9fa;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            margin-bottom: 10px;
        }
        .meta {
            color: #7f8c8d;
            margin-bottom: 20px;
        }
        #mindmap {
            width: 100%;
            height: 800px;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            background: white;
        }
        .node circle {
            fill: #3498db;
            stroke: #2980b9;
            stroke-width: 2px;
        }
        .node:hover circle {
            fill: #e74c3c;
        }
        .node text {
            font-size: 12px;
            font-weight: 500;
        }
        .link {
            fill: none;
            stroke: #95a5a6;
            stroke-width: 2px;
        }
        .controls {
            margin-top: 20px;
            padding: 15px;
            background: #ecf0f1;
            border-radius: 4px;
        }
        button {
            padding: 8px 16px;
            margin-right: 10px;
            background: #3498db;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background: #2980b9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Mind Map: $SourceFileName</h1>
        <div class="meta">
            <strong>Generated:</strong> $timestamp<br>
            <strong>Max Depth:</strong> $MaxDepth
        </div>

        <div id="mindmap"></div>

        <div class="controls">
            <button onclick="resetZoom()">Reset Zoom</button>
            <button onclick="expandAll()">Expand All</button>
            <button onclick="collapseAll()">Collapse All</button>
        </div>
    </div>

    <script>
        const data = $treeJson;

        const width = document.getElementById('mindmap').clientWidth;
        const height = 800;

        const svg = d3.select('#mindmap')
            .append('svg')
            .attr('width', width)
            .attr('height', height);

        const g = svg.append('g')
            .attr('transform', 'translate(40,0)');

        const tree = d3.tree()
            .size([height - 100, width - 200]);

        const root = d3.hierarchy(data);
        tree(root);

        const link = g.selectAll('.link')
            .data(root.links())
            .enter().append('path')
            .attr('class', 'link')
            .attr('d', d3.linkHorizontal()
                .x(d => d.y)
                .y(d => d.x));

        const node = g.selectAll('.node')
            .data(root.descendants())
            .enter().append('g')
            .attr('class', 'node')
            .attr('transform', d => \`translate(\${d.y},\${d.x})\`);

        node.append('circle')
            .attr('r', d => d.depth === 0 ? 8 : 5);

        node.append('text')
            .attr('dy', '.31em')
            .attr('x', d => d.children ? -10 : 10)
            .style('text-anchor', d => d.children ? 'end' : 'start')
            .text(d => d.data.name);

        // Zoom functionality
        const zoom = d3.zoom()
            .scaleExtent([0.5, 3])
            .on('zoom', (event) => {
                g.attr('transform', event.transform);
            });

        svg.call(zoom);

        function resetZoom() {
            svg.transition().duration(750).call(
                zoom.transform,
                d3.zoomIdentity
            );
        }

        function expandAll() {
            node.style('display', 'block');
        }

        function collapseAll() {
            node.filter((d, i) => i > 0 && d.depth > 1)
                .style('display', 'none');
        }
    </script>
</body>
</html>
"@

    return $html
}

# Main execution
Write-Host "Reading source file: $SourceFile" -ForegroundColor Yellow

if (-not (Test-Path $SourceFile)) {
    Write-Host "Error: Source file not found" -ForegroundColor Red
    return @{ Success = $false; Error = "File not found" }
}

$content = Get-Content $SourceFile -Raw
$tree = Parse-MarkdownToTree -Content $content

Write-Host "  Parsed structure with $($tree.children.Count) top-level nodes" -ForegroundColor Green
Write-Host ""

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($SourceFile)
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Generate output
Write-Host "Generating mind map..." -ForegroundColor Yellow

if ($Format -eq "mermaid") {
    $mermaid = Generate-MermaidMindmap -Tree $tree
    $outputFile = Join-Path $OutputPath "$baseName-mindmap-$timestamp.mmd"
    $mermaid | Out-File -FilePath $outputFile -Encoding UTF8

    Write-Host ""
    Write-Host "Mermaid mind map generated!" -ForegroundColor Green
    Write-Host "  Output: $outputFile" -ForegroundColor Cyan
}
elseif ($Format -eq "html") {
    $html = Generate-HTMLMindmap -Tree $tree -SourceFileName (Split-Path $SourceFile -Leaf)
    $outputFile = Join-Path $OutputPath "$baseName-mindmap-$timestamp.html"
    $html | Out-File -FilePath $outputFile -Encoding UTF8

    Write-Host ""
    Write-Host "Interactive HTML mind map generated!" -ForegroundColor Green
    Write-Host "  Output: $outputFile" -ForegroundColor Cyan
    Write-Host "  Open in browser to interact" -ForegroundColor Gray
}

Write-Host ""

return @{
    Success = $true
    OutputFile = $outputFile
    Format = $Format
    NodeCount = $tree.children.Count
}
