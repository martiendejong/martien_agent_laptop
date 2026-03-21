# Analyze State File Structure
# Shows all top-level properties and their sizes

$ErrorActionPreference = "Stop"

$statePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
$state = Get-Content $statePath | ConvertFrom-Json
$totalSize = (Get-Item $statePath).Length

Write-Host "=== STATE FILE STRUCTURE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total file: $([math]::Round($totalSize/1KB, 2)) KB"
Write-Host ""

$properties = @()

foreach ($prop in $state.PSObject.Properties) {
    $name = $prop.Name
    $json = $prop.Value | ConvertTo-Json -Depth 10 -Compress
    $sizeKB = [math]::Round($json.Length/1KB, 2)
    $pct = [math]::Round(($json.Length/$totalSize)*100, 1)

    $properties += [PSCustomObject]@{
        Name = $name
        SizeKB = $sizeKB
        Percent = $pct
    }
}

# Sort by size descending
$properties = $properties | Sort-Object -Property Percent -Descending

foreach ($p in $properties) {
    $color = if ($p.Percent -gt 20) { "Red" } elseif ($p.Percent -gt 5) { "Yellow" } else { "Green" }
    Write-Host "$($p.Name): $($p.SizeKB) KB ($($p.Percent) percent)" -ForegroundColor $color
}

Write-Host ""
Write-Host "=== BIG DATA STRUCTURES (>5 percent) ===" -ForegroundColor Cyan
Write-Host ""

$bigOnes = $properties | Where-Object { $_.Percent -gt 5 }

foreach ($big in $bigOnes) {
    Write-Host "$($big.Name) ($($big.Percent) percent):" -ForegroundColor Yellow

    $obj = $state.PSObject.Properties[$big.Name].Value

    # Check if it's an array
    if ($obj -is [Array]) {
        Write-Host "  Type: Array"
        Write-Host "  Count: $($obj.Count)"
        if ($obj.Count -gt 0) {
            Write-Host "  First item type: $($obj[0].GetType().Name)"
        }
    }
    # Check if it has properties we can count
    elseif ($obj.PSObject.Properties) {
        Write-Host "  Type: Object"
        Write-Host "  Properties:"
        foreach ($subProp in $obj.PSObject.Properties | Select-Object -First 10) {
            $subVal = $subProp.Value
            if ($subVal -is [Array]) {
                Write-Host "    $($subProp.Name): Array[$($subVal.Count)]"
            } elseif ($subVal -is [String]) {
                Write-Host "    $($subProp.Name): String (length: $($subVal.Length))"
            } else {
                Write-Host "    $($subProp.Name): $($subVal.GetType().Name)"
            }
        }
    }

    Write-Host ""
}
