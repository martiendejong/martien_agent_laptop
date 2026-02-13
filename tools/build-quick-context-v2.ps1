# Build quick-context.json from all knowledge sources
# Compiles configuration into single fast-loading JSON file
# Author: Jengo, Created: 2026-02-09

param()

$ErrorActionPreference = "Stop"

$baseDir = "C:\scripts"
$machineDir = "$baseDir\_machine"
$outputFile = "$machineDir\quick-context.json"

Write-Host "Building quick-context.json..." -ForegroundColor Cyan

# Initialize context object
$context = @{
    generated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    version = "1.1"
    identity = @{
        name = "Jengo"
        meaning = "Building (Swahili)"
        established = "2026-01-25"
        core_file = "C:\scripts\agentidentity\CORE_IDENTITY.md"
        relationship = "Partnership with Martien"
        mandate = "Leave the system better than I found it"
        startup_reminder = "ALWAYS read CORE_IDENTITY.md at session start"
    }
    projects = @()
    services = @()
    tools = @()
    worktree_pool = @()
    workflows = @{}
}

# Projects
$context.projects += @{
    name = "client-manager"
    type = "SaaS"
    code_path = "C:\Projects\client-manager"
    framework_path = "C:\Projects\hazina"
    store_path = "C:\stores\brand2boost"
    main_branch = "develop"
    admin_auth = "vault:admin"
    requires_paired_worktree = $true
    paired_repo = "hazina"
}

$context.projects += @{
    name = "hazina"
    type = "Framework"
    code_path = "C:\Projects\hazina"
    main_branch = "develop"
}

$context.projects += @{
    name = "art-revisionist"
    type = "WordPress + React"
    wordpress_path = "C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme"
    admin_path = "C:\Projects\artrevisionist\artrevisionist"
    main_branch = "develop"
}

$context.projects += @{
    name = "hydro-vision-website"
    type = "Static Website"
    code_path = "C:\Projects\hydro-vision-website"
    main_branch = "main"
    worktree_exempt = $true
}

# Services
$context.services += @{
    name = "Hazina Orchestration"
    url = "https://localhost:5123"
    tailscale_url = "https://desktop-ecbaunu.tailca9ff1.ts.net:5123"
    swagger = "https://localhost:5123/swagger"
    launcher = "C:\scripts\o.bat"
    executable = "C:\stores\orchestration\HazinaOrchestration.exe"
    auth = "vault:orchestration"
    protocol = "HTTPS"
    port = 5123
}

$context.services += @{
    name = "Agentic Debugger Bridge"
    url = "http://localhost:27183"
    purpose = "Visual Studio debugging control"
}

$context.services += @{
    name = "UI Automation Bridge"
    url = "http://localhost:27184"
    purpose = "Windows desktop control via FlaUI"
}

$context.services += @{
    name = "WordPress Local"
    url = "http://localhost:80"
    root = "C:\xampp\htdocs"
}

# Tools
$context.tools += @{
    name = "ai-image"
    path = "C:\scripts\tools\ai-image.ps1"
    purpose = "DALL-E image generation"
}

$context.tools += @{
    name = "ai-vision"
    path = "C:\scripts\tools\ai-vision.ps1"
    purpose = "Screenshot analysis, OCR"
}

$context.tools += @{
    name = "vault"
    path = "C:\scripts\tools\vault.ps1"
    purpose = "Encrypted credentials storage"
}

$context.tools += @{
    name = "services-query"
    path = "C:\scripts\tools\services-query-v2.ps1"
    purpose = "Query running services registry"
}

# Worktree pool - parse markdown table rows
if (Test-Path "$machineDir\worktrees.pool.md") {
    $poolLines = Get-Content "$machineDir\worktrees.pool.md"
    foreach ($line in $poolLines) {
        # Match table rows: | agent-XXX | ... | ... | ... | STATUS |
        if ($line -match '^\|\s*(agent-\d+)\s*\|.*?\|.*?\|.*?\|\s*(FREE|BUSY|STALE|BROKEN)\s*\|') {
            $context.worktree_pool += @{
                agent = $Matches[1]
                path = "C:\Projects\worker-agents\$($Matches[1])"
                status = $Matches[2]
            }
        }
    }
}

# Workflows
$context.workflows = @{
    feature_development = @{
        trigger = "ClickUp task or new feature"
        workspace = "Worktree"
        steps = @("Check pool", "Create worktree", "Code", "PR", "Release")
    }
    active_debugging = @{
        trigger = "Build errors"
        workspace = "Base repo"
        steps = @("Fix", "Test", "Done")
    }
}

# ClickUp config
$context.clickup = @{
    default_assignee = "74525428"
    lists = @{
        hazina = "901215559249"
        client_manager = "901214097647"
        art_revisionist = "901211612245"
    }
}

# Rules
$context.rules = @{
    language = "ALL generated content in English"
    pr_base = "Always develop, never main"
    worktree = "Always use worktree for features"
    status_reporting = "ALWAYS end responses with STATUS: headline + description on next line"
}

# Speech aliases (voice input Dutch → correct terms)
$context.speech_aliases = @{
    projects = @{
        "kleine manager" = "client-manager"
        "client manager" = "client-manager"
        "brand to boost" = "brand2boost"
    }
    tools_services = @{
        "heeft zina" = "hazina"
        "has ina" = "hazina"
        "hazina" = "hazina"
        "orchestratie" = "Hazina Orchestration"
    }
    tech_terms = @{
        "work tree" = "worktree"
        "git hub" = "GitHub"
        "click up" = "ClickUp"
    }
    people = @{
        "django" = "Jengo"
        "jengo" = "Jengo"
    }
}

# Write JSON
$json = $context | ConvertTo-Json -Depth 10 -Compress:$false
$json | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline

# Stats
$fileSize = (Get-Item $outputFile).Length
$fileSizeKB = [math]::Round($fileSize / 1KB, 2)

Write-Host "DONE: $outputFile" -ForegroundColor Green
Write-Host "Size: $fileSizeKB KB" -ForegroundColor Cyan

# Verify
try {
    $verify = Get-Content $outputFile -Raw | ConvertFrom-Json
    Write-Host "Valid: $($verify.projects.Count) projects, $($verify.services.Count) services" -ForegroundColor Green
} catch {
    Write-Host "ERROR: JSON validation failed" -ForegroundColor Red
    exit 1
}
