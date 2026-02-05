# Query beliefs from World Model
# Simple demonstration tool

param(
    [Parameter(Mandatory=$false)]
    [string]$Query,

    [Parameter(Mandatory=$false)]
    [switch]$List
)

$BeliefsDir = "C:\scripts\agentidentity\state\world_beliefs\by_category"

if ($List) {
    Write-Host ""
    Write-Host "=== World Model Beliefs ===" -ForegroundColor Cyan
    Write-Host ""

    $categories = Get-ChildItem $BeliefsDir -Directory

    foreach ($cat in $categories) {
        Write-Host "$($cat.Name.ToUpper()):" -ForegroundColor Yellow

        $files = Get-ChildItem $cat.FullName -Filter "*.yaml"
        foreach ($file in $files) {
            $content = Get-Content $file.FullName -Raw

            # Count beliefs
            $count = ([regex]::Matches($content, "belief_id:")).Count

            Write-Host "  $($file.BaseName): $count beliefs"
        }
        Write-Host ""
    }

    Write-Host "Usage: .\query-belief.ps1 -Query <search term>"
    Write-Host ""
    exit 0
}

if (-not $Query) {
    Write-Host "Usage: .\query-belief.ps1 -Query <search> or -List"
    exit 1
}

# Search all belief files
Write-Host ""
Write-Host "Searching for: $Query" -ForegroundColor Cyan
Write-Host ""

$found = $false

Get-ChildItem -Path $BeliefsDir -Recurse -Filter "*.yaml" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw

    if ($content -match $Query) {
        # Extract belief details (simple regex)
        $matches = [regex]::Matches($content, "(?ms)belief_id:\s*`"([^`"]+)`".*?statement:\s*`"([^`"]+)`".*?confidence:\s*([0-9.]+)")

        foreach ($match in $matches) {
            if ($match.Value -match $Query) {
                $id = $match.Groups[1].Value
                $statement = $match.Groups[2].Value
                $confidence = $match.Groups[3].Value

                $confPercent = [int]($confidence * 100)
                $color = if ($confidence -ge 0.80) { "Green" } elseif ($confidence -ge 0.60) { "Yellow" } else { "Red" }

                Write-Host "Belief: $statement" -ForegroundColor White
                Write-Host "  Confidence: $confPercent%" -ForegroundColor $color
                Write-Host "  ID: $id" -ForegroundColor Gray
                Write-Host ""

                $found = $true
            }
        }
    }
}

if (-not $found) {
    Write-Host "No beliefs found matching: $Query" -ForegroundColor Yellow
    Write-Host ""
}
