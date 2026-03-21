#Requires -Version 5.1
<#
.SYNOPSIS
    Setup Hazina.Auth authentication system using local project references (for testing)

.DESCRIPTION
    Same as setup-auth.ps1 but uses local project references instead of NuGet packages.
    Use this for testing before publishing to NuGet.

.PARAMETER ProjectPath
    Path to the backend API project directory

.PARAMETER Namespace
    Namespace for the AuthController (e.g., "SEOGod.API")

.PARAMETER Providers
    OAuth providers to enable (comma-separated): "Google,Microsoft"

.PARAMETER Database
    Database provider: "SQLite", "PostgreSQL", or "SQLServer"

.PARAMETER FrontendPath
    Optional path to React frontend to copy auth components

.PARAMETER HazinaPath
    Path to Hazina repository (defaults to current worktree)

.EXAMPLE
    .\setup-auth-local.ps1 -ProjectPath "E:\projects\seo-god\backend\SEOGod.API" `
                           -Namespace "SEOGod.API" `
                           -Providers "Google" `
                           -Database "SQLite" `
                           -FrontendPath "E:\projects\seo-god\frontend" `
                           -HazinaPath "C:\Projects\worker-agents\agent-006\hazina"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,

    [Parameter(Mandatory=$true)]
    [string]$Namespace,

    [Parameter(Mandatory=$false)]
    [string]$Providers = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet("SQLite", "PostgreSQL", "SQLServer")]
    [string]$Database = "SQLite",

    [Parameter(Mandatory=$false)]
    [string]$FrontendPath = "",

    [Parameter(Mandatory=$false)]
    [string]$HazinaPath = "C:\Projects\worker-agents\agent-006\hazina"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Hazina.Auth Setup (Local) ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectPath"
Write-Host "Namespace: $Namespace"
Write-Host "OAuth Providers: $(if($Providers){$Providers}else{'None'})"
Write-Host "Database: $Database"
Write-Host "Hazina Path: $HazinaPath"
Write-Host ""

# Step 1: Add local project references
Write-Host "[1/7] Adding local project references..." -ForegroundColor Yellow
cd $ProjectPath

$coreProject = Join-Path $HazinaPath "src\Infrastructure\Auth\Hazina.Auth.Core\Hazina.Auth.Core.csproj"
$identityProject = Join-Path $HazinaPath "src\Infrastructure\Auth\Hazina.Auth.Identity\Hazina.Auth.Identity.csproj"

if (-not (Test-Path $coreProject)) {
    Write-Host "  ERROR: Core project not found at $coreProject" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $identityProject)) {
    Write-Host "  ERROR: Identity project not found at $identityProject" -ForegroundColor Red
    exit 1
}

dotnet add reference $coreProject
dotnet add reference $identityProject
Write-Host "  Local project references added" -ForegroundColor Green

# Step 2: Create AuthController
Write-Host "[2/7] Creating AuthController..." -ForegroundColor Yellow
$templatePath = Join-Path $HazinaPath "templates\backend\AuthController.cs.template"
if (-not (Test-Path $templatePath)) {
    Write-Host "  ERROR: Template not found at $templatePath" -ForegroundColor Red
    exit 1
}

$controllerContent = Get-Content $templatePath -Raw
$controllerContent = $controllerContent.Replace("{{NAMESPACE}}", $Namespace)

$controllersDir = Join-Path $ProjectPath "Controllers"
if (-not (Test-Path $controllersDir)) {
    New-Item -ItemType Directory -Path $controllersDir | Out-Null
}

$controllerPath = Join-Path $controllersDir "AuthController.cs"
Set-Content -Path $controllerPath -Value $controllerContent
Write-Host "  AuthController created at $controllerPath" -ForegroundColor Green

# Step 3: Update Program.cs
Write-Host "[3/7] Updating Program.cs..." -ForegroundColor Yellow
$programPath = Join-Path $ProjectPath "Program.cs"
$programContent = Get-Content $programPath -Raw

# Add using statements
if ($programContent -notmatch "using Hazina.Auth") {
    $programContent = "using Hazina.Auth.Identity.Configuration;`n" + $programContent
}

# Add AddHazinaAuth() before builder.Build()
$oauthOptions = @()
if ($Providers -match "Google") { $oauthOptions += "opts.UseGoogleOAuth = true;" }
if ($Providers -match "Microsoft") { $oauthOptions += "opts.UseMicrosoftOAuth = true;" }

$oauthConfig = if ($oauthOptions.Count -gt 0) {
    "opts => {`n    " + ($oauthOptions -join "`n    ") + "`n}"
} else {
    "null"
}

$hazinaAuthCall = @"
// Hazina Auth - Auto-generated
builder.Services.AddHazinaAuth(builder.Configuration, $oauthConfig);
"@

if ($programContent -notmatch "AddHazinaAuth") {
    $programContent = $programContent -replace "var app = builder.Build\(\);", "$hazinaAuthCall`n`nvar app = builder.Build();"
}

# Add UseHazinaAuth() after app.UseHttpsRedirection()
if ($programContent -notmatch "UseHazinaAuth") {
    $programContent = $programContent -replace "app.UseHttpsRedirection\(\);", "app.UseHttpsRedirection();`napp.UseHazinaAuth();"
}

Set-Content -Path $programPath -Value $programContent
Write-Host "  Program.cs updated" -ForegroundColor Green

# Step 4: Update appsettings.json
Write-Host "[4/7] Updating appsettings.json..." -ForegroundColor Yellow
$appsettingsPath = Join-Path $ProjectPath "appsettings.json"
$appsettings = Get-Content $appsettingsPath | ConvertFrom-Json

# Add JWT configuration
if (-not $appsettings.JWT) {
    $jwtSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | ForEach-Object {[char]$_})
    $appsettings | Add-Member -NotePropertyName "JWT" -NotePropertyValue @{
        Secret = $jwtSecret
        Issuer = "$Namespace"
        Audience = "${Namespace}Users"
        AccessTokenExpirationMinutes = 60
    }
}

# Add OAuth providers
if ($Providers -match "Google") {
    if (-not $appsettings.Google) {
        $appsettings | Add-Member -NotePropertyName "Google" -NotePropertyValue @{
            ClientId = "YOUR_GOOGLE_CLIENT_ID"
            ClientSecret = "YOUR_GOOGLE_CLIENT_SECRET"
        }
    }
}

if ($Providers -match "Microsoft") {
    if (-not $appsettings.Microsoft) {
        $appsettings | Add-Member -NotePropertyName "Microsoft" -NotePropertyValue @{
            ClientId = "YOUR_MICROSOFT_CLIENT_ID"
            ClientSecret = "YOUR_MICROSOFT_CLIENT_SECRET"
        }
    }
}

$appsettings | ConvertTo-Json -Depth 10 | Set-Content $appsettingsPath
Write-Host "  appsettings.json updated" -ForegroundColor Green

# Step 5: Create EF migration
Write-Host "[5/7] Creating Entity Framework migration..." -ForegroundColor Yellow
try {
    dotnet ef migrations add AddHazinaAuth 2>&1 | Out-Null
    dotnet ef database update 2>&1 | Out-Null
    Write-Host "  Migration created and applied" -ForegroundColor Green
} catch {
    Write-Host "  Migration skipped (run manually if needed)" -ForegroundColor Yellow
}

# Step 6: Copy frontend components (if requested)
if ($FrontendPath) {
    Write-Host "[6/7] Copying React auth components..." -ForegroundColor Yellow
    $frontendTemplatesDir = Join-Path $HazinaPath "templates\frontend\auth"
    $targetAuthDir = Join-Path $FrontendPath "src\components\Auth"

    if (Test-Path $frontendTemplatesDir) {
        if (-not (Test-Path $targetAuthDir)) {
            New-Item -ItemType Directory -Path $targetAuthDir -Force | Out-Null
        }
        Copy-Item "$frontendTemplatesDir\*" -Destination $targetAuthDir -Recurse -Force
        Write-Host "  React components copied to $targetAuthDir" -ForegroundColor Green
    } else {
        Write-Host "  Frontend templates not found (skip)" -ForegroundColor Yellow
    }
} else {
    Write-Host "[6/7] Skipping frontend components" -ForegroundColor Yellow
}

# Step 7: Summary
Write-Host ""
Write-Host "[7/7] Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Update OAuth credentials in appsettings.json (if using OAuth)"
Write-Host "  2. Run: dotnet build"
Write-Host "  3. Run: dotnet ef migrations add AddHazinaAuth (if not auto-created)"
Write-Host "  4. Run: dotnet ef database update"
Write-Host "  5. Test endpoints: POST /api/auth/register, POST /api/auth/login"
Write-Host ""
Write-Host "Generated JWT Secret (save this!):" -ForegroundColor Yellow
Write-Host "  $($appsettings.JWT.Secret)" -ForegroundColor White
