<#
.SYNOPSIS
    Detect improvement requests in user messages and proactively implement or ask

.DESCRIPTION
    Analyzes user messages for patterns indicating they want:
    - New tools created
    - New skills created
    - Documentation updates
    - System improvements

    Either implements automatically (if confident) or asks user for approval first.

.PARAMETER UserMessage
    The user's message to analyze

.PARAMETER AutoImplement
    If set, automatically implement high-confidence improvements without asking

.PARAMETER DryRun
    Show what would be implemented without actually doing it

.EXAMPLE
    .\improvement-detector.ps1 -UserMessage "can you make a tool for that?"

.EXAMPLE
    .\improvement-detector.ps1 -UserMessage "update your insights with this" -AutoImplement
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$UserMessage,

    [Parameter(Mandatory=$false)]
    [switch]$AutoImplement,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$APPSETTINGS_PATH = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"
$PATTERNS_FILE = "C:\scripts\_machine\improvement-patterns.jsonl"

function Load-ApiKey {
    if (-not (Test-Path $APPSETTINGS_PATH)) {
        throw "appsettings.Secrets.json not found"
    }

    $secrets = Get-Content $APPSETTINGS_PATH -Raw | ConvertFrom-Json
    return $secrets.ApiSettings.OpenApiKey
}

function Detect-ImprovementRequest {
    param([string]$Message)

    # Pattern matching for common improvement requests
    $patterns = @{
        "tool_request" = @(
            "can you make a tool",
            "create a tool",
            "build a tool",
            "write a tool",
            "make a script"
        )
        "skill_request" = @(
            "can you make a skill",
            "create a skill",
            "build a skill",
            "add to skills"
        )
        "insights_update" = @(
            "update your insights",
            "update personal insights",
            "remember this",
            "write this down",
            "document this"
        )
        "reminder_request" = @(
            "remind me",
            "set a reminder",
            "don't forget",
            "remember to"
        )
        "documentation_update" = @(
            "update the docs",
            "update CLAUDE.md",
            "add to documentation"
        )
        "automation_request" = @(
            "automate this",
            "make this automatic",
            "can this be automated"
        )
    }

    $detected = @()
    $lowerMessage = $Message.ToLower()

    foreach ($type in $patterns.Keys) {
        foreach ($pattern in $patterns[$type]) {
            if ($lowerMessage -match [regex]::Escape($pattern)) {
                $detected += @{
                    type = $type
                    pattern = $pattern
                    confidence = "high"
                }
                break
            }
        }
    }

    return $detected
}

function Analyze-WithAI {
    param([string]$Message, [string]$ApiKey)

    $systemPrompt = @"
You are an improvement detector for a Claude AI agent system.

Analyze the user message and determine if they're requesting:
1. New tool creation
2. New skill creation
3. Documentation updates (insights, CLAUDE.md, etc.)
4. Reminder to be set
5. Automation/system improvement
6. None of the above

For each detected request, provide:
- type: tool|skill|docs|reminder|automation|none
- confidence: high|medium|low
- description: what specifically to implement
- auto_implementable: true|false (can Claude do this autonomously?)

Output JSON:
{
  "requests": [
    {
      "type": "tool",
      "confidence": "high",
      "description": "Create reminder system with scheduled tasks",
      "auto_implementable": true
    }
  ]
}
"@

    $headers = @{
        "Content-Type" = "application/json; charset=utf-8"
        "Authorization" = "Bearer $ApiKey"
    }

    $systemPromptEscaped = $systemPrompt -replace '\\', '\\' -replace '"', '\"' -replace "`n", '\n' -replace "`r", ''
    $userPromptEscaped = $Message -replace '\\', '\\' -replace '"', '\"' -replace "`n", '\n' -replace "`r", ''

    $body = @"
{
  "model": "gpt-4o",
  "messages": [
    {"role": "system", "content": "$systemPromptEscaped"},
    {"role": "user", "content": "$userPromptEscaped"}
  ],
  "temperature": 0.3,
  "max_tokens": 1000,
  "response_format": {"type": "json_object"}
}
"@

    try {
        $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
            -Method Post -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 60

        $content = $response.choices[0].message.content
        $result = $content | ConvertFrom-Json

        return $result.requests
    } catch {
        Write-Host "❌ AI analysis error: $_" -ForegroundColor Red
        return @()
    }
}

function Log-Pattern {
    param($Message, $Detected)

    $entry = @{
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        message = $Message
        detected = $Detected
    } | ConvertTo-Json -Depth 10 -Compress

    $dir = Split-Path $PATTERNS_FILE
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    Add-Content -Path $PATTERNS_FILE -Value $entry
}

function Show-Detected {
    param($Requests)

    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🔍 IMPROVEMENT REQUESTS DETECTED" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Cyan

    $i = 1
    foreach ($req in $Requests) {
        $icon = switch ($req.type) {
            "tool" { "🔧" }
            "skill" { "🎯" }
            "docs" { "📝" }
            "reminder" { "⏰" }
            "automation" { "⚙️" }
            default { "❓" }
        }

        $confidenceColor = switch ($req.confidence) {
            "high" { "Green" }
            "medium" { "Yellow" }
            "low" { "Red" }
            default { "White" }
        }

        Write-Host "$i. $icon " -NoNewline
        Write-Host "$($req.type.ToUpper())" -NoNewline -ForegroundColor Cyan
        Write-Host " (Confidence: " -NoNewline
        Write-Host "$($req.confidence)" -NoNewline -ForegroundColor $confidenceColor
        Write-Host ")"

        Write-Host "   Description: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($req.description)" -ForegroundColor White

        if ($req.auto_implementable) {
            Write-Host "   ✅ Can be auto-implemented" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Requires manual implementation or approval" -ForegroundColor Yellow
        }

        Write-Host ""
        $i++
    }

    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Cyan
}

# Main execution
try {
    Write-Host "🔍 Analyzing message for improvement requests..." -ForegroundColor Cyan

    # Pattern matching (fast, deterministic)
    $patternDetected = Detect-ImprovementRequest -Message $UserMessage

    # AI analysis (slower, more nuanced)
    $apiKey = Load-ApiKey
    $aiDetected = Analyze-WithAI -Message $UserMessage -ApiKey $apiKey

    # Combine results
    $allDetected = $aiDetected

    if ($allDetected.Count -eq 0) {
        Write-Host "✅ No improvement requests detected in message" -ForegroundColor Green
        exit 0
    }

    # Log for learning
    Log-Pattern -Message $UserMessage -Detected $allDetected

    # Show what was detected
    Show-Detected -Requests $allDetected

    # Auto-implement if requested and high confidence
    if ($AutoImplement -and -not $DryRun) {
        $autoRequests = $allDetected | Where-Object { $_.confidence -eq "high" -and $_.auto_implementable }

        if ($autoRequests.Count -gt 0) {
            Write-Host "🚀 Auto-implementing high-confidence requests..." -ForegroundColor Green

            foreach ($req in $autoRequests) {
                Write-Host "   Implementing: $($req.description)" -ForegroundColor Yellow

                # TODO: Actual implementation logic
                # This would call appropriate tools/scripts based on request type
                # For now, just log what would be done

                Write-Host "   ⚠️  Implementation logic not yet built" -ForegroundColor Yellow
            }
        } else {
            Write-Host "💡 No high-confidence auto-implementable requests found" -ForegroundColor Yellow
            Write-Host "   Claude should ask user for approval before implementing" -ForegroundColor DarkGray
        }
    }

    if ($DryRun) {
        Write-Host "💡 DRY RUN - No actions taken" -ForegroundColor Yellow
    }

} catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    exit 1
}
