#Requires -Version 5.1
<#
.SYNOPSIS
    Detect duplicate ClickUp tasks using similarity scoring

.DESCRIPTION
    Analyzes all tasks in a ClickUp project to find potential duplicates.
    Uses Levenshtein distance and keyword matching.

.PARAMETER Project
    Project to analyze (default: client-manager)

.PARAMETER MinScore
    Minimum similarity score to report (0.0-1.0, default: 0.70)

.EXAMPLE
    .\check-duplicates.ps1 -MinScore 0.80
#>

param(
    [string]$Project = "client-manager",
    [double]$MinScore = 0.70
)

function Get-LevenshteinDistance {
    param([string]$s1, [string]$s2)

    $len1 = $s1.Length
    $len2 = $s2.Length
    $matrix = New-Object 'int[,]' ($len1 + 1), ($len2 + 1)

    for ($i = 0; $i -le $len1; $i++) { $matrix[$i, 0] = $i }
    for ($j = 0; $j -le $len2; $j++) { $matrix[0, $j] = $j }

    for ($i = 1; $i -le $len1; $i++) {
        for ($j = 1; $j -le $len2; $j++) {
            $cost = if ($s1[$i-1] -eq $s2[$j-1]) { 0 } else { 1 }
            $del = $matrix[($i-1), $j] + 1
            $ins = $matrix[$i, ($j-1)] + 1
            $sub = $matrix[($i-1), ($j-1)] + $cost
            $matrix[$i, $j] = [Math]::Min([Math]::Min($del, $ins), $sub)
        }
    }

    return $matrix[$len1, $len2]
}

function Get-SimilarityScore {
    param([string]$s1, [string]$s2)

    if ([string]::IsNullOrWhiteSpace($s1) -or [string]::IsNullOrWhiteSpace($s2)) { return 0.0 }

    $t1 = $s1.ToLower().Trim()
    $t2 = $s2.ToLower().Trim()

    if ($t1 -eq $t2) { return 1.0 }

    $maxLen = [Math]::Max($t1.Length, $t2.Length)
    $distance = Get-LevenshteinDistance $t1 $t2

    return 1.0 - ($distance / $maxLen)
}

Write-Host "Duplicate Task Detector" -ForegroundColor Cyan
Write-Host "Project: $Project | Min Score: $MinScore`n" -ForegroundColor Gray

# Fetch tasks
Write-Host "Fetching tasks..." -ForegroundColor Yellow
$tempFile = [System.IO.Path]::GetTempFileName()
& "$PSScriptRoot\clickup-sync.ps1" -Action list -Project $Project > $tempFile 2>&1

# Parse task IDs (format: 869bx1234)
$taskIds = Get-Content $tempFile |
    Where-Object { $_ -match '^[0-9a-z]{9}\s' } |
    ForEach-Object {
        if ($_ -match '^([0-9a-z]{9})') {
            $matches[1]
        }
    } | Select-Object -Unique

Remove-Item $tempFile -ErrorAction SilentlyContinue

if (-not $taskIds -or $taskIds.Count -eq 0) {
    Write-Host "No tasks found!`n" -ForegroundColor Red
    exit 1
}

Write-Host "Found $($taskIds.Count) tasks`n" -ForegroundColor Gray

# Build task list
$tasks = @()
foreach ($id in $taskIds) {
    try {
        $details = & "$PSScriptRoot\clickup-sync.ps1" -Action show -TaskId $id 2>&1
        $name = ($details | Select-String -Pattern '^Name:\s+(.+)$').Matches.Groups[1].Value

        if ($name) {
            $tasks += [PSCustomObject]@{
                ID = $id
                Name = $name
            }
        }
    }
    catch {
        Write-Warning "Failed to fetch $id"
    }
}

# Find duplicates
$duplicates = @()

for ($i = 0; $i -lt $tasks.Count; $i++) {
    for ($j = $i + 1; $j -lt $tasks.Count; $j++) {
        $score = Get-SimilarityScore $tasks[$i].Name $tasks[$j].Name

        if ($score -ge $MinScore) {
            $duplicates += [PSCustomObject]@{
                Task1 = $tasks[$i].ID
                Name1 = $tasks[$i].Name
                Task2 = $tasks[$j].ID
                Name2 = $tasks[$j].Name
                Score = [Math]::Round($score, 2)
                Level = if ($score -ge 0.85) { "HIGH" } elseif ($score -ge 0.70) { "MEDIUM" } else { "LOW" }
            }
        }
    }
}

if ($duplicates.Count -eq 0) {
    Write-Host "No duplicates found!`n" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($duplicates.Count) potential duplicate(s):`n" -ForegroundColor Yellow

foreach ($dup in ($duplicates | Sort-Object -Property Score -Descending)) {
    $color = switch ($dup.Level) {
        "HIGH" { "Red" }
        "MEDIUM" { "Yellow" }
        default { "Gray" }
    }

    Write-Host "$($dup.Level) (Score: $($dup.Score))" -ForegroundColor $color
    Write-Host "  $($dup.Task1): $($dup.Name1)" -ForegroundColor White
    Write-Host "  $($dup.Task2): $($dup.Name2)`n" -ForegroundColor White
}

Write-Host "Done!`n" -ForegroundColor Cyan
