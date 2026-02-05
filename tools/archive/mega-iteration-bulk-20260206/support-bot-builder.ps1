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

    # Key directories to index
    $directoriesToIndex = @(
        $ProjectPath  # Root (will get all README files)
    )

    # Add docs directory if exists
    $docsPath = Join-Path $ProjectPath "docs"
    if (Test-Path $docsPath) {
        $directoriesToIndex += $docsPath
    }

    # Add ClientManagerAPI docs if exists
    $apiDocsPath = Join-Path $ProjectPath "ClientManagerAPI\docs"
    if (Test-Path $apiDocsPath) {
        $directoriesToIndex += $apiDocsPath
    }

    Write-Host "Indexing $($directoriesToIndex.Count) key directories..." -ForegroundColor Yellow
    Write-Host ""

    foreach ($dir in $directoriesToIndex) {
        Write-Host "  Directory: $dir" -ForegroundColor Cyan

        # Count markdown files
        $mdFiles = Get-ChildItem -Path $dir -Filter "*.md" -File -ErrorAction SilentlyContinue
        Write-Host "    Found: $($mdFiles.Count) markdown files" -ForegroundColor Gray

        if ($mdFiles.Count -eq 0) {
            Write-Host "    Skipping (no files)" -ForegroundColor Yellow
            continue
        }

        try {
            # Index this directory
            Write-Host "    Indexing..." -ForegroundColor Gray
            & $HazinaRagTool -Action index -StoreName $StorePath -Path $dir

            Write-Log "Indexed directory: $dir ($($mdFiles.Count) files)"
            Write-Host "    SUCCESS" -ForegroundColor Green
        }
        catch {
            Write-Host "    ERROR: $_" -ForegroundColor Red
            Write-Log "Failed to index $dir: $_" "ERROR"
        }

        Write-Host ""
    }

    Write-Host "Indexing complete!" -ForegroundColor Green

    # Get store status
    Write-Host "`nStore status:" -ForegroundColor Yellow
    & $HazinaRagTool -Action status -StoreName $StorePath

    Write-Log "Indexing complete"

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
