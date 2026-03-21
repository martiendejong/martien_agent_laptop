<#
.SYNOPSIS
Screen time monitor - tracks work hours and sleep patterns

.DESCRIPTION
Runs continuously in background, logs activity every minute to JSONL file.
Detects work (VS Code, browsers, dev tools), idle time, and estimates sleep.

Auto-starts on login via scheduled task (run setup-screen-time-monitor.ps1 first).

.NOTES
Log location: E:\jengo\health\screen-time.jsonl
#>

param(
    [switch]$Verbose
)

$ErrorActionPreference = "SilentlyContinue"

# Ensure log directory exists
$logPath = "E:\jengo\health\screen-time.jsonl"
$logDir = Split-Path $logPath -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Windows API for idle time detection
Add-Type @'
using System;
using System.Runtime.InteropServices;

public class IdleTimeDetector {
    [DllImport("user32.dll")]
    static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    [StructLayout(LayoutKind.Sequential)]
    struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }

    public static uint GetIdleSeconds() {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
        if (GetLastInputInfo(ref lii)) {
            return ((uint)Environment.TickCount - lii.dwTime) / 1000;
        }
        return 0;
    }
}
'@

# Windows API for active window title
Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public class ActiveWindowDetector {
    [DllImport("user32.dll")]
    static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);

    public static string GetTitle() {
        IntPtr hWnd = GetForegroundWindow();
        if (hWnd == IntPtr.Zero) return "";

        StringBuilder sb = new StringBuilder(256);
        GetWindowText(hWnd, sb, 256);
        return sb.ToString();
    }
}
'@

function Write-Log {
    param([string]$Message)
    if ($Verbose) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    }
}

Write-Log "Screen time monitor started"

# Main loop - check every minute
while ($true) {
    try {
        $idleSeconds = [IdleTimeDetector]::GetIdleSeconds()
        $windowTitle = [ActiveWindowDetector]::GetTitle()

        # Determine activity type
        $activity = if ($idleSeconds -gt 300) {
            # >5 min idle = idle
            "idle"
        } elseif ($windowTitle -match "Visual Studio Code|Chrome|Edge|Firefox|Visual Studio|Claude|PowerShell|Terminal") {
            # Dev tools = work
            "work"
        } elseif ($windowTitle -match "Outlook|Teams|Slack|Discord") {
            # Communication = work (for Martien's case)
            "work"
        } else {
            # Other applications
            "other"
        }

        # Create log entry
        $entry = [ordered]@{
            timestamp = (Get-Date).ToString("o")
            activity = $activity
            window = $windowTitle.Substring(0, [Math]::Min(100, $windowTitle.Length))  # Truncate long titles
            idleSeconds = $idleSeconds
        }

        # Log to JSONL (one JSON object per line)
        $json = $entry | ConvertTo-Json -Compress
        Add-Content -Path $logPath -Value $json -Encoding UTF8

        Write-Log "Logged: $activity ($($windowTitle.Substring(0, [Math]::Min(30, $windowTitle.Length))))"

    } catch {
        Write-Log "Error: $($_.Exception.Message)"
    }

    # Wait 60 seconds before next check
    Start-Sleep -Seconds 60
}
