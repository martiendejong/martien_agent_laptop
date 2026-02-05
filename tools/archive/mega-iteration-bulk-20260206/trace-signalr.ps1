#Requires -Version 5.1
<#
.SYNOPSIS
    Trace SignalR message flow for debugging real-time communication

.DESCRIPTION
    Helps debug SignalR streaming issues by checking:
    - SignalR hub availability
    - Session context configuration
    - Event routing (session groups vs project groups)
    - Frontend connection status

.PARAMETER HubUrl
    SignalR hub URL (default: http://localhost:54501/myhub)

.PARAMETER CheckFrontend
    Also check frontend SignalR configuration

.EXAMPLE
    .\trace-signalr.ps1
    Check backend SignalR hub availability

.EXAMPLE
    .\trace-signalr.ps1 -CheckFrontend
    Check both backend and frontend SignalR setup
#>

param(
    [string]$HubUrl = "http://localhost:54501/myhub",
    [switch]$CheckFrontend
)

Write-Host "SignalR Message Flow Tracer`n" -ForegroundColor Cyan

# Check 1: Hub availability
Write-Host "[1/5] Checking SignalR hub availability..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $HubUrl -Method Get -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  [OK] Hub is running at $HubUrl" -ForegroundColor Green
}
catch {
    Write-Host "  [FAIL] Hub not accessible: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  TIP: Ensure backend API is running" -ForegroundColor Gray
}

# Check 2: Session context implementation
Write-Host "`n[2/5] Checking session context implementation..." -ForegroundColor Yellow
$sessionContextFile = "C:\Projects\client-manager\ClientManagerAPI\Services\SessionContext.cs"

if (Test-Path $sessionContextFile) {
    Write-Host "  [OK] SessionContext.cs exists" -ForegroundColor Green
    $content = Get-Content $sessionContextFile -Raw
    if ($content -match 'public\s+string\s+SessionId') {
        Write-Host "  [OK] SessionId property found" -ForegroundColor Green
    }
    else {
        Write-Host "  [WARN] SessionId property not found in SessionContext" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  [FAIL] SessionContext.cs not found" -ForegroundColor Red
}

# Check 3: SignalR notifier configuration
Write-Host "`n[3/5] Checking SignalR notifier..." -ForegroundColor Yellow
$notifierFile = "C:\Projects\client-manager\ClientManagerAPI\Custom\SignalRProjectChatNotifier.cs"

if (Test-Path $notifierFile) {
    Write-Host "  [OK] SignalRProjectChatNotifier.cs exists" -ForegroundColor Green
    $content = Get-Content $notifierFile -Raw
    if ($content -match 'session:{sessionId}') {
        Write-Host "  [OK] Session group routing implemented" -ForegroundColor Green
    }
    else {
        Write-Host "  [WARN] Session group routing not found" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  [FAIL] SignalRProjectChatNotifier.cs not found" -ForegroundColor Red
}

# Check 4: Frontend SignalR connection
if ($CheckFrontend) {
    Write-Host "`n[4/5] Checking frontend SignalR connection..." -ForegroundColor Yellow
    $frontendFile = "C:\Projects\client-manager\ClientManagerFrontend\src\hooks\useChatConnection.ts"

    if (Test-Path $frontendFile) {
        Write-Host "  [OK] useChatConnection.ts exists" -ForegroundColor Green
        $content = Get-Content $frontendFile -Raw
        if ($content -match "connection\.on\('ProjectChat'") {
            Write-Host "  [OK] ProjectChat event listener found" -ForegroundColor Green
        }
        else {
            Write-Host "  [WARN] ProjectChat event listener not found" -ForegroundColor Yellow
        }

        if ($content -match 'JoinProject') {
            Write-Host "  [OK] JoinProject method call found" -ForegroundColor Green
        }
        else {
            Write-Host "  [WARN] JoinProject method call not found" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "  [FAIL] useChatConnection.ts not found" -ForegroundColor Red
    }
}

# Check 5: Recommendations
Write-Host "`n[5/5] Recommendations for debugging:" -ForegroundColor Cyan
Write-Host "  1. Add logging to SignalRProjectChatNotifier.SendToSession()" -ForegroundColor White
Write-Host "     Log which group messages are sent to (session vs project vs all)" -ForegroundColor Gray
Write-Host "  2. Add console.log in frontend ProjectChat handler" -ForegroundColor White
Write-Host "     Verify chunks are received: console.log('[ProjectChat]', data.chunk)" -ForegroundColor Gray
Write-Host "  3. Check browser DevTools Network tab for SignalR messages" -ForegroundColor White
Write-Host "     Filter by 'myhub' to see WebSocket frames" -ForegroundColor Gray
Write-Host "  4. Verify session context is set in ChatController.SendChatMessage()" -ForegroundColor White
Write-Host "     Add: _sessionContext.SessionId = Request.Headers['X-Session-Id']" -ForegroundColor Gray

Write-Host "`n`nTrace complete!`n" -ForegroundColor Cyan
