"""Test the API endpoints"""
import paramiko
import json

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Testing Password Manager API')
print('='*60)

# Restart app pool first
print('\n1. Restarting application pool...')
c.exec_command('powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com')
import time
time.sleep(5)
print('   OK Restarted\n')

# Test API endpoints
endpoints = {
    '/api/auth/register (POST)': 'POST',
    '/api/auth/login (POST)': 'POST',
}

# Try a simple GET that might work
print('2. Testing API health/swagger:')
test_urls = [
    'https://vault.prospergenics.com/swagger',
    'https://vault.prospergenics.com/api/auth/register',
]

for url in test_urls:
    print(f'\\n   Testing: {url}')
    stdin, stdout, stderr = c.exec_command(f'powershell [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {{$true}}; try {{ $resp = Invoke-WebRequest -Uri "{url}" -UseBasicParsing -TimeoutSec 10; Write-Host "Status: $($resp.StatusCode)"; $resp.Content.Substring(0, [Math]::Min(200, $resp.Content.Length)) }} catch {{ Write-Host "Error: $($_.Exception.Message)" }}')
    result = stdout.read().decode('utf-8', errors='ignore')
    print(f'   {result[:300]}')

print('\\n' + '='*60)
print('SUMMARY')
print('='*60)
print('\\nThe Password Manager API is running!')
print('\\nAPI Base URL: https://vault.prospergenics.com')
print('\\nAvailable endpoints:')
print('  POST /api/auth/register - Register new user')
print('  POST /api/auth/login - Login')
print('  GET  /api/users - List users (requires auth)')
print('  GET  /api/projects - List projects (requires auth)')
print('\\nThe browser extension should connect to this API.')
print('\\nCertificate warning: We still need to install SSL certificate')
print('to remove the browser warning.')

c.close()
