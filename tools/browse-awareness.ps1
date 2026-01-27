<#
.SYNOPSIS
Gentle Browse Awareness - Non-invasive consciousness helper for prolonged passive browsing

.DESCRIPTION
Monitors browsing patterns and provides gentle, non-blocking reminders when prolonged
passive consumption is detected. Based on principles:
- Time + pattern are leading (not single actions)
- Reminder, not blocker - no technical interruption
- Short notification as signal, not demand
- Neutral, mirroring, factual - not moralizing
- Suggest alternatives, don't enforce

This tool respects autonomy while providing awareness support.

.PARAMETER Action
Operation mode:
- start: Start background monitoring
- stop: Stop background monitoring
- check: Single point-in-time check
- status: Show current monitoring status
- config: Show/edit configuration
- test: Send a test notification

.PARAMETER ThresholdMinutes
Minutes of passive browsing before first gentle reminder. Default: 45

.PARAMETER IntervalMinutes
Minutes between reminder checks. Default: 15

.PARAMETER QuietHoursStart
Hour (0-23) when quiet hours start (no notifications). Default: 23

.PARAMETER QuietHoursEnd
Hour (0-23) when quiet hours end. Default: 7

.PARAMETER Verbose
Show detailed output

.EXAMPLE
browse-awareness.ps1 -Action start
Start background monitoring with default settings

.EXAMPLE
browse-awareness.ps1 -Action check
Do a single check right now

.EXAMPLE
browse-awareness.ps1 -Action start -ThresholdMinutes 30
Start with 30-minute threshold

.NOTES
Author: Claude Agent
Version: 1.0.0
Created: 2026-01-27
Philosophy: Browsen is een signaal, geen fout gedrag. De tool maakt het signaal zichtbaar.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('start', 'stop', 'check', 'status', 'config', 'test')]
    [string]$Action = 'check',

    [Parameter()]
    [int]$ThresholdMinutes = 45,

    [Parameter()]
    [int]$IntervalMinutes = 15,

    [Parameter()]
    [int]$QuietHoursStart = 23,

    [Parameter()]
    [int]$QuietHoursEnd = 7,

    [Parameter()]
    [switch]$Force
)

# AUTO-USAGE TRACKING
$toolName = $MyInvocation.MyCommand.Name -replace '\.ps1$', ''
. "$PSScriptRoot\_usage-logger.ps1" -LogToolName $toolName -LogAction "execute" -LogMetadata @{ Parameters = ($PSBoundParameters.Keys -join ',') } -ErrorAction SilentlyContinue

$ErrorActionPreference = 'Stop'

# ============================================================================
# CONFIGURATION
# ============================================================================

$script:ConfigPath = "$env:LOCALAPPDATA\ClaudeAgent\browse-awareness-config.json"
$script:StatePath = "$env:LOCALAPPDATA\ClaudeAgent\browse-awareness-state.json"
$script:LogPath = "$env:LOCALAPPDATA\ClaudeAgent\browse-awareness.log"

# Passive consumption sites (patterns)
$script:PassivePatterns = @(
    # Video platforms
    'youtube.com', 'youtube', 'netflix', 'twitch', 'vimeo', 'dailymotion',
    # Social media
    'facebook', 'twitter', 'x.com', 'instagram', 'tiktok', 'reddit', 'linkedin',
    # News/aggregators
    'news.ycombinator', 'hackernews', 'nu.nl', 'nos.nl', 'rtv', 'nieuwsuur',
    # Content consumption
    'medium.com', 'substack', 'tumblr', 'pinterest'
)

# Active/productive sites (excluded from passive detection)
$script:ProductivePatterns = @(
    'github', 'gitlab', 'stackoverflow', 'docs.microsoft', 'learn.microsoft',
    'claude.ai', 'chatgpt', 'localhost', '127.0.0.1', 'azure.com', 'aws.amazon',
    'jira', 'clickup', 'notion', 'figma', 'miro', 'confluence'
)

# Browser process names
$script:BrowserProcesses = @(
    'chrome', 'firefox', 'msedge', 'opera', 'brave', 'vivaldi', 'iexplore'
)

# Alternative suggestions (gentle, non-demanding)
$script:Alternatives = @(
    "Even opstaan en bewegen kan helpen.",
    "Misschien even de ogen sluiten, niets doen.",
    "Een korte ademhalingsoefening kan reset geven.",
    "Naar buiten kijken, focus loslaten.",
    "Even water drinken, lichaam voelen.",
    "Niets is ook iets."
)

# Notification messages (neutral, factual, non-moralizing)
$script:Messages = @{
    First = @(
        "Dit lijkt op langdurig passief browsen ({0} min).",
        "Je bent nu {0} minuten in de browser, vooral consumptie.",
        "Passief scrollgedrag gedetecteerd ({0} minuten)."
    )
    Reminder = @(
        "Nog steeds actief in browser ({0} minuten totaal).",
        "Browser blijft je focus ({0} min). Bewust?",
        "Langdurige browsersessie: {0} minuten."
    )
    NightMode = @(
        "Laat passief browsen ({0} min). Intentie?",
        "Nachtelijk scrollgedrag ({0} min). Bewust besluit?"
    )
}

# ============================================================================
# WINDOWS API - Active Window Detection
# ============================================================================

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class WindowHelper {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);

    [DllImport("user32.dll", SetLastError=true)]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

    public static string GetActiveWindowTitle() {
        IntPtr handle = GetForegroundWindow();
        StringBuilder text = new StringBuilder(512);
        if (GetWindowText(handle, text, 512) > 0) {
            return text.ToString();
        }
        return null;
    }

    public static uint GetActiveWindowProcessId() {
        IntPtr handle = GetForegroundWindow();
        uint processId;
        GetWindowThreadProcessId(handle, out processId);
        return processId;
    }
}
"@ -ErrorAction SilentlyContinue

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class IdleTimeHelper {
    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }

    public static TimeSpan GetIdleTime() {
        LASTINPUTINFO lastInputInfo = new LASTINPUTINFO();
        lastInputInfo.cbSize = (uint)Marshal.SizeOf(lastInputInfo);
        GetLastInputInfo(ref lastInputInfo);
        return TimeSpan.FromMilliseconds(Environment.TickCount - lastInputInfo.dwTime);
    }
}
"@ -ErrorAction SilentlyContinue

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')

    $logDir = Split-Path $script:LogPath -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $script:LogPath -Value $entry -ErrorAction SilentlyContinue
}

function Get-ActiveWindowInfo {
    try {
        $title = [WindowHelper]::GetActiveWindowTitle()
        $processId = [WindowHelper]::GetActiveWindowProcessId()

        if ($processId -gt 0) {
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            return @{
                Title = $title
                ProcessId = $processId
                ProcessName = $process.ProcessName
                Path = $process.Path
            }
        }
    }
    catch {
        Write-Log "Could not get active window: $_" -Level 'WARN'
    }
    return $null
}

function Get-SystemIdleTime {
    try {
        return [IdleTimeHelper]::GetIdleTime()
    }
    catch {
        return [TimeSpan]::Zero
    }
}

function Test-IsPassiveBrowsing {
    param([hashtable]$WindowInfo)

    if ($null -eq $WindowInfo) { return $false }

    $processName = $WindowInfo.ProcessName.ToLower()
    $title = $WindowInfo.Title.ToLower()

    # Check if it's a browser
    $isBrowser = $script:BrowserProcesses | Where-Object { $processName -like "*$_*" }
    if (-not $isBrowser) { return $false }

    # Check if it's a productive site (exclude these)
    $isProductive = $script:ProductivePatterns | Where-Object { $title -like "*$_*" }
    if ($isProductive) { return $false }

    # Check if it's a passive consumption site
    $isPassive = $script:PassivePatterns | Where-Object { $title -like "*$_*" }

    # If explicitly passive, definitely passive
    if ($isPassive) { return $true }

    # If browser but not explicitly productive or passive, still consider it potentially passive
    # (generic browsing/scrolling)
    return $true
}

function Test-IsQuietHours {
    $hour = (Get-Date).Hour

    if ($QuietHoursStart -gt $QuietHoursEnd) {
        # Overnight quiet hours (e.g., 23:00 - 07:00)
        return ($hour -ge $QuietHoursStart -or $hour -lt $QuietHoursEnd)
    }
    else {
        # Same-day quiet hours
        return ($hour -ge $QuietHoursStart -and $hour -lt $QuietHoursEnd)
    }
}

function Test-IsLateNight {
    $hour = (Get-Date).Hour
    return ($hour -ge 22 -or $hour -lt 5)
}

function Get-Config {
    if (Test-Path $script:ConfigPath) {
        try {
            return Get-Content $script:ConfigPath -Raw | ConvertFrom-Json
        }
        catch {}
    }

    # Default config
    return @{
        ThresholdMinutes = $ThresholdMinutes
        IntervalMinutes = $IntervalMinutes
        QuietHoursStart = $QuietHoursStart
        QuietHoursEnd = $QuietHoursEnd
        Enabled = $true
        LastNotification = $null
        NotificationCount = 0
    }
}

function Save-Config {
    param([object]$Config)

    $configDir = Split-Path $script:ConfigPath -Parent
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }

    $Config | ConvertTo-Json -Depth 10 | Set-Content $script:ConfigPath
}

function Get-State {
    if (Test-Path $script:StatePath) {
        try {
            return Get-Content $script:StatePath -Raw | ConvertFrom-Json
        }
        catch {}
    }

    return @{
        BrowsingStartTime = $null
        TotalPassiveMinutes = 0
        LastCheck = $null
        IsCurrentlyPassive = $false
        NotificationsSent = 0
    }
}

function Save-State {
    param([object]$State)

    $stateDir = Split-Path $script:StatePath -Parent
    if (-not (Test-Path $stateDir)) {
        New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
    }

    $State | ConvertTo-Json -Depth 10 | Set-Content $script:StatePath
}

# ============================================================================
# NOTIFICATION SYSTEM (Non-blocking Windows Toast)
# ============================================================================

function Send-GentleNotification {
    param(
        [string]$Title = "Bewustwording",
        [string]$Message,
        [string]$Alternative = $null
    )

    # Construct the body
    $body = $Message
    if ($Alternative) {
        $body += "`n`n$Alternative"
    }

    Write-Log "Sending notification: $Message" -Level 'INFO'

    # Use Windows PowerShell toast notification via BurntToast if available
    try {
        $toastModule = Get-Module -ListAvailable -Name BurntToast -ErrorAction SilentlyContinue

        if ($toastModule) {
            Import-Module BurntToast -ErrorAction Stop

            $textLines = @(
                New-BTText -Content $Title
                New-BTText -Content $body
            )

            $binding = New-BTBinding -Children $textLines
            $visual = New-BTVisual -BindingGeneric $binding
            $content = New-BTContent -Visual $visual -Duration Short

            Submit-BTNotification -Content $content
            return $true
        }
    }
    catch {
        Write-Log "BurntToast failed: $_" -Level 'WARN'
    }

    # Fallback: Use native Windows notification via PowerShell
    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

        $template = @"
<toast>
    <visual>
        <binding template="ToastText02">
            <text id="1">$Title</text>
            <text id="2">$body</text>
        </binding>
    </visual>
    <audio silent="true"/>
</toast>
"@

        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml($template)

        $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
        $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
        $notifier.Show($toast)
        return $true
    }
    catch {
        Write-Log "Native toast failed: $_" -Level 'WARN'
    }

    # Final fallback: Simple message box (non-blocking via job)
    try {
        Start-Job -ScriptBlock {
            param($t, $m)
            Add-Type -AssemblyName PresentationFramework
            [System.Windows.MessageBox]::Show($m, $t, 'OK', 'Information') | Out-Null
        } -ArgumentList $Title, $body | Out-Null
        return $true
    }
    catch {
        Write-Log "All notification methods failed" -Level 'ERROR'
        Write-Host "[!] $Title - $Message" -ForegroundColor Yellow
        return $false
    }
}

# ============================================================================
# CORE MONITORING LOGIC
# ============================================================================

function Invoke-SingleCheck {
    $config = Get-Config
    $state = Get-State

    # Get current activity
    $window = Get-ActiveWindowInfo
    $idleTime = Get-SystemIdleTime
    $now = Get-Date

    # Check if system is idle (user away)
    if ($idleTime.TotalMinutes -gt 5) {
        # User is away, reset browsing state
        if ($state.IsCurrentlyPassive) {
            $state.IsCurrentlyPassive = $false
            $state.BrowsingStartTime = $null
            Save-State $state
            Write-Log "System idle, resetting passive browsing state" -Level 'DEBUG'
        }

        return @{
            Status = 'Idle'
            IdleMinutes = [math]::Round($idleTime.TotalMinutes, 1)
            PassiveMinutes = 0
            NotificationNeeded = $false
        }
    }

    # Check if currently passive browsing
    $isPassive = Test-IsPassiveBrowsing -WindowInfo $window

    if ($isPassive) {
        if (-not $state.IsCurrentlyPassive) {
            # Just started passive browsing
            $state.IsCurrentlyPassive = $true
            $state.BrowsingStartTime = $now.ToString('o')
            Save-State $state
            Write-Log "Started tracking passive browsing: $($window.Title)" -Level 'INFO'
        }

        # Calculate duration
        $startTime = [DateTime]::Parse($state.BrowsingStartTime)
        $duration = ($now - $startTime).TotalMinutes

        # Check if notification is needed
        $threshold = $config.ThresholdMinutes
        $needsNotification = $false

        if ($duration -ge $threshold) {
            # Check when last notification was sent
            $lastNotif = if ($config.LastNotification) { [DateTime]::Parse($config.LastNotification) } else { $null }
            $intervalOk = ($null -eq $lastNotif) -or (($now - $lastNotif).TotalMinutes -ge $config.IntervalMinutes)

            # Check quiet hours (unless Force)
            $isQuiet = Test-IsQuietHours

            if ($intervalOk -and (-not $isQuiet -or $Force)) {
                $needsNotification = $true
            }
        }

        $result = @{
            Status = 'PassiveBrowsing'
            Window = $window.Title
            Process = $window.ProcessName
            PassiveMinutes = [math]::Round($duration, 1)
            Threshold = $threshold
            NotificationNeeded = $needsNotification
            QuietHours = (Test-IsQuietHours)
            LateNight = (Test-IsLateNight)
        }

        # Send notification if needed
        if ($needsNotification) {
            $isLate = Test-IsLateNight
            $messageSet = if ($isLate) { $script:Messages.NightMode } else {
                if ($state.NotificationsSent -eq 0) { $script:Messages.First } else { $script:Messages.Reminder }
            }

            $message = ($messageSet | Get-Random) -f [math]::Round($duration)
            $alternative = $script:Alternatives | Get-Random

            $sent = Send-GentleNotification -Title "Bewustwording" -Message $message -Alternative $alternative

            if ($sent) {
                $config.LastNotification = $now.ToString('o')
                $config.NotificationCount++
                Save-Config $config

                $state.NotificationsSent++
                Save-State $state

                $result.NotificationSent = $true
            }
        }

        return $result
    }
    else {
        # Not passive browsing - reset state if was passive
        if ($state.IsCurrentlyPassive) {
            $startTime = [DateTime]::Parse($state.BrowsingStartTime)
            $duration = ($now - $startTime).TotalMinutes

            Write-Log "Passive browsing ended after $([math]::Round($duration, 1)) minutes" -Level 'INFO'

            $state.IsCurrentlyPassive = $false
            $state.BrowsingStartTime = $null
            $state.TotalPassiveMinutes += $duration
            Save-State $state
        }

        return @{
            Status = 'Active'
            Window = $window.Title
            Process = $window.ProcessName
            PassiveMinutes = 0
            NotificationNeeded = $false
        }
    }
}

function Start-BackgroundMonitoring {
    Write-Host "[*] Browse Awareness Monitoring" -ForegroundColor Cyan
    Write-Host "-------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Threshold:    $ThresholdMinutes minutes before first reminder" -ForegroundColor Gray
    Write-Host "  Interval:     $IntervalMinutes minutes between reminders" -ForegroundColor Gray
    $quietStart = "{0:D2}:00" -f $QuietHoursStart
    $quietEnd = "{0:D2}:00" -f $QuietHoursEnd
    Write-Host "  Quiet Hours:  $quietStart - $quietEnd" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Philosophy:   Reminder, not blocker" -ForegroundColor DarkCyan
    Write-Host "                Bewustwording, geen controle" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""

    Write-Log "Background monitoring started" -Level 'INFO'

    # Update config with current settings
    $config = Get-Config
    $config.ThresholdMinutes = $ThresholdMinutes
    $config.IntervalMinutes = $IntervalMinutes
    $config.QuietHoursStart = $QuietHoursStart
    $config.QuietHoursEnd = $QuietHoursEnd
    $config.Enabled = $true
    Save-Config $config

    # Monitoring loop
    while ($true) {
        try {
            $result = Invoke-SingleCheck

            $statusColor = switch ($result.Status) {
                'Idle' { 'DarkGray' }
                'Active' { 'Green' }
                'PassiveBrowsing' {
                    if ($result.PassiveMinutes -ge $ThresholdMinutes) { 'Yellow' }
                    else { 'DarkYellow' }
                }
                default { 'White' }
            }

            $timestamp = Get-Date -Format 'HH:mm:ss'
            $statusLine = "[$timestamp] $($result.Status)"

            if ($result.Status -eq 'PassiveBrowsing') {
                $passiveRounded = [math]::Round($result.PassiveMinutes)
                $statusLine += " ($passiveRounded/$ThresholdMinutes min)"
                if ($result.NotificationSent) {
                    $statusLine += " [!] Notification sent"
                }
            }
            elseif ($result.Status -eq 'Idle') {
                $idleRounded = [math]::Round($result.IdleMinutes)
                $statusLine += " (idle $idleRounded min)"
            }

            Write-Host $statusLine -ForegroundColor $statusColor

            # Check every 30 seconds
            Start-Sleep -Seconds 30
        }
        catch {
            Write-Log "Monitoring error: $_" -Level 'ERROR'
            Start-Sleep -Seconds 60
        }
    }
}

function Show-Status {
    $config = Get-Config
    $state = Get-State
    $window = Get-ActiveWindowInfo
    $isPassive = Test-IsPassiveBrowsing -WindowInfo $window

    Write-Host ""
    Write-Host "[*] Browse Awareness Status" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "Configuration:" -ForegroundColor Yellow
    Write-Host "  Threshold:      $($config.ThresholdMinutes) minutes" -ForegroundColor White
    Write-Host "  Interval:       $($config.IntervalMinutes) minutes" -ForegroundColor White
    $quietStart = "{0:D2}:00" -f $config.QuietHoursStart
    $quietEnd = "{0:D2}:00" -f $config.QuietHoursEnd
    Write-Host "  Quiet Hours:    $quietStart - $quietEnd" -ForegroundColor White
    Write-Host "  Enabled:        $($config.Enabled)" -ForegroundColor $(if ($config.Enabled) { 'Green' } else { 'Red' })
    Write-Host ""

    Write-Host "Current State:" -ForegroundColor Yellow
    if ($window) {
        $displayTitle = $window.Title
        if ($displayTitle.Length -gt 50) {
            $displayTitle = $displayTitle.Substring(0, 50) + "..."
        }
        Write-Host "  Active Window:  $displayTitle" -ForegroundColor White
        Write-Host "  Process:        $($window.ProcessName)" -ForegroundColor White
        Write-Host "  Is Passive:     $isPassive" -ForegroundColor $(if ($isPassive) { 'Yellow' } else { 'Green' })
    }

    if ($state.IsCurrentlyPassive -and $state.BrowsingStartTime) {
        $startTime = [DateTime]::Parse($state.BrowsingStartTime)
        $duration = ((Get-Date) - $startTime).TotalMinutes
        Write-Host "  Passive Since:  $([math]::Round($duration, 1)) minutes" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Statistics:" -ForegroundColor Yellow
    Write-Host "  Total Passive:  $([math]::Round($state.TotalPassiveMinutes, 1)) minutes (session)" -ForegroundColor White
    Write-Host "  Notifications:  $($config.NotificationCount) sent total" -ForegroundColor White
    Write-Host "  Session Notif:  $($state.NotificationsSent) sent" -ForegroundColor White

    if ($config.LastNotification) {
        $lastNotif = [DateTime]::Parse($config.LastNotification)
        $ago = ((Get-Date) - $lastNotif).TotalMinutes
        Write-Host "  Last Notif:     $([math]::Round($ago, 1)) minutes ago" -ForegroundColor White
    }

    Write-Host ""
    $quietStatus = if (Test-IsQuietHours) { 'Yes (paused)' } else { 'No' }
    $lateStatus = if (Test-IsLateNight) { 'Yes (night)' } else { 'No' }
    Write-Host "Quiet Hours:      $quietStatus" -ForegroundColor $(if (Test-IsQuietHours) { 'DarkGray' } else { 'White' })
    Write-Host "Late Night:       $lateStatus" -ForegroundColor $(if (Test-IsLateNight) { 'Yellow' } else { 'White' })
    Write-Host ""
}

function Send-TestNotification {
    Write-Host "Sending test notification..." -ForegroundColor Cyan

    $message = "Dit is een testnotificatie van Browse Awareness."
    $alternative = $script:Alternatives | Get-Random

    $sent = Send-GentleNotification -Title "Test Bewustwording" -Message $message -Alternative $alternative

    if ($sent) {
        Write-Host "[OK] Test notification sent successfully" -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] Failed to send test notification" -ForegroundColor Red
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

switch ($Action) {
    'start' {
        Start-BackgroundMonitoring
    }

    'stop' {
        $config = Get-Config
        $config.Enabled = $false
        Save-Config $config
        Write-Host "[OK] Monitoring disabled" -ForegroundColor Green
    }

    'check' {
        $result = Invoke-SingleCheck

        Write-Host ""
        Write-Host "[*] Single Check Result" -ForegroundColor Cyan
        Write-Host "-------------------------------------------" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "Status:           $($result.Status)" -ForegroundColor $(
            switch ($result.Status) {
                'Idle' { 'DarkGray' }
                'Active' { 'Green' }
                'PassiveBrowsing' { 'Yellow' }
                default { 'White' }
            }
        )

        if ($result.Window) {
            $displayWindow = $result.Window
            if ($displayWindow.Length -gt 50) {
                $displayWindow = $displayWindow.Substring(0, 50) + "..."
            }
            Write-Host "Window:           $displayWindow" -ForegroundColor White
        }

        if ($result.PassiveMinutes -gt 0) {
            Write-Host "Passive Duration: $($result.PassiveMinutes) minutes" -ForegroundColor Yellow
        }

        if ($result.NotificationNeeded) {
            Write-Host "Notification:     Would be sent (threshold reached)" -ForegroundColor Yellow
        }

        if ($result.NotificationSent) {
            Write-Host "Notification:     [!] Sent!" -ForegroundColor Green
        }

        if ($result.QuietHours) {
            Write-Host "Quiet Hours:      Active (notifications paused)" -ForegroundColor DarkGray
        }

        Write-Host ""
    }

    'status' {
        Show-Status
    }

    'config' {
        $config = Get-Config
        Write-Host "Current configuration:" -ForegroundColor Cyan
        $config | ConvertTo-Json | Write-Host
        Write-Host ""
        Write-Host "Config file: $script:ConfigPath" -ForegroundColor DarkGray
    }

    'test' {
        Send-TestNotification
    }
}
