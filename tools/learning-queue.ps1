#!/usr/bin/env pwsh
# learning-queue.ps1 - Manage improvement opportunities queue
# Part of Embedded Learning Architecture

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("add", "list", "process", "complete", "remove")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [ValidateSet("automation", "documentation", "skill", "instruction", "tool")]
    [string]$Type,

    [Parameter(Mandatory=$false)]
    [string]$Description,

    [Parameter(Mandatory=$false)]
    [int]$Frequency = 1,

    [Parameter(Mandatory=$false)]
    [ValidateSet("LOW", "MEDIUM", "HIGH", "USER-PREF")]
    [string]$Risk = "MEDIUM",

    [Parameter(Mandatory=$false)]
    [double]$RoiEstimate = 0.0,

    [Parameter(Mandatory=$false)]
    [string]$Id,

    [Parameter(Mandatory=$false)]
    [ValidateSet("roi", "frequency", "risk", "timestamp")]
    [string]$SortBy = "roi",

    [Parameter(Mandatory=$false)]
    [string]$QueuePath = "C:\scripts\_machine\learning-queue.jsonl"
)

# Ensure queue exists
if (-not (Test-Path $QueuePath)) {
    $queueDir = Split-Path $QueuePath -Parent
    if (-not (Test-Path $queueDir)) {
        New-Item -ItemType Directory -Path $queueDir -Force | Out-Null
    }
    "" | Out-File -FilePath $QueuePath -Encoding utf8
}

# Load queue
function Get-Queue {
    $entries = Get-Content $QueuePath -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne "" }
    if ($entries) {
        return $entries | ForEach-Object { $_ | ConvertFrom-Json }
    }
    return @()
}

# Save queue
function Save-Queue {
    param($Queue)
    "" | Out-File -FilePath $QueuePath -Encoding utf8
    $Queue | ForEach-Object {
        $_ | ConvertTo-Json -Compress | Out-File -FilePath $QueuePath -Append -Encoding utf8
    }
}

switch ($Action) {
    "add" {
        if (-not $Type -or -not $Description) {
            Write-Host "❌ add requires -Type and -Description" -ForegroundColor Red
            exit 1
        }

        $queue = Get-Queue
        $newEntry = @{
            id = (New-Guid).ToString().Substring(0, 8)
            timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
            type = $Type
            description = $Description
            frequency = $Frequency
            risk = $Risk
            roi_estimate = $RoiEstimate
            status = "queued"
        }

        $queue += $newEntry
        Save-Queue -Queue $queue

        Write-Host "✅ Added to learning queue: $Description" -ForegroundColor Green
        Write-Host "   ID: $($newEntry.id) | Type: $Type | Risk: $Risk | ROI: $RoiEstimate" -ForegroundColor Gray
    }

    "list" {
        $queue = Get-Queue

        if ($queue.Count -eq 0) {
            Write-Host "📋 Learning queue is empty" -ForegroundColor Yellow
            exit 0
        }

        # Sort queue
        $sorted = switch ($SortBy) {
            "roi" { $queue | Sort-Object -Property roi_estimate -Descending }
            "frequency" { $queue | Sort-Object -Property frequency -Descending }
            "risk" { $queue | Sort-Object -Property risk }
            "timestamp" { $queue | Sort-Object -Property timestamp }
        }

        Write-Host ""
        Write-Host "📋 LEARNING QUEUE (sorted by $SortBy)" -ForegroundColor Cyan
        Write-Host "====================================" -ForegroundColor Cyan
        Write-Host ""

        $sorted | ForEach-Object {
            $color = switch ($_.status) {
                "queued" { "Yellow" }
                "in_progress" { "Cyan" }
                "completed" { "Green" }
                default { "White" }
            }

            $riskColor = switch ($_.risk) {
                "LOW" { "Green" }
                "MEDIUM" { "Yellow" }
                "HIGH" { "Red" }
                "USER-PREF" { "Magenta" }
                default { "White" }
            }

            Write-Host "[$($_.id)] $($_.type.ToUpper()) - $($_.description)" -ForegroundColor $color
            Write-Host "   Frequency: $($_.frequency)x | Risk: $($_.risk) | ROI: $($_.roi_estimate) | Status: $($_.status)" -ForegroundColor Gray
            Write-Host "   Added: $($_.timestamp)" -ForegroundColor DarkGray
            if ($_.artifact) {
                Write-Host "   Artifact: $($_.artifact)" -ForegroundColor DarkGray
            }
            Write-Host ""
        }
    }

    "process" {
        $queue = Get-Queue

        if ($queue.Count -eq 0) {
            Write-Host "📋 Learning queue is empty - nothing to process" -ForegroundColor Yellow
            exit 0
        }

        # Sort by ROI
        $sorted = $queue | Where-Object { $_.status -eq "queued" } | Sort-Object -Property roi_estimate -Descending

        Write-Host ""
        Write-Host "🔄 PROCESSING LEARNING QUEUE" -ForegroundColor Cyan
        Write-Host "============================" -ForegroundColor Cyan
        Write-Host ""

        foreach ($item in $sorted) {
            Write-Host "Processing: $($item.description)" -ForegroundColor Yellow
            Write-Host "   Type: $($item.type) | Risk: $($item.risk) | ROI: $($item.roi_estimate)" -ForegroundColor Gray

            # Decision tree based on risk
            $decision = switch ($item.risk) {
                "LOW" {
                    Write-Host "   Decision: IMPLEMENT IMMEDIATELY (low risk)" -ForegroundColor Green
                    "implement"
                }
                "MEDIUM" {
                    if ($item.roi_estimate -ge 7.0) {
                        Write-Host "   Decision: IMPLEMENT + INFORM (medium risk, high ROI)" -ForegroundColor Green
                        "implement"
                    } else {
                        Write-Host "   Decision: SUGGEST to user (medium risk, medium ROI)" -ForegroundColor Yellow
                        "suggest"
                    }
                }
                "HIGH" {
                    Write-Host "   Decision: SUGGEST + APPROVE (high risk)" -ForegroundColor Red
                    "suggest"
                }
                "USER-PREF" {
                    Write-Host "   Decision: DISCUSS with user (preference)" -ForegroundColor Magenta
                    "discuss"
                }
            }

            Write-Host "   Action: $decision" -ForegroundColor Cyan
            Write-Host ""

            # TODO: Actual implementation would happen here
            # For now, just mark as processed
        }

        Write-Host "💡 To implement items, use appropriate tools (skill-creator, self-improvement, etc.)" -ForegroundColor Cyan
    }

    "complete" {
        if (-not $Id) {
            Write-Host "❌ complete requires -Id" -ForegroundColor Red
            exit 1
        }

        $queue = Get-Queue
        $updated = $queue | ForEach-Object {
            if ($_.id -eq $Id) {
                $_.status = "completed"
                Write-Host "✅ Marked $Id as completed: $($_.description)" -ForegroundColor Green
            }
            $_
        }

        Save-Queue -Queue $updated
    }

    "remove" {
        if (-not $Id) {
            Write-Host "❌ remove requires -Id" -ForegroundColor Red
            exit 1
        }

        $queue = Get-Queue
        $filtered = $queue | Where-Object { $_.id -ne $Id }
        Save-Queue -Queue $filtered

        Write-Host "🗑️  Removed $Id from learning queue" -ForegroundColor Yellow
    }
}
