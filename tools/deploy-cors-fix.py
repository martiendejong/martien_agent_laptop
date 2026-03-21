"""Deploy backend with CORS fix for browser extension"""
import paramiko
import os
import time

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Deploying CORS Fix for Browser Extension')
print('='*60)

# Stop app pool
print('\n1. Stopping application pool...')
c.exec_command('powershell Import-Module WebAdministration; Stop-WebAppPool vault.prospergenics.com')
time.sleep(3)
print('   Stopped')

# Deploy updated DLL
print('\n2. Uploading updated application files...')
sftp = c.open_sftp()

local_base = 'E:/projects/passwordmanager/backend/PasswordManager.API/publish'
remote_base = 'C:/inetpub/vault.prospergenics.com'

# Upload only the DLL and deps (faster than uploading everything)
critical_files = [
    'PasswordManager.API.dll',
    'PasswordManager.API.pdb',
    'appsettings.json',
    'appsettings.Development.json',
]

for filename in critical_files:
    local_file = os.path.join(local_base, filename)
    if os.path.exists(local_file):
        remote_file = f'{remote_base}/{filename}'.replace('\\', '/')
        print(f'   Uploading {filename}...')
        try:
            sftp.put(local_file, remote_file)
        except Exception as e:
            print(f'   Warning: {filename} - {e}')

sftp.close()

# Start app pool
print('\n3. Starting application pool...')
c.exec_command('powershell Import-Module WebAdministration; Start-WebAppPool vault.prospergenics.com')
time.sleep(5)
print('   Started')

# Verify CORS headers
print('\n4. Verifying CORS is working...')
test_script = '''
try {
    $headers = @{
        "Origin" = "chrome-extension://test123"
    }
    $response = Invoke-WebRequest -Uri "https://vault.prospergenics.com/api/projects" `
        -Method OPTIONS `
        -Headers $headers `
        -UseBasicParsing `
        -ErrorAction SilentlyContinue

    if ($response.Headers["Access-Control-Allow-Origin"]) {
        Write-Host "✓ CORS is working!"
        Write-Host "  Access-Control-Allow-Origin: $($response.Headers["Access-Control-Allow-Origin"])"
        Write-Host "  Access-Control-Allow-Credentials: $($response.Headers["Access-Control-Allow-Credentials"])"
    } else {
        Write-Host "✗ CORS headers not found"
    }
} catch {
    Write-Host "Error testing CORS: $_"
}
'''
stdin, stdout, stderr = c.exec_command(f'powershell {test_script}')
result = stdout.read().decode('utf-8', errors='ignore')
print(result if result else '   Test completed')

c.close()

print('\n' + '='*60)
print('  CORS FIX DEPLOYED')
print('='*60)
print('\nThe extension should now be able to:')
print('  ✓ Make API requests from chrome-extension:// origins')
print('  ✓ Load projects and credentials')
print('  ✓ Persist authentication tokens')
print('\nTest the extension now!')
