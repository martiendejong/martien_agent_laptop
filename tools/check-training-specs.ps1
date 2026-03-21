$cs = Get-WmiObject Win32_ComputerSystem
$ram = [math]::Round($cs.TotalPhysicalMemory/1GB, 2)
Write-Host "RAM: $ram GB"

$cpu = Get-WmiObject Win32_Processor
Write-Host "CPU: $($cpu.Name)"

$gpu = Get-WmiObject Win32_VideoController | Where-Object {$_.Name -notlike '*Microsoft*'} | Select-Object -First 1
if ($gpu) {
    $vram = [math]::Round($gpu.AdapterRAM/1GB, 2)
    Write-Host "GPU: $($gpu.Name)"
    Write-Host "VRAM: $vram GB"
} else {
    Write-Host "GPU: None detected"
}
