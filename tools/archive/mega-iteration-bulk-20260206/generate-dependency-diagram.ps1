# Dependency Diagram Generator
# Part of Round 10 Improvements - Dependency Diagram Generator
# Shows how context files reference each other

param(
    [Parameter(Mandatory=$false)]
    [string]$ContextPath = "C:\scripts",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\dependency-diagram.html",

    [Parameter(Mandatory=$false)]
    [ValidateSet("mermaid", "html")]
    [string]$Format = "html"
)

$ErrorActionPreference = "Stop"

Write-Host "Dependency Diagram Generator - Round 10 Implementation" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

# Extract file references from markdown
function Get-FileReferences {
    param([string]$FilePath, [string]$BasePath)

    $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue

    if (-not $content) { return @() }

    $references = @()

    # Match markdown links to files
    $patterns = @(
        '\[([^\]]+)\]\(([^)]+\.md)\)',  # [text](file.md)
        '\[([^\]]+)\]\(([^)]+\.yaml)\)',  # [text](file.yaml)
        '`([^`]+\.md)`',  # `file.md`
        '`([^`]+\.yaml)`',  # `file.yaml`
        'See\s+(?:also\s+)?(?:\*\*)?([A-Z][A-Za-z0-9_-]+\.md)(?:\*\*)?',  # See FILENAME.md
        'C:\\scripts\\([^\\s\)`"]+\.(?:md|yaml))'  # C:\scripts\file.md
    )

    foreach ($pattern in $patterns) {
        $matches = [regex]::Matches($content, $pattern, 'IgnoreCase')

        foreach ($match in $matches) {
            $refFile = $match.Groups[$match.Groups.Count - 1].Value

            # Clean up the reference
            $refFile = $refFile -replace 'C:\\scripts\\', '' -replace '/', '\'

            if ($refFile -and $refFile -match '\.(md|yaml|yml)$') {
                $references += $refFile
            }
        }
    }

    return $references | Select-Object -Unique
}

# Build dependency graph
function Build-DependencyGraph {
    param([string]$Path)

    Write-Host "Building dependency graph..." -ForegroundColor Yellow

    $files = Get-ChildItem -Path $Path -Recurse -Include "*.md", "*.yaml", "*.yml" -File

    $graph = @{
        nodes = @()
        edges = @()
    }

    $nodeMap = @{}

    foreach ($file in $files) {
        $relativePath = $file.FullName.Replace($Path, "").TrimStart('\', '/')
        $fileName = $file.Name

        # Add node
        $nodeId = $nodeMap.Count
        $nodeMap[$relativePath] = $nodeId

        $graph.nodes += @{
            id = $nodeId
            name = $fileName
            path = $relativePath
            fullPath = $file.FullName
        }

        # Get references
        $refs = Get-FileReferences -FilePath $file.FullName -BasePath $Path

        foreach ($ref in $refs) {
            # Try to find the referenced file
            $refFullPath = Join-Path $Path $ref

            if (Test-Path $refFullPath) {
                $refFile = Get-Item $refFullPath
                $refRelativePath = $refFile.FullName.Replace($Path, "").TrimStart('\', '/')

                $graph.edges += @{
                    source = $relativePath
                    target = $refRelativePath
                }
            }
        }
    }

    # Convert source/target to node IDs
    $resolvedEdges = @()

    foreach ($edge in $graph.edges) {
        $sourceId = $nodeMap[$edge.source]
        $targetId = $nodeMap[$edge.target]

        if ($null -ne $sourceId -and $null -ne $targetId) {
            $resolvedEdges += @{
                source = $sourceId
                target = $targetId
            }
        }
    }

    $graph.edges = $resolvedEdges

    Write-Host "  Found $($graph.nodes.Count) nodes and $($graph.edges.Count) dependencies" -ForegroundColor Green

    return $graph
}

# Generate Mermaid diagram
function Generate-MermaidDiagram {
    param([hashtable]$Graph)

    $mermaid = "graph TD`n"

    # Limit to most connected files
    $nodeDegree = @{}

    foreach ($node in $Graph.nodes) {
        $nodeDegree[$node.id] = 0
    }

    foreach ($edge in $Graph.edges) {
        $nodeDegree[$edge.source]++
        $nodeDegree[$edge.target]++
    }

    $topNodes = $nodeDegree.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 30

    $includedNodes = $topNodes | ForEach-Object { $_.Key }

    # Add nodes
    foreach ($nodeId in $includedNodes) {
        $node = $Graph.nodes[$nodeId]
        $mermaid += "    $nodeId[$($node.name)]`n"
    }

    # Add edges
    foreach ($edge in $Graph.edges) {
        if ($includedNodes -contains $edge.source -and $includedNodes -contains $edge.target) {
            $mermaid += "    $($edge.source) --> $($edge.target)`n"
        }
    }

    return $mermaid
}

# Generate HTML with interactive visualization
function Generate-HTMLDiagram {
    param([hashtable]$Graph)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Convert to JSON
    $nodesJson = $Graph.nodes | ConvertTo-Json -Compress
    $edgesJson = $Graph.edges | ConvertTo-Json -Compress

    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Context Dependency Diagram</title>
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
        #graph {
            width: 100%;
            height: 800px;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            background: #ffffff;
        }
        .node circle {
            fill: #3498db;
            stroke: #2980b9;
            stroke-width: 2px;
            cursor: pointer;
        }
        .node:hover circle {
            fill: #e74c3c;
        }
        .node text {
            font-size: 10px;
            pointer-events: none;
        }
        .link {
            stroke: #95a5a6;
            stroke-opacity: 0.6;
            stroke-width: 1.5px;
        }
        .link-arrow {
            fill: #95a5a6;
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
        .info-panel {
            margin-top: 20px;
            padding: 15px;
            background: #ecf0f1;
            border-radius: 4px;
            display: none;
        }
        .info-panel.active {
            display: block;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Context Dependency Diagram</h1>
        <div class="meta">
            <strong>Generated:</strong> $timestamp<br>
            <strong>Files:</strong> $($Graph.nodes.Count)<br>
            <strong>Dependencies:</strong> $($Graph.edges.Count)
        </div>

        <div id="graph"></div>

        <div class="controls">
            <button onclick="resetSimulation()">Reset</button>
            <button onclick="pauseSimulation()">Pause</button>
            <button onclick="resumeSimulation()">Resume</button>
        </div>

        <div id="info-panel" class="info-panel">
            <h3 id="info-title"></h3>
            <p id="info-path"></p>
            <p><strong>Depends on:</strong> <span id="info-depends"></span></p>
            <p><strong>Required by:</strong> <span id="info-required"></span></p>
        </div>
    </div>

    <script>
        const nodes = $nodesJson;
        const edges = $edgesJson;

        const width = document.getElementById('graph').clientWidth;
        const height = 800;

        const svg = d3.select('#graph')
            .append('svg')
            .attr('width', width)
            .attr('height', height);

        // Define arrow markers
        svg.append('defs').append('marker')
            .attr('id', 'arrowhead')
            .attr('viewBox', '-0 -5 10 10')
            .attr('refX', 20)
            .attr('refY', 0)
            .attr('orient', 'auto')
            .attr('markerWidth', 6)
            .attr('markerHeight', 6)
            .append('svg:path')
            .attr('d', 'M 0,-5 L 10,0 L 0,5')
            .attr('class', 'link-arrow');

        const simulation = d3.forceSimulation(nodes)
            .force('link', d3.forceLink(edges).id(d => d.id).distance(100))
            .force('charge', d3.forceManyBody().strength(-300))
            .force('center', d3.forceCenter(width / 2, height / 2))
            .force('collision', d3.forceCollide().radius(30));

        const link = svg.append('g')
            .selectAll('line')
            .data(edges)
            .enter().append('line')
            .attr('class', 'link')
            .attr('marker-end', 'url(#arrowhead)');

        const node = svg.append('g')
            .selectAll('g')
            .data(nodes)
            .enter().append('g')
            .attr('class', 'node')
            .call(d3.drag()
                .on('start', dragstarted)
                .on('drag', dragged)
                .on('end', dragended))
            .on('click', showInfo);

        node.append('circle')
            .attr('r', 8);

        node.append('text')
            .attr('dx', 12)
            .attr('dy', '.35em')
            .text(d => d.name);

        simulation.on('tick', () => {
            link
                .attr('x1', d => d.source.x)
                .attr('y1', d => d.source.y)
                .attr('x2', d => d.target.x)
                .attr('y2', d => d.target.y);

            node
                .attr('transform', d => \`translate(\${d.x},\${d.y})\`);
        });

        function dragstarted(event, d) {
            if (!event.active) simulation.alphaTarget(0.3).restart();
            d.fx = d.x;
            d.fy = d.y;
        }

        function dragged(event, d) {
            d.fx = event.x;
            d.fy = event.y;
        }

        function dragended(event, d) {
            if (!event.active) simulation.alphaTarget(0);
            d.fx = null;
            d.fy = null;
        }

        function showInfo(event, d) {
            const dependsOn = edges.filter(e => e.source.id === d.id).map(e => nodes[e.target.id].name);
            const requiredBy = edges.filter(e => e.target.id === d.id).map(e => nodes[e.source.id].name);

            document.getElementById('info-title').textContent = d.name;
            document.getElementById('info-path').textContent = d.path;
            document.getElementById('info-depends').textContent = dependsOn.join(', ') || 'None';
            document.getElementById('info-required').textContent = requiredBy.join(', ') || 'None';
            document.getElementById('info-panel').classList.add('active');
        }

        function resetSimulation() {
            simulation.alpha(1).restart();
        }

        function pauseSimulation() {
            simulation.stop();
        }

        function resumeSimulation() {
            simulation.restart();
        }
    </script>
</body>
</html>
"@

    return $html
}

# Main execution
$graph = Build-DependencyGraph -Path $ContextPath

Write-Host ""
Write-Host "Generating dependency diagram..." -ForegroundColor Yellow

if ($Format -eq "mermaid") {
    $mermaid = Generate-MermaidDiagram -Graph $graph
    $outputFile = $OutputPath -replace '\.html$', '.mmd'
    $mermaid | Out-File -FilePath $outputFile -Encoding UTF8

    Write-Host ""
    Write-Host "Mermaid diagram generated!" -ForegroundColor Green
    Write-Host "  Output: $outputFile" -ForegroundColor Cyan
}
else {
    $html = Generate-HTMLDiagram -Graph $graph
    $html | Out-File -FilePath $OutputPath -Encoding UTF8

    Write-Host ""
    Write-Host "Interactive dependency diagram generated!" -ForegroundColor Green
    Write-Host "  Output: $OutputPath" -ForegroundColor Cyan
    Write-Host "  Open in browser to interact" -ForegroundColor Gray
}

Write-Host ""

return @{
    Success = $true
    OutputPath = if ($Format -eq "mermaid") { $outputFile } else { $OutputPath }
    NodeCount = $graph.nodes.Count
    EdgeCount = $graph.edges.Count
}
