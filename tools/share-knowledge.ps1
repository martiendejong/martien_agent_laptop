<#
.SYNOPSIS
    Share knowledge between agents

.DESCRIPTION
    Publish learnings, patterns, and best practices for other agents:
    - Best practices (confidence 8+)
    - Bug fixes with solutions
    - Optimization patterns
    - Tool usage tips

    Other agents can import and apply this knowledge.

.PARAMETER Action
    share: Publish knowledge
    import: Import from other agents
    list: List available knowledge
    browse: Browse by type/confidence

.PARAMETER KnowledgeType
    Type: best_practice, bug_fix, optimization, pattern, tool_usage

.PARAMETER Title
    Title of the knowledge item

.PARAMETER Content
    Content/description

.PARAMETER Tags
    Comma-separated tags

.PARAMETER Confidence
    Confidence level 1-10 (default: 7)

.PARAMETER MinConfidence
    Minimum confidence for import (default: 7)

.EXAMPLE
    .\share-knowledge.ps1 -Action share -KnowledgeType best_practice -Title "Error Boundaries in React" -Content "Always wrap components in error boundaries" -Tags "react,frontend" -Confidence 8

.EXAMPLE
    .\share-knowledge.ps1 -Action import -MinConfidence 8

.EXAMPLE
    .\share-knowledge.ps1 -Action browse -KnowledgeType bug_fix
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('share', 'import', 'list', 'browse')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [ValidateSet('best_practice', 'bug_fix', 'optimization', 'pattern', 'tool_usage')]
    [string]$KnowledgeType,

    [Parameter(Mandatory=$false)]
    [string]$Title,

    [Parameter(Mandatory=$false)]
    [string]$Content,

    [Parameter(Mandatory=$false)]
    [string]$Tags,

    [Parameter(Mandatory=$false)]
    [int]$Confidence = 7,

    [Parameter(Mandatory=$false)]
    [int]$MinConfidence = 7
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Inter-Agent Knowledge Sharing" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

function Get-AgentId {
    if (Test-Path "C:\scripts\_machine\.current_agent_id") {
        return (Get-Content "C:\scripts\_machine\.current_agent_id" -Raw).Trim()
    }
    return "unknown"
}

switch ($Action) {
    'share' {
        if (-not $KnowledgeType -or -not $Title -or -not $Content) {
            Write-Host "❌ Required: -KnowledgeType, -Title, -Content" -ForegroundColor Red
            exit 1
        }

        $agentId = Get-AgentId
        $titleEscaped = $Title -replace "'", "''"
        $contentEscaped = $Content -replace "'", "''"
        $tagsEscaped = if ($Tags) { $Tags -replace "'", "''" } else { "" }
        $now = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")

        $sql = @"
INSERT INTO shared_knowledge (source_agent_id, knowledge_type, title, content, tags, confidence, shared_at)
VALUES ('$agentId', '$KnowledgeType', '$titleEscaped', '$contentEscaped', '$tagsEscaped', $Confidence, '$now');
"@

        Invoke-Sql -Sql $sql

        Write-Host "✅ Knowledge shared!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Title: $Title" -ForegroundColor White
        Write-Host "Type: $KnowledgeType" -ForegroundColor Cyan
        Write-Host "Confidence: $Confidence/10" -ForegroundColor $(if ($Confidence -ge 8) { 'Green' } else { 'Yellow' })
        Write-Host "From: $agentId" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Other agents can import with:" -ForegroundColor Yellow
        Write-Host "  .\share-knowledge.ps1 -Action import" -ForegroundColor Gray
        Write-Host ""
    }

    'import' {
        $agentId = Get-AgentId

        Write-Host "📥 Importing knowledge (confidence >= $MinConfidence)..." -ForegroundColor Cyan
        Write-Host ""

        # Get knowledge not from this agent
        $sql = @"
SELECT id, source_agent_id, knowledge_type, title, content, tags, confidence
FROM shared_knowledge
WHERE source_agent_id != '$agentId'
AND confidence >= $MinConfidence
AND (imported_by IS NULL OR imported_by NOT LIKE '%$agentId%')
ORDER BY confidence DESC, shared_at DESC
LIMIT 10;
"@

        $knowledge = Invoke-Sql -Sql $sql

        if (-not $knowledge) {
            Write-Host "✅ No new knowledge to import" -ForegroundColor Green
            Write-Host ""
            exit 0
        }

        $imported = 0
        $knowledge -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $id = $parts[0]
                $source = $parts[1]
                $type = $parts[2]
                $title = $parts[3]
                $content = $parts[4]
                $tags = $parts[5]
                $conf = $parts[6]

                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
                Write-Host "📚 $title" -ForegroundColor White
                Write-Host "   Type: $type | Confidence: $conf/10" -ForegroundColor Cyan
                Write-Host "   From: $source" -ForegroundColor Gray
                Write-Host ""
                Write-Host "   $content" -ForegroundColor White
                Write-Host ""

                if ($tags) {
                    Write-Host "   Tags: $tags" -ForegroundColor DarkGray
                    Write-Host ""
                }

                # Mark as imported
                $updateSql = @"
UPDATE shared_knowledge
SET imported_by = COALESCE(imported_by || ',', '') || '$agentId',
    import_count = import_count + 1
WHERE id = $id;
"@
                Invoke-Sql -Sql $updateSql
                $imported++
            }
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "✅ Imported $imported knowledge items" -ForegroundColor Green
        Write-Host ""
    }

    'list' {
        Write-Host "📚 Shared Knowledge Library:" -ForegroundColor Cyan
        Write-Host ""

        $sql = "SELECT knowledge_type, COUNT(*) as count, AVG(confidence) as avg_conf FROM shared_knowledge GROUP BY knowledge_type;"
        $stats = Invoke-Sql -Sql $sql

        if ($stats) {
            $stats -split "`n" | ForEach-Object {
                if ($_ -match '\|') {
                    $parts = $_ -split '\|'
                    $type = $parts[0]
                    $count = $parts[1]
                    $avgConf = [math]::Round([decimal]$parts[2], 1)

                    $icon = switch ($type) {
                        'best_practice' { '⭐' }
                        'bug_fix' { '🐛' }
                        'optimization' { '⚡' }
                        'pattern' { '🔷' }
                        'tool_usage' { '🔧' }
                        default { '📄' }
                    }

                    Write-Host "  $icon $type" -ForegroundColor White
                    Write-Host "     Count: $count | Avg Confidence: $avgConf/10" -ForegroundColor Gray
                    Write-Host ""
                }
            }
        } else {
            Write-Host "  No knowledge shared yet" -ForegroundColor Yellow
            Write-Host ""
        }

        Write-Host "Browse by type:" -ForegroundColor Cyan
        Write-Host "  .\share-knowledge.ps1 -Action browse -KnowledgeType best_practice" -ForegroundColor Gray
        Write-Host ""
    }

    'browse' {
        $whereClause = ""
        if ($KnowledgeType) {
            $whereClause = "WHERE knowledge_type = '$KnowledgeType'"
        }

        $sql = "SELECT source_agent_id, knowledge_type, title, content, confidence, shared_at FROM shared_knowledge $whereClause ORDER BY confidence DESC, shared_at DESC LIMIT 20;"
        $knowledge = Invoke-Sql -Sql $sql

        if (-not $knowledge) {
            Write-Host "No knowledge found" -ForegroundColor Yellow
            exit 0
        }

        Write-Host "📚 Knowledge Library" -ForegroundColor Cyan
        if ($KnowledgeType) {
            Write-Host "   Type: $KnowledgeType" -ForegroundColor Gray
        }
        Write-Host ""

        $knowledge -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $source = $parts[0]
                $type = $parts[1]
                $title = $parts[2]
                $content = $parts[3]
                $conf = $parts[4]
                $shared = $parts[5]

                $confColor = if ([int]$conf -ge 8) { 'Green' } elseif ([int]$conf -ge 6) { 'Yellow' } else { 'Gray' }

                Write-Host "  📖 $title" -ForegroundColor White
                Write-Host "     Confidence: $conf/10" -ForegroundColor $confColor -NoNewline
                Write-Host " | Type: $type" -ForegroundColor Gray -NoNewline
                Write-Host " | From: $source" -ForegroundColor DarkGray
                Write-Host "     $content" -ForegroundColor Gray
                Write-Host ""
            }
        }
    }
}
