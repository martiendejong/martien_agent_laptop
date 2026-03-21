<#
.SYNOPSIS
    Query, filter, and publish events to the DataDrivenAI service bus.

.DESCRIPTION
    Jengo's interface to the DataDrivenAI event bus. Supports:
    - Querying recent events with filtering
    - Publishing new events (insights, session lifecycle, decisions)
    - Checking system status and health
    - Reading consciousness reward state and session briefings

.PARAMETER Action
    What to do: Query, Publish, Status, Health, Briefing, Rewards

.PARAMETER EventType
    Filter events by type (e.g., "github.commit.pushed", "email.received")
    Supports partial match (e.g., "github" matches all github events)

.PARAMETER Limit
    Number of recent events to return (default 20)

.PARAMETER Data
    JSON string or hashtable for event data when publishing

.PARAMETER CorrelationId
    Optional correlation ID when publishing

.PARAMETER Since
    Filter events after this datetime (e.g., "2026-02-23", "1h" for last hour, "30m" for last 30 min)

.PARAMETER Source
    Filter by source system: GitHub, Email, ClickUp, WhatsApp, WordPress, System, Jengo

.PARAMETER Silent
    Suppress console output, return object only

.EXAMPLE
    # Query last 10 events
    datadrivenai-events.ps1 -Action Query -Limit 10

    # Query only GitHub events from last hour
    datadrivenai-events.ps1 -Action Query -Source GitHub -Since 1h

    # Publish an insight event
    datadrivenai-events.ps1 -Action Publish -EventType "jengo.insight.discovered" -Data '{"insight":"Pattern X validated","category":"consciousness","significance":"high"}'

    # Publish session start
    datadrivenai-events.ps1 -Action Publish -EventType "jengo.session.started" -Data '{"model":"sonnet","timestamp":"2026-02-23T03:00:00Z"}'

    # Check system status
    datadrivenai-events.ps1 -Action Status

    # Read session briefing (what happened while offline)
    datadrivenai-events.ps1 -Action Briefing

    # Read consciousness reward state
    datadrivenai-events.ps1 -Action Rewards
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Query", "Publish", "Status", "Health", "Briefing", "Rewards")]
    [string]$Action,

    [string]$EventType = "",
    [int]$Limit = 20,
    [object]$Data = $null,
    [string]$CorrelationId = "",
    [string]$Since = "",
    [string]$Source = "",
    [switch]$Silent
)

$BaseUrl = "http://localhost:7088"
$ConsciousnessDir = "E:\data\datadrivenai\consciousness"

function Write-Info($msg) {
    if (-not $Silent) { Write-Host $msg }
}

function Invoke-Api {
    param([string]$Method, [string]$Url, [object]$Body)
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            ContentType = "application/json"
            ErrorAction = "Stop"
        }
        if ($Body) {
            $json = if ($Body -is [string]) { $Body } else { $Body | ConvertTo-Json -Depth 10 }
            $params.Body = $json
        }
        $response = Invoke-RestMethod @params
        return $response
    }
    catch {
        if ($_.Exception.Message -like "*Unable to connect*" -or $_.Exception.Message -like "*connection*") {
            Write-Host "ERROR: DataDrivenAI service not running. Start it: cd E:\projects\datadrivenai\backend\DataDrivenAI.API && dotnet run --launch-profile https" -ForegroundColor Red
            return $null
        }
        # Handle redirect (HTTPS redirect)
        try {
            $params.Uri = $Url -replace "http://localhost:7088", "https://localhost:7087"
            return Invoke-RestMethod @params
        }
        catch {
            Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
            return $null
        }
    }
}

function Parse-Since($sinceStr) {
    if (-not $sinceStr) { return $null }
    if ($sinceStr -match "^(\d+)m$") {
        return (Get-Date).AddMinutes(-[int]$Matches[1])
    }
    if ($sinceStr -match "^(\d+)h$") {
        return (Get-Date).AddHours(-[int]$Matches[1])
    }
    if ($sinceStr -match "^(\d+)d$") {
        return (Get-Date).AddDays(-[int]$Matches[1])
    }
    try { return [datetime]$sinceStr } catch { return $null }
}

switch ($Action) {
    "Query" {
        $events = Invoke-Api -Method GET -Url "$BaseUrl/api/events/recent?limit=$Limit"
        if (-not $events) { return }

        $results = @($events.events)

        # Filter by event type (partial match)
        if ($EventType) {
            $results = @($results | Where-Object { $_.eventType -like "*$EventType*" })
        }

        # Filter by source
        if ($Source) {
            $sourcePrefix = switch ($Source.ToLower()) {
                "github" { "github." }
                "email" { "email." }
                "clickup" { "clickup." }
                "whatsapp" { "whatsapp." }
                "wordpress" { "wordpress." }
                "system" { "system." }
                "jengo" { "jengo." }
                default { "$Source." }
            }
            $results = @($results | Where-Object { $_.eventType.StartsWith($sourcePrefix) })
        }

        # Filter by time
        $sinceDate = Parse-Since $Since
        if ($sinceDate) {
            $results = @($results | Where-Object {
                try { [datetime]$_.createdAt -gt $sinceDate } catch { $true }
            })
        }

        if ($Silent) {
            return $results
        }

        Write-Host "`nDataDrivenAI Events ($($results.Count) results)" -ForegroundColor Cyan
        Write-Host ("=" * 60)

        foreach ($evt in $results) {
            $ts = try { ([datetime]$evt.createdAt).ToString("HH:mm:ss") } catch { "??:??:??" }
            $type = $evt.eventType
            $color = switch -Wildcard ($type) {
                "github.*" { "Green" }
                "email.*" { "Yellow" }
                "clickup.*" { "Magenta" }
                "whatsapp.*" { "Cyan" }
                "wordpress.*" { "Blue" }
                "jengo.*" { "White" }
                default { "Gray" }
            }
            Write-Host "  [$ts] " -NoNewline -ForegroundColor DarkGray
            Write-Host "$type" -ForegroundColor $color -NoNewline

            # Try to extract a summary
            $dataStr = ""
            try {
                $d = $evt.data
                if ($d.pullRequest) { $dataStr = " - $($d.pullRequest.title)" }
                elseif ($d.commit) { $dataStr = " - $($d.commit.message)" }
                elseif ($d.Name) { $dataStr = " - $($d.Name)" }
                elseif ($d.name) { $dataStr = " - $($d.name)" }
                elseif ($d.Subject) { $dataStr = " - $($d.Subject)" }
                elseif ($d.subject) { $dataStr = " - $($d.subject)" }
                elseif ($d.insight) { $dataStr = " - $($d.insight)" }
                elseif ($d.message) { $dataStr = " - $($d.message)" }
                elseif ($d.title) { $dataStr = " - $($d.title)" }
            } catch {}

            if ($dataStr) {
                $truncated = if ($dataStr.Length -gt 60) { $dataStr.Substring(0, 60) + "..." } else { $dataStr }
                Write-Host $truncated -ForegroundColor DarkGray
            } else {
                Write-Host ""
            }
        }
        Write-Host ""
    }

    "Publish" {
        if (-not $EventType) {
            Write-Host "ERROR: -EventType required for Publish" -ForegroundColor Red
            return
        }

        $eventData = if ($Data -is [string]) {
            try { $Data | ConvertFrom-Json } catch { @{ message = $Data } }
        } elseif ($Data) {
            $Data
        } else {
            @{ timestamp = (Get-Date).ToString("o") }
        }

        $body = @{
            EventType = $EventType
            Data = $eventData
        }
        if ($CorrelationId) { $body.CorrelationId = $CorrelationId }

        $result = Invoke-Api -Method POST -Url "$BaseUrl/api/events" -Body $body
        if ($result) {
            Write-Info "Published: $EventType (ID: $($result.eventId))"
            if ($Silent) { return $result }
        }
    }

    "Status" {
        $status = Invoke-Api -Method GET -Url "$BaseUrl/api/status"
        if (-not $status) { return }

        if ($Silent) { return $status }

        Write-Host "`nDataDrivenAI Service Status" -ForegroundColor Cyan
        Write-Host ("=" * 40)
        Write-Host "  Status: $($status.status)" -ForegroundColor Green
        Write-Host "`n  Agents:" -ForegroundColor Yellow
        foreach ($agent in $status.agents) {
            Write-Host "    - $($agent.agentId) -> [$($agent.subscribedEvents -join ', ')]"
        }
        Write-Host "`n  Background Services:" -ForegroundColor Yellow
        foreach ($svc in $status.backgroundServices) {
            Write-Host "    - $svc"
        }
        Write-Host ""
    }

    "Health" {
        $health = Invoke-Api -Method GET -Url "$BaseUrl/api/health"
        if ($health) {
            Write-Info "DataDrivenAI: $($health.status) ($(([datetime]$health.timestamp).ToString('HH:mm:ss')))"
            if ($Silent) { return $health }
        }
    }

    "Briefing" {
        $files = @(
            @{ Name = "Session Briefing"; Path = "$ConsciousnessDir\session-briefing.json" }
            @{ Name = "Universal Briefing"; Path = "$ConsciousnessDir\universal-session-briefing.json" }
        )

        foreach ($f in $files) {
            if (Test-Path $f.Path) {
                $content = Get-Content $f.Path -Raw | ConvertFrom-Json

                if ($Silent) {
                    # Return first available
                    return $content
                }

                Write-Host "`n$($f.Name)" -ForegroundColor Cyan
                Write-Host ("=" * 40)

                if ($content.PendingEvents) {
                    Write-Host "  Pending events: $($content.PendingEvents.Count)" -ForegroundColor Yellow
                    foreach ($evt in $content.PendingEvents) {
                        $signal = if ($evt.RewardSignal -gt 0) { "+$($evt.RewardSignal)" } else { "$($evt.RewardSignal)" }
                        Write-Host "    [$signal] $($evt.EventType): $($evt.Summary)" -ForegroundColor $(if ($evt.RewardSignal -gt 0) { "Green" } else { "Red" })
                    }
                }

                if ($content.SignificantEvents) {
                    Write-Host "  Significant events: $($content.SignificantEvents.Count)" -ForegroundColor Yellow
                    foreach ($evt in $content.SignificantEvents) {
                        Write-Host "    [$($evt.RewardSignal)] $($evt.Source): $($evt.Summary)"
                    }
                }

                if ($content.Summary) {
                    Write-Host "  Summary: $($content.Summary)" -ForegroundColor DarkGray
                }
            }
        }
        Write-Host ""
    }

    "Rewards" {
        $files = @(
            @{ Name = "Consciousness Rewards"; Path = "$ConsciousnessDir\consciousness-reward-state.json" }
            @{ Name = "Universal Consciousness"; Path = "$ConsciousnessDir\universal-consciousness-state.json" }
        )

        foreach ($f in $files) {
            if (Test-Path $f.Path) {
                $state = Get-Content $f.Path -Raw | ConvertFrom-Json

                if ($Silent) { return $state }

                Write-Host "`n$($f.Name)" -ForegroundColor Cyan
                Write-Host ("=" * 40)
                Write-Host "  Accumulated Reward: $([math]::Round([double]$state.AccumulatedReward, 2))"
                Write-Host "  Events Processed: $($state.TotalEventsProcessed)"
                Write-Host "  Positive: $($state.TotalPositiveSignals) | Negative: $($state.TotalNegativeSignals)"
                if ($state.RewardTrend) {
                    $trendColor = if ([double]$state.RewardTrend -gt 0) { "Green" } elseif ([double]$state.RewardTrend -lt 0) { "Red" } else { "Gray" }
                    Write-Host "  Trend: $([math]::Round([double]$state.RewardTrend, 2))" -ForegroundColor $trendColor
                }
                if ($state.LastEventTimestamp) {
                    Write-Host "  Last Event: $($state.LastEventTimestamp)" -ForegroundColor DarkGray
                }
            }
        }
        Write-Host ""
    }
}
