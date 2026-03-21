"""Diagnose extension deployment and check CORS/API configuration"""
import paramiko
import json

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Extension Deployment Diagnosis')
print('='*60)

sftp = c.open_sftp()

# Check deployed extension
print('\n1. Checking deployed extension files...')
stdin, stdout, stderr = c.exec_command('powershell Get-ChildItem C:\\inetpub\\vault.prospergenics.com\\wwwroot\\extension -Recurse | Select-Object Name, Length')
files = stdout.read().decode('utf-8', errors='ignore')
print(files)

# Check CORS configuration in appsettings
print('\n2. Checking CORS configuration...')
with sftp.open('C:/inetpub/vault.prospergenics.com/appsettings.Production.json', 'r') as f:
    config = json.load(f)
    if 'AllowedOrigins' in config:
        print(f'   AllowedOrigins: {config["AllowedOrigins"]}')
    else:
        print('   No AllowedOrigins found in config')
        print('   Current config keys:', list(config.keys()))

# Check if we can read the deployed extension's background.js
print('\n3. Checking deployed extension API URL...')
try:
    with sftp.open('C:/inetpub/vault.prospergenics.com/wwwroot/extension/dist/background.js', 'r') as f:
        content = f.read().decode('utf-8', errors='ignore')
        if 'vault.prospergenics.com' in content:
            print('   ✓ Extension has production API URL')
        elif 'localhost' in content:
            print('   ✗ Extension still has localhost URL!')
        else:
            print('   ? Could not determine API URL')
except Exception as e:
    print(f'   Could not read deployed extension: {e}')

# Test API endpoints accessibility
print('\n4. Testing API endpoint from server...')
stdin, stdout, stderr = c.exec_command('powershell Invoke-WebRequest -Uri https://vault.prospergenics.com/api/auth/register -Method OPTIONS -UseBasicParsing | Select-Object StatusCode, Headers')
result = stdout.read().decode('utf-8', errors='ignore')
print(result[:500] if result else 'No response')

sftp.close()
c.close()

print('\n' + '='*60)
print('Next: Check browser console for actual errors')
print('Extension should show CORS or authentication errors in console')
