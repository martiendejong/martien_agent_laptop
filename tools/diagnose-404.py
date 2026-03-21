"""Diagnose 404 error"""
import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('DIAGNOSING 404 ERROR')
print('='*60)

# Check 1: Application pool status
print('\n1. Application Pool Status:')
stdin, stdout, stderr = client.exec_command('powershell Import-Module WebAdministration; Get-WebAppPoolState vault.prospergenics.com')
status = stdout.read().decode('utf-8', errors='ignore').strip()
print(f'   Status: {status}')

if 'Stopped' in status:
    print('   ERROR: App pool is stopped! Starting it...')
    stdin, stdout, stderr = client.exec_command('powershell Import-Module WebAdministration; Start-WebAppPool vault.prospergenics.com')
    print('   Started')

# Check 2: IIS site status
print('\n2. IIS Site Status:')
stdin, stdout, stderr = client.exec_command('powershell Import-Module WebAdministration; Get-Website vault.prospergenics.com | Select-Object Name, State, PhysicalPath, @{n="Bindings";e={$_.bindings.Collection.bindingInformation}} | Format-List')
print(stdout.read().decode('utf-8', errors='ignore'))

# Check 3: Check if DLL exists
print('3. Checking application files:')
stdin, stdout, stderr = client.exec_command('powershell Test-Path C:\\inetpub\\vault.prospergenics.com\\PasswordManager.API.dll')
dll_exists = stdout.read().decode('utf-8', errors='ignore').strip()
print(f'   PasswordManager.API.dll exists: {dll_exists}')

# Check 4: List all files in site directory
print('\n4. Files in site directory:')
stdin, stdout, stderr = client.exec_command('powershell Get-ChildItem C:\\inetpub\\vault.prospergenics.com -File | Select-Object Name, Length')
print(stdout.read().decode('utf-8', errors='ignore'))

# Check 5: Check IIS logs
print('\n5. Recent IIS errors (last 10 lines):')
stdin, stdout, stderr = client.exec_command('powershell Get-EventLog -LogName Application -Source "IIS*","ASP.NET*" -Newest 10 -ErrorAction SilentlyContinue | Format-Table TimeGenerated, Source, Message -AutoSize')
print(stdout.read().decode('utf-8', errors='ignore'))

# Check 6: Enable stdout logging and check web.config
print('\n6. Current web.config:')
stdin, stdout, stderr = client.exec_command('cmd /c type C:\\inetpub\\vault.prospergenics.com\\web.config')
print(stdout.read().decode('utf-8', errors='ignore'))

# Check 7: Try to manually test the app
print('\n7. Testing localhost access from server:')
stdin, stdout, stderr = client.exec_command('powershell Invoke-WebRequest -Uri http://localhost -UseBasicParsing -ErrorAction SilentlyContinue | Select-Object StatusCode, StatusDescription')
result = stdout.read().decode('utf-8', errors='ignore')
error = stderr.read().decode('utf-8', errors='ignore')
print(f'   Result: {result if result else "Error"}')
if error:
    print(f'   Error: {error}')

client.close()
