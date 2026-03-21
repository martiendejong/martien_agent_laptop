"""Full diagnostic of the issue"""
import paramiko
import time

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Full Diagnostic')
print('='*60)

# Check .NET
print('\n1. .NET Runtime:')
stdin, stdout, stderr = client.exec_command('dotnet --version')
print(f'   Version: {stdout.read().decode("utf-8", errors="ignore").strip()}')

# Check ASP.NET Core Module
print('\n2. ASP.NET Core Module:')
stdin, stdout, stderr = client.exec_command('powershell Get-WebGlobalModule -Name AspNetCoreModuleV2')
print(stdout.read().decode('utf-8', errors='ignore'))

# List runtime files
print('\n3. Application Files:')
stdin, stdout, stderr = client.exec_command('dir C:\\inetpub\\vault.prospergenics.com\\*.dll /b')
dlls = stdout.read().decode('utf-8', errors='ignore')
print(f'   DLLs found: {len(dlls.split())}')

# Try accessing via HTTP
print('\n4. Testing HTTP access (port 80):')
stdin, stdout, stderr = client.exec_command('powershell Invoke-WebRequest -Uri "http://vault.prospergenics.com" -UseBasicParsing -TimeoutSec 5')
output = stdout.read().decode('utf-8', errors='ignore')
error = stderr.read().decode('utf-8', errors='ignore')
if 'StatusCode' in output:
    print(f'   {output}')
else:
    print(f'   Error: {error[:200]}')

# Check recent logs directory
print('\n5. Checking for any log files:')
stdin, stdout, stderr = client.exec_command('dir C:\\inetpub\\vault.prospergenics.com\\logs /b /s 2>nul')
logs = stdout.read().decode('utf-8', errors='ignore').strip()
if logs:
    print(f'   Found logs: {logs}')
    # Read the newest one
    stdin, stdout, stderr = client.exec_command(f'type "{logs.split()[0]}" 2>nul')
    print('   Content:')
    print(stdout.read().decode('utf-8', errors='ignore')[:1000])
else:
    print('   No logs found')

# Check Event Viewer for .NET errors
print('\n6. Recent .NET/IIS errors:')
stdin, stdout, stderr = client.exec_command('powershell Get-WinEvent -LogName Application -MaxEvents 10 | Where-Object { $_.ProviderName -like "*IIS*" -or $_.ProviderName -like "*.NET*" } | Format-Table TimeCreated, ProviderName, Message -AutoSize')
print(stdout.read().decode('utf-8', errors='ignore')[:1000])

client.close()
