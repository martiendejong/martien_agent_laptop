# query-knowledge.ps1 - Unified knowledge search
# Searches ALL Claude Agent knowledge sources

param(
    [Parameter(Mandatory=$true)]
    [string]$Query,
    
    [string]$Source = "all",
    [int]$Context = 2,
    [int]$Limit = 10
)

$Sources = @{
    insights = "C:\scripts\_machine\PERSONAL_INSIGHTS.md"
    reflection = "C:\scripts\_machine\reflection.log.md"
    config = "C:\scripts\MACHINE_CONFIG.md"
    claude = "C:\scripts\CLAUDE.md"
    identity = "C:\scripts\agentidentity\CORE_IDENTITY.md"
    exec = "C:\scripts\agentidentity\cognitive-systems\EXECUTIVE_FUNCTION.md"
}

Write-Host "`nSearching for: $Query" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Gray

$totalMatches = 0

foreach ($name in $Sources.Keys) {
    if ($Source -ne "all" -and $Source -ne $name) { continue }
    
    $path = $Sources[$name]
    if (-not (Test-Path $path)) { continue }
    
    $matches = Select-String -Path $path -Pattern $Query -Context $Context -CaseSensitive:$false
    
    if ($matches.Count -gt 0) {
        Write-Host "`n[$name] $($matches.Count) match(es) in $(Split-Path $path -Leaf)" -ForegroundColor Yellow
        Write-Host ("-" * 70) -ForegroundColor Gray
        
        $shown = 0
        foreach ($match in $matches) {
            if ($Limit -gt 0 -and $shown -ge $Limit) { break }
            
            Write-Host "  Line $($match.LineNumber):" -ForegroundColor Green
            
            foreach ($line in $match.Context.PreContext) {
                Write-Host "    $line" -ForegroundColor DarkGray
            }
            
            Write-Host "  > $($match.Line)" -ForegroundColor White
            
            foreach ($line in $match.Context.PostContext) {
                Write-Host "    $line" -ForegroundColor DarkGray
            }
            
            Write-Host ""
            $shown++
            $totalMatches++
        }
    }
}

if ($totalMatches -eq 0) {
    Write-Host "`nNo matches found." -ForegroundColor Red
} else {
    Write-Host ("=" * 70) -ForegroundColor Gray
    Write-Host "Total: $totalMatches match(es)" -ForegroundColor Green
}
