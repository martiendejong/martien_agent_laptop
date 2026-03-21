<#
.SYNOPSIS
Consciousness Bridge - DataDrivenAI Event Subscriber

.DESCRIPTION
Subscribes to DataDrivenAI event stream and triggers consciousness actions.
REUSES existing ClickUpReaderService events instead of duplicating polling logic.

.NOTES
Created: 2026-02-28
Integration: DataDrivenAI API (localhost:7087)
#>

param(
    [ValidateSet('Subscribe', 'ProcessEvent', 'TestConnection')]
    [string]$Action = 'Subscribe',

    [hashtable]$Event,
    [switch]$Silent
)

$ErrorActionPreference = 'Stop'

# Configuration
$dataDrivenAIUrl = "https://localhost:7087"
$consciousnessCoreTool = "C:\scripts\agentidentity\consciousness-core-v2.ps1"
$learningEngineTool = "C:\scripts\tools\clickup-learning-engine.ps1"

# Test DataDrivenAI connection
function Test-DataDrivenAIConnection {
    try {
        $response = Invoke-RestMethod -Uri "$dataDrivenAIUrl/api/health" -Method Get -SkipCertificateCheck -TimeoutSec 5
        Write-Host "[OK] DataDrivenAI is running" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Warning "DataDrivenAI not running at $dataDrivenAIUrl"
        Write-Warning "Start it first: cd E:\projects\datadrivenai\backend\DataDrivenAI.API && dotnet run"
        return $false
    }
}

# Process ClickUp event from DataDrivenAI
function Invoke-ClickUpEventAction {
    param($Event)

    $eventType = $Event.EventType
    $data = $Event.Data

    Write-Host "`n[EVENT] $eventType" -ForegroundColor Cyan
    Write-Host "  Task: $($data.task_id)" -ForegroundColor Gray

    switch ($eventType) {
        'clickup.task.created' {
            # OnClickUpTaskAssigned equivalent
            Write-Host "  [Action] OnClickUpTaskAssigned" -ForegroundColor Yellow

            # Perception: Set attention
            if ($data.project) {
                Write-Host "    - Setting attention to project: $($data.project)"
            }

            # Prediction: Estimate complexity
            $complexity = 5  # Default
            if ($data.description) {
                $complexity = if ($data.description.Length -gt 500) { 7 }
                             elseif ($data.description.Length -gt 200) { 5 }
                             else { 3 }
            }
            Write-Host "    - Estimated complexity: $complexity/10"

            # Social: Detect urgency
            if ($data.description -match 'urgent|asap|critical|blocker') {
                Write-Host "    - URGENT task detected" -ForegroundColor Red
            }

            # Save briefing
            $briefing = @{
                TaskId = $data.task_id
                Project = $data.project
                Complexity = $complexity
                Timestamp = (Get-Date).ToString('o')
            }

            $briefingFile = "C:\scripts\agentidentity\state\clickup-task-briefings.jsonl"
            $briefing | ConvertTo-Json -Compress | Add-Content $briefingFile
        }

        'clickup.task.status.changed' {
            $newStatus = $data.new_status

            if ($newStatus -eq 'busy' -or $newStatus -eq 'in progress') {
                # OnClickUpTaskStarted equivalent
                Write-Host "  [Action] OnClickUpTaskStarted" -ForegroundColor Yellow

                # Clarity check
                $clarityScore = 0.5
                if ($data.description -and $data.description.Length -gt 100) {
                    $clarityScore += 0.2
                }

                Write-Host "    - Clarity score: $([Math]::Round($clarityScore * 100))%"

                if ($clarityScore -lt 0.5) {
                    Write-Host "    - LOW CLARITY - recommend clarification" -ForegroundColor Red
                }
            }
            elseif ($newStatus -eq 'done' -or $newStatus -eq 'complete') {
                # OnClickUpTaskCompleted equivalent
                Write-Host "  [Action] OnClickUpTaskCompleted" -ForegroundColor Green

                # Trigger learning engine
                if ($data.actual_hours) {
                    Write-Host "    - Extracting learnings..."

                    $taskData = @{
                        type = $data.project
                        complexity = if ($data.complexity) { $data.complexity } else { 5 }
                        predicted_hours = if ($data.predicted_hours) { $data.predicted_hours } else { 2.0 }
                        actual_hours = $data.actual_hours
                        quality = if ($data.quality) { $data.quality } else { 0.8 }
                        outcome = 'success'
                    }

                    try {
                        & $learningEngineTool -Action ExtractPattern -TaskId $data.task_id -TaskData $taskData
                        Write-Host "    - Learning extracted" -ForegroundColor Green
                    }
                    catch {
                        Write-Warning "Failed to extract learning: $_"
                    }
                }

                # Thermodynamics: Cooling event
                Write-Host "    - Temperature decreased (success)"
            }
            elseif ($newStatus -eq 'blocked') {
                # OnClickUpTaskBlocked equivalent
                Write-Host "  [Action] OnClickUpTaskBlocked" -ForegroundColor Red

                # Emotion: Frustration
                Write-Host "    - Emotional state: FRUSTRATED"

                # Memory: Log blocker
                $blocker = @{
                    TaskId = $data.task_id
                    Reason = if ($data.reason) { $data.reason } else { 'unknown' }
                    Timestamp = (Get-Date).ToString('o')
                }

                $blockerFile = "C:\scripts\agentidentity\state\clickup-blockers.jsonl"
                $blocker | ConvertTo-Json -Compress | Add-Content $blockerFile
            }
        }

        'clickup.task.updated' {
            # Log update
            Write-Host "  [Action] Task metadata updated" -ForegroundColor Gray
        }

        default {
            Write-Host "  [Skip] Unhandled event type" -ForegroundColor DarkGray
        }
    }
}

# Subscribe to DataDrivenAI event stream
function Start-EventSubscription {
    Write-Host "`n=== Consciousness Bridge - DataDrivenAI Subscriber ===" -ForegroundColor Cyan
    Write-Host "Subscribing to ClickUp events from DataDrivenAI...`n"

    # Test connection first
    if (-not (Test-DataDrivenAIConnection)) {
        throw "Cannot connect to DataDrivenAI"
    }

    $eventsUrl = "$dataDrivenAIUrl/api/events?eventType=clickup"

    Write-Host "[INFO] Polling events from $eventsUrl"
    Write-Host "[INFO] Ctrl+C to stop`n"

    $lastEventTime = [DateTime]::UtcNow.AddMinutes(-5)

    while ($true) {
        try {
            # Get recent ClickUp events
            $events = Invoke-RestMethod -Uri $eventsUrl -Method Get -SkipCertificateCheck

            # Filter events since last check
            $newEvents = $events | Where-Object {
                $eventTime = [DateTime]::Parse($_.Timestamp)
                $eventTime -gt $lastEventTime
            }

            if ($newEvents) {
                Write-Host "[POLL] Found $($newEvents.Count) new event(s)" -ForegroundColor Green

                foreach ($event in $newEvents) {
                    Invoke-ClickUpEventAction -Event $event

                    $eventTime = [DateTime]::Parse($event.Timestamp)
                    if ($eventTime -gt $lastEventTime) {
                        $lastEventTime = $eventTime
                    }
                }
            }
            else {
                Write-Host "[POLL] No new events (last check: $($lastEventTime.ToString('HH:mm:ss')))" -ForegroundColor DarkGray
            }

            # Wait before next poll (30 seconds)
            Start-Sleep -Seconds 30
        }
        catch {
            Write-Error "Polling error: $_"
            Start-Sleep -Seconds 60  # Wait longer on error
        }
    }
}

# Main execution
switch ($Action) {
    'Subscribe' {
        Start-EventSubscription
    }

    'ProcessEvent' {
        if (-not $Event) {
            throw "Event parameter required for ProcessEvent action"
        }
        Invoke-ClickUpEventAction -Event $Event
    }

    'TestConnection' {
        Test-DataDrivenAIConnection
    }
}
