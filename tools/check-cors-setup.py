"""Check CORS setup and deployed extension structure"""
import paramiko

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('CORS and Extension Structure Check')
print('='*60)

# Check extension deployment structure
print('\n1. Checking extension directory structure...')
stdin, stdout, stderr = c.exec_command('dir C:\\inetpub\\vault.prospergenics.com\\wwwroot\\extension /s /b')
structure = stdout.read().decode('utf-8', errors='ignore')
print('   Files deployed:')
for line in structure.split('\n')[:15]:
    if line.strip():
        print(f'   - {line.strip()}')

# Check Program.cs CORS configuration
print('\n2. Checking Program.cs CORS policy...')
stdin, stdout, stderr = c.exec_command('powershell Select-String -Path C:\\inetpub\\vault.prospergenics.com\\Program.cs -Pattern "AddCors|AllowAnyOrigin|WithOrigins" -Context 2,2')
cors_config = stdout.read().decode('utf-8', errors='ignore')
if cors_config:
    print('   Found CORS configuration:')
    print(cors_config[:800])
else:
    print('   Program.cs not found or no CORS configuration')
    # Try checking if Program.cs exists
    stdin, stdout, stderr = c.exec_command('powershell Test-Path C:\\inetpub\\vault.prospergenics.com\\Program.cs')
    exists = stdout.read().decode('utf-8', errors='ignore').strip()
    print(f'   Program.cs exists: {exists}')

print('\n3. Checking deployed DLL for CORS policy...')
print('   (CORS is compiled into the DLL, not in a config file)')

# Check response headers from API
print('\n4. Testing API CORS headers...')
test_script = '''
$response = Invoke-WebRequest -Uri "https://vault.prospergenics.com/api/projects" `
    -Method OPTIONS `
    -Headers @{"Origin"="chrome-extension://test"} `
    -UseBasicParsing `
    -ErrorAction SilentlyContinue

if ($response) {
    Write-Host "Status: $($response.StatusCode)"
    Write-Host "CORS Headers:"
    $response.Headers.GetEnumerator() | Where-Object { $_.Key -like "*Access-Control*" } | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)"
    }
} else {
    Write-Host "No response or error"
}
'''
stdin, stdout, stderr = c.exec_command(f'powershell {test_script}')
result = stdout.read().decode('utf-8', errors='ignore')
print(result if result else '   No response')

c.close()

print('\n' + '='*60)
print('DIAGNOSIS:')
print('Browser extensions need CORS to be configured to allow:')
print('- AllowAnyOrigin() OR')
print('- Specific chrome-extension:// origins')
