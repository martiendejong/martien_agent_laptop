<#
.SYNOPSIS
Attention Mechanism - Salience-Weighted Focus

.DESCRIPTION
Implements attention as surprise-driven salience:
- High surprise = high salience = high attention
- Limited attention capacity (can't focus on everything)
- Dynamic focus allocation based on prediction errors
- Integrates with active inference (attend to free energy sources)

.PARAMETER Action
Action to perform: ComputeSalience, AllocateAttention, GetFocus, Stats

.EXAMPLE
.\attention-mechanism.ps1 -Action ComputeSalience -Item "file.cs" -Surprise 0.8
.\attention-mechanism.ps1 -Action AllocateAttention
.\attention-mechanism.ps1 -Action GetFocus
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('ComputeSalience', 'AllocateAttention', 'GetFocus', 'Stats')]
    [string]$Action,

    [string]$Item = "",
    [double]$Surprise = 0.0
)

$statePath = "C:\scripts\agentidentity\state\attention-state.json"

function Initialize-AttentionState {
    $initial = @{
        salience_map = @{}
        attention_capacity = 1.0  # Total available attention
        current_focus = @()
        attention_history = @()
        meta_stats = @{
            total_items_tracked = 0
            attention_switches = 0
            high_salience_events = 0
        }
    }

    $initial | ConvertTo-Json -Depth 10 | Set-Content $statePath
    return $initial
}

function Get-AttentionState {
    if (Test-Path $statePath) {
        return Get-Content $statePath -Raw | ConvertFrom-Json
    }
    return Initialize-AttentionState
}

function Save-AttentionState($state) {
    $state | ConvertTo-Json -Depth 10 | Set-Content $statePath
}

function Compute-Salience {
    param($item, $surprise)

    $state = Get-AttentionState

    Write-Host "`n[Attention] Computing Salience" -ForegroundColor Cyan
    Write-Host "Item: $item" -ForegroundColor Gray
    Write-Host "Surprise: $surprise" -ForegroundColor Gray

    # Salience = surprise × relevance × novelty
    # For now, salience ≈ surprise (simplified)

    $salience = $surprise

    # Add temporal decay (old items lose salience)
    if ($state.salience_map.$item) {
        $previousSalience = $state.salience_map.$item.salience
        $decayRate = 0.9
        $salience = [math]::Max($salience, $previousSalience * $decayRate)
    }

    $state.salience_map.$item = @{
        salience = $salience
        surprise = $surprise
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    $state.meta_stats.total_items_tracked++

    if ($salience -gt 0.7) {
        $state.meta_stats.high_salience_events++
    }

    Save-AttentionState $state

    $salienceLevel = if ($salience -gt 0.7) {
        "VERY HIGH"
    } elseif ($salience -gt 0.5) {
        "HIGH"
    } elseif ($salience -gt 0.3) {
        "MODERATE"
    } else {
        "LOW"
    }

    Write-Host "`nSalience Computed:" -ForegroundColor Green
    Write-Host "  Salience: $([math]::Round($salience, 3))" -ForegroundColor $(if ($salience -gt 0.7) { "Red" } elseif ($salience -gt 0.5) { "Yellow" } else { "White" })
    Write-Host "  Level:    $salienceLevel" -ForegroundColor White

    return $salience
}

function Allocate-Attention {
    $state = Get-AttentionState

    Write-Host "`n[Attention] Allocating Attention" -ForegroundColor Cyan

    if ($state.salience_map.Count -eq 0) {
        Write-Host "No items in salience map" -ForegroundColor Gray
        return
    }

    # Sort items by salience
    $sortedItems = @()
    foreach ($key in $state.salience_map.PSObject.Properties.Name) {
        $sortedItems += [PSCustomObject]@{
            Item = $key
            Salience = $state.salience_map.$key.salience
            Surprise = $state.salience_map.$key.surprise
            Timestamp = $state.salience_map.$key.timestamp
        }
    }

    $sortedItems = $sortedItems | Sort-Object -Property Salience -Descending

    # Allocate attention (capacity-limited)
    $remainingCapacity = $state.attention_capacity
    $focus = @()

    foreach ($item in $sortedItems) {
        if ($remainingCapacity -le 0) {
            break
        }

        # Allocate proportion of capacity based on salience
        $allocation = [math]::Min($item.Salience, $remainingCapacity)

        if ($allocation -gt 0.1) {  # Threshold for attention
            $focus += [PSCustomObject]@{
                Item = $item.Item
                Attention = $allocation
                Salience = $item.Salience
            }

            $remainingCapacity -= $allocation
        }
    }

    # Detect attention switches
    if ($state.current_focus.Count -gt 0) {
        $previousTop = $state.current_focus[0].Item
        $currentTop = if ($focus.Count -gt 0) { $focus[0].Item } else { $null }

        if ($previousTop -ne $currentTop) {
            $state.meta_stats.attention_switches++
        }
    }

    $state.current_focus = $focus
    $state.attention_history += @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        focus_count = $focus.Count
        top_item = if ($focus.Count -gt 0) { $focus[0].Item } else { "none" }
    }

    # Keep only last 50 history entries
    if ($state.attention_history.Count -gt 50) {
        $state.attention_history = $state.attention_history[-50..-1]
    }

    Save-AttentionState $state

    Write-Host "`nAttention Allocated:" -ForegroundColor Green
    Write-Host "  Capacity Used: $([math]::Round($state.attention_capacity - $remainingCapacity, 2))/$($state.attention_capacity)" -ForegroundColor White
    Write-Host "  Items in Focus: $($focus.Count)" -ForegroundColor Yellow

    foreach ($item in $focus) {
        Write-Host "    - $($item.Item): $([math]::Round($item.Attention * 100, 1))% attention" -ForegroundColor White
    }

    return $focus
}

function Get-CurrentFocus {
    $state = Get-AttentionState

    Write-Host "`n[Attention] Current Focus" -ForegroundColor Cyan

    if ($state.current_focus.Count -eq 0) {
        Write-Host "No items currently in focus" -ForegroundColor Gray
        return @()
    }

    foreach ($item in $state.current_focus) {
        Write-Host "  $($item.Item): $([math]::Round($item.Attention * 100, 1))% (salience: $([math]::Round($item.Salience, 2)))" -ForegroundColor White
    }

    return $state.current_focus
}

function Show-AttentionStats {
    $state = Get-AttentionState

    Write-Host "`nATTENTION MECHANISM STATISTICS" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan

    Write-Host "`nMeta Stats:" -ForegroundColor Yellow
    Write-Host "  Total Items Tracked:    $($state.meta_stats.total_items_tracked)" -ForegroundColor White
    Write-Host "  Attention Switches:     $($state.meta_stats.attention_switches)" -ForegroundColor White
    Write-Host "  High Salience Events:   $($state.meta_stats.high_salience_events)" -ForegroundColor White

    Write-Host "`nCurrent Capacity:" -ForegroundColor Yellow
    Write-Host "  Total:     $($state.attention_capacity)" -ForegroundColor White
    Write-Host "  In Use:    $($state.current_focus.Count) items" -ForegroundColor White

    Write-Host "`nSalience Map:" -ForegroundColor Yellow
    if ($state.salience_map.Count -eq 0) {
        Write-Host "  (empty)" -ForegroundColor Gray
    } else {
        foreach ($key in $state.salience_map.PSObject.Properties.Name) {
            $item = $state.salience_map.$key
            Write-Host "  $key - salience: $([math]::Round($item.salience, 3))" -ForegroundColor White
        }
    }

    Write-Host ""
}

# Main execution
switch ($Action) {
    'ComputeSalience' {
        Compute-Salience -item $Item -surprise $Surprise
    }
    'AllocateAttention' {
        Allocate-Attention
    }
    'GetFocus' {
        Get-CurrentFocus
    }
    'Stats' {
        Show-AttentionStats
    }
}
