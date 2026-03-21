"""Fix CORS on Brand2Boost server by updating web.config"""
import paramiko
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

# First, also check if there's a custom env variable resolution
# Check appsettings.Secrets.json for ApiSettings section
print("=== Checking if ApiCorsOrigin is in secrets ===")
stdin, stdout, stderr = ssh.exec_command(
    'powershell -Command "Get-Content C:\\stores\\brand2boost\\backend\\appsettings.Secrets.json | Select-String -Pattern \'Cors\'"'
)
print(stdout.read().decode('utf-8', errors='replace'))

# The fix: Add CORS origin to appsettings.Secrets.json
# Read current secrets file
sftp = ssh.open_sftp()
with sftp.open('C:/stores/brand2boost/backend/appsettings.Secrets.json', 'r') as f:
    secrets_content = f.read().decode('utf-8-sig')

print(f"Current secrets has ApiCorsOrigin: {'ApiCorsOrigin' in secrets_content}")
print(f"Current secrets has SignalRHubCorsOrigin: {'SignalRHubCorsOrigin' in secrets_content}")

import json
secrets = json.loads(secrets_content)

# Add CORS configuration to secrets so it overrides the ${VAR} placeholders
if 'ApiSettings' not in secrets:
    secrets['ApiSettings'] = {}

secrets['ApiSettings']['ApiCorsOrigin'] = 'https://localhost:5173;http://localhost:5173;https://localhost:5174;http://localhost:5174;https://app.brand2boost.com'
secrets['ApiSettings']['SignalRHubCorsOrigin'] = 'https://localhost:5173;http://localhost:5173;https://localhost:5174;http://localhost:5174;https://app.brand2boost.com'

# Write back
updated = json.dumps(secrets, indent=2)
with sftp.open('C:/stores/brand2boost/backend/appsettings.Secrets.json', 'w') as f:
    f.write(updated)

print("\nUpdated appsettings.Secrets.json with explicit CORS origins")

# Verify
with sftp.open('C:/stores/brand2boost/backend/appsettings.Secrets.json', 'r') as f:
    verify = f.read().decode('utf-8')

if 'app.brand2boost.com' in verify and 'ApiCorsOrigin' in verify:
    print("VERIFIED: CORS origins present in secrets file")
else:
    print("WARNING: CORS origins NOT found in verification")

sftp.close()

# Now restart the IIS app pool to pick up the new config
print("\nRestarting Brand2boost app pool...")
stdin, stdout, stderr = ssh.exec_command(
    'powershell -Command "Import-Module WebAdministration; Restart-WebAppPool -Name Brand2boost; Write-Host \'App pool restarted\'"'
)
out = stdout.read().decode('utf-8', errors='replace')
err = stderr.read().decode('utf-8', errors='replace')
print(f"Output: {out}")
if err:
    print(f"Error: {err}")

# Wait a moment for restart
import time
time.sleep(5)

# Test CORS again
print("\n=== Testing CORS after fix ===")
ssh2 = paramiko.SSHClient()
ssh2.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh2.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

# Quick test using curl if available, or PowerShell
ps_test = r'''
try {
    $uri = "https://api.brand2boost.com/api/auth/login"
    $headers = @{
        "Origin" = "https://app.brand2boost.com"
        "Access-Control-Request-Method" = "POST"
        "Access-Control-Request-Headers" = "content-type"
    }
    $response = Invoke-WebRequest -Uri $uri -Method OPTIONS -Headers $headers -UseBasicParsing -TimeoutSec 10
    Write-Host "Status: $($response.StatusCode)"
    foreach ($h in $response.Headers.GetEnumerator()) {
        if ($h.Key -like "*Access*" -or $h.Key -like "*Origin*") {
            Write-Host "  $($h.Key): $($h.Value)"
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
'''
stdin, stdout, stderr = ssh2.exec_command(f'powershell -Command "{ps_test}"')
out = stdout.read().decode('utf-8', errors='replace')
err = stderr.read().decode('utf-8', errors='replace')
print(f"OPTIONS test: {out}")
if err and 'error' in err.lower():
    print(f"Stderr: {err[:300]}")

ssh2.close()
ssh.close()
print("\nDone")
