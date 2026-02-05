# Context Event Bus (R22-002)
# Publish-subscribe system for context intelligence events

param(
    [Parameter(ParameterSetName='Publish')]
    [switch]$Publish,

    [Parameter(ParameterSetName='Publish')]
    [string]$EventType,

    [Parameter(ParameterSetName='Publish')]
    [string]$Data,

    [Parameter(ParameterSetName='Subscribe')]
    [switch]$Subscribe,

    [Parameter(ParameterSetName='Subscribe')]
    [string]$FilterType,

    [Parameter(ParameterSetName='Process')]
    [switch]$ProcessQueue,

    [Parameter(ParameterSetName='Status')]
    [switch]$Status
)

$KnowledgeStore = "C:\scripts\_machine\knowledge-store.yaml"

function Publish-Event {
    param(
        [string]$Type,
        [string]$EventData
    )

    $store = Get-Content $KnowledgeStore -Raw | ConvertFrom-Yaml

    $event = @{
        id = [guid]::NewGuid().ToString()
        timestamp = Get-Date -Format 'o'
        event_type = $Type
        data = $EventData
        processed = $false
    }

    if (!$store.events.queue) {
        $store.events.queue = @()
    }

    $store.events.queue += $event
    $store | ConvertTo-Yaml | Out-File -FilePath $KnowledgeStore -Encoding UTF8

    Write-Host "Published event: $Type" -ForegroundColor Green
    return $event.id
}

function Get-Events {
    param([string]$FilterByType)

    $store = Get-Content $KnowledgeStore -Raw | ConvertFrom-Yaml

    if (!$store.events.queue) {
        return @()
    }

    $events = $store.events.queue | Where-Object { !$_.processed }

    if ($FilterByType) {
        $events = $events | Where-Object { $_.event_type -eq $FilterByType }
    }

    return $events
}

function Mark-EventProcessed {
    param([string]$EventId)

    $store = Get-Content $KnowledgeStore -Raw | ConvertFrom-Yaml

    foreach ($event in $store.events.queue) {
        if ($event.id -eq $EventId) {
            $event.processed = $true
            break
        }
    }

    $store | ConvertTo-Yaml | Out-File -FilePath $KnowledgeStore -Encoding UTF8
}

function Process-EventQueue {
    Write-Host "Processing event queue..." -ForegroundColor Cyan

    $events = Get-Events

    foreach ($event in $events) {
        Write-Host "Processing: $($event.event_type)" -ForegroundColor Yellow

        # Route events to appropriate handlers
        switch ($event.event_type) {
            "prediction_success" {
                # Trigger pattern update
                Write-Host "  -> Updating patterns based on successful prediction"
                # Could call cross-session-patterns.ps1 -Mine here
            }
            "prediction_failure" {
                # Trigger weight adjustment
                Write-Host "  -> Adjusting prediction weights"
                # Could call self-improving-prediction.ps1 -UpdateWeights here
            }
            "cluster_updated" {
                # Trigger semantic search cache refresh
                Write-Host "  -> Refreshing semantic search cache"
            }
            "pattern_discovered" {
                # Trigger proactive mode check
                Write-Host "  -> Checking if proactive mode should activate"
            }
            default {
                Write-Host "  -> No handler for event type: $($event.event_type)"
            }
        }

        Mark-EventProcessed -EventId $event.id
    }

    Write-Host "Queue processing complete" -ForegroundColor Green
}

function Show-Status {
    $store = Get-Content $KnowledgeStore -Raw | ConvertFrom-Yaml

    $total = $store.events.queue.Count
    $pending = ($store.events.queue | Where-Object { !$_.processed }).Count
    $processed = $total - $pending

    Write-Host "`n=== Event Bus Status ===" -ForegroundColor Cyan
    Write-Host "Total Events: $total"
    Write-Host "Pending: $pending"
    Write-Host "Processed: $processed"

    if ($pending -gt 0) {
        Write-Host "`nPending Events:" -ForegroundColor Yellow
        $store.events.queue | Where-Object { !$_.processed } | ForEach-Object {
            Write-Host "  [$($_.timestamp)] $($_.event_type)"
        }
    }
}

# Main execution
if ($Publish -and $EventType) {
    Publish-Event -Type $EventType -EventData $Data
}
elseif ($Subscribe) {
    $events = Get-Events -FilterByType $FilterType
    $events | ConvertTo-Json -Depth 3
}
elseif ($ProcessQueue) {
    Process-EventQueue
}
elseif ($Status) {
    Show-Status
}
else {
    Write-Host "Usage: context-event-bus.ps1"
    Write-Host "  -Publish -EventType <type> [-Data <json>]  : Publish an event"
    Write-Host "  -Subscribe [-FilterType <type>]             : Get unprocessed events"
    Write-Host "  -ProcessQueue                               : Process all pending events"
    Write-Host "  -Status                                     : Show event bus status"
    Write-Host "`nEvent Types:"
    Write-Host "  prediction_success, prediction_failure, cluster_updated, pattern_discovered"
}
