# Check Hazina Orchestration Service
Write-Host "=== Hazina Orchestration Service Status ===" -ForegroundColor Cyan

# Get service details
$service = Get-Service -Name "HazinaOrchestrator" -ErrorAction SilentlyContinue
if ($service) {
    Write-Host "Service Name: $($service.Name)"
    Write-Host "Display Name: $($service.DisplayName)"
    Write-Host "Status: $($service.Status)" -ForegroundColor $(if ($service.Status -eq 'Running') { 'Green' } else { 'Yellow' })
    Write-Host "Start Type: $($service.StartType)"

    # Get service path
    $wmiService = Get-WmiObject win32_service | Where-Object {$_.Name -eq 'HazinaOrchestrator'}
    if ($wmiService) {
        Write-Host "Path: $($wmiService.PathName)"

        # Check if exe exists
        $exePath = $wmiService.PathName -replace '"', ''
        if (Test-Path $exePath) {
            $exeInfo = Get-Item $exePath
            Write-Host "Exe exists: Yes ($($exeInfo.Length / 1MB) MB, modified $($exeInfo.LastWriteTime))"
        } else {
            Write-Host "Exe exists: NO - FILE NOT FOUND!" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Service not found!" -ForegroundColor Red
    exit
}

Write-Host "`n=== Attempting to start service ===" -ForegroundColor Cyan
try {
    Start-Service -Name "HazinaOrchestrator" -ErrorAction Stop
    Write-Host "Service started successfully!" -ForegroundColor Green

    # Wait and check status
    Start-Sleep -Seconds 2
    $service = Get-Service -Name "HazinaOrchestrator"
    Write-Host "Current status: $($service.Status)" -ForegroundColor Green
} catch {
    Write-Host "Failed to start service!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red

    # Check event log for recent errors
    Write-Host "`n=== Recent Application Event Log Errors ===" -ForegroundColor Cyan
    Get-EventLog -LogName Application -EntryType Error -Newest 5 -ErrorAction SilentlyContinue |
        Where-Object {$_.TimeGenerated -gt (Get-Date).AddHours(-1)} |
        Format-List TimeGenerated, Source, Message
}
