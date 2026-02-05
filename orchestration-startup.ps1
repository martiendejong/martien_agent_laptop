# Orchestration Startup Script
# Auto-runs foundation tools at session start

Write-Host "🚀 Starting orchestration foundation..." -ForegroundColor Cyan

# 1. Validate startup
& "C:\scripts\tools\startup-validator.ps1" -Validate

# 2. Start health monitoring (background)
Start-Job -ScriptBlock {
    & "C:\scripts\tools\health-dashboard.ps1" -Watch
} | Out-Null

# 3. Sync knowledge base
& "C:\scripts\tools\shared-knowledge-sync.ps1" -Action Sync -AgentId "primary"

# 4. Register with coordinator
& "C:\scripts\tools\agent-coordinator.ps1" -Action Start -AgentId "primary"

Write-Host "✅ Orchestration foundation ready" -ForegroundColor Green
