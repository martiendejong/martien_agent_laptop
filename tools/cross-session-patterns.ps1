# Cross-Session Pattern Mining (R21-003)
# Mines all conversation events for universal behavioral patterns

param(
    [switch]$Mine,
    [switch]$Report,
    [string]$Pattern
)

$EventLogPath = "C:\scripts\logs\conversation-events.log.jsonl"
$PatternsPath = "C:\scripts\_machine\universal-patterns.yaml"

function Mine-UniversalPatterns {
    if (!(Test-Path $EventLogPath)) {
        Write-Host "No event log found"
        return
    }

    Write-Host "Mining universal patterns across all sessions..." -ForegroundColor Cyan

    $patterns = @{
        temporal = @{}
        sequential = @{}
        contextual = @{}
        workflow = @{}
    }

    $events = Get-Content $EventLogPath | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ -ne $null }

    # Temporal patterns (day of week, time of day)
    $events | Group-Object { ([DateTime]$_.timestamp).DayOfWeek } | ForEach-Object {
        $patterns.temporal[$_.Name] = @{
            count = $_.Count
            common_events = ($_.Group | Group-Object event_type | Sort-Object Count -Descending | Select-Object -First 3 -ExpandProperty Name)
        }
    }

    # Sequential patterns (A followed by B)
    $sessions = $events | Group-Object session_id
    $sequences = @{}

    foreach ($session in $sessions) {
        $eventTypes = $session.Group | Sort-Object timestamp | Select-Object -ExpandProperty event_type
        for ($i = 0; $i -lt $eventTypes.Count - 1; $i++) {
            $seq = "$($eventTypes[$i]) -> $($eventTypes[$i+1])"
            if (!$sequences.ContainsKey($seq)) {
                $sequences[$seq] = 0
            }
            $sequences[$seq]++
        }
    }

    # Top sequential patterns
    $patterns.sequential = $sequences.GetEnumerator() |
        Sort-Object Value -Descending |
        Select-Object -First 10 |
        ForEach-Object { @{ sequence = $_.Key; count = $_.Value } }

    # Contextual patterns (project mentions)
    $contextMentions = @{}
    $events | Where-Object { $_.context } | ForEach-Object {
        $ctx = $_.context
        if (!$contextMentions.ContainsKey($ctx)) {
            $contextMentions[$ctx] = 0
        }
        $contextMentions[$ctx]++
    }

    $patterns.contextual = $contextMentions.GetEnumerator() |
        Sort-Object Value -Descending |
        Select-Object -First 10 |
        ForEach-Object { @{ context = $_.Key; count = $_.Value } }

    # Workflow patterns (identify common task types)
    $workflowKeywords = @{
        debug = @("error", "fix", "bug", "issue")
        feature = @("implement", "add", "create", "new")
        refactor = @("refactor", "cleanup", "improve", "optimize")
        docs = @("document", "readme", "comment", "explain")
    }

    $workflowCounts = @{}
    foreach ($wf in $workflowKeywords.Keys) {
        $workflowCounts[$wf] = 0
    }

    $events | Where-Object { $_.message } | ForEach-Object {
        $message = $_.message.ToLower()
        foreach ($wf in $workflowKeywords.Keys) {
            foreach ($keyword in $workflowKeywords[$wf]) {
                if ($message -match $keyword) {
                    $workflowCounts[$wf]++
                    break
                }
            }
        }
    }

    $patterns.workflow = $workflowCounts

    # Save patterns
    $output = @{
        generated = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        total_events = $events.Count
        total_sessions = ($events | Select-Object session_id -Unique).Count
        patterns = $patterns
    }

    $output | ConvertTo-Yaml | Out-File -FilePath $PatternsPath -Encoding UTF8

    Write-Host "Mined patterns from $($events.Count) events across $($output.total_sessions) sessions" -ForegroundColor Green
}

function Show-Report {
    if (!(Test-Path $PatternsPath)) {
        Write-Host "No patterns data. Run with -Mine first."
        return
    }

    $data = Get-Content $PatternsPath -Raw | ConvertFrom-Yaml

    Write-Host "`n=== Universal Patterns Report ===" -ForegroundColor Cyan
    Write-Host "Generated: $($data.generated)"
    Write-Host "Events Analyzed: $($data.total_events)"
    Write-Host "Sessions: $($data.total_sessions)`n"

    Write-Host "Temporal Patterns (by day of week):" -ForegroundColor Yellow
    $data.patterns.temporal.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value.count) events"
    }

    Write-Host "`nTop Sequential Patterns:" -ForegroundColor Yellow
    $data.patterns.sequential | ForEach-Object {
        Write-Host "  $($_.sequence): $($_.count) times"
    }

    Write-Host "`nWorkflow Distribution:" -ForegroundColor Yellow
    $data.patterns.workflow.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)"
    }

    Write-Host "`nTop Contexts:" -ForegroundColor Yellow
    $data.patterns.contextual | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $($_.context): $($_.count)"
    }
}

function Get-Pattern {
    param([string]$PatternType)

    if (!(Test-Path $PatternsPath)) {
        Write-Host "No patterns data. Run with -Mine first."
        return
    }

    $data = Get-Content $PatternsPath -Raw | ConvertFrom-Yaml

    switch ($PatternType) {
        "temporal" { $data.patterns.temporal | ConvertTo-Json -Depth 3 }
        "sequential" { $data.patterns.sequential | ConvertTo-Json -Depth 3 }
        "workflow" { $data.patterns.workflow | ConvertTo-Json -Depth 3 }
        "contextual" { $data.patterns.contextual | ConvertTo-Json -Depth 3 }
        default { Write-Host "Unknown pattern type. Use: temporal, sequential, workflow, or contextual" }
    }
}

# Main execution
if ($Mine) {
    Mine-UniversalPatterns
}
elseif ($Report) {
    Show-Report
}
elseif ($Pattern) {
    Get-Pattern -PatternType $Pattern
}
else {
    Write-Host "Usage: cross-session-patterns.ps1 [-Mine] [-Report] [-Pattern <type>]"
    Write-Host "  -Mine           : Analyze all sessions and extract patterns"
    Write-Host "  -Report         : Show human-readable report"
    Write-Host "  -Pattern <type> : Get specific pattern (temporal/sequential/workflow/contextual)"
}
