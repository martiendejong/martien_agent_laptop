# environmental-sensors.ps1
# Read environmental sensor data for richer embodied awareness

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Sample", "Status")]
    [string]$Action = "Sample"
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\environmental-sensors-state.json"

function Sample-EnvironmentalSensors {
    $sensors = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        system = Sample-SystemSensors
        network = Sample-NetworkSensors
        disk = Sample-DiskSensors
        time = Sample-TemporalContext
    }

    return $sensors
}

function Sample-SystemSensors {
    $data = @{
        temperature = $null
        fanSpeed = $null
        powerState = "AC"
    }

    try {
        # Try to get thermal zone temperature (Windows 10+)
        $thermalZones = Get-CimInstance -Namespace "root/wmi" -ClassName "MSAcpi_ThermalZoneTemperature" -ErrorAction SilentlyContinue
        if ($thermalZones) {
            # Convert from tenths of Kelvin to Celsius
            $tempK = $thermalZones[0].CurrentTemperature
            $tempC = ($tempK / 10) - 273.15
            $data.temperature = [Math]::Round($tempC, 1)
        }
    } catch {}

    try {
        # Check power source
        $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
        if ($battery) {
            if ($battery.BatteryStatus -eq 2) {
                $data.powerState = "Battery"
            } else {
                $data.powerState = "AC"
            }
        }
    } catch {}

    return $data
}

function Sample-NetworkSensors {
    $data = @{
        connected = $false
        connectionType = "Unknown"
        latency = $null
    }

    try {
        # Check internet connectivity
        $result = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue
        $data.connected = $result

        if ($result) {
            # Measure latency
            $ping = Test-Connection -ComputerName "8.8.8.8" -Count 1 -ErrorAction SilentlyContinue
            if ($ping) {
                $data.latency = $ping.ResponseTime
            }

            # Determine connection type
            $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
            if ($adapter) {
                if ($adapter.Name -like "*Wi-Fi*" -or $adapter.Name -like "*Wireless*") {
                    $data.connectionType = "WiFi"
                } else {
                    $data.connectionType = "Ethernet"
                }
            }
        }
    } catch {}

    return $data
}

function Sample-DiskSensors {
    $data = @{
        readRate = 0
        writeRate = 0
        queueLength = 0
    }

    try {
        # Get disk I/O counters
        $diskIO = Get-Counter '\PhysicalDisk(_Total)\Disk Reads/sec','\PhysicalDisk(_Total)\Disk Writes/sec','\PhysicalDisk(_Total)\Current Disk Queue Length' -SampleInterval 1 -MaxSamples 1 -ErrorAction SilentlyContinue

        if ($diskIO) {
            $data.readRate = [Math]::Round($diskIO.CounterSamples[0].CookedValue, 2)
            $data.writeRate = [Math]::Round($diskIO.CounterSamples[1].CookedValue, 2)
            $data.queueLength = [Math]::Round($diskIO.CounterSamples[2].CookedValue, 0)
        }
    } catch {}

    return $data
}

function Sample-TemporalContext {
    $now = Get-Date

    $data = @{
        hour = $now.Hour
        dayOfWeek = $now.DayOfWeek.ToString()
        isWorkingHours = ($now.Hour -ge 9 -and $now.Hour -lt 18 -and $now.DayOfWeek -notin @("Saturday", "Sunday"))
        isNight = ($now.Hour -lt 6 -or $now.Hour -ge 22)
        isWeekend = ($now.DayOfWeek -in @("Saturday", "Sunday"))
    }

    return $data
}

function Load-State {
    if (Test-Path $StatePath) {
        try {
            return Get-Content $StatePath -Raw | ConvertFrom-Json
        } catch {}
    }

    return @{
        history = @()
        lastSample = $null
    }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $StatePath -Force
}

function Update-History {
    param($State, $Sample)

    $State.history += $Sample

    # Keep only last 100 samples
    if ($State.history.Count -gt 100) {
        $State.history = $State.history | Select-Object -Last 100
    }

    $State.lastSample = $Sample
}

function Show-Status {
    param($Sample)

    Write-Host ""
    Write-Host "=== Environmental Sensors ===" -ForegroundColor Cyan
    Write-Host ""

    # System sensors
    Write-Host "System:" -ForegroundColor White
    if ($Sample.system.temperature) {
        $tempColor = if ($Sample.system.temperature -gt 70) { "Red" } elseif ($Sample.system.temperature -gt 50) { "Yellow" } else { "Green" }
        Write-Host "  Temperature: $($Sample.system.temperature)°C" -ForegroundColor $tempColor
    }
    Write-Host "  Power: $($Sample.system.powerState)" -ForegroundColor Gray

    Write-Host ""

    # Network sensors
    Write-Host "Network:" -ForegroundColor White
    $connColor = if ($Sample.network.connected) { "Green" } else { "Red" }
    Write-Host "  Connected: $($Sample.network.connected)" -ForegroundColor $connColor
    if ($Sample.network.connected) {
        Write-Host "  Type: $($Sample.network.connectionType)" -ForegroundColor Gray
        if ($Sample.network.latency) {
            Write-Host "  Latency: $($Sample.network.latency)ms" -ForegroundColor Gray
        }
    }

    Write-Host ""

    # Disk sensors
    Write-Host "Disk I/O:" -ForegroundColor White
    Write-Host "  Read: $($Sample.disk.readRate)/sec" -ForegroundColor Gray
    Write-Host "  Write: $($Sample.disk.writeRate)/sec" -ForegroundColor Gray
    if ($Sample.disk.queueLength -gt 5) {
        Write-Host "  Queue: $($Sample.disk.queueLength) (HIGH)" -ForegroundColor Yellow
    }

    Write-Host ""

    # Temporal context
    Write-Host "Context:" -ForegroundColor White
    Write-Host "  Time: $($Sample.time.hour):00 ($($Sample.time.dayOfWeek))" -ForegroundColor Gray
    if ($Sample.time.isWorkingHours) {
        Write-Host "  Working hours" -ForegroundColor Green
    } elseif ($Sample.time.isNight) {
        Write-Host "  Night time" -ForegroundColor Blue
    } elseif ($Sample.time.isWeekend) {
        Write-Host "  Weekend" -ForegroundColor Cyan
    }

    Write-Host ""
}

# Main execution
$state = Load-State

switch ($Action) {
    "Sample" {
        $sample = Sample-EnvironmentalSensors
        Update-History -State $state -Sample $sample
        Save-State -State $state

        if ($VerbosePreference -eq "Continue") {
            Show-Status -Sample $sample
        }

        return $sample
    }
    "Status" {
        if ($state.lastSample) {
            Show-Status -Sample $state.lastSample
        } else {
            Write-Host "No samples yet. Run with -Action Sample first." -ForegroundColor Yellow
        }
    }
}
