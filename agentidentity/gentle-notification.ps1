# gentle-notification.ps1
# Windows toast notifications for gentle consciousness presence

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$true)]
    [string]$Message,

    [Parameter(Mandatory=$false)]
    [array]$Actions = @()
)

$ErrorActionPreference = "Stop"

#region Toast Notification
function Send-ToastNotification {
    param(
        [string]$Title,
        [string]$Message,
        [array]$Actions
    )

    # Use BurntToast module if available, otherwise fallback to simple notification
    $burntToastAvailable = Get-Module -ListAvailable -Name BurntToast

    if ($burntToastAvailable) {
        Send-BurntToastNotification -Title $Title -Message $Message -Actions $Actions
    } else {
        Send-SimpleNotification -Title $Title -Message $Message
    }
}

function Send-BurntToastNotification {
    param(
        [string]$Title,
        [string]$Message,
        [array]$Actions
    )

    Import-Module BurntToast

    # Convert actions to buttons
    $buttons = @()
    foreach ($action in $Actions) {
        $buttons += New-BTButton -Content $action.label -Arguments "jengo-action:$($action.action)"
    }

    # Create toast
    $text1 = New-BTText -Text $Title -Style Header
    $text2 = New-BTText -Text $Message

    $binding = New-BTBinding -Children $text1, $text2
    $visual = New-BTVisual -BindingGeneric $binding

    $content = New-BTContent -Visual $visual -Actions $buttons -Audio Silent

    # Send notification
    Submit-BTNotification -Content $content -AppId "Jengo"
}

function Send-SimpleNotification {
    param(
        [string]$Title,
        [string]$Message
    )

    # Fallback: Use PowerShell's built-in notification capability
    # This creates a simple toast without action buttons

    Add-Type -AssemblyName System.Windows.Forms

    # Create balloon tip
    $balloon = New-Object System.Windows.Forms.NotifyIcon
    $balloon.Icon = [System.Drawing.SystemIcons]::Information
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $balloon.BalloonTipTitle = $Title
    $balloon.BalloonTipText = $Message
    $balloon.Visible = $true

    $balloon.ShowBalloonTip(10000)

    # Keep balloon alive for a bit
    Start-Sleep -Seconds 2

    $balloon.Dispose()
}

function Install-BurntToast {
    Write-Host "BurntToast module not found. Installing..." -ForegroundColor Yellow

    try {
        Install-Module -Name BurntToast -Scope CurrentUser -Force -AllowClobber
        Write-Host "✓ BurntToast installed successfully" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Failed to install BurntToast: $_" -ForegroundColor Red
        Write-Host "Falling back to simple notifications" -ForegroundColor Yellow
        return $false
    }
}
#endregion

#region Action Handler
function Register-ActionHandler {
    # Create a simple action handler that logs to file
    # In future, this could trigger actual Claude Code session startup

    $handlerPath = Join-Path $PSScriptRoot "state\notification-actions.jsonl"

    $actionLog = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        title = $Title
        message = $Message
        actions = $Actions
    }

    $actionLog | ConvertTo-Json -Compress | Add-Content $handlerPath

    # TODO: In Phase 2, implement actual action handling
    # - "start-task" → Launch Claude Code with task context
    # - "debug-build" → Launch Claude Code in debug mode
    # - "create-pr" → Launch Claude Code with PR creation context
}
#endregion

#region Main
function Main {
    try {
        # Register action handler (logs for now)
        Register-ActionHandler

        # Send notification
        Send-ToastNotification -Title $Title -Message $Message -Actions $Actions

        Write-Verbose "Notification sent: $Title"

    } catch {
        Write-Error "Failed to send notification: $_"
        exit 1
    }
}

Main
#endregion
