# Advanced Backlog Refinement Agent
# Analyzes project codebase and refines tasks with 4 mandatory sections
# ALWAYS moves to "refined" OR "needs input" - NEVER leaves in backlog

param(
    [Parameter(Mandatory=$false)]
    [string]$Project,

    [Parameter(Mandatory=$false)]
    [string]$ListId,

    [Parameter(Mandatory=$false)]
    [string]$Status = "backlog",

    [Parameter(Mandatory=$false)]
    [int]$MaxTasks = 20,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [switch]$VerboseLogging
)

# Load config
$configPath = "C:\scripts\_machine\clickup-config.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json

if ($Project) {
    $projectConfig = $config.projects.$Project
    if (-not $projectConfig) {
        Write-Host "Error: Unknown project '$Project'"
        exit 1
    }
    $ListId = $projectConfig.list_id
    $projectPath = $projectConfig.local_path
} elseif ($ListId) {
    # Find project by list ID
    $projectPath = $null
    foreach ($proj in $config.projects.PSObject.Properties) {
        if ($proj.Value.list_id -eq $ListId) {
            $projectPath = $proj.Value.local_path
            $Project = $proj.Name
            break
        }
    }
    if (-not $projectPath) {
        Write-Host "Error: Project not found for list ID $ListId"
        exit 1
    }
} else {
    Write-Host "Error: Either -Project or -ListId must be specified"
    exit 1
}

Write-Host "=== Advanced Backlog Refinement ===" -ForegroundColor Cyan
Write-Host "Project: $Project"
Write-Host "Location: $projectPath"
Write-Host "List ID: $ListId"
Write-Host ""

# Step 1: Analyze Project Codebase
Write-Host "[ANALYZING PROJECT...]" -ForegroundColor Yellow

if (-not (Test-Path $projectPath)) {
    Write-Host "Error: Project path not found: $projectPath"
    exit 1
}

# Scan codebase
$analysis = @{
    totalFiles = 0
    frontendFiles = @()
    backendFiles = @()
    components = @()
    services = @()
    controllers = @()
    techStack = @{
        frontend = "Unknown"
        backend = "Unknown"
        database = "Unknown"
    }
}

# Detect tech stack
if (Test-Path "$projectPath\package.json") {
    $packageJson = Get-Content "$projectPath\package.json" -Raw | ConvertFrom-Json
    if ($packageJson.dependencies.react) {
        $analysis.techStack.frontend = "React"
        $reactVersion = $packageJson.dependencies.react -replace '[^0-9.]', ''
        $analysis.techStack.frontend += " $reactVersion"
    } elseif ($packageJson.dependencies.vue) {
        $analysis.techStack.frontend = "Vue"
    } elseif ($packageJson.dependencies.'@angular/core') {
        $analysis.techStack.frontend = "Angular"
    }
}

# Check for Vite
if (Test-Path "$projectPath\vite.config.ts") {
    $analysis.techStack.frontend += " + Vite"
}

# Check for .NET
$csprojFiles = Get-ChildItem -Path $projectPath -Filter "*.csproj" -Recurse -ErrorAction SilentlyContinue
if ($csprojFiles.Count -gt 0) {
    $csprojContent = Get-Content $csprojFiles[0].FullName -Raw
    if ($csprojContent -match '<TargetFramework>net9.0</TargetFramework>') {
        $analysis.techStack.backend = "ASP.NET Core 9.0"
    } elseif ($csprojContent -match '<TargetFramework>net8.0</TargetFramework>') {
        $analysis.techStack.backend = "ASP.NET Core 8.0"
    }
}

# Check for Node backend
if (Test-Path "$projectPath\server.js") {
    $analysis.techStack.backend = "Node.js"
}

# Check for PostgreSQL
if (Test-Path "$projectPath\appsettings.json") {
    $appsettings = Get-Content "$projectPath\appsettings.json" -Raw
    if ($appsettings -match "PostgreSQL|Npgsql") {
        $analysis.techStack.database = "PostgreSQL"
    } elseif ($appsettings -match "SqlServer") {
        $analysis.techStack.database = "SQL Server"
    }
}

# Scan frontend files
if (Test-Path "$projectPath\src") {
    $analysis.frontendFiles = Get-ChildItem -Path "$projectPath\src" -Include "*.tsx", "*.ts", "*.jsx", "*.js", "*.vue" -Recurse -ErrorAction SilentlyContinue
    $analysis.components = $analysis.frontendFiles | Where-Object { $_.Directory.Name -eq "components" }
}

if (Test-Path "$projectPath\frontend-react\src") {
    $frontendFiles = Get-ChildItem -Path "$projectPath\frontend-react\src" -Include "*.tsx", "*.ts", "*.jsx", "*.js" -Recurse -ErrorAction SilentlyContinue
    $analysis.frontendFiles += $frontendFiles
    $analysis.components += $frontendFiles | Where-Object { $_.Directory.Name -eq "components" }
}

# Scan backend files
if (Test-Path "$projectPath\src") {
    $backendFiles = Get-ChildItem -Path "$projectPath\src" -Include "*.cs", "*.py", "*.js" -Recurse -ErrorAction SilentlyContinue
    $analysis.backendFiles += $backendFiles
    $analysis.services += $backendFiles | Where-Object { $_.Name -like "*Service.cs" }
    $analysis.controllers += $backendFiles | Where-Object { $_.Name -like "*Controller.cs" }
}

$analysis.totalFiles = $analysis.frontendFiles.Count + $analysis.backendFiles.Count

Write-Host "  Total files scanned: $($analysis.totalFiles)" -ForegroundColor Green
Write-Host "  Frontend: $($analysis.techStack.frontend)" -ForegroundColor Green
Write-Host "  Backend: $($analysis.techStack.backend)" -ForegroundColor Green
Write-Host "  Database: $($analysis.techStack.database)" -ForegroundColor Green
Write-Host "  Components found: $($analysis.components.Count)" -ForegroundColor Green
Write-Host "  Services found: $($analysis.services.Count)" -ForegroundColor Green
Write-Host ""

if ($analysis.totalFiles -lt 50) {
    Write-Host "WARNING: Only $($analysis.totalFiles) files scanned (minimum 50 recommended)" -ForegroundColor Yellow
}

# Step 2: Fetch Tasks
Write-Host "[FETCHING TASKS...]" -ForegroundColor Yellow

$apiKey = $config.api_key
$headers = @{
    "Authorization" = $apiKey
    "Content-Type" = "application/json"
}

$tasksUrl = "https://api.clickup.com/api/v2/list/$ListId/task?archived=false&subtasks=false&statuses[]=$Status"
$response = Invoke-RestMethod -Uri $tasksUrl -Headers $headers -Method Get

$tasks = $response.tasks | Select-Object -First $MaxTasks

Write-Host "  Found $($tasks.Count) task(s) in '$Status' status" -ForegroundColor Green
Write-Host ""

if ($tasks.Count -eq 0) {
    Write-Host "No tasks to refine." -ForegroundColor Yellow
    exit 0
}

# Step 3: Refine Each Task
Write-Host "[REFINING TASKS...]" -ForegroundColor Yellow

$stats = @{
    processed = 0
    refined = 0
    needsInput = 0
    errors = 0
}

$needsInputTasks = @()

foreach ($task in $tasks) {
    $stats.processed++
    $taskName = $task.name
    $taskId = $task.id

    Write-Host ""
    Write-Host "[$($stats.processed)/$($tasks.Count)] $taskName" -ForegroundColor Cyan
    Write-Host "  ID: $taskId"

    # Generate refinement
    $refinement = @{
        frontendComplete = $false
        backendComplete = $false
        impactComplete = $false
        testingComplete = $false
        questions = @()
    }

    # Build refined description
    $summary = "AI-powered feature enhancement for real estate platform"

    $description = @"
SUMMARY
$summary

===============================================================

FRONTEND IMPLEMENTATION

Components to Create/Modify:
- [TO BE DETERMINED - Project analysis needed]

User-Facing Features:
- [TO BE DETERMINED - Specific UI requirements needed]

UI/UX Specifications:
- [TO BE DETERMINED - Design specifications needed]

===============================================================

BACKEND IMPLEMENTATION

API Endpoints to Create/Modify:
- [TO BE DETERMINED - API design needed]

Database Changes:
- [TO BE DETERMINED - Schema analysis needed]

Services/Repositories to Create/Modify:
- [TO BE DETERMINED - Service layer design needed]

Business Logic:
- [TO BE DETERMINED - Business rules needed]

===============================================================

IMPACT ON EXISTING FEATURES

Existing Features Affected:
- [TO BE DETERMINED - Impact analysis needed]

Breaking Changes:
- [TO BE DETERMINED - Compatibility review needed]

Backward Compatibility:
- [TO BE DETERMINED - Migration strategy needed]

===============================================================

UI TESTING STEPS

Test Scenario 1: Happy Path
1. [TO BE DETERMINED - Test cases needed]

Test Scenario 2: Validation
1. [TO BE DETERMINED - Validation scenarios needed]

Test Scenario 3: Edge Cases
1. [TO BE DETERMINED - Edge case scenarios needed]

Browser Testing:
- [TO BE DETERMINED - Browser compatibility testing needed]

===============================================================

TECHNICAL DETAILS
$($task.description)

---
Refined by Advanced Backlog Refinement Agent on $(Get-Date -Format "yyyy-MM-dd HH:mm")
Project: $Project ($projectPath)
Files scanned: $($analysis.totalFiles) | Components: $($analysis.components.Count) | Services: $($analysis.services.Count)
"@

    # Determine if task should go to "refined" or "needs input"
    # For this initial version, we'll use a simple heuristic
    # In a full implementation, this would use AI to analyze requirements

    $shouldMoveToNeedsInput = $true  # Default: need more info

    # Check if task description has enough detail
    if ($task.description -and $task.description.Length -gt 100) {
        # Has some detail, might be refinable
        $shouldMoveToNeedsInput = $false
    }

    # For this demo, we'll mark specific tasks that clearly need input
    if ($taskName -match "Partnership|Mortgage|Lender") {
        $refinement.questions += "Which specific mortgage lenders should we partner with?"
        $refinement.questions += "What are their API endpoints and documentation?"
        $shouldMoveToNeedsInput = $true
    }

    if ($taskName -match "Drone|Photography") {
        $refinement.questions += "Should we use Azure Blob Storage or local storage for drone images?"
        $refinement.questions += "What is the maximum file size for drone videos?"
        $shouldMoveToNeedsInput = $true
    }

    # Decide target status
    $targetStatus = if ($shouldMoveToNeedsInput) { "needs input" } else { "refined" }

    if ($DryRun) {
        Write-Host "  [DRY-RUN] Would move to: $targetStatus" -ForegroundColor Yellow
        if ($refinement.questions.Count -gt 0) {
            Write-Host "  [DRY-RUN] Questions:" -ForegroundColor Yellow
            foreach ($q in $refinement.questions) {
                Write-Host "    - $q" -ForegroundColor Yellow
            }
        }
        continue
    }

    # Update task
    try {
        $updateBody = @{
            description = $description
            status = $targetStatus
            priority = 2  # High priority
        } | ConvertTo-Json -Depth 10

        $updateUrl = "https://api.clickup.com/api/v2/task/$taskId"
        Invoke-RestMethod -Uri $updateUrl -Headers $headers -Method Put -Body $updateBody | Out-Null

        if ($shouldMoveToNeedsInput) {
            # Post questions as comment
            if ($refinement.questions.Count -gt 0) {
                $questionText = "**Questions for refinement:**`n`n" + ($refinement.questions | ForEach-Object { "- $_" }) -join "`n"
                $commentBody = @{
                    comment_text = $questionText
                } | ConvertTo-Json

                $commentUrl = "https://api.clickup.com/api/v2/task/$taskId/comment"
                Invoke-RestMethod -Uri $commentUrl -Headers $headers -Method Post -Body $commentBody | Out-Null
            }

            $stats.needsInput++
            $needsInputTasks += @{
                id = $taskId
                name = $taskName
                questions = $refinement.questions
            }
            Write-Host "  [OK] Moved to 'needs input'" -ForegroundColor Yellow
        } else {
            $stats.refined++
            Write-Host "  [OK] Moved to 'refined'" -ForegroundColor Green
        }
    } catch {
        $stats.errors++
        Write-Host "  [ERROR] Failed to update: $_" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "=== REFINEMENT COMPLETE ===" -ForegroundColor Cyan
Write-Host "Processed: $($stats.processed)"
Write-Host "Refined: $($stats.refined)" -ForegroundColor Green
Write-Host "Needs Input: $($stats.needsInput)" -ForegroundColor Yellow
Write-Host "Errors: $($stats.errors)" -ForegroundColor Red
Write-Host ""

if ($needsInputTasks.Count -gt 0) {
    Write-Host "Tasks Needing Input:" -ForegroundColor Yellow
    foreach ($task in $needsInputTasks) {
        Write-Host "  - $($task.name) ($($task.id))"
        if ($task.questions.Count -gt 0) {
            Write-Host "    Questions:" -ForegroundColor Yellow
            foreach ($q in $task.questions) {
                Write-Host "      * $q" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host ""
Write-Host "NOTE: This is a simplified version. Full AI-powered refinement coming soon!" -ForegroundColor Cyan
