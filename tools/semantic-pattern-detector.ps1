#!/usr/bin/env pwsh
# semantic-pattern-detector.ps1 - Detect patterns by INTENT, not just frequency
# Phase 1: Embedded Learning Architecture v2
# Clusters actions semantically to find higher-order patterns

param(
    [Parameter(Mandatory=$false)]
    [string]$SessionLogPath = "C:\scripts\_machine\current-session-log.jsonl",

    [Parameter(Mandatory=$false)]
    [string]$IntentTaxonomyPath = "C:\scripts\_machine\intent-taxonomy.yaml",

    [Parameter(Mandatory=$false)]
    [int]$MinClusterSize = 2,

    [Parameter(Mandatory=$false)]
    [switch]$Detailed = $false
)

if (-not (Test-Path $SessionLogPath)) {
    Write-Verbose "No session log found"
    exit 0
}

# Load intent taxonomy
$taxonomy = @{
    authentication = @("auth", "login", "credential", "token", "jwt", "password", "api-key", "secret")
    testing = @("test", "spec", "assert", "mock", "fixture", "coverage")
    debugging = @("error", "debug", "trace", "log", "exception", "fail", "bug")
    deployment = @("deploy", "build", "ci", "cd", "release", "publish", "docker")
    database = @("migration", "db", "database", "entity", "schema", "query", "sql")
    git_operations = @("commit", "branch", "merge", "pr", "pull request", "push", "checkout")
    documentation = @("readme", "docs", "documentation", "comment", "guide", "manual")
    api_development = @("api", "endpoint", "route", "controller", "service", "dto")
    frontend = @("component", "react", "ui", "css", "html", "jsx", "tsx")
    configuration = @("config", "settings", "env", "appsettings", "yaml", "json")
}

# Load custom taxonomy if exists
if (Test-Path $IntentTaxonomyPath) {
    $customTaxonomy = Get-Content $IntentTaxonomyPath | ConvertFrom-Yaml -ErrorAction SilentlyContinue
    if ($customTaxonomy) {
        $taxonomy = $customTaxonomy
    }
}

# Load session log
$logEntries = Get-Content $SessionLogPath | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
    $_ | ConvertFrom-Json
}

if ($logEntries.Count -eq 0) {
    Write-Verbose "Session log empty"
    exit 0
}

# Classify each action by intent
function Get-Intent {
    param($action, $reasoning)

    $text = "$action $reasoning".ToLower()
    $intents = @()

    foreach ($intentName in $taxonomy.Keys) {
        $keywords = $taxonomy[$intentName]
        foreach ($keyword in $keywords) {
            if ($text -match "\b$keyword\b") {
                $intents += $intentName
                break
            }
        }
    }

    if ($intents.Count -eq 0) {
        return "general"
    }

    return $intents
}

# Classify all actions
$classified = $logEntries | ForEach-Object {
    $intents = Get-Intent -action $_.action -reasoning $_.reasoning
    [PSCustomObject]@{
        timestamp = $_.timestamp
        action = $_.action
        reasoning = $_.reasoning
        intents = $intents
        outcome = $_.outcome
    }
}

# Group by intent
$intentClusters = @{}
foreach ($entry in $classified) {
    foreach ($intent in $entry.intents) {
        if (-not $intentClusters.ContainsKey($intent)) {
            $intentClusters[$intent] = @()
        }
        $intentClusters[$intent] += $entry
    }
}

# Find semantic patterns
Write-Host ""
Write-Host "🧠 SEMANTIC PATTERN DETECTION" -ForegroundColor Magenta
Write-Host "=============================" -ForegroundColor Magenta
Write-Host ""

$patternsFound = $false

foreach ($intent in $intentClusters.Keys | Sort-Object) {
    $cluster = $intentClusters[$intent]

    if ($cluster.Count -ge $MinClusterSize) {
        $patternsFound = $true

        Write-Host "📊 Intent: $intent ($($cluster.Count) actions)" -ForegroundColor Yellow

        # List unique actions in this cluster
        $uniqueActions = $cluster | Select-Object -ExpandProperty action -Unique

        foreach ($action in $uniqueActions) {
            $count = ($cluster | Where-Object { $_.action -eq $action }).Count
            Write-Host "   • $action ($count×)" -ForegroundColor Gray
        }

        # Suggest improvement
        if ($cluster.Count -ge 3) {
            Write-Host "   💡 Suggestion: Create $intent-quick-ref.md (consolidate all $intent info)" -ForegroundColor Cyan
        }

        if ($Detailed) {
            Write-Host "   Timeline:" -ForegroundColor DarkGray
            foreach ($entry in $cluster) {
                Write-Host "      $($entry.timestamp) - $($entry.action)" -ForegroundColor DarkGray
            }
        }

        Write-Host ""
    }
}

# Cross-intent patterns (actions spanning multiple intents)
Write-Host "🔗 Cross-Intent Patterns:" -ForegroundColor Cyan
$multiIntentActions = $classified | Where-Object { $_.intents.Count -gt 1 }

if ($multiIntentActions.Count -gt 0) {
    $patternsFound = $true

    foreach ($entry in $multiIntentActions) {
        $intentList = $entry.intents -join " + "
        Write-Host "   • $($entry.action) → [$intentList]" -ForegroundColor Cyan
    }
    Write-Host ""
}

# Temporal patterns (sequences within same intent)
Write-Host "⏱️  Temporal Sequences:" -ForegroundColor Green

foreach ($intent in $intentClusters.Keys | Sort-Object) {
    $cluster = $intentClusters[$intent]

    if ($cluster.Count -ge 3) {
        # Sort by timestamp
        $sorted = $cluster | Sort-Object timestamp

        # Find sequences (actions within 5 minutes = likely related)
        $sequences = @()
        $currentSeq = @($sorted[0])

        for ($i = 1; $i -lt $sorted.Count; $i++) {
            $prevTime = [DateTime]::Parse($sorted[$i-1].timestamp)
            $currTime = [DateTime]::Parse($sorted[$i].timestamp)
            $diff = ($currTime - $prevTime).TotalMinutes

            if ($diff -le 5) {
                $currentSeq += $sorted[$i]
            } else {
                if ($currentSeq.Count -ge 2) {
                    $sequences += ,@($currentSeq)
                }
                $currentSeq = @($sorted[$i])
            }
        }

        if ($currentSeq.Count -ge 2) {
            $sequences += ,@($currentSeq)
        }

        if ($sequences.Count -gt 0) {
            $patternsFound = $true
            Write-Host "   Intent: $intent" -ForegroundColor Green

            foreach ($seq in $sequences) {
                $actionChain = ($seq | Select-Object -ExpandProperty action) -join " → "
                Write-Host "      Sequence: $actionChain" -ForegroundColor Gray
            }
        }
    }
}

if (-not $patternsFound) {
    Write-Host "✅ No significant semantic patterns detected yet" -ForegroundColor Green
}

Write-Host ""

# Return structured data for programmatic use
return @{
    IntentClusters = $intentClusters
    MultiIntentActions = $multiIntentActions.Count
    TotalIntents = $intentClusters.Keys.Count
}
