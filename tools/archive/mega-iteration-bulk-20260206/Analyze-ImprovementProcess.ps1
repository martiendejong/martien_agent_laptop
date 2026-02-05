# Improvement Process Analyzer (R24-001)
# Extracts meta-patterns from all improvement rounds

param(
    [switch]$Analyze,
    [switch]$Report,
    [switch]$Recommendations
)

$RoundsPath = "C:\scripts\_machine"

function Get-AllRounds {
    $rounds = @()

    Get-ChildItem -Path $RoundsPath -Filter "IMPROVEMENTS_ROUND_*.yaml" | ForEach-Object {
        try {
            $content = Get-Content $_.FullName -Raw | ConvertFrom-Yaml
            $roundNumber = [int]($_.Name -replace 'IMPROVEMENTS_ROUND_|\.yaml', '')

            $rounds += @{
                round = $roundNumber
                file = $_.FullName
                data = $content
            }
        }
        catch {
            Write-Host "Skipping $($_.Name): $_" -ForegroundColor Yellow
        }
    }

    return $rounds | Sort-Object round
}

function Analyze-Patterns {
    $rounds = Get-AllRounds

    if ($rounds.Count -eq 0) {
        Write-Host "No rounds found" -ForegroundColor Yellow
        return
    }

    $analysis = @{
        total_rounds = $rounds.Count
        total_improvements = $rounds.Count * 5
        value_effort_ratios = @()
        categories = @{}
        themes = @{}
    }

    foreach ($round in $rounds) {
        $data = $round.data

        # Extract theme
        if ($data.improvements.PSObject.Properties.Name.Contains('context_analysis')) {
            $theme = $data.improvements.theme ?? "Unknown"
            if (!$analysis.themes.ContainsKey($theme)) {
                $analysis.themes[$theme] = 0
            }
            $analysis.themes[$theme]++
        }

        # Analyze top 5
        if ($data.improvements.top_5) {
            foreach ($improvement in $data.improvements.top_5) {
                # Value/effort ratio
                if ($improvement.ratio) {
                    $analysis.value_effort_ratios += $improvement.ratio
                }

                # Category distribution
                if ($improvement.category) {
                    if (!$analysis.categories.ContainsKey($improvement.category)) {
                        $analysis.categories[$improvement.category] = 0
                    }
                    $analysis.categories[$improvement.category]++
                }
            }
        }
    }

    # Calculate statistics
    if ($analysis.value_effort_ratios.Count -gt 0) {
        $analysis.avg_ratio = ($analysis.value_effort_ratios | Measure-Object -Average).Average
        $analysis.max_ratio = ($analysis.value_effort_ratios | Measure-Object -Maximum).Maximum
        $analysis.min_ratio = ($analysis.value_effort_ratios | Measure-Object -Minimum).Minimum
    }

    return $analysis
}

function Show-Report {
    $analysis = Analyze-Patterns

    Write-Host "`n=== Improvement Process Analysis ===" -ForegroundColor Cyan
    Write-Host "Total Rounds: $($analysis.total_rounds)"
    Write-Host "Total Improvements: $($analysis.total_improvements)`n"

    Write-Host "Value/Effort Ratios:" -ForegroundColor Yellow
    Write-Host "  Average: $([math]::Round($analysis.avg_ratio, 2))"
    Write-Host "  Best: $([math]::Round($analysis.max_ratio, 2))"
    Write-Host "  Worst: $([math]::Round($analysis.min_ratio, 2))`n"

    Write-Host "Top Categories:" -ForegroundColor Yellow
    $analysis.categories.GetEnumerator() |
        Sort-Object Value -Descending |
        Select-Object -First 10 |
        ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value) improvements"
        }

    Write-Host "`nThemes:" -ForegroundColor Yellow
    $analysis.themes.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value) rounds"
    }
}

function Get-Recommendations {
    $analysis = Analyze-Patterns

    Write-Host "`n=== Recommendations for Future Rounds ===" -ForegroundColor Cyan

    # High-value categories
    $topCategories = $analysis.categories.GetEnumerator() |
        Sort-Object Value -Descending |
        Select-Object -First 3 -ExpandProperty Name

    Write-Host "`nFocus on high-value categories:" -ForegroundColor Green
    $topCategories | ForEach-Object {
        Write-Host "  - $_"
    }

    # Ratio insights
    Write-Host "`nTarget value/effort ratio: > $([math]::Round($analysis.avg_ratio, 1))" -ForegroundColor Green

    Write-Host "`nBest practices observed:" -ForegroundColor Green
    Write-Host "  - PowerShell tools: low effort, high value"
    Write-Host "  - Central data structures: medium effort, very high value"
    Write-Host "  - Event-driven systems: medium effort, high value"
    Write-Host "  - Resilience patterns: low-medium effort, high risk reduction"

    Write-Host "`nRecommended next themes:" -ForegroundColor Yellow
    Write-Host "  - Observability & Monitoring (measure everything)"
    Write-Host "  - Performance Optimization (speed improvements)"
    Write-Host "  - User Experience (simplified interfaces)"
    Write-Host "  - Security & Privacy (protect sensitive data)"
}

# Main execution
if ($Analyze) {
    $analysis = Analyze-Patterns
    $analysis | ConvertTo-Json -Depth 5
}
elseif ($Report) {
    Show-Report
}
elseif ($Recommendations) {
    Get-Recommendations
}
else {
    Write-Host "Usage: Analyze-ImprovementProcess.ps1 [-Analyze] [-Report] [-Recommendations]"
    Write-Host "  -Analyze          : Output analysis data (JSON)"
    Write-Host "  -Report           : Human-readable report"
    Write-Host "  -Recommendations  : Recommendations for future rounds"
}
