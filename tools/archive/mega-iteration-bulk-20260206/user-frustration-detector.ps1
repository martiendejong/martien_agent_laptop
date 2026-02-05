# user-frustration-detector.ps1
# Detect signals of user frustration to avoid annoying behavior

param(
    [ValidateSet('check', 'log', 'report')]
    [string]$Action = 'check',

    [string]$UserMessage,

    [string[]]$RecentBehaviors = @()
)

$detectorPath = "C:\scripts\agentidentity\state\frustration-signals.yaml"

# Frustration signal patterns
$frustrationPatterns = @{
    explicit = @{
        patterns = @(
            "stop asking",
            "just do it",
            "don't ask",
            "you're asking too much",
            "stop",
            "enough questions",
            "figure it out",
            "use your judgment"
        )
        severity = "high"
    }
    implicit = @{
        patterns = @(
            "come on",
            "really\?",
            "seriously\?",
            "again\?",
            "^yes$",
            "^no$",
            "^ok$",
            "^fine$",
            "whatever"
        )
        severity = "medium"
    }
    behavioral = @{
        patterns = @(
            "repeated_question",  # Asked same thing twice
            "slow_response",      # User took long to respond
            "short_answer",       # User gave minimal answer
            "context_switch"      # User changed topic suddenly
        )
        severity = "low"
    }
}

# Risk factors in recent behaviors
$riskFactors = @{
    "asked_without_investigation" = @{
        description = "Asked question without gathering context first"
        risk = "high"
    }
    "multiple_clarifications" = @{
        description = "Asked multiple clarifying questions in a row"
        risk = "high"
    }
    "obvious_question" = @{
        description = "Asked question with obvious answer"
        risk = "medium"
    }
    "repeated_same_question" = @{
        description = "Asked same question user already answered"
        risk = "high"
    }
    "asked_before_trying" = @{
        description = "Asked permission when should have just done it"
        risk = "medium"
    }
}

# Initialize if doesn't exist
if (-not (Test-Path $detectorPath)) {
    @{
        signals = @()
        metadata = @{
            created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            total_signals = 0
            frustration_level = "none"
        }
    } | ConvertTo-Yaml | Out-File -FilePath $detectorPath -Encoding UTF8
}

# Read current data
$data = Get-Content $detectorPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'check' {
        if (-not $UserMessage) {
            Write-Host "⚠️  No user message provided to check" -ForegroundColor Yellow
            return
        }

        $detected = @()
        $maxSeverity = "none"

        # Check explicit patterns
        foreach ($pattern in $frustrationPatterns.explicit.patterns) {
            if ($UserMessage -match $pattern) {
                $detected += @{
                    type = "explicit"
                    pattern = $pattern
                    severity = $frustrationPatterns.explicit.severity
                }
                $maxSeverity = "high"
            }
        }

        # Check implicit patterns
        if ($maxSeverity -ne "high") {
            foreach ($pattern in $frustrationPatterns.implicit.patterns) {
                if ($UserMessage -match $pattern) {
                    $detected += @{
                        type = "implicit"
                        pattern = $pattern
                        severity = $frustrationPatterns.implicit.severity
                    }
                    if ($maxSeverity -ne "high") {
                        $maxSeverity = "medium"
                    }
                }
            }
        }

        # Check risk factors in recent behaviors
        $risks = @()
        foreach ($behavior in $RecentBehaviors) {
            if ($riskFactors.ContainsKey($behavior)) {
                $risks += @{
                    behavior = $behavior
                    description = $riskFactors[$behavior].description
                    risk = $riskFactors[$behavior].risk
                }
            }
        }

        if ($detected.Count -gt 0 -or $risks.Count -gt 0) {
            # Log the signal
            $signal = @{
                timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                user_message = $UserMessage
                detected_patterns = $detected
                risk_factors = $risks
                severity = $maxSeverity
            }

            $data.signals += $signal
            $data.metadata.total_signals++

            # Update frustration level based on recent signals
            $recentSignals = $data.signals | Where-Object {
                $signalTime = [DateTime]::ParseExact($_.timestamp, "yyyy-MM-dd HH:mm:ss", $null)
                ((Get-Date) - $signalTime).TotalMinutes -lt 30
            }

            if ($recentSignals.Count -ge 3) {
                $data.metadata.frustration_level = "high"
            } elseif ($recentSignals.Count -eq 2) {
                $data.metadata.frustration_level = "medium"
            } elseif ($recentSignals.Count -eq 1) {
                $data.metadata.frustration_level = "low"
            } else {
                $data.metadata.frustration_level = "none"
            }

            $data | ConvertTo-Yaml | Out-File -FilePath $detectorPath -Encoding UTF8

            # Output warning
            Write-Host "`n⚠️  FRUSTRATION SIGNAL DETECTED" -ForegroundColor Red
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
            Write-Host "Severity: " -NoNewline -ForegroundColor Gray

            $color = switch ($maxSeverity) {
                'high' { "Red" }
                'medium' { "Yellow" }
                'low' { "Cyan" }
                default { "DarkGray" }
            }
            Write-Host $maxSeverity.ToUpper() -ForegroundColor $color

            if ($detected.Count -gt 0) {
                Write-Host "`nDetected Patterns:" -ForegroundColor Cyan
                foreach ($d in $detected) {
                    Write-Host "  • " -NoNewline -ForegroundColor DarkGray
                    Write-Host "[$($d.type)] " -NoNewline -ForegroundColor Yellow
                    Write-Host $d.pattern -ForegroundColor White
                }
            }

            if ($risks.Count -gt 0) {
                Write-Host "`nRisk Factors:" -ForegroundColor Cyan
                foreach ($r in $risks) {
                    Write-Host "  • " -NoNewline -ForegroundColor DarkGray
                    Write-Host $r.description -ForegroundColor Yellow
                    Write-Host "    Risk: " -NoNewline -ForegroundColor DarkGray
                    Write-Host $r.risk -ForegroundColor $(if ($r.risk -eq "high") { "Red" } else { "Yellow" })
                }
            }

            Write-Host "`n💡 RECOMMENDED ACTIONS:" -ForegroundColor Cyan
            switch ($maxSeverity) {
                'high' {
                    Write-Host "  1. Stop asking questions immediately" -ForegroundColor Red
                    Write-Host "  2. Use best judgment and proceed" -ForegroundColor Red
                    Write-Host "  3. Gather context autonomously before any future questions" -ForegroundColor Red
                }
                'medium' {
                    Write-Host "  1. Reduce question frequency" -ForegroundColor Yellow
                    Write-Host "  2. Investigate context before asking" -ForegroundColor Yellow
                    Write-Host "  3. Ask only essential questions" -ForegroundColor Yellow
                }
                'low' {
                    Write-Host "  1. Be more decisive" -ForegroundColor Cyan
                    Write-Host "  2. Ask fewer clarifying questions" -ForegroundColor Cyan
                }
            }

            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

            return $signal
        } else {
            Write-Host "✅ No frustration signals detected" -ForegroundColor Green
            return $null
        }
    }

    'log' {
        if (-not $UserMessage) {
            Write-Host "❌ Error: -UserMessage required" -ForegroundColor Red
            return
        }

        # Log without checking patterns (manual log)
        $signal = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            user_message = $UserMessage
            risk_factors = $RecentBehaviors | ForEach-Object {
                @{
                    behavior = $_
                    description = if ($riskFactors.ContainsKey($_)) { $riskFactors[$_].description } else { $_ }
                    risk = if ($riskFactors.ContainsKey($_)) { $riskFactors[$_].risk } else { "unknown" }
                }
            }
            severity = "manual"
        }

        $data.signals += $signal
        $data.metadata.total_signals++
        $data | ConvertTo-Yaml | Out-File -FilePath $detectorPath -Encoding UTF8

        Write-Host "✅ Frustration signal logged manually" -ForegroundColor Cyan
    }

    'report' {
        if ($data.signals.Count -eq 0) {
            Write-Host "`n📊 No frustration signals detected yet" -ForegroundColor Green
            return
        }

        Write-Host "`n📊 FRUSTRATION DETECTION REPORT" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

        Write-Host "Total Signals: " -NoNewline -ForegroundColor Gray
        Write-Host $data.metadata.total_signals -ForegroundColor White
        Write-Host "Current Level: " -NoNewline -ForegroundColor Gray

        $level = $data.metadata.frustration_level
        $color = switch ($level) {
            'high' { "Red" }
            'medium' { "Yellow" }
            'low' { "Cyan" }
            default { "Green" }
        }
        Write-Host $level.ToUpper() -ForegroundColor $color

        # Recent signals (last 24 hours)
        $recentSignals = $data.signals | Where-Object {
            $signalTime = [DateTime]::ParseExact($_.timestamp, "yyyy-MM-dd HH:mm:ss", $null)
            ((Get-Date) - $signalTime).TotalHours -lt 24
        }

        if ($recentSignals.Count -gt 0) {
            Write-Host "`nRecent Signals (24h):" -ForegroundColor Cyan
            foreach ($signal in ($recentSignals | Select-Object -Last 5)) {
                Write-Host "  • " -NoNewline -ForegroundColor DarkGray
                Write-Host "$($signal.timestamp) - " -NoNewline -ForegroundColor DarkGray
                Write-Host $signal.user_message -NoNewline -ForegroundColor White
                Write-Host " [$($signal.severity)]" -ForegroundColor $(
                    switch ($signal.severity) {
                        'high' { "Red" }
                        'medium' { "Yellow" }
                        'low' { "Cyan" }
                        default { "DarkGray" }
                    }
                )
            }
        }

        # Most common risk factors
        $allRisks = $data.signals | ForEach-Object { $_.risk_factors } | Where-Object { $_ } | ForEach-Object { $_.behavior }
        if ($allRisks.Count -gt 0) {
            Write-Host "`nMost Common Risk Factors:" -ForegroundColor Cyan
            $riskGroups = $allRisks | Group-Object | Sort-Object -Property Count -Descending | Select-Object -First 5
            foreach ($riskGroup in $riskGroups) {
                Write-Host "  • " -NoNewline -ForegroundColor DarkGray
                Write-Host "$($riskGroup.Name): " -NoNewline -ForegroundColor Yellow
                Write-Host "$($riskGroup.Count) times" -ForegroundColor Gray
            }
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host ""
    }
}
