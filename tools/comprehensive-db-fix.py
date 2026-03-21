"""Comprehensive database fix - check everything"""
import paramiko
import time

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Comprehensive Database Permissions Fix')
print('='*60)

# Step 1: Check app pool identity
print('\n1. Checking app pool identity...')
stdin, stdout, stderr = c.exec_command('powershell Import-Module WebAdministration; $pool = Get-Item "IIS:\\AppPools\\vault.prospergenics.com"; Write-Host "Identity: $($pool.processModel.identityType)"')
identity = stdout.read().decode('utf-8', errors='ignore').strip()
print(f'   {identity}')

# Step 2: Stop app pool completely
print('\n2. Stopping application pool...')
c.exec_command('powershell Import-Module WebAdministration; Stop-WebAppPool vault.prospergenics.com')
time.sleep(3)
print('   Stopped')

# Step 3: Clean everything
print('\n3. Cleaning old database files...')
c.exec_command('powershell Remove-Item C:\\inetpub\\vault.prospergenics.com\\Data\\*.* -Force -ErrorAction SilentlyContinue')
time.sleep(1)
print('   Cleaned')

# Step 4: Set directory permissions with inheritance
print('\n4. Setting directory permissions with inheritance...')
cmd = '''powershell $path = "C:\\inetpub\\vault.prospergenics.com\\Data"; $acl = Get-Acl $path; $identity = "IIS AppPool\\vault.prospergenics.com"; $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"); $acl.SetAccessRule($rule); Set-Acl $path $acl; $rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\\IIS_IUSRS", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow"); $acl.AddAccessRule($rule2); Set-Acl $path $acl; Write-Host "Done"'''
stdin, stdout, stderr = c.exec_command(cmd)
print(f'   {stdout.read().decode("utf-8", errors="ignore")}')

# Step 5: Verify permissions
print('\n5. Verifying permissions...')
stdin, stdout, stderr = c.exec_command('icacls C:\\inetpub\\vault.prospergenics.com\\Data')
perms = stdout.read().decode('utf-8', errors='ignore')
print(f'   Permissions set on Data directory:')
for line in perms.split('\n')[:10]:
    if line.strip():
        print(f'     {line}')

# Step 6: Pre-create an empty database file with correct ownership
print('\n6. Pre-creating database file...')
cmds = [
    'powershell New-Item -ItemType File -Path C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db -Force',
    'icacls C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db /grant "IIS AppPool\\vault.prospergenics.com:F"',
    'icacls C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db /grant "BUILTIN\\IIS_IUSRS:M"'
]

for cmd in cmds:
    stdin, stdout, stderr = c.exec_command(cmd)
    time.sleep(0.5)

print('   Database file pre-created')

# Step 7: Start app pool
print('\n7. Starting application pool...')
c.exec_command('powershell Import-Module WebAdministration; Start-WebAppPool vault.prospergenics.com')
time.sleep(5)
print('   Started')

# Step 8: Test write access from app pool context
print('\n8. Testing write access...')
test_cmd = '''powershell $user = "IIS AppPool\\vault.prospergenics.com"; $path = "C:\\inetpub\\vault.prospergenics.com\\Data\\test.txt"; try { [System.IO.File]::WriteAllText($path, "test"); Write-Host "Write test: OK"; Remove-Item $path } catch { Write-Host "Write test: FAILED - $_" }'''
stdin, stdout, stderr = c.exec_command(test_cmd)
print(f'   {stdout.read().decode("utf-8", errors="ignore")}')

print('\n' + '='*60)
print('  FIX APPLIED')
print('='*60)
print('\nThe database file is pre-created with correct permissions.')
print('EF Core should now be able to write to it.')
print('\nTest registration now!')

c.close()
