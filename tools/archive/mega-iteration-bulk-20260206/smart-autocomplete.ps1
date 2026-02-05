# smart-autocomplete.ps1
# Context-aware autocomplete suggestions for agent commands
# Learns from history and suggests relevant completions

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Register", "Suggest", "History", "Clear")]
    [string]$Action,

    [string]$Partial = "",
    [string]$Context = "",
    [int]$MaxSuggestions = 10
)

$script:HistoryFile = "C:\scripts\_machine\command-history.jsonl"
$script:CompletionsFile = "C:\scripts\_machine\completions.json"

function Get-CommandHistory {
    if (Test-Path $script:HistoryFile) {
        $content = Get-Content $script:HistoryFile
        return $content | ForEach-Object { $_ | ConvertFrom-Json }
    }
    return @()
}

function Add-CommandToHistory {
    param([string]$Command, [string]$Context)

    $entry = @{
        Command = $Command
        Context = $Context
        Timestamp = (Get-Date).ToString("o")
        Frequency = 1
    }

    $json = $entry | ConvertTo-Json -Compress
    Add-Content -Path $script:HistoryFile -Value $json
}

function Get-CompletionData {
    if (Test-Path $script:CompletionsFile) {
        return Get-Content $script:CompletionsFile -Raw | ConvertFrom-Json
    }
    return @{
        Commands = @{}
        Paths = @{}
        Arguments = @{}
    }
}

function Set-CompletionData {
    param($Data)
    $Data | ConvertTo-Json -Depth 10 | Set-Content -Path $script:CompletionsFile -Force
}

function Get-SmartSuggestions {
    param(
        [string]$PartialInput,
        [string]$Context,
        [int]$Max
    )

    $suggestions = @()

    # Get command history
    $history = Get-CommandHistory

    # Filter by partial match
    $matches = $history | Where-Object {
        $_.Command -like "$PartialInput*"
    } | Group-Object Command | ForEach-Object {
        @{
            Command = $_.Name
            Count = $_.Count
            LastUsed = ($_.Group | Sort-Object Timestamp -Descending | Select-Object -First 1).Timestamp
        }
    }

    # Score matches by:
    # - Frequency (how often used)
    # - Recency (how recently used)
    # - Context match (if in similar context)
    foreach ($match in $matches) {
        $frequencyScore = $match.Count
        $recencyScore = 100 - ((Get-Date) - [DateTime]$match.LastUsed).TotalDays

        # Context matching
        $contextScore = 0
        if ($Context) {
            $matchingHistory = $history | Where-Object {
                $_.Command -eq $match.Command -and $_.Context -eq $Context
            }
            $contextScore = $matchingHistory.Count * 10
        }

        $totalScore = $frequencyScore + $recencyScore + $contextScore

        $suggestions += @{
            Command = $match.Command
            Score = $totalScore
            Frequency = $match.Count
            LastUsed = $match.LastUsed
        }
    }

    # Sort by score and return top N
    $topSuggestions = $suggestions | Sort-Object -Property Score -Descending | Select-Object -First $Max

    return $topSuggestions
}

function Show-Suggestions {
    param([array]$Suggestions, [string]$Partial)

    if ($Suggestions.Count -eq 0) {
        Write-Host "No suggestions for: $Partial" -ForegroundColor Gray
        return
    }

    Write-Host "`n💡 Suggestions for: $Partial" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

    for ($i = 0; $i -lt $Suggestions.Count; $i++) {
        $suggestion = $Suggestions[$i]
        $age = ((Get-Date) - [DateTime]$suggestion.LastUsed).TotalDays

        Write-Host "`n[$($i + 1)] " -NoNewline -ForegroundColor Yellow
        Write-Host "$($suggestion.Command)" -ForegroundColor White
        Write-Host "    Used $($suggestion.Frequency)x | Last: $([math]::Round($age, 1))d ago | Score: $([math]::Round($suggestion.Score, 0))" -ForegroundColor DarkGray
    }

    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "Press 1-$($Suggestions.Count) to use suggestion" -ForegroundColor Gray
}

function Show-CommandHistory {
    $history = Get-CommandHistory

    if ($history.Count -eq 0) {
        Write-Host "No command history" -ForegroundColor Gray
        return
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📜 COMMAND HISTORY" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    # Group by command and show frequency
    $grouped = $history | Group-Object Command | Sort-Object Count -Descending | Select-Object -First 20

    foreach ($group in $grouped) {
        $latest = $group.Group | Sort-Object Timestamp -Descending | Select-Object -First 1
        $age = ((Get-Date) - [DateTime]$latest.Timestamp).TotalDays

        Write-Host "`n[$($group.Count)x] $($group.Name)" -ForegroundColor White
        Write-Host "   Last used: $([math]::Round($age, 1))d ago" -ForegroundColor DarkGray
        if ($latest.Context) {
            Write-Host "   Context: $($latest.Context)" -ForegroundColor DarkGray
        }
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Total commands: $($history.Count) | Unique: $($grouped.Count)" -ForegroundColor Gray
    Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Clear-History {
    if (Test-Path $script:HistoryFile) {
        Remove-Item $script:HistoryFile -Force
        Write-Host "✅ Command history cleared" -ForegroundColor Green
    } else {
        Write-Host "⚠️ No history to clear" -ForegroundColor Yellow
    }
}

# Main logic
switch ($Action) {
    "Register" {
        if (-not $Partial) {
            Write-Host "❌ Register requires -Partial (command to register)" -ForegroundColor Red
            exit 1
        }

        Add-CommandToHistory -Command $Partial -Context $Context
        Write-Host "✅ Command registered in history" -ForegroundColor Green
        exit 0
    }

    "Suggest" {
        if (-not $Partial) {
            Write-Host "❌ Suggest requires -Partial (partial command)" -ForegroundColor Red
            exit 1
        }

        $suggestions = Get-SmartSuggestions -PartialInput $Partial -Context $Context -Max $MaxSuggestions
        Show-Suggestions -Suggestions $suggestions -Partial $Partial

        exit 0
    }

    "History" {
        Show-CommandHistory
        exit 0
    }

    "Clear" {
        Clear-History
        exit 0
    }
}
