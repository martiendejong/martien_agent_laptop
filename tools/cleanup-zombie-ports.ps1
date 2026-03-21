# cleanup-zombie-ports.ps1
# Kills zombie dev server processes occupying development ports
# Created: 2026-03-02 after Zombie Process Crisis

param(
    [string]$PortRange,
    [switch]$All,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Define dev server port ranges
$DevServerPorts = @{
    "Frontend" = 3000..3999 + 5190..5299
    "Backend" = 5000..5189 + 7000..7099
}

# Parse port range if provided
if ($PortRange) {
    if ($PortRange -match "^(\d+)-(\d+)$") {
        $StartPort = [int]$matches[1]
        $EndPort = [int]$matches[2]
        $PortsToCheck = $StartPort..$EndPort
    } else {
        Write-Error "Invalid port range format. Use: 5190-5215"
        exit 1
    }
} elseif ($All) {
    $PortsToCheck = $DevServerPorts.Frontend + $DevServerPorts.Backend | Sort-Object -Unique
} else {
    Write-Host "Usage: .\cleanup-zombie-ports.ps1 [-PortRange '5190-5215'] [-All] [-Force]"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\cleanup-zombie-ports.ps1 -PortRange '5190-5215'  # Clean specific range"
    Write-Host "  .\cleanup-zombie-ports.ps1 -All                     # Clean all dev ports"
    Write-Host "  .\cleanup-zombie-ports.ps1 -All -Force              # No confirmation"
    exit 0
}

Write-Host "Scanning for zombie processes on ports: $($PortsToCheck -join ', ')" -ForegroundColor Cyan
Write-Host ""

# Get all listening processes
$NetstatOutput = netstat -ano | Select-String "LISTENING"

# Find processes on target ports
$ZombieProcesses = @()
foreach ($Port in $PortsToCheck) {
    $Matches = $NetstatOutput | Select-String ":$Port\s"
    foreach ($Match in $Matches) {
        if ($Match -match "\s+(\d+)\s*$") {
            $PID = $matches[1]
            try {
                $Process = Get-Process -Id $PID -ErrorAction Stop
                $ZombieProcesses += [PSCustomObject]@{
                    Port = $Port
                    PID = $PID
                    Name = $Process.ProcessName
                    StartTime = $Process.StartTime
                    Age = (Get-Date) - $Process.StartTime
                }
            } catch {
                # Process already gone or inaccessible
            }
        }
    }
}

if ($ZombieProcesses.Count -eq 0) {
    Write-Host "✓ No zombie processes found. All ports are clean!" -ForegroundColor Green
    exit 0
}

# Display found processes
Write-Host "Found $($ZombieProcesses.Count) process(es) on dev server ports:" -ForegroundColor Yellow
Write-Host ""
$ZombieProcesses | Format-Table Port, PID, Name, StartTime, @{Label="Age";Expression={"{0:hh\:mm\:ss}" -f $_.Age}} -AutoSize

# Confirm before killing
if (-not $Force) {
    $Confirmation = Read-Host "Kill these processes? (Y/N)"
    if ($Confirmation -ne "Y" -and $Confirmation -ne "y") {
        Write-Host "Aborted by user." -ForegroundColor Yellow
        exit 0
    }
}

# Kill processes
Write-Host ""
Write-Host "Killing processes..." -ForegroundColor Cyan
$KilledCount = 0
foreach ($Zombie in $ZombieProcesses) {
    try {
        Stop-Process -Id $Zombie.PID -Force -ErrorAction Stop
        Write-Host "✓ Killed PID $($Zombie.PID) ($($Zombie.Name)) on port $($Zombie.Port)" -ForegroundColor Green
        $KilledCount++
    } catch {
        Write-Host "✗ Failed to kill PID $($Zombie.PID): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Cleanup complete: $KilledCount of $($ZombieProcesses.Count) processes killed." -ForegroundColor Green
