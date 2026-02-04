# communication-efficiency-tracker.ps1
# Track question/answer ratio and communication patterns to learn efficiency

param(
    [ValidateSet('ask', 'answer', 'report', 'analyze')]
    [string]$Action = 'report',

    [string]$InteractionId,
    [string]$Question,
    [string]$Answer,
    [int]$TurnsToResolve = 1
)

$trackerPath = "C:\scripts\agentidentity\state\communication-efficiency.yaml"

# Initialize if doesn't exist
if (-not (Test-Path $trackerPath)) {
    @{
        interactions = @()
        metadata = @{
            created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            total_questions = 0
            total_answers = 0
            avg_turns_to_resolve = 0.0
        }
    } | ConvertTo-Yaml | Out-File -FilePath $trackerPath -Encoding UTF8
}

# Read current data
$data = Get-Content $trackerPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'ask' {
        if (-not $InteractionId -or -not $Question) {
            Write-Host "❌ Error: -InteractionId and -Question required" -ForegroundColor Red
            return
        }

        $interaction = @{
            id = $InteractionId
            type = "question"
            question = $Question
            asked_at = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            status = "pending"
        }

        $data.interactions += $interaction
        $data.metadata.total_questions++
        $data | ConvertTo-Yaml | Out-File -FilePath $trackerPath -Encoding UTF8

        Write-Host "📝 Question logged: $InteractionId" -ForegroundColor Cyan
    }

    'answer' {
        if (-not $InteractionId) {
            Write-Host "❌ Error: -InteractionId required" -ForegroundColor Red
            return
        }

        $interaction = $data.interactions | Where-Object { $_.id -eq $InteractionId }
        if (-not $interaction) {
            Write-Host "❌ Error: Interaction ID '$InteractionId' not found" -ForegroundColor Red
            return
        }

        $interaction.answer = $Answer
        $interaction.answered_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $interaction.status = "resolved"
        $interaction.turns_to_resolve = $TurnsToResolve

        # Calculate time to resolve
        $askedTime = [DateTime]::ParseExact($interaction.asked_at, "yyyy-MM-dd HH:mm:ss", $null)
        $answeredTime = [DateTime]::ParseExact($interaction.answered_at, "yyyy-MM-dd HH:mm:ss", $null)
        $interaction.time_to_resolve_seconds = ($answeredTime - $askedTime).TotalSeconds

        $data.metadata.total_answers++

        # Update average turns to resolve
        $resolvedInteractions = $data.interactions | Where-Object { $_.status -eq "resolved" }
        if ($resolvedInteractions.Count -gt 0) {
            $avgTurns = ($resolvedInteractions | Measure-Object -Property turns_to_resolve -Average).Average
            $data.metadata.avg_turns_to_resolve = [Math]::Round($avgTurns, 2)
        }

        $data | ConvertTo-Yaml | Out-File -FilePath $trackerPath -Encoding UTF8

        Write-Host "✅ Answer logged for: $InteractionId" -ForegroundColor Green
        Write-Host "   Turns to resolve: $TurnsToResolve" -ForegroundColor Gray
    }

    'report' {
        $total = $data.interactions.Count
        $resolved = ($data.interactions | Where-Object { $_.status -eq "resolved" }).Count
        $pending = $total - $resolved

        if ($total -eq 0) {
            Write-Host "`n📊 No communication interactions tracked yet" -ForegroundColor Yellow
            return
        }

        Write-Host "`n📊 COMMUNICATION EFFICIENCY REPORT" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

        Write-Host "Total Interactions: " -NoNewline -ForegroundColor Gray
        Write-Host $total -ForegroundColor White
        Write-Host "Resolved: " -NoNewline -ForegroundColor Gray
        Write-Host $resolved -ForegroundColor Green
        Write-Host "Pending: " -NoNewline -ForegroundColor Gray
        Write-Host $pending -ForegroundColor $(if ($pending -gt 0) { "Yellow" } else { "Green" })

        Write-Host "`nEfficiency Metrics:" -ForegroundColor Cyan
        Write-Host "  Average Turns to Resolve: " -NoNewline -ForegroundColor Gray

        $avgTurns = $data.metadata.avg_turns_to_resolve
        $color = if ($avgTurns -le 1.5) { "Green" } elseif ($avgTurns -le 3.0) { "Yellow" } else { "Red" }
        Write-Host "$avgTurns" -ForegroundColor $color

        # Single-turn resolution rate
        $singleTurn = ($data.interactions | Where-Object { $_.status -eq "resolved" -and $_.turns_to_resolve -eq 1 }).Count
        if ($resolved -gt 0) {
            $singleTurnRate = [Math]::Round(($singleTurn / $resolved) * 100, 1)
            Write-Host "  Single-Turn Resolution: " -NoNewline -ForegroundColor Gray
            $color = if ($singleTurnRate -gt 80) { "Green" } elseif ($singleTurnRate -gt 50) { "Yellow" } else { "Red" }
            Write-Host "$singleTurnRate%" -ForegroundColor $color
        }

        # Response time
        $timedInteractions = $data.interactions | Where-Object { $_.status -eq "resolved" -and $_.time_to_resolve_seconds }
        if ($timedInteractions.Count -gt 0) {
            $avgTime = ($timedInteractions | Measure-Object -Property time_to_resolve_seconds -Average).Average
            Write-Host "  Average Response Time: " -NoNewline -ForegroundColor Gray
            if ($avgTime -lt 60) {
                Write-Host "$([Math]::Round($avgTime, 1))s" -ForegroundColor Green
            } else {
                Write-Host "$([Math]::Round($avgTime / 60, 1))m" -ForegroundColor Yellow
            }
        }

        # Recent interactions
        Write-Host "`nRecent Interactions:" -ForegroundColor Cyan
        foreach ($interaction in ($data.interactions | Select-Object -Last 5)) {
            $statusSymbol = if ($interaction.status -eq "resolved") { "✅" } else { "⏳" }
            Write-Host "  $statusSymbol " -NoNewline -ForegroundColor DarkGray
            Write-Host $interaction.question -NoNewline -ForegroundColor White

            if ($interaction.status -eq "resolved") {
                Write-Host " ($($interaction.turns_to_resolve) turn$(if ($interaction.turns_to_resolve -gt 1) { 's' }))" -ForegroundColor Gray
            } else {
                Write-Host " (pending)" -ForegroundColor Yellow
            }
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host ""
    }

    'analyze' {
        $resolved = $data.interactions | Where-Object { $_.status -eq "resolved" }

        if ($resolved.Count -lt 5) {
            Write-Host "⚠️  Not enough data for analysis (need 5+ resolved interactions)" -ForegroundColor Yellow
            return
        }

        Write-Host "`n🔍 COMMUNICATION PATTERN ANALYSIS" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

        # Multi-turn questions (might indicate poor initial questions)
        $multiTurn = $resolved | Where-Object { $_.turns_to_resolve -gt 2 }
        if ($multiTurn.Count -gt 0) {
            Write-Host "⚠️  High-Turn Interactions ($($multiTurn.Count)):" -ForegroundColor Yellow
            foreach ($interaction in ($multiTurn | Select-Object -First 3)) {
                Write-Host "   • " -NoNewline -ForegroundColor DarkGray
                Write-Host $interaction.question -NoNewline -ForegroundColor Yellow
                Write-Host " ($($interaction.turns_to_resolve) turns)" -ForegroundColor Red
            }
            Write-Host "   💡 Consider: More specific initial questions" -ForegroundColor Cyan
        }

        # Question patterns
        Write-Host "`n📝 Common Question Patterns:" -ForegroundColor Cyan
        $questionWords = @{}
        foreach ($interaction in $resolved) {
            $words = $interaction.question -split '\s+' | Where-Object { $_.Length -gt 3 }
            foreach ($word in $words) {
                $word = $word.ToLower()
                if ($questionWords.ContainsKey($word)) {
                    $questionWords[$word]++
                } else {
                    $questionWords[$word] = 1
                }
            }
        }

        $topWords = $questionWords.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 5
        foreach ($wordEntry in $topWords) {
            Write-Host "   • " -NoNewline -ForegroundColor DarkGray
            Write-Host "$($wordEntry.Key): " -NoNewline -ForegroundColor White
            Write-Host "$($wordEntry.Value) times" -ForegroundColor Gray
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host ""
    }
}
