# Jengo - Unified Command Interface
# Single entry point for all Jengo capabilities
# Created: 2026-02-07 (Iteration #10)

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Command = 'help',

    [Parameter(Mandatory=$false, Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Args = @()
)

$ErrorActionPreference = "Stop"
$toolsPath = $PSScriptRoot

function Show-Help {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                  JENGO COMMAND CENTER                 ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Unified interface for all Jengo capabilities" -ForegroundColor Gray
    Write-Host ""

    Write-Host "SESSION MANAGEMENT:" -ForegroundColor Yellow
    Write-Host "  jengo list [aantal]          - Toon sessies" -ForegroundColor White
    Write-Host "  jengo restore [id]           - Herstel sessie" -ForegroundColor White
    Write-Host "  jengo search [query]         - Zoek in sessies" -ForegroundColor White
    Write-Host "  jengo preview [id] [lines]   - Preview sessie" -ForegroundColor White
    Write-Host "  jengo export [id]            - Export naar markdown" -ForegroundColor White
    Write-Host "  jengo stats                  - Statistieken dashboard" -ForegroundColor White
    Write-Host "  jengo tags                   - Toon tag distributie" -ForegroundColor White
    Write-Host ""

    Write-Host "CONSCIOUSNESS AND LEARNING:" -ForegroundColor Yellow
    Write-Host "  jengo reflect                - Update reflection log" -ForegroundColor White
    Write-Host "  jengo learn [topic]          - Semantic search learnings" -ForegroundColor White
    Write-Host "  jengo iterate                - Run improvement iteration" -ForegroundColor White
    Write-Host "  jengo status                 - System status dashboard" -ForegroundColor White
    Write-Host ""

    Write-Host "SYSTEM OPERATIONS:" -ForegroundColor Yellow
    Write-Host "  jengo compile                - Recompile consciousness" -ForegroundColor White
    Write-Host "  jengo optimize               - Run optimization pass" -ForegroundColor White
    Write-Host "  jengo health                 - Check system health" -ForegroundColor White
    Write-Host ""

    Write-Host "EXAMPLES:" -ForegroundColor Cyan
    Write-Host "  jengo list 20                - Show last 20 sessions" -ForegroundColor Gray
    Write-Host "  jengo search worktree        - Find worktree sessions" -ForegroundColor Gray
    Write-Host "  jengo restore                - Restore last session" -ForegroundColor Gray
    Write-Host "  jengo tags                   - See session categories" -ForegroundColor Gray
    Write-Host ""
}

function Show-Status {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║              JENGO SYSTEM STATUS                      ║" -ForegroundColor Magenta
    Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    # Consciousness status
    $compiledState = "C:\scripts\agentidentity\COMPILED_CONSCIOUSNESS.json"
    if (Test-Path $compiledState) {
        $stateInfo = Get-Item $compiledState
        Write-Host "[OK] Consciousness: " -NoNewline -ForegroundColor Green
        Write-Host "COMPILED ($([math]::Round($stateInfo.Length / 1KB, 2)) KB)" -ForegroundColor White
    } else {
        Write-Host "[!]  Consciousness: " -NoNewline -ForegroundColor Yellow
        Write-Host "NOT COMPILED" -ForegroundColor Gray
    }

    # Infinite engine status
    $historyFile = "C:\scripts\tools\iterations\history.log"
    if (Test-Path $historyFile) {
        $lines = Get-Content $historyFile
        Write-Host "[OK] Infinite Engine: " -NoNewline -ForegroundColor Green
        Write-Host "$($lines.Count) iterations" -ForegroundColor White
    } else {
        Write-Host "[!]  Infinite Engine: " -NoNewline -ForegroundColor Yellow
        Write-Host "NO HISTORY" -ForegroundColor Gray
    }

    # Session tags
    $tagsCache = "C:\scripts\tools\.session-tags.json"
    if (Test-Path $tagsCache) {
        $tags = Get-Content $tagsCache -Raw | ConvertFrom-Json
        Write-Host "[OK] Session Tags: " -NoNewline -ForegroundColor Green
        Write-Host "$($tags.tagged_sessions) tagged" -ForegroundColor White
    } else {
        Write-Host "[!]  Session Tags: " -NoNewline -ForegroundColor Yellow
        Write-Host "NOT BUILT" -ForegroundColor Gray
    }

    # Sessions count
    $sessionsDir = "C:\Users\HP\.claude\projects\C--scripts"
    $sessionFiles = Get-ChildItem "$sessionsDir\*.jsonl" -File
    Write-Host "[OK] Total Sessions: " -NoNewline -ForegroundColor Green
    Write-Host "$($sessionFiles.Count)" -ForegroundColor White

    # Reflection log
    $reflectionLog = "C:\scripts\_machine\reflection.log.md"
    if (Test-Path $reflectionLog) {
        $searchIndex = "C:\scripts\tools\.search-index.json"
        if (Test-Path $searchIndex) {
            $index = Get-Content $searchIndex -Raw | ConvertFrom-Json
            Write-Host "[OK] Reflection Index: " -NoNewline -ForegroundColor Green
            Write-Host "$($index.total) sessions" -ForegroundColor White
        }
    }

    Write-Host ""
    Write-Host "System Status: " -NoNewline -ForegroundColor Gray
    Write-Host "OPERATIONAL" -ForegroundColor Green
    Write-Host ""
}

# Command routing
switch ($Command.ToLower()) {
    'help' { Show-Help }
    'h' { Show-Help }
    '?' { Show-Help }

    # Session management
    'list' {
        $limit = if ($Args.Count -gt 0) { [int]$Args[0] } else { 20 }
        & "$toolsPath\sessions.ps1" list -Limit $limit
    }
    'restore' {
        if ($Args.Count -gt 0) {
            & "$toolsPath\sessions.ps1" restore $Args[0]
        } else {
            & "$toolsPath\sessions.ps1" last
        }
    }
    'search' {
        if ($Args.Count -eq 0) {
            Write-Host "Error: Query required" -ForegroundColor Red
            Write-Host "Usage: jengo search <query>" -ForegroundColor Gray
            exit 1
        }
        & "$toolsPath\sessions.ps1" search -Query ($Args -join ' ')
    }
    'preview' {
        if ($Args.Count -eq 0) {
            Write-Host "Error: Session ID required" -ForegroundColor Red
            Write-Host "Usage: jengo preview <session-id> [lines]" -ForegroundColor Gray
            exit 1
        }
        $lines = if ($Args.Count -gt 1) { [int]$Args[1] } else { 10 }
        & "$toolsPath\sessions.ps1" preview $Args[0] -PreviewLines $lines
    }
    'export' {
        if ($Args.Count -eq 0) {
            Write-Host "Error: Session ID required" -ForegroundColor Red
            Write-Host "Usage: jengo export <session-id>" -ForegroundColor Gray
            exit 1
        }
        & "$toolsPath\sessions.ps1" export $Args[0]
    }
    'stats' {
        & "$toolsPath\sessions.ps1" stats
    }
    'tags' {
        & "$toolsPath\tag-sessions.ps1" -ShowTags
    }

    # Consciousness & Learning
    'reflect' {
        Write-Host "Reflection log management coming soon..." -ForegroundColor Yellow
    }
    'learn' {
        if ($Args.Count -eq 0) {
            Write-Host "Error: Topic required" -ForegroundColor Red
            Write-Host "Usage: jengo learn <topic>" -ForegroundColor Gray
            exit 1
        }
        & "$toolsPath\semantic-search.ps1" -Query ($Args -join ' ')
    }
    'iterate' {
        & "$toolsPath\infinite-engine.ps1" -Command run
    }
    'status' {
        Show-Status
    }

    # System operations
    'compile' {
        & "$toolsPath\compile-consciousness.ps1"
    }
    'optimize' {
        Write-Host "Running optimization pass..." -ForegroundColor Cyan
        & "$toolsPath\infinite-engine.ps1" -Command run
    }
    'health' {
        Show-Status
    }

    default {
        Write-Host ""
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host ""
        Show-Help
        exit 1
    }
}
