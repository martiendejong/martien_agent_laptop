<#
.SYNOPSIS
    Generate FAQs for all Art Revisionist pages

.DESCRIPTION
    Wrapper script for easy bulk FAQ generation using Hazina WordPress AIO service.
    Leverages existing RegenerateQuestionsForAllEnabledPagesAsync() with retry logic.

.PARAMETER Environment
    Environment to target: Development (localhost) or Production (artrevisionist.com)
    Default: Development

.PARAMETER Delay
    Delay in milliseconds between page processing (to avoid rate limiting)
    Default: 2000 (2 seconds)

.EXAMPLE
    .\generate-all-faqs.ps1
    # Generate FAQs for all pages on localhost

.EXAMPLE
    .\generate-all-faqs.ps1 -Environment Production
    # Generate FAQs for all pages on artrevisionist.com

.NOTES
    Prerequisites:
    - FAQ prompt template must exist at C:\stores\artrevisionist\faq-generation.prompts.json
    - OPENAI_API_KEY environment variable must be set
    - Hazina API must be running
    - WordPress must be accessible (localhost or production)

    Cost Estimation:
    - 71 pages × ~2000 tokens per page = ~142,000 tokens
    - GPT-4o cost: $2.50 per 1M input tokens
    - Estimated total: ~$0.27
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Development", "Production")]
    [string]$Environment = "Development",

    [Parameter(Mandatory=$false)]
    [int]$Delay = 2000
)

# Configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

# Colors
$ColorInfo = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"

# Environment-specific URLs
$HazinaApiUrl = "http://localhost:5000" # Adjust to your Hazina API URL
$ProjectId = "artrevisionist"

# Pre-flight checks
Write-Host "`n=== FAQ Generation Pre-Flight Checks ===" -ForegroundColor $ColorInfo

# Check 1: Prompt template exists
$PromptPath = "C:\stores\artrevisionist\faq-generation.prompts.json"
if (!(Test-Path $PromptPath)) {
    Write-Host "❌ FAILED: Prompt template not found at $PromptPath" -ForegroundColor $ColorError
    Write-Host "   Create the template first using the plan specifications." -ForegroundColor $ColorWarning
    exit 1
}
Write-Host "✅ Prompt template found" -ForegroundColor $ColorSuccess

# Check 2: OpenAI API key
if ([string]::IsNullOrEmpty($env:OPENAI_API_KEY)) {
    Write-Host "❌ FAILED: OPENAI_API_KEY environment variable not set" -ForegroundColor $ColorError
    Write-Host "   Set it with: `$env:OPENAI_API_KEY = 'your-key-here'" -ForegroundColor $ColorWarning
    exit 1
}
Write-Host "✅ OpenAI API key configured" -ForegroundColor $ColorSuccess

# Check 3: Hazina API accessible
try {
    $Response = Invoke-WebRequest -Uri "$HazinaApiUrl/health" -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
    Write-Host "✅ Hazina API is accessible" -ForegroundColor $ColorSuccess
} catch {
    Write-Host "⚠️  WARNING: Could not reach Hazina API at $HazinaApiUrl" -ForegroundColor $ColorWarning
    Write-Host "   Make sure Hazina API is running before proceeding." -ForegroundColor $ColorWarning
    $Continue = Read-Host "Continue anyway? (y/n)"
    if ($Continue -ne "y") {
        exit 1
    }
}

Write-Host "`n=== Starting FAQ Generation ===" -ForegroundColor $ColorInfo
Write-Host "Environment: $Environment" -ForegroundColor $ColorInfo
Write-Host "Delay between pages: $Delay ms" -ForegroundColor $ColorInfo
Write-Host ""

# Step 1: Enable AIO for all pages (if not already enabled)
Write-Host "[1/2] Enabling AIO for all pages..." -ForegroundColor $ColorCyan

try {
    $EnableUrl = "$HazinaApiUrl/api/wordpress/bulk-toggle-aio?projectId=$ProjectId"
    Write-Host "   POST $EnableUrl" -ForegroundColor DarkGray

    $EnableResponse = Invoke-RestMethod -Uri $EnableUrl -Method POST -TimeoutSec 120

    if ($EnableResponse.failedPages -and $EnableResponse.failedPages.Count -gt 0) {
        Write-Host "   ⚠️  Some pages failed to enable:" -ForegroundColor $ColorWarning
        foreach ($failed in $EnableResponse.failedPages) {
            Write-Host "      - $failed" -ForegroundColor $ColorWarning
        }
    } else {
        Write-Host "   ✅ All pages enabled for AIO" -ForegroundColor $ColorSuccess
    }
} catch {
    Write-Host "   ❌ Failed to enable AIO: $_" -ForegroundColor $ColorError
    Write-Host "   Check Hazina API logs for details" -ForegroundColor $ColorWarning
    exit 1
}

# Step 2: Generate FAQs for all enabled pages
Write-Host "`n[2/2] Generating FAQs for all enabled pages..." -ForegroundColor $ColorCyan
Write-Host "   This may take several minutes (delay: $Delay ms per page)..." -ForegroundColor DarkGray

try {
    $GenerateUrl = "$HazinaApiUrl/api/wordpress/regenerate-all-questions?projectId=$ProjectId&delay=$Delay"
    Write-Host "   POST $GenerateUrl" -ForegroundColor DarkGray

    $StartTime = Get-Date
    $GenerateResponse = Invoke-RestMethod -Uri $GenerateUrl -Method POST -TimeoutSec 600
    $EndTime = Get-Date
    $Duration = ($EndTime - $StartTime).TotalSeconds

    if ($GenerateResponse.failedPages -and $GenerateResponse.failedPages.Count -gt 0) {
        Write-Host "   ⚠️  Some pages failed to generate FAQs:" -ForegroundColor $ColorWarning
        foreach ($failed in $GenerateResponse.failedPages) {
            Write-Host "      - $failed" -ForegroundColor $ColorWarning
        }
    } else {
        Write-Host "   ✅ All pages processed successfully" -ForegroundColor $ColorSuccess
    }

    Write-Host "   Duration: $([Math]::Round($Duration, 2)) seconds" -ForegroundColor DarkGray
} catch {
    Write-Host "   ❌ Failed to generate FAQs: $_" -ForegroundColor $ColorError
    Write-Host "   Check Hazina API logs for details" -ForegroundColor $ColorWarning
    exit 1
}

# Summary
Write-Host "`n=== FAQ Generation Complete ===" -ForegroundColor $ColorSuccess
Write-Host ""
Write-Host "Next steps:" -ForegroundColor $ColorInfo
Write-Host "1. Verify FAQs on random sample pages" -ForegroundColor DarkGray
Write-Host "2. Check for broken cross-links" -ForegroundColor DarkGray
Write-Host "3. Review FAQ quality (natural questions, accurate answers)" -ForegroundColor DarkGray
Write-Host "4. If satisfied, deploy to production (if not already)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Estimated cost: ~`$0.27 (71 pages × ~2000 tokens × GPT-4o pricing)" -ForegroundColor DarkGray
Write-Host ""
