# shared-knowledge-sync.ps1
# Synchronizes knowledge across multiple agents
# Enables collective learning and prevents duplicate discoveries

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Push", "Pull", "Sync", "Query", "Status")]
    [string]$Action,

    [string]$AgentId = "",
    [string]$KnowledgeType = "",  # pattern, error, solution, insight
    [string]$Content = "",
    [string]$Query = "",
    [switch]$Force
)

$script:KnowledgeBase = "C:\scripts\_machine\shared-knowledge.json"
$script:KnowledgeHistory = "C:\scripts\_machine\knowledge-history.jsonl"

function Get-SharedKnowledge {
    if (Test-Path $script:KnowledgeBase) {
        return Get-Content $script:KnowledgeBase -Raw | ConvertFrom-Json
    }
    return @{
        Patterns = @()
        Errors = @()
        Solutions = @()
        Insights = @()
        Contributors = @{}
        LastSync = $null
    }
}

function Set-SharedKnowledge {
    param($Knowledge)
    $Knowledge | ConvertTo-Json -Depth 10 | Set-Content -Path $script:KnowledgeBase -Force
}

function Add-Knowledge {
    param(
        [string]$AgentId,
        [string]$Type,
        [string]$Content
    )

    $knowledge = Get-SharedKnowledge

    $entry = @{
        Id = [guid]::NewGuid().ToString()
        Type = $Type
        Content = $Content
        ContributedBy = $AgentId
        Timestamp = (Get-Date).ToString("o")
        UsageCount = 0
        Votes = 0
    }

    # Add to appropriate collection
    switch ($Type) {
        "pattern" { $knowledge.Patterns += $entry }
        "error" { $knowledge.Errors += $entry }
        "solution" { $knowledge.Solutions += $entry }
        "insight" { $knowledge.Insights += $entry }
    }

    # Update contributor stats
    if (-not $knowledge.Contributors.ContainsKey($AgentId)) {
        $knowledge.Contributors[$AgentId] = @{
            Contributions = 0
            LastActive = (Get-Date).ToString("o")
        }
    }
    $knowledge.Contributors[$AgentId].Contributions++
    $knowledge.Contributors[$AgentId].LastActive = (Get-Date).ToString("o")

    $knowledge.LastSync = (Get-Date).ToString("o")
    Set-SharedKnowledge -Knowledge $knowledge

    # Log to history
    $historyEntry = @{
        Action = "Add"
        AgentId = $AgentId
        Type = $Type
        EntryId = $entry.Id
        Timestamp = (Get-Date).ToString("o")
    }
    $json = $historyEntry | ConvertTo-Json -Compress
    Add-Content -Path $script:KnowledgeHistory -Value $json

    Write-Host "✅ Knowledge added: $Type" -ForegroundColor Green
    Write-Host "   ID: $($entry.Id)" -ForegroundColor Gray
    Write-Host "   Contributor: $AgentId" -ForegroundColor Gray

    return $entry.Id
}

function Get-RelevantKnowledge {
    param(
        [string]$AgentId,
        [string]$QueryText,
        [string]$Type
    )

    $knowledge = Get-SharedKnowledge

    Write-Host "🔍 Searching knowledge base..." -ForegroundColor Cyan
    Write-Host "   Query: $QueryText" -ForegroundColor Gray

    $results = @()

    # Get collection to search
    $collections = if ($Type) {
        @($Type)
    } else {
        @("Patterns", "Errors", "Solutions", "Insights")
    }

    foreach ($collectionName in $collections) {
        $collection = $knowledge.$collectionName

        foreach ($entry in $collection) {
            # Simple relevance scoring (keyword matching)
            $relevanceScore = 0

            # Split query into keywords
            $keywords = $QueryText -split '\s+' | Where-Object { $_.Length -gt 2 }

            foreach ($keyword in $keywords) {
                if ($entry.Content -match [regex]::Escape($keyword)) {
                    $relevanceScore++
                }
            }

            if ($relevanceScore -gt 0) {
                $results += @{
                    Entry = $entry
                    RelevanceScore = $relevanceScore
                    Collection = $collectionName
                }
            }
        }
    }

    # Sort by relevance
    $results = $results | Sort-Object -Property RelevanceScore -Descending | Select-Object -First 10

    if ($results.Count -eq 0) {
        Write-Host "❌ No relevant knowledge found" -ForegroundColor Yellow
        return @()
    }

    Write-Host "✅ Found $($results.Count) relevant entries" -ForegroundColor Green
    Write-Host ""

    foreach ($result in $results) {
        $entry = $result.Entry
        $age = ((Get-Date) - [DateTime]$entry.Timestamp).TotalDays

        $typeEmoji = switch ($result.Collection) {
            "Patterns" { "🔄" }
            "Errors" { "❌" }
            "Solutions" { "✅" }
            "Insights" { "💡" }
            default { "📝" }
        }

        Write-Host "$typeEmoji [$($result.Collection)] (Relevance: $($result.RelevanceScore))" -ForegroundColor Cyan
        Write-Host "   $($entry.Content)" -ForegroundColor White
        Write-Host "   By: $($entry.ContributedBy) | Age: $([math]::Round($age, 1))d | Used: $($entry.UsageCount)x | Votes: $($entry.Votes)" -ForegroundColor DarkGray
        Write-Host ""

        # Increment usage count
        $entry.UsageCount++
    }

    # Save updated usage counts
    Set-SharedKnowledge -Knowledge $knowledge

    return $results
}

function Invoke-KnowledgeSync {
    param([string]$AgentId)

    Write-Host "🔄 Syncing knowledge base..." -ForegroundColor Cyan

    # Pull from reflection log
    $reflectionFile = "C:\scripts\_machine\reflection.log.md"
    if (Test-Path $reflectionFile) {
        $content = Get-Content $reflectionFile -Raw

        # Extract patterns from reflection log
        $patternMatches = [regex]::Matches($content, "\*\*Pattern \d+:(.*?)\*\*", [System.Text.RegularExpressions.RegexOptions]::Singleline)

        foreach ($match in $patternMatches | Select-Object -First 5) {
            $patternText = $match.Groups[1].Value.Trim()
            if ($patternText.Length -gt 20 -and $patternText.Length -lt 500) {
                Add-Knowledge -AgentId $AgentId -Type "pattern" -Content $patternText
            }
        }

        Write-Host "✅ Extracted patterns from reflection log" -ForegroundColor Green
    }

    # Pull from error logs
    $errorLogFile = "C:\scripts\_machine\errors.jsonl"
    if (Test-Path $errorLogFile) {
        $content = Get-Content $errorLogFile -Tail 10

        foreach ($line in $content) {
            try {
                $errorEntry = $line | ConvertFrom-Json
                if ($errorEntry.Message.Length -gt 20) {
                    Add-Knowledge -AgentId $AgentId -Type "error" -Content $errorEntry.Message
                }
            }
            catch {
                # Skip malformed entries
            }
        }

        Write-Host "✅ Extracted errors from error log" -ForegroundColor Green
    }

    Write-Host "✅ Knowledge sync complete" -ForegroundColor Green
}

function Show-KnowledgeStatus {
    $knowledge = Get-SharedKnowledge

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🧠 SHARED KNOWLEDGE BASE STATUS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    Write-Host "`n📊 Statistics:" -ForegroundColor Cyan
    Write-Host "   Patterns: $($knowledge.Patterns.Count)" -ForegroundColor White
    Write-Host "   Errors: $($knowledge.Errors.Count)" -ForegroundColor White
    Write-Host "   Solutions: $($knowledge.Solutions.Count)" -ForegroundColor White
    Write-Host "   Insights: $($knowledge.Insights.Count)" -ForegroundColor White
    Write-Host "   Last sync: $($knowledge.LastSync)" -ForegroundColor Gray

    Write-Host "`n👥 Contributors: $($knowledge.Contributors.Count)" -ForegroundColor Cyan

    $topContributors = $knowledge.Contributors.GetEnumerator() | Sort-Object { $_.Value.Contributions } -Descending | Select-Object -First 5

    foreach ($contributor in $topContributors) {
        Write-Host "   $($contributor.Key): $($contributor.Value.Contributions) contributions" -ForegroundColor White
        Write-Host "      Last active: $($contributor.Value.LastActive)" -ForegroundColor DarkGray
    }

    # Show top patterns by usage
    Write-Host "`n🔥 Top Patterns (by usage):" -ForegroundColor Cyan
    $topPatterns = $knowledge.Patterns | Sort-Object -Property UsageCount -Descending | Select-Object -First 3

    foreach ($pattern in $topPatterns) {
        Write-Host "   [$($pattern.UsageCount)x] $($pattern.Content.Substring(0, [Math]::Min(80, $pattern.Content.Length)))" -ForegroundColor White
    }

    # Show recent additions
    Write-Host "`n🆕 Recent Additions:" -ForegroundColor Cyan
    $allEntries = @()
    $allEntries += $knowledge.Patterns | ForEach-Object { @{ Type = "Pattern"; Entry = $_ } }
    $allEntries += $knowledge.Errors | ForEach-Object { @{ Type = "Error"; Entry = $_ } }
    $allEntries += $knowledge.Solutions | ForEach-Object { @{ Type = "Solution"; Entry = $_ } }
    $allEntries += $knowledge.Insights | ForEach-Object { @{ Type = "Insight"; Entry = $_ } }

    $recent = $allEntries | Sort-Object { [DateTime]$_.Entry.Timestamp } -Descending | Select-Object -First 5

    foreach ($item in $recent) {
        $age = ((Get-Date) - [DateTime]$item.Entry.Timestamp).TotalHours
        Write-Host "   [$([math]::Round($age, 1))h ago] $($item.Type): $($item.Entry.Content.Substring(0, [Math]::Min(60, $item.Entry.Content.Length)))..." -ForegroundColor Gray
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

# Main logic
switch ($Action) {
    "Push" {
        if (-not $AgentId -or -not $KnowledgeType -or -not $Content) {
            Write-Host "❌ Push requires -AgentId, -KnowledgeType, and -Content parameters" -ForegroundColor Red
            exit 1
        }

        $entryId = Add-Knowledge -AgentId $AgentId -Type $KnowledgeType -Content $Content
        Write-Host "✅ Knowledge ID: $entryId" -ForegroundColor Green
        exit 0
    }

    "Pull" {
        if (-not $AgentId) {
            Write-Host "❌ Pull requires -AgentId parameter" -ForegroundColor Red
            exit 1
        }

        # For now, just show all knowledge
        Show-KnowledgeStatus
        exit 0
    }

    "Sync" {
        if (-not $AgentId) {
            Write-Host "❌ Sync requires -AgentId parameter" -ForegroundColor Red
            exit 1
        }

        Invoke-KnowledgeSync -AgentId $AgentId
        exit 0
    }

    "Query" {
        if (-not $AgentId -or -not $Query) {
            Write-Host "❌ Query requires -AgentId and -Query parameters" -ForegroundColor Red
            exit 1
        }

        $results = Get-RelevantKnowledge -AgentId $AgentId -QueryText $Query -Type $KnowledgeType
        exit 0
    }

    "Status" {
        Show-KnowledgeStatus
        exit 0
    }
}
