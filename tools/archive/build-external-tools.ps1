#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build external tools registry

.DESCRIPTION
    Creates a registry of external tools/services (GitHub, ClickUp, Gmail, etc.)
    with access methods, auth types, and credential references.

.EXAMPLE
    .\build-external-tools.ps1

.NOTES
    Author: Jengo
    Created: 2026-02-09
    ROI: 5.0
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$outputFile = "C:\scripts\_machine\external-tools.json"

Write-Host "🔨 Building external tools registry..." -ForegroundColor Cyan

$tools = @(
    @{
        name = "GitHub"
        category = "Development"
        web_url = "https://github.com"
        api_url = "https://api.github.com"
        cli_tool = "gh"
        auth_method = "token"
        credential_ref = "github"
        capabilities = @(
            "Code hosting"
            "Pull requests"
            "Issues"
            "Actions CI/CD"
            "Releases"
        )
        common_operations = @{
            create_pr = "gh pr create --base develop --title 'Title' --body 'Description'"
            list_prs = "gh pr list"
            view_pr = "gh pr view NUMBER"
            merge_pr = "gh pr merge NUMBER"
        }
    }
    @{
        name = "ClickUp"
        category = "Project Management"
        web_url = "https://app.clickup.com"
        api_url = "https://api.clickup.com/api/v2"
        auth_method = "api_key"
        credential_ref = "clickup"
        lists = @{
            hazina = "901215559249"
            client_manager = "901214097647"
            art_revisionist = "901211612245"
        }
        default_assignee = "74525428"
        capabilities = @(
            "Task management"
            "Status tracking"
            "Comments"
            "Time tracking"
            "Custom fields"
        )
    }
    @{
        name = "Gmail"
        category = "Email"
        web_url = "https://mail.google.com"
        api_url = "https://www.googleapis.com/gmail/v1"
        auth_method = "oauth"
        credential_ref = "gmail"
        capabilities = @(
            "Send/receive email"
            "Labels"
            "Filters"
            "Search"
        )
    }
    @{
        name = "Google Drive"
        category = "Storage"
        web_url = "https://drive.google.com"
        api_url = "https://www.googleapis.com/drive/v3"
        auth_method = "oauth"
        credential_ref = "google"
        capabilities = @(
            "File storage"
            "Sharing"
            "Collaboration"
            "Search"
        )
    }
    @{
        name = "OpenAI"
        category = "AI/LLM"
        api_url = "https://api.openai.com/v1"
        auth_method = "api_key"
        credential_ref = "openai"
        capabilities = @(
            "GPT-4 completions"
            "DALL-E image generation"
            "Embeddings"
            "Audio transcription"
        )
        local_config = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"
    }
    @{
        name = "Anthropic"
        category = "AI/LLM"
        api_url = "https://api.anthropic.com/v1"
        auth_method = "api_key"
        credential_ref = "anthropic"
        capabilities = @(
            "Claude completions"
            "Vision analysis"
            "Tool use"
            "Streaming"
        )
    }
    @{
        name = "ManicTime"
        category = "Time Tracking"
        local_api = "http://localhost:8080"
        auth_method = "local"
        capabilities = @(
            "Activity monitoring"
            "Time tracking"
            "Statistics"
            "Reports"
        )
    }
    @{
        name = "WordPress Admin"
        category = "CMS"
        web_url = "http://localhost/wp-admin"
        auth_method = "username_password"
        credential_ref = "wordpress"
        capabilities = @(
            "Content management"
            "Theme editing"
            "Plugin management"
            "Media library"
        )
    }
    @{
        name = "FTP (Art Revisionist)"
        category = "Deployment"
        auth_method = "username_password"
        credential_ref = "ftp_artrevisionist"
        capabilities = @(
            "File upload"
            "File download"
            "Directory listing"
        )
    }
)

$registry = @{
    generated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    version = "1.0"
    total_tools = $tools.Count
    tools = $tools
}

$registry | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8

$fileSize = (Get-Item $outputFile).Length
$fileSizeKB = [math]::Round($fileSize / 1KB, 2)

Write-Host "✅ Built: $outputFile" -ForegroundColor Green
Write-Host "📊 Size: $fileSizeKB KB" -ForegroundColor Cyan
Write-Host "🔧 Tools: $($tools.Count)" -ForegroundColor Cyan

# Summary
Write-Host ""
Write-Host "📋 Categories:" -ForegroundColor Cyan
$categories = $tools | Group-Object -Property category
foreach ($cat in $categories) {
    Write-Host "  • $($cat.Name): $($cat.Count) tools" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Credentials:" -ForegroundColor Yellow
Write-Host "  Store these using: vault.ps1 -Action set -Service NAME" -ForegroundColor Gray

$uniqueCreds = $tools | Where-Object { $_.credential_ref } | Select-Object -ExpandProperty credential_ref -Unique
foreach ($cred in $uniqueCreds) {
    Write-Host "  - $cred" -ForegroundColor Gray
}
