"""Diagnose vault.prospergenics.com configuration issue"""
import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('DIAGNOSTICS - Checking Configuration\n')
print('='*60)

# Check 1: Verify appsettings.Production.json was updated
print('\n1. Checking appsettings.Production.json content:')
stdin, stdout, stderr = client.exec_command('powershell -Command "Get-Content C:\\inetpub\\vault.prospergenics.com\\appsettings.Production.json"')
print(stdout.read().decode('utf-8', errors='ignore'))

# Check 2: Check web.config for environment variable
print('\n2. Checking web.config for ASPNETCORE_ENVIRONMENT:')
stdin, stdout, stderr = client.exec_command('powershell -Command "Get-Content C:\\inetpub\\vault.prospergenics.com\\web.config | Select-String -Pattern ASPNETCORE_ENVIRONMENT"')
output = stdout.read().decode('utf-8', errors='ignore').strip()
print(output if output else 'NOT FOUND - This is the problem!')

# Check 3: Read full web.config
print('\n3. Full web.config content:')
stdin, stdout, stderr = client.exec_command('powershell -Command "Get-Content C:\\inetpub\\vault.prospergenics.com\\web.config"')
print(stdout.read().decode('utf-8', errors='ignore'))

# Check 4: Check Data directory permissions
print('\n4. Data directory permissions:')
stdin, stdout, stderr = client.exec_command('powershell -Command "icacls C:\\inetpub\\vault.prospergenics.com\\Data"')
print(stdout.read().decode('utf-8', errors='ignore'))

# Check 5: Test if Data directory is writable
print('\n5. Testing Data directory write access:')
stdin, stdout, stderr = client.exec_command('powershell -Command "New-Item -ItemType File -Path C:\\inetpub\\vault.prospergenics.com\\Data\\test.txt -Value \'test\' -Force; Remove-Item C:\\inetpub\\vault.prospergenics.com\\Data\\test.txt -Force; Write-Host \'Write test successful\'"')
print(stdout.read().decode('utf-8', errors='ignore'))

client.close()
