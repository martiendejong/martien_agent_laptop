<#
.SYNOPSIS
    Quick deploy script for Hazina Orchestration tray app (v2)
    Runs elevated, outputs to log file for monitoring.
#>

$ErrorActionPreference = "Stop"
$logFile = "C:\scripts\logs\deploy-output.log"

Start-Transcript -Path $logFile -Force

Write-Output "=== STEP 1: Check/Remove old Windows Service ==="
$svc = Get-Service HazinaOrchestration -ErrorAction SilentlyContinue
if ($svc) {
    Write-Output "Found old service (status: $($svc.Status)), removing..."
    if ($svc.Status -eq "Running") {
        Stop-Service HazinaOrchestration -Force
        Start-Sleep -Seconds 3
    }
    sc.exe delete HazinaOrchestration 2>&1
    Write-Output "Old service removed"
} else {
    Write-Output "No old service found - clean install or already migrated"
}

Write-Output ""
Write-Output "=== STEP 2: Kill running HazinaOrchestration process ==="
$procs = Get-Process HazinaOrchestration -ErrorAction SilentlyContinue
if ($procs) {
    $procs | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Output "Killed $($procs.Count) process(es)"
} else {
    Write-Output "No running process found"
}

Write-Output ""
Write-Output "=== STEP 3: Install MSI ==="
$msiPath = "C:\Projects\hazina\apps\Demos\Hazina.Demo.AgenticOrchestration.Installer\bin\Release\HazinaOrchestrationSetup.msi"
if (-not (Test-Path $msiPath)) {
    Write-Output "FATAL: MSI not found at $msiPath"
    Stop-Transcript
    exit 1
}

$msiLog = Join-Path $env:TEMP "hazina-install.log"
Write-Output "Installing MSI (logging to $msiLog)..."
$proc = Start-Process msiexec -ArgumentList "/i", "`"$msiPath`"", "/qn", "/l*v", "`"$msiLog`"" -Wait -PassThru
Write-Output "MSI exit code: $($proc.ExitCode)"

if ($proc.ExitCode -ne 0) {
    Write-Output "FATAL: MSI install failed! Check $msiLog"
    Stop-Transcript
    exit 1
}

$installDir = "C:\Program Files (x86)\Hazina Orchestration"
if (-not (Test-Path (Join-Path $installDir "HazinaOrchestration.exe"))) {
    Write-Output "FATAL: HazinaOrchestration.exe not found after install"
    Stop-Transcript
    exit 1
}
Write-Output "MSI installed successfully to $installDir"

Write-Output ""
Write-Output "=== STEP 4: Copy Tailscale certificates ==="
Copy-Item "C:\stores\orchestration\tailscale.crt" -Destination (Join-Path $installDir "tailscale.crt") -Force
Copy-Item "C:\stores\orchestration\tailscale.key" -Destination (Join-Path $installDir "tailscale.key") -Force
Write-Output "Certificates copied"

Write-Output ""
Write-Output "=== STEP 5: Write machine-specific appsettings.json ==="
$appSettings = @{
    Logging = @{
        LogLevel = @{
            Default = "Information"
            "Microsoft.AspNetCore" = "Warning"
        }
    }
    AllowedHosts = "*"
    Kestrel = @{
        Endpoints = @{
            Https = @{
                Url = "https://*:5123"
                Certificate = @{
                    Path = "tailscale.crt"
                    KeyPath = "tailscale.key"
                }
            }
        }
    }
    Authentication = @{
        Enabled = $true
        Username = "bosi"
        Password = "Th1s1sSp4rt4!"
        Realm = "Hazina Agentic Orchestration"
    }
    AgenticOrchestration = @{
        DatabasePath = "C:\scripts\_machine\agent-activity.db"
        LogsPath = "C:\scripts\logs"
        EntitiesYamlPath = "entities.yaml"
        SignalR = @{
            Enabled = $true
            HubPath = "/hubs/agentic"
        }
        Polling = @{
            InstanceHeartbeatTimeoutSeconds = 60
            InteractionExpiryMinutes = 60
        }
        Features = @{
            EnableTaskQueue = $true
            EnableOutputStreaming = $true
            EnableRealtimeNotifications = $true
        }
        Terminal = @{
            DefaultCommand = "C:\scripts\claude_agent.bat"
            DefaultWorkingDirectory = "C:\scripts"
            DefaultArguments = @()
            DefaultColumns = 120
            DefaultRows = 30
            MaxConcurrentSessions = 10
            SessionTimeoutMinutes = 60
        }
        SessionLogging = @{
            Enabled = $true
            BasePath = "C:\scripts\logs\agent-sessions"
        }
    }
    Swagger = @{
        Enabled = $true
        Title = "Hazina Agentic Orchestration API"
        Description = "Web API for managing Claude Code CLI instances via Hazina declarative framework"
        Version = "v1"
    }
    OpenAI = @{
        ApiKey = "YOUR_OPENAI_API_KEY_HERE"
        Model = "gpt-4o-mini"
        EmbeddingModel = "text-embedding-3-small"
        ImageModel = "dall-e-3"
        TtsModel = "gpt-4o-mini-tts"
    }
} | ConvertTo-Json -Depth 10

Set-Content -Path (Join-Path $installDir "appsettings.json") -Value $appSettings -Encoding UTF8
Write-Output "appsettings.json written"

Write-Output ""
Write-Output "=== STEP 6: Strip appsettings.Production.json ==="
$productionSettings = @{
    Logging = @{
        LogLevel = @{
            Default = "Information"
            "Microsoft.AspNetCore" = "Warning"
        }
        EventLog = @{
            LogLevel = @{
                Default = "Information"
            }
        }
    }
    AllowedHosts = "*"
    Swagger = @{
        Enabled = $true
        Title = "Hazina Agentic Orchestration API"
        Description = "Web API for managing Claude Code CLI instances via Hazina declarative framework"
        Version = "v1"
    }
    OpenAI = @{
        ApiKey = ""
        Model = "gpt-4o-mini"
        EmbeddingModel = "text-embedding-3-small"
        ImageModel = "dall-e-3"
        TtsModel = "gpt-4o-mini-tts"
    }
} | ConvertTo-Json -Depth 10

Set-Content -Path (Join-Path $installDir "appsettings.Production.json") -Value $productionSettings -Encoding UTF8
Write-Output "Production config stripped (no Kestrel/Auth/Terminal overrides)"

Write-Output ""
Write-Output "=== STEP 7: Launch tray application ==="
$exePath = Join-Path $installDir "HazinaOrchestration.exe"
Start-Process $exePath -WorkingDirectory $installDir
Start-Sleep -Seconds 6

$running = Get-Process HazinaOrchestration -ErrorAction SilentlyContinue
if ($running) {
    Write-Output "Tray app running! PID: $($running.Id)"
} else {
    Write-Output "WARNING: Process not detected after launch"
}

Write-Output ""
Write-Output "=== STEP 8: Verify ==="
Start-Sleep -Seconds 3
try {
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("bosi:Th1s1sSp4rt4!"))
    $headers = @{ Authorization = "Basic $auth" }
    $response = Invoke-WebRequest -Uri "https://localhost:5123/health" -Headers $headers -SkipCertificateCheck -TimeoutSec 10 -UseBasicParsing
    Write-Output "Health check: $($response.StatusCode) - $($response.Content)"
} catch {
    Write-Output "Health check failed: $($_.Exception.Message)"
    Write-Output "App may still be starting up..."
}

Write-Output ""
Write-Output "========================================="
Write-Output "  DEPLOYMENT COMPLETE - Tray App v2"
Write-Output "========================================="
Write-Output "  Local:   https://localhost:5123"
Write-Output "  Swagger: https://localhost:5123/swagger"
Write-Output "  Tray:    Check system tray for icon"
Write-Output "========================================="

Stop-Transcript
