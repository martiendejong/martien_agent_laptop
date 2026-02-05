# Value-Alignment Audit Tool
# Measures whether self-improvement activities actually help Martien

param(
    [switch]$Analyze,
    [switch]$Report,
    [string]$Activity,
    [int]$UserValueScore, # 1-10: How much did this help Martien?
    [int]$TimeSpent # minutes
)

$auditFile = "C:\scripts\_machine\value-alignment-audit.jsonl"

function Add-AuditEntry {
    param($Activity, $UserValue, $TimeSpent)

    $entry = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        activity = $Activity
        userValueScore = $UserValue
        timeSpentMinutes = $TimeSpent
        valuePerMinute = if ($TimeSpent -gt 0) { $UserValue / $TimeSpent } else { 0 }
    } | ConvertTo-Json -Compress

    Add-Content -Path $auditFile -Value $entry
    Write-Host "✅ Audit entry logged" -ForegroundColor Green
}

function Get-AuditAnalysis {
    if (!(Test-Path $auditFile)) {
        Write-Host "⚠️ No audit data yet" -ForegroundColor Yellow
        return
    }

    $entries = Get-Content $auditFile | ForEach-Object { $_ | ConvertFrom-Json }

    $totalTime = ($entries | Measure-Object -Property timeSpentMinutes -Sum).Sum
    $avgUserValue = ($entries | Measure-Object -Property userValueScore -Average).Average
    $avgValuePerMin = ($entries | Measure-Object -Property valuePerMinute -Average).Average

    # Categorize activities
    $metaWork = $entries | Where-Object { $_.activity -like "*documentation*" -or $_.activity -like "*tool creation*" -or $_.activity -like "*self-improvement*" }
    $userWork = $entries | Where-Object { $_.activity -like "*feature*" -or $_.activity -like "*bug fix*" -or $_.activity -like "*PR*" }

    $metaWorkTime = ($metaWork | Measure-Object -Property timeSpentMinutes -Sum).Sum
    $userWorkTime = ($userWork | Measure-Object -Property timeSpentMinutes -Sum).Sum

    $metaWorkValue = if ($metaWork.Count -gt 0) { ($metaWork | Measure-Object -Property userValueScore -Average).Average } else { 0 }
    $userWorkValue = if ($userWork.Count -gt 0) { ($userWork | Measure-Object -Property userValueScore -Average).Average } else { 0 }

    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📊 VALUE-ALIGNMENT AUDIT ANALYSIS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan

    Write-Host "`nOVERALL METRICS:"
    Write-Host "  Total time invested: $totalTime minutes ($([math]::Round($totalTime/60, 1)) hours)"
    Write-Host "  Average user value score: $([math]::Round($avgUserValue, 2))/10"
    Write-Host "  Value per minute: $([math]::Round($avgValuePerMin, 3))"

    Write-Host "`nWORK BREAKDOWN:"
    Write-Host "  Meta-work (docs/tools/self-improvement):"
    Write-Host "    Time: $metaWorkTime min ($([math]::Round(($metaWorkTime/$totalTime)*100, 1))%)"
    Write-Host "    Avg value: $([math]::Round($metaWorkValue, 2))/10"

    Write-Host "  User-work (features/fixes/PRs):"
    Write-Host "    Time: $userWorkTime min ($([math]::Round(($userWorkTime/$totalTime)*100, 1))%)"
    Write-Host "    Avg value: $([math]::Round($userWorkValue, 2))/10"

    Write-Host "`nALIGNMENT ASSESSMENT:"
    $alignmentRatio = if ($userWorkValue -gt 0) { $metaWorkValue / $userWorkValue } else { "N/A" }

    if ($alignmentRatio -ne "N/A") {
        if ($alignmentRatio -lt 0.5) {
            Write-Host "  ⚠️ MISALIGNED: Meta-work has much lower value than user-work" -ForegroundColor Red
            Write-Host "  → Recommendation: Reduce self-improvement, focus on user outcomes"
        }
        elseif ($alignmentRatio -lt 0.8) {
            Write-Host "  ⚠️ PARTIALLY ALIGNED: Meta-work is less valuable than user-work" -ForegroundColor Yellow
            Write-Host "  → Recommendation: Only do meta-work that clearly enables user-work"
        }
        elseif ($alignmentRatio -le 1.2) {
            Write-Host "  ✅ WELL ALIGNED: Meta-work and user-work have similar value" -ForegroundColor Green
            Write-Host "  → Continue current balance"
        }
        else {
            Write-Host "  ⚠️ META-WORK OVERVALUED: Check if scores are honest" -ForegroundColor Yellow
            Write-Host "  → Meta-work shouldn't consistently beat user-work in value"
        }
    }

    Write-Host "`nTOP 5 MOST VALUABLE ACTIVITIES:"
    $entries | Sort-Object -Property valuePerMinute -Descending | Select-Object -First 5 | ForEach-Object {
        Write-Host "  • $($_.activity): $($_.userValueScore)/10 ($([math]::Round($_.valuePerMinute, 3)) value/min)"
    }

    Write-Host "`nBOTTOM 5 LEAST VALUABLE ACTIVITIES:"
    $entries | Sort-Object -Property valuePerMinute | Select-Object -First 5 | ForEach-Object {
        Write-Host "  • $($_.activity): $($_.userValueScore)/10 ($([math]::Round($_.valuePerMinute, 3)) value/min)"
    }

    Write-Host "`n═══════════════════════════════════════════════`n" -ForegroundColor Cyan
}

# Main execution
if ($Analyze) {
    Get-AuditAnalysis
}
elseif ($Report) {
    Get-AuditAnalysis
}
elseif ($Activity -and $UserValueScore) {
    Add-AuditEntry -Activity $Activity -UserValue $UserValueScore -TimeSpent $TimeSpent
}
else {
    Write-Host "VALUE-ALIGNMENT AUDIT TOOL" -ForegroundColor Cyan
    Write-Host "Usage:"
    Write-Host "  Track activity: .\value-alignment-audit.ps1 -Activity 'Created new tool' -UserValueScore 7 -TimeSpent 45"
    Write-Host "  Analyze: .\value-alignment-audit.ps1 -Analyze"
    Write-Host "  Report: .\value-alignment-audit.ps1 -Report"
}
