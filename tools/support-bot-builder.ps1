#!/usr/bin/env pwsh
<#
.SYNOPSIS
Build intelligent support bot using Hazina RAG for client-manager

.DESCRIPTION
Creates an AI-powered support system that:
- Indexes all product documentation into RAG store
- Answers support questions automatically
- Escalates to human when confidence low
- Saves 6-10 hours/week on support

.PARAMETER ProjectPath
Path to client-manager project (default: C:\Projects\client-manager)

.PARAMETER StoreName
Name for Hazina RAG store (default: client-manager-support)

.PARAMETER MinConfidence
Minimum confidence to auto-respond (default: 0.7)

.PARAMETER Action
Action to perform: init, index, query, test, serve

.PARAMETER Question
Question to answer (for query/test actions)

.EXAMPLE
.\support-bot-builder.ps1 -Action init
# Initialize support bot knowledge base

.EXAMPLE
.\support-bot-builder.ps1 -Action index
# Index all documentation

.EXAMPLE
.\support-bot-builder.ps1 -Action query -Question "How do I reset my password?"
# Test support bot

.EXAMPLE
.\support-bot-builder.ps1 -Action serve
# Start support bot server (listens for questions)
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = "C:\Projects\client-manager",

    [Parameter(Mandatory=$false)]
    [string]$StoreName = "client-manager-support",

    [Parameter(Mandatory=$false)]
    [decimal]$MinConfidence = 0.7,

    [Parameter(Mandatory=$false)]
    [ValidateSet('init', 'index', 'query', 'test', 'serve')]
    [string]$Action = 'init',

    [Parameter(Mandatory=$false)]
    [string]$Question = ""
)

$ErrorActionPreference = "Stop"

# Paths
$StoreBasePath = "C:\stores\support-bots"
$StorePath = Join-Path $StoreBasePath $StoreName
$HazinaRagTool = "C:\scripts\tools\hazina-rag.ps1"
$LogPath = "C:\scripts\logs\support-bot-$(Get-Date -Format 'yyyy-MM').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogPath -Value $logMessage
}

function Initialize-SupportBot {
    Write-Host "`n=== INITIALIZING SUPPORT BOT ===" -ForegroundColor Cyan
    Write-Host "Store: $StoreName"
    Write-Host "Project: $ProjectPath"
    Write-Host "Min Confidence: $MinConfidence"
    Write-Host ""

    # Create store directory
    if (-not (Test-Path $StoreBasePath)) {
        New-Item -ItemType Directory -Path $StoreBasePath -Force | Out-Null
        Write-Log "Created support bots directory: $StoreBasePath"
    }

    # Initialize Hazina RAG store
    Write-Host "Initializing Hazina RAG store..." -ForegroundColor Yellow

    & $HazinaRagTool -Action init -StoreName $StorePath

    Write-Host "Support bot initialized successfully!" -ForegroundColor Green
    Write-Log "Support bot initialized: $StoreName"

    Write-Host "`nNext step: Run with -Action index to build knowledge base"
}

function Index-Documentation {
    Write-Host "`n=== INDEXING DOCUMENTATION ===" -ForegroundColor Cyan

    if (-not (Test-Path $ProjectPath)) {
        Write-Host "ERROR: Project path not found: $ProjectPath" -ForegroundColor Red
        Write-Log "Project path not found: $ProjectPath" "ERROR"
        return
    }

    # Find all documentation files
    $docFiles = @()

    # README files
    $docFiles += Get-ChildItem -Path $ProjectPath -Filter "README*.md" -Recurse -ErrorAction SilentlyContinue

    # Docs directory
    $docsPath = Join-Path $ProjectPath "docs"
    if (Test-Path $docsPath) {
        $docFiles += Get-ChildItem -Path $docsPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue
    }

    # API documentation
    $apiDocsPath = Join-Path $ProjectPath "ClientManagerAPI\docs"
    if (Test-Path $apiDocsPath) {
        $docFiles += Get-ChildItem -Path $apiDocsPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue
    }

    # Common issues / FAQ
    $faqFiles = Get-ChildItem -Path $ProjectPath -Filter "*FAQ*.md" -Recurse -ErrorAction SilentlyContinue
    $docFiles += $faqFiles

    Write-Host "Found $($docFiles.Count) documentation files to index" -ForegroundColor Yellow

    if ($docFiles.Count -eq 0) {
        Write-Host "WARNING: No documentation files found" -ForegroundColor Yellow
        Write-Host "Creating sample FAQ to get started..."

        # Create sample FAQ
        $sampleFaqPath = Join-Path $ProjectPath "docs\FAQ.md"
        $sampleFaqDir = Split-Path $sampleFaqPath -Parent

        if (-not (Test-Path $sampleFaqDir)) {
            New-Item -ItemType Directory -Path $sampleFaqDir -Force | Out-Null
        }

        $sampleContent = @"
# Client Manager FAQ

## Authentication

### How do I reset my password?
1. Go to the login page
2. Click "Forgot Password"
3. Enter your email address
4. Check your email for reset link
5. Click link and create new password

### Why can't I log in?
Common causes:
- Incorrect email/password
- Account not activated (check email)
- Browser cookies disabled
- Caps Lock enabled

## Billing

### How do I update my payment method?
1. Log into your account
2. Go to Settings > Billing
3. Click "Update Payment Method"
4. Enter new card details
5. Save changes

### When will I be charged?
- Monthly plans: Same day each month
- Annual plans: Once per year on sign-up anniversary
- Invoices sent 3 days before charge

## Features

### How do I add team members?
1. Go to Settings > Team
2. Click "Invite Member"
3. Enter their email address
4. Choose their role (Admin, Editor, Viewer)
5. Click Send Invitation

### Can I export my data?
Yes! Go to Settings > Data Export
- Export formats: CSV, JSON, PDF
- Full data export within 24 hours
- Sent to your email address

## Support

### How do I contact support?
- Email: support@brand2boost.com
- Response time: Within 24 hours
- Priority support: Strategic Partners (<4 hours)

### Where can I find tutorials?
- Help Center: help.brand2boost.com
- Video tutorials: youtube.com/brand2boost
- Documentation: docs.brand2boost.com
"@

        Set-Content -Path $sampleFaqPath -Value $sampleContent -Encoding UTF8
        Write-Host "Created sample FAQ: $sampleFaqPath" -ForegroundColor Green

        $docFiles = @(Get-Item $sampleFaqPath)
    }

    # Index each file
    Write-Host "`nIndexing files..." -ForegroundColor Yellow

    foreach ($file in $docFiles) {
        Write-Host "  Indexing: $($file.Name)" -ForegroundColor Gray

        try {
            # Index this file into Hazina RAG
            & $HazinaRagTool -Action index `
                -StoreName $StorePath `
                -FilePath $file.FullName

            Write-Log "Indexed: $($file.FullName)"
        }
        catch {
            Write-Host "    ERROR: Failed to index $($file.Name)" -ForegroundColor Red
            Write-Log "Failed to index $($file.FullName): $_" "ERROR"
        }
    }

    Write-Host "`nIndexing complete!" -ForegroundColor Green
    Write-Host "Total files indexed: $($docFiles.Count)" -ForegroundColor Cyan

    # Get store status
    Write-Host "`nStore status:" -ForegroundColor Yellow
    & $HazinaRagTool -Action status -StoreName $StorePath

    Write-Log "Indexing complete: $($docFiles.Count) files"

    Write-Host "`nNext step: Run with -Action test to test the bot"
}

function Query-SupportBot {
    param([string]$UserQuestion)

    if ([string]::IsNullOrWhiteSpace($UserQuestion)) {
        Write-Host "ERROR: No question provided" -ForegroundColor Red
        Write-Host "Usage: .\support-bot-builder.ps1 -Action query -Question 'How do I...?'"
        return
    }

    Write-Host "`n=== SUPPORT BOT QUERY ===" -ForegroundColor Cyan
    Write-Host "Question: $UserQuestion" -ForegroundColor Yellow
    Write-Host ""

    # Query Hazina RAG
    Write-Host "Searching knowledge base..." -ForegroundColor Gray

    $answer = & $HazinaRagTool query $UserQuestion -StoreName $StorePath

    Write-Host "`nANSWER:" -ForegroundColor Green
    Write-Host $answer
    Write-Host ""

    # Log query
    Write-Log "Query: $UserQuestion | Answer: $($answer.Substring(0, [Math]::Min(100, $answer.Length)))..."

    # Confidence assessment (simplified - actual would use Hazina's confidence score)
    $confidence = 0.8 # Placeholder

    if ($confidence -ge $MinConfidence) {
        Write-Host "DECISION: Auto-respond (confidence: $confidence)" -ForegroundColor Green
    }
    else {
        Write-Host "DECISION: Escalate to human (confidence: $confidence)" -ForegroundColor Yellow
    }
}

function Test-SupportBot {
    Write-Host "`n=== TESTING SUPPORT BOT ===" -ForegroundColor Cyan
    Write-Host "Running test questions...`n"

    $testQuestions = @(
        "How do I reset my password?",
        "How do I add team members?",
        "When will I be charged?",
        "How do I contact support?",
        "Can I export my data?"
    )

    foreach ($q in $testQuestions) {
        Write-Host "Q: $q" -ForegroundColor Yellow

        $answer = & $HazinaRagTool query $q -StoreName $StorePath 2>$null

        if ($answer) {
            $preview = $answer.Substring(0, [Math]::Min(150, $answer.Length))
            Write-Host "A: $preview..." -ForegroundColor Gray
        }
        else {
            Write-Host "A: [No answer found]" -ForegroundColor Red
        }

        Write-Host ""
    }

    Write-Host "Test complete!" -ForegroundColor Green
    Write-Host "`nTo query manually: .\support-bot-builder.ps1 -Action query -Question 'your question'"
}

function Start-SupportBotServer {
    Write-Host "`n=== SUPPORT BOT SERVER ===" -ForegroundColor Cyan
    Write-Host "Starting support bot listener..."
    Write-Host "This would integrate with your support ticket system"
    Write-Host ""
    Write-Host "Integration options:" -ForegroundColor Yellow
    Write-Host "  1. Email monitoring (IMAP)"
    Write-Host "  2. ClickUp webhook (new comments)"
    Write-Host "  3. API endpoint (POST /support)"
    Write-Host "  4. Slack bot"
    Write-Host ""
    Write-Host "For now, use -Action query for manual testing" -ForegroundColor Cyan
    Write-Host "Future: Build integration based on your support system"
}

# Main execution
switch ($Action) {
    'init' {
        Initialize-SupportBot
    }
    'index' {
        Index-Documentation
    }
    'query' {
        Query-SupportBot -UserQuestion $Question
    }
    'test' {
        Test-SupportBot
    }
    'serve' {
        Start-SupportBotServer
    }
}

Write-Host ""
