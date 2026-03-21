@echo off
powershell.exe -ExecutionPolicy Bypass -Command "Import-Module C:\scripts\agentidentity\scp-metrics-logger.ps1; Get-SCPMetricsReport"
