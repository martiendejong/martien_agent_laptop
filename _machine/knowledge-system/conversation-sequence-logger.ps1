# Conversation Sequence Logger - R03-001
# Log each query → context accessed → next query sequence for training data
# Expert: Dr. Isabella Costa - Sequence Mining Expert

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('log', 'view', 'stats', 'export')]
    [string]$Action = 'log',

    [Parameter(Mandatory=$false)]
    [string]$Query,

    [Parameter(Mandatory=$false)]
    [string[]]$ContextFiles,

    [Parameter(Mandatory=$false)]
    [string]$NextQuery
)

$SequenceFile = "C:\scripts\_machine\knowledge-system\sequences.jsonl"

function Log-ConversationSequence {
    param(
        [string]$Query,
        [string[]]$ContextFiles,
        [string]$NextQuery
    )

    $sequence = @{
        'timestamp' = Get-Date -Format 'o'
        'query' = $Query
        'context_files' = $ContextFiles
        'next_query' = $NextQuery
        'hour_of_day' = (Get-Date).Hour
        'day_of_week' = (Get-Date).DayOfWeek.ToString()
        'session_id' = $env:CLAUDE_SESSION_ID ?? "unknown"
    } | ConvertTo-Json -Compress

    Add-Content -Path $SequenceFile -Value $sequence -Encoding UTF8
    Write-Host "Logged sequence: $Query" -ForegroundColor Green
}

function View-Sequences {
    if (-not (Test-Path $SequenceFile)) {
        Write-Host "No sequences logged yet" -ForegroundColor Yellow
        return
    }

    $sequences = Get-Content $SequenceFile | ForEach-Object { $_ | ConvertFrom-Json }
    $sequences | Select-Object timestamp, query, @{N='files';E={$_.context_files.Count}}, next_query | Format-Table -AutoSize
}

function Get-SequenceStats {
    if (-not (Test-Path $SequenceFile)) {
        Write-Host "No sequences logged yet" -ForegroundColor Yellow
        return
    }

    $sequences = Get-Content $SequenceFile | ForEach-Object { $_ | ConvertFrom-Json }

    $stats = @{
        'total_sequences' = $sequences.Count
        'unique_queries' = ($sequences.query | Sort-Object -Unique).Count
        'avg_context_files' = ($sequences | ForEach-Object { $_.context_files.Count } | Measure-Object -Average).Average
        'most_common_hour' = ($sequences.hour_of_day | Group-Object | Sort-Object Count -Descending | Select-Object -First 1).Name
        'most_common_day' = ($sequences.day_of_week | Group-Object | Sort-Object Count -Descending | Select-Object -First 1).Name
        'first_sequence' = $sequences[0].timestamp
        'last_sequence' = $sequences[-1].timestamp
    }

    Write-Host "`nConversation Sequence Statistics:" -ForegroundColor Cyan
    Write-Host "===================================" -ForegroundColor Cyan
    $stats | ConvertTo-Json -Depth 3
}

function Export-SequencesForTraining {
    if (-not (Test-Path $SequenceFile)) {
        Write-Host "No sequences logged yet" -ForegroundColor Yellow
        return
    }

    $exportFile = "C:\scripts\_machine\knowledge-system\sequences-training-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

    $sequences = Get-Content $SequenceFile | ForEach-Object { $_ | ConvertFrom-Json }

    $trainingData = @{
        'metadata' = @{
            'exported' = Get-Date -Format 'o'
            'total_sequences' = $sequences.Count
            'date_range' = @{
                'start' = $sequences[0].timestamp
                'end' = $sequences[-1].timestamp
            }
        }
        'sequences' = $sequences
    }

    $trainingData | ConvertTo-Json -Depth 10 | Out-File $exportFile -Encoding UTF8
    Write-Host "Exported training data to $exportFile" -ForegroundColor Green
}

# Main execution
switch ($Action) {
    'log' {
        if (-not $Query) {
            Write-Host "Query required for log operation" -ForegroundColor Red
            exit 1
        }
        Log-ConversationSequence -Query $Query -ContextFiles $ContextFiles -NextQuery $NextQuery
    }
    'view' {
        View-Sequences
    }
    'stats' {
        Get-SequenceStats
    }
    'export' {
        Export-SequencesForTraining
    }
}
