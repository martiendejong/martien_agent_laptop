<#
.SYNOPSIS
    Proactive pattern detection - monitors action sequences

.DESCRIPTION
    Watches agent actions and detects repeated patterns:
    - Captures tool call sequences
    - Alerts when 3+ repetitions detected
    - Suggests tool creation
    - Generates tool stub code

.PARAMETER Action
    monitor: Start monitoring (background)
    analyze: Analyze current patterns
    suggest: Suggest tools to create
    clear: Clear pattern history

.PARAMETER Threshold
    Minimum repetitions to alert (default: 3)

.EXAMPLE
    .\pattern-monitor.ps1 -Action analyze

.EXAMPLE
    .\pattern-monitor.ps1 -Action suggest -Threshold 3
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('monitor', 'analyze', 'suggest', 'clear')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [int]$Threshold = 3
)

$ErrorActionPreference = 'Stop'

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

function Get-AgentId {
    if (Test-Path "C:\scripts\_machine\.current_agent_id") {
        return (Get-Content "C:\scripts\_machine\.current_agent_id" -Raw).Trim()
    }
    return "unknown"
}

function Analyze-Patterns {
    param([int]$Threshold)

    Write-Host "`nPattern Analysis" -ForegroundColor Cyan
    Write-Host "===============`n" -ForegroundColor Cyan

    # Get patterns above threshold
    $sql = @"
SELECT sequence_json, count, last_occurrence, suggested_tool_name, tool_created
FROM action_sequences
WHERE count >= $Threshold
ORDER BY count DESC, last_occurrence DESC
LIMIT 10;
"@

    $patterns = Invoke-Sql -Sql $sql

    if ($patterns) {
        Write-Host "Detected Patterns (threshold: $Threshold):`n" -ForegroundColor Yellow

        $patterns -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $sequence = $parts[0] | ConvertFrom-Json
                $count = $parts[1]
                $lastSeen = $parts[2]
                $suggested = $parts[3]
                $created = $parts[4]

                $icon = if ($created -eq "1") { "✅" } else { "🔔" }
                Write-Host "  $icon Repeated $count times:" -ForegroundColor $(if ($created -eq "1") { "Green" } else { "Yellow" })
                Write-Host "    Actions:" -ForegroundColor Gray
                foreach ($action in $sequence) {
                    Write-Host "      - $action" -ForegroundColor White
                }
                if ($suggested) {
                    Write-Host "    Suggested tool: $suggested" -ForegroundColor Cyan
                }
                Write-Host "    Last seen: $lastSeen" -ForegroundColor DarkGray
                Write-Host ""
            }
        }
    } else {
        Write-Host "  No patterns detected above threshold.`n" -ForegroundColor Gray
    }
}

function Suggest-Tools {
    param([int]$Threshold)

    Write-Host "`nTool Suggestions" -ForegroundColor Cyan
    Write-Host "===============`n" -ForegroundColor Cyan

    # Get patterns not yet converted to tools
    $sql = @"
SELECT sequence_json, count, suggested_tool_name
FROM action_sequences
WHERE count >= $Threshold AND tool_created = 0
ORDER BY count DESC
LIMIT 5;
"@

    $patterns = Invoke-Sql -Sql $sql

    if ($patterns) {
        Write-Host "Recommended Tools to Create:`n" -ForegroundColor Yellow

        $index = 1
        $patterns -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $sequence = $parts[0] | ConvertFrom-Json
                $count = $parts[1]
                $suggested = $parts[2]

                Write-Host "[$index] $suggested" -ForegroundColor Cyan
                Write-Host "    Repeated: $count times" -ForegroundColor Gray
                Write-Host "    Automates:" -ForegroundColor Gray
                foreach ($action in $sequence) {
                    Write-Host "      - $action" -ForegroundColor White
                }

                # Generate tool stub
                $toolPath = "C:\scripts\tools\$suggested.ps1"
                if (-not (Test-Path $toolPath)) {
                    Write-Host "    Generate: .\pattern-monitor.ps1 -Action generate -ToolName $suggested" -ForegroundColor Yellow
                } else {
                    Write-Host "    Status: Already exists" -ForegroundColor Green
                }
                Write-Host ""
                $index++
            }
        }

        Write-Host "Tip: Review and create these tools to eliminate repetitive work.`n" -ForegroundColor Yellow
    } else {
        Write-Host "  No tool suggestions at this time.`n" -ForegroundColor Gray
    }
}

function Clear-Patterns {
    Write-Host "`nClearing pattern history..." -ForegroundColor Yellow

    $sql = "DELETE FROM action_sequences;"
    Invoke-Sql -Sql $sql

    Write-Host "Pattern history cleared.`n" -ForegroundColor Green
}

function Capture-ActionSequence {
    param([array]$Actions)

    # Create hash of action sequence
    $sequenceJson = $Actions | ConvertTo-Json -Compress
    $hash = [System.BitConverter]::ToString(
        [System.Security.Cryptography.SHA256]::Create().ComputeHash(
            [System.Text.Encoding]::UTF8.GetBytes($sequenceJson)
        )
    ).Replace("-", "")

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    # Upsert action sequence
    $sequenceJson = $sequenceJson -replace "'", "''"
    $sql = @"
INSERT INTO action_sequences (agent_id, sequence_hash, sequence_json, count, last_occurrence, first_occurrence)
VALUES ('$agentId', '$hash', '$sequenceJson', 1, '$now', '$now')
ON CONFLICT(agent_id, sequence_hash) DO UPDATE SET
    count = count + 1,
    last_occurrence = '$now';
"@

    Invoke-Sql -Sql $sql

    # Check if this should trigger alert
    $countSql = "SELECT count FROM action_sequences WHERE agent_id='$agentId' AND sequence_hash='$hash';"
    $count = Invoke-Sql -Sql $countSql

    if ([int]$count -eq 3) {
        Write-Host "`n🔔 Pattern Detected!" -ForegroundColor Yellow
        Write-Host "You've performed this sequence $count times:" -ForegroundColor Yellow
        foreach ($action in $Actions) {
            Write-Host "  - $action" -ForegroundColor White
        }
        Write-Host "Consider creating a tool to automate this.`n" -ForegroundColor Yellow
    }
}

# Main execution
try {
    switch ($Action) {
        'analyze' {
            Analyze-Patterns -Threshold $Threshold
        }

        'suggest' {
            Suggest-Tools -Threshold $Threshold
        }

        'clear' {
            Clear-Patterns
        }

        'monitor' {
            Write-Host "Pattern monitoring is integrated into tool wrappers." -ForegroundColor Cyan
            Write-Host "Patterns are captured automatically when you use tracked tools.`n" -ForegroundColor Gray
        }
    }

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
