# Natural Language Query Resolver
# Resolves common questions to direct answers using pre-computed mappings

param(
    [Parameter(Mandatory=$true)]
    [string]$Query
)

$mappingsFile = "C:\scripts\_machine\QUERY_MAPPINGS.yaml"

if (-not (Test-Path $mappingsFile)) {
    Write-Host "[ERROR] Query mappings file not found" -ForegroundColor Red
    exit 1
}

$mappings = Get-Content $mappingsFile -Raw | ConvertFrom-Yaml

function Find-BestMatch {
    param(
        [string]$Query,
        [array]$Queries
    )

    $bestMatch = $null
    $bestScore = 0

    foreach ($item in $Queries.queries) {
        foreach ($pattern in $item.patterns) {
            # Simple similarity: count matching words
            $queryWords = $Query.ToLower() -split '\s+'
            $patternWords = $pattern.ToLower() -split '\s+'

            $matchCount = 0
            foreach ($qw in $queryWords) {
                if ($patternWords -contains $qw) { $matchCount++ }
            }

            $score = $matchCount / [Math]::Max($queryWords.Count, $patternWords.Count)

            if ($score -gt $bestScore -and $score -ge 0.5) {
                $bestScore = $score
                $bestMatch = $item
            }
        }
    }

    return @{
        match = $bestMatch
        score = $bestScore
    }
}

$result = Find-BestMatch -Query $Query -Queries $mappings

if ($result.match) {
    Write-Host "`n=== QUERY RESOLUTION ===" -ForegroundColor Cyan
    Write-Host "Query: $Query" -ForegroundColor White
    Write-Host "Confidence: $([math]::Round($result.score * 100))%" -ForegroundColor Gray
    Write-Host ""

    $answer = $result.match.answer

    switch ($answer.type) {
        "credentials" {
            Write-Host "Credentials: $($answer.context)" -ForegroundColor Yellow
            Write-Host "  Username: $($answer.username)" -ForegroundColor Green
            Write-Host "  Password: $($answer.password)" -ForegroundColor Green
            Write-Host "  Location: $($answer.location)" -ForegroundColor Gray
        }
        "workflow" {
            Write-Host "Workflow: $($answer.file)" -ForegroundColor Yellow
            if ($answer.section) {
                Write-Host "  Section: $($answer.section)" -ForegroundColor Cyan
            }
            if ($answer.quick_steps) {
                Write-Host "  Steps:" -ForegroundColor Cyan
                $answer.quick_steps | ForEach-Object {
                    Write-Host "    - $_" -ForegroundColor Gray
                }
            }
            if ($answer.tool) {
                Write-Host "  Tool: $($answer.tool)" -ForegroundColor Green
            }
        }
        "troubleshooting" {
            Write-Host "Troubleshooting Guide: $($answer.file)" -ForegroundColor Yellow
            if ($answer.common_causes) {
                Write-Host "  Common causes:" -ForegroundColor Cyan
                $answer.common_causes | ForEach-Object {
                    Write-Host "    - $_" -ForegroundColor Gray
                }
            }
            if ($answer.first_steps) {
                Write-Host "  First steps:" -ForegroundColor Cyan
                $answer.first_steps | ForEach-Object {
                    Write-Host "    - $_" -ForegroundColor Gray
                }
            }
        }
        "path" {
            Write-Host "Paths:" -ForegroundColor Yellow
            $answer.PSObject.Properties | ForEach-Object {
                Write-Host "  $($_.Name): $($_.Value)" -ForegroundColor Cyan
            }
        }
        "command" {
            Write-Host "Command: $($answer.command)" -ForegroundColor Green
            if ($answer.dashboard) {
                Write-Host "  Dashboard: $($answer.dashboard)" -ForegroundColor Cyan
            }
        }
        "error_solution" {
            Write-Host "Error: $($answer.cause)" -ForegroundColor Red
            Write-Host "Solution: $($answer.solution)" -ForegroundColor Green
            if ($answer.tool) {
                Write-Host "  Tool: $($answer.tool)" -ForegroundColor Cyan
            }
            if ($answer.docs) {
                Write-Host "  Docs: $($answer.docs)" -ForegroundColor Cyan
            }
        }
    }
} else {
    Write-Host "`n[No Match] Query not recognized" -ForegroundColor Yellow
    Write-Host "Try: 'where are credentials', 'how to create pr', 'ci failing', etc." -ForegroundColor Gray
}
