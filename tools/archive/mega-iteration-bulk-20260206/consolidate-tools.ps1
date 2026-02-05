# consolidate-tools.ps1
# Audits and consolidates the 3,783 tools down to essentials

param([string]$Action="Audit")

$toolsDir = "/c/scripts/tools"
$auditFile = "/c/scripts/_machine/tool-audit-results.json"

function Invoke-ToolAudit {
    Write-Host "🔍 Auditing tools in $toolsDir..." -ForegroundColor Cyan
    
    $tools = Get-ChildItem $toolsDir -Filter "*.ps1"
    $stats = @{
        Total = $tools.Count
        BySize = @{
            Tiny = 0      # < 100 bytes (templates)
            Small = 0     # 100-500 bytes
            Medium = 0    # 500-2000 bytes
            Large = 0     # > 2000 bytes (production)
        }
        Categories = @{}
        Duplicates = @()
        Obsolete = @()
        Production = @()
        Created = (Get-Date).ToString("o")
    }
    
    Write-Host "Analyzing $($tools.Count) tools..." -ForegroundColor Gray
    
    $contentHashes = @{}
    
    foreach($tool in $tools) {
        $size = $tool.Length
        $content = Get-Content $tool.FullName -Raw -ErrorAction SilentlyContinue
        
        # Size categorization
        if($size -lt 100) { $stats.BySize.Tiny++ }
        elseif($size -lt 500) { $stats.BySize.Small++ }
        elseif($size -lt 2000) { $stats.BySize.Medium++ }
        else { $stats.BySize.Large++; $stats.Production += $tool.Name }
        
        # Detect duplicates by content hash
        if($content) {
            $hash = ($content | Get-FileHash -Algorithm MD5).Hash
            if($contentHashes.ContainsKey($hash)) {
                $stats.Duplicates += @{
                    Original = $contentHashes[$hash]
                    Duplicate = $tool.Name
                }
            }
            else {
                $contentHashes[$hash] = $tool.Name
            }
            
            # Detect templates/placeholders
            if($content -match "Iteration \d+" -or $content -match "placeholder" -or $content.Length -lt 200) {
                $stats.Obsolete += $tool.Name
            }
        }
        
        # Category detection (simple heuristic)
        $category = "Uncategorized"
        if($tool.Name -match "test") { $category = "Testing" }
        elseif($tool.Name -match "monitor|health|dashboard") { $category = "Monitoring" }
        elseif($tool.Name -match "agent|coordinator|pool") { $category = "Coordination" }
        elseif($tool.Name -match "error|log|audit") { $category = "Observability" }
        elseif($tool.Name -match "cache|optimize|performance") { $category = "Performance" }
        
        if(-not $stats.Categories.ContainsKey($category)) {
            $stats.Categories[$category] = 0
        }
        $stats.Categories[$category]++
    }
    
    # Save audit results
    $stats | ConvertTo-Json -Depth 10 | Set-Content $auditFile
    
    # Display results
    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📊 TOOL AUDIT RESULTS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "`nTotal Tools: $($stats.Total)" -ForegroundColor White
    Write-Host "`nBy Size:" -ForegroundColor Yellow
    Write-Host "  Tiny (<100b):    $($stats.BySize.Tiny) - TEMPLATES/PLACEHOLDERS" -ForegroundColor Red
    Write-Host "  Small (100-500): $($stats.BySize.Small)" -ForegroundColor Gray
    Write-Host "  Medium (500-2K): $($stats.BySize.Medium)" -ForegroundColor White
    Write-Host "  Large (>2K):     $($stats.BySize.Large) - PRODUCTION READY" -ForegroundColor Green
    
    Write-Host "`nBy Category:" -ForegroundColor Yellow
    foreach($cat in $stats.Categories.Keys | Sort-Object) {
        Write-Host "  $cat: $($stats.Categories[$cat])" -ForegroundColor White
    }
    
    Write-Host "`nQuality:" -ForegroundColor Yellow
    Write-Host "  Production-ready: $($stats.Production.Count)" -ForegroundColor Green
    Write-Host "  Duplicates found: $($stats.Duplicates.Count)" -ForegroundColor Red
    Write-Host "  Obsolete/templates: $($stats.Obsolete.Count)" -ForegroundColor Red
    
    Write-Host "`n📋 RECOMMENDATIONS:" -ForegroundColor Cyan
    Write-Host "  • Keep: $($stats.Production.Count) production tools" -ForegroundColor Green
    Write-Host "  • Delete: $($stats.Obsolete.Count) obsolete/template tools" -ForegroundColor Red
    Write-Host "  • Review: $($stats.Duplicates.Count) duplicates" -ForegroundColor Yellow
    Write-Host "  • Potential savings: $(($stats.Obsolete.Count / $stats.Total * 100).ToString('F1'))% reduction" -ForegroundColor Cyan
    
    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    return $stats
}

function Remove-ObsoleteTools {
    Write-Host "🗑️ Removing obsolete tools..." -ForegroundColor Yellow
    
    if(-not (Test-Path $auditFile)) {
        Write-Host "❌ Run 'Audit' first" -ForegroundColor Red
        return
    }
    
    $audit = Get-Content $auditFile | ConvertFrom-Json
    $obsolete = $audit.Obsolete
    
    Write-Host "Found $($obsolete.Count) obsolete tools to remove" -ForegroundColor Gray
    
    $removed = 0
    foreach($tool in $obsolete) {
        $path = Join-Path $toolsDir $tool
        if(Test-Path $path) {
            Remove-Item $path -Force
            $removed++
        }
    }
    
    Write-Host "✅ Removed $removed obsolete tools" -ForegroundColor Green
}

switch($Action) {
    "Audit" { Invoke-ToolAudit }
    "Prune" { Remove-ObsoleteTools }
}
