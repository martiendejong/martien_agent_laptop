# Build external tools registry
# Author: Jengo, Created: 2026-02-09

param()

$ErrorActionPreference = "Stop"

$outputFile = "C:\scripts\_machine\external-tools.json"

Write-Host "Building external tools registry..." -ForegroundColor Cyan

$tools = @(
    @{
        name = "GitHub"
        category = "Development"
        web_url = "https://github.com"
        api_url = "https://api.github.com"
        cli_tool = "gh"
        auth_method = "token"
        credential_ref = "github"
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
    }
    @{
        name = "Gmail"
        category = "Email"
        web_url = "https://mail.google.com"
        api_url = "https://www.googleapis.com/gmail/v1"
        auth_method = "oauth"
        credential_ref = "gmail"
    }
    @{
        name = "Google Drive"
        category = "Storage"
        web_url = "https://drive.google.com"
        api_url = "https://www.googleapis.com/drive/v3"
        auth_method = "oauth"
        credential_ref = "google"
    }
    @{
        name = "OpenAI"
        category = "AI/LLM"
        api_url = "https://api.openai.com/v1"
        auth_method = "api_key"
        credential_ref = "openai"
        local_config = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"
    }
    @{
        name = "Anthropic"
        category = "AI/LLM"
        api_url = "https://api.anthropic.com/v1"
        auth_method = "api_key"
        credential_ref = "anthropic"
    }
    @{
        name = "ManicTime"
        category = "Time Tracking"
        local_api = "http://localhost:8080"
        auth_method = "local"
    }
    @{
        name = "WordPress Admin"
        category = "CMS"
        web_url = "http://localhost/wp-admin"
        auth_method = "username_password"
        credential_ref = "wordpress"
    }
    @{
        name = "FTP Art Revisionist"
        category = "Deployment"
        auth_method = "username_password"
        credential_ref = "ftp_artrevisionist"
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

Write-Host "DONE: $outputFile" -ForegroundColor Green
Write-Host "Size: $fileSizeKB KB" -ForegroundColor Cyan
Write-Host "Tools: $($tools.Count)" -ForegroundColor Cyan

# Summary
Write-Host "" -ForegroundColor Cyan
Write-Host "Categories:" -ForegroundColor Cyan
$categories = $tools | Group-Object -Property category
foreach ($cat in $categories) {
    Write-Host "  - $($cat.Name): $($cat.Count) tools" -ForegroundColor Gray
}
